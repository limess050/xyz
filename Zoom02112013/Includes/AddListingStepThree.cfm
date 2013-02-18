<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfset allFields="ListingID,LinkID,SubtotalAmount,VAT,PaymentAmount,PaymentMethodID,CCNumber,CCExpireMonth,CCExpireYear,CSV,SaveListing,SaveForLater,StatusMessage,DeleteListing,ProcessELPDocs,StatusMessageFileType">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="CCNumber,ListingID,PaymentMethodID,CCExpireMonth,CCExpireYear,CSV">

<cfset ListingID="">

<cfinclude template="FindListing.cfm">

<cfif Len(SaveListing)>	
	<cfif Len(SaveForLater)>
		<cflocation URL="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=5&LinkID=#LinkID#" addToken="No">
		<cfabort>
	</cfif>
	<!--- <cftransaction> --->			
		<cfif getListing.InProgress and ListFind("1,2,14",getListing.ListingTypeID) and (not IsDefined('session.UserID') or session.UserID is "")>
			<!--- If Business Listing, create Account in LH_Users --->
			<cfquery name="createAccount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Insert into LH_Users
				(UserName, Password, Website, Active, Company, 
				ContactFirstName, ContactLastName, ContactPhoneLand, ContactPhoneMobile, ContactEmail,
				AltContactFirstName, AltContactLastName, AltContactPhoneLand, AltContactPhoneMobile, AltContactEmail)
				VALUES
				(<cfqueryparam value="#getListing.ContactEmail#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(getListing.ContactEmail)#">,
				<cfqueryparam value="#getListing.InProgressPassword#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(getListing.InProgressPassword)#">,
				<cfqueryparam value="#getListing.WebsiteURL#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(getListing.WebsiteURL)#">,
				1,
				<cfqueryparam value="#getListing.InProgressCompanyName#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(getListing.ListingTitle)#">,
				<cfqueryparam value="#getListing.ContactFirstName#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(getListing.ContactFirstName)#">,
				<cfqueryparam value="#getListing.ContactLastName#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(getListing.ContactLastName)#">,
				<cfqueryparam value="#getListing.ContactPhone#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(getListing.ContactPhone)#">,
				<cfqueryparam value="#getListing.ContactSecondPhone#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(getListing.ContactSecondPhone)#">,
				<cfqueryparam value="#getListing.ContactEmail#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(getListing.ContactEmail)#">,
				<cfqueryparam value="#getListing.AltContactFirstName#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(getListing.AltContactFirstName)#">,
				<cfqueryparam value="#getListing.AltContactLastName#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(getListing.AltContactLastName)#">,
				<cfqueryparam value="#getListing.AltContactPhone#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(getListing.AltContactPhone)#">,
				<cfqueryparam value="#getListing.AltContactSecondPhone#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(getListing.AltContactSecondPhone)#">,
				<cfqueryparam value="#getListing.AltContactEmail#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(getListing.AltContactEmail)#">)	
				
				Select Max(UserID) as NewUserID
				From LH_Users	
			</cfquery>
			<cfset NewUserID=createAccount.NewUserID>
			<cfif Request.environment is "Live" or Request.environment is "Devel" or Request.environment is "DB">
				<cfset NewAccountID=NewUserID>
				<cfset NewAccountName=getListing.InProgressCompanyName>
				<cfset NewUserName=getListing.ContactEmail>
				<cfif Len(getListing.AltContactEmail)>
					<cfset NewUserName=ListAppend(NewUserName,getListing.AltContactEmail)>
				</cfif>
				<cfset NewPassword=getListing.InProgressPassword>
				<cfinclude template="EmailNewAccount.cfm">
			</cfif>
		<cfelse>
			<cfset NewUserID="">
		</cfif>
		
		<cfset OrderID="">
		
		<cfif IsDefined('session.UserID') and Len(session.UserID) AND getListing.InProgress>
		<!--- If logged in, go to cart unless they are submitting just an expanded listing. --->
			<cfif Len(ProcessELPDocs)>
				<cfinclude template="ProcessELPDocs.cfm">
			</cfif>
			<cflocation url="#lh_getPageLink(14,'mycart')#" addToken="no">
			<cfabort>	
		<cfelse>
			<cfif PaymentAmount neq '' and PaymentAmount neq "0" and PaymentMethodID is "3">
			<!--- Credit card processing and error handling --->
				<cfset PaymentErrorRedirect="page.cfm?PageID=#PageID#&LinkID=#LinkID#&Step=3">
				<cfinclude template="PaymentProcessing.cfm">				
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
					<cfif IsDefined('CCTransactionID')>
						<cfqueryparam value="#CCTransactionID#" cfsqltype="CF_SQL_VARCHAR">, 
					<cfelse><!--- No fee but user selected CCard as Payment Method --->
						'NO FEE',
					</cfif>
					<cfqueryparam value="#CSV#" cfsqltype="CF_SQL_VARCHAR">,
				<cfelseif PaymentAmount is '' or PaymentAmount is "0">
					2, GetDate(), null, null, null, null, null, null, null, null,
				<cfelse>
					1, null, null, null, null, null, null, null, null, null,
				</cfif>
				<cfif Len(NewUserID)>
					<cfqueryparam value="#NewUserID#" cfsqltype="CF_SQL_INTEGER">
				<cfelseif Len(session.UserID)><!--- Logged in User adding just an Expanded Listing to an existing Listing --->
					<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
				<cfelse>
					null
				</cfif>)
				
				Select Max(OrderID) as NewOrderID
				From Orders
			</cfquery>
			<cfset OrderID=InsertOrder.NewOrderID>
			<cfif Len(ProcessELPDocs)>
				<cfinclude template="ProcessELPDocs.cfm">
			</cfif>
			<cfquery name="updateListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Update Listings
				Set InProgress=0,
				ExpandedListingInProgress = 0,
				InProgressCompanyName=null,
				<cfif getListing.InProgress>
					DateListed=getDate(),
					OrderID=<cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(OrderID)#">
					<cfif getListing.ExpandedListingInProgress and Len(getListing.ExpandedListingFee) and getListing.ExpandedListingFee neq "0">				
					    , ExpandedListingOrderID = <cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(OrderID)#">
					</cfif>
				<cfelse>
					ExpandedListingOrderID = <cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(OrderID)#">
				</cfif>	
				Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>			
			<cfinclude template="SetExpirationDate.cfm">	
			<cfif PaymentAmount gt "0" and (Request.environment is "Live" or Request.environment is "Devel" or Request.environment is "DB")>
				<cfset NewOrderID=OrderID>
				<cfset NewOrderType="OneListing">
				<cfinclude template="EmailNewOrder.cfm">
			</cfif>
		</cfif>					
	<!--- </cftransaction> --->	
	
	<cfinclude template="ListingTitlesUpdater.cfm">
	<cfif getListing.ListingTypeID EQ 15>
		<cfinclude template="ListingEventDays.cfm">	
	</cfif>	
	
	<cfif Len(NewUserID)><!--- Log them in if they just created an account --->
		<cfset session.UserID=NewUserID>
		<cfcookie name="LoggedIn" value="1">
	</cfif>
	
	<cflocation URL="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=4&LinkID=#LinkID#" addToken="No">
	<cfabort>
