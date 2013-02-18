
<cfset allFields="ListingIDs,ApplyHAndRPackage,ApplyVPackage,ApplyJRPackage,IncludeELPListingIDs,SubtotalAmount,VAT,PaymentAmount,PaymentMethodID,CCNumber,CCExpireMonth,CCExpireYear,CSV,StatusMessage,Checkout">
<cfinclude template="../includes/setVariables.cfm">
<cfmodule template="../includes/_checkNumbers.cfm" fields="CCNumber,PaymentMethodID,CCExpireMonth,CCExpireYear,CSV">

<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfset ContentStyle="innercontent-nolines">

<cfparam name="VPackageListingsRemaining" default="0">
<cfparam name="HAndRPackageListingsRemaining" default="0">
<cfparam name="JRPackageListingsRemaining" default="0">

<cfquery name="getImpressionSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SectionID
	From PageSections
	Where PageID = <cfqueryparam value="#PageID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfset ImpressionSectionID=getImpressionSection.SectionID>
<cfif not Len(ImpressionSectionID)>
	<cfset ImpressionSectionID = 0>
</cfif>

<cfif not IsDefined('application.SectionImpressions')>
	<cfset application.SectionImpressions= structNew()>
</cfif>
<cfif StructKeyExists(application.SectionImpressions,ImpressionSectionID)>
	<cfset application.SectionImpressions[ImpressionSectionID] = application.SectionImpressions[ImpressionSectionID] + 1>
<cfelse>
	<cfset application.SectionImpressions[ImpressionSectionID] = 1>
</cfif>

<cfinclude template="header.cfm">

<cfinclude template="../includes/MyListings.cfm">
<cfinclude template="../includes/MyRenewalCartListings.cfm">

