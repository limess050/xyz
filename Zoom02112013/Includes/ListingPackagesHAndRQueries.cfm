<cfparam name="InCart" default="0">
<cfparam name="HasOpenHAndRPackages" default="0">
<cfparam name="HAndRPackageListingsRemaining" default="0">

<cfquery name="getHRListingPackages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
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
	Where LP.ListingPackageTypeID=1 <!--- HAndR --->
	and O.UserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
	Order By O.OrderDate desc
</cfquery>	

<cfoutput query="getHRListingPackages">
	<cfif ListingsInPackage lt ListingsPaidFor and (not Len(PaymentDate) or DateDiff("d",Now(),DateAdd("yyyy",1,PaymentDate)))>
		<cfset HasOpenHAndRPackages="1">
		<cfset HAndRListingPackageID=ListingPackageID>
		<cfif ListingsPaidFor is "1000000">
			<cfset HAndRPackageListingsRemaining=ListingsPaidFor>
		<cfelse>
			<cfset HAndRPackageListingsRemaining=ListingsPaidFor-ListingsInPackage>
		</cfif>
	</cfif>
</cfoutput>

<cfif not HasOpenHAndRPackages and not InCart>
	<cfquery name="getHAndRListingPackageFees" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select FivePerYearFee, TenPerYearFee, TwentyPerYearFee, UnlimitedPerYearFee
		From ListingTypes
		Where ListingTypeID=17<!--- H&R 4 --->
	</cfquery>
</cfif>	