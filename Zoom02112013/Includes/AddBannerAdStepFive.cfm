<cfimport prefix="lh" taglib="../Lighthouse/Tags">


<cfset allFields="BannerAdID">
<cfinclude template="setVariables.cfm">


<cfquery name="getOrder" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	select o.* ,pm.title as PaymentMethod
	from orders o
	inner join paymentMethods pm on o.paymentMethodID = pm.paymentMethodID
	where OrderID = <cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>	
<p>
Thank you for purchasing a banner ad on ZoomTanzania.com! You will receive regular email updates from
us about the number of visitors that have viewed your banner ad. We appreciate the opportunity to help
you grow your business.<br><br>
You can edit your banner ad at any time by following the link in the email or visiting <a href="/myaccount">My Account</a>, etc.
Other text to explain.

</p>	
<cfif Len(getOrder.OrderID)>
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
<cfoutput>
<input type="button" name="postalisting" id="postalisting" value="Post a Listing" class="btn"  onClick="location.href='#lh_getPageLink(5,'postalisting')#'" />
	<input type="button" name="postabannerad" id="postabannerad" value="Post a Banner Ad" class="btn"  onClick="location.href='#lh_getPageLink(21,'postabannerad')#'" />
	<input name="postanevent" type="button" value="Post an Event" class="btn" id="postanevent" onClick="location.href='#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=46&CategoryID=103'" />
	<input name="postanevent" type="button" value="Post an Employment Opportunity" class="btn" id="postanemploymentopportunity" onClick="location.href='#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=8&ListingSectionID=19&ListingTypeID=10'" />
</cfoutput>
 <br />



