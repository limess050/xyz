<!---
Simple header used for Listing Images page and image-based ELP page.
--->

<cfparam name="UseImageController" default="1">
<cfparam name="ShowBannerAds" default="0">
<cfparam name="ImpressionSectionID" default="0">
<cfparam name="InImageViewer" default="0">

<cfset NowinDAR=DateAdd('h',7,Now())>

<!--- If logged in as AdminUser, log them out. --->

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

<cfif cgi.https is "on">
	<cfset FullHTTPURL=Request.HTTPSURL>
<cfelse>
	<cfset FullHTTPURL=Request.HTTPURL>
</cfif>

<cfsavecontent variable="DARHeaderAdditions">
<cfoutput>
<cfif UseImageController>
	<style>
		.TB_Wrapper {
			max-width: 660px;
			height: 500px;  
		}
	</style>
	<link rel="stylesheet" href="trans_banner/style.css" />
	<script src="trans_banner/jquery-1.7.1.min.js"></script>
	<script src="trans_banner/jquery.easing.1.3.min.js"></script>
	<script src="trans_banner/trans-banner.min.js"></script>
	<script type="text/javascript">
		jQuery(function($){
			$('.TB_Wrapper').TransBanner({
				slide_autoplay: false,
				button_show_back: true,
				image_resize_to_fit: true,
				button_size: 40,
				<cfif InImageViewer and getListing.RecordCount and getListingImages.RecordCount is "1">
					button_show_next: false,
					button_show_back: false,
					button_show_numbers: false,
					button_show_timer: false,
				</cfif>
				button_numbers_autohide: false
			});  
		});    
	</script>
</cfif>
<!--[if IE 6]>
<link rel="stylesheet" type="text/css" media="all" href="ie6.css" />
<![endif]--> 
 </cfoutput>
</cfsavecontent>
<cfhtmlhead text="#DARHeaderAdditions#">
<cfoutput>
<div class="wrapper">
	<div class="masthead">
		
		<div class="clear"></div>
	</div>
	<!-- LOGO AND AD ROW -->
	<div class="logoandad">
		<div id="logo" class="float-left"><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/"><img src="#FullHTTPURL#/images/sitewide/logoZoom.gif" width="344" height="126" alt="ZoomTanzania. Find What You Need - Fast!" /></a></div>
		<div id="ad" class="float-right">
			<cfif ShowBannerAds>
				<cfinclude template="../includes/AdTechBannerAds.cfm">		
			</cfif>
		</div>
		<div class="clear"></div>
	</div>
	</cfoutput>
<!-- CONTENT -->
<div class="hp-wrapper">
