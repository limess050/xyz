<cfset checkPermissionFunction = "editPage">
<cfinclude template="checkPermission.cfm">

<cfparam name="pageID" default="">
<cfparam name="pageArchiveID" default="">
<cfif Len(pageArchiveID) is 0>
	<!--- Check to see if a live page exists --->
	<cfquery name="checkLive" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT pageID 
		FROM #Request.dbprefix#_Pages_Live 
		WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
	</cfquery>
	<cfif checkLive.recordcount is 0>
		<cfquery name="checkArchive" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT top 1 pageArchiveID
			FROM #Request.dbprefix#_Pages_Archive
			WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
			ORDER BY dateModified desc
		</cfquery>
		<cfif checkArchive.recordcount gt 0>
			<cfset pageArchiveID = checkArchive.pageArchiveID>
		</cfif>
	</cfif>
</cfif>

<html>
<head>
<title>Content Administration</title>
<cfoutput>
<script type="text/javascript"><!--
var MCFResourcesPath = "#Request.AppVirtualPath#/Lighthouse/Resources";
//--></script>
<script type="text/javascript" src="#Request.AppVirtualPath#/Lighthouse/dojo/dojo.js"></script>
<script type="text/javascript" src="#Request.AppVirtualPath#/Lighthouse/Resources/js/library.js"></script>
<script type="text/javascript" src="#Request.AppVirtualPath#/Lighthouse/Resources/js/wysiwyg.js"></script>
</head>

<frameset name="mainFrameset" rows="38,*" frameborder=1 marginwidth=0 marginheight=0>
	<frame src="index.cfm?adminFunction=versionsToolbar&pageID=#pageID#&pageArchiveID=#pageArchiveID#" name="toolbar" scrolling="auto" frameborder=1 marginwidth=1 marginheight=1>
	<frame src="../page.cfm?pageID=#pageID#&pageArchiveID=#pageArchiveID#" name="page" frameborder=1 marginwidth=0 marginheight=0>
</frameset>
</cfoutput>
<body>
</body>
</html>