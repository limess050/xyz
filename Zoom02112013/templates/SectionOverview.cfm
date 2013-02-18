<cfset createObject("component","CFC.Limiter").limiter()>
<cfparam name="ParentSectionID" default="1">
<cfparam name="ShowEmptyCategories" default="1">
<cfparam name="SortBy" default="MostRecent">
<cfparam name="JETID" default=""><!--- Jobs and Employment Type ID --->
<cfparam name="CurrentPage" default="1">
<cfparam name="ShowFilterFields" default="">

<cfif ParentSectionID is "59">
	<cfinclude template="Calendar.cfm">
	<cfabort>
</cfif>

<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfif ListFind("4,5,8,55",ParentSectionID)>
	<cfset allFields="SelectedCategoryID,LocationID">
	<cfinclude template="../includes/setVariables.cfm">
	<cfmodule template="../includes/_checkNumbers.cfm" fields="SelectedCategoryID">
	
	<cfif Len(SelectedCategoryID) and IsNumeric(SelectedCategoryID)>	<!--- Redirect to Event Category Page if Category was selected in filters. --->
		<cfquery name="getCategoryURL" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select URLSafeTitle
			From Categories With (NoLock)
			Where CategoryID = <cfqueryparam value="#SelectedCategoryID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfif getCategoryURL.RecordCount>
			<cfset CategoryURL="#getCategoryURL.URLSafeTitle#">
			<cflocation url="#CategoryURL#" addToken="No">
			<cfabort>
		</cfif>
	</cfif>
</cfif>


<cfif not IsDefined('application.SectionImpressions')>
	<cfset application.SectionImpressions= structNew()>
</cfif>
<cfif StructKeyExists(application.SectionImpressions,ParentSectionID)>
	<cfset application.SectionImpressions[ParentSectionID] = application.SectionImpressions[ParentSectionID] + 1>
<cfelse>
	<cfset application.SectionImpressions[ParentSectionID] = 1>
</cfif>
<cfset ImpressionSectionID = ParentSectionID>

<cfinclude template="header.cfm">

<cfif edit>
	<div class="centercol-inner">
	<p class="STATUSMESSAGE">This page has no CMS manageable text.</p>
	</div>
	<cfinclude template="footer.cfm">
	<cfabort>
</cfif>
<script type="text/javascript" src="Lighthouse/Resources/js/lighthouse_all.js"></script>

