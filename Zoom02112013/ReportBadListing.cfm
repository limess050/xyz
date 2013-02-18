<!--- This template expects a ListingID. --->
<cfset Edit=0>

<cfset allFields="ListingID,BadListingReasonID,BadListingComments,ReporterName,ReporterEmail,ReporterPhone">
<cfinclude template="includes/setVariables.cfm">
<cfmodule template="includes/_checkNumbers.cfm" fields="ListingID">

<cfif not IsDefined('CaptchaEntryBL') or not IsDefined('BadListingReasonID')><!--- Web crawler following old cached link when Bad Listing form was thickbox pop-up --->
	<cfif Len(ListingID)>
		<cflocation url="listingdetail?ListingID=#ListingID#" addToken="No">
	<cfelse>	
		<cflocation url="#Request.HTTPURL#" addToken="No">
	</cfif>
</cfif>

<cfquery name="getListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select L.ListingID, L.ListingTypeID, L.ListingTitle
	From ListingsView L
	Where L.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="cf_sql_integer">
</cfquery>

<cfset captcha = CreateObject("component","cfc.Captcha").init("BL")>
<cfif Not captcha.Validate()>
	<cfset rString = "The letters you entered did not match the image. The email was not sent.">
<cfelse>
	<cfset captcha.Use()>
	<cfset rString="Thank you for your report.">
	
	<cfmail to="#Request.MailToFormsTo#" from="#Request.MailToFormsFrom#" Subject="Bad Listing Report" type="HTML" BCC="#Request.BCCEmail#">
		<a href="#Request.HTTPURL#/ListingDetail?ListingID=#ListingID#">#getListing.ListingTitle#</a><br />
		<cfif Len(BadListingReasonID)>
			Type: #BadListingReasonID#<br />
		</cfif>
		<cfif Len(BadListingComments)>
			Comments/Details: #BadListingComments#<br />
		</cfif>
		<cfif Len(ReporterName)>
			Name: #ReporterName#<br />
		</cfif>
		<cfif Len(ReporterEmail)>
			Email: #ReporterEmail#<br />
		</cfif>
		<cfif Len(ReporterPhone)>
			Phone: #ReporterPhone#<br />
		</cfif>	
	</cfmail>
</cfif>



<cfif ListFind("1,2,14",getListing.ListingTypeID)>
	<cfsavecontent variable="ListingURL">
	<cfoutput>
	<cfif AmpOrQuestion is "?">#REReplace(Replace(Replace(getListing.ListingTitle," - ","-","All")," ","-","All"), "[^a-zA-Z0-9\-]","","all")#?StatusMessage=#rstring#<cfelse>#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#&StatusMessage=#rstring#</cfif>
	</cfoutput>
	</cfsavecontent>
<cfelse>
	<cfset ListingURL="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#&StatusMessage=#rString#">
</cfif>

<cflocation url="#ListingURL#" addtoken="no">
<cfabort>



