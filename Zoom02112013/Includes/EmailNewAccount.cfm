<cfset allFields="NewAccountName,NewAccountID,NewUserName,NewPassword">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="NewAccountID">

<cfquery name="getAutoEmail" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SubjectLine, Body
	From AutoEmails
	Where AutoEmailID = 2
</cfquery>

<cfset EmailBody=getAutoEmail.Body>
<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertMyAccountLink%","<a href='#Request.httpUrl#/MyAccount'>Click Here</a>")>
<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertHowToPayLink%","<a href='#Request.httpUrl#/HowToPay'>Click Here</a>")>
<cfinclude template="getAccountInfo.cfm">

<cfmail to="#NewUserName#" from="#Request.MailToFormsFrom#" subject="#getAutoEmail.SubjectLine#" type="HTML" BCC="#Request.DevelCCEmail#">
	#EmailBody#	
</cfmail> 