
<cfset allFields="ListingID,IncludeELP,LinkID,SubtotalAmount,VAT,PaymentAmount,PaymentMethodID,CCNumber,CCExpireMonth,CCExpireYear,CSV,StatusMessage,Checkout">
<cfinclude template="../includes/setVariables.cfm">
<cfmodule template="../includes/_checkNumbers.cfm" fields="CCNumber,PaymentMethodID,CCExpireMonth,CCExpireYear,CSV">

<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfset ContentStyle="innercontent-nolines">

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

<cfif Len(CheckOut) and Len(LinkID)>	
	<cfinclude template="../includes/FindListing.cfm">
	<cfinclude template="../includes/eventFunctions.cfm">	
	<cftransaction>				
		<cfset OrderID="">
		<cfif PaymentAmount neq '' and PaymentAmount neq "0" and PaymentMethodID is "3">
		<!--- Credit card processing and error handling --->
			<cfset PaymentErrorRedirect="#lh_getPageLink(pageID,'renewlisting')#">
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
			null)
			
			Select Max(OrderID) as NewOrderID
			From Orders
		</cfquery>
		<cfset OrderID=InsertOrder.NewOrderID>	
		<cfquery name="getListingFees" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select L.ListingID, L.ExpandedListingHTML, L.ExpandedListingPDF,
			CASE WHEN LT.AllowFreeRenewal=1 THEN 0 ELSE IsNull(LT.BasicFee,0) END as ListingFee, 
			IsNull(LT.ExpandedFee,0) as ExpandedFee, 
			L.ExpirationDate, L.ListingTypeID
			From ListingsView L
			Inner Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
			Where L.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfquery name="renewListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Insert into ListingRenewals
			(ListingID, OrderID, RenewalDate, ListingFee, ExpandedListingFee, IncludesExpandedListing)
			VALUES
			(<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">,
			<cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER"null="#NOT LEN(OrderID)#">,
			GetDate(),
			<cfqueryparam value="#getListingFees.ListingFee#" cfsqltype="CF_SQL_MONEY">,
			<cfif IncludeELP is "1">
				<cfqueryparam value="#getListingFees.ExpandedFee#" cfsqltype="CF_SQL_MONEY">,
				1
			<cfelse>
				0,
				0
			</cfif>				
			)
		</cfquery>
		<cfinclude template="../includes/SetExpirationDate.cfm">
	</cftransaction>
	<cflocation URL="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=3&LinkID=#LinkID#&StatusMessage=Renewal submitted." addToken="No">
	<cfabort>
