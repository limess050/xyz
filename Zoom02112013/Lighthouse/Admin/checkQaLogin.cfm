<!--- 
Check for QA login.  
This is used during development to password
protect the entire site.  Note that lh_authType must be set to "basic",
and IIS authentication must be turned off. 
--->
<cfscript>
if (Not IsDefined("session.qaUserID")) {
	lh_getClientInfo("qaUserID");
}
</cfscript>
<cfif Len(session.qaUserID) is 0>
	<cfif Request.lh_authType is "basic">
		<cflogin>
			<cfif IsDefined("cflogin")>
				<cfquery name="getUser" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT userID FROM #lighthouse_getTableName("Users")#
					WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(cflogin.name)#"> 
						and password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(cflogin.password)#"> 
						and active = 1
				</cfquery>
				<cfif getUser.recordCount gt 0>
					<cfset session.qaUserID = getUser.userID>
				<cfelse>
					<!--- authentication failed - send back 401 --->
					<cfsetting enablecfoutputonly="yes" showdebugoutput="no">
					<cfheader statuscode="401">
					<cfheader name="WWW-Authenticate" value="Basic realm=""#Request.glb_title# QA Site""">
					<cfoutput><cfinclude template="login.cfm"></cfoutput>
					<cfabort>
				</cfif>
			<cfelse>
				<!--- authentication failed - send back 401 --->
				<cfsetting enablecfoutputonly="yes" showdebugoutput="no">
				<cfheader statuscode="401">
				<cfheader name="WWW-Authenticate" value="Basic realm=""#Request.glb_title# QA Site""">
				<cfoutput><cfinclude template="login.cfm"></cfoutput>
				<cfabort>
			</cfif>
		</cflogin>
	</cfif>
</cfif>