<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfset allFields="ConfirmationID,AlertID">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="AlertID">

<cfif Len(ConfirmationID) and Len(AlertID)>
	<cfquery name="ConfirmAlert" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select AlertID 
		from Alerts
		Where ConfirmationID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ConfirmationID#">
		and AlertID = <cfqueryparam value="#AlertID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif ConfirmAlert.RecordCount>
		<cfquery name="DeleteAllRelatedRecords" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Delete From AlertSectionCategories
			Where AlertSectionID in (Select AlertSectionID From AlertSections Where AlertID = <cfqueryparam value="#AlertID#" cfsqltype="CF_SQL_INTEGER">)			
			
			Delete From AlertSectionLocations
			Where AlertSectionID in (Select AlertSectionID From AlertSections Where AlertID = <cfqueryparam value="#AlertID#" cfsqltype="CF_SQL_INTEGER">)
		</cfquery>
		<cfquery name="DeleteAllAlertSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Delete From AlertSections
			Where AlertID = <cfqueryparam value="#AlertID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cfif>

	<cflocation url="#lh_getPageLink(7,'MyAccount')#" addToken="No">
	<cfabort>
<cfelseif Len(ConfirmationID)>
	<cflocation url="#lh_getPageLink(Request.ManageAlertPageID,'manageAlerts')#?ConfirmationID=#ConfirmationID#" addToken="No">
	<cfabort>
<cfelse>
	<cflocation url="#lh_getPageLink(Request.ManageAlertPageID,'manageAlerts')#" addToken="No">
	<cfabort>
</cfif>