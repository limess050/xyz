<!---
Site Search Template
Shows a search screen for site-wide search.
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<script type="text/javascript" src="Lighthouse/Resources/js/lighthouse_all.js"></script>

<cfparam name="SearchKeyword" default="">
<cfparam name="EventStartDate" default="">
<cfparam name="EventEndDate" default="">
<cfparam name="EventCategoryID" default="">
<cfparam name="LocationID" default="">

<cfif Len(EventCategoryID) and IsNumeric(EventCategoryID)>	<!--- Redirect to Event Category Page if Category was selected in filters. --->
	<cfquery name="getCategoryURL" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select URLSafeTitle
		From Categories With (NoLock)
		Where CategoryID = <cfqueryparam value="#EventCategoryID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfset EventSearchParams="">
	<cfif IsDefined('EventStartDate') and Len(EventStartDate)>
		<cfset EventSearchParams=ListAppend(EventSearchParams,"EventStartDate=#EventStartDate#","&")>
	</cfif>
	<cfif IsDefined('EventEndDate') and Len(EventEndDate)>
		<cfset EventSearchParams=ListAppend(EventSearchParams,"EventEndDate=#EventEndDate#","&")>
	</cfif>
	<cfif IsDefined('LocationID') and Len(LocationID)>
		<cfset EventSearchParams=ListAppend(EventSearchParams,"LocationID=#LocationID#","&")>
	</cfif>
	<cfif Len(EventSearchParams)>
		<cfset EventsURL="#getCategoryURL.URLSafeTitle#?#EventSearchParams#">
	<cfelse>
		<cfset EventsURL="#getCategoryURL.URLSafeTitle#">
	</cfif>
	<cflocation url="#EventsURL#" addToken="No">
	<cfabort>
</cfif>

<cfset ResultsLabel="Events">

<cfif SearchKeyword is "Find an Event by Keyword">
	<cfset SearchKeyword="">
</cfif>

<cfset HPAccordion="0">
<cfset ContentStyle="content">

<cfif not IsDefined('application.SectionImpressions')>
	<cfset application.SectionImpressions= structNew()>
</cfif>
<cfif StructKeyExists(application.SectionImpressions,59)>
	<cfset application.SectionImpressions[59] = application.SectionImpressions[59] + 1>
<cfelse>
	<cfset application.SectionImpressions[59] = 1>
</cfif>
<cfset ImpressionSectionID = 59>

<cfinclude template="header.cfm">

<cfset InDate=EventStartDate>
<cfinclude template="../includes/DateFormatter.cfm">
<cfset LocalEventStartDate=OutDate>

<cfif Len(EventStartDate) and DateCompare(NowInDAR,LocalEventStartDate) is "1">
	<cfset LocalEventStartDate=DateFormat(NowInDar,'mm/dd/yyyy')>
	<cfset EventStartDate=DateFormat(NowInDar,'dd/mm/yyyy')>
</cfif>

<cfset InDate=EventEndDate>
<cfinclude template="../includes/DateFormatter.cfm">
<cfset LocalEventEndDate=OutDate>

<cfif Len(EventEndDate) and DateCompare(NowInDAR,LocalEventEndDate) is "1">
	<cfset LocalEventEndDate=DateFormat(NowInDar,'mm/dd/yyyy')>
	<cfset EventEndDate=DateFormat(NowInDar,'dd/mm/yyyy')>
</cfif>

<!--- <cfoutput>#Request.Page.GetCookieCrumb()#</cfoutput><br>
<cfoutput>#Request.Page.GetSectionName()#</cfoutput> --->

<!--- <lh:MS_SitePagePart id="title" class="title">
<lh:MS_SitePagePart id="body" class="body">
 --->

