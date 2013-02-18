<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfinclude template="UpSellButtons.cfm">

<cfset allFields="LinkID">
<cfinclude template="setVariables.cfm">

<cfset ListingID="">

<cfinclude template="FindListing.cfm">
<cfif IsDefined('session.UserID') and Len(session.UserID) and not edit>
	<cfinclude template="../includes/MyListings.cfm">
	<cfif AllowHAndR>
		<hr>
		<cfinclude template="../includes/ListingPackagesHAndR.cfm">	
	</cfif>	
	<cfif AllowVehicle>
		<hr>
		<cfinclude template="../includes/ListingPackagesV.cfm">	
	</cfif>
	<cfif not AllowHAndR and not AllowVehicle>
		<hr>
	</cfif>
	<cfoutput>
	<div>
		<a href="#lh_getPageLink(7,'myaccount')#">Go to My Account</a><br />
		<!--- <a href="#lh_getPageLink(20,'mytendersnotifications')#">Receive Tender Notifications</a><br /> --->
		<a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/?Logout=Y">Log Out</a>
	</div>
	</cfoutput>
	
</cfif>
<cfif Len(getListing.OrderID)>
	<cfoutput>
		<cfswitch expression="#getOrder.PaymentMethodID#">
			<cfcase value="1,2">
				<table width="650" border="0" cellspacing="0" cellpadding="0" class="datatable">
				   <tr>
				     <td valign="top"><p><strong>Payment Information</strong></p>
				       <table width="100%" border="0" cellspacing="0" cellpadding="0" class="datatable">
				         <tr>
				           <td>Total Fee:</td>
				           <td class="ltgray">#DollarFormat(getOrder.OrderTotal)#</td>
				         </tr>
				         <tr>
				           <td valign="top">Payment Method:</td>
				           <td class="ltgray">#getOrder.PaymentMethod#</td>
				         </tr>
				         <tr>
				           <td>Payment Due Date:</td>
				           <td class="ltgray">#DateFormat(getOrder.DueDate,'dd/mm/yyyy')#</td>
				         </tr>
				       </table>
				     </td>
				   </tr>
				 </table>
			</cfcase>
			<cfcase value="3">
				<table width="650" border="0" cellspacing="0" cellpadding="0" class="datatable">
				   <tr>
				     <td valign="top"><p><strong>Your Receipt</strong></p>
				       <table width="100%" border="0" cellspacing="0" cellpadding="0" class="datatable">
				         <tr>
				           <td>Total Fee:</td>
				           <td class="ltgray">#DollarFormat(getOrder.OrderTotal)#</td>
				         </tr>
				         <tr>
				           <td valign="top">Payment Method:</td>
				           <td class="ltgray">#getOrder.PaymentMethod#</td>
				         </tr>
				         <tr>
				           <td>Credit Card ##:</td>
				           <td class="ltgray">****#getOrder.CCLastFourDigits#</td>
				         </tr>
				         <tr>
				           <td valign="top">Credit Card Expiration Date:</td>
				           <td class="ltgray" valign="top">#MonthasString(getOrder.CCExpireMonth)# #getOrder.CCExpireYear#</td>
				         </tr>
				       </table>
				       <p>&nbsp;</p></td>
				   </tr>
				 </table>
			</cfcase>
		</cfswitch>
	</cfoutput>
</cfif>


