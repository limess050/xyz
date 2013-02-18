<cfset createObject("component","CFC.Limiter").limiter()>
<!---
This template expects a CategoryID
--->
<cfparam name="SortBy" default="">
<cfparam name="JETID" default=""><!--- Jobs and Employment Type ID --->
<cfparam name="CurrentPage" default="1">
<cfparam name="QID" default=""><!--- Refers to CategoryQueryID, used to display randomized results set across pagination pages --->
<cfparam name="getFilenameForTN" default="0">
<cfparam name="TME" default="0">
<script type="text/javascript" src="Lighthouse/Resources/js/lighthouse_all.js"></script>

<cfif IsDefined('EventCategoryID') and (not Len(EventCategoryID) or not IsNumeric(EventCategoryID))><!--- Redirect to Event Search Page if no Category was selected in filters. --->
	<cfset EventSearchParams="">
	<cfif IsDefined('EventStartDate') and Len(EventStartDate)>
		<cfset EventSearchParams=ListAppend(EventSearchParams,"EventStartDate=#EventStartDate#","&")>
	</cfif>
	<cfif IsDefined('EventStartDate') and Len(EventEndDate)>
		<cfset EventSearchParams=ListAppend(EventSearchParams,"EventStartDate=#EventStartDate#","&")>
	</cfif>
	<cfif IsDefined('LocationID') and Len(LocationID)>
		<cfset EventSearchParams=ListAppend(EventSearchParams,"LocationID=#LocationID#","&")>
	</cfif>
	<cfif Len(EventSearchParams)>
		<cfset EventsURL="searchEvents?#EventSearchParams#">
	<cfelse>
		<cfset EventsURL="searchEvents">
	</cfif>
	<cflocation url="#EventsURL#" addToken="No">
	<cfabort>
</cfif>

<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<script type="text/javascript" src="Lighthouse/Resources/js/lighthouse_all.js"></script>

<cfif not edit and Not IsDefined('CategoryID')>
	<cfinclude template="header.cfm">
	<div class="centercol-inner">
	<p class="STATUSMESSAGE">No Category passed.</p>
	</div>
	<cfinclude template="footer.cfm">
	<cfabort>
<cfelseif edit>
	<cfinclude template="header.cfm">
	<div class="centercol-inner">
	<p class="STATUSMESSAGE">This page has no CMS manageable text.</p>
	</div>
	<cfinclude template="footer.cfm">
	<cfabort>
</cfif>

<cfquery name="getCategory" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select C.Title, C.ParentSectionID, C.SectionID, C.Descr as CallOut, C.H1Text, C.MetaKeywords, C.URLSafeTitle,
	PS.Title as ParentSection, S.Title as SubSection
	From Categories C With (NoLock)
	Left Outer Join ParentSectionsView PS With (NoLock) on C.ParentSectionID=PS.ParentSectionID
	Left Outer Join Sections S With (NoLock) on C.SectionID=S.SectionID
	Where C.CategoryID=<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">	
</cfquery>
<cfif not getCategory.RecordCount>
	<cflocation url="index.cfm" AddToken="No">
	<cfabort>
</cfif>

<cfif not IsDefined('application.CategoryImpressions')>
	<cfset application.CategoryImpressions= structNew()>
</cfif>
<cfif StructKeyExists(application.CategoryImpressions,CategoryID)>
	<cfset application.CategoryImpressions[CategoryID] = application.CategoryImpressions[CategoryID] + 1>
<cfelse>
	<cfset application.CategoryImpressions[CategoryID] = 1>
</cfif>

<cfset ImpressionSectionID=getCategory.ParentSectionID>

<cfif not IsDefined('application.SectionImpressions')>
	<cfset application.SectionImpressions= structNew()>
</cfif>
<cfif StructKeyExists(application.SectionImpressions,ImpressionSectionID)>
	<cfset application.SectionImpressions[ImpressionSectionID] = application.SectionImpressions[ImpressionSectionID] + 1>
<cfelse>
	<cfset application.SectionImpressions[ImpressionSectionID] = 1>