<cfquery name="ParentSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT Title, Metakeywords, H1Text, URLSafeTitleDashed as URLSafeTitle
	FROM ParentSectionsView With (NoLock)
	Where ParentSectionID = <cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfif ParentSectionID is "8">
	<cfquery name="SectionLinksEmpOpps" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#" cachedwithin="#createtimespan(0,0,5,0)#">
		Select C.SectionID, S.Title as SubSection, S.OrderNum as SectionOrderNum, S.ImageFile as SectionImage,
		C.CategoryID, C.Title as Category, C.OrderNum as CategoryOrderNum, C.SectionID, C.ParentSectionID, C.URLSafeTitleDashed as CategoryURLSafeTitle,
		C.ImageFile as CategoryImage,
		(Select Count(L.ListingID) 
		From ListingsView L With (NoLock) Inner Join ListingCategories LC With (NoLock) on L.ListingID=LC.ListingID
		Where LC.CategoryID=C.CategoryID 
		<cfinclude template="../includes/LiveListingFilter.cfm"> 
		and (L.ListingTypeID is null or L.ListingTypeID in (10,12))) as ListingCount
		From Sections S With (NoLock)
		Left Outer Join Categories C With (NoLock) on S.SectionID=C.SectionID or (C.ParentSectionID=S.SectionID and C.SectionID is null) 		
		Where S.Active=1
		and C.Active=1
		and C.ParentSectionID=8
		and S.SectionID <> 29
		Order By SectionOrderNum, CategoryOrderNum
	</cfquery>
	<cfquery name="SectionLinksSeekEmp" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#" cachedwithin="#createtimespan(0,0,5,0)#">
		Select C.SectionID, S.Title as SubSection, S.OrderNum as SectionOrderNum, S.ImageFile as SectionImage,
		C.CategoryID, C.Title as Category, C.OrderNum as CategoryOrderNum, C.SectionID, C.ParentSectionID, C.URLSafeTitleDashed as CategoryURLSafeTitle,
		C.ImageFile as CategoryImage,
		(Select Count(L.ListingID) 
		From ListingsView L With (NoLock) Inner Join ListingCategories LC With (NoLock) on L.ListingID=LC.ListingID
		Where LC.CategoryID=C.CategoryID
		<cfinclude template="../includes/LiveListingFilter.cfm"> 
		and (L.ListingTypeID is null or L.ListingTypeID in (11,13))) as ListingCount
		From Sections S With (NoLock)
		Left Outer Join Categories C With (NoLock) on S.SectionID=C.SectionID or (C.ParentSectionID=S.SectionID and C.SectionID is null) 		
		Where S.Active=1
		and C.Active=1
		and C.ParentSectionID=8
		and S.SectionID <> 29
		Order By SectionOrderNum, CategoryOrderNum
	</cfquery>
	<cfif Len(SelectedCategoryID)>
		<cfset CategoryIDs=SelectedCategoryID>
	<cfelse>
		<cfset CategoryIDs=ValueList(SectionLinksEmpOpps.CategoryID)>
	</cfif>
	<cfset getFilenameForTN="1">
	<cfset FilterListingTypeID="">
	<cfif ListLen(CategoryIDs) is "1">
		<cfquery name="getCategoryListingTypes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select ListingTypeID
			From CategoryListingTypes With (NoLock)
			Where CategoryID=<cfqueryparam value="#CategoryIDs#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset FilterListingTypeID=getCategoryListingTypes.ListingTypeID>
		<cfset CategoryID=CategoryIDs>
	</cfif>
	<cfquery name="Locations" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select LocationID as SelectValue, Title as SelectText 
		From Locations With (NoLock)
		Where Active=1
		Order By OrderNum
	</cfquery>
	
	<cfsavecontent variable="FilterAdditionalParams">									
		<div class="filterField">&nbsp;&nbsp;
			<span class="filterLabel">Category: </span>
			<select class="dining-locationsearch" name="SelectedCategoryID" id="SelectedCategoryID">
				<option value="">-- Select --
				<cfoutput query="SectionLinksEmpOpps" group="SectionOrderNum">
					<optgroup label="#SubSection#">
					<cfoutput>
						<option value="#CategoryID#" <cfif CategoryID is SelectedCategoryID>selected</cfif>>#Category# (#ListingCount#)
					</cfoutput>
					</optgroup>
				</cfoutput>
			</select>		
		</div>
		<cfif not Len(SelectedCategoryID)>
			<cfoutput>										
			<div class="filterField">&nbsp;&nbsp;
				<span class="filterLabel">Location: </span>
				<select class="dining-locationsearch" name="LocationID" id="LocationID">
					<option value="">-- Select an Area --
					<cfloop query="Locations">
						<option value="#SelectValue#" <cfif ListFind(LocationID,SelectValue)>Selected</cfif>>#SelectText#
					</cfloop>
				</select>		
			</div>	
			</cfoutput>
		</cfif>
	</cfsavecontent>
	
	<cfset FilterAction="#ParentSection.URLSafeTitle#">
	<cfset CategoryPageFilter="0">
	<cfinclude template="../includes/Filter.cfm">
	<cfset JETID="1">
	<cfset InJobSectionOverview="1">
	<cfinclude template="../includes/GetListings.cfm">
	
	<!--- <cfif getListings.RecordCount gt request.RowsPerPage and not Len(PSQID)>
		<cfquery name="insertParentSectionQuery" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			exec insertParentSectionQuery '#Left(ValueList(getListings.ListingID),7999)#,', '#ParentSectionID#'
					
			Select Max(ParentSectionQueryID) as NewParentSectionQueryID
			From ParentSectionQueries
		</cfquery>
		<cfset PSQID=insertParentSectionQuery.NewParentSectionQueryID>
	</cfif> --->
