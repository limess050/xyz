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

<cfinclude template="headerTemp.cfm">

<cfoutput query="Sections">
	<cfif ParentSectionID is "8">
		<cfset JAndELinkName=ParentSectionURLSafeTitle>
	<cfelseif ParentSectionID is "4">
		<cfset FSBOLinkName=ParentSectionURLSafeTitle>
	<cfelseif ParentSectionID is "5">
		<cfset HAndRLinkName=ParentSectionURLSafeTitle>
	</cfif>
</cfoutput>

<cfquery name="getHomepageJobs" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select Top #HomepageJobsCount# L.ListingID, L.ListingTitle, L.ShortDescr, L.Deadline, L.LocationOther,
	(Select Top 1 Title From Locations Lo Inner Join ListingLocations LL on Lo.LocationID=LL.LocationID Where LL.ListingID = L.ListingID and Lo.LocationID <> 4) as Location
	From ListingsView L
	Where L.ListingTypeID = 10
	<cfinclude template="../includes/LiveListingFilter.cfm">
	Order by DateSort desc
</cfquery>

<cfquery name="getHomepageFSBO" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select Top #HomepageFSBONonVehicleCount# L.ListingID, L.ListingTitle, L.ShortDescr, L.PriceUS, L.PriceTZS, L.ListingTypeID, L.LocationOther,
	(Select Top 1 Title From Locations Lo Inner Join ListingLocations LL on Lo.LocationID=LL.LocationID Where LL.ListingID = L.ListingID and Lo.LocationID <> 4) as Location,
	(Select Top 1 FileName
			From ListingImages
			Where ListingID=L.ListingID
			Order By OrderNum, ListingImageID) as FileNameForTN
	From ListingsView L
	Where L.ListingTypeID in (3,4,5)
	and exists (Select ListingID from ListingParentSections Where ListingID=L.ListingID and ParentSectionID<>55)
	and exists (Select ListingID from ListingImages Where ListingID=L.ListingID)
	<cfinclude template="../includes/LiveListingFilter.cfm">
	Order by DateSort desc
</cfquery>

<cfquery name="getHomepageFSBOVehicles" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select Top #HomepageFSBOVehicleCount# L.ListingID, L.ListingTitle, L.ShortDescr, L.PriceUS, L.PriceTZS, L.ListingTypeID, L.LocationOther,
	(Select Top 1 Title From Locations Lo Inner Join ListingLocations LL on Lo.LocationID=LL.LocationID Where LL.ListingID = L.ListingID and Lo.LocationID <> 4) as Location,
	(Select Top 1 FileName
			From ListingImages
			Where ListingID=L.ListingID
			Order By OrderNum, ListingImageID) as FileNameForTN
	From ListingsView L
	Where L.ListingTypeID in (3,4,5)
	and exists (Select ListingID from ListingParentSections Where ListingID=L.ListingID and ParentSectionID=55)
	and exists (Select ListingID from ListingImages Where ListingID=L.ListingID)
	<cfinclude template="../includes/LiveListingFilter.cfm">	
	Order by DateSort desc
</cfquery>

<cfquery name="getHomepageHR" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select Top #HomepageHRCount# L.ListingID, L.ListingTitle, L.ShortDescr, L.PriceUS, L.PriceTZS, L.RentUS, L.RentTZS, L.ListingTypeID, L.LocationOther,
	(Select Top 1 Title From Locations Lo Inner Join ListingLocations LL on Lo.LocationID=LL.LocationID Where LL.ListingID = L.ListingID and Lo.LocationID <> 4) as Location,
	T.Title as Term,
	(Select Top 1 FileName
			From ListingImages
			Where ListingID=L.ListingID
			Order By OrderNum, ListingImageID) as FileNameForTN
	From ListingsView L
	Left Outer Join Terms T on L.TermID=T.TermID
	Where L.ListingTypeID  in (6,7,8)
	and exists (Select ListingID from ListingImages Where ListingID=L.ListingID)
	<cfinclude template="../includes/LiveListingFilter.cfm">
	Order by DateSort desc
</cfquery>

