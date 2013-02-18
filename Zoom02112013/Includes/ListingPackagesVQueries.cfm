<cfparam name="InCart" default="0">
<cfparam name="HasOpenVPackages" default="0">
<cfparam name="VPackageListingsRemaining" default="0">

<cfquery name="getVListingPackages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
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
	Where LP.ListingPackageTypeID=2 <!--- V --->
	and O.UserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
	Order By O.OrderDate desc
</cfquery>	

<cfoutput query="getVListingPackages">
	<cfif ListingsInPackage lt ListingsPaidFor and (not Len(PaymentDate) or DateDiff("d",Now(),DateAdd("yyyy",1,PaymentDate)))>
		<cfset HasOpenVPackages="1">
		<cfset VListingPackageID=ListingPackageID>
		<cfif ListingsPaidFor is "1000000">
			<cfset VPackageListingsRemaining=ListingsPaidFor>
		<cfelse>
			<cfset VPackageListingsRemaining=ListingsPaidFor-ListingsInPackage>
		</cfif>
	</cfif>
</cfoutput>

<cfif not HasOpenVPackages and not InCart>
	<cfquery name="getVListingPackageFees" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select FivePerYearFee, TenPerYearFee, TwentyPerYearFee, UnlimitedPerYearFee
		From ListingTypes
		Where ListingTypeID=16<!--- FBSO 4 --->
	</cfquery>
</cfif>	