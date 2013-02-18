<!---
Index List template
Same as default template, except that it includes a list of all child pages after content.
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfsilent>
	<cfquery name="childlist" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT p.pageID as listPageID, p.name as listName, coalesce(mp.title,p.title,mp.navTitle,p.navTitle) as listTitle
		FROM #Request.dbprefix#_Pages_Live p left join #Request.dbprefix#_Pages_Live mp on p.masterPageID = mp.pageID
		WHERE p.parentPageID = <cfqueryparam value="#pageID#" cfsqltype="CF_SQL_INTEGER">
		ORDER BY p.OrderNum
	</cfquery>
	<cfif variables.membersOnly is 1>
		<cfset rssLink = Request.AppVirtualPath & "/Lighthouse/rss.cfm?parentPageID=#pageID#&amp;#Application.Lighthouse.lh_getAuthToken()#">
	<cfelse>
		<cfset rssLink = Request.AppVirtualPath & "/Lighthouse/rss.cfm?parentPageID=#pageID#">
	</cfif>
</cfsilent>

<cfinclude template="header.cfm">

<lh:MS_SitePagePart id="title" class="title">
<lh:MS_SitePagePart id="body" class="body">

<ul>
<cfoutput query="childlist">
	<li><a href="#lh_getPageLink(listPageID,listName)#" target="_top">#listTitle#</a>
</cfoutput>
</ul>

<cfoutput>
<link rel="alternate" type="application/rss+xml" title="#variables.title# RSS Feed" href="#rssLink#">
<p align=right><a href="#rssLink#"><img src="../Lighthouse/Resources/images/rss.gif" alt="RSS Feed" border="0"></p>
</cfoutput>

<cfinclude template="footer.cfm">