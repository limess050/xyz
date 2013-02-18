<!--- This template expects an OrderID of a primary listing. (A listing that is either a One-Off listing, or a listing that created an account. If the Listing has a Spearate ExpandedListingOrderID, that Order will be processed as well. --->



<cfif ListFind("Devel,Live",Request.environment)>
	<cfimport prefix="lh" taglib="../Lighthouse/Tags">
	<cfset pg_title = "Synch Orders">
	<cfinclude template="../Lighthouse/Admin/Header.cfm">

	<p class="STATUSMESSAGE">This template is not designed to run on the server. It runs on the laptops to move listings to the server.</p>
	<cfinclude template="../Lighthouse/Admin/Footer.cfm">
	<cfabort>
</cfif>

<cfset allFields="OrderID">
<cfinclude template="../includes/setVariables.cfm">
<cfmodule template="../includes/_checkNumbers.cfm" fields="OrderID">

<cfinclude template="../includes/getLaptopKey.cfm">
<cfinclude template="../includes/SynchURL.cfm">

<cfparam name="StatusMessage" default="No Order data passed">

<cfset OrderColumns="OrderTotal,PaymentAmount,OrderDate,DueDate,PaymentDate,PaymentStatusID,PaymentMethodID,UserID,CheckNumber">
<cfset ListingPackageColumns="ListingPackageTypeID,FiveListing,TenListing,TwentyListing,UnlimitedListing,PackageEmptyEmailSentDate,ExpirationDate">

<cfif Len(OrderID)>
	<cfquery name="getOrder" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select OrderID, #OrderColumns#,
		(Select Count(O2.OrderID) From Orders O2 Where O2.UserID=O.UserID) as OrderCount
		From Orders O 
		Where O.OrderID=<cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif Len(getOrder.UserID)>
		<cfquery name="getServerUserID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select ServerUserID
			From LH_Users
			Where UserID=<cfqueryparam value="#getOrder.UserID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset ServerUserID=getServerUserID.ServerUserID>
	</cfif>
	<cfoutput query="getOrder">
		<cfset OrderInsert="">
		<cfloop List="#OrderColumns#" index="i">
			<cfif i is "UserID" and Len(getOrder.UserID) and Len(getServerUserID.ServerUserID)><!--- Get the Server's UserID (which will already have been set in the Accounts synching) and use that in the Order record. --->
				<cfset OrderInsert=ListAppend(OrderInsert,getServerUserID.ServerUserID)>
			<cfelse>
				<cfif Len(Evaluate(i))>
					<cfset OrderInsert=ListAppend(OrderInsert,Evaluate(i))>
				<cfelse>
					<cfset OrderInsert=ListAppend(OrderInsert,"null")>
				</cfif>			
			</cfif>
		</cfloop>
	</cfoutput>
	
	<cfquery name="getListingPackage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select ListingPackageID, #ListingPackageColumns#
		From ListingPackages
		Where OrderID=<cfqueryparam value="#getOrder.OrderID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	

	<cfif Len(OrderInsert) and getListingPackage.RecordCount>
		<cfhttp url="http://#SynchURL#/intTasks/SynchListingPackage.cfm" method="POST" timeout="600">
	   		<cfhttpparam type="FORMFIELD" name="OrderInsert" value="#OrderInsert#">
			<cfoutput query="getListingPackage">
				<cfloop List="#ListingPackageColumns#" index="i">
					<cfhttpparam type="FORMFIELD" name="#i#" value="#Evaluate(i)#">					
				</cfloop>
			</cfoutput>
	   		<cfhttpparam type="FORMFIELD" name="AdminUserID" value="#Session.UserID#">
	   		<cfhttpparam type="FORMFIELD" name="LapTopKey" value="#LapTopKey#">
		</cfhttp>
		
		<cfset ReturnValue=Trim(cfhttp.filecontent)>
	
		<!--- <cfoutput>
			#ReturnValue#<p>
		</cfoutput> --->
		<cfif IsNumeric(ReturnValue)><!--- Returning new Server ListingPackgeID --->
			<cfset NewListingPackageID=ReturnValue>
			<cftransaction>
				<cfquery name="updateListingPackage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Update ListingPackages 
					Set ServerListingPackageID=<cfqueryparam value="#NewListingPackageID#" cfsqltype="CF_SQL_INTEGER">
					Where ListingPackageID=<cfqueryparam value="#GetListingPackage.ListingPackageID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				<!--- If other Orders exists, see if any other Orders have Listings using this Listing Package --->
				<cfif getOrder.OrderCount gt 1>
					<cfquery name="checkLPOrders" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						Select O.OrderID
						From Orders O
						Inner Join Listings L on O.OrderID=L.OrderID
						Where L.ListingPackageID=<cfqueryparam value="#GetListingPackage.ListingPackageID#" cfsqltype="CF_SQL_INTEGER">
					</cfquery>
				</cfif>
				<cfif getOrder.OrderCount is "1" or not checkLPOrders.RecordCount><!--- If this is the account's last order to be synched, or any remaining Orders do not use this ListingPackage remove the listing package record and the listing package's order. --->		
					<cfquery name="deleteListingPackage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						Delete From ListingPackages where ListingPackageID=<cfqueryparam value="#GetListingPackage.ListingPackageID#" cfsqltype="CF_SQL_INTEGER">
					</cfquery>					
					<cfquery name="deleteOrderUpdates" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						Delete From Updates where OrderID=<cfqueryparam value="#getOrder.OrderID#" cfsqltype="CF_SQL_INTEGER">
					</cfquery>					
					<cfquery name="deleteOrder" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						Delete From Orders where OrderID=<cfqueryparam value="#getOrder.OrderID#" cfsqltype="CF_SQL_INTEGER">
					</cfquery>		
				</cfif>
			</cftransaction>
			
			<!--- If No Orders are left for the Account, delete it. --->
			<cfquery name="getAccountOrders" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select O.OrderID
				From Orders O
				Where O.UserID=<cfqueryparam value="#getOrder.UserID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<cfif not getAccountOrders.RecordCount>
				<cfquery name="deleteAccountUpdates" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Delete From Updates where UserID=<cfqueryparam value="#getOrder.UserID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				<cfquery name="deleteAccount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Delete From LH_Users where UserID=<cfqueryparam value="#getOrder.UserID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
			</cfif>
			
			<cfset StatusMessage="Order #OrderID# synching completed.">
			<cfset OrderStatusMessage=StatusMessage>
			<cfset OrderSynched="1">
		<cfelse>
			<cfset StatusMessage="Order #OrderID# synching failed.">
			<cfset OrderStatusMessage=StatusMessage>
			<cfset OrderSynched="0">
			<cfoutput>
				#ReturnValue#<p>
			</cfoutput>
			<cfabort>
		</cfif>
	</cfif>
</cfif>
<!--- <cfoutput>#StatusMessage#</cfoutput>
<cfabort> --->

<cflocation url="Synch.cfm?StatusMessage=#URLEncodedFormat(StatusMessage)#" addToken="no">
<cfabort>