</cfif>
<cfset FormFieldsToCopy="LocationID,CuisineID,NGOTypeID">
<cfinclude template="header.cfm">
<!--- This automatically copies the Filter Form field values into the Inquery form, so that any filters selected but not yet submitted get includesd in the Inquery query.  --->
<script>
	$(document).ready(function(){
		$('#fT').submit(function() {
			<cfloop list="#FormFieldsToCopy#" index="ff">
				<cfoutput>$('###ff#C').val($('###ff#').val());</cfoutput>
			</cfloop>
		});
    });
</script>

<cfquery name="getCategoryListingTypes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select ListingTypeID
	From CategoryListingTypes With (NoLock)
	Where CategoryID=<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfset FilterListingTypeID=getCategoryListingTypes.ListingTypeID>
<cfquery name="checkForLTsWithCatTNs" dbtype="query">
	Select ListingTypeID
	From getCategoryListingTypes
	Where ListingTypeID in (3,4,5,6,7,8)
</cfquery>
<cfif checkForLTsWithCatTNs.RecordCount>
	<cfset getFilenameForTN="1">	
</cfif>

<cfif not Len(SortBy)>
	<cfif ListFind("4,5,8,55",getCategory.ParentSectionID) and not ListFind(ValueList(getCategoryListingTypes.ListingTypeID),1)>
		<cfset SortBy="MostRecent">
	<cfelseif ListFind("59",getCategory.ParentSectionID)>
		<cfset SortBy="EventSort">
	<cfelseif getCategory.ParentSectionID is "21" and not ListFind(ValueList(getCategoryListingTypes.ListingTypeID),1)>
		<cfset SortBy="MostRecent">
	</cfif>
</cfif>

<cfset FilterAction="#getCategory.URLSafeTitle#">
<cfif ListFind(Request.ParkCategoryIDs,CategoryID)>
	<cfset FilterParkCategory="1">
</cfif>
<cfinclude template="../includes/Filter.cfm">

<cfset CategoryIDs=CategoryID>
<cfset ParentSectionID=GetCategory.ParentSectionID>
<cfif not Len(getCategory.SectionID)>
	<cfset HasSections="0">
</cfif>
<cfinclude template="../includes/getListings.cfm">

<cfif getListings.RecordCount gt request.RowsPerPage and not Len(QID)>
	<cfquery name="insertCategoryQuery" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		exec InsertCategoryQuery '#Left(ValueList(getListings.ListingID),7999)#,', '#CategoryID#'
				
		Select Max(CategoryQueryID) as NewCategoryQueryID
		From CategoryQueries
	</cfquery>
	<cfset QID=insertCategoryQuery.NewCategoryQueryID>
</cfif>

<cfif getListings.ParentSectionID is "8"><!--- Determine JETID --->
	<cfif ListFind("10,12",getListings.ListingTypeID)>
		<cfset JETID="1">
	<cfelse>
		<cfset JETID="2">
	</cfif>
</cfif>

