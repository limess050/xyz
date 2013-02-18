
<cfset allFields="ListingType,Listings,SubTotalAmount,VAT,PaymentAmount,PaymentMethodID,CCNumber,CCExpireMonth,CCExpireYear,CSV,StatusMessage,Checkout">
<cfinclude template="../includes/setVariables.cfm">
<!--- <cfmodule template="../includes/_checkNumbers.cfm" fields="CCNumber,PaymentMethodID,CCExpireMonth,CCExpireYear,CSV"> --->

<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfinclude template="../includes/PreLaunch.cfm">

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
<script language="JavaScript" src="/DAR/web//Lighthouse/Resources/js/library.js" type="text/javascript"></script>
<cfinclude template="../includes/MyListings.cfm">
<cfinclude template="../includes/ListingPackagesHAndRQueries.cfm">
<cfinclude template="../includes/ListingPackagesVQueries.cfm">
<cfinclude template="../includes/ListingPackagesJRQueries.cfm">
<!--- Check to make sure that 
	The ListingType is present and valid
	the Listings value is valid (5,10,20 or unlimited)
	The user is permitted to buy this listing type
	The user has no open packages --->
<cfset showForm="1">

<cfif not ListFind("H,V,JR",ListingType)>
	<cfset StatusMessage="Listing Type not valid.">
	<cfset showForm="0">

<cfelseif not ListFindNoCase("5,10,20,Unlimited",Listings)>
	<cfset StatusMessage="Listing count not valid.">
	<cfset showForm="0">

<cfelseif ListingType is "H" and not AllowHAndR>
	<cfset StatusMessage="You are not eligible to buy Housing and Rental Listing Packages.">
	<cfset showForm="0">

<cfelseif ListingType is "H" and HasOpenHAndRPackages>
	<cfset StatusMessage="You currently have an unused Housing and Rental Listing Package.">
	<cfset showForm="0">

<cfelseif ListingType is "V" and not AllowVehicle>
	<cfset StatusMessage="You are not eligible to buy Vehicle Listing Packages.">
	<cfset showForm="0">

<cfelseif ListingType is "V" and HasOpenVPackages>
	<cfset StatusMessage="You currently have an unused Vehicle Listing Package.">
	<cfset showForm="0">

<cfelseif ListingType is "JR" and not AllowJobRecruiter>
	<cfset StatusMessage="You are not eligible to buy Job Recruitment Listing Packages.">
	<cfset showForm="0">

<cfelseif ListingType is "JR" and HasOpenJRPackages>
	<cfset StatusMessage="You currently have an unused Job Recruitment Listing Package.">
	<cfset showForm="0">
</cfif>

<div class="centercol-inner-wide legacy legacy-wide">
<h1>Buy A Listing Package</h1>
<cfif Len(StatusMessage)>
	<p><strong><em><cfoutput>#StatusMessage#</cfoutput></em></strong>
</cfif>		
<lh:MS_SitePagePart id="body" class="body">


