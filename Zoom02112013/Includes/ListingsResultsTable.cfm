<!--- Outputs getListings query with pagination. Used in templates Category.cfm and Search.cfm --->

<cfparam name="StartRow" default="1">
<cfparam name="SortBy" default="">
<cfparam name="CategoryID" default="1">
<cfparam name="PaginationPageLink" default="#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#CategoryID#">
<cfparam name="FilterCriteria" default="">
<cfparam name="QID" default="">
<cfparam name="CategoryResults" default="0">
<cfparam name="ResultsLabel" default="">
<cfparam name="ShowDividers" default="1">
<cfparam name="ShowPagination" default="1">
<cfparam name="FeaturedShown" default="0">
<cfparam name="FeaturedOpen" default="0">
<cfparam name="NonFeaturedOpen" default="0">
<cfparam name="PhoneOnlyOpen" default="0">
<cfparam name="EventCategory" default="0">
<cfparam name="ShowNoImageTN" default="0">
<cfparam name="ShowFeaturedListings" default="1">
<cfparam name="SearchResults" default="0">

<cfif getListings.RecordCount gt Request.RowsPerPage>
	 <cfparam name="CurrentPage" default="1">
	 <cfset NumOfPages=Ceiling(getListings.RecordCount/Request.RowsPerPage)>
	 <cfif CurrentPage gt NumOfPages>
	 	<cfset CurrentPage=NumOfPages>
	 <cfelseif CurrentPage lt 1>
	 	<cfset CurrentPage="1">
	 </cfif>
	 <cfset PrevPage=CurrentPage-1>
	 <cfset NextPage=CurrentPage+1>
	 <cfset StartRow=((CurrentPage-1)*Request.RowsPerPage)+1>
	 <cfif NumOfPages gt Request.LinksPerPage>
	 	<cfset StartPage=Ceiling(CurrentPage-(Request.LinksPerPage/2))>
		<cfif StartPage lt 1>
			<cfset StartPage=1>
		</cfif>
		<cfset EndPage=StartPage+Request.LinksPerPage-1>
		<cfif EndPage gt NumOfPages>
			<cfset EndPage=NumOfPages>
		</cfif>
	 	<cfset JumpBackToPage=StartPage-Ceiling((Request.LinksPerPage/2))>
		<cfif JumpBackToPage lt 1>
			<cfset JumpBackToPage=1>
		</cfif>
		<cfset JumpForwardToPage=EndPage+Ceiling((Request.LinksPerPage/2))+1>
		<cfif JumpForwardToPage gt NumOfPages>
			<cfset JumpForwardToPage=NumOfPages>
		</cfif>
	 <cfelse>
	 	<cfset StartPage="1">
		<cfset EndPage=NumOfPages>
	 </cfif>
	 <!--[if lte IE 7]>
