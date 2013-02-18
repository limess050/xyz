<cfset allFields="Em">
<cfinclude template="setVariables.cfm">
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfquery name="GetAlertByEmailAddress" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select Email, ConfirmationID 
	From Alerts 
	Where Email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Em#">
</cfquery>

<cfif GetAlertByEmailAddress.RecordCount>
	<cfoutput>
	<cfsavecontent variable="EmailText">
		<lh:MS_SitePagePart id="bodyResendEmail" class="body">
		<br>
		<a href="#request.httpurl##lh_getPageLink(Request.ManageAlertPageID,'managealerts')##AmpOrQuestion#ConfirmationID=#GetAlertByEmailAddress.ConfirmationID#">Click Here</a>
	</cfsavecontent>
	<cfsavecontent variable="EmailTextPlain">
		<lh:MS_SitePagePart id="bodyResendEmail" class="body">
		<br>
		#request.httpurl##lh_getPageLink(Request.ManageAlertPageID,'managealerts')##AmpOrQuestion#ConfirmationID=#GetAlertByEmailAddress.ConfirmationID#
	</cfsavecontent>
	</cfoutput>
	
	<cfinclude template="EmailMessageToPlainText.cfm">
	<cfmail to="#session.NewAlert["Email"]#" from="#Request.MailToFormsFrom#" Subject="Your Alert Confirmation Link" type="HTML" BCC="">
		<cfmailpart type="text/plain" charset="utf-8">#textMessage(EmailTextPlain)#</cfmailpart>
		<cfmailpart type="text/html" charset="utf-8">#EmailText#</cfmailpart>
	</cfmail>

	<lh:MS_SitePagePart id="bodyLinkResent" class="body">
<cfelse>
	<cflocation url="page.cfm?PageID=#Request.AddAlertPageID#&Step=1" addToken="No">
	<cfabort>
</cfif>