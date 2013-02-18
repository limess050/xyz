<cfparam name="SetDateLive" default="0">

<cfset allFields="NewListingID">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="NewListingID">

<cfquery name="getListingForEmail" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select L.ListingID, 
	CASE WHEN L.ListingTypeID in (10,12) THEN L.ShortDescr ELSE L.ListingTitle END as ListingTitle, 
	L.URLSafeTitle, L.ListingTypeID, L.ContactEmail, L.AltContactEmail, L.UserID, L.LinkID,
	L.AcctContactEmail, L.AcctAltContactEmail, L.PublicEmail,
	U.Username, U.Password, U.Company,
	CASE WHEN L.Active=1 and L.Reviewed=1 and L.ExpirationDate >= #application.CurrentDateInTZ# THEN 1
	ELSE 0 END as ListingLive
	From ListingsView L
	Left Outer Join LH_Users U on L.UserID=U.UserID
	Where L.ListingID = <cfqueryparam value="#NewListingID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>


<cfquery name="updateListingLiveEmailDateSent" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Update Listings 
	Set ListingLiveEmailDateSent=getDate()
	<cfif SetDateLive>, DateLive=getDate(), DateSort=getDate()</cfif>
	Where ListingID = <cfqueryparam value="#NewListingID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfquery name="getAutoEmail" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SubjectLine, Body
	From AutoEmails
	Where 
	<cfif Len(getListingForEmail.UserID)>
		AutoEmailID = 10
	<cfelse>
		AutoEmailID = 7
	</cfif>	
</cfquery>


<cfset EditListingLink="<a href='#request.HTTPSURL#/postalisting?Step=3&LinkID=#getListingForEmail.LinkID#'>Edit Listing</a>">	
<cfset DeleteListingLink="<a href='#request.HTTPSURL#/postalisting?Step=3&LinkID=#getListingForEmail.LinkID#&DeleteListing=1'>Delete Listing</a>">
<cfset ListingIsLiveParagraph="">

<cfif getListingForEmail.ListingLive>	
	<cfset ListingIsLiveParagraph="<p>Your listing <strong>#getListingForEmail.ListingTitle#</strong> is now live on ZoomTanzania.com.   To view your live listing, click on the link below.<br />">
	<cfif ListFind("1,2,14",getListingForEmail.ListingTypeID)>
		<cfset ListingIsLiveParagraph=ListingIsLiveParagraph & "#Request.HTTPURL#/#getListingForEmail.URLSafeTitle#</p>">
	<cfelse>
		<cfset ListingIsLiveParagraph=ListingIsLiveParagraph & "#Request.HTTPURL#/listingDetail?ListingID=#getListingForEmail.ListingID#</p>">
	</cfif>
</cfif>

<cfif Len(getListingForEmail.UserID)>	<!--- Account Listing --->
	<cfset EmailBody=getAutoEmail.Body>
	<cfset AccountName=getListingForEmail.Company>
	<cfset UserID=getListingForEmail.UserID>
	<cfset UserName=getListingForEmail.UserName>
	<cfset Password=getListingForEmail.Password>
	<cfinclude template="getAccountInfo.cfm">
	<cfset EmailBody=ReplaceNoCase(EmailBody,"%includeIfListingIsLiveParagraph%",ListingIsLiveParagraph)>
<cfelse><!--- Non-account Listing --->
	<cfset EmailBody=ReplaceNoCase(getAutoEmail.Body,"%insertEditLink%",EditListingLink)>
	<cfset EmailBody=ReplaceNoCase(EmailBody,"%deleteListingLink%",DeleteListingLink)>
	<cfset EmailBody=ReplaceNoCase(EmailBody,"%includeIfListingIsLiveParagraph%",ListingIsLiveParagraph)>
</cfif>

<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertMyAccountLink%","<a href='#Request.httpUrl#/MyAccount'>Click Here</a>")>
<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertHowToPayLink%","<a href='#Request.httpUrl#/HowToPay'>Click Here</a>")>


<cfset ListingEmailTo=getListingForEmail.ContactEmail>
<cfif Len(getListingForEmail.AltContactEmail)>
	<cfset ListingEmailTo=ListAppend(ListingEmailTo,getListingForEmail.AltContactEmail)>
</cfif>
<cfif not Len(ListingEmailTo) and Len(getListingForEmail.AcctContactEmail)>
	<cfset ListingEmailTo=getListingForEmail.AcctContactEmail>
</cfif>
<cfif not Len(ListingEmailTo) and Len(getListingForEmail.AcctAltContactEmail)>
	<cfset ListingEmailTo=getListingForEmail.AcctAltContactEmail>
</cfif>
<cfif not Len(ListingEmailTo) and Len(getListingForEmail.PublicEmail)>
	<cfset ListingEmailTo=getListingForEmail.PublicEmail>
</cfif>

<cfif Len(ListingEmailTo)>
	<cfmail to="#ListingEmailTo#" from="#Request.MailToFormsFrom#" subject="#getAutoEmail.SubjectLine#" type="HTML" BCC="#Request.DevelCCEmail#">
		#EmailBody#	
	</cfmail> 
</cfif>