<!---
News Home template
Appropriate for as a home page for child pages using the News Article template.
Displays a list of child pages, including the date field for articles.
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfquery name="childlist" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT p.pageID as listPageID, 
		p.name as listName,
		coalesce(mp.title,p.title,mp.navTitle,p.navTitle) as listTitle,
		(SELECT shortValue FROM #Request.dbprefix#_PageParts_Live WHERE pageID = p.pageID and label = 'NEWSDATE') as newsDate
	FROM #Request.dbprefix#_Pages_Live p left join #Request.dbprefix#_Pages_Live mp on p.masterPageID = mp.pageID
	WHERE p.parentPageID = <cfqueryparam value="#pageID#" cfsqltype="CF_SQL_INTEGER">
	ORDER BY p.OrderNum
</cfquery>

<cfinclude template="header.cfm">

<lh:MS_SitePagePart id="title" class="title">
<lh:MS_SitePagePart id="body" class="body">

<ul id="newsArticleList">
<cfoutput query="childlist">
	<li><a href="#lh_getPageLink(listPageID,listName)#" target="_top"><i>#newsDate#:</i> #listTitle#</a>
</cfoutput>
</ul>

<cfinclude template="footer.cfm">
