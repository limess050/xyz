<!---
Global header include for templates
--->
<cfparam name="Preview" default="0">
<cfparam name="AcRunActiveContentIncluded" default="0">
<cfparam name="ShowRightColumn" default="1">
<cfparam name="ShowHintsAndRelLinks" default="1">

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
			<cflocation url="#Request.HttpsURL#/">
		<cfelse>
			<cflocation url="#Request.HttpURL#/">
		</cfif>
		
		<cfabort>
	</cfif>
</cfif>

<cfparam name="ShowEmptyCategories" default="1">

<cfquery name="Sections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select PS.ParentSectionID, PS.Title, PS.Descr, PS.URLSafeTitleDashed as ParentSectionURLSafeTitle
	From ParentSectionsView PS
	<cfif not ShowEmptyCategories>
		Inner Join Sections S on PS.ParentSectionID=S.ParentSectionID
		Inner Join Categories C on S.SectionID=C.SectionID
		Inner Join ListingCategories LC on C.CategoryID=LC.CategoryID
		Inner Join ListingsView L on LC.ListingID=L.ListingID and L.Active=1 and L.Reviewed=1 and L.ExpirationDate >= #Now()#
	</cfif>
	Where PS.Active=1
	Order by PS.OrderNum
</cfquery>

<cfif cgi.https is "on">
	<cfset FullHTTPURL=Request.HTTPSURL>
<cfelse>
	<cfset FullHTTPURL=Request.HTTPURL>
</cfif>

<cfset adminAd = false>
<cfif FindNoCase("postalisting",query_string) OR FindNoCase("postabannerad",query_string) OR FindNoCase("mycart",query_string) OR FindNoCase("myaccount",query_string) OR ListFindNoCase("page.cfm",script_name) OR FindNoCase("aboutus",query_string) OR FindNoCase("contactus",query_string) OR FindNoCase("ratecard",query_string) OR FindNoCase("sitemap",query_string) OR FindNoCase("privacypolicy",query_string) OR FindNoCase("termsofuse",query_string)>
	<cfset adminAd = true>
</cfif>	

<cfif isDefined("pageID") AND ListFind("5,7,8,9,10,11,14,21,23,28",pageID)>
	<cfset adminAd = true>
</cfif>

<cfif PageID is Request.JobSeekersGuidePageID>
	<cfset ParentSectionID="8">
</cfif>

<cfif isDefined("listingID") and not adminAd>
	<cfif Len(ListingID)>
		<cfquery name="getListingCategoryID"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			select categoryID from listingCategories
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

<cfquery name="getBannerAdPos1"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	select BA.BannerAdID, BA.BannerAdUrl, BA.BannerAdImage, BA.BannerAdLinkFile, 'Banner' AS Type, 0 AS BannerAdED
	from BannerAds BA inner join
	Orders O on o.orderID = BA.OrderID
	Where BA.InProgress = 0 AND BA.PositionID = 1 AND BA.Active = 1
	AND BA.StartDate <= <cfqueryparam value="#DateFormat(Now(),'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE">
	AND BA.EndDate >= <cfqueryparam value="#DateFormat(Now(),'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE">
	AND BA.PlacementID 
	<cfif adminAd>
		=
	<cfelse>
		<> 
	</cfif>
	6
	AND O.PaymentStatusID = 2
	<cfif isDefined("categoryID") AND not adminAd>
		AND (BA.PlacementID = 2 
			OR BA.BannerADID in (select BannerADID from BannerADCategories where categoryID = <cfqueryparam value="#categoryID#" cfsqltype="CF_SQL_INTEGER">) 
			OR BA.BannerAdID in (select BannerAdID from BannerADSections where sectionID = (select sectionID from categories where categoryID = <cfqueryparam value="#categoryID#" cfsqltype="CF_SQL_INTEGER">))
			OR BA.BannerAdID in (select BannerAdID from BannerADParentSections where parentsectionID = (select parentsectionID from categories where categoryID = <cfqueryparam value="#categoryID#" cfsqltype="CF_SQL_INTEGER">))
			)
	</cfif>
	<cfif isDefined("ParentSectionID")>
		<cfif Len(ParentSectionID) AND not adminAd>
			AND (BA.PlacementID = 2 
				
				OR BA.BannerAdID in (select BannerAdID from BannerADParentSections where parentsectionID = <cfqueryparam value="#parentsectionID#" cfsqltype="CF_SQL_INTEGER">)
				)
		</cfif>
	</cfif>
	<cfif FindNoCase("index.cfm",cgi.SCRIPT_NAME)>
		AND BA.PlacementID = 1
	<cfelse>
		AND BA.PlacementID <> 1	
	</cfif>
	<cfif not isDefined("categoryID") AND not isDefined("parentSectionID") AND not adminAd AND not FindNoCase("index.cfm",cgi.SCRIPT_NAME)>
		AND BA.PlacementID = 2
	</cfif>
	
