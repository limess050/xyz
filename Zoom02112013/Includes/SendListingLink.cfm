<cfquery name="getAutoEmail" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SubjectLine, Body
	From AutoEmails
	Where AutoEmailID = 1
</cfquery>

<cfset ListingDetailPageLink="#Request.httpURL#/#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=3&LinkID=#LinkID#">
<cfset ListingLink='<a href="#ListingDetailPageLink#">#ListingDetailPageLink#</a>'>
<cfset EmailBody=ReplaceNoCase(getAutoEmail.Body,'%insertlink%',ListingLink)>
<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertMyAccountLink%","<a href='#Request.httpUrl#/MyAccount'>Click Here</a>")>
<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertHowToPayLink%","<a href='#Request.httpUrl#/HowToPay'>Click Here</a>")>
<cfset ListingEmailTo=getListing.ContactEmail>
<cfif Len(getListing.AltContactEmail)>
	<cfset ListingEmailTo=ListAppend(ListingEmailTo,getListing.altContactEmail)>
</cfif>

					
<cfmail to="#ListingEmailTo#" from="#Request.MailToFormsFrom#" subject="#getAutoEmail.SubjectLine# - #getListing.ListingTitle#" type="HTML" BCC="#Request.DevelCCEmail#">
	#EmailBody#	
</cfmail> 