<cfelse>

	<cfquery name="getMyRenewalListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ListingID, L.LinkID, 
		CASE WHEN LT.AllowFreeRenewal=1 THEN 0 ELSE IsNull(LT.BasicFee,0) END as ListingFee, 
		IsNull(LT.ExpandedFee,0) as ExpandedFee, 
		L.ListingTitle, L.ExpirationDate, L.ListingTypeID,
		L.Make as MakeOther, L.Model as ModelOther, L.VehicleYear, L.ExpandedListingPDF, L.ExpandedListingHTML,
		PS.Title as ParentSection, S.SectionID, S.Title as Section, C.CategoryID, C.Title as Category,
		LT.TermExpiration,
		M.Title as Make,
		CASE WHEN L.ExpandedListingHTML is null and L.ExpandedListingPDF is null  and LT.AllowFreeRenewal=0 THEN IsNull(LT.BasicFee,0)
		WHEN L.ExpandedListingHTML is null and L.ExpandedListingPDF is null  and LT.AllowFreeRenewal=1 THEN 0
		WHEN LT.AllowFreeRenewal=0 THEN IsNull(LT.BasicFee,0) + IsNull(LT.ExpandedFee,0)
		ELSE IsNull(LT.ExpandedFee,0) END as TotalFee
		From ListingsView L
		Inner Join ListingParentSections LPS on L.ListingID=LPS.ListingID
		Inner Join ParentSectionsView PS On LPS.ParentSectionID=PS.ParentSectionID
		Inner Join ListingCategories LC on L.ListingID=LC.ListingID
		Inner Join Categories C on LC.CategoryID=C.CategoryID
		Inner Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
		Left Outer Join ListingSections LS on L.ListingID=LS.ListingID
		Left Outer Join SectionsView S on LS.SectionID=S.SectionID
		Left Outer Join Makes M on L.MakeID=M.MakeID
		Where L.LinkID 	<cfif Len(LinkID)>
								= <cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">
							<cfelse><!--- When being viewed in CMS editor. --->
								= '0'
							</cfif>
	</cfquery>

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
	<h1>Renew Listing</h1>
	<cfif Len(StatusMessage)>
		<p><strong><em>#StatusMessage#</em></strong>
	</cfif>		
	<lh:MS_SitePagePart id="body" class="body">
	<cfoutput>
	<form name="f1" action="page.cfm?PageID=#PageID#" method="post" ONSUBMIT="return validateForm(this)">
		<input type="hidden" name="Checkout" value="1">
	 <hr />
	 <!--- <h1>Renew Listing</h1> --->
	 <br />
	
	<cfif getMyRenewalListing.RecordCount>
		<table width="705" border="0" cellspacing="0" cellpadding="0" class="listingstable">
	    <tr class="listingstable-toprow">
	      <td>Listing</td>
	      <td class="centered">Site Location</td>
	      <td class="centered"><strong>Expires</strong></td>
	      <td class="centered">Renewal Fee</td>
	    </tr>
		
		<cfloop query="getMyRenewalListing">
		    <tr>
		      <td><strong>#ListingTitle#</strong>
				<cfif ListFind("1,2,9,15",ListingTypeID)>
					<cfif Len(ExpandedListingPDF) or Len(ExpandedListingHTML)>
						<p>This listing has an Featured Listing.</p>
					</cfif>
				</cfif>	
				<input type="hidden" name="LinkID" value="#LinkID#">        
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
								<input type="checkbox" name="IncludeELP" ID="IncludeELP#ListingID#" class="IncludeELP" value="1" checked>
							</td>
						</tr>
					</table>
				</cfif>
			  </td>
		    </tr>	
		</cfloop>
	  </table><br />
	
		<br /><hr />
		
		<cfset SubtotalAmount=getMyRenewalListing.ListingFee>
		<cfset SubtotalAmountIncludeELP=getMyRenewalListing.TotalFee>
		<cfinclude template="../includes/VATCalc.cfm">
		
		<cfset PaymentAmount=SubtotalAmount+VAT>
		<cfset PaymentAmountIncludeELP=SubtotalAmountIncludeELP+VATIncludeELP>
		
		<cfset ShowSaveForLater="0">
		
		<cfset showTopText="0">
		<cfinclude template="../includes/PaymentFields.cfm">
	 
	<cfelse>
		<p><em>No listing was found</em></p>
	</cfif> 
	  <!-- END CENTER COL -->
	
	<!-- RIGHT COL -->
	</form>
	</cfoutput>
	</div>

</cfif>
<!-- END CENTER COL -->

<cfset ShowRightColumn="0">
<cfinclude template="footer.cfm">
<cfif not edit>
	<cfoutput>
	<script language="javascript" type="text/javascript">
		$(document).ready(function()
		{	
			getCartTotal();
			$(".IncludeELP").click(getCartTotal);
		});
		
		function getCartTotal() {
			if ($(".IncludeELP").is(':checked')) {
				$("##SubtotalAmountSpan").html('#DollarFormat(SubtotalAmountIncludeELP)#');
				$("##SubtotalAmount").val(#SubtotalAmountIncludeELP#);	
				$("##VATAmountSpan").html('#DollarFormat(VATIncludeELP)#');
				$("##VAT").val(#VATIncludeELP#);	
				$("##PaymentAmountSpan").html('#DollarFormat(PaymentAmountIncludeELP)#');	
				$("##PaymentAmount").val(#PaymentAmountIncludeELP#);	
			}
			else {
				$("##SubtotalAmountSpan").html('#DollarFormat(SubtotalAmount)#');
				$("##SubtotalAmount").val(#SubtotalAmount#);	
				$("##VATAmountSpan").html('#DollarFormat(VAT)#');
				$("##VAT").val(#VAT#);	
				$("##PaymentAmountSpan").html('#DollarFormat(PaymentAmount)#');
				$("##PaymentAmount").val(#PaymentAmount#);	
			}
		}
	</script>
	</cfoutput>
</cfif>

