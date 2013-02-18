<!---
Functions for initializing Lighthouse
--->

<cffunction name="ApplicationIsInitialized" output="false" returntype="boolean"
	description="Tests whether the application has been initialized yet.">
	<cfreturn Not StructKeyExists(url,"lh_Initialize") and StructKeyExists(application,"TimeInitialized")>
</cffunction>

<cffunction name="InitializeApplication" output="false" returntype="void"
	description="Initializes a Lighthouse application.">
	<!--- Set path to cfcs --->
	<cfif Len(Request.AppVirtualPath) gt 0>	
		<cfset Application.ComponentPath = "#Replace(Replace(Request.AppVirtualPath, "/", ""), "/", ".", "all")#.Lighthouse.Components">
		<cfset Application.PhysicalPath = ExpandPath(Request.AppVirtualPath)>
	<cfelse>
		<cfset Application.ComponentPath = "Lighthouse.Components">
		<cfset Application.PhysicalPath = ExpandPath("/")>
	</cfif>
	
	<!--- Set up Google Analytics include. --->
	<cfset Application.GoogleAnalyticsInclude = "">
	<cfif StructKeyExists(Application,"GoogleAnalyticsAcctNum")>
		<cfif Len(Application.GoogleAnalyticsAcctNum) gt 0>
			<cfsavecontent variable="Application.GoogleAnalyticsInclude">
				<cfoutput><script src="https://ssl.google-analytics.com/urchin.js" type="text/javascript"></script>
				<script type="text/javascript">_uacct = "#Application.GoogleAnalyticsAcctNum#";urchinTracker();</script></cfoutput>
			</cfsavecontent>
		</cfif>
	</cfif>
	
	<!--- Error message. This string will be evaluated at run-time. --->
	<cfsavecontent variable="Application.ErrorMessage">
		<html>
		<head>
		<title>#Request.glb_title#: An Error Occurred</title>
		<link rel=stylesheet href="#Request.AppVirtualPath#/style.css" type="text/css">
		<style>body {margin:20px;}</style>
		</head>
		<body class=NORMALTEXT>
			<div class="title">We're sorry -- An Error Occurred</div>
			<div class="body">We apologize for the error. The website administrator has been notified and we will address the problem as soon as we can. Please try the site again later.</div>
			<cfif StructKeyExists(Request,"lh_showErrorInfo") and Request.lh_showErrorInfo>
				#errorInfo#
			</cfif>
		</body>
		</html>
	</cfsavecontent>

	<cfset StructDelete(session,"User")>

	<cfset Application.LoginTemplate="Lighthouse/templates/login.cfm">

	<!--- Create global objects --->
	<cfobject name="Application.Lighthouse" component="#Application.ComponentPath#.Lighthouse">
	<cfobject name="Application.Json" component="#Application.ComponentPath#.json">
	<cfobject name="Application.PageAudit" component="#Application.ComponentPath#.PageAudit">
	<cfobject name="Application.UserGroup" component="#Application.ComponentPath#.UserGroup">
	<cfobject name="Application.Status" component="#Application.ComponentPath#.Status">
	<cfobject name="Application.Topic" component="#Application.ComponentPath#.Topic">
	<cfobject name="Application.Section" component="#Application.ComponentPath#.Section">
	<cfparam name="Application.TempDirectory" default="#GetTempDirectory()#">
	<cfset Application.Tables = StructNew()>
	
	<cfobject name="Application.Tables.Pages" component="#Application.ComponentPath#.Table">
	<cfset Application.Tables.Pages = Application.Lighthouse.AddTable(table="#Request.dbprefix#_Pages")>
	<cfset Application.Tables.Pages.AddColumn(ColName="PageID",Type="integer",PrimaryKey="true")>
	<cfset Application.Tables.Pages.AddColumn(ColName="Name",Type="text")>
	<cfset Application.Tables.Pages.AddColumn(ColName="Title",Type="text")>
	<cfset Application.Tables.Pages.AddColumn(ColName="NavTitle",Type="text")>
	<cfset Application.Tables.Pages.AddColumn(ColName="ShowInNav",Type="checkbox",OnValue="1",OffValue="0")>
	<cfset Application.Tables.Pages.AddColumn(ColName="TitleTag",Type="text")>

	<cfset Application.TimeInitialized = Now()>
</cffunction>