<cfif Len(CheckOut) and Len(ListingIDs)>	
	<cfinclude template="../includes/eventFunctions.cfm">	
	<cftransaction>				
		<cfset OrderID="">
		<cfif PaymentAmount neq '' and PaymentAmount neq "0" and PaymentMethodID is "3">
		<!--- Credit card processing and error handling --->
			<cfset PaymentErrorRedirect="#lh_getPageLink(pageID,'myrenewalcart')#">
			<cfinclude template="../includes/PaymentProcessing.cfm">				
		</cfif>	
		<!--- Insert Order --->
		<cfquery name="insertOrder" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Insert into Orders
			(OrderTotal, PreVATTotal, VAT, PaymentAmount, OrderDate, DueDate, PaymentMethodID, PaymentStatusID, PaymentDate, BillingFirstName, BillingLastName, CCTypeID, CCLastFourDigits, CCExpireMonth, CCExpireYear, CCTransactionID, CSV, UserID)
			VALUES
			(<cfif PaymentAmount is "">0<cfelse><cfqueryparam value="#PaymentAmount#" cfsqltype="CF_SQL_MONEY"></cfif>,
			<cfif SubtotalAmount is "">0<cfelse><cfqueryparam value="#SubtotalAmount#" cfsqltype="CF_SQL_MONEY"></cfif>,
			<cfif VAT is "">0<cfelse><cfqueryparam value="#VAT#" cfsqltype="CF_SQL_MONEY"></cfif>,
			<cfif PaymentMethodID is "3"><cfqueryparam value="#PaymentAmount#" cfsqltype="CF_SQL_MONEY"><cfelseif PaymentAmount is "0">0<cfelse>null</cfif>,
			GetDate(),
			GetDate(),
			<cfqueryparam value="#PaymentMethodID#" cfsqltype="CF_SQL_INTEGER">,
			<cfif PaymentMethodID is "3">
				2, 
				GetDate(),
				null, 
				null, 
				null, 
				<cfqueryparam value="#Right(CCNumber,4)#" cfsqltype="CF_SQL_VARCHARNTEGER">, 
				<cfqueryparam value="#CCExpireMonth#" cfsqltype="CF_SQL_INTEGER">, 
				<cfqueryparam value="#CCExpireYear#" cfsqltype="CF_SQL_INTEGER">, 
				<cfqueryparam value="#CCTransactionID#" cfsqltype="CF_SQL_VARCHAR">, 
				<cfqueryparam value="#CSV#" cfsqltype="CF_SQL_VARCHAR">,
			<cfelseif PaymentAmount is '' or PaymentAmount is "0">
				2, GetDate(), null, null, null, null, null, null, null, null,
			<cfelse>
				1, null, null, null, null, null, null, null, null, null,
			</cfif>
			<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">)
			
			Select Max(OrderID) as NewOrderID
			From Orders
		</cfquery>
		<cfset OrderID=InsertOrder.NewOrderID>	
		
		
		<cfif Len(ApplyHAndRPackage)>
			<cfinclude template="../includes/ListingPackagesHAndRQueries.cfm">
		</cfif>
		
		<cfif Len(ApplyVPackage)>
			<cfinclude template="../includes/ListingPackagesVQueries.cfm">
		</cfif>
		
		<cfif Len(ApplyJRPackage)>
			<cfinclude template="../includes/ListingPackagesJRQueries.cfm">
		</cfif>
		
		<cfloop list="#ListingIDs#" index="i">		
			<cfquery name="getListingFees" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Select L.ListingID, L.ExpandedListingHTML, L.ExpandedListingPDF,
				CASE WHEN LT.AllowFreeRenewal=1 THEN 0 ELSE IsNull(LT.BasicFee,0) END as ListingFee, 
				IsNull(LT.ExpandedFee,0) as ExpandedFee, 
				L.ExpirationDate, L.ListingTypeID
				From ListingsView L
				Inner Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
				Where L.ListingID=<cfqueryparam value="#i#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<cfquery name="renewListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Insert into ListingRenewals
				(ListingID, OrderID, RenewalDate, ListingFee, ExpandedListingFee, IncludesExpandedListing, ListingPackageID)
				VALUES
				(<cfqueryparam value="#i#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER"null="#NOT LEN(OrderID)#">,
				GetDate(),
				<cfif ListFind(ApplyHAndRPackage,i) or ListFind(ApplyVPackage,i) or ListFind(ApplyJRPackage,i)>
					0,
				<cfelse>
					<cfqueryparam value="#getListingFees.ListingFee#" cfsqltype="CF_SQL_MONEY">,
				</cfif>				
				<cfif ListFind(IncludeELPListingIDs,i)>
					<cfqueryparam value="#getListingFees.ExpandedFee#" cfsqltype="CF_SQL_MONEY">,
					1,
				<cfelse>
					0,
					0,
				</cfif>
				<cfif ListFind(ApplyHAndRPackage,i)>
					<cfqueryparam value="#HAndRListingPackageID#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(HAndRListingPackageID)#">
				<cfelseif ListFind(ApplyVPackage,i)>
					<cfqueryparam value="#VListingPackageID#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(VListingPackageID)#">
				<cfelseif ListFind(ApplyJRPackage,i)>
					<cfqueryparam value="#JRListingPackageID#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(JRListingPackageID)#">
				<cfelse>
					null
				</cfif>			
				)
			</cfquery>
		</cfloop>
		<cfinclude template="../includes/SetExpirationDate.cfm">
	</cftransaction>
	
	<cfif PaymentAmount gt "0" and (Request.environment is "Live" or Request.environment is "Devel" or Request.environment is "DB")>
		<cfset NewOrderID=OrderID>
		<cfset NewOrderType="Renewal">
		<cfinclude template="../includes/EmailNewOrder.cfm">
	</cfif>
	
	<cflocation URL="#lh_getPageLink(7,'myaccount')##AmpOrQuestion#StatusMessage=Renewal Order submitted." addToken="No">
	<cfabort>
</cfif>

<script>
	function validateForm(formObj) {				
		if (formObj.PaymentMethodID.selectedIndex==2) {
			if (!checkText(formObj.CCNumber,"Card Number")) {
				return false;
			}
			if (!checkNumber(formObj.CCNumber,"Card Number")) {
				return false;
			}
			if (!checkText(formObj.CSV,"CSV")) {
				return false;
			}
			if (!checkSelected(formObj.CCExpireMonth,"Expiration Date Month")) {
				return false;
			}
			if (!checkSelected(formObj.CCExpireYear,"Expiration Date Year")) {
				return false;
			}
		}
		return true;
	}
</script>

<div class="centercol-inner-wide legacy legacy-wide">
<h1>My Renewal Cart</h1>
<cfif Len(StatusMessage)>
	<p><strong><em>#StatusMessage#</em></strong>
</cfif>		
<lh:MS_SitePagePart id="body" class="body">
<cfoutput>
<form name="f1" action="page.cfm?PageID=#PageID#" method="post" ONSUBMIT="return validateForm(this)">
	<input type="hidden" name="Checkout" value="1">
 <hr />
 <h1>Listings to Renew</h1>
 <br />
 
<cfif AllowHAndR>
	<cfset InCart="1">
	<cfinclude template="../includes/ListingPackagesHAndR.cfm">	
</cfif>

<cfif AllowVehicle>
	<cfset InCart="1">
	<cfinclude template="../includes/ListingPackagesV.cfm">	
</cfif>

<cfif AllowJobRecruiter>
	<cfset InCart="1">
	<cfinclude template="../includes/ListingPackagesJR.cfm">	
</cfif>

<cfif ListingsInCart>
	<table width="705" border="0" cellspacing="0" cellpadding="0" class="listingstable">
    <tr class="listingstable-toprow">
      <td>Listings</td>
      <td class="centered">Site Location</td>
      <td class="centered"><strong>Expires</strong></td>
      <td class="centered">Listing Fee</td>
      <td class="centered">Buy Now</td>
	  <cfif AllowHAndR and HasHAndRListingsInCart and HasOpenHAndRPackages>
	  	<cfset HAndRPackageListingChecked=0>
	  	<td class="centered">Use H&R Package Credit</td>
	  </cfif>
	  <cfif AllowVehicle and HasVListingsInCart and HasOpenVPackages>
	  	<cfset VPackageListingChecked=0>
	  	<td class="centered">Use Vehicle Package Credit</td>
	  </cfif>
	  <cfif AllowJobRecruiter and HasJRListingsInCart and HasOpenJRPackages>
	  	<cfset JRPackageListingChecked=0>
	  	<td class="centered">Use Job Recruitment Package Credit</td>
	  </cfif>
    </tr>
	
	<cfloop query="getMyRenewalCartListings">
	    <tr>
	      <td><strong><cfif ListingTypeID is "10">#ShortDescr#<cfelse>#ListingTitle#</cfif></strong>
			<cfif session.UserID is Request.PhoneOnlyUserID>
			  	<br>(Phone Only Listing)
			</cfif>
			<cfif ListFind("1,2,9,15",ListingTypeID) and session.UserID neq Request.PhoneOnlyUserID>
				<cfif not Len(ExpandedListingPDF) and not Len(ExpandedListingHTML)>
					<p><span class="red">!</span> <a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=3&LinkID=#LinkID#"> Upgrade to a featured listing</a></p>
				<cfelse>
					<p>This listing has an Featured Listing.</p>
				</cfif>
			</cfif>	        
	       </td>
	      <td class="centered">#ParentSection#&nbsp;&gt; <cfif Len(Section)>#Section#&nbsp;&gt; </cfif>#Category#</td>
	      <td class="centered"><span class="ltgray">#TermExpiration# days after payment received</span></td>
	      <td class="centered">	
				<cfif TotalFee is ListingFee>
					#DollarFormat(TotalFee)#
				<cfelse>
					#DollarFormat(TotalFee)#<br>
					<table class="listingstableinner">
						<tr>
							<td colspan="2">
								(#DollarFormat(ListingFee)#&nbsp;Basic)
							</td>
						</tr>
						<tr>
							<td>
								(#DollarFormat(ExpandedFee)#&nbsp;Expanded)
							</td>
							<td>
								<input type="checkbox" name="IncludeELPListingIDs" ID="IncludeELPFee#ListingID#" class="ListingID" value="#ListingID#" checked>
							</td>
						</tr>
					</table>
				</cfif>
		  </td>
	      <td class="centered">
		  	<input type="checkbox" name="ListingIDs" ID="ListingID#ListingID#" class="ListingID" value="#ListingID#" checked>
		  </td>
		  <cfif AllowHAndR and HasHAndRListingsInCart and HasOpenHAndRPackages>
		  	<td class="centered">
				<cfif ListFind("5",ParentSectionID) and ListFind("6,7,8",ListingTypeID)>
					<cfif HAndRPackageListingChecked lt HAndRPackageListingsRemaining>
						<input type="checkbox" name="ApplyHAndRPackage" id="ApplyHAndRPackage#ListingID#" class="ApplyHAndRPackage" value="#ListingID#" checked>
						<cfset HAndRPackageListingChecked=HAndRPackageListingChecked+1>						
					<cfelse>
						<input type="checkbox" name="ApplyHAndRPackage" id="ApplyHAndRPackage#ListingID#" class="ApplyHAndRPackage" value="#ListingID#">
					</cfif>
					
				</cfif>
			</td>
		  </cfif>
		  <cfif AllowVehicle and HasVListingsInCart and HasOpenVPackages>
		  	<td class="centered">
				<cfif ListFind("4",ParentSectionID) and ListFind("84,85,86",CategoryID)>
					<cfif VPackageListingChecked lt VPackageListingsRemaining>
						<input type="checkbox" name="ApplyVPackage" id="ApplyVPackage#ListingID#" class="ApplyVPackage" value="#ListingID#" checked>
						<cfset VPackageListingChecked=VPackageListingChecked+1>						
					<cfelse>
						<input type="checkbox" name="ApplyVPackage" id="ApplyVPackage#ListingID#" class="ApplyVPackage" value="#ListingID#">
					</cfif>
				</cfif>
			</td>
		  </cfif>
		  <cfif AllowJobRecruiter and HasJRListingsInCart and HasOpenJRPackages>
		  	<td class="centered">
				<cfif ListFind("10",ListingTypeID)>
					<cfif JRPackageListingChecked lt JRPackageListingsRemaining>
						<input type="checkbox" name="ApplyJRPackage" id="ApplyJRPackage#ListingID#" class="ApplyJRPackage" value="#ListingID#" checked>
						<cfset JRPackageListingChecked=JRPackageListingChecked+1>						
					<cfelse>
						<input type="checkbox" name="ApplyJRPackage" id="ApplyJRPackage#ListingID#" class="ApplyJRPackage" value="#ListingID#">
					</cfif>
				</cfif>
			</td>
		  </cfif>
	    </tr>	
	</cfloop>
  </table><br />
<cfelse>
	<p><em>There are no Listings in your renewal cart at this time. Would you like to <a href="#lh_getPageLink(7,'myaccount')#">add one now</a>?</em></p>
</cfif> 

<br /><hr />

<cfset PaymentAmount=FeesInCart>
<cfset ShowSaveForLater="0">

<cfinclude template="../includes/PaymentFields.cfm">
 
  <!-- END CENTER COL -->

<!-- RIGHT COL -->
</form>
</cfoutput>
</div>

<!-- END CENTER COL -->

<cfset ShowRightColumn="0">
<cfinclude template="footer.cfm">
<cfoutput>
<script language="javascript" type="text/javascript">
	$(document).ready(function()
	{	
		getCartTotal();
		listingIDChecked();
		$(".ListingID").click(listingIDChecked);
		$(".ApplyHAndRPackage").click(applyHAndRPackageIDChecked);
		$(".ApplyVPackage").click(applyVPackageIDChecked);		
		$(".ApplyJRPackage").click(applyJRPackageIDChecked);	
		
	});
	
	<!--- Automatically uncheck any "Use Package Credt" checkboxes if "Buy  Now" is unchecked --->
	function listingIDChecked() {
		$('input:checkbox[name=ListingID]').each(function() {
			if ($(this).is(":checked")==false) {
				$("##ApplyHAndRPackage" + $(this).val()).attr('checked', false);
				$("##ApplyVPackage" + $(this).val()).attr('checked', false);
				$("##ApplyJRPackage" + $(this).val()).attr('checked', false);
			}
		});
		applyHAndRPackageIDChecked();
		applyVPackageIDChecked();
		applyJRPackageIDChecked();
	}
	<!--- Automatically check and "Buy Now" checkboxes if "Use H&R Package Credit" is checked --->
	function applyHAndRPackageIDChecked() {
		var HAndRCheckedCount=0;
		$('input:checkbox[name=ApplyHAndRPackage]').each(function() {
			if ($(this).is(":checked")==true) {
				if(HAndRCheckedCount<#HAndRPackageListingsRemaining#) {					
					$("##ListingID" + $(this).val()).attr('checked', true);
					$("##TotalFeeSpan" + $(this).val()).attr('style', 'text-decoration: line-through;');
					HAndRCheckedCount=HAndRCheckedCount+1;
				}
				else {
					$("##ApplyHAndRPackage" + $(this).val()).attr('checked', false);
					$("##TotalFeeSpan" + $(this).val()).attr('style', '');
					alert('You have already checked #HAndRPackageListingsRemaining# listings in your cart as "Use H&R Package Credit".');
				}
			}
			else {
				$("##TotalFeeSpan" + $(this).val()).attr('style', '');
			}
		});
		applyVPackageIDChecked();
	}
	
	<!--- Automatically check and "Buy Now" checkboxes if "Use Vehicle Package Credit" is checked --->
	function applyVPackageIDChecked() {
		var VCheckedCount=0;
		$('input:checkbox[name=ApplyVPackage]').each(function() {
			if ($(this).is(":checked")==true) {
				if(VCheckedCount<#VPackageListingsRemaining#) {					
					$("##ListingID" + $(this).val()).attr('checked', true);
					$("##TotalFeeSpan" + $(this).val()).attr('style', 'text-decoration: line-through;');
					VCheckedCount=VCheckedCount+1;
				}
				else {
					$("##ApplyVPackage" + $(this).val()).attr('checked', false);
					$("##TotalFeeSpan" + $(this).val()).attr('style', '');
					alert('You have already checked #VPackageListingsRemaining# listings in your cart as "Use Vehicle Package Credit".');
				}
			}
			else {
				$("##TotalFeeSpan" + $(this).val()).attr('style', '');
			}
		});
		getCartTotal();
	}
	
	<!--- Automatically check and "Buy Now" checkboxes if "Use Job Recruitment Package Credit" is checked --->
	function applyJRPackageIDChecked() {
		var JRCheckedCount=0;
		$('input:checkbox[name=ApplyJRPackage]').each(function() {
			if ($(this).is(":checked")==true) {
				if(JRCheckedCount<#JRPackageListingsRemaining#) {					
					$("##ListingID" + $(this).val()).attr('checked', true);
					$("##TotalFeeSpan" + $(this).val()).attr('style', 'text-decoration: line-through;');
					JRCheckedCount=JRCheckedCount+1;
				}
				else {
					$("##ApplyJRPackage" + $(this).val()).attr('checked', false);
					$("##TotalFeeSpan" + $(this).val()).attr('style', '');
					alert('You have already checked #JRPackageListingsRemaining# listings in your cart as "Use Job Recruitment Package Credit".');
				}
			}
			else {
				$("##TotalFeeSpan" + $(this).val()).attr('style', '');
			}
		});
		getCartTotal();
	}
	
	function getCartTotal() {
		var checkedListingIDs='';	
		$('input:checkbox[name=ListingIDs]:checked').each(function() {
			if (checkedListingIDs=='') {
				checkedListingIDs = this.value;	
			}
			else {
				checkedListingIDs = checkedListingIDs + ',' + this.value;			
			}
		});
		
		var checkedIncludeELPListingIDs='';	
		$('input:checkbox[name=IncludeELPListingIDs]:checked').each(function() {
			if (checkedIncludeELPListingIDs=='') {
				checkedIncludeELPListingIDs = this.value;	
			}
			else {
				checkedIncludeELPListingIDs = checkedIncludeELPListingIDs + ',' + this.value;			
			}
		});
		
		var checkedApplyHAndRPackageListingIDs='';	
		$('input:checkbox[name=ApplyHAndRPackage]:checked').each(function() {
			if (checkedApplyHAndRPackageListingIDs=='') {
				checkedApplyHAndRPackageListingIDs = this.value;	
			}
			else {
				checkedApplyHAndRPackageListingIDs = checkedApplyHAndRPackageListingIDs + ',' + this.value;			
			}
		});
		var checkedApplyVPackageListingIDs='';	
		$('input:checkbox[name=ApplyVPackage]:checked').each(function() {
			if (checkedApplyVPackageListingIDs=='') {
				checkedApplyVPackageListingIDs = this.value;	
			}
			else {
				checkedApplyVPackageListingIDs = checkedApplyVPackageListingIDs + ',' + this.value;			
			}
		});
		var checkedApplyJRPackageListingIDs='';	
		$('input:checkbox[name=ApplyJRPackage]:checked').each(function() {
			if (checkedApplyJRPackageListingIDs=='') {
				checkedApplyJRPackageListingIDs = this.value;	
			}
			else {
				checkedApplyJRPackageListingIDs = checkedApplyJRPackageListingIDs + ',' + this.value;			
			}
		});
		
		var datastring = "ListingIDs=" + checkedListingIDs + "&IncludeELPListingIDs=" + checkedIncludeELPListingIDs + "&ApplyHAndRPackageListingID=" + checkedApplyHAndRPackageListingIDs + "&ApplyVPackageListingID=" + checkedApplyVPackageListingIDs + "&ApplyJRPackageListingID=" + checkedApplyJRPackageListingIDs;    
		$.ajax(
           {
			type:"POST",
			dataType: 'json',
               url:"#Request.HTTPSURL#/includes/GetRenewalCartTotal.cfc?method=GetCartTotal&returnformat=plain",
               data:datastring,
               success: function(responseVars)
               {
			    $("##SubtotalAmountSpan").html('$' + parseFloat(responseVars.SubtotalAmount).toFixed(2));
				$("##SubtotalAmount").val(responseVars.SubtotalAmount);	
				$("##VATAmountSpan").html('$' + parseFloat(responseVars.VAT).toFixed(2));
				$("##VAT").val(responseVars.VAT);	
				$("##PaymentAmountSpan").html('$' + parseFloat(responseVars.PaymentAmount).toFixed(2));
				$("##PaymentAmount").val(responseVars.PaymentAmount);					
               }
           });		
	}
</script>
</cfoutput>
