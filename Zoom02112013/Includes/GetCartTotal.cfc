
<cfsetting showdebugoutput="no">

<cffunction name="GetCartTotal" access="remote" returntype="string" displayname="Returns the total Listing Fees of all the  passed ListingIDs">
	<cfargument name="ListingID" required="yes">
	<cfargument name="ApplyHAndRPackageListingID" required="yes">
	<cfargument name="ApplyVPackageListingID" required="yes">
	<cfargument name="ApplyJRPackageListingID" required="yes">
	
	<cfset rString="0">
	<cfset SubtotalAmount="0">
	
	<cfquery name="getListingFees"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select Sum(IsNull(ListingFee,0)) as FeeTotal
		From Listings
		Where ListingID <cfif Len(arguments.ListingID)>in (<cfqueryparam value="#arguments.ListingID#" cfsqltype="CF_SQL_INTEGER" list="Yes">)<cfelse>=0</cfif>	
		<cfif Len(ApplyHAndRPackageListingID)> and ListingID not in (<cfqueryparam value="#arguments.ApplyHAndRPackageListingID#" cfsqltype="CF_SQL_INTEGER" list="Yes">)</cfif>	
		<cfif Len(ApplyVPackageListingID)> and ListingID not in (<cfqueryparam value="#arguments.ApplyVPackageListingID#" cfsqltype="CF_SQL_INTEGER" list="Yes">)</cfif>	
		<cfif Len(ApplyJRPackageListingID)> and ListingID not in (<cfqueryparam value="#arguments.ApplyJRPackageListingID#" cfsqltype="CF_SQL_INTEGER" list="Yes">)</cfif>	
	</cfquery>
	
	<cfquery name="getBannerAdFees"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select Sum(IsNull(Price,0)) as FeeTotal
		From BannerAds
		Where BannerAdID <cfif Len(arguments.BannerAdID)>in (<cfqueryparam value="#arguments.BannerAdID#" cfsqltype="CF_SQL_INTEGER" list="Yes">)<cfelse>=0</cfif>	
	</cfquery>
	
	
	<cfquery name="getExpandedListingFees"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select Sum(IsNull(L.ExpandedListingFee,0)) as ExpandedFeeTotal
		From Listings L
		Where L.ListingID <cfif Len(arguments.ListingID)>in (<cfqueryparam value="#arguments.ListingID#" cfsqltype="CF_SQL_INTEGER" list="Yes">)<cfelse>=0</cfif>
		and (L.ExpandedListingHTML is not null or ExpandedListingPDF is not null)
	</cfquery>
	
	<cfif Len(getListingFees.FeeTotal)>
		<cfset SubtotalAmount=SubtotalAmount + getListingFees.FeeTotal>	
	</cfif>
	
	<cfif Len(getBannerAdFees.FeeTotal)>
		<cfset SubtotalAmount=SubtotalAmount + getBannerAdFees.FeeTotal>	
	</cfif>
	
	<cfif Len(getExpandedListingFees.ExpandedFeeTotal)>
		<cfset SubtotalAmount=SubtotalAmount + getExpandedListingFees.ExpandedFeeTotal>	
	</cfif>
	
	<cfinclude template="VATCalc.cfm">
	
	<cfset PaymentAmount=SubtotalAmount+VAT>
	
	<cfset ResponseVars["SubtotalAmount"]= "#SubtotalAmount#" />
	<cfset ResponseVars["VAT"]= "#VAT#" />
	<cfset ResponseVars["PaymentAmount"]= "#PaymentAmount#" />
	
	<cfset rString=serializeJSON(ResponseVars)>
	
 	<cfreturn rString>
</cffunction>

