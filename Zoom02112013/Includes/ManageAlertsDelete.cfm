<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfset allFields="ConfirmationID,AlertSectionID">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="AlertSectionID">

<cfif Len(ConfirmationID) and Len(AlertSectionID)>
	<cfquery name="ConfirmAlertSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select AlertSectionID
		From AlertSections
		Where AlertSectionID = <cfqueryparam value="#AlertSectionID#" cfsqltype="CF_SQL_INTEGER">
		and AlertID in (Select AlertID from Alerts Where ConfirmationID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ConfirmationID#">)
	</cfquery>
	<cfif ConfirmAlertSection.RecordCount>
		<cfquery name="DeleteAlertSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Delete From AlertSectionCategories
			Where AlertSectionID = <cfqueryparam value="#AlertSectionID#" cfsqltype="CF_SQL_INTEGER">
			
			Delete From AlertSectionLocations
			Where AlertSectionID = <cfqueryparam value="#AlertSectionID#" cfsqltype="CF_SQL_INTEGER">
			
			Delete From AlertSections
			Where AlertSectionID = <cfqueryparam value="#AlertSectionID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cfif>
	<cflocation url="page.cfm?PageID=#Request.ManageAlertPageID#&ConfirmationID=#ConfirmationID#" addToken="No">
	<cfabort>
<cfelseif Len(ConfirmationID)>
	<cflocation url="page.cfm?PageID=#Request.ManageAlertPageID#&ConfirmationID=#ConfirmationID#" addToken="No">
	<cfabort>
<cfelse>
	<cflocation url="page.cfm?PageID=#Request.ManageAlertPageID#" addToken="No">
	<cfabort>
</cfif>