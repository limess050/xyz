
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfif not edit and IsDefined('session.UserID') and Len(session.UserID) and isDefined('cookie.LoggedIn') and cookie.LoggedIn is "1"><!--- Already logged in --->
	<cflocation url="#lh_getPageLink(7,'myAccount')#" AddToken="No">
	<cfabort>
</cfif>


<cfset allFields="FirstName,Email,AreaID,GenderID,BirthMonthID,BirthYearID,SelfIdentifiedTypeID,EducationLevelID,ConfirmationID">
<cfinclude template="../includes/setVariables.cfm">
<cfmodule template="../includes/_checkNumbers.cfm" fields="AreaID,GenderID,BirthMonthID,BirthYearID,EducationLevelID,SelfIdentifiedTypeID">
	
<cfparam name="MatchFound" default="0">
<cfparam name="EmailAddress" default="">

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

<cfinclude template="header.cfm">


<cfoutput>
<div class="centercol-inner legacy">
 	<h1><lh:MS_SitePagePart id="title" class="title"></h1>
	<p>&nbsp;</p>
</cfoutput>

<cfif edit>
	<p>Text to display on initial page.</p>
	<lh:MS_SitePagePart id="bodyStart" class="body">
	<p>Text to display above demographic questions. (This appears on the Create Account page, the Manage Alerts page and the Sign Up For Alerts page).</p>
	<lh:MS_SitePagePart id="BodyDemogrQuestionsHeader" class="body">	
	<p>Text to display when confirmation email has been sent.</p>
	<lh:MS_SitePagePart id="bodyConfSent" class="body">
	<p>Text to display at top of Confirmation email.</p>
	<lh:MS_SitePagePart id="bodyEmail" class="body">
	<p>Text to display when Confirmation link used.</p>
	<lh:MS_SitePagePart id="bodyConfirmation" class="body">
<cfelse>
 	<cfif Len(Email)>
		<cfset ConfirmationID = CreateUUID()>
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
			Active,
			ConfirmationID)
			VALUES
			(<cfqueryparam cfsqltype="cf_sql_varchar" value="#FirstName#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#Email#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#Email#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#Password#">,
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#AreaID#">,
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#GenderID#">,
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#BirthMonthID#">,
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#BirthYearID#">,
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#SelfIdentifiedTypeID#">,
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#EducationLevelID#">,
			1,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#ConfirmationID#">)
			
			Select Max(UserID) as NewUserID
			From LH_Users	
		</cfquery>
		<lh:MS_SitePagePart id="bodyConfSent" class="body">
		<cfoutput>
		<cfsavecontent variable="EmailText">
			<lh:MS_SitePagePart id="bodyEmail" class="body">
			<br>
			<a href="#request.httpurl##lh_getPageLink(Request.CreateAccountPageID,'createaccount')##AmpOrQuestion#ConfirmationID=#ConfirmationID#">#request.httpurl##lh_getPageLink(Request.CreateAccountPageID,'createaccount')##AmpOrQuestion#ConfirmationID=#ConfirmationID#</a>
		</cfsavecontent>
		<cfsavecontent variable="EmailTextPlain">
			<lh:MS_SitePagePart id="bodyEmail" class="body">
			<br>
			#request.httpurl##lh_getPageLink(Request.CreateAccountPageID,'createaccount')##AmpOrQuestion#ConfirmationID=#ConfirmationID#
		</cfsavecontent>
		</cfoutput>
		
		<cfinclude template="../includes/EmailMessageToPlainText.cfm">
		<cfmail to="#Email#" from="#Request.AlertsFrom#" Subject="Your New Account Confirmation Link" type="HTML" BCC="#Request.DevelCCEmail#">
			<cfmailpart type="text/plain" charset="utf-8">#textMessage(EmailTextPlain)#</cfmailpart>
			<cfmailpart type="text/html" charset="utf-8">#EmailText#</cfmailpart>
		</cfmail>
	<cfelseif Len(ConfirmationID)>		
		<cfquery name="GetUser" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select U.UserID, U.Email, U.AreaID, U.GenderID, U.BirthMonthID, U.BirthYearID, U.EducationLevelID, U.SelfIdentifiedTypeID,
			IsNull(U.ContactFirstName,'') + ' ' + IsNull(U.ContactLastName,'') as UserName 
			From LH_Users U 
			Where U.ConfirmationID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ConfirmationID#">
			and U.Active = 1
		</cfquery>
		<cfif GetUser.RecordCount>
			<cfquery name="UpdateUser" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Update LH_Users
				Set ConfirmedDate = <cfqueryparam cfsqltype="cf_sql_date" value="#application.CurrentDateInTZ#">
				Where UserID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#GetUser.UserID#">
				and ConfirmedDate is null
			</cfquery>
			<cfinclude template="../includes/LoginSetVars.cfm">
			<lh:MS_SitePagePart id="bodyConfirmation" class="body">
			<cfoutput>
			<script>					
				$(document).ready(function() {
					$( "##UserWelcome").html('Welcome, #session.UserName#<br>&nbsp;&nbsp;&nbsp;&nbsp;<a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/?Logout=Y">(log out)</a>&nbsp;&nbsp;&nbsp;');
				});
			</script>
			</cfoutput>
		<cfelse>
			<!--- Redirect to login page --->
			<cfset redirectURL = "page.cfm?PageID=#Request.ManageAlertPageID#">
			<cfinclude template="login.cfm">
			<cfabort>
		</cfif>
	<cfelse>
		<lh:MS_SitePagePart id="bodyStart" class="body">
		<cfset IncludeAlertSectionSelect = "0">
		<cfinclude template="../includes/CreateEditAccountForm.cfm">
	</cfif>
</cfif>


</div>

<!-- END CENTER COL -->

<cfinclude template="footer.cfm">
