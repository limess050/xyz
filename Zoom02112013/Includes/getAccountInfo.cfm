<cfparam name="AccountName" default="">
<cfparam name="UserID" default="">
<cfparam name="UserName" default="">
<cfparam name="Password" default="">
<cfparam name="EmailBody" default="No Email Body was passed.">

<cfif IsDefined('NewAccountName')>
	<cfset AccountName=NewAccountName>
</cfif>
<cfif IsDefined('NewAccountID')>
	<cfset UserID=NewAccountID>
</cfif>
<cfif IsDefined('NewUserName')>
	<cfset UserName=NewUserName>
</cfif>
<cfif IsDefined('NewPassword')>
	<cfset Password=NewPassword>
</cfif>

<cfsavecontent variable="AccountInfo">
	<cfoutput>
		<strong>
		Account. Name = #AccountName#<br>
		Account ## = #UserID#<br>
		Username = #UserName#<br>
		Password = #Password#
		</strong>
	</cfoutput>
</cfsavecontent>

<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertacctinfo%",AccountInfo,"ALL")>
