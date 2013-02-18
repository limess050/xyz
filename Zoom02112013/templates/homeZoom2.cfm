<!---
Home page template
Use this if the home page is different from the default template
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfparam name="HomepageJobsCount" default="1">
<cfparam name="HomepageFSBONonVehicleCount" default="1">
<cfparam name="HomepageFSBOVehicleCount" default="1">
<cfparam name="HomepageHRCount" default="1">
<cfparam name="JAndELinkName" default="">
<cfparam name="FSBOLinkName" default="">
<cfparam name="HAndRLinkName" default="">

<cfif not IsDefined('application.SectionImpressions')>
	<cfset application.SectionImpressions= structNew()>
</cfif>
<cfif StructKeyExists(application.SectionImpressions,0)>
	<cfset application.SectionImpressions[0] = application.SectionImpressions[0] + 1>
<cfelse>
	<cfset application.SectionImpressions[0] = 1>
</cfif>
<cfset ImpressionSectionID = 0>

<cfinclude template="header.cfm">

<cfoutput query="Sections">
	<cfif ParentSectionID is "8">
		<cfset JAndELinkName=ParentSectionURLSafeTitle>
	<cfelseif ParentSectionID is "4">
		<cfset FSBOLinkName=ParentSectionURLSafeTitle>
	<cfelseif ParentSectionID is "5">
		<cfset HAndRLinkName=ParentSectionURLSafeTitle>
	</cfif>
</cfoutput>

<cfquery name="getHomepageJobs" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#" cachedwithin="#createtimespan(0,0,5,0)#">
	Select Top #HomepageJobsCount# L.ListingID, L.ListingTitle, L.ShortDescr, L.Deadline, L.LocationOther,
	(Select Top 1 Title From Locations Lo With (NoLock) Inner Join ListingLocations LL With (NoLock) on Lo.LocationID=LL.LocationID Where LL.ListingID = L.ListingID and Lo.LocationID <> 4) as Location
	From ListingsView L With (NoLock)
	Where L.ListingTypeID = 10
	<cfinclude template="../includes/LiveListingFilter.cfm">
	Order by DateSort desc
</cfquery>

<cfquery name="getHomepageFSBO" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#" cachedwithin="#createtimespan(0,0,5,0)#">
	Select Top #HomepageFSBONonVehicleCount# L.ListingID, L.ListingTitle, L.ShortDescr, L.PriceUS, L.PriceTZS, L.ListingTypeID, L.LocationOther,
	(Select Top 1 Title From Locations Lo With (NoLock) Inner Join ListingLocations LL With (NoLock) on Lo.LocationID=LL.LocationID Where LL.ListingID = L.ListingID and Lo.LocationID <> 4) as Location,
	(Select Top 1 FileName
			From ListingImages With (NoLock)
			Where ListingID=L.ListingID
			Order By OrderNum, ListingImageID) as FileNameForTN
	From ListingsView L With (NoLock)
	Where L.ListingTypeID in (3,4,5)
	and exists (Select ListingID from ListingParentSections With (NoLock) Where ListingID=L.ListingID and ParentSectionID<>55)	
	and exists (Select ListingID from ListingImages With (NoLock) Where ListingID=L.ListingID)
	<cfinclude template="../includes/LiveListingFilter.cfm">
	Order by DateSort desc
</cfquery>

<cfquery name="getHomepageFSBOVehicles" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#" cachedwithin="#createtimespan(0,0,5,0)#">
	Select Top #HomepageFSBOVehicleCount# L.ListingID, L.ListingTitle, L.ShortDescr, L.PriceUS, L.PriceTZS, L.ListingTypeID, L.LocationOther,
	(Select Top 1 Title From Locations Lo With (NoLock) Inner Join ListingLocations LL With (NoLock) on Lo.LocationID=LL.LocationID Where LL.ListingID = L.ListingID and Lo.LocationID <> 4) as Location,
	(Select Top 1 FileName
			From ListingImages With (NoLock)
			Where ListingID=L.ListingID
			Order By OrderNum, ListingImageID) as FileNameForTN
	From ListingsView L With (NoLock)
	Where L.ListingTypeID in (3,4,5)
	and exists (Select ListingID from ListingParentSections Where ListingID=L.ListingID and ParentSectionID=55)
	and exists (Select ListingID from ListingImages Where ListingID=L.ListingID)
	<cfinclude template="../includes/LiveListingFilter.cfm">	
	Order by DateSort desc
