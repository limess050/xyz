
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfparam name="Step" default="1">
<cfparam name="ConfirmAlert" default="0">
<cfparam name="ConfirmationID" default="">

<cfif Len(ConfirmationID) and (not IsDefined('session.UserID') or not Len(session.UserID))>
<!--- Log user in to associated account --->
	<cfquery name="GetUser" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select A.AlertID, A.ConfirmationReceived,
		U.UserID, U.Email, U.AreaID, U.GenderID, U.BirthMonthID, U.BirthYearID, U.EducationLevelID, U.SelfIdentifiedTypeID,
		IsNull(U.ContactFirstName,'') + ' ' + IsNull(U.ContactLastName,'') as UserName 
		From Alerts A
		Inner Join LH_Users U on A.UserID=U.UserID
		Where A.ConfirmationID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ConfirmationID#">
		and U.Active = 1
	</cfquery>
	<cfif GetUser.RecordCount>
		<cfinclude template="../includes/LoginSetVars.cfm">
	<cfelse>
		<!--- Redirect to login page --->
		<cfset redirectURL = "page.cfm?PageID=#Request.ManageAlertPageID#">
		<cfinclude template="login.cfm">
		<cfabort>
	</cfif>
<cfelseif IsDefined('session.UserID') and Len(session.UserID) and isDefined('cookie.LoggedIn') and cookie.LoggedIn is "1"><!--- Already logged in --->
<!--- Get ConfirmationID from associated Alert record. If none exists, create Alert record and mark it as already confirmed. --->
	<cfquery name="GetConfirmationID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select A.ConfirmationID
		From Alerts A
		Where A.UserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.UserID#">
	</cfquery>
	<cfif not GetConfirmationID.RecordCount>
		<cfset ConfirmationID = CreateUUID()>	
		<cfquery name="InsertAlert" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Insert into Alerts
			(UserID,
			DateCreated,
			ConfirmationID,
			ConfirmationReceived)
			VALUES
			(<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.UserID#">,
			<cfqueryparam cfsqltype="cf_sql_date" value="#application.CurrentDateInTZ#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#ConfirmationID#">,
			<cfqueryparam cfsqltype="cf_sql_date" value="#application.CurrentDateInTZ#">)
		</cfquery>
	<cfelse>
		<cfset ConfirmationID = GetConfirmationID.ConfirmationID>
	</cfif>
<cfelseif not edit>
<!--- Redirect to login page --->
	<cfset redirectURL = "#request.httpsURL#/page.cfm?PageID=#Request.ManageAlertPageID#">
	<cfinclude template="login.cfm">
	<cfabort>
</cfif>

<cfquery name="getImpressionSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SectionID
	From PageSections
	Where PageID = <cfqueryparam value="#PageID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfset ImpressionSectionID=getImpressionSection.SectionID>
<cfif not Len(ImpressionSectionID)>
	<cfset ImpressionSectionID = 0>
</cfif>

<cfif not IsDefined('application.SectionImpressions')>
	<cfset application.SectionImpressions= structNew()>
</cfif>
<cfif StructKeyExists(application.SectionImpressions,ImpressionSectionID)>
	<cfset application.SectionImpressions[ImpressionSectionID] = application.SectionImpressions[ImpressionSectionID] + 1>
<cfelse>
	<cfset application.SectionImpressions[ImpressionSectionID] = 1>
</cfif>

<cfquery name="AlertSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select SectionID as SelectValue,
	CASE WHEN SectionID in (39,40,50) THEN (Select Title From Sections Where SectionID = 5) + ' - ' + Title ELSE Title END as SelectText
	From Sections
	Where SectionID in (4,8,37,55,59,39,40,50)
	Order by SelectText, Title
</cfquery>

