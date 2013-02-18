<!---
Global header include for templates
--->
<cfparam name="Preview" default="0">
<cfparam name="AcRunActiveContentIncluded" default="0">
<cfparam name="ShowRightColumn" default="1">
<cfparam name="ShowHintsAndRelLinks" default="1">
<cfparam name="ImpressionSectionID" default="0">

<cfset NowinDAR=DateAdd('h',7,Now())>

<!--- If logged in as AdminUser, log them out. --->
<cfif IsDefined('session.UserID') and Len(session.UserID)>
	<cfquery name="checkAdmin" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select AdminUser
		From LH_Users
		Where UserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif not Edit and Not Preview and (not checkAdmin.RecordCount or checkAdmin.AdminUser)>
		<cfset msg = "You have been logged out.">
		<cfset lh_setClientInfo("userID","")>
		<cfset lh_setClientInfo("remote_addr","")>
		<cfset StructDelete(session,"UserID")>
		<cfset StructDelete(session,"User")>
		<cfif cgi.https is "on">
			<cflocation url="#Request.HttpsURL#/" addToken="No">
		<cfelse>
			<cflocation url="#Request.HttpURL#/" addToken="No">
		</cfif>
		
		<cfabort>
	</cfif>
</cfif>

<cfparam name="ShowEmptyCategories" default="1">

<cfquery name="Sections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select PS.ParentSectionID, PS.Title, PS.Descr, PS.URLSafeTitleDashed as ParentSectionURLSafeTitle
	From ParentSectionsView PS With (NoLock)
	<cfif not ShowEmptyCategories>
		Inner Join Sections S With (NoLock) on PS.ParentSectionID=S.ParentSectionID
		Inner Join Categories C With (NoLock) on S.SectionID=C.SectionID
		Inner Join ListingCategories LC With (NoLock) on C.CategoryID=LC.CategoryID
		Inner Join ListingsView L With (NoLock) on LC.ListingID=L.ListingID and L.Active=1 and L.Reviewed=1 and L.ExpirationDate >= #Now()#
	</cfif>
	Where PS.Active=1
	Order by PS.OrderNum
</cfquery>

<cfif cgi.https is "on">
	<cfset FullHTTPURL=Request.HTTPSURL>
<cfelse>
	<cfset FullHTTPURL=Request.HTTPURL>
</cfif>

<cfif PageID is Request.JobSeekersGuidePageID>
	<cfset ParentSectionID="8">
</cfif>

<cfif isDefined("listingID")>
	<cfif Len(ListingID)>
		<cfquery name="getListingCategoryID"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			select categoryID from listingCategories With (NoLock)
			where listingID = <cfqueryparam value="#ListGetAt(ListingID,1)#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfif getListingCategoryID.recordcount>
			<cfset categoryID = getListingCategoryID.categoryID>
		</cfif>	
	</cfif>
</cfif>

<cfif isDefined("name")>
	<cfif name EQ "searchevents">
		<cfset parentSectionID = 59>
	</cfif>	
</cfif>

<cfsavecontent variable="DARHeaderAdditions">
<cfoutput>
<!--  jQuery library //-->
<script type="text/javascript" src="js/jquery-1.5.1.min.js"></script>
<!--  jQuery UI script -->
<script type="text/javascript" src="js/jquery-ui-1.8.12.custom.min.js"></script>
<cfif PageID is "1">
	<!--  jCarousel library -->
	<script type="text/javascript" src="js/jquery.jcarousel.min.js"></script>
	<!--  jCarousel skin stylesheet -->
	<link rel="stylesheet" type="text/css" href="skin.css" />
	<!--  jCarousel carousel script -->
	<script type="text/javascript" src="js/carousel.js" language="javascript"></script>
<cfelse>
	<meta http-equiv="X-UA-Compatible" content="IE=7" />