<cfquery name="getHomepageMultiDayEvents" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select Distinct L.ListingID
	From ListingsView L
	Inner Join ListingEventDays LED on L.ListingID=LED.ListingID
	Where (RecurrenceID is null
			and (Select Count(ListingID) From ListingEventDays Where ListingID=L.ListingID)>1)
	and (ListingEventDate >=DATEADD(Day,0,DATEDIFF(Day,0,DATEADD(HOUR,3,GETUTCDATE())))
		and ListingEventDate <=DATEADD(Day,28,DATEDIFF(Day,0,DATEADD(HOUR,3,GETUTCDATE()))))
	<cfinclude template="../includes/LiveListingFilter.cfm">
</cfquery>

<cfquery name="getHomepageEvents" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	<!--- get all non-MultiDay Events --->
	Select L.ListingID, L.ListingTitle, L.EventStartDate, L.RecurrenceID,
	LED.ListingEventDate as StartDate, LED.ListingEventDate as EndDate,
	CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= DATEADD(Day, 0, DATEDIFF(Day, 0, GetDate())+1) Then 1 Else 0 END as HasExpandedListing,
	ELPTypeThumbnailImage, ExpandedListingPDF
	From ListingsView L
	Inner Join ListingEventDays LED on L.ListingID=LED.ListingID
	Where (RecurrenceID in (3,4) or (RecurrenceID is null
									and (Select Count(ListingID) From ListingEventDays LED2 Where LED2.ListingID=L.ListingID)=1))
	and (ListingEventDate >=DATEADD(Day,0,DATEDIFF(Day,0,DATEADD(HOUR,3,GETUTCDATE())))
		and ListingEventDate <=DATEADD(Day,28,DATEDIFF(Day,0,DATEADD(HOUR,3,GETUTCDATE()))))
	and L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= DATEADD(Day, 0, DATEDIFF(Day, 0, GetDate())+1)
	<cfinclude template="../includes/LiveListingFilter.cfm">
	<cfif getHomepageMultiDayEvents.RecordCount>
		UNION
		<!--- Get MultiDay Events with correct start and end date --->
		Select Distinct L.ListingID, L.ListingTitle, L.EventStartDate, L.RecurrenceID,
		(Select Min(ListingEventDate) From ListingEventDays Where ListingID=L.ListingID) as StartDate, (Select Max(ListingEventDate) From ListingEventDays Where ListingID=L.ListingID) as EndDate,
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= DATEADD(Day, 0, DATEDIFF(Day, 0, GetDate())+1) Then 1 Else 0 END as HasExpandedListing,
		ELPTypeThumbnailImage, ExpandedListingPDF
		From ListingsView L
		Inner Join ListingEventDays LED on L.ListingID=LED.ListingID
		Where L.ListingID in (#ValueList(getHomepageMultiDayEvents.ListingID)#)
		and L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= DATEADD(Day, 0, DATEDIFF(Day, 0, GetDate())+1)
	</cfif>
	Order by ListingEventDate, RecurrenceID
</cfquery>


		<div class="centercol">
			<!-- HOT JOBS AND FOR SALE BY OWNER -->
			<table width="100%">
				<tr>
					<td width="274" class="promo-homepage" valign="top"><div class="promo-homepagetitle">
						<cfoutput>
						  	<h2><a href="#JAndELinkName#">Tanzania Jobs</a></h2>
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
						  		<h2><a href="#FSBOLinkName#">For Sale By Owner</a></h2>
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
						  		<h2><a href="Cars-And-Trucks">Cars, Trucks &amp; Boats</a></h2>
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
						  		<h2><a href="#HAndRLinkName#">Tanzania Real Estate</a></h2>
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
					<td class="promo-homepagebuttons"><a href="Cars-And-Trucks" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-viewallauto','','images/sitewide/btn.viewall_on.gif',1)"><img src="images/sitewide/btn.viewall_off.gif" alt="View All" name="btn-viewallauto" width="93" height="20" border="0" id="btn-viewallauto" /></a><a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=55&ListingSectionID=57&CategoryID=84" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-postforfreeauto','','images/sitewide/btn.postforfree_on.gif',1)"><img src="images/sitewide/btn.postforfree_off.gif" alt="Post for Free" name="btn-postforfreeauto" width="164" height="20" border="0" id="btn-postforfreeauto" /></a></td>
					<td width="5">&nbsp;</td>
					<td class="promo-homepagebuttons"><a href="#HAndRLinkName#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-viewallfortanzania','','images/sitewide/btn.viewall_on.gif',1)"><img src="images/sitewide/btn.viewall_off.gif" alt="View All" name="btn-viewallfortanzania" width="93" height="20" border="0" id="btn-viewallfortanzania" /></a><a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=5" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-postfortanzania','','images/sitewide/btn.postforfree_on.gif',1)"><img src="images/sitewide/btn.postforfree_off.gif" alt="Post for Free" name="btn-postfortanzania" width="164" height="20" border="0" id="btn-postfortanzania" /></a></td>
				</tr>
				</cfoutput>
			</table>
			<!-- UPCOMING SPECIAL EVENTS -->
			<div class="promotitle">
				<cfoutput>
			 		<h2><a href="#lh_getPageLink(32,'events')#">Upcoming Special Events</a></h2>
			  	</cfoutput>
		  </div>
			<!--- If ListingTitle is longer than x, show show x characters of the ListingTitle and the rest of any word that would be truncated, then end with an ellipis. --->
			<div class="promo-upcomingspecialevents">
				<ul id="mycarousel" class="jcarousel-skin-tango">
					<cfoutput query="getHomepageEvents">
						<cfset ShowELPTypeThumbnailImage="">
						<cfif Len(ELPTypeThumbNailImage)>
							<cfset ShowELPTypeThumbnailImage=ELPTypeThumbNailImage>
						</cfif>							
						<cfif Len(ExpandedListingPDF) and FileExists("#Request.ListingUploadedDocsDir#\#ExpandedListingPDF#") and (not Len(ELPTypeThumbnailImage) or not FileExists("#Request.ListingUploadedDocsDir#\#ShowELPTypeThumbnailImage#"))>
							<cfinclude template="createELPThumbnail.cfm">
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
						<cfif showTN>
							<cfsavecontent variable="EventDateString">#DateFormat(StartDate,'mmm')#&nbsp;#DateFormat(StartDate,'d')#<cfif StartDate neq EndDate>&nbsp;&ndash;&nbsp;<cfif #DateFormat(StartDate,'mmm')# neq DateFormat(EndDate,'mmm')>#DateFormat(EndDate,'mmm')#&nbsp;</cfif>#DateFormat(EndDate,'d')#</cfif></cfsavecontent>
							<cfset EventDateLen=Len(EventDateString)>
			  				<cfset ListingTitleTrunc=Request.ListingTitleTrunc>
							<cfset ListingTitleTrunc=ListingTitleTrunc-EventDateLen>
							<li><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">#Left(ListingTitle,ListingTitleTrunc)#<cfif Len(ListingTitle) gt ListingTitleTrunc>#ListFirst(RemoveChars(ListingTitle,1,ListingTitleTrunc)," ")#...</cfif></a> <em>#EventDateString#</em><br />							
							<a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#"><img src="ListingImages/HomepageThumbnails/#ShowELPTypeThumbNailImage#" width="100" align="center" class="grayBorderImg" alt="#ListingTitle#"></a> 	
		                    </li>
						</cfif>
					</cfoutput>
				</ul>
			</div>
			<cfoutput>
			<div class="promo-homepagebuttons"><a href="#lh_getPageLink(32,'events')#" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-viewallspecialevents','','images/home/btn.viewallevents_on.gif',1)" style="margin-right: 40px;"><img src="images/home/btn.viewallevents_off.gif" alt="View all Special Events" name="btn-viewallspecialevents" width="164" height="20" border="0" id="btn-viewallspecialevents" /></a><a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=59" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-postspecialevents','','images/sitewide/btn.postforfree_on.gif',1)"><img src="images/sitewide/btn.postforfree_off.gif" alt="Post for Free" name="btn-postspecialevents" width="164" height="20" border="0" id="btn-postspecialevents" /></a></div>
			</cfoutput>
		</div>
		



<cfinclude template="footerTemp.cfm">



