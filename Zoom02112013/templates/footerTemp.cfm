
	<cfquery name="getLatestFeaturedBusiness" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select Top 1 L.ListingID, L.ListingTitle, L.ShortDescr, L.Deadline,
		L.ELPTypeThumbnailImage, L.LogoImage, L.ELPThumbnailFromDoc
		From ListingsView L
		Where L.ListingTypeID  in (1,2)
		and L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= DATEADD(Day, 0, DATEDIFF(Day, 0, GetDate())+1)
		<cfinclude template="../includes/LiveListingFilter.cfm">
		Order by DateSort desc
	</cfquery>
	<cfquery name="getFeaturedParentSectionaAndCategory" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select L.ListingID, C.CategoryID, C.ParentSectionID
		From ListingsView L
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

		<div class="clear"></div>
		<!-- END HOME PAGE WRAPPER -->
	</div>
	<cfoutput>
	<div class="footer">
		<div class="footer-left float-left">Copyright &copy; 2011, All rights reserved</div>
		<div class="footer-right float-right"><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/" class="lightgray">Home</a> | <a href="#lh_getPageLink(9,'aboutus')#" class="lightgray">About Us</a> | <a href="#lh_getPageLink(8,'contactus')#" class="lightgray">Contact Us</a> | <a href="#lh_getPageLink(23,'ratecard')#" class="lightgray">Advertise</a> | <a href="#lh_getPageLink(10,'privacypolicy')#" class="lightgray">Privacy Policy</a> | <a href="#lh_getPageLink(11,'termsofuse')#" class="lightgray">Terms of Use</a> | <a href="#lh_getPageLink(28,'sitemap')#" class="lightgray">Site Map</a> | <a href="#lh_getPageLink(7,'myaccount')#" class="darkgray">My Account</a><!--- <br />
			 | <a href="#lh_getPageLink(5,'postalisting')#" class="darkgray">Submit a Listing</a> | <a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=59" class="darkgray">Post an Event</a></div> --->
		<div class="clear"></div>
	</div>
	</cfoutput>
	<!-- END WRAPPER -->
</div>