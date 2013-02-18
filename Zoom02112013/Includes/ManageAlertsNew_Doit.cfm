<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfset allFields="ConfirmationID,NewAlertSectionID,CategoryIDs,LocationIDs,PriceMinUS,PriceMaxUS,PriceMinTZS,PriceMaxTZS">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="NewAlertSectionID">

<cfif Len(ConfirmationID) and Len(NewAlertSectionID)>
	<cfquery name="ConfirmAlert" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select AlertID 
		from Alerts 
		Where ConfirmationID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ConfirmationID#">
	</cfquery>
	<cfif ConfirmAlert.RecordCount>
		<cfset AlertID = ConfirmAlert.AlertID>
		<cfquery name="InsertAlertSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Insert into AlertSections
			(AlertID, SectionID, PriceMinUS, PriceMaxUS, PriceMinTZS, PriceMaxTZS)
			VALUES
			(<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#AlertID#">,
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#NewAlertSectionID#">,
			<cfif Len(PriceMinUS)><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#PriceMinUS#"><cfelse>null</cfif>,
			<cfif Len(PriceMaxUS)><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#PriceMaxUS#"><cfelse>null</cfif>,
			<cfif Len(PriceMinTZS)><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#PriceMinTZS#"><cfelse>null</cfif>,
			<cfif Len(PriceMaxTZS)><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#PriceMaxTZS#"><cfelse>null</cfif>)
			
			Select Max(AlertSectionID) as NewID
			From AlertSections
			
		</cfquery>
		<cfset NewID = InsertAlertSection.NewID>
		<cfquery name="InsertAlertSectionCategoriesAndLocations" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			<cfloop list="#CategoryIDs#" index="c">
				Insert into AlertSectionCategories
				(AlertSectionID, CategoryID)
				VALUES
				(<cfqueryparam value="#NewID#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#c#" cfsqltype="CF_SQL_INTEGER">)
			</cfloop>
						
			<cfloop list="#LocationIDs#" index="loc">
				Insert into AlertSectionLocations
				(AlertSectionID, LocationID)
				VALUES
				(<cfqueryparam value="#NewID#" cfsqltype="CF_SQL_INTEGER">,
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