<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfset allFields="ConfirmationID,AlertSectionID">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="AlertSectionID">

<cfparam name="ShowLocations" default="1">
<cfparam name="ShowPriceRanges" default="0">
<cfparam name="LimitSelectionCount" default="0">

<cfquery name="Locations" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select LocationID as SelectValue, Title as SelectText
	From Locations
	Where Active=1
	Order by Title
</cfquery>

<cfif Len(ConfirmationID) and Len(AlertSectionID)>
	<cfquery name="ConfirmAlertSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select AlertSectionID, SectionID, PriceMinUS, PriceMaxUS, PriceMinTZS, PriceMaxTZS
		From AlertSections
		Where AlertSectionID = <cfqueryparam value="#AlertSectionID#" cfsqltype="CF_SQL_INTEGER">
		and AlertID in (Select AlertID from Alerts Where ConfirmationID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ConfirmationID#">)
	</cfquery>
	<cfif ConfirmAlertSection.RecordCount>
		<cfset i = ConfirmAlertSection.SectionID>
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