
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfif not edit and  IsDefined('session.UserID') and Len(session.UserID) and isDefined('cookie.LoggedIn') and cookie.LoggedIn is "1"><!--- Already logged in --->
	<cflocation url="#lh_getPageLink(7,'myAccount')#" AddToken="No">
	<cfabort>
</cfif>

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
<script>
	function validateForm(formObj) {		
		if (!checkText(formObj.elements["EmailAddress"],"Email Address")) return false;	
		if (!checkEmail(formObj.elements["EmailAddress"],"Email Address")) return false;	
		return true;
	}					
</script>

<cfoutput>
<div class="centercol-inner legacy">
 	<h1><lh:MS_SitePagePart id="title" class="title"></h1>
	<p>&nbsp;</p>


</cfoutput>

<cfif edit>
	<p>Text to display on initial page.</p>
	<lh:MS_SitePagePart id="bodyStart" class="body">	
	<p>Text to display when match found and email has been sent.</p>
	<lh:MS_SitePagePart id="bodyMatchFound" class="body">
	<p>Text to display when no match was found for email address entered.</p>
	<lh:MS_SitePagePart id="bodyNoMatch" class="body">
	<p>Text to display at top of Forgot Password email.</p>
	<lh:MS_SitePagePart id="bodyEmail" class="body">
<cfelse>
 	<cfif Len(EmailAddress)>
		<cfquery name="findUser" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select password
			From LH_Users
			Where Username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#EmailAddress#">
			and Active=1
			and AdminUser=0
		</cfquery>
		<cfif findUser.RecordCount>
			<cfset MatchFound = 1>
			<cfinclude template="../includes/EmailMessageToPlainText.cfm">
			<cfsavecontent variable="EmailText">				
				<lh:MS_SitePagePart id="bodyEmail" class="body">
				<br>
				Password: <cfoutput>#findUser.Password#</cfoutput>
			</cfsavecontent>
			<cfmail to="#EmailAddress#" from="#Request.MailToFormsFrom#" Subject="Forgot Your Password Help" type="HTML" BCC="">
				<cfmailpart type="text/plain" charset="utf-8">#textMessage(EmailText)#</cfmailpart>
				<cfmailpart type="text/html" charset="utf-8">#EmailText#</cfmailpart>
			</cfmail>
		</cfif>
		<cfif MatchFound>
			<lh:MS_SitePagePart id="bodyMatchFound" class="body">
		<cfelse>
			<lh:MS_SitePagePart id="bodyNoMatch" class="body">
		</cfif>
	<cfelse>
		<lh:MS_SitePagePart id="bodyStart" class="body">
	</cfif>
	<cfif not MatchFound>
		<br>
		<div>
			<cfoutput>
				<form name="forgotPassword" action="page.cfm?PageID=#PageID#" method="post" onSubmit="return validateForm(this)">
					Email Address: <input type="text" name="EmailAddress" id="EmailAddress" value="#EmailAddress#">
					<br>
					<input type="submit" value="Submit">
				</form>
			</cfoutput>
		</div>
	</cfif>	
</cfif>


</div>

<!-- END CENTER COL -->

<cfinclude template="footer.cfm">