<cfquery name="getListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">		
	Select L.ListingID, L.ListingTypeID, L.ListingTitle, L.ShortDescr, L.DateListed, L.PriceUS, L.PriceTZS,
	L.RentUS, L.RentTZS, L.Bedrooms, L.Bathrooms, L.AmenityOther, L.LocationOther, L.LocationText,
	L.LongDescr, L.MakeID,
	L.Make as MakeOther, L.Model, L.Model as ModelOther, L.VehicleYear, L.Kilometers, L.FourWheelDrive,
	L.Deadline, L.WebsiteURL, L.PublicPhone,  L.PublicPhone2,  L.PublicPhone3,  L.PublicPhone4, L.PublicEmail, 
	L.EventStartDate as StartDate, L.EventEndDate as EndDate, L.RecurrenceID, L.RecurrenceMonthID,
	L.ExpandedListingHTML, L.ExpandedListingPDF,
	<cfinclude template="../includes/EventOrderingColumns.cfm">
	CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ# Then 1 Else 0 END as HasExpandedListing, 
	L.ELPTypeThumbnailImage, L.SquareFeet, L.SquareMeters,
	L.LogoImage,
	M.Title as Make, T.Title as Transmission,
	Te.Title as Term, 
	CASE WHEN L.UserID = <cfqueryparam value="#Request.PhoneOnlyUserID#" cfsqltype="CF_SQL_INTEGER"> THEN 1 ELSE 0 END as PhoneOnlyListing_fl,
	<cfif Len(SearchKeyword)>
		KEY_TBL.RANK as Rank
	<cfelse>
		0 as Rank
	</cfif>	
	FROM ListingsView L With (NoLock)
	Left Outer Join Makes M With (NoLock) on L.MakeID=M.MakeID
	Left Outer Join Transmissions T With (NoLock) on L.TransmissionID=T.TransmissionID
	Left outer Join Terms Te With (NoLock) on L.TermID=Te.TermID
    	<cfif Len(SearchKeyword)>INNER JOIN FREETEXTTABLE(Listings, *, <cfqueryparam value="#SearchKeyword#" cfsqltype="CF_SQL_VARCHAR">) AS KEY_TBL ON KEY_TBL.[KEY] = L.ListingID</cfif>
	Where 
	(Exists (Select LS.ListingID From ListingSections LS With (NoLock) Where LS.SectionID in (59) and LS.ListingID=L.ListingID)
	or exists (Select ListingID from ListingParentSections LPS With (NoLock) Where LPS.ParentSectionID in (59) and LPS.ListingID=L.ListingID))
	<cfinclude template="../includes/LiveListingFilter.cfm">
	<cfif Len(EventCategoryID)>
		and exists (Select ListingID from ListingCategories LC With (NoLock) Where L.ListingID=LC.ListingID and LC.CategoryID=<cfqueryparam value="#EventCategoryID#" cfsqltype="CF_SQL_INTEGER">)
	</cfif>
	<cfif Len(LocationID)>
		and exists (Select ListingID from ListingLocations LL With (NoLock) Where L.ListingID=LL.ListingID and LL.LocationID=<cfqueryparam value="#LocationID#" cfsqltype="CF_SQL_INTEGER">)
	</cfif>
	<cfif Len(EventStartDate) and not Len(EventEndDate)>
		and exists (Select ListingID from ListingEventDays LD With (NoLock) Where L.ListingID=LD.ListingID and LD.ListingEventDate >= <cfqueryparam value="#LocalEventStartDate#" cfsqltype="CF_SQL_DATE">)
	<cfelseif Len(EventEndDate) and not Len(EventStartDate)>
		and exists (Select ListingID from ListingEventDays LD With (NoLock) Where L.ListingID=LD.ListingID and LD.ListingEventDate <= <cfqueryparam value="#LocalEventEndDate#" cfsqltype="CF_SQL_DATE">)
	<cfelseif Len(EventStartDate) and Len(EventEndDate)>
		<cfif EventStartDate is EventEndDate>
			and exists (Select ListingID from ListingEventDays LD With (NoLock) Where L.ListingID=LD.ListingID and LD.ListingEventDate = <cfqueryparam value="#LocalEventStartDate#" cfsqltype="CF_SQL_DATE">)
		<cfelse>
			and exists (Select ListingID from ListingEventDays LD With (NoLock) Where L.ListingID=LD.ListingID and LD.ListingEventDate >= <cfqueryparam value="#LocalEventStartDate#" cfsqltype="CF_SQL_DATE"> and LD.ListingEventDate <= <cfqueryparam value="#LocalEventEndDate#" cfsqltype="CF_SQL_DATE">)				
		</cfif>
	</cfif>
	ORDER BY EventSortDate, EventRank, L.ListingTitle	