</cfif>
<link type="text/css" href="css/smoothness/jquery-ui-1.8.12.custom.css" rel="stylesheet" />
<!-- JRoll script -->
<script type="text/javascript" src="js/roll.js" language="javascript"></script>
<script type="text/javascript" src="Lighthouse/Resources/js/lighthouse_all.js"></script>
<cfif PageID is "1">
	<!--  Share This script -->
	<script type="text/javascript">var switchTo5x=true;</script>
	<script type="text/javascript" src="http://w.sharethis.com/button/buttons.js"></script>
	<script type="text/javascript">
		stLight.options({
			publisher:'7cfc1015-cebd-4b1b-ba2f-d33bd9574abf',
			onhover: false
		});
	</script>
</cfif>
<script>		
	function checkListingID(formObj) {
		if (!checkText(formObj.elements["searchString"],"Listing ID")) return false;	
		if (!checkNumber(formObj.elements["searchString"],"Listing ID")) return false;	
		return true;
	}
</script>
<!--[if IE 6]>
<link rel="stylesheet" type="text/css" media="all" href="ie6.css" />
<![endif]--> 
 </cfoutput>
</cfsavecontent>
<cfhtmlhead text="#DARHeaderAdditions#">
<cfoutput>
<div class="wrapper">
	<cfif PageID is "1">
	<!-- ABOUT US AND SOCIAL MEDIA -->
	<div class="promo-aboutzoom">
		<h1>Welcome to ZoomTanzania, where locals go to find the most accurate and up-to-date information in Tanzania. From business and tourism directories to classified ads and entertainment information - find what you need fast.</h1>
	  <div class="sharethis"><span  class='st_facebook_large sharethistxt'  ></span><span  class='st_twitter_large sharethistxt' ></span><span  class='st_email_large sharethistxt' ></span><span  class='st_blogger_large sharethistxt' ></span><span  class='st_gbuzz_large sharethistxt' ></span></div>
		<br clear="all" />
		<div class="sharethistxt">Facebook</div>
		<div class="sharethistxt">Twitter</div>
		<div class="sharethistxt">Email</div>
		<div class="sharethistxt">Blog</div>
		<div class="sharethistxt">Buzz</div>
	</div>
	</cfif>
	
	<div class="masthead">
		<div class="myaccount"><a href="myaccount" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-myaccount','','#FullHTTPURL#/images/sitewide/btn.myaccount_on.gif',1)"><img src="#FullHTTPURL#/images/sitewide/btn.myaccount_off.gif" alt="My Account" name="btn-myaccount" width="114" height="25" border="0" id="btn-myaccount" /></a></div>
		<div class="loggedIn">&nbsp;&nbsp;<noscript><div style="color:red">This site requires javaScript to function correctly. Please use your browser's options to enable javaScript.</div></noscript>
		<span id="UserWelcome"><cfif IsDefined('session.UserID') and Len(session.UserID) and IsDefined('session.UserName')>Welcome, #session.UserName#<br>&nbsp;&nbsp;&nbsp;&nbsp;<a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/?Logout=Y">(log out)</a>&nbsp;&nbsp;&nbsp;</cfif></span></div>
		<div class="search searchByID">
			<form action="#lh_getPageLink(53,'sitesearch')#" method="get" onSubmit="return checkListingID(this);">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Search by Listing ID##&nbsp;&nbsp;<input name="searchString" type="text" value="Listing ID" class="searchByIDfield" maxlength="7"  onFocus="if (this.value=='Listing ID') {this.value=''};"/>
				<input type="hidden" name="SearchByID" value="1">
				<input name="go" id="btn-go" type="image" value="Go" src="#FullHTTPURL#/images/sitewide/btn.go_off.gif" alt="Search" align="absmiddle" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-go','','images/sitewide/btn.go_on.gif',1)" />
			</form>
		</div>
		<div class="search searchByName">
			<form action="#lh_getPageLink(53,'sitesearch')#" method="get">
				<span id="SearchByNameField" style="float: right;">
				<input name="searchString" type="text" value="Search ZoomTanzania.com" class="searchfield" maxlength="50"  onFocus="if (this.value=='Search ZoomTanzania.com') {this.value=''};"/>
				<input name="go" id="btn-go" type="image" value="Go" src="#FullHTTPURL#/images/sitewide/btn.go_off.gif" alt="Search" align="absmiddle" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-go','','images/sitewide/btn.go_on.gif',1)" />
				</span>
				<span id="searchByNameText" style="float: right;">
				Search by Business Name or Type of Business&nbsp;&nbsp;<br>
				Ex: Auto Emporium OR Car Dealers
				</span>
			</form>
		</div>
		<div class="clear"></div>
	</div>
	
	<!-- LOGO AND AD ROW -->
	<div class="logoandad">
		<div id="logo" class="float-left"><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/"><img src="#FullHTTPURL#/images/sitewide/logoZoom.gif" width="344" height="126" alt="ZoomTanzania. Find What You Need - Fast!" /></a></div>
		<div id="ad" class="float-right">
		<cfinclude template="../includes/AdTechBannerAds.cfm">		
		</div>
		<div class="clear"></div>
	</div>
	</cfoutput>
