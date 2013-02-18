<!---
RSS 2.0 File for site
Helpful RSS 2.0 Specifications are at: http://www.rssboard.org/rss-specification

Whole site RSS feed is appropriate for submitting to search engines:
Yahoo: http://submit.search.yahoo.com/free/request
Google: https://www.google.com/webmasters/sitemaps
--->

<cfset edit = false>

<!--- Parent page RSS feed --->
<cfif IsDefined("url.parentPageID")>
	<cfquery name="getParentPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT pageID, title, dateModified, membersOnly
		FROM #Request.dbprefix#_Pages_Live 
		WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.parentPageID#">
	</cfquery>
	<cfset infoLevel = "full">
	<cfif getParentPage.recordCount gt 0>
		<cfset variables.title = getParentPage.title>
		<cfset variables.link = Request.httpUrl & "/page.cfm?pageID=" & url.parentPageID>
		<cfif getParentPage.membersOnly is 1>
			<cfinclude template="Lighthouse/Admin/checklogin.cfm">
			<cfset variables.link = variables.link & "&amp;" & Application.Lighthouse.lh_getAuthToken()>
		</cfif>
		<cfset variables.description = getParentPage.title>
		<cfquery name="getPages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT p.pageID, 
				p.name as name, 
				coalesce(mp.title,p.title,mp.navTitle,p.navTitle) as title, 
				p.dateModified, 
				p.membersOnly
			FROM #Request.dbprefix#_Pages_Live p left join #Request.dbprefix#_Pages_Live mp on p.masterPageID = mp.pageID
			WHERE p.parentPageID = <cfqueryparam value="#parentPageID#" cfsqltype="CF_SQL_INTEGER">
			ORDER BY p.OrderNum
		</cfquery>
	<cfelse>
		<cfset variables.title = "">
		<cfset variables.link = Request.httpUrl & "/page.cfm?pageID=" & url.parentPageID>
		<cfset variables.description = "">
	</cfif>

<!--- Whole site RSS feed --->
<cfelse>
	<cfset variables.title = Request.glb_title>
	<cfset variables.link = Request.httpUrl & "/Lighthouse/rss.cfm">
	<cfset variables.description = "Modern Signal is a full-service consulting firm offering project management, graphic design, programming and database services to both corporate and non-profit clients.">
	<cfset infoLevel = "min">
	<cfquery name="getPages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT pageID, name, title, dateModified, membersOnly
		FROM #Request.dbprefix#_Pages_Live 
		WHERE membersOnly = 0
	</cfquery>
</cfif>

<cfcontent type="text/xml" reset="Yes"><?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet href="<cfoutput>#Request.httpUrl#</cfoutput>/Lighthouse/Resources/xml/rss2.xsl" type="text/xsl" media="screen"?>
<rss version="2.0">
<channel>
	<cfoutput>
		<title>#variables.title#</title>
		<link>#variables.link#</link>
		<description>#variables.description#</description>
		<language>en-us</language>
		<copyright>Copyright 2004-#DateFormat(Now(),"yyyy")# Modern Signal, LLC</copyright>
		<generator>Modern Signal Lighthouse</generator>
	</cfoutput>
	<cfif IsDefined("getPages")><cfoutput query="getPages">
		<cfset link = "#Request.httpUrl##lh_getPageLink(pageID,name)#">
		<item>
			<link><cfif membersOnly is 1>#lh_addAuthToken(link)#<cfelse>#link#</cfif></link>
			<title>#title#</title>
			<pubDate>#rssDateFormat(dateModified)#</pubDate>
			<cfif infoLevel is "full">
				<guid>#link# #rssDateFormat(dateModified)#</guid>
			</cfif>
		</item>
	</cfoutput></cfif>
</channel>
</rss>
