<!--- This template runs early in the lighthouse/page.cfm template, in order to set the header title with the listing info. --->

<cfset allFields="ListingID">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="ListingID">

<cfif Len(ListingID)>
	<cfquery name="getListingInfo2" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select L.ListingHeaderTitle, L.ListingTitleForH1, L.ListingMetaDescr, Lo.Title as Location, Lo.LocationID
		From Listings L With (NoLock)
		Left Outer Join ListingLocations LL With (NoLock) on L.ListingID=LL.ListingID
		Left Outer Join Locations Lo With (NoLock) on LL.LocationID=Lo.LocationID
		Where L.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		Order by Lo.OrderNum
	</cfquery>
	<cfset ListingHeaderTitle=getListingInfo2.ListingHeaderTitle>
	<cfset ListingTitleForH1=getListingInfo2.ListingTitleForH1>	
	<cfset ListingMetaDescr=getListingInfo2.ListingMetaDescr>
</cfif>