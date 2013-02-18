<cfset createObject("component","CFC.Limiter").limiter()>
<cfparam name="Preview" default="0">
<cfparam name="JETID" default="">

<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfif not edit and Not IsDefined('ListingID')>
	<cfinclude template="header.cfm">
	<div class="centercol-inner legacy">
	<p class="STATUSMESSAGE">No Listing passed.</p>
	</div>
	<cfinclude template="footer.cfm">
	<cfabort>
<cfelseif edit>
	<cfset ListingID="1">
</cfif>

<cfif IsDefined('session.UserID') and Len(session.UserID)>
	<cfquery name="checkAdmin" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select AdminUser
		From LH_Users
		Where UserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
</cfif>

<cfquery name="getListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
Select L.ListingID, 
	L.ListingTitle, 
	L.ShortDescr, L.DateListed, L.ListingTypeID, L.ListingType,
	L.PublicPhone, L.PublicPhone2, L.PublicPhone3, L.PublicPhone4,  L.PublicEmail, L.WebsiteURL, L.PriceUS, L.PriceTZS,
	L.Make as MakeOther, L.Model as ModelOther, L.VehicleYear, L.Kilometers, L.FourWheelDrive,
	L.RentUS, L.RentTZS, L.Bedrooms, L.Bathrooms, L.AmenityOther, L.LocationOther, L.LocationText,
	L.EventStartDate, L.EventEndDate, L.RecurrenceID, L.RecurrenceMonthID, L.AccountName,
	L.Deadline, L.LongDescr, L.Instructions, L.UploadedDoc,
	L.ExpandedListingHTML, L.ExpandedListingPDF, L.ExpandedListingInProgress,
	C.CategoryID, C.Title as Category, C.URLSafeTitleDashed as CategoryURLSafeTitle, C.Descr as CallOut,
	PS.ParentSectionID, PS.Title as ParentSection, PS.URLSafeTitleDashed as ParentSectionURLSafeTitle,
	S.SectionID, S.Title as SubSection,	
	L.CuisineOther, L.NGOTypeOther,
	L.SquareFeet, L.SquareMeters,
	M.Title as Make, T.Title as Transmission,
	Te.Title as Term,
	ELO.PaymentStatusID as ExpandedListingPaymentStatusID,
	L.AcctWebsiteURL,
	L.UserID, L.InProgressUserID,
	L.ExpirationDate,
	L.LogoImage, CASE WHEN L.ELPTypeOther is not null and ELPTypeOther <> '' THEN L.ELPTypeOther ELSE ELPT.Descr END as ELPType, L.ELPTypeOther, L.ELPTypeThumbnailImage,
	CASE WHEN L.ExpirationDate >= #application.CurrentDateInTZ# THEN 0 ELSE 1 END as ListingExpired,
	CASE WHEN HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ#  THEN 1 Else 0 END as HasExpandedListing,
	CASE WHEN L.UserID = <cfqueryparam value="#Request.PhoneOnlyUserID#" cfsqltype="CF_SQL_INTEGER"> THEN 1 ELSE 0 END as PhoneOnlyListing_fl,
	L.ParkOther, MovieFees
	From ListingsView L With (NoLock)
	Inner Join ListingCategories LC With (NoLock) on L.ListingID=LC.ListingID 
	Inner Join Categories C With (NoLock) on LC.CategoryID=C.CategoryID 
	Inner Join ParentSectionsView PS With (NoLock) on C.ParentSectionID=PS.ParentSectionID
	Left Outer Join Sections S With (NoLock) on C.SectionID=S.SectionID
	Left Outer Join Makes M With (NoLock) on L.MakeID=M.MakeID
	Left Outer Join Transmissions T With (NoLock) on L.TransmissionID=T.TransmissionID
	Left outer Join Terms Te With (NoLock) on L.TermID=Te.TermID
	Left Outer Join Orders ELO With (NoLock) on L.ExpandedListingOrderID=ELO.OrderID
	Left Outer Join ELPTypes ELPT With (NoLock) on L.ELPTypeID=ELPT.ELPTypeID
	Where L.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
	and L.DeletedAfterSubmitted=0
	<cfif Preview>
		<cfif IsDefined('session.UserID') and Len(session.UserID) and not checkAdmin.AdminUser>
			and (L.InProgressUserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
				or L.UserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">)
		</cfif>
	<cfelse>
		<cfinclude template="../includes/LiveListingFilter.cfm">
	</cfif>
	and PS.Active=1	
</cfquery>
<cfif getListing.ListingTypeID is "15">
	<cfquery name="getRecurrenceDays"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		select lr.RecurrenceDayID, rd.descr
		from ListingRecurrences lr With (NoLock)
		inner join RecurrenceDays rd With (NoLock) ON rd.recurrenceDayID = lr.recurrenceDayID
		where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<!--- If event dates are all passed, mark page 404 --->
	<cfquery name="getFutureEventDays"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT ListingID 
		FROM ListingEventDays with (NOLOCK)
		WHERE ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		AND ListingEventDate >= #application.CurrentDateInTZ#
	</cfquery>
	<cfif not getFutureEventDays.RecordCount and not Preview>
		<cfheader statuscode="410" statustext="Gone">
		<cfif FileExists(Application.PhysicalPath & "\templates\404.cfm")>
			<cfinclude template="../templates/404.cfm">
		<cfelse>
			<cfinclude template="header.cfm">
			<div class="centercol-inner legacy">
				<div class="PTWrapper">
					<h1>Event Passed</h1>
					<p>The event "<cfoutput>#getListing.ListingTitle#</cfoutput>", has passed and no longer exists on this site.</p>
				</div>
			</div>
			<cfinclude template="footer.cfm">
		</cfif>
		<cfabort>	
	</cfif>
</cfif>

<cfif not getListing.RecordCount>
	<cfinclude template="header.cfm">
	<!-- CENTER COL -->
	<div class="centercol-inner legacy">
	<p class="STATUSMESSAGE">Listing not found</p>
	
	<cfif edit>
		Message to that appears when user has reach the daily "Click to Email" limit on job opportunities. 
		<lh:MS_SitePagePart id="bodyJobClickLimit" class="body">
		Message to that appears when user tries to apply for a job posting but is not logged in. 
		<lh:MS_SitePagePart id="bodyJobPleaseLogIn" class="body">
	</cfif>
	</div>
	<cfset ShowHintsAndRelLinks="0">
	<cfinclude template="footer.cfm">
	<cfabort>
</cfif>

<cfset ImpressionSectionID=getListing.ParentSectionID>

<cfinclude template="header.cfm">
<script type="text/javascript" src="Lighthouse/Resources/js/lighthouse_all.js"></script>

<cfset CategoryID=getListing.CategoryID>

<cfset HR4Qualified=0>
<cfset FSBO4Qualified=0>
<cfif Len(getListing.UserID) or Len(getListing.InProgressUserID)>
	<cfquery name="getAccountQuals" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select AQ.HR4Qualified, AQ.FSBO4Qualified
		From AccountsQualified AQ With (NoLock)
		Where AQ.UserID=<cfif Len(getListing.UserID)><cfqueryparam value="#getListing.UserID#" cfsqltype="CF_SQL_INTEGER"><cfelse><cfqueryparam value="#getListing.InProgressUserID#" cfsqltype="CF_SQL_INTEGER"></cfif>
	</cfquery>
	<cfif getAccountQuals.HR4Qualified is "1">
		<cfset HR4Qualified=1>
	</cfif>
	<cfif getAccountQuals.FSBO4Qualified is "1">
		<cfset FSBO4Qualified=1>
	</cfif>
</cfif>



<cfif not Preview>
	<cfif not IsDefined('application.SectionImpressions')>
		<cfset application.SectionImpressions= structNew()>
	</cfif>
	<cfif StructKeyExists(application.SectionImpressions,getListing.ParentSectionID)>
		<cfset application.SectionImpressions[getListing.ParentSectionID] = application.SectionImpressions[getListing.ParentSectionID] + 1>
	<cfelse>
		<cfset application.SectionImpressions[getListing.ParentSectionID] = 1>
	</cfif>
	
	<cfif not IsDefined('application.CategoryImpressions')>
		<cfset application.CategoryImpressions= structNew()>
	</cfif>
	<cfif StructKeyExists(application.CategoryImpressions,CategoryID)>
		<cfset application.CategoryImpressions[CategoryID] = application.CategoryImpressions[CategoryID] + 1>
	<cfelse>
		<cfset application.CategoryImpressions[CategoryID] = 1>
	</cfif>
	
	<cfif not IsDefined('application.ListingImpressions')>
		<cfset application.ListingImpressions= structNew()>
	</cfif>
	<cfif StructKeyExists(application.ListingImpressions,ListingID)>
		<cfset application.ListingImpressions[ListingID] = application.ListingImpressions[ListingID] + 1>
	<cfelse>
		<cfset application.ListingImpressions[ListingID] = 1>
	</cfif>
</cfif>

<cfif getListing.RecordCount>
	<cfif ListFind("3,4,5,6,7,8,9",getListing.ListingTypeID)>
		<cfquery name="getListingImages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select FileName
			From ListingImages With (NoLock)
			Where ListingID=<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
			Order By OrderNum, ListingImageID
		</cfquery>
	</cfif>
	<cfif getListing.ListingTypeID is "2">
		<cfquery name="getListingCuisines" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select LC.CuisineID, C.Title
			From ListingCuisines LC With (NoLock)
			Inner Join Cuisines C With (NoLock) on LC.CuisineID=C.CuisineID
			Where LC.ListingID=<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	<cfelseif getListing.ListingTypeID is "1">
		<cfquery name="getListingPriceRanges" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select LPR.PriceRangeID, PR.Title
			From ListingPriceRanges LPR With (NoLock)
			Inner Join PriceRanges PR With (NoLock) on LPR.PriceRangeID=PR.PriceRangeID
			Where LPR.ListingID=<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	<cfelseif getListing.ListingTypeID is "14">
		<cfquery name="getListingNGOTypes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select LNT.NGOTypeID, NT.Title
			From ListingNGOTypes LNT With (NoLock)
			Inner Join NGOTypes NT With (NoLock) on LNT.NGOTypeID=NT.NGOTypeID
			Where LNT.ListingID=<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cfif>
	<cfif Len(getListing.WebsiteURL)>
		<cfset WebsiteLink=getListing.WebsiteURL>
		<cfif Left(WebsiteLink,4) neq "http">
			<cfset WebsiteLink="http://" & WebsiteLink>
		</cfif>
	</cfif>
	
	<cfquery name="GetLocationTitles"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.Title as Location
		From ListingLocations LL With (NoLock)
		Inner Join Locations L With (NoLock) on LL.LocationID=L.LocationID
		Where LL.ListingID = <cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
		and L.LocationID <> 4
		Order by L.Title
	</cfquery>	
	<cfset LocationTitles=ValueList(getLocationTitles.Location)>
	<cfset LocationOutput="">
	<cfset LocationOutput=LocationTitles>
	<cfif Len(getListing.LocationOther)>
		<cfset LocationOutput=ListAppend(LocationOutput,getListing.LocationOther)>
	</cfif>
	<cfset LocationOutput=Replace(LocationOutput,",",", ","ALL")>
	
	<cfif getListing.ParentSectionID is "8"><!--- Determine JETID --->
		<cfif getListing.SectionID is "29"><!--- Tenders --->
			<cfif ListFind("10,12",getListing.ListingTypeID)>
				<cfset JETID="3">
			<cfelse>
				<cfset JETID="4">
			</cfif>
		<cfelse>
			<cfif ListFind("10,12",getListing.ListingTypeID)>
				<cfset JETID="1">
			<cfelse>
				<cfset JETID="2">
			</cfif>
		</cfif>
	</cfif>
</cfif>

<cfoutput>
<div class="centercol-inner legacy">
<div class="PTWrapper">

	<h1>#ListingTitleForH1#</h1>
	<div class="float-right padLeft5 top5">
		<cfoutput>
		<cfif ListFind("4,5,55",getListing.ParentSectionID)><!--- FSBO, Cars --->
			<a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=#getListing.ParentSectionID#<cfif Len(getListing.SectionID)>&ListingSectionID=#getListing.SectionID#</cfif>&CategoryID=#getListing.CategoryID#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('postfreetanzania','','images/sitewide/btn.postclassifiedsforfree_on.gif',1)"><img src="images/sitewide/btn.postclassifiedsforfree_off.gif" alt="Post Classifieds Free" name="postfreetanzania" width="164" height="20" border="0" align="right" id="postfreetanzania" /></a>
		<cfelseif getListing.ParentSectionID is "8"><!--- Jobs --->
			<cfif JETID is "2"><!--- CVs --->
				<a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=#getListing.ParentSectionID#&ListingSectionID=#getListing.SectionID#&ListingTypeID=#getListing.ListingTypeID#&CategoryID=#getListing.CategoryID#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('postfreecvtanzania','','images/sitewide/btn.postcvforfree_on.gif',1)"><img src="images/sitewide/btn.postcvforfree_off.gif" alt="Post A CV Free" name="postfreecvtanzania" width="164" height="20" border="0" align="right" id="postfreetanzania" /></a>	
			<cfelse><!--- Job Opps --->
				<a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=#getListing.ParentSectionID#&ListingSectionID=#getListing.SectionID#&ListingTypeID=#getListing.ListingTypeID#&CategoryID=#getListing.CategoryID#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('postfreetanzania','','images/sitewide/btn.postvacancyforfree_on.gif',1)"><img src="images/sitewide/btn.postvacancyforfree_off.gif" alt="Post A Vacancy Free" name="postfreetanzania" width="164" height="20" border="0" align="right" id="postfreetanzania" /></a>
			</cfif>		
		<cfelseif getListing.ParentSectionID is "59"><!--- Events --->
			<a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=#getListing.ParentSectionID#<cfif Len(getListing.SectionID)>&ListingSectionID=#getListing.SectionID#</cfif>&CategoryID=#getListing.CategoryID#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('posteventsfreetanzania','','images/sitewide/btn.posteventsfree_on.gif',1)"><img src="images/sitewide/btn.posteventsfree_off.gif" alt="Post Events Free" name="posteventsfreetanzania" width="148" height="20" border="0" align="right" id="posteventsfreetanzania" /></a>
		<cfelse><!--- Everything else --->
			<a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=#getListing.ParentSectionID#<cfif Len(getListing.SectionID)>&ListingSectionID=#getListing.SectionID#</cfif>&CategoryID=#getListing.CategoryID#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('postlistingtanzania','','images/sitewide/btn.postlisting_on.gif',1)"><img src="images/sitewide/btn.postlisting_off.gif" alt="Post A Listing" name="postlistingtanzania" width="164" height="20" border="0" align="right" id="postlistingtanzania" /></a>	
		</cfif>
		</cfoutput>
	</div>
</div>
<!--- <cfmodule template="../includes/HelpfulHints.cfm" CategoryID="#getListing.CategoryID#" SectionID="#getListing.SectionID#" ParentSectionID="#getListing.ParentSectionID#"> ---><br>

<cfif getListing.RecordCount>
 <div class="breadcrumb""><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/">Home</a> &gt;  <a href="#getListing.ParentSectionURLSafeTitle#">#getListing.ParentSection#</a> &gt; 
	<cfif Len(getListing.SectionID)>
		<cfif getListing.ParentSectionID is "8">
			<a href="#getListing.ParentSectionURLSafeTitle###J#JETID#">
			<cfif JETID is "1">
				Employment Opportunities
			<cfelse><!--- 2 --->
				Seeking Employment
			</cfif></a> &gt;
		</cfif>
		<a href="#getListing.ParentSectionURLSafeTitle###<cfif Len(JETID)>J#JetID#</cfif>S#getListing.SectionID#">#getListing.SubSection#</a> &gt;
	</cfif> 
	<a href="<cfif AmpOrQuestion is "?">#getListing.CategoryURLSafeTitle#<cfif JETID is "2">CVs</cfif><cfelse>#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#GetListing.CategoryID#<cfif Len(JETID)>&JETID=#JETID#</cfif></cfif>">#getListing.Category#</a> 
 </div>
 </cfif>
</cfoutput>
<cfif getListing.RecordCount>
	<cfif not ListFind("1,2,14,15",getListing.ListingTypeID) and getListing.ListingExpired and not Preview>
		<cfoutput>
			<p>&nbsp;</p>
			<p class="greenlarge">#ListingTitleForH1#</p>
			<p>The listing you are attempting to view is expired. Please see other listings like it&nbsp;in&nbsp;>&nbsp;<a href="<cfif AmpOrQuestion is "?">#getListing.CategoryURLSafeTitle#<cfif JETID is "2">CVs</cfif><cfelse>#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#GetListing.CategoryID#<cfif Len(JETID)>&JETID=#JETID#</cfif></cfif>">#getListing.Category#</a>.
		</cfoutput>
	<cfelse>
		<cfif IsDefined('StatusMessage')>
			<cfif statusMessage is "MS">
				<cfoutput>
					<p class="Important">
						<br>Your message has been sent.
						<cfif ListFind("4,8,37,55,59,39,40,50",getListing.SectionID) or ListFind("4,8,37,55,59,39,40,50",getListing.ParentSectionID)>
							 <br>Would you like to receive Email Alerts when similar #GetListing.ParentSection# listings are added?</p>
							 <p><a href="#lh_getPageLink(Request.AddAlertPageID,'SignUpForAlerts')#"><img id="SignUp" name="SignUp" value="Sign Me Up" src="images/inner/btn.Alerts_off.gif" align="absmiddle" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('SignUp','','images/inner/btn.Alerts_on.gif',1)"></a>
						</cfif>
					</p>
				</cfoutput>
			<cfelseif statusMessage is "MNS">
				<cfoutput>
					<p class="Important">
						<br>Your message was NOT sent.
					</p>
				</cfoutput>
			<cfelse>
				<p class="Important"><br><cfoutput>#StatusMessage#</cfoutput></p>
			</cfif>
		</cfif>
		<cfinclude template="../includes/ListingDetailOutput.cfm">
		<p>&nbsp;</p>
		<div class="addthis_toolbox addthis_default_style">
			<a class="addthis_button_email"></a>
		    <a class="addthis_button_print"></a>
			<a class="addthis_button" href="http://www.addthis.com/bookmark.php?v=250&amp;username=kirkdar"></a>
		</div>
		<script type="text/javascript">
			var addthis_config = {
			data_track_clickback: true,
		    username: "kirkdar",
		    services_compact: 'fark, bizsugar, facebook, delicious, google, live, aim, adifni, digg, myspace, more'        
		    }
			function jsAppend(js_file)
			{
			    js_script = document.createElement('script');
			    js_script.type = "text/javascript";
			    js_script.src = js_file;
			    document.getElementsByTagName('head')[0].appendChild(js_script);
			}
			jsAppend(window.location.protocol + "//s7.addthis.com/js/250/addthis_widget.js");
		</script>
	</cfif>
	<!--- <script type="text/javascript">
	addthis.button("#emailbutton", "addthis_email");
	</script> --->
<cfelse>
	<p><br /></p>
	<p class="greenlarge">No current listing found.</p>
</cfif>

</div>

<!-- END CENTER COL -->
<cfoutput>
<script language="javascript" type="text/javascript">
	$(document).ready(function() {
	    $('.ListingImage').each(function() {
	        var maxWidth = 470; // Max width for the image
	        var maxHeight = 10000;    // Max height for the image
	        var ratio = 0;  // Used for aspect ratio
	        var width = $(this).width();    // Current image width
	        var height = $(this).height();  // Current image height
	 
	        // Check if the current width is larger than the max
	        if(width > maxWidth){
	            ratio = maxWidth / width;   // get ratio for scaling image
	            $(this).css("width", maxWidth); // Set new width
	            $(this).css("height", height * ratio);  // Scale height based on ratio
	            height = height * ratio;    // Reset height to match scaled image
	            width = width * ratio;    // Reset width to match scaled image
	        }
	 
	        // Check if current height is larger than max
	        if(height > maxHeight){
	            ratio = maxHeight / height; // get ratio for scaling image
	            $(this).css("height", maxHeight);   // Set new height
	            $(this).css("width", width * ratio);    // Scale width based on ratio
	            width = width * ratio;    // Reset width to match scaled image
	        }
	    });
	});
	
	
	function clickThroughExpanded(x) {
		
		var datastring = "ListingID=" + x;    
		$.ajax(
           {
			type:"POST",
               url:"#Request.HTTPSURL#/includes/ClickThroughExpanded.cfc?method=Increment&returnformat=plain",
               data:datastring,
               success: function(response)
               {			
               }
           });		
	}
	
	
	function clickThroughExternal(x) {
		
		var datastring = "ListingID=" + x;    
		$.ajax(
           {
			type:"POST",
               url:"#Request.HTTPSURL#/includes/ClickThroughExternal.cfc?method=Increment&returnformat=plain",
               data:datastring,
               success: function(response)
               {			
               }
           });		
	}
</script>

<cfset useCustomTracker="1">

<cfinclude template="footer.cfm">

<cfif (Request.environment is "LIVE" or Request.environment is "Devel") and not edit>
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("<cfif Request.environment is "Live">UA-15419468-1<cfelse>UA-15419468-2</cfif>");
pageTracker._setCustomVar(1,"Category","#getListing.Category#",3 );
pageTracker._setCustomVar(2,"Section","#getListing.ParentSection#",3 );
pageTracker._setCustomVar(3,"SubSection","#getListing.SubSection#",3 );
pageTracker._setCustomVar(4,"ListingType","#getListing.ListingType#",3);
pageTracker._setCustomVar(4,"Listing","#getListing.ListingID# - #getListing.ListingTitle#",3 );
pageTracker._trackPageview();
} catch(err) {}</script>
</cfif>
</cfoutput>