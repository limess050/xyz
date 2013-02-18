<!---
Home page template
Use this if the home page is different from the default template
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfset HPAccordion="1">

<cfset ContentStyle="content">

<cfset CycleTime="9000">

<cfparam name="HomepageNewsCount" default="4">
<cfparam name="HomepageEventsCount" default="4">
<cfparam name="HomepageJobsCount" default="9">
<cfparam name="HomepageFSBONonVehicleCount" default="4">
<cfparam name="HomepageFSBOVehicleCount" default="3">
<cfparam name="HomepageHRCount" default="6">

<cfset HomepageFSBOCount= HomepageFSBONonVehicleCount + HomepageFSBOVehicleCount>

<cfinclude template="header1.cfm">
<cfsavecontent variable="HeaderAdditions">
	<META name="y_key" content="96a68d2f9ac2440c" />
	<meta name="msvalidate.01" content="4BFB8C5590BEDC34D9E16B4A8AC23969" />
	<cfoutput>
		<script type="text/javascript" src="#Request.HTTPURL#/js/jquery.cycle.all.min.js"></script>
		<script>
			$(document).ready(function() {
				$('##NewsParentDiv').cycle({
					timeout: #CycleTime#,
					fx: 'scrollHorz',
			        after: onAfterNews
				});

				$('##NewsPrev').click(function() {
	    			$('##NewsParentDiv').cycle('prev');
	                $('##NewsParentDiv').cycle('resume');
				});

				$('##NewsNext').click(function() {
	    			$('##NewsParentDiv').cycle('next');
	                $('##NewsParentDiv').cycle('resume');
				});

				$('##NewsPause').toggle(function() {
		                $('##NewsParentDiv').cycle('pause');
		                <!--- $(this).attr({ src: "images/pause_inactive.gif"}); --->
		                }, function() {
		                $('##NewsParentDiv').cycle('resume');
		                <!--- $(this).attr({ src: "images/pause_slide.gif"}); --->
		        });

				function onAfterNews(curr,next,opts) {
					var newsPagination = (opts.currSlide + 1) + '/' + opts.slideCount;
					$('##NewsPagination').html(newsPagination);
				}


				$('##EventsParentDiv').cycle({
					timeout: #CycleTime#,
					fx: 'scrollHorz',
			        after: onAfterEvents
				});

				$('##EventsPrev').click(function() {
	    			$('##EventsParentDiv').cycle('prev');
	                $('##EventsParentDiv').cycle('resume');
				});

				$('##EventsNext').click(function() {
	    			$('##EventsParentDiv').cycle('next');
	                $('##EventsParentDiv').cycle('resume');
				});

				$('##EventsPause').toggle(function() {
		                $('##EventsParentDiv').cycle('pause');
		                }, function() {
		                $('##EventsParentDiv').cycle('resume');
		        });

				function onAfterEvents(curr,next,opts) {
					var eventsPagination = (opts.currSlide + 1) + '/' + opts.slideCount;
					$('##EventsPagination').html(eventsPagination);
				}

			});
		</script>
	</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#HeaderAdditions#">

<cfparam name="JAndELinkName" default="">
<cfparam name="FSBOLinkName" default="">
<cfparam name="HAndRLinkName" default="">
<cfoutput query="Sections">
	<cfif ParentSectionID is "8">
		<cfset JAndELinkName=ParentSectionURLSafeTitle>
	<cfelseif ParentSectionID is "4">
		<cfset FSBOLinkName=ParentSectionURLSafeTitle>
	<cfelseif ParentSectionID is "5">
		<cfset HAndRLinkName=ParentSectionURLSafeTitle>
	</cfif>
</cfoutput>

<cfquery name="insertHPImpression" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Insert into Impressions
	(HomePage)
	Values
	(1)
</cfquery>

