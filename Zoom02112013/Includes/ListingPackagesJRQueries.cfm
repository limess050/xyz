<cfparam name="InCart" default="0">
<cfparam name="HasOpenJRPackages" default="0">
<cfparam name="JRPackageListingsRemaining" default="0">

<cfquery name="getJRListingPackages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select LP.ListingPackageID, O.PaymentDate, O.PaymentStatusID,
	CASE
	WHEN LP.FiveListing=1 THEN 5
	WHEN LP.TenListing=1 THEN 10
	WHEN LP.TwentyListing=1 THEN 20
	WHEN LP.UnlimitedListing=1 THEN 1000000<!--- Unlimited --->
	END as ListingsPaidFor,
	LP.FiveListing, LP.TenListing, LP.TwentyListing, LP.ExpirationDate,
	(Select Count(ListingID) From Listings Where ListingPackageID=LP.ListingPackageID) + (Select Count(ListingRenewalID) From ListingRenewals Where ListingPackageID=LP.ListingPackageID) as ListingsInPackage
	From ListingPackages LP
	Inner Join Orders O on LP.OrderID=O.OrderID
	Where LP.ListingPackageTypeID=3 <!--- J --->
	and O.UserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
	Order By O.OrderDate desc
</cfquery>	

<cfoutput query="getJRListingPackages">
	<cfif ListingsInPackage lt ListingsPaidFor and (not Len(PaymentDate) or DateDiff("d",Now(),DateAdd("yyyy",1,PaymentDate)))>
		<cfset HasOpenJRPackages="1">
		<cfset JRListingPackageID=ListingPackageID>
		<cfif ListingsPaidFor is "1000000">
			<cfset JRPackageListingsRemaining=ListingsPaidFor>
		<cfelse>
			<cfset JRPackageListingsRemaining=ListingsPaidFor-ListingsInPackage>
		</cfif>
	</cfif>
</cfoutput>

<cfif not HasOpenJRPackages and not InCart>
	<cfquery name="getJRListingPackageFees" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select FivePerYearFee, TenPerYearFee, TwentyPerYearFee, UnlimitedPerYearFee
		From ListingTypes
		Where ListingTypeID=18<!--- Job Recruiter  --->
	</cfquery>
</cfif>	