<cfelse>
	<cfquery name="SectionLinks" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select C.SectionID, S.Title as SubSection, CASE WHEN C.SectionID IS null THEN null ELSE S.OrderNum END as SectionOrderNum, S.ImageFile as SectionImage,
		C.CategoryID, C.Title as Category, C.OrderNum as CategoryOrderNum, C.SectionID, C.ParentSectionID, C.URLSafeTitleDashed as CategoryURLSafeTitle,
		C.ImageFile as CategoryImage,
		(Select Count(L.ListingID) 
		From ListingsView L With (NoLock) Inner Join ListingCategories LC With (NoLock) on L.ListingID=LC.ListingID
		Where LC.CategoryID=C.CategoryID
		<cfinclude template="../includes/LiveListingFilter.cfm"> )
		as ListingCount
		From Sections S With (NoLock)
		Left Outer Join Categories C With (NoLock) on S.SectionID=C.SectionID or (C.ParentSectionID=S.SectionID and C.SectionID is null) 
		Where S.Active=1
		and C.ParentSectionID=<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">
		and C.Active=1
		Order By SectionOrderNum, CategoryOrderNum
	</cfquery>
	<cfif ListFind("4,5,55",ParentSectionID)>
		<cfif Len(SelectedCategoryID)>
			<cfset CategoryIDs=SelectedCategoryID>
		<cfelse>
			<cfset CategoryIDs=ValueList(SectionLinks.CategoryID)>
		</cfif>
		<cfset getFilenameForTN="1">
		<cfset FilterListingTypeID="">
		<cfif ListLen(CategoryIDs) is "1">
			<cfquery name="getCategoryListingTypes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select ListingTypeID
				From CategoryListingTypes With (NoLock)
				Where CategoryID=<cfqueryparam value="#CategoryIDs#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<cfset FilterListingTypeID=getCategoryListingTypes.ListingTypeID>
			<cfset CategoryID=CategoryIDs>
		</cfif>
		<cfquery name="getSections" dbtype="query">
			Select Distinct SectionID 
			From SectionLinks
		</cfquery>
		
		<cfsavecontent variable="FilterAdditionalParams">									
			<div class="filterField">&nbsp;&nbsp;
				<span class="filterLabel">Category: </span>
				<select class="dining-locationsearch" name="SelectedCategoryID" id="SelectedCategoryID">
					<option value="">-- Select --
					<cfoutput query="SectionLinks" group="SectionOrderNum">
						<cfif getSections.RecordCount gt "1"><optgroup label="#SubSection#"></cfif>
						<cfoutput>
							<option value="#CategoryID#" <cfif CategoryID is SelectedCategoryID>selected</cfif>>#Category# (#ListingCount#)
						</cfoutput>
						<cfif getSections.RecordCount gt "1"></optgroup></cfif>
					</cfoutput>
				</select>		
			</div>	
		</cfsavecontent>
		
		<!--- <cfset FilterAction="#lh_getPageLink(30,'sectionoverview')#"> --->
		<cfset FilterAction="#ParentSection.URLSafeTitle#">
		<cfset CategoryPageFilter="0">
		<cfinclude template="../includes/Filter.cfm">
		<cfif ParentSectionID is "4">
			<cfset HasSections="0">
		</cfif>
		<cfinclude template="../includes/GetListings.cfm">
		
		<!--- <cfif getListings.RecordCount gt request.RowsPerPage and not Len(PSQID)>
			<cfquery name="insertParentSectionQuery" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				exec insertParentSectionQuery '#Left(ValueList(getListings.ListingID),7999)#,', '#ParentSectionID#'
						
				Select Max(ParentSectionQueryID) as NewParentSectionQueryID
				From ParentSectionQueries
			</cfquery>
			<cfset PSQID=insertParentSectionQuery.NewParentSectionQueryID>
		</cfif> --->
	</cfif>
</cfif>


<cfoutput>
	<cfsavecontent variable="KeywordHeaderAdditions">
	<cfif Len(ParentSection.MetaKeywords)>
		<meta name="keywords" content="#ParentSection.MetaKeywords#">		
	</cfif>
	<!--[if lte IE 7]>