<cfquery name="getHomepageNews" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select NewsID, Headline, Source, WebsiteURL
	From News
	Where Active=1
	and Homepage_fl=1
	Order by DatePosted desc
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
	LED.ListingEventDate as StartDate, LED.ListingEventDate as EndDate
	From ListingsView L
	Inner Join ListingEventDays LED on L.ListingID=LED.ListingID
	Where (RecurrenceID in (3,4) or (RecurrenceID is null
									and (Select Count(ListingID) From ListingEventDays LED2 Where LED2.ListingID=L.ListingID)=1))
	and (ListingEventDate >=DATEADD(Day,0,DATEDIFF(Day,0,DATEADD(HOUR,3,GETUTCDATE())))
		and ListingEventDate <=DATEADD(Day,28,DATEDIFF(Day,0,DATEADD(HOUR,3,GETUTCDATE()))))
	<cfinclude template="../includes/LiveListingFilter.cfm">
	<cfif getHomepageMultiDayEvents.RecordCount>
		UNION
		<!--- Get MultiDay Events with correct start and end date --->
		Select Distinct L.ListingID, L.ListingTitle, L.EventStartDate, L.RecurrenceID,
		(Select Min(ListingEventDate) From ListingEventDays Where ListingID=L.ListingID) as StartDate, (Select Max(ListingEventDate) From ListingEventDays Where ListingID=L.ListingID) as EndDate
		From ListingsView L
		Inner Join ListingEventDays LED on L.ListingID=LED.ListingID
		Where L.ListingID in (#ValueList(getHomepageMultiDayEvents.ListingID)#)
	</cfif>
	Order by ListingEventDate, RecurrenceID
</cfquery>

<cfquery name="getHomepageJobs" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select Top #HomepageJobsCount# L.ListingID, L.ListingTitle, L.ShortDescr
	From ListingsView L
	Where L.ListingTypeID = 10
	<cfinclude template="../includes/LiveListingFilter.cfm">
	Order by ListingID desc
</cfquery>

<cfquery name="getHomepageFSBO" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select Top #HomepageFSBOVehicleCount# L.ListingID, L.ListingTitle, L.ShortDescr, L.PriceUS, L.PriceTZS, L.ListingTypeID
	From ListingsView L
	Where L.ListingTypeID in (3,4,5)
	and exists (Select ListingID from ListingParentSections Where ListingID=L.ListingID and ParentSectionID=55)
	<cfinclude template="../includes/LiveListingFilter.cfm">
	UNION
	Select Top #HomepageFSBONonVehicleCount# L.ListingID, L.ListingTitle, L.ShortDescr, L.PriceUS, L.PriceTZS, L.ListingTypeID
	From ListingsView L
	Where L.ListingTypeID in (3,4,5)
	and exists (Select ListingID from ListingParentSections Where ListingID=L.ListingID and ParentSectionID<>55)
	<cfinclude template="../includes/LiveListingFilter.cfm">
	Order by ListingID desc
</cfquery>

<cfquery name="getHomepageHR" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select Top #HomepageHRCount# L.ListingID, L.ListingTitle, L.ShortDescr, L.PriceUS, L.PriceTZS, L.RentUS, L.RentTZS, L.ListingTypeID, L.LocationOther,
	(Select Top 1 Title From Locations Lo Inner Join ListingLocations LL on Lo.LocationID=LL.LocationID Where LL.ListingID = L.ListingID and Lo.LocationID <> 4) as Location,
	T.Title as Term
	From ListingsView L
	Left Outer Join Terms T on L.TermID=T.TermID
	Where L.ListingTypeID  in (6,7,8)
	<cfinclude template="../includes/LiveListingFilter.cfm">
	Order by ListingID desc
</cfquery>

<!--- <lh:MS_SitePagePart id="title" class="title">
<lh:MS_SitePagePart id="body" class="body"> --->


<!-- RIGHT COLUMN -->
<div id="hp-content">

	<table class="homepagetable" width="730">
    	<tbody>
			<tr>
      			<td class="outercell" width="60%">
					<table border="0" cellpadding="0" cellspacing="0" width="100%">
        				<tbody>
							<tr>
          						<td class="headercell">Tanzania News Today</td>
        					</tr>
        					<tr>
          						<td>
									<div class="homepagetablecontent">
										<div id="NewsParentDiv">
											<cfset NewsDivCounter="1">
											<div id="NewsDiv1" class="FirstDiv">
											<cfoutput query="getHomepageNews">
												<p><a href="#WebsiteURL#" target="_blank" class="largerLink">#Headline#</a><br>
	            								<em>#Source#</em></p>
												<cfif CurrentRow and CurrentRow MOD HomepageNewsCount is "0" and CurrentRow neq RecordCount>
													</div>
													<cfset NewsDivCounter=NewsDivCounter + 1>
													<div id="NewsDiv#NewsDivCounter#">
												</cfif>
											</cfoutput>
											</div>
										</div>
										<cfoutput>
											<div class="pausecontinuepagination" id="NewsPagination">1/#NewsDivCounter#</div>
											<div>
												<div class="pausecontinue"><img src="images/sitewide/icon_005.png" ID="NewsPrev" class="changeCursor" alt="Back" height="17" width="17"><img src="images/sitewide/icon_003.png" ID="NewsPause" class="changeCursor" alt="Pause" height="17" width="17"><img src="images/sitewide/icon_002.png" ID="NewsNext" class="changeCursor" alt="Forward" height="17" width="17"></div>
												<div class="homepagebuttons"><a href="mailto:news@ZoomTanzania.com"><img src="images/sitewide/btn.suggestnewsitem.gif" alt="Suggest a News Item" height="29" width="135"></a></div>
	             								<div class="clear"></div>
											</div>
											<div class="greencaps"><cfif Request.lh_useFriendlyUrls><a href="News"><cfelse><a href="#lh_getPageLink(34,'news')#"></cfif>View All New Headlines</a></div>
										</cfoutput>
             						</div>
								</td>
        					</tr>
      					</tbody>
					</table>
				</td>
      			<td class="outercell">
					<table border="0" cellpadding="0" cellspacing="0" width="100%">
        				<tbody>
							<tr>
          						<td class="headercell">Upcoming Events</td>
        					</tr>
        					<tr>
          						<td>
									<div class="homepagetablecontent">
										<div id="EventsParentDiv">
											<cfset EventsDivCounter="1">
											<div id="EventsDiv1" class="FirstDiv">
											<cfoutput query="getHomepageEvents">
												<p><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#" class="largerLink">#ListingTitle#</a>&nbsp;&ndash;&nbsp;#DateFormat(StartDate,'mmm')#&nbsp;#DateFormat(StartDate,'d')#<cfif StartDate neq EndDate>&nbsp;&ndash;&nbsp;#DateFormat(EndDate,'mmm')#&nbsp;#DateFormat(EndDate,'d')#</cfif></p>
												<cfif CurrentRow and CurrentRow MOD HomepageEventsCount is "0" and CurrentRow neq RecordCount>
													</div>
													<cfset EventsDivCounter=EventsDivCounter + 1>
													<div id="EventsDiv#NewsDivCounter#">
												</cfif>
											</cfoutput>
											</div>
										</div>
										<cfoutput>
											<div class="pausecontinuepagination" id="EventsPagination">1/#EventsDivCounter#</div>
	            							<div>
	              								<div class="pausecontinue"><img src="images/sitewide/icon_005.png" ID="EventsPrev" class="changeCursor" alt="Back" height="17" width="17"><img src="images/sitewide/icon_003.png" ID="EventsPause" class="changeCursor" alt="Pause" height="17" width="17"><img src="images/sitewide/icon_002.png" ID="EventsNext" class="changeCursor" alt="Forward" height="17" width="17"></div>
												<div class="homepagebuttons"><a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=59"><img src="images/sitewide/btn.posteventfree.gif" alt="Post an Event Free" height="29" width="135"></a></div>
	              								<div class="clear"></div>

	            							</div>
	              							<div class="greencaps"><a href="#lh_getPageLink(32,'events')#">View Full Events Calendar</a></div>
										</cfoutput>
          							</div>
								</td>
        					</tr>
      					</tbody>
					</table>
				</td>
			</tr>
  		</tbody>
	</table>
  	<table class="homepagetable" style="margin-top: 0.5em;" width="730">
    	<tbody>
			<tr>
      			<td class="outercell" width="33%">
					<table border="0" cellpadding="0" cellspacing="0" width="100%">
	        			<tbody>
							<tr>
	          					<td class="headercell">Hot Jobs</td>
	        				</tr>
	        				<tr>
          						<td>
									<div class="homepagetablecontent">
										<div id="JobsParentDiv">
											<cfset JobsDivCounter="1">
											<div id="JobsDiv1" class="FirstDiv">
											<cfoutput query="getHomepageJobs">
												<p><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#" class="largerLink">#ShortDescr#</a><br>
												#ListingTitle#</p>
												<cfif CurrentRow and CurrentRow MOD HomepageJobsCount is "0" and CurrentRow neq RecordCount>
													</div>
													<cfset JobsDivCounter=JobsDivCounter + 1>
													<div id="JobsDiv#NewsDivCounter#">
												</cfif>
											</cfoutput>
											</div>
										</div>
										<cfoutput>
	                           			<div class="linkandbutton">
	               							<div class="greencaps"><a href="#JAndELinkName#">View All<br>Hot Jobs</a></div>
	             							<div class="homepagebuttons"><a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=8&ListingSectionID=19&ListingTypeID=10"><img src="images/sitewide/btn.postvacancy.gif" alt="Post Vacancy $25" height="29" width="135"></a></div>
	             							<div class="clear"></div>
										</div>
										</cfoutput>
             						</div>
								</td>
        					</tr>
      					</tbody>
					</table>
				</td>
       			<td class="outercell" width="33%">
					<table border="0" cellpadding="0" cellspacing="0" width="100%">
        				<tbody>
							<tr>
          						<td class="headercell">Latest for Sale Classifieds</td>
        					</tr>
        					<tr>
          						<td>
									<div class="homepagetablecontent">
										<div id="FSBOParentDiv">
											<cfset FSBODivCounter="1">
											<div id="FSBODiv1" class="FirstDiv">
											<cfoutput query="getHomepageFSBO">
												<p><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#" class="largerLink">
													#ListingTitle#</a>&nbsp;<cfif Len(PriceUS)>$US&nbsp;#NumberFormat(PriceUS,",")#<br /><cfelseif Len(PriceTZS)>TSH&nbsp;#NumberFormat(PriceTZS,",")#<br /></cfif></p>
												<cfif CurrentRow and CurrentRow MOD HomepageFSBOCount is "0" and CurrentRow neq RecordCount>
													</div>
													<cfset FSBODivCounter=FSBODivCounter + 1>
													<div id="FSBODiv#NewsDivCounter#">
												</cfif>
											</cfoutput>
											</div>
										</div>
										<cfoutput>
                         				<div class="linkandbutton">
               								<div class="greencaps"><a href="category?CategoryID=84">View All<br>Vehicles<br>&amp; Boats</a></div>
             								<div class="homepagebuttons"><a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=55&ListingSectionID=57&CategoryID=84"><img src="images/sitewide/btn.postvehiclesfree.gif" alt="Post Vehicles Free" height="29" width="135"></a></div>
             								<div class="clear"></div>
										</div>
             							<div class="linkandbutton">
               								<div class="greencaps"><a href="#FSBOLinkName#">View All<br>Classifieds</a></div>
             								<div class="homepagebuttons"><a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=4"><img src="images/sitewide/btn.postclassifiedsfree.gif" alt="Post Classifieds FREE" height="29" width="135"></a></div>
             								<div class="clear"></div>
										</div>
										</cfoutput>
             						</div>
								</td>
        					</tr>
      					</tbody>
					</table>
				</td>
      			<td class="outercell">
					<table border="0" cellpadding="0" cellspacing="0" width="100%">
        				<tbody>
							<tr>
          						<td class="headercell">Newest Property Listings</td>
        					</tr>
        					<tr>
          						<td>
									<div class="homepagetablecontent">
										<div id="HRParentDiv">
											<cfset HRDivCounter="1">
											<div id="HRDiv1" class="FirstDiv">
											<cfoutput query="getHomepageHR">
												<p><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#" class="largerLink">
													#ListingTitle#
													<cfswitch expression="#ListingTypeID#">
														<cfcase value="6,7">
															<cfif Len(RentUS)>$US&nbsp;#NumberFormat(RentUS,",")#<cfif Len(Term)>/#Term#</cfif><br /><cfelseif Len(RentTZS)>TSH&nbsp;#NumberFormat(RentTZS,",")#<cfif Len(Term)>/#Term#</cfif></cfif>
														</cfcase>
														<cfcase value="8">
															<cfif Len(PriceUS)>$US&nbsp;#NumberFormat(PriceUS,",")#<br /><cfelseif Len(PriceTZS)>TSH&nbsp;#NumberFormat(PriceTZS,",")#<br /></cfif>
														</cfcase>
													</cfswitch>
													</a> &ndash;&nbsp;#Location#<cfif Len(Location) and len(LocationOther)>, </cfif>#LocationOther#</p>
												<cfif CurrentRow and CurrentRow MOD HomepageHRCount is "0" and CurrentRow neq RecordCount>
													</div>
													<cfset HRDivCounter=HRDivCounter + 1>
													<div id="HRDiv#NewsDivCounter#">
												</cfif>
											</cfoutput>
											</div>
										</div>
										<cfoutput>
										<div class="linkandbutton">
              								<div class="greencaps"><a href="#HAndRLinkName#">View All<br>Properties<br></a></div>
              								<div class="homepagebuttons"><a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=5"><img src="images/sitewide/btn.postpropertyfree.gif" alt="Post Property FREE" height="29" width="135"></a></div>
              								<div class="clear"></div>
            							</div>
										</cfoutput>
          							</div>
								</td>
        					</tr>
      					</tbody>
					</table>
				</td>
			</tr>
  		</tbody>
	</table>

</div>
<div id="clear"></div>
</div>


<cfset ShowRightColumn="0">
<cfinclude template="footer1.cfm">
</div>
</div>