<cfoutput>
	<cfif Len(getCategory.MetaKeywords)>
		<cfsavecontent variable="KeywordHeaderAdditions">
			<meta name="keywords" content="#getCategory.MetaKeywords#">
		</cfsavecontent>
		<cfhtmlhead text="#KeywordHeaderAdditions#">
	</cfif>
	<div class="centercol-inner">	
	<table width="100%">
		<tr>
			<td class="promo-eventscalendar" valign="top">
				<div class="promo-homepagetitle">
					<h1>#getCategory.H1Text#</h1>
			    </div>
				
				<div class="promo-eventscalendartext">
					<div class="PTwrapper">
						<div class="float-right padLeft5">
							<cfoutput>
							<cfif ListFind("4,5,55",ParentSectionID)><!--- FSBO, Real Estate, Cars --->
								<a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=#getCategory.ParentSectionID#<cfif Len(getCategory.SectionID)>&ListingSectionID=#getCategory.SectionID#</cfif>&CategoryID=#CategoryID#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('postfreetanzania','','images/sitewide/btn.postclassifiedsforfree_on.gif',1)"><img src="images/sitewide/btn.postclassifiedsforfree_off.gif" alt="Post Classifieds Free" name="postfreetanzania" width="164" height="20" border="0" align="right" id="postfreetanzania" /></a>
							<cfelseif ParentSectionID is "8"><!--- Jobs --->
								<cfif JETID is "2"><!--- CVs --->
									<a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=#ParentSectionID#&ListingSectionID=#GetCategory.SectionID#&ListingTypeID=#getCategoryListingTypes.ListingTypeID#&CategoryID=#CategoryID#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('postfreecvtanzania','','images/sitewide/btn.postcvforfree_on.gif',1)"><img src="images/sitewide/btn.postcvforfree_off.gif" alt="Post A CV Free" name="postfreecvtanzania" width="164" height="20" border="0" align="right" id="postfreetanzania" /></a>	
								<cfelse><!--- Job Opps --->
									<a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=#getCategory.ParentSectionID#&ListingSectionID=#getCategory.SectionID#&ListingTypeID=#getCategoryListingTypes.ListingTypeID#&CategoryID=#CategoryID#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('postfreetanzania','','images/sitewide/btn.postvacancyforfree_on.gif',1)"><img src="images/sitewide/btn.postvacancyforfree_off.gif" alt="Post A Vacancy Free" name="postfreetanzania" width="164" height="20" border="0" align="right" id="postfreetanzania" /></a>
								</cfif>		
							<cfelseif ParentSectionID is "59"><!--- Events --->
								<a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=#getCategory.ParentSectionID#<cfif Len(getCategory.SectionID)>&ListingSectionID=#getCategory.SectionID#</cfif>&CategoryID=#CategoryID#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('posteventsfreetanzania','','images/sitewide/btn.posteventsfree_on.gif',1)"><img src="images/sitewide/btn.posteventsfree_off.gif" alt="Post Events Free" name="posteventsfreetanzania" width="148" height="20" border="0" align="right" id="posteventsfreetanzania" /></a>
							<cfelse><!--- Everything else --->
								<a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=#getCategory.ParentSectionID#<cfif Len(getCategory.SectionID)>&ListingSectionID=#getCategory.SectionID#</cfif>&CategoryID=#CategoryID#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('postlistingtanzania','','images/sitewide/btn.postlisting_on.gif',1)"><img src="images/sitewide/btn.postlisting_off.gif" alt="Post A Listing" name="postlistingtanzania" width="164" height="20" border="0" align="right" id="postlistingtanzania" /></a>	
							</cfif>
							</cfoutput>
						</div>
	                    <cfmodule template="../includes/HelpfulHints.cfm" CategoryID="#CategoryID#" SectionID="#getCategory.SectionID#" ParentSectionID="#getCategory.ParentSectionID#">
					</div>
					<cfmodule template="../includes/HelpfulHints.cfm" CategoryID="#CategoryID#" SectionID="#getCategory.SectionID#" ParentSectionID="#getCategory.ParentSectionID#" HintTypeID="2">
                	<cfif getListings.RecordCount>
						 <div class="breadcrumb"><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/">Home</a> &gt; <a href="#getListings.ParentSectionURLSafeTitle#">#getListings.ParentSection#</a> &gt; 
							<cfif Len(getListings.SectionID)>
								<cfif getListings.ParentSectionID is "8"and getListings.SectionID is "29">
									<a href="#getListings.ParentSectionURLSafeTitle###J#JETID#"><cfif JETID is "3">
										Tenders Opportunities
									<cfelse><!--- 4 --->
										Seeking Tenders
									</cfif></a> &gt;
								<cfelse>
									<cfif getListings.ParentSectionID is "8">
										<a href="#getListings.ParentSectionURLSafeTitle###J#JETID#">
										<cfif JETID is "1">
											Employment Opportunities
										<cfelse><!--- 2 --->
											Seeking Employment
										</cfif></a> &gt;
									</cfif>
									<a href="#getListings.ParentSectionURLSafeTitle###<cfif Len(JETID)>J#JetID#</cfif>S#getListings.SectionID#">#getListings.SubSection#</a> &gt;
								</cfif>
							</cfif> 
							<span class="breadcrumb-selected">#getListings.Category#</span></div>
						</cfif>  