<style type="text/css">
.businessguide-skin-tango li {border-right: solid 1px ##d9d9d9; display: inline-block; width: 250px; padding: 8px; margin:3px; border-bottom: solid 1px ##CCC; vertical-align: text-top; min-height: 180px; text-align: center; zoom: 1; *display: inline;}
</style><![endif]-->
	</cfsavecontent>
</cfoutput>
	<cfhtmlhead text="#KeywordHeaderAdditions#">
	<script>
		$(document).ready(function() {
			$('.CategorySelect').change(function() {
				if ($(this).val() != '') {
					$(this).closest("form").attr('action', $(this).val());
					$(this).closest("form").submit();
				}
			});
		});
	</script>
	<div class="centercol-inner">
		<div class="promo-eventscalendar">
		 	<div class="promo-homepagetitle"><cfoutput><h1>#ParentSection.H1Text#</h1></cfoutput> </div>
			<div class="promo-eventscalendartext">
				<div class="PTwrapper">
					<cfif ParentSectionID is "8">			
						<div class="SearchCV float-left">		
    					<form action="" method="post">	
							<div class="promotitle">Search CV Database</div>
								<div class="promo-latestfeaturebiz">
								<p>
								<select name="CategorySelect" id="CategorySelect" class="CategorySelect dining-locationsearch">
					                  	<option value="">Choose a CV Category</option>
									<cfoutput query="SectionLinksSeekEmp" group="SectionOrderNum">
										<optgroup label="#SubSection#">
										<cfoutput>
											<cfif AmpOrQuestion is "?">
												<cfset CategoryLink="#CategoryURLSafeTitle#CVs">
											<cfelse>
												<cfset CategoryLink="#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#CategoryID#&JETID=2">
											</cfif>
											<option value="#CategoryLink#">#Category#&nbsp;(#ListingCount#)
										</cfoutput>
										</optgroup>
									</cfoutput>
					            </select> 
								</p>	
							</div>
						</form>
						</div>
					</cfif>
					
					<cfif ListFind("4,5,8,55",ParentSectionID)>
						<div class="float-right padLeft5">
						<cfoutput>
						<cfif ParentSectionID is "8"><!--- Jobs --->
							<a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=#ParentSectionID#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('postfreetanzania','','images/sitewide/btn.postvacancyforfree_on.gif',1)"><img src="images/sitewide/btn.postvacancyforfree_off.gif" alt="Post A Vacancy Free" name="postfreetanzania" width="164" height="20" border="0" align="right" id="postfreetanzania" /></a>
							<div class="clear5"></div><a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=#ParentSectionID#&ListingSectionID=19&ListingTypeID=11" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('postfreecvtanzania','','images/sitewide/btn.postcvforfree_on.gif',1)"><img src="images/sitewide/btn.postcvforfree_off.gif" alt="Post A CV Free" name="postfreecvtanzania" width="164" height="20" border="0" align="right" id="postfreetanzania" /></a>			
						<cfelseif ListFind("4,5,55",ParentSectionID)><!--- FSBO, Real Estate, Cars --->
							<a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=#ParentSectionID#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('postfreetanzania','','images/sitewide/btn.postclassifiedsforfree_on.gif',1)"><img src="images/sitewide/btn.postclassifiedsforfree_off.gif" alt="Post Classifieds Free" name="postfreetanzania" width="164" height="20" border="0" align="right" id="postfreetanzania" /></a>			
						<cfelse><!--- Everything else --->
							<a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=#ParentSectionID#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('postlistingtanzania','','images/sitewide/btn.postlisting_on.gif',1)"><img src="images/sitewide/btn.postlisting_off.gif" alt="Post A Listing" name="postlistingtanzania" width="164" height="20" border="0" align="right" id="postlistingtanzania" /></a>		
						</cfif>
						</cfoutput>
						</div>
						<cfif ParentSectionID is "8"><br class="clear"/></cfif>
					</cfif>					
					<cfmodule template="../includes/HelpfulHints.cfm" CategoryID="" SectionID="" ParentSectionID="#ParentSectionID#" OnSectionOverview="1">
				</div>
				<div class="clear5"></div>
				<cfmodule template="../includes/HelpfulHints.cfm" CategoryID="" SectionID="" ParentSectionID="#ParentSectionID#" HintTypeID="2">

<cfset SectionOverviewPage="1">

<cfif ParentSectionID is "8"><!--- Jobs --->
	<script>
		function validateForm1(f) {					
			return true;
		}
	</script>	
	<a name="S#SectionID#"></a>	
	<div class="clear5"></div>	
	<div class="filterForm">
	<hr>
		<cfif not Len(SelectedCategoryID)>
			<cfoutput>
			<cfif not Len(SelectedCategoryID)>
				<cfoutput>
					<form name="f1" action="#FilterAction#" method="get"  ONSUBMIT="return validateForm1(this)">
						<div class="notice">&nbsp;&nbsp;Filter listings by any combination of the fields below.</div><div class="clear5"></div>
							#FilterAdditionalParams#	
							<div class="filterField">&nbsp;&nbsp;
								<input name="btn-searchdining" id="btn-searchdining" type="image" value="Go" src="images/inner/btn.go_off.gif" alt="Go" align="absmiddle" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-searchdining','','images/inner/btn.go_on.gif',1)"  />
							</div>
					</form>
				</cfoutput>
			<cfelse>
				<cfoutput>#FilterForm#</cfoutput>
			</cfif>
			</cfoutput>
		<cfelse>
			<cfoutput>#FilterForm#</cfoutput>
		</cfif>
	</div>
	</div>
	</div>
	<div class="clear10"></div>
	<cfif getListings.RecordCount>
		<cfset CategoryResults="1">
		<cfset ShowDividers="0">
		<cfif Len(SelectedCategoryID)>
			<cfset PaginationPageLink="#lh_getPageLink(30,'sectionoverview')##AmpOrQuestion#ParentSectionID=#ParentSectionID#&SelectedCategoryID=#SelectedCategoryID#">
		<cfelse>
			<cfset PaginationPageLink="#lh_getPageLink(30,'sectionoverview')##AmpOrQuestion#ParentSectionID=#ParentSectionID#">	
		</cfif>
		
		<cfinclude template="../includes/ListingsResultsTable.cfm">
	<cfelse>
		<p><br /></p>
		<p class="greenlarge">No current listings were found for this category<cfif ListLen(ShowFilterFields)> with the selected criteria</cfif>.</p>
	</cfif>
<cfelseif ListFind("4,5,55",ParentSectionID)><!--- FSBO --->
	<script>
		function validateForm1(f) {					
			return true;
		}
	</script>
	<hr>
	
	<div class="filterForm">
	<cfif not Len(SelectedCategoryID)>
		<cfoutput>
			<form name="f1" action="#FilterAction#" method="get"  ONSUBMIT="return validateForm1(this)">
				<div class="notice">&nbsp;&nbsp;Filter listings by any combination of the fields below.</div><div class="clear5"></div>
					#FilterAdditionalParams#	
					<div class="filterField">&nbsp;&nbsp;
						<input name="btn-searchdining" id="btn-searchdining" type="image" value="Go" src="images/inner/btn.go_off.gif" alt="Go" align="absmiddle" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-searchdining','','images/inner/btn.go_on.gif',1)"  />
					</div>
			</form>
		</cfoutput>
	<cfelse>
		<cfoutput>#FilterForm#</cfoutput>
	</cfif>
	</div>
	</div>
	</div>
	<div class="clear15"></div>
	<cfif getListings.RecordCount>
		<cfset CategoryResults="1">
		<cfset ShowDividers="0">
		<cfif Len(SelectedCategoryID)>
			<cfset PaginationPageLink="#lh_getPageLink(30,'sectionoverview')##AmpOrQuestion#ParentSectionID=#ParentSectionID#&SelectedCategoryID=#SelectedCategoryID#">
		<cfelse>
			<cfset PaginationPageLink="#lh_getPageLink(30,'sectionoverview')##AmpOrQuestion#ParentSectionID=#ParentSectionID#">	
		</cfif>
		
		<cfinclude template="../includes/ListingsResultsTable.cfm">
	<cfelse>
		<p><br /></p>
		<p class="greenlarge">No current listings were found for this category<cfif ListLen(ShowFilterFields)> with the selected criteria</cfif>.</p>
	</cfif>
<cfelseif ParentSectionID is "21"><!--- Travel --->
	<cfquery name="SectionLinksSpecials" dbtype="query">
		Select *
		From SectionLinks
		Where SectionID=37
	</cfquery>
	<cfquery name="getLatestTravelSpecial" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#" cachedwithin="#createtimespan(0,0,5,0)#">
		Select Top 1 L.ListingID, L.ListingTitle, L.ShortDescr, L.Deadline,
		L.ELPTypeThumbnailImage, L.LogoImage, L.ELPThumbnailFromDoc, 
		L.AccountName, L.PriceUS, L.PriceTZS,
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ# Then 1 Else 0 END as HasExpandedListing, LC.CategoryID
		From ListingsView L With (NoLock)
		Inner Join ListingCategories LC With (NoLock) on L.ListingID=LC.ListingID
		Where L.ListingTypeID  in (9)
		and L.PaymentStatusID in (2,3)
		<cfinclude template="../includes/LiveListingFilter.cfm">
		Order by L.FeaturedTravelListing desc, L.DateSort desc
	</cfquery>
	<cfoutput query="SectionLinksSpecials" group="SectionOrderNum">
		<div class="clear10"></div>
		<a name="S#SectionID#"></a>
            <form action="" method="post">
				<div class="float-left widthTTS">
					<cfif getLatestTravelSpecial.RecordCount>
					<div class="promotitle"><h2>Latest Travel Special</h2></div>
					<div class="promo-latestfeaturebiz">
						<cfset ListingLink="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#getLatestTravelSpecial.ListingID#">	
						<cfif getLatestTravelSpecial.HasExpandedListing>	
							<cfif Len(getLatestTravelSpecial.ELPTypeThumbnailImage)>
								<cfset FeaturedTN=Replace(getLatestTravelSpecial.ELPTypeThumbnailImage,'.jp','Two.jp')>
								<cfset FeaturedTN=Replace(FeaturedTN,'.gif','Two.gif')>
								<cfset FeaturedTN=Replace(FeaturedTN,'.png','Two.png')>
							</cfif>				 	
						 	<cfif getLatestTravelSpecial.CategoryID neq "94" and getLatestTravelSpecial.ELPThumbnailFromDoc is "0" and Len(getLatestTravelSpecial.ELPTypeThumbnailImage) and FileExists("#Request.ListingUploadedDocsDir#\#FeaturedTN#")><!--- For most Special Travel Offers, show the Featured Image if it was uploaded. --->						
								<p><a href="#ListingLink#"><img src="ListingUploadedDocs/#FeaturedTN#" alt="#getLatestTravelSpecial.ListingTitle#"></a></p>
							<cfelseif Len(getLatestTravelSpecial.LogoImage) and FileExists("#Request.ListingUploadedDocsDir#\#getLatestTravelSpecial.LogoImage#")>
								<p><a href="#ListingLink#"><img src="ListingUploadedDocs/#getLatestTravelSpecial.LogoImage#" alt="#getLatestTravelSpecial.ListingTitle#"></a></p>
							</cfif> 					
						</cfif>
						<p><a href="#ListingLink#">#getLatestTravelSpecial.ListingTitle#<cfif Len(getLatestTravelSpecial.PriceUS)> $US&nbsp;#NumberFormat(getLatestTravelSpecial.PriceUS,",")#<cfelseif Len(getLatestTravelSpecial.PriceTZS)> TSH&nbsp;#NumberFormat(getLatestTravelSpecial.PriceTZS,",")#</cfif></a></p>	
					</div>
					</cfif>
				</div>
				<span class="SSSelect float-left">
					<strong>Tanzania National Parks</strong><br>
					<div class="promotitle"><h2>&nbsp;<a href="#lh_getPageLink(Request.NationalParksPageID,'tanzania-national-parks-guide')#">Tanzania National Parks Guide</a>&nbsp;</h2></div>
					<div class="promotitle"><h2><a href="#lh_getPageLink(Request.NationalParkFeePageID,'tanzania-national-park-fees')#">Tanzania National Park Fees</a></h2></div>
					<p><strong>#SubSection#</strong><br>					
					<cfoutput>
						<cfif AmpOrQuestion is "?">
							<cfset CategoryLink=CategoryURLSafeTitle>
						<cfelse>
							<cfset CategoryLink="#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#CategoryID#">
						</cfif>
						<a href="#CategoryLink#">#Category#&nbsp;(#ListingCount#)</a><br>
					</cfoutput>
				</span>
				<!--- <span class="SSSelect float-left">
					<strong>#SubSection#</strong><br>
					<select name="CategorySelect" id="CategorySelect" class="CategorySelect dining-locationsearch">
	                   	<option value="">Choose a Category</option>
						<cfoutput>
							<cfif AmpOrQuestion is "?">
								<cfset CategoryLink=CategoryURLSafeTitle>
							<cfelse>
								<cfset CategoryLink="#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#CategoryID#">
							</cfif>
							<option value="#CategoryLink#">#Category#&nbsp;(#ListingCount#)
						</cfoutput>
	                  	</select> 	
				</span> --->
			</form>
			<div class="clear"></div>
			</div>
			</div>
	</cfoutput>
	<cfquery name="SectionLinksBusinesses" dbtype="query">
		Select *
		From SectionLinks
		Where SectionID<>37
	</cfquery>
	<p></p>
	<!--- <cfoutput><div style="font-weight: bold;">#SectionLinksBusinesses.SubSection#</div></cfoutput> --->
	<ul class="businessguide-skin-tango">
	<cfoutput query="SectionLinksBusinesses" group="SectionOrderNum">		
		<cfoutput>
			<cfif AmpOrQuestion is "?">
				<cfset CategoryLink=CategoryURLSafeTitle>
			<cfelse>
				<cfset CategoryLink="#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#CategoryID#">
			</cfif>
			<li><h2><a href="#CategoryLink#"><cfif Len(CategoryImage) and FileExists("#Request.UploadedImages#/Categories/#CategoryImage#")><img src="uploads/Categories/#CategoryImage#" width="190" height="152" alt="#Category#" /></a><br /><br /> </cfif>
 <a href="#CategoryLink#">#Category#</a>&nbsp;(#ListingCount#)</h2></li>
 			</cfoutput>
	</cfoutput>
	</ul>
<cfelse>
	</div>
	</div>
	<ul class="businessguide-skin-tango">
	<cfoutput query="SectionLinks" group="SectionOrderNum">
		<cfif Len(SectionID)>
			<li class="MH255"><a name="S#SectionID#"></a>
				<h2><span class="ss">#SubSection#</span></h2>
                   <form action="" method="post">
					<select name="CategorySelect" id="CategorySelect" class="CategorySelect">
                    	<option value="">Choose a Category</option>
						<cfoutput>
							<cfif AmpOrQuestion is "?">
								<cfset CategoryLink=CategoryURLSafeTitle>
							<cfelse>
								<cfset CategoryLink="#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#CategoryID#">
							</cfif>
							<option value="#CategoryLink#">#Category#&nbsp;(#ListingCount#)
						</cfoutput>
                   	</select>
				</form> 
				<cfif Len(SectionImage) and FileExists("#Request.UploadedImages#\Sections\#SectionImage#")>
					<img src="Uploads/Sections/#SectionImage#" width="190" height="152" alt="#SubSection#" />
				</cfif>					                 
		   </li>
		<cfelse>			
			<cfoutput>
				<cfif AmpOrQuestion is "?">
					<cfset CategoryLink=CategoryURLSafeTitle>
				<cfelse>
					<cfset CategoryLink="#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#CategoryID#">
				</cfif>
				<li><h2><a href="#CategoryLink#"><cfif Len(CategoryImage) and FileExists("#Request.UploadedImages#/Categories/#CategoryImage#")><img src="uploads/Categories/#CategoryImage#" width="190" height="152" alt="#Category#" /></a><br /><br /> </cfif>
  <a href="#CategoryLink#">#Category#</a>&nbsp;(#ListingCount#)</h2></li>
  			</cfoutput>
		</cfif>		
	</cfoutput>
	</ul>
</cfif>
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
pageTracker._setCustomVar(2,"Section","#ParentSection.Title#",3 );
pageTracker._trackPageview();
} catch(err) {}</script>
</cfif>
</cfoutput>