</cfquery>
<cfquery name="ParentSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT Title, Metakeywords, H1Text, URLSafeTitleDashed as URLSafeTitle
	FROM ParentSectionsView With (NoLock)
	Where ParentSectionID = 59
</cfquery>
<cfset ShowFeaturedListings = "0">

<style>
	#content {border-top: solid 2px #c0c0c0; clear: both; background: url(images/inner/bg.content.gif) repeat-y left #FFFFFF; padding-top: 5px;}
</style>
<cfoutput>
<div class="centercol-inner">
	<div class="promo-eventscalendar">
	 	<div class="promo-homepagetitle"><h1>#ParentSection.H1Text#</h1> </div>
		<div class="promo-eventscalendartext">
			<cfoutput>
				<div class="PTwrapper">
					<div class="float-right padLeft5">
	                  	<a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=59" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('posteventsfreetanzania','','images/sitewide/btn.posteventsfree_on.gif',1)"><img src="images/sitewide/btn.posteventsfree_off.gif" alt="Post Events Free" name="posteventsfreetanzania" width="148" height="20" border="0" align="right" id="posteventsfreetanzania" /></a>
						</div>
					<cfmodule template="../includes/HelpfulHints.cfm" CategoryID="" SectionID="" ParentSectionID="59">
				</div>
			</cfoutput>
			<cfmodule template="../includes/HelpfulHints.cfm" CategoryID="" SectionID="" ParentSectionID="59" HintTypeID="2">
 			<div class="breadcrumb"><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/">Home</a> &gt; <a href="Events">Tanzania Events</a><cfif Len(EventCategoryID) and getCategory.RecordCount> &gt; <span class="bluelarge">#getCategory.Title#</span></cfif></div>

</cfoutput>

<hr>
<cfinclude template="../includes/EventsSearchRow.cfm">
		</div>
	</div>
<div class="clear"></div>	
<lh:MS_SitePagePart id="body" class="body">
<cfif edit>
	<p>Search results appear here when a front end user searches the site for events.
<cfelse>	
	<cfoutput>
		<p>Your search found <strong>#getListings.RecordCount#</strong> result<cfif getListings.RecordCount neq "1">s</cfif>.<br>
	</cfoutput>
	<cfset SearchURLString="">
	<cfif Len(SearchKeyword)>
		<cfset SearchURLString=ListAppend(SearchURLString,"searchKeyword=#UrlEncodedFormat(SearchKeyword)#","&")>
	</cfif>
	<cfif Len(EventStartDate)>
		<cfset SearchURLString=ListAppend(SearchURLString,"EventStartDate=#UrlEncodedFormat(EventStartDate)#","&")>
	</cfif>
	<cfif Len(EventEndDate)>
		<cfset SearchURLString=ListAppend(SearchURLString,"EventEndDate=#UrlEncodedFormat(EventEndDate)#","&")>
	</cfif>
	<cfif Len(EventCategoryID)>
		<cfset SearchURLString=ListAppend(SearchURLString,"EventCategoryID=#UrlEncodedFormat(EventCategoryID)#","&")>
	</cfif>
	
	<cfset PaginationPageLink="#lh_getPageLink(Request.SearchEventsPageID,'searchEvents')##AmpOrQuestion##SearchURLString#">
	<cfset ShowDividers="0">
	<cfset EventCategory="1">
	<cfinclude template="../includes/ListingsResultsTable.cfm">	
</cfif>
</div>


<!--- <cfset ShowRightColumn="0"> --->
<cfinclude template="footer.cfm">