<cfif showForm>	
	<cfif Len(CheckOut)>	
		<cftransaction>				
			<cfset OrderID="">
			<cfif PaymentAmount neq '' and PaymentAmount neq "0" and PaymentMethodID is "3">
			<!--- Credit card processing and error handling --->
				<cfset PaymentErrorRedirect="#lh_getPageLink(pageID,'buyalistingpackage')##AmpOrQuestion#ListingType=#ListingType#&Listings=#Listings#">
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
			<cfquery name="insertListingPackage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Insert into ListingPackages
				(ListingPackageTypeID, FiveListing, TenListing, TwentyListing, UnlimitedListing, OrderID, ExpirationDate)
				VALUES
				(<cfif ListingType is "H">1<cfelseif ListingType is "V">2<cfelse>3</cfif>,
				<cfif Listings is "5">1<cfelse>0</cfif>,
				<cfif Listings is "10">1<cfelse>0</cfif>,
				<cfif Listings is "20">1<cfelse>0</cfif>,
				<cfif Listings is "Unlimited">1<cfelse>0</cfif>,
				<cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER"null="#NOT LEN(OrderID)#">,
				<cfif PaymentMethodID is "3" or PaymentAmount is '' or PaymentAmount is "0">
					<cfif PreLaunch>
						<cfqueryparam value="04/01/2010" cfsqltype="CF_SQL_DATE">
					<cfelse>
						DateAdd(day, 365, GetDate())
					</cfif>
				<cfelse>
					null
				</cfif>)
			</cfquery>
		</cftransaction>
	
		<cfif PaymentAmount gt "0" and (Request.environment is "Live" or Request.environment is "Devel" or Request.environment is "DB")>
			<cfset NewOrderID=OrderID>
			<cfset NewOrderType="ListingPackage">
			<cfinclude template="../includes/EmailNewOrder.cfm">
		</cfif>
		
		<cflocation URL="#lh_getPageLink(7,'myaccount')##AmpOrQuestion#StatusMessage=Order submitted." addToken="No">
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
	
	
	
	<!--- <cfoutput>#Request.Page.GetCookieCrumb()#</cfoutput><br>
	<cfoutput>#Request.Page.GetSectionName()#</cfoutput> --->
	
	<!--- <lh:MS_SitePagePart id="title" class="title">
	<lh:MS_SitePagePart id="body" class="body">
	
	 --->
	
	
	

	<cfoutput>
		<form name="f1" action="page.cfm?PageID=#PageID#" method="post" ONSUBMIT="return validateForm(this)">
			<input type="hidden" name="Checkout" value="1">
			<input type="hidden" name="ListingType" value="#ListingType#">
			<input type="hidden" name="Listings" value="#Listings#">		
		<br /><hr />
		<cfswitch expression="#ListingType#">
			<cfcase value="H">				
				<cfswitch expression="#Listings#">
					<cfcase value="5">
						<cfset SubtotalAmount=getHAndRListingPackageFees.FivePerYearFee>
					</cfcase>
					<cfcase value="10">
						<cfset SubtotalAmount=getHAndRListingPackageFees.TenPerYearFee>
					</cfcase>
					<cfcase value="20">
						<cfset SubtotalAmount=getHAndRListingPackageFees.TwentyPerYearFee>
					</cfcase>
					<cfcase value="Unlimited">
						<cfset SubtotalAmount=getHAndRListingPackageFees.UnlimitedPerYearFee>
					</cfcase>
				</cfswitch>
				Housing and Rental Listing Package: #Listings# for #DollarFormat(PaymentAmount)#
			</cfcase>
			<cfcase value="V">
				<cfswitch expression="#Listings#">
					<cfcase value="5">
						<cfset SubtotalAmount=getVListingPackageFees.FivePerYearFee>
					</cfcase>
					<cfcase value="10">
						<cfset SubtotalAmount=getVListingPackageFees.TenPerYearFee>
					</cfcase>
					<cfcase value="20">
						<cfset SubtotalAmount=getVListingPackageFees.TwentyPerYearFee>
					</cfcase>
					<cfcase value="Unlimited">
						<cfset SubtotalAmount=getVListingPackageFees.UnlimitedPerYearFee>
					</cfcase>
				</cfswitch>
				Vehicle Listing Package: #Listings# for #DollarFormat(PaymentAmount)#
			</cfcase>
			<cfcase value="JR">
				<cfswitch expression="#Listings#">
					<cfcase value="5">
						<cfset SubtotalAmount=getJRListingPackageFees.FivePerYearFee>
					</cfcase>
					<cfcase value="10">
						<cfset SubtotalAmount=getJRListingPackageFees.TenPerYearFee>
					</cfcase>
					<cfcase value="20">
						<cfset SubtotalAmount=getJRListingPackageFees.TwentyPerYearFee>
					</cfcase>
					<cfcase value="Unlimited">
						<cfset SubtotalAmount=getJRListingPackageFees.UnlimitedPerYearFee>
					</cfcase>
				</cfswitch>
				Job Recruitment Listing Package: #Listings# for #DollarFormat(PaymentAmount)#
			</cfcase>
		</cfswitch>
		
		<cfinclude template="../includes/VATCalc.cfm">
		
		<cfset PaymentAmount=SubtotalAmount+VAT>
		
		<cfset ShowSaveForLater="0">
		<cfset ShowListingPackageText="1">
		<cfinclude template="../includes/PaymentFields.cfm">
		 
		  <!-- END CENTER COL -->
		
		<!-- RIGHT COL -->
		</form>
	</cfoutput>
</cfif>
</div>

<!-- END CENTER COL -->

<cfset ShowRightColumn="0">
<cfinclude template="footer.cfm">