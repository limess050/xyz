<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfset allFields="ConfirmationID,AlertSectionID,CategoryIDs,LocationIDs,PriceMinUS,PriceMaxUS,PriceMinTZS,PriceMaxTZS">
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
		<cfquery name="UpdateAlertSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update AlertSections
			Set PriceMinUS = <cfif Len(PriceMinUS)><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#PriceMinUS#"><cfelse>null</cfif>,
			PriceMaxUS = <cfif Len(PriceMaxUS)><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#PriceMaxUS#"><cfelse>null</cfif>,
			PriceMinTZS = <cfif Len(PriceMinTZS)><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#PriceMinTZS#"><cfelse>null</cfif>,
			PriceMaxTZS = <cfif Len(PriceMaxTZS)><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#PriceMaxTZS#"><cfelse>null</cfif>
			Where AlertSectionID = <cfqueryparam value="#AlertSectionID#" cfsqltype="CF_SQL_INTEGER">
			
			Delete From AlertSectionCategories
			Where AlertSectionID = <cfqueryparam value="#AlertSectionID#" cfsqltype="CF_SQL_INTEGER">
			
			Delete From AlertSectionLocations
			Where AlertSectionID = <cfqueryparam value="#AlertSectionID#" cfsqltype="CF_SQL_INTEGER">
			
			<cfloop list="#CategoryIDs#" index="c">
				Insert into AlertSectionCategories
				(AlertSectionID, CategoryID)
				VALUES
				(<cfqueryparam value="#AlertSectionID#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#c#" cfsqltype="CF_SQL_INTEGER">)
			</cfloop>
						
			<cfloop list="#LocationIDs#" index="loc">
				Insert into AlertSectionLocations
				(AlertSectionID, LocationID)
				VALUES
				(<cfqueryparam value="#AlertSectionID#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#loc#" cfsqltype="CF_SQL_INTEGER">)
			</cfloop>
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