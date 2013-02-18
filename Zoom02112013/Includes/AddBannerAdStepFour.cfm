<cfimport prefix="lh" taglib="../Lighthouse/Tags">


<cfparam name="PositionID" default="1">
<cfset allFields="PaymentAmount,PositionID,CategoryIDs,ParentSectionIDs,SaveListing,SaveForLater,SectionIDs,Impressions,StartDisplayingOn,StopDisplayingOn,BannerAdUrl,BannerAdFileName">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="PositionID,Impressions">
<cfif Len(SaveForLater)>
	<cfquery name="updateBannerAd" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		update BannerAds
		set inProgressUserID = <cfqueryparam value="#session.userID#" cfsqltype="CF_SQL_INTEGER">
		where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cflocation URL="/mycart" addToken="No">
	<cfabort>
</cfif>

<cfif Len(PaymentAmount)>	
	
	
	<cfif PaymentAmount neq "0" and PaymentMethodID is "3">
	<!--- Credit card processing and error handling --->
		<cfset PaymentErrorRedirect="page.cfm?PageID=#PageID#&BannerAdID=#BannerAdID#&PaymentAmount=#PaymentAmount#&Step=3">
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
		update BannerAds
		set InProgress = 0,
		Active = 1,
		OrderID = <cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER">
		where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
	<cflocation url="page.cfm?PageID=#Request.AddABannerAdPageID#&BannerAdID=#BannerAdID#&OrderID=#OrderID#&step=5">
	<cfabort>
</cfif>	


<cfquery name="getBannerPricing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	select * from BannerAdPricing
</cfquery>

<cfset InDate=StartDisplayingOn>
<cfinclude template="DateFormatter.cfm">
<cfset LocalStartDate=OutDate>

<cfset InDate=StopDisplayingOn>
<cfinclude template="DateFormatter.cfm">
<cfset LocalEndDate=OutDate>


<cfquery name="getBannerAd" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	update BannerAds set 
	StartDate = <cfqueryparam value="#LocalStartDate#" cfsqltype="CF_SQL_DATE">,
	EndDate = <cfqueryparam value="#LocalEndDate#" cfsqltype="CF_SQL_DATE">,
	BannerAdUrl = <cfqueryparam value="#BannerAdUrl#" cfsqltype="CF_SQL_VARCHAR">
	where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
		
	Select B.*,BPS.ParentSectionID
	From BannerAds B Left Join BannerAdParentSections BPS on B.BannerAdID=BPS.BannerAdID
	Where B.BannerAdID=<cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfquery dbType="query" name="getParentSectionIDs">
	select distinct(ParentSectionID)
	from getBannerAd
</cfquery>




<cfset ParentSectionIDs=ValueList(getParentSectionIDs.ParentSectionID)>

<cfset PositionID = getBannerAd.PositionID>
<cfset LinkID = getBannerAd.LinkID>
<cfset impressions = getBannerAd.Impressions>
<cfset BannerAdImpressions = getBannerAd.Impressions>
<cfset BannerAdStartDate = getBannerAd.StartDate>
<cfset BannerAdEndDate = getBannerAd.EndDate>
<cfset BannerAdFileName = getBannerAd.BannerAdImage>
<cfset BannerAdLinkFileName = getBannerAd.BannerAdLinkFile>
<cfset BannerAdUrl = getBannerAd.BannerAdUrl>
<cfset PaymentAmount = Price>

<cfquery name="updatePrice" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	update BannerAds
	set	Price = <cfqueryparam value="#PaymentAmount#" cfsqltype="CF_SQL_MONEY">
	where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfif Len(BannerAdFile)>
	<cfif FileExists("#Request.BannerAdsUploadedDocsDir#\#BannerAdFileName#")>
		<cffile action="delete" file="#Request.BannerAdsUploadedDocsDir#\#BannerAdFileName#">
	</cfif>
	<cffile action="upload" filefield="BannerAdFile" destination="#Request.BannerAdsUploadedDocsDir#" nameconflict="MakeUnique">	
	
	<!--- Check file extension --->
	<cfif Not ListFindNoCase("gif,jpg,jpeg,png,swf",cffile.ClientFileExt)>
		<cfif FileExists("#cffile.ServerDirectory#\#cffile.ServerFile#")>
       		<cffile action="Delete" file="#cffile.ServerDirectory#\#cffile.ServerFile#">
    	</cfif>
		<cfoutput>The uploaded file has the extension of #cffile.ClientFileExt# which is not allowed.  File extensions that are allowed are: swf, gif, jpg, jpeg and png.</cfoutput>
		<cfabort>
	</cfif>

	<cfset BannerAdFileName = CFFILE.ServerFile>
	<cfquery name="updateBannerAd" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		update BannerAds set BannerAdImage = <cfqueryparam value="#BannerAdFileName#" cfsqltype="CF_SQL_VARCHAR">
		where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
</cfif>

