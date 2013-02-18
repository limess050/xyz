<cfset OrderID=PK>
<cfinclude template="../includes/SetExpirationDate.cfm">

<cfquery name="getOrderUpdated" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select O.PaymentStatusID, O.PaymentConfirmationEmailDateSent, O.OrderTotal, LP.ListingPackageID, LS.ListingServiceID
	From Orders O
	Left Outer Join ListingPackages LP on O.OrderID=LP.OrderID
	Left Outer Join ListingServices LS on O.OrderID=LS.OrderID
	Where O.OrderID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>

<cfif getOrderUpdated.PaymentStatusID is "2" and (Request.environment is "Live" or Request.environment is "Devel" or Request.environment is "DB")>	
	<cfif not Len(getOrderUpdated.PaymentConfirmationEmailDateSent) and getOrderUpdated.OrderTotal gt "0">
		<cfset NewOrderID=PK>
		<cfif Len(getOrderUpdated.ListingPackageID)>
			<cfset NewOrderType="AdminListingPackageOrderUpdate">
		<cfelseif Len(getOrderUpdated.ListingServiceID)>
			<cfset NewOrderType="AdminServiceOrderUpdate">
		<cfelse>
			<cfset NewOrderType="AdminOrderUpdate">
		</cfif>
		<cfinclude template="../includes/EmailNewOrder.cfm">
	</cfif>
	<!--- Loop through order's listings and send ListingLive email if appropriate --->
	<cfquery name="getListingsToEmail" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select L.ListingID
		From Listings L
		Where L.OrderID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
		and L.ListingLiveEmailDateSent is null
		and L.Reviewed=1
	</cfquery>
	<cfoutput query="getListingsToEmail">
		<cfset NewListingID=getListingsToEmail.ListingID>
		<cfset SetDateLive="1">
		<cfinclude template="../includes/EmailListingLive.cfm">
	</cfoutput>
</cfif>