<!--- <div class="breadcrumb"><a href="index.html">Home</a> > <a href="#">Dining &amp; Nightlife</a> > <span class="breadcrumb-selected">Tanzania Restaurants Guide</span></div> --->
						<hr />
						<div class="clear15"></div>
						<div class="filterForm">
							#FilterForm#
						</div>
					  </div></td>
				</tr>
			</table>
			<cfif ListFind("1,2,14",getCategoryListingTypes.ListingTypeID)>
				<div id="RequestBid">
					<table>
						<tr>
							<td style="vertical-align: middle;padding-top: 10px;">
								<cfoutput>
									<form name="fT" ID="fT" action="page.cfm?PageID=#Request.TenderPageID#" method="post">
										<cfif Len(QID)>
											<input type="hidden" name="ListingResultsQID" value="#QID#">
										<cfelse>
											<input type="hidden" name="ListingResults" value="#ValueList(getListings.ListingID)#">
										</cfif>
										<input type="hidden" name="CategoryID" value="#CategoryID#">	
										<input type="hidden" name="CategoryURL" value="#getCategory.URLSafeTitle#">	
										<input type="image" name="SGI" ID="SGI" value="Send Group Inquiry" title="TIP:  Use the 'Filter Listings' fields above to narrow your options before opening the group inquiry form." src="images/inner/btn.groupinquiry_off.gif" align="absmiddle" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('SGI','','images/inner/btn.groupinquiry_on.gif',1)">	
										<input type="hidden" name="FilterListingTypeID" value="#FilterListingTypeID#">	
										<cfloop list="#FormFieldsToCopy#" index="ff">
											<input type="hidden" name="#ff#" ID="#ff#C" value="">
										</cfloop>
									</form>
								</cfoutput>
							</td>
							<td class="promo-eventscalendartext" style="padding-bottom: 0px;">
								<strong>Send an email inquiry to up to 6 businesses below at one time.</strong>
							</td>
						</tr>
					</table>
				</div>
			</cfif>
		  <cfif TME is "1">
		  	<p class="STATUSMESSAGE">None of the listings has an email address, so no inquiries can be sent.</p>
		  </cfif>
		  
		  
		
	<cfif getListings.RecordCount>
		<cfif ListFind("84,85,86",CategoryID)>
			<p><br />
			Sort by: <cfif SortBy is "Year"><strong><a href="#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#CategoryID#&SortBy=Year#FilterCriteria#">Year</a></strong><cfelse><a href="#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#CategoryID#&SortBy=Year#FilterCriteria#">Year</a></cfif> | <cfif SortBy is "MakeModel"><strong><a href="#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#CategoryID#&SortBy=Year#FilterCriteria#">Make & Model</a></strong><cfelse><a href="#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#CategoryID#&SortBy=MakeModel#FilterCriteria#">Make & Model</a></cfif></p>
		</cfif>
		<cfset CategoryResults="1">
		<cfif ParentSectionID is "59">
			<cfset ShowDividers="0">
			<cfset EventCategory="1">
		</cfif>
		<cfif ParentSectionID is "21" and not ListFind(ValueList(getCategoryListingTypes.ListingTypeID),1)>
			<cfset ShowDividers="1">
			<cfset ShowNoImageTN="1">
			<cfset ShowFeaturedListings = "0">
		</cfif>
		<cfinclude template="../includes/ListingsResultsTable.cfm">
	<cfelse>
		<p><br /></p>
		<p class="greenlarge">No current listings were found for this category<cfif ListLen(ShowFilterFields)> with the selected criteria</cfif>.</p>
	</cfif>
</cfoutput>
	
</div>

<!-- END CENTER COL -->


<cfset useCustomTracker="1">

<cfinclude template="footer.cfm">
<cfoutput>
<cfif (Request.environment is "LIVE" or Request.environment is "Devel") and not edit>
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("<cfif Request.environment is "Live">UA-15419468-1<cfelse>UA-15419468-2</cfif>");
pageTracker._setCustomVar(1,"Category","#getCategory.Title#",3);
pageTracker._setCustomVar(2,"Section","#getCategory.ParentSection#",3);
pageTracker._setCustomVar(3,"SubSection","#getCategory.SubSection#",3);
pageTracker._trackPageview();
} catch(err) {}</script>
</cfif>
</cfoutput>