</cfquery>

<cfif getBannerAdPos1.recordcount EQ 0>
	<cfquery name="getBannerAdPos1"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		select HouseBannerAdID as BannerAdID, BannerAdUrl, BannerAdImage,'' as BannerAdLinkFile, 'House' AS Type, BannerAdED
		from HouseBannerAds
		where positionID = 1
		AND active = 1
	</cfquery>
</cfif>	

<cfset ED = false>

<cfset BannerAdElement = RandRange(1,getBannerAdPos1.recordcount)>
<cfset BannerAdID1 = getBannerAdPos1.BannerAdID[BannerAdElement]>
<cfset BannerAdUrl1 = getBannerAdPos1.BannerAdUrl[BannerAdElement]>
<cfset BannerAdLinkFile1 = getBannerAdPos1.BannerAdLinkFile[BannerAdElement]>
<cfset BannerAdImage = getBannerAdPos1.BannerAdImage[BannerAdElement]>
<cfset BannerAdType = getBannerAdPos1.Type[BannerAdElement]>
<cfset BannerAdType1 = BannerAdType>
<cfset BannerAdImage1 = BannerAdImage>
<cfif getBannerAdPos1.BannerAdED EQ 1>
	<cfset ED = true>
</cfif>

<cfif getBannerAdPos1.recordcount>
	<cfquery name="insImpressions"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		insert into impressions(<cfif BannerAdType EQ "Banner">BannerADID<cfelse>HouseBannerAdID</cfif>)
		values(<cfqueryparam value="#BannerAdID1#" cfsqltype="CF_SQL_INTEGER">)
		
		<cfif BannerAdType EQ "Banner">
			Update BannerAds 
			Set Impressions = Impressions + 1
			Where BannerAdID=<cfqueryparam value="#BannerAdID1#" cfsqltype="CF_SQL_INTEGER">
		</cfif>
	</cfquery>
</cfif>

<cfsavecontent variable="DARHeaderAdditions">
<cfoutput>
<!--  jQuery library //-->
<script type="text/javascript" src="js/jquery-1.5.1.min.js"></script>
<!--  jQuery UI script -->
<script type="text/javascript" src="js/jquery-ui-1.8.12.custom.min.js"></script>
<!--- <cfif PageID is "1"> --->
	<!--  jCarousel library -->
	<script type="text/javascript" src="js/jquery.jcarousel.min.js"></script>
	<!--  jCarousel skin stylesheet -->
	<link rel="stylesheet" type="text/css" href="skin.css" />
	<!--  jCarousel carousel script -->
	<script type="text/javascript" src="js/carousel.js" language="javascript"></script>
<!--- <cfelse>
	<meta http-equiv="X-UA-Compatible" content="IE=7" />
</cfif> --->
<link type="text/css" href="css/smoothness/jquery-ui-1.8.12.custom.css" rel="stylesheet" />
<!-- JRoll script -->
<script type="text/javascript" src="js/roll.js" language="javascript"></script>
<!--- <cfif PageID is "1"> --->
	<!--  Share This script -->
	<script type="text/javascript">var switchTo5x=true;</script>
	<script type="text/javascript" src="http://w.sharethis.com/button/buttons.js"></script>
	<script type="text/javascript">
		stLight.options({
			publisher:'7cfc1015-cebd-4b1b-ba2f-d33bd9574abf',
			onhover: false
		});
	</script>
<!--- </cfif> --->
<!--[if IE 6]>
<link rel="stylesheet" type="text/css" media="all" href="ie6.css" />
<![endif]-->

 </cfoutput>