<!-- CONTENT -->
<div class="hp-wrapper">
		<div class="leftcol">
			<!-- LEFT NAV -->
			<div class="leftnav">
				<ul>
					<cfif PageID neq "1">
						<cfoutput><li><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/">Home Page</a></li></cfoutput>
					</cfif>
					<cfoutput query="Sections">
						<cfif PageID neq "1" or not ListFind("4,5,8,55,59",ParentSectionID)>
							<cfif Request.lh_useFriendlyUrls>
								<li><a href="#ParentSectionURLSafeTitle#">
							<cfelse>
								<li><a href="#lh_getPageLink(Request.SectionOverviewPageID,'sectionoverview')##AmpOrQuestion#ParentSectionID=#ParentSectionID#">
							</cfif>
							#Title#</a></li>
						</cfif>
					</cfoutput>
				</ul>
			</div>
			<!--- <cfif IsDefined('ListingID') and Len(ListingID) and ShowHintsAndRelLinks>
				<cfmodule template="../includes/RelevantLinks.cfm" CategoryID="#getListing.CategoryID#" SectionID="#getListing.SectionID#" ParentSectionID="#getListing.ParentSectionID#">
			<cfelseif IsDefined('CategoryID') and Len(CategoryID) and IsDefined('getCategory.ParentSectionID') and Len(getCategory.ParentSectionID)>
				<cfmodule template="../includes/RelevantLinks.cfm" CategoryID="#CategoryID#" SectionID="#getCategory.SectionID#" ParentSectionID="#getCategory.ParentSectionID#">
			<cfelseif IsDefined('ParentSectionID') and Len(ParentSectionID)>
				<cfmodule template="../includes/RelevantLinks.cfm" CategoryID="" SectionID="" ParentSectionID="#ParentSectionID#">
			</cfif> --->
			
			<!-- POST A LISTING -->
			<div class="clear15"></div>
			<div><a href="how-to-post-a-listing" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-howtopostalisting','','images/sitewide/btn.postalisting_on.gif',1)"><img src="images/sitewide/btn.postalisting_off.gif" alt="How to Post a Listing?" name="btn-howtopostalisting" width="211" height="28" border="0" id="btn-howtopostalisting" /></a></div>
			<!-- EXCHANGE RATES -->
			<div class="clear15"></div>
			<div class="promo-tideandlunartitle">
				<div class="float-left"><img src="images/sitewide/icon.exchangerates.gif" alt="Exchange Rates" width="28" height="39" align="left" /></div>
				<div class="float-left promo-tideandlunartitletext"><strong>EXCHANGE RATES:</strong><br />
					<cfoutput><em>#DateFormat(NowInDAR,'ddd., mmm dd, yyyy')#</em></div></cfoutput>
				<div class="clear"></div>
			</div>
			<cfinclude template="../includes/ExchangeRates2.cfm">	
			<!-- TIDE AND LUNAR -->
			<div class="clear15"></div>
			<cfinclude template="../includes/TidesLunar2.cfm">		
		</div>