</cfif>

<cfset ListingFee=getListing.ListingFee>
<cfset ListingTypeID = getListing.ListingTypeID>
<cfset ListingSectionID = getListing.ListingSectionID>

<cfif ListFind("3,4,5,6,7,8,9",getListing.ListingTypeID)>
	<cfquery name="getListingImages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select FileName
		From ListingImages
		Where ListingID=<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
		Order By OrderNum, ListingImageID
	</cfquery>
</cfif>

<script>
	function validateForm(formObj) {
		<cfinclude template="ELPJSValidationIncludes.cfm">
		
		if (formObj.PaymentMethodID && formObj.PaymentMethodID.selectedIndex==2) {
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

	<cfinclude template="ELPJSIncludes.cfm">
	
</script>
<cfif IsDefined('session.UserID') and session.UserID is request.PhoneOnlyUserID>	
	<p class="Important">Phone Only Listings Account in use.</p><br>
</cfif>
<cfif getListing.InProgress>
	<cfif ListFind("1,2,14",getListing.ListingTypeID)>
		<lh:MS_SitePagePart id="bodyThreeELP" class="body">
	<cfelse>
		<lh:MS_SitePagePart id="bodyThree" class="body">
	</cfif>
<cfelse>
	<cfif ListFind("1,2,14",getListing.ListingTypeID)>
		<lh:MS_SitePagePart id="bodyThreeSubmittedELP" class="body">
	<cfelse>
		<lh:MS_SitePagePart id="bodyThreeSubmitted" class="body">
	</cfif>
</cfif>
<p>&nbsp;</p>

<cfoutput>

<cfif Len(StatusMessage)>
	<p><strong><em><span id="StatusMessageSpan">#StatusMessage#</span></em></strong>
</cfif>		
<cfif Len(StatusMessageFileType)>
	<p><strong><em><span id="StatusMessageSpan" style="color: ##bc1232;">#StatusMessageFileType#</span></em></strong>
</cfif>		
<hr>

<!--- <span style="float:left;">	 --->
	<cfset DisplayExpandedListing="0">
	<cfset Preview = "1">
	<cfinclude template="../includes/ListingDetailOutput.cfm">
	
<br clear="all">

<input type="button" value="Edit Listing" class="btn" onClick="location.href='#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=2&LinkID=#LinkID#'">
<hr>
<form name="f1" action="page.cfm?PageID=#Request.AddAListingPageID#" method="post" ENCTYPE="multipart/form-data" ONSUBMIT="return validateForm(this)">
	<input type="hidden" name="LinkID" value="#LinkID#">
	<input type="hidden" name="SaveListing" value="1">
	<input type="hidden" name="Step" value="3">
	<br />
	
	<div id="ExpandedListingDiv" <cfif getListing.ListingTypeID is "15" or getListing.ListingSectionID is "37">style="display:none;"</cfif>>
		
	</div>
	
<cfif getListing.InProgress or getListing.ExpandedListingInProgress>
	<cfif IsDefined('session.UserID') and Len(session.UserID)><!--- Logged in Account holder --->
		<cfif getListing.InProgress><!--- Submitting a listing (with or without an Expanded Listing) --->
			<br />
			<input type="submit" name="button" id="button" value="Add To Cart" class="btn" />	
		<cfelseif getListing.ListingTypeID neq "15" and getListing.ListingSectionID neq "37"><!--- Submitting just an Expanded Listing to go with an already submitted listing --->
			<cfset SubtotalAmount = ExpandedFee>
			<cfinclude template="VATCalc.cfm">
			<cfset PaymentAmount=SubtotalAmount+VAT>
			<cfset ShowSaveForLater="0">
			<cfinclude template="PaymentFields.cfm">	
		</cfif>		
	<cfelse><!--- One-time user, or first-time user submitting a listing that will create an account, or one-time user returning to add an Expanded Listing to an already submitted listing. --->
		<cfset SubtotalAmount=0>
		<cfif Len(getListing.ListingFee) and getListing.InProgress><!--- New listing being submitted --->
			<cfset SubtotalAmount= SubtotalAmount + getListing.ListingFee>
		</cfif>
		<cfif Len(getListing.ExpandedListingFee) and getListing.ExpandedListingInProgress><!--- Expanded Listing being submitted, either along with a new listing or as a later add on to an already submitted listing --->
			<cfset SubtotalAmount= SubtotalAmount + getListing.ExpandedListingFee>
		</cfif>
		<cfinclude template="VATCalc.cfm">
		<cfset PaymentAmount=SubtotalAmount+VAT>
		<cfif not getListing.InProgress>
			<cfset ShowSaveForLater="0">
		</cfif>
		<cfinclude template="PaymentFields.cfm">	
	</cfif>
<cfelseif Len(getListing.ExpirationDate)>
	This listing expires on #DateFormat(getListing.ExpirationDate,'dd/mm/yyyy')#.
	<p>&nbsp;<br>
	
	<cfif not Len(getListing.UserID)>
		<cfquery name="getRenewReminder"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select RenewReminder1, ListingID, 
			DateDiff(d,getDate(),expirationDate) as DaysToExpiration, OrderDate, AccountName, ExpirationDate, LinkID
			From listingsView 
				where active = 1
				AND PaymentStatusID = 2
				AND DateDiff(d,getDate(),expirationDate) <= RenewReminder1
				and RenewReminder1 is not null
				and RenewReminder1 > 0
				and DeletedAfterSubmitted=0
				and InProgress=0
				and ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfquery name="getUnpaidRenewal"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select O.OrderID, O.OrderDate, O.OrderTotal
			From Orders O inner join ListingRenewals LR on O.OrderID=LR.OrderID
			Where LR.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			and O.PaymentStatusID = 1
			Order by OrderID desc
		</cfquery>
		<cfif getRenewReminder.RecordCount>
			<input value="Renew Listing" class="btn" onclick="location.href='page.cfm?pageID=#Request.NonAcctRenewalPageID#&LinkID=#getListing.LinkID#'" type="button">
			<cfif getUnpaidRenewal.RecordCount>
				This listing has a renewal order that is not yet paid.<br />
				Order Date: #DateFormat(getUnpaidRenewal.OrderDate,'dd/mm/yyyy')# #DollarFormat(OrderTotal)#
			</cfif>
		</cfif>
	</cfif>
</cfif>
<cfinclude template="DeleteThisListing.cfm">
<!--- User clicking Delete link in Listing Email --->
<cfif Len(DeleteListing)>
	<script>deleteListing();</script>
</cfif>
					
</form>
</cfoutput>

