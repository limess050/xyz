<cfimport prefix="lh" taglib="../Lighthouse/Tags">


<cfparam name="PositionID" default="1">
<cfset allFields="BannerAdPlacement,PaymentAmount,PositionID,CategoryIDs,ParentSectionIDs,SaveListing,SaveForLater,SectionIDs,Impressions,StartDisplayingOn,StopDisplayingOn,BannerAdUrl,BannerAdFileName">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="BannerAdPlacement,PositionID,Impressions">

<cfif Len(PaymentAmount)>	
	
	
	<cfif PaymentAmount neq "0" and PaymentMethodID is "3">
	<!--- Credit card processing and error handling --->
		<cfset PaymentErrorRedirect="page.cfm?PageID=#PageID#&BannerAdID=#BannerAdID#&PaymentAmount=#PaymentAmount#&Step=7">
		<cfinclude template="PaymentProcessing.cfm">				
	</cfif>	
	
	<cfquery name="insertOrder" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Insert into Orders
		(OrderTotal, PaymentAmount, OrderDate, DueDate, PaymentMethodID, PaymentStatusID, PaymentDate, BillingFirstName, BillingLastName, CCTypeID, CCLastFourDigits, CCExpireMonth, CCExpireYear, CCTransactionID, CSV, UserID)
		VALUES
		(<cfqueryparam value="#PaymentAmount#" cfsqltype="CF_SQL_MONEY">,
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
		<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
		)
		Select Max(OrderID) as NewOrderID
		From Orders
	</cfquery>
	<cfset orderID = insertOrder.newOrderID>
	<cfquery name="updateBannerAd" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		insert into BannerAdAdditionalImpressions(orderID,BannerAdID,impressions,price)
		values(
		<cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER">,
		<cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">,
		<cfqueryparam value="#impressions#" cfsqltype="CF_SQL_INTEGER">,
		<cfqueryparam value="#paymentAmount#" cfsqltype="CF_SQL_MONEY">
		)
		
		update BannerAds
		set impressions = impressions + <cfqueryparam value="#impressions#" cfsqltype="CF_SQL_INTEGER">
		where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
	<cflocation url="page.cfm?PageID=#Request.AddABannerAdPageID#&BannerAdID=#BannerAdID#&OrderID=#OrderID#&step=5">
	<cfabort>
</cfif>	


<cfquery name="getBannerPricing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	select * from BannerAdPricing
</cfquery>




<cfquery name="getBannerAd" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		
	Select B.*,BPS.ParentSectionID,BS.SectionID,BC.CategoryID,BP.Placement
	From BannerAds B Left Join BannerAdParentSections BPS on B.BannerAdID=BPS.BannerAdID
	inner join BannerAdPlacement BP ON BP.PlacementID = B.PlacementID
	Left Join BannerAdCategories BC on B.BannerAdID=BC.BannerAdID
	Left Outer Join BannerAdSections BS on B.BannerAdID=BS.BannerAdID 
	Where B.BannerAdID=<cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfquery dbType="query" name="getParentSectionIDs">
	select distinct(ParentSectionID)
	from getBannerAd
</cfquery>
<cfquery dbType="query" name="getSectionIDs">
	select distinct(SectionID)
	from getBannerAd
</cfquery>




<cfset ParentSectionIDs=ValueList(getParentSectionIDs.ParentSectionID)>
<cfset SectionIDs=ValueList(getSectionIDs.SectionID)>
<cfset CategoryIDs=ValueList(getBannerAd.CategoryID)>

<cfset BannerAdPlacement = getBannerAd.PlacementID>
<cfset Placement = getBannerAd.Placement>
<cfset PositionID = getBannerAd.PositionID>
<cfset LinkID = getBannerAd.LinkID>
<cfset BannerAdImpressions = getBannerAd.Impressions>
<cfset BannerAdStartDate = getBannerAd.StartDate>
<cfset BannerAdEndDate = getBannerAd.EndDate>
<cfset BannerAdFileName = getBannerAd.BannerAdImage>
<cfset BannerAdUrl = getBannerAd.BannerAdUrl>


