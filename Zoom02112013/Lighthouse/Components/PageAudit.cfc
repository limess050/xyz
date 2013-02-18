<cfcomponent name="PageAudit" hint="Tracks changes to pages." extends="Object">

	<cffunction name="InsertRow" description="Inserts a row in the PageAudit table" output="false" returntype="boolean">
		<cfargument name="PageID" type="numeric" required="true">
		<cfargument name="PageName" type="string" required="true">
		<cfargument name="User" type="User" required="true">
		<cfargument name="delete" type="numeric" default="0">
		<cfargument name="insert" type="numeric" default="0">
		<cfargument name="deactivate" type="numeric" default="0">
		<cfargument name="restoreAsWorking" type="numeric" default="0">
		<cfargument name="restoreAsLive" type="numeric" default="0">
		<cfargument name="statusID" type="numeric" default="0">
		<cfargument name="pageArchiveID" type="numeric" default="0">

		<cfset var name = "#Arguments.user.firstName# #Arguments.user.lastName#">
		<cfset var action = "">
		
		<cfif Arguments.insert gt 0>
			<cfset action = "added page ""#Arguments.pageName#""">
		<cfelseif Arguments.delete gt 0>
			<cfset action = "deleted page ""#Arguments.pageName#""">
		<cfelseif Arguments.deactivate gt 0>
			<cfset action = "deactivated page ""#Arguments.pageName#""">
		<cfelseif Arguments.restoreAsWorking gt 0>
			<cfif Arguments.pageArchiveID gt 0>
				<cfset action = "restored archive id #Arguments.pageArchiveID# of page ""#Arguments.pageName#"" as a working page">
			<cfelse>
				<cfset action = "restored the live version of page ""#Arguments.pageName#"" as a working page">
			</cfif>
		<cfelseif Arguments.restoreAsLive gt 0>
			<cfset action = "restored archive id #Arguments.pageArchiveID# of page ""#Arguments.pageName#"" as a live page">
		<cfelseif Arguments.statusID gt 0>
			<cfquery name="getStatusName" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT descr FROM #Request.dbprefix#_Statuses 
				WHERE statusID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Arguments.statusID#">
			</cfquery>
			<cfset action = "saved page ""#Arguments.pageName#"" with status ""#getStatusName.descr#""">
		<cfelse>
			<cfset action = "updated the properties of page ""#Arguments.pageName#""">
		</cfif>
		
		<cfset actionDescr = "User ""#name#"" #action#">
		
		<cfquery name="recordAction" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			INSERT INTO #Request.dbprefix#_Pages_Audit (
				PageID, UserID, StatusID, PageInsert, PageDelete, ActionDate, ActionDescr
			) VALUES (
				<cfqueryparam cfsqltype="cf_sql_integer" value="#Arguments.pageID#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#Arguments.user.UserID#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#Arguments.statusID#">,
				<cfqueryparam cfsqltype="cf_sql_bit" value="#Arguments.insert#">,
				<cfqueryparam cfsqltype="cf_sql_bit" value="#Arguments.delete#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#actionDescr#">
			)
		</cfquery>
		<cfreturn true>
	</cffunction>
</cfcomponent>