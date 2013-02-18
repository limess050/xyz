<cfif PageID is "1">
	<cfquery name="getLatestFeaturedBusiness" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#" cachedwithin="#createtimespan(0,0,5,0)#">
		Select Top 1 L.ListingID, L.ListingTitle, L.ShortDescr, L.Deadline,
		L.ELPTypeThumbnailImage, L.LogoImage, L.ELPThumbnailFromDoc
		From ListingsView L With (NoLock)
		Where L.ListingTypeID  in (1,2,14)
		and L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ#
		<cfinclude template="../includes/LiveListingFilter.cfm">
		Order by L.FeaturedListing desc, L.DateSort desc
	</cfquery>
	<cfquery name="getFeaturedParentSectionaAndCategory" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#"cachedwithin="#createtimespan(0,0,5,0)#">
		Select L.ListingID, C.CategoryID, C.ParentSectionID
		From ListingsView L With (NoLock)
		Inner Join ListingCategories LC on L.ListingID=LC.ListingID
		Inner Join Categories C on LC.CategoryID=C.CategoryID
		Where L.ListingID=<cfqueryparam value="#getLatestFeaturedBusiness.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<div class="rightcol">
		<!-- LATEST FEATURED BUSINESS -->
		<div class="promotitle">Latest Featured Business</div>
		<div class="promo-latestfeaturebiz">
			<cfoutput query="getLatestFeaturedBusiness">	
				<cfif Len(LogoImage) and FileExists("#Request.ListingUploadedDocsDir#\#LogoImage#")>
					<p><a href="<cfif AmpOrQuestion is "?">#REReplace(Replace(Replace(ListingTitle," - ","-","All")," ","-","All"), "[^a-zA-Z0-9\-]","","all")#<cfelse>#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#</cfif>"><img src="ListingUploadedDocs/#LogoImage#" alt="#ListingTitle#"></a></p>
				</cfif>
				<p><a href="<cfif AmpOrQuestion is "?">#REReplace(Replace(Replace(ListingTitle," - ","-","All")," ","-","All"), "[^a-zA-Z0-9\-]","","all")#<cfelse>#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#</cfif>">#ListingTitle#</a></p>
			</cfoutput>
		</div>
	    <!-- FACEBOOK -->
		<div class="clear15"></div>
		<div id="fb-root"></div>
			<script src="http://connect.facebook.net/en_US/all.js#xfbml=1"></script>
			<fb:like-box href="http://www.facebook.com/pages/ZoomTanzaniacom/196820157025531" width="230" show_faces="true" stream="false" header="false"></fb:like-box>
			<!-- COMING SOON -->
			<cfoutput>
			<div class="promo-comingsoon">
				<br />
				<a href="#lh_getPageLink(48,'top-tanzania-blogs')#"><img src="images/home/btn.toptanzaniablogs.gif" width="210" height="28" alt="Top Tanzania Blogs" border="0"></a><br />
				<a href="#lh_getPageLink(49,'recommended-tanzania-websites')#"><img src="images/home/btn.othertanzaniawebsites.gif" width="210" height="28" alt="Featured Tanzania Websites" border="0" /></a> </div>
			</cfoutput>
	</div>
<cfelseif ShowRightColumn>
	<cfoutput>
	<div class="rightcol-inner">
      	<div class="clear15"></div>
		<cfset BannerAdPosition = "3">
		<cfinclude template="../includes/AdTechBannerAds.cfm">		
	</div>
	<!--- <div class="rightcol-inner">
		<div class="clear15"></div>
		<div id="AT_ANCHOR_DIV3944813" style="overflow:hidden;position:relative;width:200px;height:550px;z-index:0;">
			<div id="AT_DIV3944813" style="width:200px;height:550px;z-index:0;position:absolute;top:0px;left:0px;" onmouseover="expand3944813()" onmouseout="collapse3944813()">
				<a target="_blank" href="http://zoomtanzania.dev2.modernsignal.com">
					<img width="200" height="550" border="0" title=" " alt=" " src="images/AlienBug.jpg">
				</a>
			</div>
		</div>
	</div> --->
	</cfoutput>
</cfif>
		<div class="clear"></div>
		<!-- END HOME PAGE WRAPPER -->
	</div>
	<cfoutput>
	<div class="footer">
		<div class="footer-left float-left">Copyright &copy; #DateFormat(application.CurrentDateInTZ,'yyyy')#, All rights reserved</div>
		<div class="footer-right float-right"><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/" class="lightgray">Home</a> | <a href="#lh_getPageLink(9,'aboutus')#" class="lightgray">About Us</a> | <a href="#lh_getPageLink(8,'contactus')#" class="lightgray">Contact Us</a> | <a href="#lh_getPageLink(41,'zoom-advertising-options')#" class="lightgray">Advertise</a> | <a href="#lh_getPageLink(10,'privacypolicy')#" class="lightgray">Privacy Policy</a> | <a href="#lh_getPageLink(11,'termsofuse')#" class="lightgray">Terms of Use</a> | <a href="#lh_getPageLink(28,'sitemap')#" class="lightgray">Site Map</a> | <a href="#lh_getPageLink(7,'myaccount')#" class="darkgray">My Account</a><!--- <br />
			 | <a href="#lh_getPageLink(5,'postalisting')#" class="darkgray">Submit a Listing</a> | <a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=59" class="darkgray">Post an Event</a></div> --->
		<div class="clear"></div>
	</div>
	</cfoutput>
	<!-- END WRAPPER -->
</div>
<cfparam name="useCustomTracker" default="0">
<cfif (Request.environment is "LIVE" or Request.environment is "Devel") and not edit and not useCustomTracker>
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("<cfif Request.environment is "Live">UA-15419468-1<cfelse>UA-15419468-2</cfif>");
pageTracker._trackPageview();
} catch(err) {}</script>
</cfif>

<cfoutput>
<script language="javascript" type="text/javascript">	
	
	function clickThroughBannerExpanded(x,y) {
		
		var datastring = "BannerAdID=" + x + "&SectionID=" + y;
		$.ajax(
           {
			type:"POST",
               url:"#Request.HTTPSURL#/includes/ClickThroughBannerExpanded.cfc?method=Increment&returnformat=plain",
               data:datastring,
               success: function(response)
               {			
               }
           });		
	}
	
	
	function clickThroughBannerExternal(x,y) {
		
		var datastring = "BannerAdID=" + x + "&SectionID=" + y;
		$.ajax(
           {
			type:"POST",
               url:"#Request.HTTPSURL#/includes/ClickThroughBannerExternal.cfc?method=Increment&returnformat=plain",
               data:datastring,
               success: function(response)
               {			
               }
           });		
	}
</script>
</cfoutput>

