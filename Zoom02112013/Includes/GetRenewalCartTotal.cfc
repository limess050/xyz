
<cfsetting showdebugoutput="no">

<cffunction name="GetCartTotal" access="remote" returntype="string" displayname="Returns the total Listing Fees of all the  passed ListingIDs">
	<cfargument name="ListingIDs" required="yes">
	<cfargument name="IncludeELPListingIDs" required="yes">
	<cfargument name="ApplyHAndRPackageListingID" required="yes">
	<cfargument name="ApplyVPackageListingID" required="yes">
	<cfargument name="ApplyJRPackageListingID" required="yes">
	
	<cfset rString="0">
	<cfset SubtotalAmount="0">
	
	<cfquery name="getListingFees"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ListingID, 
		CASE WHEN LT.AllowFreeRenewal=0 THEN IsNull(LT.BasicFee,0) Else 0 END as BasicFee, 
		IsNull(LT.ExpandedFee,0) as ExpandedFee,
		CASE WHEN L.ExpandedListingHTML is null and L.ExpandedListingPDF is null  and LT.AllowFreeRenewal=0 THEN IsNull(LT.BasicFee,0)
	WHEN L.ExpandedListingHTML is null and L.ExpandedListingPDF is null  and LT.AllowFreeRenewal=1 THEN 0
	WHEN LT.AllowFreeRenewal=0 THEN IsNull(LT.BasicFee,0) + IsNull(LT.ExpandedFee,0)
	ELSE IsNull(LT.ExpandedFee,0) END as TotalFee
		From Listings L
		Inner Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
		Where L.ListingID <cfif Len(arguments.ListingIDs)>in (<cfqueryparam value="#arguments.ListingIDs#" cfsqltype="CF_SQL_INTEGER" list="Yes">)<cfelse>=0</cfif>	
		<cfif Len(ApplyHAndRPackageListingID)> and L.ListingID not in (<cfqueryparam value="#arguments.ApplyHAndRPackageListingID#" cfsqltype="CF_SQL_INTEGER" list="Yes">)</cfif>	
		<cfif Len(ApplyVPackageListingID)> and L.ListingID not in (<cfqueryparam value="#arguments.ApplyVPackageListingID#" cfsqltype="CF_SQL_INTEGER" list="Yes">)</cfif>	
		<cfif Len(ApplyJRPackageListingID)> and L.ListingID not in (<cfqueryparam value="#arguments.ApplyJRPackageListingID#" cfsqltype="CF_SQL_INTEGER" list="Yes">)</cfif>	
	</cfquery>
	
	<cfloop query="getListingFees">
		<cfset SubtotalAmount=SubtotalAmount + BasicFee>	
		<cfif ListFind(arguments.IncludeELPListingIDs,ListingID)>
			<cfset SubtotalAmount=SubtotalAmount + ExpandedFee>	
		</cfif>
	</cfloop>
	
	<cfinclude template="VATCalc.cfm">
	
	<cfset PaymentAmount=SubtotalAmount+VAT>
	
	<cfset ResponseVars["SubtotalAmount"]= "#SubtotalAmount#" />
	<cfset ResponseVars["VAT"]= "#VAT#" />
	<cfset ResponseVars["PaymentAmount"]= "#PaymentAmount#" />
	
	<cfset rString=serializeJSON(ResponseVars)>
	
 	<cfreturn rString>
</cffunction>

