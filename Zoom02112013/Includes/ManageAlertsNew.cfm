<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfset allFields="ConfirmationID,NewAlertSectionID">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="NewAlertSectionID">

<cfparam name="ShowLocations" default="1">
<cfparam name="ShowPriceRanges" default="0">
<cfparam name="LimitSelectionCount" default="0">

<cfquery name="Locations" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select LocationID as SelectValue, Title as SelectText
	From Locations
	Where Active=1
	Order by Title
</cfquery>

<cfif Len(ConfirmationID) and Len(NewAlertSectionID)>
	<cfquery name="ConfirmAlert" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select AlertID
		From Alerts
		Where ConfirmationID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ConfirmationID#">
	</cfquery>
	<cfif ConfirmAlert.RecordCount>
		<cfset i = NewAlertSectionID>
		<cfinclude template="AlertSectionForm.cfm">		
	<cfelse>
		<cflocation url="page.cfm?PageID=#Request.ManageAlertPageID#&ConfirmationID=#ConfirmationID#" addToken="No">
		<cfabort>
	</cfif>
<cfelseif Len(ConfirmationID)>
	<cflocation url="page.cfm?PageID=#Request.ManageAlertPageID#&ConfirmationID=#ConfirmationID#" addToken="No">
	<cfabort>
<cfelse>
	<cflocation url="page.cfm?PageID=#Request.ManageAlertPageID#" addToken="No">
	<cfabort>
</cfif>