<cfif Len(BannerAdLinkFile)>
	<cfif FileExists("#Request.BannerAdsUploadedDocsDir#\#BannerAdLinkFileName#")>
		<cffile action="delete" file="#Request.BannerAdsUploadedDocsDir#\#BannerAdLinkFileName#">
	</cfif>
	<cffile action="upload" filefield="BannerAdLinkFile" destination="#Request.BannerAdsUploadedDocsDir#" nameconflict="MakeUnique">	
	
	<!--- Check file extension --->
	<cfif Not ListFindNoCase("pdf,doc,xls,html,gif,jpg,jpeg,png",cffile.ClientFileExt)>
		<cfif FileExists("#cffile.ServerDirectory#\#cffile.ServerFile#")>
       		<cffile action="Delete" file="#cffile.ServerDirectory#\#cffile.ServerFile#">
    	</cfif>
		<cfoutput>The uploaded file has the extension of #cffile.ClientFileExt# which is not allowed.  File extensions that are allowed are: pdf, doc, xls, html, gif, jpg, jpeg and png.</cfoutput>
		<cfabort>
	</cfif>

	<cfset BannerAdLinkFileName = CFFILE.ServerFile>
	<cfquery name="updateBannerAd" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		update BannerAds set BannerAdLinkFile = <cfqueryparam value="#BannerAdLinkFileName#" cfsqltype="CF_SQL_VARCHAR">
		where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
</cfif>




<cfquery name="getSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum
	FROM  PageSectionsView PS 
	WHERE PS.ParentSectionID IN (<cfqueryparam value="#ParentSectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)
</cfquery>


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
				<td><b>Position:</b></td>
				<td>Position #PositionID#</td>
			</tr>
			
			<tr>
				<td><b>Date Range:</b></td>
				<td>#DateFormat(BannerAdStartDate,"dd/mm/yyyy")# - #DateFormat(BannerAdEndDate,"dd/mm/yyyy")#</td>
			</tr>
			
			<tr>
				<td><b>URL:</b></td>
				<td>#BannerAdUrl#</td>
			</tr>
			<tr>
				<td valign="top"><b>Placement(s):</b></td>
				<td>
					<b>Sections</b><br>
					<cfloop query="getSections">
						#PSTitle#<br>
					</cfloop>
				</td>
			</tr>
			<tr><td>&nbsp;</td>
			<td><input type="submit" value="Edit Banner Ad Details" class="btn"></td>
			</tr>
		</table>
		
	</td>
	<td valign="top">&nbsp;
		<cfif Right(BannerAdFileName,3) is "swf">
				<cfif not AcRunActiveContentIncluded>
					<cfset AcRunActiveContentIncluded="1">
					<cfhtmlhead text='<script src="#request.HTTPSURL#/Scripts/AC_RunActiveContent.js" type="text/javascript"></script>'>
				</cfif>
				<cfif PositionID is "1">
					<cfset FlashWidth="675">
					<cfset FlashHeight="90">
				<cfelse>
					<cfset FlashWidth="200">
					<cfif PositionID is "2">						
						<cfset FlashHeight="200">
					<cfelse>				
						<cfset FlashHeight="200">
					</cfif>
				</cfif>
				<script language="javascript">
					if (AC_FL_RunContent == 0) {
						alert("This page requires AC_RunActiveContent.js.");
					} else {
						AC_FL_RunContent(
							'codebase', 'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab##version=8,0,0,0',
							'width', '#FlashWidth#',
							'height', '#FlashHeight#',
							'src', 'uploads/BannerAds/#ReplaceNoCase(BannerAdFileName,'.swf','')#',
							'quality', 'high',
							'pluginspage', 'http://www.macromedia.com/go/getflashplayer',
							'align', 'middle',
							'play', 'true',
							'loop', 'true',
							'scale', 'showall',
							'wmode', 'transparent',
							'devicefont', 'false',
							'id', 'bannerAdConfirm',
							'name', 'tangramone',
							'menu', 'true',
							'allowFullScreen', 'false',
							'allowScriptAccess','sameDomain',
							'movie', 'uploads/BannerAds/#ReplaceNoCase(BannerAdFileName,'.swf','')#',
							'salign', ''
							); //end AC code
					}
				</script>
				<noscript>
					<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab##version=8,0,24,0" width="#FlashWidth#" height="#FlashHeight#" id="BannerAdPos2" align="middle">
					<param name="allowScriptAccess" value="sameDomain" />
					<param name="allowFullScreen" value="false" />
					<param name="movie" value="uploads/BannerAds/#BannerAdFileName#" /><param name="quality" value="high" />	<embed src="uploads/BannerAds/#BannerAdFileName#" quality="high" width="#FlashWidth#" height="#FlashHeight#" name="#BannerAdFileName#" align="middle" allowScriptAccess="sameDomain" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
					</object>
				</noscript>
		<cfelse>
			<img src="#request.httpurl#/uploads/bannerAds/#BannerAdFileName#" width="200">
		</cfif>
	</td>
	</tr>
</table>

</form>

<form name="f1" action="page.cfm?PageID=#Request.AddABannerAdPageID#" method="post" ENCTYPE="multipart/form-data" ONSUBMIT="return validateForm(this)">
<input type="hidden" name="step" value="4">
<input type="hidden" name="BannerAdID" value="#BannerAdID#">
<input type="submit" name="SaveForLater" value="Add To Cart" class="btn">
</form>


</cfoutput>
