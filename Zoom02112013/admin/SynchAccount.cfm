<!--- This template expects an AccountID  --->



<cfif ListFind("Devel,Live",Request.environment)>
	<cfimport prefix="lh" taglib="../Lighthouse/Tags">
	<cfset pg_title = "Synch Accounts">
	<cfinclude template="../Lighthouse/Admin/Header.cfm">

	<p class="STATUSMESSAGE">This template is not designed to run on the server. It runs on the laptops to move listings to the server.</p>
	<cfinclude template="../Lighthouse/Admin/Footer.cfm">
	<cfabort>
</cfif>

<cfset allFields="AccountID">
<cfinclude template="../includes/setVariables.cfm">
<cfmodule template="../includes/_checkNumbers.cfm" fields="AccountID">

<cfinclude template="../includes/getLaptopKey.cfm">
<cfinclude template="../includes/SynchURL.cfm">

<cfparam name="StatusMessage" default="No Account data passed">

<cfset AccountColumns="UserName,Password,Website,Active,Company,ContactFirstName,ContactLastName,ContactPhoneLand,ContactPhoneMobile,ContactEmail,AltContactFirstName,AltContactLastName,AltContactPhoneLand,AltContactPhoneMobile,AltContactEmail">
<cfset UpdateColumns="UpdateDate,UpdatedByID,Descr">


<cfif Len(AccountID)>
	<cfquery name="getAccount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select  #AccountColumns#
		From LH_Users
		Where ServerUserID is null
		and UserID=<cfqueryparam value="#AccountID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<cfquery name="getAccountUpdates" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select #UpdateColumns#
		From Updates
		Where UserID=<cfqueryparam value="#AccountID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<!--- Tender Notifications --->
	<cfquery name="getUserCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select CategoryID
		From UserCategories
		Where UserID=<cfqueryparam value="#AccountID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<cfset UpdatesCount=getAccountUpdates.RecordCount>
	
	<cfif getAccount.RecordCount>
		<cfhttp url="http://#SynchURL#/intTasks/SynchAccount.cfm" method="POST" timeout="600">
	   		<cfhttpparam type="FORMFIELD" name="AccountID" value="#AccountID#">
			<cfoutput query="getAccount">
				<cfloop List="#AccountColumns#" index="i">
					<cfhttpparam type="FORMFIELD" name="#i#" value="#Evaluate(i)#">					
				</cfloop>
			</cfoutput>
			<cfhttpparam type="FORMFIELD" name="TenderNotificationCategories" value="#ValueList(getUserCategories.CategoryID)#">
			<cfhttpparam type="FORMFIELD" name="UpdatesCount" value="#UpdatesCount#">
			<cfoutput query="getAccountUpdates">
				<cfloop List="#UpdateColumns#" index="i">
					<cfhttpparam type="FORMFIELD" name="Update_#CurrentRow#_#i#" value="#Evaluate(i)#">					
				</cfloop>
			</cfoutput>
	   		<cfhttpparam type="FORMFIELD" name="AdminUserID" value="#Session.UserID#">
	   		<cfhttpparam type="FORMFIELD" name="LapTopKey" value="#LapTopKey#">
		</cfhttp>
		
		<cfset ReturnValue=Trim(cfhttp.filecontent)>
	
		<!--- <cfoutput>
			#ReturnValue#<p>
		</cfoutput> --->
		<cfif IsNumeric(ReturnValue)><!--- Returning new Server UserID --->
			<cfset NewAccountID=ReturnValue>
			<cfquery name="updateAccount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Update LH_Users 
				Set ServerUserID=<cfqueryparam value="#NewAccountID#" cfsqltype="CF_SQL_INTEGER">
				Where UserID=<cfqueryparam value="#AccountID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<!--- Now get Account's Orders and synch initial order --->
			<cfquery name="getAccountOrders" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select OrderID
				From Orders
				Where UserID=<cfqueryparam value="#AccountID#" cfsqltype="CF_SQL_INTEGER">
				Order by OrderID
			</cfquery>
			<cfset OrderID=getAccountOrders.OrderID>
			<cfset PartOfAccountSynch="1">
			<cfinclude template="SynchOrder.cfm">			
			<cfset StatusMessage="Account #AccountID# synching completed.<br />" & OrderStatusMessage>
		<cfelse>
			<cfset StatusMessage="Account #AccountID# synching failed.">
		</cfif>
	</cfif>
</cfif>
<!--- <cfoutput>#StatusMessage#</cfoutput>
<cfabort> --->
<cflocation url="Synch.cfm?StatusMessage=#URLEncodedFormat(StatusMessage)#" addToken="no">
<cfabort>