</cfquery>

<cfquery name="getHomepageHR" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#" cachedwithin="#createtimespan(0,0,5,0)#">
	Select Top #HomepageHRCount# L.ListingID, L.ListingTitle, L.ShortDescr, L.PriceUS, L.PriceTZS, L.RentUS, L.RentTZS, L.ListingTypeID, L.LocationOther,
	(Select Top 1 Title From Locations Lo With (NoLock) Inner Join ListingLocations LL With (NoLock) on Lo.LocationID=LL.LocationID Where LL.ListingID = L.ListingID and Lo.LocationID <> 4) as Location,
	T.Title as Term,
	(Select Top 1 FileName
			From ListingImages With (NoLock)
			Where ListingID=L.ListingID
			Order By OrderNum, ListingImageID) as FileNameForTN
	From ListingsView L With (NoLock)
	Left Outer Join Terms T With (NoLock) on L.TermID=T.TermID
	Where L.ListingTypeID  in (6,7,8)
	and exists (Select ListingID from ListingImages With (NoLock) Where ListingID=L.ListingID)
	<cfinclude template="../includes/LiveListingFilter.cfm">
	Order by DateSort desc
</cfquery>


<cfquery name="getHomepageEvents" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#" cachedwithin="#createtimespan(0,0,5,0)#">
	Select L.ListingID, L.ListingTitle, L.EventStartDate, L.RecurrenceID, L.RecurrenceMonthID,
	(Select Min(ListingEventDate) From ListingEventDays With (NoLock) Where ListingID=L.ListingID) as StartDate, (Select Max(ListingEventDate) From ListingEventDays With (NoLock) Where ListingID=L.ListingID) as EndDate,
	<cfinclude template="../includes/EventOrderingColumns.cfm">
	CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ#Then 1 Else 0 END as HasExpandedListing,
	L.ELPTypeThumbnailImage, L.ExpandedListingPDF		
	From ListingsView L With (NoLock)
	Where (
			EXISTS (SELECT ListingID FROM ListingEventDays With (NoLock) WHERE ListingID=L.ListingID AND ListingEventDate >= #application.CurrentDateInTZ#)
			and EXISTS (SELECT ListingID FROM ListingEventDays With (NoLock) WHERE ListingID=L.ListingID and ListingEventDate <=DATEADD(Day,28,DATEDIFF(Day,0,DATEADD(HOUR,3,GETUTCDATE()))))
		)
	and (RecurrenceID  in (3,4) or RecurrenceID is null)
	and L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ#
	<cfinclude template="../includes/LiveListingFilter.cfm">
	Order By EventSortDate, EventRank,  L.ListingTitle			
</cfquery>


		<div class="centercol">
			<!-- HOT JOBS AND FOR SALE BY OWNER -->
			<table width="100%">
				<tr>
					<td width="274" class="promo-homepage" valign="top"><div class="promo-homepagetitle">
						<cfoutput>
						  	<h1><a href="#JAndELinkName#">Tanzania Jobs</a></h1>
						</cfoutput>
			   			</div>
						<cfoutput query="getHomepageJobs">
							<div class="promo-homepagetext"><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">#ShortDescr#</a>
								<hr />
								<cfif Len(Deadline)><em>Deadline: #DateFormat(Deadline,'dd/mm/yyyy')#</em> - </cfif>#ListingTitle#								
								<cfif Len(Location) or Len(LocationOther)>
								<br>#Location#<cfif Len(Location) and len(LocationOther)>, </cfif>#LocationOther#
								</cfif>
							</div>
						</cfoutput>
					</td>
					<td width="5">&nbsp;</td>
					<td width="274" class="promo-homepage" valign="top">
						<div class="promo-homepagetitle">
							<cfoutput>
						  		<h1><a href="#FSBOLinkName#">For Sale By Owner</a></h1>
							</cfoutput>
			    		</div>
						<cfoutput query="getHomepageFSBO">
							<cfset ShowTN="0">
							<cfif Len(FileNameForTN)>
								<cfif FileExists("#Request.ListingImagesDir#\HomepageThumbnails\#FileNameForTN#")>
									<cfset ShowTN="1">
								<cfelseif FileExists("#Request.ListingImagesDir#\#FileNameForTN#")>
									<cfinclude template="../includes/CreateHomepageThumbNail.cfm">
									<cfif FileExists("#Request.ListingImagesDir#\HomepageThumbnails\#FileNameForTN#")>
										<cfset ShowTN="1">
									</cfif>
								</cfif>			
							</cfif>
							<table width="100%" border="0">
								<tr>
									<td><div class="promo-homepagetext"><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#"><img src="<cfif ShowTN and FileExists("#Request.ListingImagesDir#\#FileNameForTN#")>ListingImages/HomepageThumbnails/#FileNameForTN#<cfelse>Images/SiteWide/NoImageAvailableHP.gif</cfif>" alt="#ListingTitle#" width="60" /></a></div></td>
									<td><div class="promo-homepagetext"><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">#ListingTitle#</a><br><cfif Len(PriceUS)>$US&nbsp;#NumberFormat(PriceUS,",")#<cfelseif Len(PriceTZS)>TSH&nbsp;#NumberFormat(PriceTZS,",")#</cfif>								
										<cfif Len(Location) or Len(LocationOther)>
										<br>#Location#<cfif Len(Location) and len(LocationOther)>, </cfif>#LocationOther#
										</cfif>
										</div>
									</td>
								</tr>
							</table>
						</cfoutput>
					</td>
				</tr>
				<cfoutput>
				<tr>
					<td class="promo-homepagebuttons"><a href="#JAndELinkName#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-viewalljobs','','images/sitewide/btn.viewall_on.gif',1)"><img src="images/sitewide/btn.viewall_off.gif" alt="View All" name="btn-viewalljobs" width="93" height="20" border="0" id="btn-viewalljobs" /></a><a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=8&ListingSectionID=19&ListingTypeID=10" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-postforfreejobs','','images/sitewide/btn.postforfree_on.gif',1)"><img src="images/sitewide/btn.postforfree_off.gif" alt="Post for Free" name="btn-postforfreejobs" width="164" height="20" border="0" id="btn-postforfreejobs" /></a></td>
					<td width="5">&nbsp;</td>
					<td class="promo-homepagebuttons"><a href="#FSBOLinkName#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-viewallforsalebyowner','','images/sitewide/btn.viewall_on.gif',1)"><img src="images/sitewide/btn.viewall_off.gif" alt="View All" name="btn-viewallforsalebyowner" width="93" height="20" border="0" id="btn-viewallforsalebyowner" /></a><a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=4" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-postforforsalebyowner','','images/sitewide/btn.postforfree_on.gif',1)"><img src="images/sitewide/btn.postforfree_off.gif" alt="Post for Free" name="btn-postforforsalebyowner" width="164" height="20" border="0" id="btn-postforforsalebyowner" /></a></td>
				</tr>
				</cfoutput>
			</table>
			<!-- CARS/TRUCKS/BOATS AND REAL ESTATE -->
			<table width="100%">
				<tr>
					<td width="274" class="promo-homepage" valign="top">
						<div class="promo-homepagetitle">
							<cfoutput>
						  		<h1><a href="Used-Cars-Trucks-and-Boats">Cars, Trucks &amp; Boats</a></h1>
							</cfoutput>
			    		</div>
						
						<cfoutput query="getHomepageFSBOVehicles">
							<cfset ShowTN="0">
							<cfif Len(FileNameForTN)>
								<cfif FileExists("#Request.ListingImagesDir#\HomepageThumbnails\#FileNameForTN#")>
									<cfset ShowTN="1">
								<cfelseif FileExists("#Request.ListingImagesDir#\#FileNameForTN#")>
									<cfinclude template="../includes/CreateHomepageThumbNail.cfm">
									<cfif FileExists("#Request.ListingImagesDir#\HomepageThumbnails\#FileNameForTN#")>
										<cfset ShowTN="1">
									</cfif>
								</cfif>			
							</cfif>
							<table width="100%" border="0">
								<tr>
									<td><div class="promo-homepagetext"><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#"><img src="<cfif ShowTN and FileExists("#Request.ListingImagesDir#\#FileNameForTN#")>ListingImages/HomepageThumbnails/#FileNameForTN#<cfelse>Images/SiteWide/NoImageAvailableHP.gif</cfif>" alt="#ListingTitle#" width="60" /></a></div></td>
									<td><div class="promo-homepagetext"><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">#ListingTitle#</a><br><cfif Len(PriceUS)>$US&nbsp;#NumberFormat(PriceUS,",")#<cfelseif Len(PriceTZS)>TSH&nbsp;#NumberFormat(PriceTZS,",")#</cfif>										
										<cfif Len(Location) or Len(LocationOther)>
										<br>#Location#<cfif Len(Location) and len(LocationOther)>, </cfif>#LocationOther#
										</cfif>
										</div>
									</td>
								</tr>
							</table>
						</cfoutput>
					</td>
					<td width="5">&nbsp;</td>
					<td width="274" class="promo-homepage" valign="top">
						<div class="promo-homepagetitle">
							<cfoutput>
						  		<h1><a href="#HAndRLinkName#">Tanzania Real Estate</a></h1>
							</cfoutput>
			    		</div>
						<cfoutput query="getHomepageHR">
							<cfset ShowTN="0">
							<cfif Len(FileNameForTN)>
								<cfif FileExists("#Request.ListingImagesDir#\HomepageThumbnails\#FileNameForTN#")>
									<cfset ShowTN="1">
								<cfelseif FileExists("#Request.ListingImagesDir#\#FileNameForTN#")>
									<cfinclude template="../includes/CreateHomepageThumbNail.cfm">
									<cfif FileExists("#Request.ListingImagesDir#\HomepageThumbnails\#FileNameForTN#")>
										<cfset ShowTN="1">
									</cfif>
								</cfif>			
							</cfif>
							<table width="100%" border="0">
								<tr>
									<td><div class="promo-homepagetext"><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#"><img src="<cfif ShowTN and FileExists("#Request.ListingImagesDir#\#FileNameForTN#")>ListingImages/HomepageThumbnails/#FileNameForTN#<cfelse>Images/SiteWide/NoImageAvailableHP.gif</cfif>" alt="#ListingTitle#" width="60" /></a></div></td>
									<td><div class="promo-homepagetext"><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">#ListingTitle#</a> <br />
										<cfswitch expression="#ListingTypeID#">
											<cfcase value="6,7">
												<cfif Len(RentUS)>$US&nbsp;#NumberFormat(RentUS,",")#<cfif Len(Term)>/#Term#</cfif>,<cfelseif Len(RentTZS)>TSH&nbsp;#NumberFormat(RentTZS,",")#<cfif Len(Term)>/#Term#</cfif>,</cfif>
											</cfcase>
											<cfcase value="8">
												<cfif Len(PriceUS)>$US&nbsp;#NumberFormat(PriceUS,",")#<cfelseif Len(PriceTZS)>TSH&nbsp;#NumberFormat(PriceTZS,",")#</cfif>
											</cfcase>
										</cfswitch>
										<cfif Len(Location) or Len(LocationOther)>
										<br>#Location#<cfif Len(Location) and len(LocationOther)>, </cfif>#LocationOther#
										</cfif>
										</div>
									</td>
								</tr>
							</table>
						</cfoutput>
					</td>
				</tr>
				<cfoutput>
				<tr>
					<td class="promo-homepagebuttons"><a href="Used-Cars-Trucks-and-Boats" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-viewallauto','','images/sitewide/btn.viewall_on.gif',1)"><img src="images/sitewide/btn.viewall_off.gif" alt="View All" name="btn-viewallauto" width="93" height="20" border="0" id="btn-viewallauto" /></a><a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=55&ListingSectionID=57&CategoryID=84" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-postforfreeauto','','images/sitewide/btn.postforfree_on.gif',1)"><img src="images/sitewide/btn.postforfree_off.gif" alt="Post for Free" name="btn-postforfreeauto" width="164" height="20" border="0" id="btn-postforfreeauto" /></a></td>
					<td width="5">&nbsp;</td>
					<td class="promo-homepagebuttons"><a href="#HAndRLinkName#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-viewallfortanzania','','images/sitewide/btn.viewall_on.gif',1)"><img src="images/sitewide/btn.viewall_off.gif" alt="View All" name="btn-viewallfortanzania" width="93" height="20" border="0" id="btn-viewallfortanzania" /></a><a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=5" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-postfortanzania','','images/sitewide/btn.postforfree_on.gif',1)"><img src="images/sitewide/btn.postforfree_off.gif" alt="Post for Free" name="btn-postfortanzania" width="164" height="20" border="0" id="btn-postfortanzania" /></a></td>
				</tr>
				</cfoutput>
			</table>
			<!-- UPCOMING SPECIAL EVENTS -->
			<div class="promotitle">
				<cfoutput>
			 		<h2><a href="Tanzania-Events-Calendar">Upcoming Special Events</a></h2>
			  	</cfoutput>
		  </div>
			<!--- If ListingTitle is longer than x, show show x characters of the ListingTitle and the rest of any word that would be truncated, then end with an ellipis. --->
			<div class="promo-upcomingspecialevents">
				<ul id="mycarousel" class="jcarousel-skin-tango">
					<cfoutput query="getHomepageEvents">
						<cfif Len(RecurrenceID)>	
						 	<cfif ListFind("1,2",RecurrenceID)>
								<cfquery name="getRecurrenceDays"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
									select lr.RecurrenceDayID, rd.descr
									from ListingRecurrences lr With (NoLock)
									inner join RecurrenceDays rd With (NoLock) ON rd.recurrenceDayID = lr.recurrenceDayID
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
									<cfquery name="getRecurrenceMonth"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
										select descr, daily
										from RecurrenceMonths With (NoLock)
										where recurrenceMonthID = <cfqueryparam value="#RecurrenceMonthID#" cfsqltype="CF_SQL_INTEGER">			
									</cfquery>
									Monthly on the #ReplaceNoCase(getRecurrenceMonth.descr,"5th","Last")# of Each Month
								</cfcase>	
							</cfswitch>
							</cfsavecontent>
						<cfelse>
							<cfsavecontent variable="EventDateString">#DateFormat(StartDate,'mmm')#&nbsp;#DateFormat(StartDate,'d')#<cfif StartDate neq EndDate>&nbsp;&ndash;&nbsp;<cfif #DateFormat(StartDate,'mmm')# neq DateFormat(EndDate,'mmm')>#DateFormat(EndDate,'mmm')#&nbsp;</cfif>#DateFormat(EndDate,'d')#</cfif></cfsavecontent>
						</cfif>
						<cfset ShowELPTypeThumbnailImage="">
						<cfif Len(ELPTypeThumbNailImage)>
							<cfset ShowELPTypeThumbnailImage=ELPTypeThumbNailImage>
						</cfif>							
						<cfif Len(ExpandedListingPDF) and FileExists("#Request.ListingUploadedDocsDir#\#ExpandedListingPDF#") and (not Len(ELPTypeThumbnailImage) or not FileExists("#Request.ListingUploadedDocsDir#\#ShowELPTypeThumbnailImage#"))>
							<cfinclude template="../includes/createELPThumbnail.cfm">
						</cfif>
						<cfset ShowTN="0">
						<cfif Len(ShowELPTypeThumbnailImage)>
							<cfif FileExists("#Request.ListingImagesDir#\HomepageThumbnails\#ShowELPTypeThumbnailImage#")>
								<cfset ShowTN="1">
							<cfelseif FileExists("#Request.ListingUploadedDocsDir#\#ShowELPTypeThumbnailImage#")>
								<cfset TNLongestSide="100">
								<cfset LIDir=Request.ListingUploadedDocsDir>
								<cfset FileNameForTN=ShowELPTypeThumbnailImage>
								<cfinclude template="../includes/CreateHomepageThumbNail.cfm">
								<cfif FileExists("#Request.ListingImagesDir#\HomepageThumbnails\#FileNameForTN#")>
									<cfset ShowTN="1">
								</cfif>
							</cfif>			
						</cfif>
						<cfset EventDateLen=Len(EventDateString)>
		  				<cfset ListingTitleTrunc=Request.ListingTitleTrunc>
						<cfset ListingTitleTrunc=ListingTitleTrunc-EventDateLen>
						<cfif showTN>
							<li><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">#Left(ListingTitle,ListingTitleTrunc)#<cfif Len(ListingTitle) gt ListingTitleTrunc>#ListFirst(RemoveChars(ListingTitle,1,ListingTitleTrunc)," ")#...</cfif></a> <em>#EventDateString#</em>	<br /><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#"><img src="ListingImages/HomepageThumbnails/#ShowELPTypeThumbNailImage#" width="100" align="center" class="grayBorderImg" alt="#ListingTitle#"></a> 	
		                    </li>
						</cfif>
					</cfoutput>
				</ul>
			</div>
			<cfoutput>
			<div class="promo-homepagebuttons"><a href="Tanzania-Events-Calendar" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-viewallspecialevents','','images/home/btn.viewallevents_on.gif',1)" style="margin-right: 40px;"><img src="images/home/btn.viewallevents_off.gif" alt="View all Special Events" name="btn-viewallspecialevents" width="164" height="20" border="0" id="btn-viewallspecialevents" /></a><a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=59" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-postspecialevents','','images/sitewide/btn.postforfree_on.gif',1)"><img src="images/sitewide/btn.postforfree_off.gif" alt="Post for Free" name="btn-postspecialevents" width="164" height="20" border="0" id="btn-postspecialevents" /></a></div>
			</cfoutput>
			<!--ALERTS SIGN UP -->
			
			<div class="promotitle alert-title">
				
			 		<h2 >BE THE FIRST TO KNOW - SIGN UP TODAY!</h2>
			  	
		  </div>
			
			<div class="promo-upcomingspecialevents">
			<div class="jcarousel-skin-tango">
				<ul id="mycarousel" class="jcarousel-list jcarousel-list-horizontal" style="overflow-x: hidden; overflow-y: hidden; position: relative; top: 0px; margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 0px;   ">
					
					<li class="jcarousel-item jcarousel-item-horizontal alert-types" style="float: left; list-style-type: none; list-style-position: initial; list-style-image: initial; text-align: center; height: 120px; width: 170px; margin-top: 5px;" ><strong>Email Alerts</strong><br>Email me when new jobs, classifieds or events are added that match my criteria.
					<a href="<cfoutput>#lh_getPageLink(request.AddAlertPageID,'signupforalerts')#</cfoutput>" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-emailalerts','','images/inner/btn.SignUp_on.gif',1)" ><img src="images/inner/btn.SignUp_off.gif" alt="Email Alerts Sign Up" name="btn-emailalerts" height="20" border="0" id="btn-emailalerts" style="border:none; margin-left: 0px;"></a>
					</li>
				
					<li class="jcarousel-item jcarousel-item-horizontal alert-types" style="float: left; list-style-type: none; list-style-position: initial; list-style-image: initial; text-align: center; height: 120px; width: 170px; margin-top: 5px;" ><strong>Weekly Newsletter</strong><br>This Week in Tanzania Newsletter - highlights for the upcoming week.<br>
					<a href="this-week-in-tanzania-newsletter-archive" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-newsletter','','images/inner/btn.SignUp_on.gif',1)" style="border:none"><img src="images/inner/btn.SignUp_off.gif" alt="View all Special Events" name="btn-newsletter" height="20" border="0" id="btn-newsletter" style="border:none; margin-left: 0px;"></a>
					</li>
					
					<li class="jcarousel-item jcarousel-item-horizontal alert-types" style="float: left; list-style-type: none; list-style-position: initial; list-style-image: initial; text-align: center; border: none; margin-right: 0; height: 120px; width: 170px; margin-top: 5px;" ><strong>Mail Shots</strong><br>Receive special deals, offers and promotions from leading companies.<br>
					<a href="mailshots" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-mailshots','','images/inner/btn.SignUp_on.gif',1)" style="border:none"><img src="images/inner/btn.SignUp_off.gif" alt="View all Special Events" name="btn-mailshots" height="20" border="0" id="btn-mailshots" style="border:none; margin-left: 0px;"></a>
					</li>
				</ul>
			</div>
			</div>
			<!-- END ALERTS SIGN UP -->
		</div>
		



<cfinclude template="footer.cfm">