</cfsavecontent>
<cfhtmlhead text="#DARHeaderAdditions#">
<cfoutput>
<div class="wrapper">
	<!--- <cfif PageID is "1"> --->
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
	<!--- </cfif> --->
	
	<div class="masthead">
		<div class="myaccount"><a href="myaccount" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-myaccount','','#FullHTTPURL#/images/sitewide/btn.myaccount_on.gif',1)"><img src="#FullHTTPURL#/images/sitewide/btn.myaccount_off.gif" alt="My Account" name="btn-myaccount" width="114" height="25" border="0" id="btn-myaccount" /></a></div>
		<div class="loggedIn">&nbsp;&nbsp;<noscript><div style="color:red">This site requires javaScript to function correctly. Please use your browser's options to enable javaScript.</div></noscript><cfif IsDefined('session.UserID') and Len(session.UserID) and IsDefined('session.UserName')>Welcome, #session.UserName#&nbsp;&nbsp;&nbsp;<a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/?Logout=Y">(log out)</a>&nbsp;&nbsp;&nbsp;</cfif></div>
		<div class="search">
			<form action="#lh_getPageLink(4,'search')#" method="get">
				<input name="searchString" type="text" value="Search ZoomTanzania.com" class="searchfield" maxlength="50"  onFocus="if (this.value=='Search ZoomTanzania.com') {this.value=''};"/>
				<select name="ParentSectionID">
					<option value="">Entire Site</option>
					<cfloop query="Sections">
						<option value="#ParentSectionID#">#Title#</option>
					</cfloop>
				</select>
				<input name="go" id="btn-go" type="image" value="Go" src="#FullHTTPURL#/images/sitewide/btn.go_off.gif" alt="Search" align="absmiddle" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-go','','images/sitewide/btn.go_on.gif',1)" />
			</form>
		</div>
		<div class="clear"></div>
	</div>
	
	<!-- LOGO AND AD ROW -->
	<div class="logoandad">
		<div id="logo" class="float-left"><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/"><img src="#FullHTTPURL#/images/sitewide/logoZoom.gif" width="344" height="126" alt="ZoomTanzania. Find What You Need - Fast!" /></a></div>
		<div id="ad" class="float-right">
		<cfif getBannerAdPos1.recordcount>
			<cfif Right(BannerAdImage1,3) is "swf">			
				<cfset AcRunActiveContentIncluded="1">
				<cfhtmlhead text='<script src="#request.HTTPSURL#/Scripts/AC_RunActiveContent.js" type="text/javascript"></script>'>
				<cfoutput>
					<script language="javascript">
						if (AC_FL_RunContent == 0) {
							alert("This page requires AC_RunActiveContent.js.");
						} else {
							AC_FL_RunContent(
								'codebase', 'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab##version=8,0,0,0',
								'width', '675',
								'height', '90',
								'src', 'uploads/BannerAds/#ReplaceNoCase(BannerAdImage1,'.swf','')#',
								'quality', 'high',
								'pluginspage', 'http://www.macromedia.com/go/getflashplayer',
								'align', 'middle',
								'play', 'true',
								'loop', 'true',
								'scale', 'showall',
								'wmode', 'transparent',
								'devicefont', 'false',
								'id', 'bannerAdPos1',
								'bgcolor', '##ffffff',
								'name', '#ReplaceNoCase(BannerAdImage1,'.swf','')#',
								'menu', 'true',
								'allowFullScreen', 'false',
								'allowScriptAccess','sameDomain',
								'movie', 'uploads/BannerAds/#ReplaceNoCase(BannerAdImage1,'.swf','')#',
								'salign', ''
								); //end AC code
						}
					</script>
					<noscript>
						<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab##version=8,0,24,0" width="675" height="90" id="BannerAdPos1" align="middle">
						<param name="allowScriptAccess" value="sameDomain" />
						<param name="allowFullScreen" value="false" />
						<param name="movie" value="uploads/BannerAds/#BannerAdImage1#" /><param name="quality" value="high" /><param name="bgcolor" value="##ffffff" />	<embed src="uploads/BannerAds/#BannerAdImage1#" quality="high" bgcolor="##ffffff" width="675" height="90" name="#BannerAdImage1#" align="middle" allowScriptAccess="sameDomain" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
						</object>
					</noscript>
				</cfoutput>
			<cfelse>
				<cfif Len(BannerAdUrl1) OR Len(BannerAdLinkFile1)><a href="<cfif Len(BannerAdUrl1)>#bannerAdUrl1#<cfelse>#request.httpurl#/uploads/bannerads/#bannerAdLinkFile1#</cfif>" target="_blank" onclick="<cfif Len(BannerAdUrl1)>clickThroughBannerExternal(#BannerAdID1#,'#BannerAdType1#')<cfelse>clickThroughBannerExpanded(#BannerAdID1#,'#BannerAdType1#')</cfif>"><img src="#fullhttpurl#/uploads/bannerAds/#BannerAdImage1#" class="grayBorderImg" /></a>
			
				<cfelse>
					<img src="#fullhttpurl#/uploads/bannerAds/#BannerAdImage#" alt="#BannerAdUrl1#" />
				</cfif>
			</cfif>
		<!--- <cfelse>
			No Banner Ad Found --->
		</cfif>
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
				
					<cfoutput query="Sections">
						<cfif Request.lh_useFriendlyUrls>
							<li><a href="#ParentSectionURLSafeTitle#">
						<cfelse>
							<li><a href="#lh_getPageLink(Request.SectionOverviewPageID,'sectionoverview')##AmpOrQuestion#ParentSectionID=#ParentSectionID#">
						</cfif>
						#Title#</a></li>
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
