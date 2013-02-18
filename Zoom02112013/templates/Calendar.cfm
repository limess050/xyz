
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<script type="text/javascript" src="Lighthouse/Resources/js/lighthouse_all.js"></script>

	<script type="text/javascript">
			$(function(){

				// Datepicker
				$('#datepicker').datepicker({
					inline: true,
					altField: '#datePicked',
					altFormat: 'dd/mm/yy',
					minDate: +0,
					onSelect: function(dateText, inst) { 
						dp=$("#datePicked").val();
						$("#datePicked2").val(dp);
						$('#datePickerForm').submit();
					}

				});
				
				//hover states on the static widgets
				$('#dialog_link, ul#icons li').hover(
					function() { $(this).addClass('ui-state-hover'); }, 
					function() { $(this).removeClass('ui-state-hover'); }
				);
				
			});
		</script>
<script type="text/javascript">
	$(function() {
		var dates = $( "#from, #to" ).datepicker({
			defaultDate: "+1w",
			changeMonth: true,
			numberOfMonths: 2,
			onSelect: function( selectedDate ) {
				var option = this.id == "from" ? "minDate" : "maxDate",
					instance = $( this ).data( "datepicker" ),
					date = $.datepicker.parseDate(
						instance.settings.dateFormat ||
						$.datepicker._defaults.dateFormat,
						selectedDate, instance.settings );
				dates.not( this ).datepicker( "option", option, date );
			}
		});
	});
	</script>

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

<cfquery name="getEvents" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select Top 15 L.ListingID, L.ListingTitle, L.EventStartDate, L.RecurrenceID, L.RecurrenceMonthID,
		(Select Min(ListingEventDate) From ListingEventDays With (NoLock) Where ListingID=L.ListingID) as StartDate, (Select Max(ListingEventDate) From ListingEventDays With (NoLock) Where ListingID=L.ListingID) as EndDate,
		<cfinclude template="../includes/EventOrderingColumns.cfm">
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ# Then 1 Else 0 END as HasExpandedListing,
		L.ELPTypeThumbnailImage, L.ExpandedListingPDF		
		From ListingsView L With (NoLock)
		Where (EXISTS (SELECT ListingID FROM ListingEventDays With (NoLock) WHERE ListingID=L.ListingID AND ListingEventDate >= #application.CurrentDateInTZ#))
		<cfinclude template="../includes/LiveListingFilter.cfm">
		Order By EventSortDate, EventRank,  L.ListingTitle			
	</cfquery>

<div class="centercol-inner">
		<table width="100%">
				<tr>
					<td class="promo-eventscalendar" valign="top">
						<div class="promo-homepagetitle">
						  	<h1>Tanzania Events Calendar</h1>
				  			</div>
							<div class="promo-eventscalendartext">
								<cfoutput>
									<div class="PTwrapper">
										<div class="float-right padLeft5">
			                     			<a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=59" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('posteventsfreetanzania','','images/sitewide/btn.posteventsfree_on.gif',1)"><img src="images/sitewide/btn.posteventsfree_off.gif" alt="Post Events Free" name="posteventsfreetanzania" width="148" height="20" border="0" align="right" id="posteventsfreetanzania" /></a>
										</div>
										<cfmodule template="../includes/HelpfulHints.cfm" CategoryID="" SectionID="" ParentSectionID="59">
									</div>
									<cfmodule template="../includes/HelpfulHints.cfm" CategoryID="" SectionID="" ParentSectionID="59" HintTypeID="2">
								</cfoutput>
                     			<hr />
								<div class="clear15"></div>
							<table width="100%" border="0">
								<tr>
									<td class="grayrightvertical"><strong>View Events by Date</strong> <em>Click on Date</em>
										<!-- Datepicker -->
										<div id="datepicker"></div>
										<cfoutput><form name="datePickerForm" id="datePickerForm" action="#lh_getPageLink(Request.SearchEventsPageID,'searchEvents')#" method="get">
											<input type="hidden" name="EventStartDate" id="datePicked">
											<input type="hidden" name="EventEndDate" id="datePicked2">
										</form></cfoutput>
									</td>
									<td width="10">&nbsp;</td>
									<td>
										<cfset OnEventLanding="1">
                                        <cfinclude template="../includes/EventsSearchRow.cfm">
									  </td>
								</tr>
							</table>
					  </div></td>
				</tr>
			</table>
		  <div class="clear15"></div>
			<!-- UPCOMING SPECIAL EVENTS -->
			<div class="promotitle">
			  <h2>Upcoming Special Events</h2>
		  </div>		  
			<!--- If ListingTitle is longer than x, show show x characters of the ListingTitle and the rest of any word that would be truncated, then end with an ellipis. --->
			<div class="promo-upcomingspecialevents-inner">
				 <!--[if lte IE 7]>
				<style type="text/css">
				.events-skin-tango li {border-right: solid 1px #d9d9d9; display: inline-block; width: 155px; padding: 8px; margin: 7px 3px; border-bottom: solid 1px #CCC; vertical-align: text-top; min-height: 220px; text-align: center; zoom: 1; *display: inline;}
				</style><![endif]-->

				<ul class="events-skin-tango">
					<cfoutput query="getEvents" maxrows="12">
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
								<cfinclude template="../includes/createELPThumbnail.cfm">
								<cfset ShowELPTypeThumbNailImage=ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(ShowELPTypeThumbNailImage,'.jp','Two.jp'),'.gi','Two.gi'),'.pn','Two.pn')>
							</cfif>
							<a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">
							<cfif Len(ShowELPTypeThumbNailImage) and FileExists("#Request.ListingUploadedDocsDir#\#ShowELPTypeThumbNailImage#")>
								<img src="ListingUploadedDocs/#ShowELPTypeThumbNailImage#" width="100" align="center" class="grayBorderImg" alt="#ListingTitle#">
							<cfelse>
								<img src="../Images/SiteWide/NoImageAvailableHPE.gif" align="center" class="grayBorderImg" alt="#ListingTitle#">
							</cfif>
							</a> 					
						<cfelse>
							<a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#"><img src="../Images/SiteWide/NoImageAvailableHPE.gif" height="142" align="center" class="grayBorderImg" alt="#ListingTitle#"></a>
						</cfif>
						</li>
					</cfoutput>
				</ul>
      </div>
			<div class="promo-homepagebuttons"><a href="<cfoutput>#lh_getPageLink(33,'searchevents')#</cfoutput>" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-viewallspecialevents','','images/home/btn.viewallevents_on.gif',1)" style="margin-right: 40px;"><img src="images/home/btn.viewallevents_off.gif" alt="View all Special Events" name="btn-viewallspecialevents" width="164" height="20" border="0" id="btn-viewallspecialevents" /></a><a href="<cfoutput>#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=59</cfoutput>" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-postspecialevents','','images/sitewide/btn.postforfree_on.gif',1)"><img src="images/sitewide/btn.postforfree_off.gif" alt="Post for Free" name="btn-postspecialevents" width="164" height="20" border="0" id="btn-postspecialevents" /></a></div>
	
	
</div>

<!-- END CENTER COL -->

<cfinclude template="footer.cfm">