<cfif Len(ConfirmationID)>
	<cfquery name="GetAlert" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select A.AlertID, A.ConfirmationReceived, U.UserName as Email, U.UserID
		From Alerts A
		Inner Join LH_Users U on A.UserID=U.UserID
		Where A.ConfirmationID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ConfirmationID#">
	</cfquery>
	<cfif not GetAlert.RecordCount>
		No matching Alert record found.
	<cfelse>
		<cfif not Len(GetAlert.ConfirmationReceived)>
			<cfquery name="UpdateAlert" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Update Alerts
				Set ConfirmationReceived = <cfqueryparam cfsqltype="cf_sql_date" value="#application.CurrentDateInTZ#">
				Where AlertID = <cfqueryparam value="#GetAlert.AlertID#" cfsqltype="CF_SQL_INTEGER">
				
				Update LH_Users
				Set ConfirmedDate = <cfqueryparam cfsqltype="cf_sql_date" value="#application.CurrentDateInTZ#">
				Where UserID = <cfqueryparam value="#GetAlert.UserID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<cfset ConfirmAlert = "1">
		</cfif>		
	</cfif>
<cfelse>
	No ConfirmationID passed.
</cfif>

<cfinclude template="header.cfm">

<cfoutput>
<div class="centercol-inner legacy">
 	<h1><lh:MS_SitePagePart id="title" class="title"></h1>
	<p>&nbsp;</p>

 	<div class="breadcrumb"><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/">Home</a> &gt; </div>

</cfoutput>

<cfif edit>
	<p>Text to show when user first confirms alert.</p>
	<lh:MS_SitePagePart id="bodyConfirmed" class="body">
	<p>Text to display on summary page.</p>
	<lh:MS_SitePagePart id="bodySummary" class="body">
	<p>Text to display on summary page when user has no alerts.</p>
	<lh:MS_SitePagePart id="bodySummaryNoAlerts" class="body">
	<p>Text to display on email/demographics form.</p>	
	<lh:MS_SitePagePart id="bodyDemogIntro" class="body">
	<p>Text to display on For Sale Classifieds form.</p>
	<lh:MS_SitePagePart id="bodySectionData4" class="body">	
	<p>Text to display on Special Travel Offers form.</p>
	<lh:MS_SitePagePart id="bodySectionData37" class="body">		
	<p>Text to display on Tanzania Events Calendar form.</p>
	<lh:MS_SitePagePart id="bodySectionData59" class="body">
	<p>Text to display on Tanzania Jobs &amp; Employment form.</p>
	<lh:MS_SitePagePart id="bodySectionData8" class="body">		
	<p>Text to display on Commercial Rentals form.</p>
	<lh:MS_SitePagePart id="bodySectionData50" class="body">	
	<p>Text to display on Homes &amp; Property For Sales form.</p>
	<lh:MS_SitePagePart id="bodySectionData40" class="body">	
	<p>Text to display on Housing Rentals form.</p>
	<lh:MS_SitePagePart id="bodySectionData39" class="body">
	<p>Text to display on second page for Used Cars, Trucks &amp; Boats.</p>
	<lh:MS_SitePagePart id="bodySectionData55" class="body">
<cfelse>
 	<cfswitch expression="#Step#">
	 	<cfcase value="1">
			<cfinclude template="../includes/ManageAlertsSummary.cfm">
		</cfcase>
	 	<cfcase value="2">
			<!--- Details --->
			<cfinclude template="../includes/ManageAlertsUpdate.cfm">
		</cfcase>
	 	<cfcase value="3">
			<!--- Details --->
			<cfinclude template="../includes/ManageAlertsUpdate_Doit.cfm">
		</cfcase>
		<cfcase value="4">
			<!--- Deletes --->
			<cfinclude template="../includes/ManageAlertsDelete.cfm">
		</cfcase>
	 	<cfcase value="5">
			<cfinclude template="../includes/ManageAlertsNew.cfm">
		</cfcase>
	 	<cfcase value="6">
			<cfinclude template="../includes/ManageAlertsNew_Doit.cfm">
		</cfcase>
	 	<cfcase value="7">
			<cfinclude template="../includes/ManageAlertsDeleteAll_Doit.cfm">
		</cfcase>
	 	<cfcase value="8">
			<!--- Email and Demographics --->
			<cfinclude template="../includes/ManageAlertsDemogr.cfm">
		</cfcase>
	 	<cfcase value="9">
			<!--- Email and Demographics --->
			<cfinclude template="../includes/ManageAlertsDemogr_Doit.cfm">
		</cfcase>
	 </cfswitch>	
</cfif>

</div>

<!-- END CENTER COL -->

<cfinclude template="footer.cfm">
