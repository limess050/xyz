<!--- Based on admin/AccountWelcomeEmail.cfm and inttasks/Reminders.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="NewOrderType" default="">

<cffunction name="SendEmail" access="remote" returntype="string" displayname="Sends the Payment Reminder email">
	<cfargument name="PK" type="numeric" required="yes">
	
	<cfquery name="getOrder" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select O.PaymentStatusID, O.PaymentConfirmationEmailDateSent, LP.ListingPackageID, LS.ListingServiceID
		From Orders O
		Left Outer Join ListingPackages LP on O.OrderID=LP.OrderID
		Left Outer Join ListingServices LS on O.OrderID=LS.OrderID
		Where O.OrderID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
	</cfquery>

	<cfif Len(getOrder.ListingServiceID)>
		<cfset NewOrderType="AdminServiceOrderUpdate">
	<cfelseif Len(getOrder.ListingPackageID)>
		<cfset NewOrderType="AdminListingPackageOrderUpdate">
	<cfelse>
		<cfset NewOrderType="AdminOrderUpdate">
	</cfif>

	<cfif Len(NewOrderType)>
		<cfset NewOrderID=PK>
		<cfinclude template="../includes/EmailNewOrder.cfm">
		<cfset rString="Order Confirmation sent.">	
	<cfelse>
		<cfset rString="Order type undetermined. No email sent.">	
	</cfif>
	<cfif not Len(getOrder.PaymentConfirmationEmailDateSent)>
		<cfquery name="SetDate" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Update Orders
			Set PaymentConfirmationEmailDateSent=getDate()
			Where OrderID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
		</cfquery>
	</cfif>

 	<cfreturn rString>

</cffunction>