<cfinclude template="../includes/BannerAdPricing.cfm">
<!---
<cfif impressions LT 11000>
	<cfset paymentAmount = PriceLT10K*(impressions/1000)>
<cfelseif impressions GTE 11000 AND impressions LT 50000>
	<cfset paymentAmount = Price1150K*(impressions/1000)>
<cfelse>
	<cfset paymentAmount = PriceGT50K*(impressions/1000)>		
</cfif>
--->
<cfset paymentamount = price>









<cfif BannerAdPlacement EQ 5>
	<cfquery name="getCategoryTree" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum,
		S.SectionID, S.Title as STitle, S.OrderNum as SOrderNum,
		C.CategoryID, C.Title as CTitle, C.OrderNum as COrderNum
		FROM Categories C
		Inner Join Sections S on C.SectionID=S.SectionID
		Inner Join ParentSectionsView PS on S.ParentSectionID=PS.ParentSectionID
		WHERE C.CategoryID IN (<cfqueryparam value="#CategoryIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)
	</cfquery>
	
<cfelseif BannerAdPlacement EQ 3>
	<cfquery name="getSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum
		FROM  ParentSectionsView PS 
		WHERE PS.ParentSectionID IN (<cfqueryparam value="#ParentSectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)
	</cfquery>
<cfelseif BannerAdPlacement EQ 4>
	<cfquery name="getSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT S.SectionID, S.Title as STitle, S.OrderNum as SOrderNum
		FROM  Sections S 
		WHERE S.SectionID IN (<cfqueryparam value="#SectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)
	</cfquery>		

</cfif>

<script>
	function validateForm(formObj) {
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
</script>	

<cfoutput>
Review the details of your banner ad below and complete the payment information at the bottom.
<hr>
<form action="page.cfm?PageID=#Request.AddABannerAdPageID#" method="post">
<input type="hidden" name="LinkID" value="#LinkID#">

<table>
	<tr>
	<td valign="top">
		<table cellspacing="5" cellpadding="5">
			
			<tr>
				<td><b>Impressions:</b></td>
				<td>#impressions# Additional Impressions</td>
			</tr>
			<tr>
				<td valign="top"><b>Placement(s):</b></td>
				<td>
					<cfif BannerAdPlacement EQ 5>
						<b>Categories</b><br>
						<cfloop query="getCategoryTree">
							#CTitle#<br>
						</cfloop>
					</cfif>
					<cfif BannerAdPlacement EQ 3>
						<b>Sections</b><br>
						<cfloop query="getSections">
							#PSTitle#<br>
						</cfloop>
					</cfif>
					<cfif BannerAdPlacement EQ 4>
						<b>Sub-Sections</b><br>
						<cfloop query="getSections">
							#STitle#<br>
						</cfloop>
					</cfif>
					<cfif BannerAdPlacement EQ 1>
						<b>Homepage</b><br>
						
					</cfif>
					<cfif BannerAdPlacement EQ 2>
						<b>Sitewide</b><br>
						
					</cfif>
					<cfif BannerAdPlacement EQ 6>
						<b>Admin Pages</b><br>
						
					</cfif>
				</td>
			</tr>
			
		</table>
		
	</td>
	<td valign="top">
		<img src="#request.httpurl#/uploads/bannerAds/#BannerAdFileName#" width="200">
	</td>
	</tr>
</table>

</form>

<cfset subtotalamount = paymentamount>
<cfset vat = 0>
<form name="f1" action="page.cfm?PageID=#Request.AddABannerAdPageID#" method="post" ENCTYPE="multipart/form-data" ONSUBMIT="return validateForm(this)">
<input type="hidden" name="SaveBannerAd" value="1">
<input type="hidden" name="BannerAdID" value="#BannerAdID#">
<input type="hidden" name="impressions" value="#impressions#">
<cfset showTopText = 0>
<cfset showSaveForLater = 0>
<cfinclude template="PaymentFields.cfm">	



	
	
				
<input type="hidden" name="Step" value="7">
	
	
	
</form>
</cfoutput>
