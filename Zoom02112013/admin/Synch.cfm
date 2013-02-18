<cfset allFields="StatusMessage">
<cfinclude template="../includes/setVariables.cfm">

<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Synch From Laptop">
<cfinclude template="../Lighthouse/Admin/Header.cfm">

<cfoutput><script language="JavaScript" src="#Request.HTTPSURL#/scripts/jquery-1.3.2.min.js" type="text/javascript"></script></cfoutput>

<cfif ListFind("Devel,Live",Request.environment)>
	<p class="STATUSMESSAGE">This template is not designed to run on the server. It runs on the laptops to move listings to the server.</p>
	<cfinclude template="../Lighthouse/Admin/Footer.cfm">
	<cfabort>
</cfif>

<cfquery name="getAccount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select Top 1 U.UserID, U.ServerUserID, U.Company,
	Case When ServerUserID is null THEN 0 ELSE 1 END as Synched
	From LH_Users U
	Where AdminUser=0
	Order by Synched desc, UserID
</cfquery>

<cfquery name="getOrder" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select Top 1 O.OrderID, LP.ListingPackageID
	From Orders O
	Left Outer Join ListingPackages LP on O.OrderID=LP.OrderID
	Where LP.ServerListingPackageID is null
	<cfif getAccount.RecordCount and getAccount.Synched>
		and O.UserID=<cfqueryparam value="#getAccount.UserID#" cfsqltype="CF_SQL_INTEGER">
	<cfelse>
		and O.UserID is null
	</cfif>
	Order by O.OrderID
</cfquery>

<cfif Len(StatusMessage)>
	<cfoutput>
		<p class="STATUSMESSAGE">#StatusMessage#</p>
	</cfoutput>
</cfif>
<script>
	function hideSynchButton() {
		$("#OrderButtonSpan").hide();
		$("#OrderSubmittedSpan").show();
		return true;
	}
</script>
<cfoutput>
<cfif getAccount.RecordCount>
	<cfif getAccount.Synched><!--- Account already synched. Synch Account's Order --->
		<cfif Len(getOrder.ListingPackageID)><!--- If ListingPackage Order, synch order and update ListingPackage with Server ListingPackageID --->	
			<form name="f1" action="SynchListingPackage.cfm" method="post" onSubmit="return hideSynchButton();">
				<input type="hidden" name="OrderID" value="#getOrder.OrderID#">
				<span id="OrderButtonSpan"><input type="submit" value="Synch '#getAccount.Company#' Order ID: #getOrder.OrderID#"></span><br>
				<span id="OrderSubmittedSpan" class="STATUSMESSAGE" style="display:none;">Synching...</span>
			</form>
		<cfelse><!--- If Listing(s) Order, synch order, checking to see if any listing was part of a listingPackage and if so, use ServerListingPackageID during insert --->		
			<form name="f1" action="SynchOrder.cfm" method="post" onSubmit="return hideSynchButton();">
				<input type="hidden" name="OrderID" value="#getOrder.OrderID#">
				<span id="OrderButtonSpan"><input type="submit" value="Synch '#getAccount.Company#' Order ID: #getOrder.OrderID#"></span><br>
				<span id="OrderSubmittedSpan" class="STATUSMESSAGE" style="display:none;">Synching...</span>
			</form>
		</cfif>
	<cfelse><!--- Synch Account Record --->
		<form name="f1" action="SynchAccount.cfm" method="post" onSubmit="return hideSynchButton();">
			<input type="hidden" name="AccountID" value="#getAccount.UserID#">
			<span id="OrderButtonSpan"><input type="submit" value="Synch Account: #getAccount.Company#"></span><br>
			<span id="OrderSubmittedSpan" class="STATUSMESSAGE" style="display:none;">Synching...</span>
		</form>
	</cfif>
<cfelseif getOrder.RecordCount>	
	<form name="f1" action="SynchOrder.cfm" method="post" onSubmit="return hideSynchButton();">
		<input type="hidden" name="OrderID" value="#getOrder.OrderID#">
		<span id="OrderButtonSpan"><input type="submit" value="Synch OrderID: #getOrder.OrderID#"></span><br>
		<span id="OrderSubmittedSpan" class="STATUSMESSAGE" style="display:none;">Synching...</span>
	</form>
<cfelse>
	No Accounts or Orders to synch.
</cfif>
</cfoutput>
<cfinclude template="../Lighthouse/Admin/Footer.cfm">