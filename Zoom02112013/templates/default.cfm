<!---
Default Template
This template expects a CategoryID
--->



<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfquery name="getImpressionSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SectionID
	From PageSections
	Where PageID = <cfqueryparam value="#PageID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfset ImpressionSectionID=getImpressionSection.SectionID>
<cfif not Len(ImpressionSectionID)>
	<cfset ImpressionSectionID = 0>
</cfif>

<cfif not IsDefined('application.SectionImpressions')>
	<cfset application.SectionImpressions= structNew()>
</cfif>
<cfif StructKeyExists(application.SectionImpressions,ImpressionSectionID)>
	<cfset application.SectionImpressions[ImpressionSectionID] = application.SectionImpressions[ImpressionSectionID] + 1>
<cfelse>
	<cfset application.SectionImpressions[ImpressionSectionID] = 1>
</cfif>

<cfinclude template="header.cfm">

<cfoutput>
<div class="centercol-inner legacy">
 	<h1><lh:MS_SitePagePart id="title" class="title"></h1>
	<p>&nbsp;</p>

 	<div class="breadcrumb""><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/">Home</a> &gt; </div>

</cfoutput>

	<lh:MS_SitePagePart id="body" class="body">

</div>

<!-- END CENTER COL -->

<cfinclude template="footer.cfm">
