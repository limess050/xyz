<cfsetting requesttimeout="300">

<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfif not Len(session.NewAlert["FirstName"]) or not Len(session.NewAlert["AlertSectionIDs"])>
	<cflocation url="#lh_getPageLink(Request.AddAlertPageID,'signupforalerts')#" AddToken="No">
	<cfabort>
<cfelse>
	<cfloop list="#session.NewAlert["AlertSectionIDs"]#" index="i">
		<cfif not StructKeyExists(session.NewAlert["AlertSectionID"],i)>
			<cflocation url="#lh_getPageLink(Request.AddAlertPageID,'signupforalerts')#" AddToken="No">
			<cfabort>		
		</cfif>
	</cfloop>
</cfif>

<cfset ConfirmationID = CreateUUID()>
<cftransaction>
	<cfquery name="createAccount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Insert into LH_Users
		(ContactFirstName,
		ContactEmail,
		UserName,
		Password,
		AreaID,
		GenderID,
		BirthMonthID,
		BirthYearID,
		SelfIdentifiedTypeID,
		EducationLevelID,
		Active)
		VALUES
		(<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.NewAlert["FirstName"]#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.NewAlert["Email"]#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.NewAlert["Email"]#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.NewAlert["Password"]#">,
		<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.NewAlert["AreaID"]#">,
		<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.NewAlert["GenderID"]#">,
		<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.NewAlert["BirthMonthID"]#">,
		<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.NewAlert["BirthYearID"]#">,
		<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.NewAlert["SelfIdentifiedTypeID"]#">,
		<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.NewAlert["EducationLevelID"]#">,
		1)
		
		Select Max(UserID) as NewUserID
		From LH_Users	
	</cfquery>
	<cfset NewUserID=createAccount.NewUserID>
	
	<cfquery name="InsertAlert" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Insert into Alerts
		(UserID,
		DateCreated,
		ConfirmationID)
		VALUES
		(<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#NewUserID#">,
		<cfqueryparam cfsqltype="cf_sql_date" value="#application.CurrentDateInTZ#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#ConfirmationID#">)
		
		Select Max(AlertID) as NewAlertID
		From Alerts		
	</cfquery>
	<cfset NewAlertID = InsertAlert.NewAlertID>
	
	<cfset ProcessedAlertSectionIDs = "">
	<cfloop list="#session.NewAlert["AlertSectionIDs"]#" index="i">
		<cfset AlertSectionIDCounter = ListValueCount(ProcessedAlertSectionIDs,i) + 1>
		<cfset ProcessedAlertSectionIDs = ListAppend(ProcessedAlertSectionIDs, i)>
		<cfquery name="InsertAlertSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Insert into AlertSections
			(AlertID,
			SectionID,
			PriceMinUS,
			PriceMaxUS,
			PriceMinTZS,
			PriceMaxTZS)
			VALUES
			(<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#NewAlertID#">,
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">,
			<cfif Len(session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["PriceMinUS"])><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["PriceMinUS"]#"><cfelse>null</cfif>,
			<cfif Len(session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["PriceMaxUS"])><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["PriceMaxUS"]#"><cfelse>null</cfif>,
			<cfif Len(session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["PriceMinTZS"])><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["PriceMinTZS"]#"><cfelse>null</cfif>,
			<cfif Len(session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["PriceMaxTZS"])><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["PriceMaxTZS"]#"><cfelse>null</cfif>)
			
			Select Max(ALertSectionID) as NewAlertSectionID
			From AlertSections
		</cfquery>
		<cfset NewAlertSectionID= InsertAlertSection.NewAlertSectionID>
		
		<cfquery name="InsertAlertSectionCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			<cfloop list="#session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["CategoryIDs"]#" index="c">
				Insert into AlertSectionCategories
				(AlertSectionID, CategoryID)
				VALUES
				(<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#NewAlertSectionID#">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#c#">)
			</cfloop>
		</cfquery>
		
		<cfif Len(session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["LocationIDs"])>
			<cfquery name="InsertAlertSectionLocations" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				<cfloop list="#session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["LocationIDs"]#" index="loc">
					Insert into AlertSectionLocations
					(AlertSectionID, LocationID)
					VALUES
					(<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#NewAlertSectionID#">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#loc#">)
				</cfloop>
			</cfquery>
		</cfif>
		
	</cfloop>		
</cftransaction>


<cfoutput>
<cfsavecontent variable="EmailText">
	<lh:MS_SitePagePart id="bodyEmail" class="body">
</cfsavecontent>
<cfset EmailText= ReplaceNoCase(EmailText,'[ConfirmationLink]','#request.httpurl##lh_getPageLink(Request.ManageAlertPageID,'managealerts')##AmpOrQuestion#ConfirmationID=#ConfirmationID#','All')>

</cfoutput>

<cfinclude template="EmailMessageToPlainText.cfm">
<cfmail to="#session.NewAlert["Email"]#" from="#Request.AlertsFrom#" Subject="Welcome to ZoomTanzania new listing notifications" type="HTML" BCC="#request.AlertsBCCEmail#">
	<cfmailpart type="text/plain" charset="utf-8">#textMessage(EmailText)#</cfmailpart>
	<cfmailpart type="text/html" charset="utf-8">#EmailText#</cfmailpart>
</cfmail>

<cfset StructDelete(session,"NewAlert")>


<lh:MS_SitePagePart id="bodyThankYou" class="body">


