<!--- make sure user has permission to access this function --->
<cfif Not IsDefined("checkPermissionFunction")>
	<cfif IsDefined("url.adminFunction")>
		<cfset checkPermissionFunction = url.adminFunction>
	<cfelse>
		<cfset checkPermissionFunction = "">
		<cfif Not IsDefined("checkPermissionPage")>
			<cfset checkPermissionPage = REReplace(cgi.script_name,"/.+/","")>
		</cfif>
	</cfif>
</cfif>
<cfif glb_User.super neq 1>
	<cfquery name="checkPermission" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT
			<cfif Request.dbtype is not "mysql">TOP 1</cfif>
			al.linkID
		FROM #Request.dbprefix#_links al inner join #Request.dbprefix#_userLinks aul on al.linkID = aul.linkID
		WHERE userID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">
			<cfif checkPermissionFunction is not "">
				and href like <cfqueryparam cfsqltype="cf_sql_varchar" value="%index.cfm?%adminFunction=#UrlEncodedFormat(checkPermissionFunction)#%">
			<cfelse>
				and href like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#checkPermissionPage#%">
			</cfif>
		<cfif Request.dbtype is "mysql">LIMIT 1</cfif>
	</cfquery>
	<cfif checkPermission.recordCount is 0>
		<cfset pg_title = "Permission Denied">
		<cfinclude template="header.cfm">
		You do not have permission to access this page.
		<cfinclude template="footer.cfm">
		<cfabort>
	</cfif>
</cfif>