<style type="text/css">
.dining-skin-tango li {border-right: solid 1px #d9d9d9; display: inline-block; width: 260px; padding: 0px; margin: 7px 3px; border-bottom: solid 1px #CCC; vertical-align: text-top; min-height: 180px; text-align: center; zoom: 1; *display: inline;}
</style><![endif]-->
	 <cfoutput>
	 <cfsavecontent variable="PaginationString">
	<div class="float-right pages">		
		<cfloop from="#StartPage#" to="#EndPage#" index="i">
			<cfif i is StartPage>
				Pages
				<cfif CurrentPage neq "1">
					<a href="#PaginationPageLink#&CurrentPage=#PrevPage#<cfif Len(SortBy)>&SortBy=#SortBy#</cfif><cfif Len(QID)>&QID=#QID#</cfif><cfif Len(FilterCriteria)>#FilterCriteria#</cfif>"><img src="images/home/prev-horizontal.png"></a>
				</cfif> 
				<cfif StartPage neq "1"><a href="#PaginationPageLink#&CurrentPage=#JumpBackToPage#<cfif Len(SortBy)>&SortBy=#SortBy#</cfif><cfif Len(QID)>&QID=#QID#</cfif><cfif Len(FilterCriteria)>#FilterCriteria#</cfif>">...</a></cfif>
			</cfif>
			<cfif i is CurrentPage>#i#<cfelse><a href="#PaginationPageLink#&CurrentPage=#i#<cfif Len(SortBy)>&SortBy=#SortBy#</cfif><cfif Len(QID)>&QID=#QID#</cfif><cfif Len(FilterCriteria)>#FilterCriteria#</cfif>">#i#</a></cfif>
			<cfif i neq EndPage> | </cfif>
			<cfif i is EndPage and EndPage lt NumOfPages><a href="#PaginationPageLink#&CurrentPage=#JumpForwardToPage#<cfif Len(SortBy)>&SortBy=#SortBy#</cfif><cfif Len(QID)>&QID=#QID#</cfif><cfif Len(FilterCriteria)>#FilterCriteria#</cfif>">...</a></cfif>
			<cfif CurrentPage neq EndPage and i is EndPage>
				<a href="#PaginationPageLink#&CurrentPage=#NextPage#<cfif Len(SortBy)>&SortBy=#SortBy#</cfif><cfif Len(QID)>&QID=#QID#</cfif><cfif Len(FilterCriteria)>#FilterCriteria#</cfif>"><img src="images/home/next-horizontal.png"></a>
			</cfif>
		</cfloop>
	</div>
	</cfsavecontent>
	<!--- #PaginationString# --->
	</cfoutput>
<cfelse>
	<cfset PaginationString="">
</cfif>
<!--- <cfif not ShowDividers><p><br /></p></cfif> --->

<cfset NumFeaturedListings="0">
<cfoutput query="getListings" startrow="#StartRow#" maxrows="#Request.RowsPerPage#">
	<cfif HasExpandedListing>
		<cfset NumFeaturedListings=NumFeaturedListings+1>
	</cfif>
</cfoutput>

<cfset ListingCounter=0>
<cfset ListingIDs="">
<cfset RecurrenceMonthIDs="">
<cfoutput query="getListings" startrow="#StartRow#" maxrows="#Request.RowsPerPage#">
	<cfif Len(ListingID)>
		<cfset ListingIDs=ListAppend(ListingIDs,ListingID)>
		<cfif ListingTypeID is "15" and Len(RecurrenceMonthID) and not ListFind(RecurrenceMonthIDs,RecurrenceMonthID)>
			<cfset RecurrenceMonthIDs=ListAppend(RecurrenceMonthIDs,RecurrenceMonthID)>
		</cfif>
	</cfif>
</cfoutput>
<cfif Len(ListingIDs)>
	<cfquery name="GetAllLocationTitles"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.Title as Location, LL.ListingID
		From ListingLocations LL With (NoLock)
		Inner Join Locations L With (NoLock) on LL.LocationID=L.LocationID
		Where LL.ListingID in (<cfqueryparam value="#ListingIDs#" cfsqltype="CF_SQL_INTEGER" list="yes">)
		and L.LocationID <> 4
	</cfquery>
	<cfquery name="GetAllRecurrenceDays"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			select lr.ListingID, lr.RecurrenceDayID, rd.descr, rd.OrderNum
			from ListingRecurrences lr With (NoLock)
			inner join RecurrenceDays rd With (NoLock) ON rd.recurrenceDayID = lr.recurrenceDayID
			where ListingID in (<cfqueryparam value="#ListingIDs#" cfsqltype="CF_SQL_INTEGER" list="yes">)
			Order By OrderNum
	</cfquery>
</cfif>
<cfif Len(RecurrenceMonthIDs)>
	<cfquery name="GetAllRecurrenceMonths"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select RecurrenceMonthID, Descr, Daily
		From RecurrenceMonths With (NoLock) 
		Where recurrenceMonthID IN (<cfqueryparam value="#RecurrenceMonthIDs#" cfsqltype="CF_SQL_INTEGER" list="yes">)
	</cfquery>
</cfif>
<cfif ShowFeaturedListings>
	<!--- Output just the Featured Listings --->
	<cfquery name="getFeaturedListings" dbtype="query">
		Select *
		From getListings
		Where HasExpandedListing = 1
		Order By QLineID, HasExpandedListing desc, PhoneOnlyListing_fl, RandOrderID
	</cfquery>
	<cfif getFeaturedListings.RecordCount and StartRow lte getFeaturedListings.RecordCount>
		<cfoutput>
				<cfset FeaturedOpen="1">
				<div class="float-left"> <h3 class="h3Featured">Featured <cfif CategoryResults>#getCategory.H1Text#<cfelseif Len(ResultsLabel)>#ResultsLabel#<cfelse>Listings</cfif></h3></div>			
				<cfif ShowPagination>
					#PaginationString#
					<cfset ShowPagination="0">
				</cfif>
				<div class="clear"></div>
				<div class="promo-upcomingspecialevents-inner">
					<ul class="dining-skin-tango">
		</cfoutput>
		<cfoutput query="getFeaturedListings" startrow="#StartRow#" maxrows="#Request.RowsPerPage#">
			<cfset ListingCounter=ListingCounter+1>
				
			<cfif not IsDefined('application.ListingResultsPageImpressions')>
				<cfset application.ListingResultsPageImpressions= structNew()>
			</cfif>
			<cfif StructKeyExists(application.ListingResultsPageImpressions,ListingID)>
				<cfset application.ListingResultsPageImpressions[ListingID] = application.ListingResultsPageImpressions[ListingID] + 1>
			<cfelse>
				<cfset application.ListingResultsPageImpressions[ListingID] = 1>
			</cfif>
				
			<cfquery name="GetLocationTitles" dbtype="query">
				Select Location
				From GetAllLocationTitles
				Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
				Order by Location
			</cfquery>	
			<cfset LocationTitles=ValueList(getLocationTitles.Location)>
			<cfset LocationOutput="">
			<cfset LocationOutput=LocationTitles>
			<cfif Len(LocationOther)>
				<cfset LocationOutput=ListAppend(LocationOutput,LocationOther)>
			</cfif>
			<cfset LocationOutput=Replace(LocationOutput,",",", ","ALL")>
			
			<cfset ShowTN="0">
			<cfif ShowDividers>
				<cfif not FeaturedOpen>
					<cfset FeaturedOpen="1">
					<div class="float-left"> <h3 class="h3Featured">Featured <cfif CategoryResults>#getCategory.H1Text#<cfelseif Len(ResultsLabel)>#ResultsLabel#<cfelse>Listings</cfif></h3></div>			
					<cfif ShowPagination>
						#PaginationString#
						<cfset ShowPagination="0">
					</cfif>
					<div class="clear"></div>
					<div class="promo-upcomingspecialevents-inner">
						<ul class="dining-skin-tango">				
				</cfif>		
			</cfif>
			
			<cfif Len(ELPTypeThumbnailImage)>
				<cfset FeaturedTN=Replace(ELPTypeThumbnailImage,'.jp','Two.jp')>
				<cfset FeaturedTN=Replace(FeaturedTN,'.gif','Two.gif')>
				<cfset FeaturedTN=Replace(FeaturedTN,'.png','Two.png')>
			</cfif>
			
			<!--- Only 1, 2, 9 and 14 can possibly have Featured Listings  --->
			<cfswitch expression="#ListingTypeID#">		
			
				<cfcase value="1,2,14,20"><!--- BUS 1, BUS 2 (Restaurant), Community --->
					<cfif AmpOrQuestion is "?">
						<cfset ListingLink=REReplace(Replace(Replace(ListingTitle," - ","-","All")," ","-","All"), "[^a-zA-Z0-9\-]","","all")>
					<cfelse>
						<cfset ListingLink="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">
					</cfif>			
					<li> 
						<cfif HasExpandedListing>						 	
						 	<cfif ParentSectionID is "21" and not ListFind("93,325,335",CategoryID) and ELPThumbnailFromDoc is "0" and Len(ELPTypeThumbnailImage) and FileExists("#Request.ListingUploadedDocsDir#\#FeaturedTN#")><!--- For most Travel Businesses, show the Featured Image if it was uploaded. --->							
								<a href="#ListingLink#"><img src="ListingUploadedDocs/#FeaturedTN#" alt="#ListingTitle#"></a>
							<cfelseif Len(LogoImage) and FileExists("#Request.ListingUploadedDocsDir#\#LogoImage#")>
								<a href="#ListingLink#"><img src="ListingUploadedDocs/#LogoImage#" alt="#ListingTitle#"></a>
							<cfelseif ShowNoImageTN>
								<a href="#ListingLink#"><img src="../Images/SiteWide/NoImageAvailable.gif" alt="#ListingTitle#"></a>
							</cfif>			
						<cfelseif ShowNoImageTN>
							<a href="#ListingLink#"><img src="../Images/SiteWide/NoImageAvailable.gif" alt="#ListingTitle#"></a>
						</cfif>
		            	<h2><a href="#ListingLink#">#ListingTitle#</a></h2>
						<cfif Len(LocationOutput)><span class="smalltext">#LocationOutput#</span></cfif>
					</li>				
				</cfcase>
				
				<cfcase value="9"><!--- Travel & Tourism (Trip Listings) --->
					<cfset ListingLink="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">
					<li>
						<cfif HasExpandedListing>					 	
						 	<cfif CategoryID neq "94" and ELPThumbnailFromDoc is "0" and Len(ELPTypeThumbnailImage) and FileExists("#Request.ListingUploadedDocsDir#\#FeaturedTN#")><!--- For most Special Travel Offers, show the Featured Image if it was uploaded. --->				
								<a href="#ListingLink#"><img src="ListingUploadedDocs/#FeaturedTN#" alt="#ListingTitle#"></a>
							<cfelseif Len(LogoImage) and FileExists("#Request.ListingUploadedDocsDir#\#LogoImage#")>
								<a href="#ListingLink#"><img src="ListingUploadedDocs/#LogoImage#" alt="#ListingTitle#"></a>
							<cfelse>
								<a href="#ListingLink#"><img src="../Images/SiteWide/NoImageAvailable.gif" alt="#ListingTitle#"></a>
							</cfif> 					
						<cfelse>
							<a href="#ListingLink#"><img src="../Images/SiteWide/NoImageAvailable.gif" alt="#ListingTitle#"></a>
						</cfif>
						<h2><a href="#ListingLink#">#ListingTitle#<cfif Len(PriceUS)> $US&nbsp;#NumberFormat(PriceUS,",")#<cfelseif Len(PriceTZS)> TSH&nbsp;#NumberFormat(PriceTZS,",")#</cfif></a></h2>		
					</li>
				</cfcase>
				
			</cfswitch>
			
			<cfif FeaturedOpen and  ListingCounter is "1" and NumFeaturedListings MOD 2 is 1>
				<li>
					<a href="featured-listing-example"><img width="190" height="109" style="border: none;" alt="Feature Your <cfif getListings.ListingTypeID is "2">Restaurant<cfelseif getListings.ParentSectionID is "9">Community Service<cfelseif ListFind("1,2",getListings.ListingTypeID)>Business<cfelse>Listing</cfif> Here!" src="images/inner/<cfif getListings.ListingTypeID is "2">featureyourrestaurant.gif<cfelseif getListings.ParentSectionID is "9">featureyourcommunitylisting.gif<cfelseif ListFind("1,2",getListings.ListingTypeID)>featureyourbusiness.gif<cfelse>featureyourlisting.gif</cfif>"></a>
				</li>
			</cfif>
		</cfoutput>
	</cfif> 
</cfif>
<!--- Output all the listings, including the Featured listings. --->
<cfif not SearchResults and ListFind("1,2,9,14",getListings.ListingTypeID)>
	<!--- CF Query of Queries will alpha sort like this "A,B,D,C,a,b,c,d" rather than "A,a,B,b,C,c" so the Lower() eliminates that isuue --->
	<cfquery name="getListings" dbtype="query">
		Select 
		<cfloop list="#getListings.ColumnList#" index="i">
			<cfif not ListFindNoCase("PhoneOnlyListing_Fl",i)>
				#i#,
			</cfif>
		</cfloop>
		0 as PhoneOnlyListing_Fl, lower(ListingTitle) as SortTitle
		from getListings
		<cfswitch expression="#SortBy#">
			<cfcase value="Year">
				Order By VehicleYear desc, SortTitle, DateSort desc
			</cfcase>
			<cfcase value="MakeModel">
				<cfif CategoryID is "84">
					Order By SortTitle, Model, VehicleYear, DateSort desc
				<cfelse><!--- Motorcycles, mopeds, etc where Make and Model are open text values --->
					Order By Make, Model, VehicleYear, SortTitle, DateSort desc
				</cfif>
			</cfcase>
			<cfcase value="MostRecent">
				Order By DateSort desc, SortTitle
			</cfcase>
			<cfcase value="EventSort">
				Order By EventSortDate, EventRank, DateSort desc, SortTitle
			</cfcase>
			<cfdefaultcase>
				Order By SortTitle
			</cfdefaultcase>
		</cfswitch>		
	</cfquery>	
</cfif>

<cfoutput query="getListings" startrow="#StartRow#" maxrows="#Request.RowsPerPage#">
	<cfset ListingCounter=ListingCounter+1>
		
	<cfif not IsDefined('application.ListingResultsPageImpressions')>
		<cfset application.ListingResultsPageImpressions= structNew()>
	</cfif>
	<cfif StructKeyExists(application.ListingResultsPageImpressions,ListingID)>
		<cfset application.ListingResultsPageImpressions[ListingID] = application.ListingResultsPageImpressions[ListingID] + 1>
	<cfelse>
		<cfset application.ListingResultsPageImpressions[ListingID] = 1>
	</cfif>
	
	<cfif Len(ListingID)>
		<cfquery name="GetLocationTitles"  dbtype="query">
			Select Location
			From GetAllLocationTitles
			Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			Order by Location
		</cfquery>
		<cfset LocationTitles=ValueList(getLocationTitles.Location)>
		<cfset LocationOutput="">
		<cfset LocationOutput=LocationTitles>
		<cfif Len(LocationOther)>
			<cfset LocationOutput=ListAppend(LocationOutput,LocationOther)>
		</cfif>
		<cfset LocationOutput=Replace(LocationOutput,",",", ","ALL")>		
	</cfif>	
	
	<cfset ShowTN="0">
	<cfif ListFind("3,4,5,6,7,8",ListingTypeID)>		
		<cfif Len(FileNameForTN)>
			<cfif FileExists("#Request.ListingImagesDir#\CategoryThumbnails\#FileNameForTN#")>
				<cfset ShowTN="1">
			<cfelseif FileExists("#Request.ListingImagesDir#\#FileNameForTN#")>
				<cfinclude template="CreateListingImageThumbNail.cfm">
				<cfif FileExists("#Request.ListingImagesDir#\CategoryThumbnails\#FileNameForTN#")>
					<cfset ShowTN="1">
				</cfif>
			</cfif>			
		</cfif>
	</cfif>
	<cfif ShowDividers>
		<cfif not PhoneOnlyListing_Fl and not NonFeaturedOpen>
			<cfset NonFeaturedOpen="1">
			<cfif FeaturedOpen>
				</ul>
				</div>
			</cfif>
			<ul class="dining-nonfeatured">
			<div class="float-left"><h4 class="h4Category"><cfif ListingTypeID neq "9">All </cfif><cfif CategoryResults>#getCategory.H1Text#<cfelseif Len(ResultsLabel)>#ResultsLabel#<cfelse>Listings</cfif></h4></div>
			<cfif FeaturedOpen>
				<cfset FeaturedOpen="0">
			</cfif>
			<cfif ShowPagination>
				#PaginationString#
				<cfset ShowPagination="0">
			</cfif>
			<div class="clear"></div>
		<cfelseif PhoneOnlyListing_Fl and not PhoneOnlyOpen>
			<cfset PhoneOnlyOpen="1">
			<cfif FeaturedOpen>
				<cfset FeaturedOpen="0">
				</ul>
				</div>
			</cfif>
			<cfif NonFeaturedOpen>
				<cfset NonFeaturedOpen="0">
				</ul>
			</cfif>
			<ul class="dining-nonfeatured">
			<div class="float-left"><h4 class="h4Category"><cfif CategoryResults>#getCategory.H1Text#<cfelseif Len(ResultsLabel)>#ResultsLabel#<cfelse>Listings</cfif> (Phone Only)</h4></div>
			<cfif ShowPagination>
				#PaginationString#
				<cfset ShowPagination="0">
			</cfif>
			<div class="clear"></div>
		</cfif>
	<cfelseif ((PageID is Request.SectionOverviewPageID and ListFind("4,5,55",ParentSectionID)) or (PageID is "2" and ListFind("21",ParentSectionID))) and not FeaturedOpen>
		<cfset FeaturedOpen="1">		
		<cfif ShowPagination>
			#PaginationString#
			<cfset ShowPagination="0">
		</cfif>
		<div class="clear"></div>
		<div class="promo-upcomingspecialevents-inner">
			<ul class="dining-skin-tango">
	<cfelseif PageID is Request.SectionOverviewPageID and ListFind("8",ParentSectionID) and not NonFeaturedOpen>
		<cfset NonFeaturedOpen="1">
		<ul class="dining-nonfeatured">
		#PaginationString#
		<div class="clear"></div>
	<cfelseif (PageID is "33" or (PageID is "2" and ListFind("59",ParentSectionID))) and not NonFeaturedOpen>
		<cfset NonFeaturedOpen="1">
		<div class="promo-upcomingspecialevents-inner">
		<ul class="events-skin-tango">
		#PaginationString#
		<div class="clear"></div>
	<cfelseif not FeaturedOpen and not NonFeaturedOpen>
		<cfset NonFeaturedOpen="1">
		<ul class="dining-nonfeatured">
		#PaginationString#
		<div class="clear"></div>
	</cfif>
	
	<cfswitch expression="#ListingTypeID#">		
	
		<cfcase value="0"><!--- CMS Page, Section Page, or CategoryPage --->
			<cfif AmpOrQuestion is "?">
				<cfset ListingLink=REReplace(Replace(Replace(ListingTitle," - ","-","All")," ","-","All"), "[^a-zA-Z0-9\-]","","all")>
			<cfelse>
				<cfset ListingLink="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">
			</cfif>			
			<li> 
            	<h2><a href="#ListingLink#">#ListingTitle#</a></h2>
			</li>				
		</cfcase>
	
		<cfcase value="1,2,14,20"><!--- BUS 1, BUS 2 (Restaurant), Community --->
			<cfif AmpOrQuestion is "?">
				<cfset ListingLink=REReplace(Replace(Replace(ListingTitle," - ","-","All")," ","-","All"), "[^a-zA-Z0-9\-]","","all")>
			<cfelse>
				<cfset ListingLink="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">
			</cfif>			
			<li> 
            	<h2><a href="#ListingLink#">#ListingTitle#</a></h2>
				<cfif Len(LocationOutput)><span class="smalltext">#LocationOutput#</span></cfif>
			</li>				
		</cfcase>
		
		<cfcase value="3"><!--- For Sale by Owner � General --->
			<cfset ListingLink="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">
			<li>
				<a href="#ListingLink#"><img src="<cfif ShowTN>../ListingImages/CategoryThumbnails/#FileNameForTN#<cfelse>../Images/SiteWide/NoImageAvailable.gif</cfif>" alt="#ListingTitle#"></a>
				<h2><a href="#ListingLink#">#ListingTitle# <cfif Len(PriceUS)> $US&nbsp;#NumberFormat(PriceUS,",")#<cfelseif Len(PriceTZS)> TSH&nbsp;#NumberFormat(PriceTZS,",")#</cfif></a></h2>
				<cfif Len(LocationOutput)><span class="smalltext">#LocationOutput#</span></cfif>
			</li>
		</cfcase>
		
		<cfcase value="4"><!--- For Sale by Owner � Cars & Trucks --->
			<cfset ListingLink="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">
			<li>
				<a href="#ListingLink#"><img src="<cfif ShowTN>../ListingImages/CategoryThumbnails/#FileNameForTN#<cfelse>../Images/SiteWide/NoImageAvailable.gif</cfif>" alt="#VehicleYear#<cfif MakeID is "1" and Len(MakeOther)> #MakeOther#<cfelse> #Make#</cfif> #ModelOther#"></a>
				<h2><a href="#ListingLink#">#VehicleYear#<cfif MakeID is "1" and Len(MakeOther)> #MakeOther#<cfelse> #Make#</cfif> #ModelOther#<cfif Len(PriceUS)> $US&nbsp;#NumberFormat(PriceUS,",")#<cfelseif Len(PriceTZS)> TSH&nbsp;#NumberFormat(PriceTZS,",")#</cfif></a></h2>
				<cfif Len(LocationOutput)><span class="smalltext">#LocationOutput#</span></cfif>
			</li>		
		</cfcase>
		
		<cfcase value="5"><!--- FSBO Motorcycles, Mopeds, ATVs, & Vibajaji & FSBO Commercial Trucks --->
			<cfset ListingLink="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">
			<li>
				<a href="#ListingLink#"><img src="<cfif ShowTN>../ListingImages/CategoryThumbnails/#FileNameForTN#<cfelse>../Images/SiteWide/NoImageAvailable.gif</cfif>" alt="#VehicleYear#<cfif Len(MakeOther)>&nbsp;#MakeOther#</cfif><cfif Len(ModelOther)>&nbsp;#ModelOther#</cfif>"></a>
				<h2><a href="#ListingLink#">#VehicleYear#<cfif Len(MakeOther)>&nbsp;#MakeOther#</cfif><cfif Len(ModelOther)>&nbsp;#ModelOther#</cfif><cfif Len(PriceUS)> $US&nbsp;#NumberFormat(PriceUS,",")#<cfelseif Len(PriceTZS)> TSH&nbsp;#NumberFormat(PriceTZS,",")#</cfif></a></h2>
				<cfif Len(LocationOutput)><span class="smalltext">#LocationOutput#</span></cfif>
			</li>				
		</cfcase>
		
		<cfcase value="6"><!--- Housing & Real Estate Housing Rentals --->
			<cfset ListingLink="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">
			<li>
				<a href="#ListingLink#"><img src="<cfif ShowTN>../ListingImages/CategoryThumbnails/#FileNameForTN#<cfelse>../Images/SiteWide/NoImageAvailable.gif</cfif>" alt="#ListingTitle#"></a>
				<h2><a href="#ListingLink#">#ListingTitle#</a><cfif Len(RentUS)> $US&nbsp;#NumberFormat(RentUS,",")#<cfif Len(Term)>/#Term#</cfif> <cfelseif Len(RentTZS)> TSH&nbsp;#NumberFormat(RentTZS,",")#<cfif Len(Term)>/#Term#</cfif></cfif></h2>
				<cfif Len(LocationOutput)><span class="smalltext">#LocationOutput#</span></cfif>
			</li>
		</cfcase>
		
		<cfcase value="7"><!--- Housing & Real Estate Commercial Rentals --->
			<cfset ListingLink="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">
			<cfif Len(SquareFeet) or Len(SquareMeters)>
				<cfif Len(SquareFeet)>
					<cfset LocalSquareFeet=SquareFeet>
					<cfset LocalSquareMeters=0.092903*SquareFeet>
				<cfelse>
					<cfset LocalSquareMeters=SquareMeters>
					<cfset LocalSquareFeet=10.7639*SquareMeters>
				</cfif>
			</cfif>
			<li>
				<a href="#ListingLink#"><img src="<cfif ShowTN>../ListingImages/CategoryThumbnails/#FileNameForTN#<cfelse>../Images/SiteWide/NoImageAvailable.gif</cfif>" alt="#ListingTitle#"></a>
				<h2><a href="#ListingLink#">#ListingTitle#<cfif Len(SquareFeet) or Len(SquareMeters)> <span class="nowrap">#Round(LocalSquareFeet)# ft<sup>2</sup>/#NumberFormat(LocalSquareMeters,",.9")# m<sup>2</sup></span></cfif></a> <span class="nowrap"><cfif Len(RentUS)> $US&nbsp;#NumberFormat(RentUS,",")#<cfif Len(Term)>/#Term#</cfif> <cfelseif Len(RentTZS)> TSH&nbsp;#NumberFormat(RentTZS,",")#<cfif Len(Term)>/#Term#</cfif> </cfif></h2>
				<cfif Len(LocationOutput)><span class="smalltext">#LocationOutput#</span></cfif>
			</li>
		</cfcase>
		
		<cfcase value="8"><!--- Housing & Real Estate For Sale --->
			<cfset ListingLink="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">
			<li>
				<a href="#ListingLink#"><img src="<cfif ShowTN>../ListingImages/CategoryThumbnails/#FileNameForTN#<cfelse>../Images/SiteWide/NoImageAvailable.gif</cfif>" alt="#ListingTitle#"></a>
				<h2><a href="#ListingLink#">#ListingTitle#</a><cfif Len(PriceUS)> $US&nbsp;#NumberFormat(PriceUS,",")#<cfelseif Len(PriceTZS)> TSH&nbsp;#NumberFormat(PriceTZS,",")#</cfif></h2>
				<cfif Len(LocationOutput)><span class="smalltext">#LocationOutput#</span></cfif>
			</li>
		</cfcase>
		
		<cfcase value="9"><!--- Travel & Tourism (Trip Listings) --->
			<cfset ListingLink="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">
			<li>
				<h2><a href="#ListingLink#">#ListingTitle#<cfif Len(PriceUS)> $US&nbsp;#NumberFormat(PriceUS,",")#<cfelseif Len(PriceTZS)> TSH&nbsp;#NumberFormat(PriceTZS,",")#</cfif></a></h2>
				<cfif HasExpandedListing>
					<cfset ShowELPTypeThumbnailImage="">
					<cfif Len(ELPTypeThumbNailImage)>
						<!--- Use the smaller TN --->
						<cfset TNImage=ReplaceNoCase(ELPTypeThumbNailImage,'.jp','Two.jp','All')>
						<cfset TNImage=ReplaceNoCase(TNImage,'.png','Two.png','All')>
						<cfset TNImage=ReplaceNoCase(TNImage,'gif','Two.gif','All')>
						<cfset ShowELPTypeThumbnailImage=TNImage>
					</cfif>							
					<cfif Len(ExpandedListingPDF) and FileExists("#Request.ListingUploadedDocsDir#\#ExpandedListingPDF#") and (not Len(ELPTypeThumbnailImage) or not FileExists("#Request.ListingUploadedDocsDir#\#TNImage#"))>
						<cfinclude template="createELPThumbnail.cfm">
						<cfset ShowELPTypeThumbNailImage=ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(ShowELPTypeThumbNailImage,'.jp','Two.jp'),'.gi','Two.gi'),'.pn','Two.pn')>
					</cfif>
					
					<cfif Len(ShowELPTypeThumbNailImage) and FileExists("#Request.ListingUploadedDocsDir#\#ShowELPTypeThumbNailImage#")>
						<a href="#ListingLink#"><img src="ListingUploadedDocs/#ShowELPTypeThumbNailImage#" width="100" align="center" class="grayBorderImg" alt="#ListingTitle#"></a>
					<!--- <cfelse>
						<a href="#ListingLink#"><img src="../Images/SiteWide/NoImageAvailableHPE.gif" align="center" class="grayBorderImg" alt="#ListingTitle#"></a> --->
					</cfif>										
				<!--- <cfelse>
					<a href="#ListingLink#"><img src="../Images/SiteWide/NoImageAvailableHPE.gif" height="142" align="center" class="grayBorderImg" alt="#ListingTitle#"></a> --->
				</cfif>
				</li>
		</cfcase>
		
		<cfcase value="10"><!--- Jobs & Employment Professional (employment opportunities) --->
			<li>
			 	<h2><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">#ShortDescr#</a></h2>
				#ListingTitle#
				<cfif Len(Deadline)><br />Deadline:&nbsp;#DateFormat(Deadline,"mmm dd, yyyy")#</cfif>
			</li>	
		</cfcase>
		
		<cfcase value="11"><!--- Jobs & Employment Professional (seeking employment) --->
			<li>
			 <h2><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">#ListingTitle#</a></h2>
			 	<cfif Len(ShortDescr)>
					<cfset LocalShortDescr=Trim(ShortDescr)>
					<cfif Left(LocalShortDescr,3) is "<p>">
						<cfset LocalShortDescr=RemoveChars(LocalShortDescr,1,3)>
					</cfif>
				 	<cfif ListLen(LocalShortDescr," ") gt 41><cfloop from="1" to="40" index="i"> #ListGetAt(LocalShortDescr,i," ")#</cfloop>...<cfelse> #LocalShortDescr#</cfif>
				</cfif>
			</li>
		</cfcase>
		
		<cfcase value="12"><!--- Jobs & Employment Domestic Staff (employment opportunities) --->
			 <li>
			 	<h2><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">#ShortDescr#</a></h2>
				<cfif Len(Deadline)><br />Deadline:&nbsp;#DateFormat(Deadline,"mmm dd, yyyy")#</cfif>
			</li>
		</cfcase>
		
		<cfcase value="13"><!--- Jobs & Employment Domestic Staff (seeking employment) --->
			<li>
				<h2><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">#ListingTitle#</a></h2>
			 	<cfif Len(ShortDescr)>
					<cfset LocalShortDescr=Trim(ShortDescr)>
					<cfif Left(LocalShortDescr,3) is "<p>">
						<cfset LocalShortDescr=RemoveChars(LocalShortDescr,1,3)>
					</cfif>
				 	<cfif ListLen(LocalShortDescr," ") gt 41><cfloop from="1" to="40" index="i"> #ListGetAt(LocalShortDescr,i," ")#</cfloop>...<cfelse> #LocalShortDescr#</cfif>
				</cfif>
			</li>
		</cfcase>
		
		<cfcase value="15"><!--- Events --->
			<!--- <cfif EventCategory> --->
				<cfif Len(RecurrenceID)>	
				 	<cfif ListFind("1,2",RecurrenceID)>
						<cfquery name="getRecurrenceDays"  dbtype="query">
							select RecurrenceDayID, descr
							from GetAllRecurrenceDays
							where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
							Order By OrderNum
						</cfquery>
					</cfif>
					<cfsavecontent variable="EventDateString">
					<cfswitch expression="#RecurrenceID#">	
						<cfcase value="1">
							Weekly on #Replace(ValueList(getRecurrenceDays.descr),',',', ','ALL')#
						</cfcase>
						<cfcase value="2">
							Every other week on #Replace(ValueList(getRecurrenceDays.descr),',',', ','ALL')#
						</cfcase>
						<cfcase value="3">
							<cfquery name="getRecurrenceMonth"  dbtype="query">
								select descr, daily
								from GetAllRecurrenceMonths
								where recurrenceMonthID = <cfqueryparam value="#RecurrenceMonthID#" cfsqltype="CF_SQL_INTEGER">			
							</cfquery>
							Monthly on the #ReplaceNoCase(getRecurrenceMonth.descr,"5th","Last")# of Each Month
						</cfcase>	
					</cfswitch>
					</cfsavecontent>
				<cfelse>
					<cfsavecontent variable="EventDateString">#DateFormat(StartDate,'mmm')#&nbsp;#DateFormat(StartDate,'d')#<cfif Len(EndDate) and StartDate neq EndDate>&nbsp;&ndash;&nbsp;<cfif #DateFormat(StartDate,'mmm')# neq DateFormat(EndDate,'mmm')>#DateFormat(EndDate,'mmm')#&nbsp;</cfif>#DateFormat(EndDate,'d')#</cfif></cfsavecontent>
				</cfif>
				
				<cfset EventDateLen=Len(EventDateString)>
  				<cfset ListingTitleTrunc=Request.ListingTitleTrunc>
				<cfset ListingTitleTrunc=ListingTitleTrunc-EventDateLen>
				<li><h2><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">#Left(ListingTitle,ListingTitleTrunc)#<cfif Len(ListingTitle) gt ListingTitleTrunc>#ListFirst(RemoveChars(ListingTitle,1,ListingTitleTrunc)," ")#...</cfif></a> <em>#EventDateString#</em></h2>
				<cfif HasExpandedListing>
					<cfset ShowELPTypeThumbnailImage="">
					<cfif Len(ELPTypeThumbNailImage)>
						<!--- Use the smaller TN --->
						<cfset TNImage=ReplaceNoCase(ELPTypeThumbNailImage,'.jp','Two.jp','All')>
						<cfset TNImage=ReplaceNoCase(TNImage,'.png','Two.png','All')>
						<cfset TNImage=ReplaceNoCase(TNImage,'gif','Two.gif','All')>
						<cfset ShowELPTypeThumbnailImage=TNImage>
					</cfif>							
					<cfif Len(ExpandedListingPDF) and FileExists("#Request.ListingUploadedDocsDir#\#ExpandedListingPDF#") and (not Len(ELPTypeThumbnailImage) or not FileExists("#Request.ListingUploadedDocsDir#\#TNImage#"))>
						<cfinclude template="createELPThumbnail.cfm">
						<cfset ShowELPTypeThumbNailImage=ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(ShowELPTypeThumbNailImage,'.jp','Two.jp'),'.gi','Two.gi'),'.pn','Two.pn')>
					</cfif>					
					<cfif Len(ShowELPTypeThumbNailImage) and FileExists("#Request.ListingUploadedDocsDir#\#ShowELPTypeThumbNailImage#")>
						<a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#"><img src="ListingUploadedDocs/#ShowELPTypeThumbNailImage#" width="100" align="center" class="grayBorderImg" alt="#ListingTitle#"></a><br>
					<cfelseif not SearchResults>
						<a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#"><img src="../Images/SiteWide/NoImageAvailableHPE.gif" align="center" class="grayBorderImg" alt="#ListingTitle#"></a><br>
					</cfif>										
				<cfelseif not SearchResults>
					<a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#"><img src="../Images/SiteWide/NoImageAvailableHPE.gif" height="142" align="center" class="grayBorderImg" alt="#ListingTitle#"></a><br>
				</cfif>
				<cfif SearchResults and Len(LocationOutput)><span class="smalltext">#LocationOutput#</span><br></cfif>
				</li>
			<!--- <cfelse><!--- Event appearing in general site search --->
				<cfset ListingLink="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">
				<li>
					<cfif HasExpandedListing>
						<cfset ShowELPTypeThumbnailImage="">
						<cfif Len(ELPTypeThumbNailImage)>
							<!--- Use the smaller TN --->
							<cfset TNImage=ReplaceNoCase(ELPTypeThumbNailImage,'.jp','Two.jp','All')>
							<cfset TNImage=ReplaceNoCase(TNImage,'.png','Two.png','All')>
							<cfset TNImage=ReplaceNoCase(TNImage,'gif','Two.gif','All')>
							<cfset ShowELPTypeThumbnailImage=TNImage>
						</cfif>							
						<cfif Len(ExpandedListingPDF) and FileExists("#Request.ListingUploadedDocsDir#\#ExpandedListingPDF#") and (not Len(ELPTypeThumbnailImage) or not FileExists("#Request.ListingUploadedDocsDir#\#TNImage#"))>
							<cfinclude template="createELPThumbnail.cfm">
							<cfset ShowELPTypeThumbNailImage=ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(ShowELPTypeThumbNailImage,'.jp','Two.jp'),'.gi','Two.gi'),'.pn','Two.pn')>
						</cfif>
						<cfif Len(ShowELPTypeThumbNailImage) and FileExists("#Request.ListingUploadedDocsDir#\#ShowELPTypeThumbNailImage#")>
							<a href="#ListingLink#"><img src="ListingUploadedDocs/#ShowELPTypeThumbNailImage#" alt="#ListingTitle#"></a>
						</cfif>
					</cfif>
					<h2><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">#ListingTitle#</a></h2>
						<cfif Len(RecurrenceID)>	
						 	<cfif ListFind("1,2",RecurrenceID)>
								<cfquery name="getRecurrenceDays"  dbtype="query">
									select RecurrenceDayID, descr
									from GetAllRecurrenceDays
									where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
									Order By OrderNum
								</cfquery>
							</cfif>
							<cfswitch expression="#RecurrenceID#">	
								<cfcase value="1">
									Weekly on #Replace(ValueList(getRecurrenceDays.descr),',',', ','ALL')#
								</cfcase>
								<cfcase value="2">
									Every other week on #Replace(ValueList(getRecurrenceDays.descr),',',', ','ALL')#
								</cfcase>
								<cfcase value="3">
									<cfquery name="getRecurrenceMonth"  dbtype="query">
										select descr, daily
										from GetAllRecurrenceMonths
										where recurrenceMonthID = <cfqueryparam value="#RecurrenceMonthID#" cfsqltype="CF_SQL_INTEGER">			
									</cfquery>
									Monthly on the #ReplaceNoCase(getRecurrenceMonth.descr,"5th","Last")# of Each Month
								</cfcase>	
							</cfswitch>
						<cfelse>
							#DateFormat(EventStartDate,"mmm dd, yyyy")#<cfif Len(EventEndDate)> - #DateFormat(EventEndDate,"mmm dd, yyyy")#</cfif>
						</cfif>
						<cfif Len(LocationOutput)><br><span class="smalltext">#LocationOutput#</span></cfif>
				</li>			
			</cfif> --->	
		</cfcase>		
	</cfswitch>
</cfoutput>
	
<cfif FeaturedOpen>
	<cfset FeaturedOpen="0">
	</ul>
	</div>
</cfif>
<cfif NonFeaturedOpen>
	<cfset NonFeaturedOpen="0">
	</ul>
	<cfif PageID is "33" or (PageID is "2" and ListFind("59",ParentSectionID))>
		</div>
	</cfif>
</cfif>
<cfif PhoneOnlyOpen>
	<cfset PhoneOnlyOpen="0">
	</ul>
</cfif>
<cfoutput>#PaginationString#</cfoutput><div class="clear"></div>
