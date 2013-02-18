<!---
Index List template
Same as default template, except that it includes a list of all child pages after content.
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfquery name="childlist" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT p.pageID as listPageID, p.name as listName, coalesce(mp.title,p.title,mp.navTitle,p.navTitle) as listTitle
	FROM #Request.dbprefix#_Pages_Live p left join #Request.dbprefix#_Pages_Live mp on p.masterPageID = mp.pageID
	WHERE p.parentPageID = <cfqueryparam value="#pageID#" cfsqltype="CF_SQL_INTEGER">
	ORDER BY p.OrderNum
</cfquery>

<cfinclude template="header.cfm">

<lh:MS_SitePagePart id="title" class="title">
<lh:MS_SitePagePart id="body" class="body">

<ul>
<cfoutput query="childlist">
	<li><a href="#lh_getPageLink(listPageID,listName)#" target="_top">#listTitle#</a>
</cfoutput>
</ul>

<cfinclude template="footer.cfm">
