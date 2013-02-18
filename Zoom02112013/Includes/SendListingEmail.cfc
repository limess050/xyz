
<cfsetting showdebugoutput="no">

<cffunction name="SendEmail" access="remote" returntype="string" displayname="Sends email to Public Email in Listing record">
	<cfargument name="ListingID" required="yes">
	<cfargument name="Email" required="yes">
	<cfargument name="EmailBody" required="yes">
	
	<cfmodule template="spamChecker.cfm"
		commenterName="#Email#"
		comments="#EmailBody#">
	
	<cfset rString = "">
	 
	<cfquery name="getListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ListingID, L.PublicEmail, 
		CASE 
		WHEN L.ListingTypeID = 4 
			THEN Cast(L.VehicleYear as varchar(4)) + ' ' + M.Title + ' ' + L.Model 
		WHEN L.ListingTypeID = 5 
			THEN Cast(L.VehicleYear as varchar(4)) + ' ' + L.Make + ' ' + L.Model 
		WHEN L.ListingTypeID in (12)
			THEN L.ShortDescr
		ELSE L.Title 
		END as ListingTitle,
		CASE 
		WHEN L.ListingTypeID in (1,2,14)
			THEN '#Request.HTTPURL#/' + URLSafeTitle
		ELSE '#Request.HTTPURL#/ListingDetail?ListingID=' + Cast(ListingID as varchar(10))
		END as ListingFriendlyURL
		From Listings L
		Left Outer Join Makes M on L.MakeID=M.MakeID
		Where L.ListingID =  <cfqueryparam value="#arguments.ListingID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	
	<cfif not getListing.RecordCount or not Len(getListing.PublicEmail)>
		<cfset rString="Listing Email Address not found.">
	<cfelse>		
		<cfquery name="insertImpression" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Insert into Impressions
			(ListingID,EmailInquiry)
			Values 
			(<cfqueryparam value="#arguments.ListingID#" cfsqltype="CF_SQL_INTEGER">,1)
		
			Update Listings 
			Set ImpressionsEmailInquiries = ImpressionsEmailInquiries + 1
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfmail to="#getListing.PublicEmail#" from="#Request.MailToFormsFrom#" subject="Inquiry from ZoomTanzania.com Regarding Your '#getListing.ListingTitle#' Listing" replyto="#arguments.Email#" type="HTML" BCC="#Request.DevelCCEmail#">
			An inquiry regarding your listing on ZoomTanzania.com for #getListing.ListingTitle#:<br>
			Listing ID: #getListing.ListingID# - <a href="#getListing.ListingFriendlyURL#">#getListing.ListingTitle#</a><br>
			<p>This inquiry was sent from #arguments.Email#.  To reply to this inquiry, simply “Reply” as you would any other email and it will be addressed to the correct email address.
			<p>
			#arguments.EmailBody#
		</cfmail>
		<cfset rString="Email sent.">
	</cfif>
 	<cfreturn rString>
</cffunction>
