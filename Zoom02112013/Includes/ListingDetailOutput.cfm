<cfparam name="DisplayExpandedListing" default="1">
<cfparam name="Preview" default="0">
<cfparam name="HasPublicEmail" default="0">
<cfparam name="CE" default="0"><!--- A value of 1 means the user has logged in to Click to Email a Job Posting and has been redirected here, with the Email Lister form open. --->
<cfparam name="ShowCodeOfConduct" default="0">
<cfparam name="ClickCount" default="">

<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfoutput query="getListing" maxrows="1">
	<cfif Preview>
		<cfif not IsDefined('session.UserID') or not Len(session.UserID)>
			<cfset Preview = "0">
		<cfelseif session.UserID neq InProgressUserID and session.UserID neq UserID and not checkAdmin.RecordCount>
			<cfset Preview = "0">		
		</cfif>
	</cfif>
	
	<cfif ListFind("10,12",ListingTypeID) and IsDefined('session.UserID') and Len(session.UserID)>
		<!--- Check for completed Code of Conduct and today's number of JobClicks. --->
		<cfquery name="getClickandCOC" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select UCC.CodeOfConductID, J.ClickCount
			From LH_Users U
			Left Outer Join UserCodeOfConduct UCC on U.UserID=UCC.UserID and CodeOfConductID = 3
			Left Outer Join JobClicks J on U.UserID=J.UserID and J.ClickDate = <cfqueryparam value="#application.CurrentDateInTZ#" cfsqltype="cf_sql_date">
			Where U.UserID = <cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfif not Len(getClickandCOC.CodeOfConductID)>
			<cfset ShowCodeOfConduct = 1>
		</cfif>
		<cfset ClickCount = getClickandCOC.ClickCount>
	</cfif>
	
	<cfswitch expression="#getListing.ListingTypeID#">	
		
		<cfcase value="1,20"><!--- BUS 1 and MOVIE THEATERS --->
			 <div class="listings">
				<cfquery name="getPriceRanges" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Select PR.Title
					From ListingPriceRanges LPR With (NoLock) inner join PriceRanges PR With (NoLock) on LPR.PriceRangeID=PR.PriceRangeID
					Where LPR.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
					and PR.Active=1
					Order By PR.OrderNum
				</cfquery>
				<cfif ListFind(Request.ParkCategoryIDs,CategoryID)>						
					<cfquery name="getParks" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						Select P.Title
						From ListingParks LP With (NoLock) inner join Parks P With (NoLock) on LP.ParkID=P.ParkID
						Where LP.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
						and P.Active=1
						and P.Title <> 'Other'
						Order By P.OrderNum
					</cfquery>
				</cfif>
				<cfif getListing.ListingTypeID is "20">						
					<cfquery name="getMovies"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						Select LM.ListingMovieID, LM.Title as MovieTitle, LM.Starring, LM.NowPlayingID, 
						LM.DailyShowTimes, LM.OtherShowTimes, LM.Saturdays, LM.Sundays, LM.Holidays,
						LM.DirectedBy, LM.Descr, LM.OfficialURL, LM.YahooURL, LM.IMDBURL, 
						LM.MovieImage, LM.OrderNum
						From ListingMovies LM
						Where LM.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
						Order By LM.NowPlayingID, LM.OrderNum
					</cfquery>
				</cfif>
				<cfsavecontent variable="ShortFieldsContent">
	   				
					<cfif ListingTypeID is "20" and Len(LocationText)>
		   				<span style="float:right; width: 280px;">
					<cfelse>
						<p>&nbsp;</p>
					</cfif> 								
					<cfif getPriceRanges.RecordCount and ListFind(Request.PriceRangeCategoryIDs,CategoryID)>
						<p><strong>Price Range<cfif getPriceRanges.RecordCount gt 1>s</cfif>:</strong> #Replace(valueList(getPriceRanges.Title),",",", ","ALL")#<br>
					</cfif>		
					<cfif not PhoneOnlyListing_fl and Len(PublicEmail)>
						<p><strong>Email Address:</strong> <span id="EmailLister"><a href="javascript:void(0);" class="ELLink">Click to Email</a><br />
					</cfif>  
					<cfif Len(PublicPhone)>
						<strong>Phone&nbsp;##: </strong>#PublicPhone#<br />
					</cfif> 				
					<cfif Len(PublicPhone2)>
						<strong>Fax&nbsp;##: </strong>#PublicPhone2#<br />
					</cfif>		
					<cfif Len(PublicPhone3)>
						<strong>Other Phone&nbsp;##: </strong>#PublicPhone3#<br />
					</cfif>		
					<cfif Len(PublicPhone4)>
						<strong>Other Phone&nbsp;##: </strong>#PublicPhone4#<br />
					</cfif>
					<cfif Len(LocationTitles) or Len(LocationOther)>
						<cfset LocationCount=ListLen(LocationTitles)>
						<cfif Len(LocationOther)>
							<cfset LocationCount=LocationCount+1>
						</cfif>
						<strong>Area<cfif LocationCount gt 1>s</cfif>:</strong> <cfif Len(LocationTitles)>#Replace(LocationTitles,",",", ","ALL")#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#LocationOther#</cfif>
					</cfif>		
	   				</p>
					<cfif not PhoneOnlyListing_fl and Len(WebsiteURL)>
						<cfif Left(WebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & WebsiteURL><cfelse><cfset LocalWebsiteURL=WebsiteURL></cfif>
						<p><strong>Website: </strong><a href="#LocalWebsiteURL#" target="_blank" onClick="clickThroughExternal(#ListingID#)">Go to Website</a><br />
		   				</p>
					</cfif>
					<cfif ListingTypeID is "20" and Len(LocationText)>
						</span>
						<span style="float:right; width: 280px;">
							<p><strong>Location/Directions: </strong>#LocationText#<br />
			   				</p>
			   				<cfif Len(MovieFees)>
								<a href="##PriceInfo">See Price Information</a>
							</cfif>
		   				</span>
					</cfif>
				</cfsavecontent>
				<cfset showELPLink="0">
				<cfset ShowELPTypeThumbnailImage=ELPTypeThumbnailImage>
				<cfif Len(ExpandedListingPDF) and FileExists("#Request.ListingUploadedDocsDir#\#ExpandedListingPDF#") and (not Len(ELPTypeThumbnailImage) or not FileExists("#Request.ListingUploadedDocsDir#\#ELPTypeThumbnailImage#"))>
					<cfinclude template="createELPThumbnail.cfm">
				</cfif>
				<table border="0" class="listingTable">
					<tr>
						<td align="left">
						 	<cfif ListingTypeID is "1" and not PhoneOnlyListing_fl and ((Len(ExpandedListingHTML) or Len(ExpandedListingPDF)) and (Preview or (not ExpandedListingInProgress and DisplayExpandedListing and HasExpandedListing)))>
								<cfset ShowELPLink="1">
								<p class="bluelarge"><a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)">#ListingTitle#</a></p>
							<cfelse>
								<p class="greenlarge">#ListingTitle#</strong></p>
							</cfif>
							<cfif Len(LogoImage) and FileExists("#Request.ListingUploadedDocsDir#\#LogoImage#")>
								<cfif ListingTypeID is "1" and ShowELPLink>
									<a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="ListingUploadedDocs/#LogoImage#" alt="#ListingTitle# Logo" title="#ListingTitle# Logo" class="grayBorderImg"></a><br>
								<cfelse>
									<span style="float:left;"><img src="ListingUploadedDocs/#LogoImage#" alt="#ListingTitle# Logo" title="#ListingTitle# Logo" class="grayBorderImg"></span>
								</cfif>
																
							</cfif>
							#ShortFieldsContent#
						</td>
						<cfif ListingTypeID is "1" and ShowELPLink and Len(ShowELPTypeThumbnailImage) and FileExists("#Request.ListingUploadedDocsDir#\#ShowELPTypeThumbnailImage#")>
							<td align="center">
								<a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="ListingUploadedDocs/#ShowELPTypeThumbnailImage#" border="0" alt="#ListingTitle# #ELPType#" title="#ListingTitle# #ELPType#" class="grayBorderImg"></a>
								<br>
								<a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="images/inner/psd-magnifier-zoom-icons-2.png" style="padding: 5px 5px 0 0; ">Zoom our <cfif Len(ELPType)>#ELPType#<cfelse>Flier</cfif></a>
							</td>
						</cfif>
					</tr>
				</table>
				<cfif getListing.ListingTypeID is "20" and getMovies.RecordCount>
					<div style="width:530px;">
						<p>&nbsp;</p>
						<strong>Movies and Showtimes:</strong>
						<cfset ShowComingSoon = "0">
						<cfif getMovies.RecordCount>
							<cfloop query="getMovies">
								<cfif not ShowComingSoon and NowPlayingID is "2">
									<p>&nbsp;</p>
									<div class="greenBar"><strong>COMING SOON:</strong></div>
									<p>&nbsp;</p>
									<cfset ShowComingSoon = "1">
								</cfif>
								<div style="width:530px; overflow:hidden;">
									<cfif Len(MovieImage)>
										<div class="movieImage">
											<img src="../ListingImages/#MovieImage#">
										</div>
									</cfif>
									<p>&nbsp;</p>
									<span class="movieTitle">#MovieTitle#</span><br>
									<cfif Len(Starring)>
										<p>&nbsp;</p>
										<p><strong>Starring:</strong> #Starring#</p>
									</cfif>
									<cfif Len(DailyShowTimes)>
										<p>&nbsp;</p>
										<p><strong>Daily Show Times:</strong> #DailyShowTimes#</p>
									</cfif>
									<cfif (Saturdays or Sundays or Holidays) and Len(OtherShowTimes)>
										<p>&nbsp;</p>
										<p><strong><cfif Saturdays>Saturdays<cfif Sundays or Holidays>,</cfif></cfif><cfif Sundays><cfif Saturdays and not Holidays> and</cfif> Sundays<cfif Holidays>,</cfif></cfif><cfif Holidays><cfif Saturdays or Sundays> and</cfif> Public Holidays</cfif>: </strong>#OtherShowTimes#</p>
									</cfif>
									<cfif Len(DirectedBy)>
										<p>&nbsp;</p>
										<p><strong>Directed by:</strong> #DirectedBy#</p>
									</cfif>
									<cfif Len(Descr)>
										<p>&nbsp;</p>
										<p>#Descr#</p>
									</cfif>
									<cfif Len(OfficialURL) or Len(YahooURL) or Len(IMDBURL)>
										<p>&nbsp;</p>
										<p>
											<strong>Reviews and more about #MovieTitle#</strong><br>
											<cfif Len(OfficialURL)><a href="#OfficialURL#" target="_blank">Official Site</a></cfif>
											<cfif Len(YahooURL)><cfif Len(OfficialURL)> | </cfif><a href="#YahooURL#" target="_blank">Yahoo Movie Review</a></cfif>
											<cfif Len(IMDBURL)><cfif Len(OfficialURL) or Len(YahooURL)> | </cfif><a href="#IMDBURL#" target="_blank">IMDb Review</a></cfif>
										</p>
									</cfif>
									<div style="clear:both;"><hr></div>
								</div>								
							</cfloop>
						<cfelse>
							No movie records found.<br>
						</cfif>
					</div>
				</cfif>
				<cfif not PhoneOnlyListing_fl>
	   				<cfif Len(MovieFees)>
		   				<a name="PriceInfo"></a>
						<p>&nbsp;</p>
						<div style="width:530px;"><strong>Prices and Fees: </strong><br>
						#MovieFees#</div>
					</cfif> 
	   				<cfif Len(ShortDescr)>
						<p>&nbsp;</p>
						<div style="width:530px;"><strong>About #ListingTitle#: </strong><cfif getListing.ListingTypeID is "20"><br></cfif>#ShortDescr#</div>
					</cfif> 	
				</cfif>
				<cfif (ListFind(Request.ParkCategoryIDs,CategoryID) and (getParks.RecordCount or Len(ParkOther))) or Len(LocationText) >
					<p>&nbsp;</p>
				</cfif>
				<cfif ListFind(Request.ParkCategoryIDs,CategoryID) and (getParks.RecordCount or Len(ParkOther))>
					<cfset ParkCount=getParks.RecordCount>
					<cfif Len(ParkOther)>
						<cfset ParkCount=ParkCount+1>
					</cfif>
					<p><strong>Park<cfif ParkCount gt 1>s</cfif> Served:</strong> <cfif getParks.RecordCount>#Replace(ValueList(getParks.Title),",",", ","ALL")#</cfif><cfif Len(ParkOther)><cfif ParkCount gt 1>, </cfif>#ParkOther#</cfif>
				</cfif>	
				<cfif ListingTypeID is "1" and Len(LocationText)>					
					<p><strong>Location/Directions: </strong>#LocationText#<br />
	   				</p>
				</cfif> 
				<cfif ListingTypeID is "1" and not PhoneOnlyListing_fl and ShowELPLink>	
	   				<p><br />
	   				</p>
					<p><a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="images/inner/psd-magnifier-zoom-icons-2.png" style="padding: 5px 5px 0 0; ">Zoom our <cfif Len(ELPType)>#ELPType#<cfelse>Flier</cfif></a>
				</cfif>
   			</div>						
		</cfcase>		
		
		<cfcase value="2"><!--- BUS 2 (Restaurant) --->
			<cfquery name="getCuisines" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select C.Title
				From ListingCuisines LC With (NoLock) inner join Cuisines C With (NoLock) on LC.CuisineID=C.CuisineID
				Where LC.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
				and C.Active=1
				and C.CuisineID <> 4 <!--- Other) --->
				Order By C.OrderNum
			</cfquery>
			<div class="listings">
				<cfsavecontent variable="ShortFieldsContent">					
					<p><br></p>
					<cfif (getCuisines.RecordCount or Len(CuisineOther))>
						<p><strong>Cuisine<cfif getCuisines.RecordCount gt 1 or (getCuisines.RecordCount and Len(CuisineOther))>s</cfif>:</strong> #Replace(valueList(getCuisines.Title),",",", ","ALL")#<cfif getCuisines.RecordCount and Len(CuisineOther)>,</cfif> #CuisineOther#<br>
					</cfif>	
	   				<p>&nbsp;</p>
					<cfif not PhoneOnlyListing_fl and Len(PublicEmail)>
						<p><strong>Email Address:</strong> <span id="EmailLister"><a href="javascript:void(0);" class="ELLink">Click to Email</a><br />
					</cfif>  				
					<cfif Len(PublicPhone)>
						<strong>Phone&nbsp;##: </strong>#PublicPhone#<br />
					</cfif> 				
					<cfif Len(PublicPhone2)>
						<strong>Fax&nbsp;##: </strong>#PublicPhone2#<br />
					</cfif>		
					<cfif Len(PublicPhone3)>
						<strong>Other Phone&nbsp;##: </strong>#PublicPhone3#<br />
					</cfif>		
					<cfif Len(PublicPhone4)>
						<strong>Other Phone&nbsp;##: </strong>#PublicPhone4#<br />
					</cfif>		
					<cfif Len(LocationTitles) or Len(LocationOther)>
						<cfset LocationCount=ListLen(LocationTitles)>
						<cfif Len(LocationOther)>
							<cfset LocationCount=LocationCount+1>
						</cfif>
						<strong>Area<cfif LocationCount gt 1>s</cfif>:</strong> <cfif Len(LocationTitles)>#Replace(LocationTitles,",",", ","ALL")#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#LocationOther#</cfif>
					</cfif>	
	   				</p>
					<cfif not PhoneOnlyListing_fl and Len(WebsiteURL)>
						<cfif Left(WebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & WebsiteURL><cfelse><cfset LocalWebsiteURL=WebsiteURL></cfif>
						<p><strong>Website: </strong><a href="#LocalWebsiteURL#" target="_blank" onClick="clickThroughExternal(#ListingID#)">Go to Website</a><br />
		   				</p>
					</cfif>
				</cfsavecontent>
				<cfset showELPLink="0">
				<cfset ShowELPTypeThumbnailImage=ELPTypeThumbnailImage>
				<cfif Len(ExpandedListingPDF) and FileExists("#Request.ListingUploadedDocsDir#\#ExpandedListingPDF#") and (not Len(ELPTypeThumbnailImage) or not FileExists("#Request.ListingUploadedDocsDir#\#ELPTypeThumbnailImage#"))>
					<cfinclude template="createELPThumbnail.cfm">
				</cfif>
				<table border="0" width="100%">
					<tr>
						<td align="left">							
						 	<cfif not PhoneOnlyListing_fl and ((Len(ExpandedListingHTML) or Len(ExpandedListingPDF)) and (Preview or (not ExpandedListingInProgress and DisplayExpandedListing and HasExpandedListing)))>
								<cfset ShowELPLink="1">
								<p class="bluelarge"><a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)">#ListingTitle#</a></p>
							<cfelse>
								<p class="greenlarge">#ListingTitle#</strong></p>
							</cfif>
							<cfif Len(LogoImage) and FileExists("#Request.ListingUploadedDocsDir#\#LogoImage#")>									
								<a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="ListingUploadedDocs/#LogoImage#" alt="#ListingTitle# Logo" title="#ListingTitle# Logo" class="grayBorderImg"></a><br>
							</cfif>							
							#ShortFieldsContent#
						</td>
						<cfif ShowELPLink and Len(ShowELPTypeThumbnailImage) and FileExists("#Request.ListingUploadedDocsDir#\#ShowELPTypeThumbnailImage#")>
							<td align="center">
								<a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="ListingUploadedDocs/#ShowELPTypeThumbnailImage#" border="0" alt="#ListingTitle# #ELPType#" title="#ListingTitle# #ELPType#" class="grayBorderImg"></a>
								<br>
								<a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="images/inner/psd-magnifier-zoom-icons-2.png" style="padding: 5px 5px 0 0; ">Zoom our <cfif Len(ELPType)>#ELPType#<cfelse>Flier</cfif></a>
							</td>
						</cfif>
					</tr>
				</table>	
				<p><br></p>
				<cfif not PhoneOnlyListing_fl>
	   				<cfif Len(ShortDescr)>
						<p>&nbsp;</p>
						<div style="width:530px;"><strong>About #ListingTitle#: </strong>#ShortDescr#</div>
					</cfif> 	
				</cfif>
				<cfif Len(LocationText)>
					<p>&nbsp;</p>
					<p><strong>Location/Directions: </strong>#LocationText#<br />
	   				</p>
				</cfif>   	
				<cfif not PhoneOnlyListing_fl and ShowELPLink>
	   				<p><br />
	   				</p>
					<p><a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="images/inner/psd-magnifier-zoom-icons-2.png" style="padding: 5px 5px 0 0; ">Zoom our <cfif Len(ELPType)>#ELPType#<cfelse>Flier</cfif></a>
				</cfif>	
   			</div>					
		</cfcase>
		
		<cfcase value="3"><!--- General For Sale by Owner --->
			<div class="listings">
			 	<p class="greenlarge">#ListingTitle#</p>
				<p>
				<cfif Len(PriceUS)><strong>Price:</strong> $US&nbsp;#NumberFormat(PriceUS,",")#<br /><cfelseif Len(PriceTZS)><strong>Price:</strong> TSH&nbsp;#NumberFormat(PriceTZS,",")#<br /></cfif> 
				<strong>Date Listed:</strong> #DateFormat(DateListed,'mmm d, yyyy')#<br />
				<cfif Len(PublicEmail)>
					<p><strong>Email Address:</strong> <span id="EmailLister"><a href="javascript:void(0);" class="ELLink">Click to Email</a><br />
				</cfif>   				
				<cfif Len(PublicPhone)>
					<strong>Phone: </strong>#PublicPhone#<br />
				</cfif>
				<cfif Len(LocationTitles) or Len(LocationOther)>
					<cfset LocationCount=ListLen(LocationTitles)>
					<cfif Len(LocationOther)>
						<cfset LocationCount=LocationCount+1>
					</cfif>
					<strong>Area:</strong> <cfif Len(LocationTitles)>#Replace(LocationTitles,",",", ","ALL")#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#LocationOther#</cfif>
				</cfif>
   				</p>
   				<cfif Len(ShortDescr)>
					<p>&nbsp;</p>
					<div style="width:530px;">#ShortDescr#</div>
				</cfif>	
				<p>&nbsp;</p>
				<cfif getListingImages.RecordCount>
					<table>
						<tr><td colspan="3">Click on an image to view the larger version</td></tr>
						<tr>
							<cfloop query="GetListingImages">
								<cfif CurrentRow neq "1" and CurrentRow Mod 2 is "1">
									</tr>
									<tr>
								</cfif>
								<td valign="top"><a href="#lh_getPageLink(Request.ImageViewerPageID,'imageviewer')##AmpOrQuestion#ListingID=#ListingID#" target="_blank"><img src="../ListingImages/#FileName#" alt="#getListing.ListingTitle# Image" class="ListingImage"></a>&nbsp;&nbsp;&nbsp;</td>
							</cfloop>
						</tr>
					</table>					
				</cfif>	
   			</div>	
		</cfcase>
		
		<cfcase value="4"><!--- For Sale by Owner - Cars & Trucks --->
			<div class="listings">
			 	<p class="greenlarge">#ListingTitle#</p>
				<cfif FSBO4Qualified is 1>
					<p><strong>Reference ##: </strong>#ListingID#<br />
	   				</p>
				</cfif>
				<p>
				<cfif Len(PriceUS)><strong>Price:</strong> $US&nbsp;#NumberFormat(PriceUS,",")#<br /><cfelseif Len(PriceTZS)><strong>Price:</strong> TSH&nbsp;#NumberFormat(PriceTZS,",")#<br /></cfif>
				<cfif Len(Kilometers)><strong>Kilometers:</strong> #Kilometers#<br /></cfif>
				<cfif FourWheelDrive>Four Wheel Drive<br /></cfif>
				<cfif Len(Transmission)><strong>Transmission:</strong> #Transmission#<br /></cfif>
				<strong>Date Listed:</strong> #DateFormat(DateListed,'mmm d, yyyy')#<br />
				<cfif Len(PublicEmail)>
					<p><strong>Email Address:</strong> <span id="EmailLister"><a href="javascript:void(0);" class="ELLink">Click to Email</a><br />
				</cfif>   				
				<cfif Len(PublicPhone)>
					<strong>Phone: </strong>#PublicPhone#<br />
				</cfif>
				<cfif Len(LocationTitles) or Len(LocationOther)>
					<cfset LocationCount=ListLen(LocationTitles)>
					<cfif Len(LocationOther)>
						<cfset LocationCount=LocationCount+1>
					</cfif>
					<strong>Area:</strong> <cfif Len(LocationTitles)>#Replace(LocationTitles,",",", ","ALL")#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#LocationOther#</cfif>
				</cfif>	
   				</p> 
   				<cfif Len(ShortDescr)>
					<p>&nbsp;</p>
					<div style="width:530px;">#ShortDescr#</div>
				</cfif>
				<cfif FSBO4Qualified is 1 and Len(AcctWebsiteURL)>
					<cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>
					<p><strong>Website: </strong><a href="#LocalWebsiteURL#" target="_blank" onClick="clickThroughExternal(#ListingID#)">Go to Website</a><br />
	   				</p>
				</cfif>
				<p>&nbsp;</p>
				<cfif getListingImages.RecordCount>
					<table>
						<tr><td colspan="3">Click on an image to view the larger version</td></tr>
						<tr>
							<cfloop query="GetListingImages">							
								<cfif CurrentRow neq "1" and CurrentRow Mod 2 is "1">
									</tr>
									<tr>
								</cfif>
								<td valign="top" <cfif CurrentRow is "3" and RecordCount is "3">colspan="2"</cfif>><a href="#lh_getPageLink(Request.ImageViewerPageID,'imageviewer')##AmpOrQuestion#ListingID=#ListingID#" target="_blank"><img src="../ListingImages/#FileName#" alt="#getListing.ListingTitle# Image" class="ListingImage"></a></a>&nbsp;&nbsp;&nbsp;</td>
							</cfloop>
						</tr>
					</table>					
				</cfif>	
   			</div>				
		</cfcase>
		
		<cfcase value="5"><!--- FSBO Motorcycles, Mopeds, ATVs, & Vibajaji & FSBO Commercial Trucks --->
			<div class="listings">
			 	<p class="greenlarge">#VehicleYear#<cfif Len(MakeOther)>  #MakeOther#</cfif><cfif Len(ModelOther)> #ModelOther#</cfif></p>
   				<cfif Len(ShortDescr)>
					<p>&nbsp;</p>
					<div style="width:530px;">#ShortDescr#</div>
				</cfif>
				<cfif FSBO4Qualified is 1>
					<p><strong>Reference ##: </strong>#ListingID#<br />
	   				</p>
				</cfif>
				<p>
				<cfif Len(PriceUS)><strong>Price:</strong> $US&nbsp;#NumberFormat(PriceUS,",")#<br /><cfelseif Len(PriceTZS)><strong>Price:</strong> TSH&nbsp;#NumberFormat(PriceTZS,",")#<br /></cfif>
				<strong>Date Listed:</strong> #DateFormat(DateListed,'mmm d, yyyy')#<br />
				<cfif Len(PublicEmail)>
					<p><strong>Email Address:</strong> <span id="EmailLister"><a href="javascript:void(0);" class="ELLink">Click to Email</a><br />
				</cfif>   				
				<cfif Len(PublicPhone)>
					<strong>Phone: </strong>#PublicPhone#<br />
				</cfif>
				<cfif Len(LocationTitles) or Len(LocationOther)>
					<cfset LocationCount=ListLen(LocationTitles)>
					<cfif Len(LocationOther)>
						<cfset LocationCount=LocationCount+1>
					</cfif>
					<strong>Area:</strong> <cfif Len(LocationTitles)>#Replace(LocationTitles,",",", ","ALL")#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#LocationOther#</cfif>
				</cfif>	
   				</p>
				<cfif FSBO4Qualified is 1 and Len(AcctWebsiteURL)>
					<cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>
					<p><strong>Website: </strong><a href="#LocalWebsiteURL#" target="_blank" onClick="clickThroughExternal(#ListingID#)">Go to Website</a><br />
	   				</p>
				</cfif>
				<p>&nbsp;</p>
				<cfif getListingImages.RecordCount>
					<table>
						<tr><td colspan="3">Click on an image to view the larger version</td></tr>
						<tr>
							<cfloop query="GetListingImages">							
								<cfif CurrentRow neq "1" and CurrentRow Mod 2 is "1">
									</tr>
									<tr>
								</cfif>
								<td valign="top" <cfif CurrentRow is "3" and RecordCount is "3">colspan="2"</cfif>><a href="#lh_getPageLink(Request.ImageViewerPageID,'imageviewer')##AmpOrQuestion#ListingID=#ListingID#" target="_blank"><img src="../ListingImages/#FileName#" alt="#getListing.ListingTitle# Image" class="ListingImage"></a>&nbsp;&nbsp;&nbsp;</td>
							</cfloop>
						</tr>
					</table>					
				</cfif>		
   			</div>	
		</cfcase>
		
		<cfcase value="6"><!--- Housing & Real Estate Housing Rentals --->
			<cfquery name="getAmenities" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select A.Title
				From ListingAmenities LA With (NoLock) inner join Amenities A With (NoLock) on LA.AmenityID=A.AmenityID
				Where LA.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
				and A.Active=1
				and A.AmenityID <> 1 <!--- Other) --->
				Order By A.OrderNum
			</cfquery>
			<div class="listings">
			 	<p class="greenlarge">#ListingTitle#</p>
   				<cfif Len(ShortDescr)>
					<p>&nbsp;</p>
					<div style="width:530px;">#ShortDescr#</div>
					<p>&nbsp;</p>
				</cfif>
				<cfif HR4Qualified is 1>
					<p><strong>Reference ##: </strong>#ListingID#<br />
	   				</p>
				</cfif>
				<p>
				
				<cfif Len(RentUS)><strong>Rent:</strong> $US&nbsp;#NumberFormat(RentUS,",")#<cfif Len(Term)>/#Term#</cfif><br /><cfelseif Len(RentTZS)><strong>Rent:</strong> TSH&nbsp;#NumberFormat(RentTZS,",")#<cfif Len(Term)>/#Term#</cfif><br /></cfif>
				<strong>Date Listed:</strong> #DateFormat(DateListed,'mmm d, yyyy')#<br />				
				<cfif Len(PublicEmail)>
					<p><strong>Email Address:</strong> <span id="EmailLister"><a href="javascript:void(0);" class="ELLink">Click to Email</a><br />
				</cfif>   				
				<cfif Len(PublicPhone)>
					<strong>Phone: </strong>#PublicPhone#<br />
				</cfif>
				<cfif Len(Bedrooms)><strong>Bedrooms:</strong> #Bedrooms#<br /></cfif>
				<cfif Len(Bathrooms)><strong>Bathrooms:</strong> #Bathrooms#<br /></cfif>
				<cfif getAmenities.RecordCount or Len(AmenityOther)>
					<p><strong>Amenities:</strong> #Replace(valueList(getAmenities.Title),",",", ","ALL")#<cfif getAmenities.RecordCount>,</cfif> #AmenityOther#<br>
				</cfif>			
				<cfif Len(LocationTitles) or Len(LocationOther)>
					<cfset LocationCount=ListLen(LocationTitles)>
					<cfif Len(LocationOther)>
						<cfset LocationCount=LocationCount+1>
					</cfif>
					<strong>Area<cfif LocationCount gt 1>s</cfif>:</strong> <cfif Len(LocationTitles)>#Replace(LocationTitles,",",", ","ALL")#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#LocationOther#</cfif>
				</cfif>	
				<cfif Len(LocationText)> - #LocationText#</cfif>
   				</p> 
				<cfif Len(AcctWebsiteURL)>
					<cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>
					<p><strong>Website: </strong><a href="#LocalWebsiteURL#" target="_blank" onClick="clickThroughExternal(#ListingID#)">Go to Website</a><br />
	   				</p>
				</cfif>
				<cfif HR4Qualified  is 1 and Len(AccountName)>
					<p><strong>#AccountName#</strong><br />
	   				</p>
				</cfif>
				<p>&nbsp;</p>
				<cfif getListingImages.RecordCount>
					<table>
						<tr><td colspan="3">Click on an image to view the larger version</td></tr>
						<tr>
							<cfloop query="GetListingImages">								
								<cfif CurrentRow neq "1" and CurrentRow Mod 2 is "1">
									</tr>
									<tr>
								</cfif>
								<td valign="top" <cfif CurrentRow is "3" and RecordCount is "3">colspan="2"</cfif>><a href="#lh_getPageLink(Request.ImageViewerPageID,'imageviewer')##AmpOrQuestion#ListingID=#ListingID#" target="_blank"><img src="../ListingImages/#FileName#" alt="#getListing.ListingTitle# Image" class="ListingImage"></a>&nbsp;&nbsp;&nbsp;</td>
							</cfloop>
						</tr>
					</table>					
				</cfif>	
   			</div>	
		</cfcase>
		
		<cfcase value="7"><!--- Housing & Real Estate Commercial Rentals --->
			<cfif Len(SquareFeet) or Len(SquareMeters)>
				<cfif Len(SquareFeet)>
					<cfset LocalSquareFeet=SquareFeet>
					<cfset LocalSquareMeters=0.092903*SquareFeet>
				<cfelse>
					<cfset LocalSquareMeters=SquareMeters>
					<cfset LocalSquareFeet=10.7639*SquareMeters>
				</cfif>
			</cfif>
			<div class="listings">
			 	<p class="greenlarge">#ListingTitle#<cfif Len(SquareFeet) or Len(SquareMeters)> <span class="nowrap">#Round(LocalSquareFeet)# ft<sup>2</sup>/#NumberFormat(LocalSquareMeters,",.9")# m<sup>2</sup></span></cfif></p>
   				<cfif Len(ShortDescr)>
					<p>&nbsp;</p>
					<div style="width:530px;">#ShortDescr#</div>
					<p>&nbsp;</p>
				</cfif>
				<cfif HR4Qualified is 1>
					<p><strong>Reference ##: </strong>#ListingID#<br />
	   				</p>
				</cfif>
				<p>
				<cfif Len(Term)><strong>Term:</strong> #Term#<br /></cfif>
				<cfif Len(RentUS)><strong>Rent:</strong> $US&nbsp;#NumberFormat(RentUS,",")#<br /><cfelseif Len(RentTZS)><strong>Rent:</strong> TSH&nbsp;#NumberFormat(RentTZS,",")#<br /></cfif>
				<cfif Len(SquareFeet) or Len(SquareMeters)>
					<strong>Square Feet/Meters: </strong>
					#Round(LocalSquareFeet)# ft<sup>2</sup>/#NumberFormat(LocalSquareMeters,",.9")# m<sup>2</sup><br />
				</cfif>
				<strong>Date Listed:</strong> #DateFormat(DateListed,'mmm d, yyyy')#<br />
				<cfif Len(AccountName)>#AccountName#<br /></cfif>
				<cfif Len(PublicEmail)>
					<p><strong>Email Address:</strong> <span id="EmailLister"><a href="javascript:void(0);" class="ELLink">Click to Email</a><br />
				</cfif>   				
				<cfif Len(PublicPhone)>
					<strong>Phone: </strong>#PublicPhone#<br />
				</cfif>		
				<cfif Len(LocationTitles) or Len(LocationOther)>
					<cfset LocationCount=ListLen(LocationTitles)>
					<cfif Len(LocationOther)>
						<cfset LocationCount=LocationCount+1>
					</cfif>
					<strong>Area<cfif LocationCount gt 1>s</cfif>:</strong> <cfif Len(LocationTitles)>#Replace(LocationTitles,",",", ","ALL")#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#LocationOther#</cfif>
					<cfif Len(LocationText)> - #LocationText#</cfif>
				</cfif>					
   				</p> 
				<cfif Len(AcctWebsiteURL)>
					<cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>
					<p><strong>Website: </strong><a href="#LocalWebsiteURL#" target="_blank" onClick="clickThroughExternal(#ListingID#)">Go to Website</a><br />
	   				</p>
				</cfif>
				<cfif HR4Qualified is 1 and Len(AccountName)>
					<p><strong>#AccountName#</strong>
	   				</p>
				</cfif>
				<p>&nbsp;</p>
				<cfif getListingImages.RecordCount>
					<table>
						<tr><td colspan="3">Click on an image to view the larger version</td></tr>
						<tr>
							<cfloop query="GetListingImages">							
								<cfif CurrentRow neq "1" and CurrentRow Mod 2 is "1">
									</tr>
									<tr>
								</cfif>
								<td valign="top" <cfif CurrentRow is "3" and RecordCount is "3">colspan="2"</cfif>><a href="#lh_getPageLink(Request.ImageViewerPageID,'imageviewer')##AmpOrQuestion#ListingID=#ListingID#" target="_blank"><img src="../ListingImages/#FileName#" alt="#getListing.ListingTitle# Image" class="ListingImage"></a>&nbsp;&nbsp;&nbsp;</td>
							</cfloop>
						</tr>
					</table>					
				</cfif>	
   			</div>	
		</cfcase>
		
		<cfcase value="8"><!--- Housing & Real Estate For Sale --->
			<cfquery name="getAmenities" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select A.Title
				From ListingAmenities LA With (NoLock) inner join Amenities A With (NoLock) on LA.AmenityID=A.AmenityID
				Where LA.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
				and A.Active=1
				and A.AmenityID <> 1 <!--- Other) --->
				Order By A.OrderNum
			</cfquery>
			<div class="listings">
			 	<p class="greenlarge">#ListingTitle#</p>
   				<cfif Len(ShortDescr)>
					<p>&nbsp;</p>
					<div style="width:530px;">#ShortDescr#</div>
					<p>&nbsp;</p>
				</cfif>
				<cfif HR4Qualified is 1>
					<p><strong>Reference ##: </strong>#ListingID#<br />
	   				</p>
				</cfif>
				<p>
				<cfif Len(PriceUS)><strong>Price:</strong> $US&nbsp;#NumberFormat(PriceUS,",")#<br /><cfelseif Len(PriceTZS)><strong>Price:</strong> TSH&nbsp;#NumberFormat(PriceTZS,",")#<br /></cfif>
				<strong>Date Listed:</strong> #DateFormat(DateListed,'mmm d, yyyy')#<br />
				<cfif Len(AccountName)>#AccountName#<br /></cfif>
				<cfif Len(PublicEmail)>
					<p><strong>Email Address:</strong> <span id="EmailLister"><a href="javascript:void(0);" class="ELLink">Click to Email</a><br />
				</cfif>   				
				<cfif Len(PublicPhone)>
					<strong>Phone: </strong>#PublicPhone#<br />
				</cfif>		
				<cfif ListFind(CategoryID,"89")>		
					<cfif Len(Bedrooms)><strong>Bedrooms:</strong> #Bedrooms#<br /></cfif>
					<cfif Len(Bathrooms)><strong>Bathrooms:</strong> #Bathrooms#<br /></cfif>
					<cfif getAmenities.RecordCount or Len(AmenityOther)>
						<p><strong>Amenities:</strong> #Replace(valueList(getAmenities.Title),",",", ","ALL")#<cfif getAmenities.RecordCount>,</cfif> #AmenityOther#<br>
					</cfif>	
				</cfif>
				<cfif Len(LocationTitles) or Len(LocationOther)>
					<cfset LocationCount=ListLen(LocationTitles)>
					<cfif Len(LocationOther)>
						<cfset LocationCount=LocationCount+1>
					</cfif>
					<strong>Area<cfif LocationCount gt 1>s</cfif>:</strong> <cfif Len(LocationTitles)>#Replace(LocationTitles,",",", ","ALL")#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#LocationOther#</cfif>
					<cfif Len(LocationText)> - #LocationText#</cfif>
				</cfif>	
   				</p>
				<cfif Len(AcctWebsiteURL)>
					<cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>
					<p><strong>Website: </strong><a href="#LocalWebsiteURL#" target="_blank" onClick="clickThroughExternal(#ListingID#)">Go to Website</a><br />
	   				</p>
				</cfif> 
				<cfif HR4Qualified is 1 and Len(AccountName)>
					<strong>#AccountName#</strong><br />
				</cfif>
				<p>&nbsp;</p>
				<cfif getListingImages.RecordCount>
					<table>
						<tr><td colspan="3">Click on an image to view the larger version</td></tr>
						<tr>
							<cfloop query="GetListingImages">							
								<cfif CurrentRow neq "1" and CurrentRow Mod 2 is "1">
									</tr>
									<tr>
								</cfif>
								<td valign="top" <cfif CurrentRow is "3" and RecordCount is "3">colspan="2"</cfif>><a href="#lh_getPageLink(Request.ImageViewerPageID,'imageviewer')##AmpOrQuestion#ListingID=#ListingID#" target="_blank"><img src="../ListingImages/#FileName#" alt="#getListing.ListingTitle# Image" class="ListingImage"></a>&nbsp;&nbsp;&nbsp;</td>
							</cfloop>
						</tr>
					</table>					
				</cfif>	
   			</div>	
		</cfcase>
		
		<cfcase value="9"><!--- Travel & Tourism (Trip Listings) --->
			 <div class="listings">
			 	
				<cfsavecontent variable="ShortFieldsContent">
					<p><br></p>
					<p>
					<cfif Len(PriceUS)><strong>Minimum Price:</strong> $US&nbsp;#NumberFormat(PriceUS,",")#<br /><cfelseif Len(PriceTZS)><strong>Minimum Price:</strong> TSH&nbsp;#NumberFormat(PriceTZS,",")#<br /></cfif>
					<cfif Len(PublicEmail)>
						<strong>Email Address:</strong> <span id="EmailLister"><a href="javascript:void(0);" class="ELLink">Click to Email</a><br />
					</cfif>   				
					<cfif Len(PublicPhone)>
						<strong>Phone: </strong>#PublicPhone#<br />
					</cfif>
					<cfif Len(AcctWebsiteURL)>
						<cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>
						<p><strong>Website: </strong><a href="#LocalWebsiteURL#" target="_blank" onClick="clickThroughExternal(#ListingID#)">Go to Website</a><br />
		   				</p>
					</cfif>
	   				</p>	
				</cfsavecontent>
				<cfset showELPLink="0">
				<cfset ShowELPTypeThumbnailImage=ELPTypeThumbnailImage>
				<cfif Len(ExpandedListingPDF) and FileExists("#Request.ListingUploadedDocsDir#\#ExpandedListingPDF#") and (not Len(ELPTypeThumbnailImage) or not FileExists("#Request.ListingUploadedDocsDir#\#ELPTypeThumbnailImage#"))>
					<cfinclude template="createELPThumbnail.cfm">
				</cfif>
				<table border="0" width="100%">
					<tr>
						<td align="left">
							<cfif (Len(ExpandedListingHTML) or Len(ExpandedListingPDF)) and ((Preview and Len(session.UserID) and (InProgressUserID is session.UserID or UserID is session.UserID or IsDefined('cookie.LHLoggedIn'))) or (not ExpandedListingInProgress and DisplayExpandedListing and HasExpandedListing))>
								<cfset ShowELPLink="1">
								<p class="bluelarge"><a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)">#ListingTitle#</a></p>
							<cfelse>
								<p class="greenlarge">#ListingTitle#</strong></p>
							</cfif>
							<cfif Len(LogoImage) and FileExists("#Request.ListingUploadedDocsDir#\#LogoImage#")>
								<cfif ShowELPLink>
									<a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="ListingUploadedDocs/#LogoImage#" alt="#ListingTitle# Logo" title="#ListingTitle# Logo" class="grayBorderImg"></a>
								<cfelse>
									<img src="ListingUploadedDocs/#LogoImage#" alt="#ListingTitle# Logo" title="#ListingTitle# Logo" class="grayBorderImg">
								</cfif><br>									
							</cfif>
							#ShortFieldsContent#
						</td>
						<cfif ShowELPLink and Len(ShowELPTypeThumbnailImage) and FileExists("#Request.ListingUploadedDocsDir#\#ShowELPTypeThumbnailImage#")>
							<td align="center">
								<a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="ListingUploadedDocs/#ShowELPTypeThumbnailImage#" border="0" alt="#ListingTitle# #ELPType#" title="#ListingTitle# #ELPType#" class="grayBorderImg"></a>
								<br>
								<a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="images/inner/psd-magnifier-zoom-icons-2.png" style="padding: 5px 5px 0 0; ">Zoom our <cfif Len(ELPType)>#ELPType#<cfelse>Flier</cfif></a><br>
							</td>
						</cfif>
					</tr>
				</table>		
				<p><br></p>
   				<cfif Len(ShortDescr)>
					<p>&nbsp;</p>
					<div style="width:530px;"><strong>About #ListingTitle#: </strong>#ShortDescr#</div>
				</cfif>
    			<cfif ShowELPLink>	
	   				<p><br />
	   				</p>
					<p><a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="images/inner/psd-magnifier-zoom-icons-2.png" style="padding: 5px 5px 0 0; ">Zoom our <cfif Len(ELPType)>#ELPType#<cfelse>Flier</cfif></a>
				</cfif>	
   			</div>	
		</cfcase>
		
		<cfcase value="10"><!--- Jobs & Employment Professional (employment opportunities) --->
			 <div class="listings">
			 	<p class="greenlarge">#ShortDescr#</p>
   				<cfif Len(ListingTitle)>
					<p>#ListingTitle#</p>
				</cfif>
   				<p>&nbsp;</p>
				<strong>Date Listed:</strong> #DateFormat(DateListed,'mmm d, yyyy')#<br />	
				<cfif Len(PublicEmail)>
					<p><strong>Email Address:</strong> <span id="EmailLister"><a href="javascript:void(0);" class="ELLink">Click to Email</a><br />
				</cfif>   				
				<cfif Len(PublicPhone)>
					<strong>Phone: </strong>#PublicPhone#<br />
				</cfif>		
				<cfif Len(LocationTitles) or Len(LocationOther)>
					<cfset LocationCount=ListLen(LocationTitles)>
					<cfif Len(LocationOther)>
						<cfset LocationCount=LocationCount+1>
					</cfif>
					<strong>Area<cfif LocationCount gt 1>s</cfif>:</strong> <cfif Len(LocationTitles)>#Replace(LocationTitles,",",", ","ALL")#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#LocationOther#</cfif><br />
				</cfif>	
				<cfif Len(Deadline)>
					<strong>Application Deadline: </strong>#DateFormat(Deadline,"mmm dd, yyyy")#<br />
				</cfif>		
				<cfif Len(EventStartDate)>
					<strong>Start Date: </strong>#DateFormat(EventStartDate,"mmm dd, yyyy")#<br />
				</cfif>	
				<cfif Len(LongDescr)>
					</p><p>&nbsp;</p><p>
					<strong><cfif CategoryID is "289">Tender<cfelse>Position</cfif> Description:</strong><br />#LongDescr#<br />
				<cfelseif Len(UploadedDoc)>
					<strong><cfif CategoryID is "289">Tender<cfelse>Position</cfif> Description:</strong> <a href="../ListingUploadedDocs/#UploadedDoc#" target="_blank">Click&nbsp;Here</a><br />
				</cfif>
				<cfif Len(Instructions)>
					</p><p>&nbsp;</p><p>
					<strong>Application Instructions:</strong><br />#Instructions#<br />
				</cfif>	
				<cfif Len(WebsiteURL)>
					<cfif Left(WebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & WebsiteURL><cfelse><cfset LocalWebsiteURL=WebsiteURL></cfif>
					<p><strong>Website: </strong><a href="#LocalWebsiteURL#" target="_blank" onClick="clickThroughExternal(#ListingID#)">Go to Website</a><br />
					</p>
				<!--- <cfelseif Len(AcctWebsiteURL)>
					<cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>
					<p><strong>Website: </strong><a href="#LocalWebsiteURL#" target="_blank" onClick="clickThroughExternal(#ListingID#)">Go to Website</a><br />
	   				</p> --->
				</cfif>
   				</p>		
   				<p><br />
   				</p>
   			</div>	
		</cfcase>
		
		<cfcase value="11"><!--- Jobs & Employment Professional (seeking employment) --->
			 <div class="listings">
			 	<p class="greenlarge">#ListingTitle#</p>
				<cfif Len(ShortDescr)>
					<p>&nbsp;</p>
					<div style="width:530px;">#ShortDescr#</div>
				</cfif>
   				<p>&nbsp;</p>
				<p><strong>Date Listed:</strong> #DateFormat(DateListed,'mmm d, yyyy')#<br />	
				<cfif Len(PublicEmail)>
					<p><strong>Email Address:</strong> <span id="EmailLister"><a href="javascript:void(0);" class="ELLink">Click to Email</a><br />
				</cfif>   				
				<cfif Len(PublicPhone)>
					<strong>Phone: </strong>#PublicPhone#<br />
				</cfif>
				<cfif Len(LongDescr)>
					</p><p>&nbsp;</p><p>
					<strong>Resume/CV:</strong><br />#LongDescr#<br />
				<cfelseif Len(UploadedDoc)>
					<strong>Resume/CV:</strong> <a href="../ListingUploadedDocs/#UploadedDoc#" target="_blank">Click&nbsp;Here</a><br />
				</cfif>
   				</p>		
   				<p><br />
   				</p>
   			</div>	
		</cfcase>
		
		<cfcase value="12"><!--- Jobs & Employment Domestic Staff (employment opportunities) --->
			 <div class="listings">
			 	<p class="greenlarge">#ShortDescr#</p>
				<p><strong>Date Listed:</strong> #DateFormat(DateListed,'mmm d, yyyy')#<br />	
				<cfif Len(PublicEmail)>
					<p><strong>Email Address:</strong> <span id="EmailLister"><a href="javascript:void(0);" class="ELLink">Click to Email</a><br />
				</cfif>   				
				<cfif Len(PublicPhone)>
					<strong>Phone: </strong>#PublicPhone#<br />
				</cfif>
				<cfif Len(LocationTitles) or Len(LocationOther)>
					<cfset LocationCount=ListLen(LocationTitles)>
					<cfif Len(LocationOther)>
						<cfset LocationCount=LocationCount+1>
					</cfif>
					<strong>Area<cfif LocationCount gt 1>s</cfif>:</strong> <cfif Len(LocationTitles)>#Replace(LocationTitles,",",", ","ALL")#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#LocationOther#</cfif>
				</cfif>	
				<cfif Len(Deadline)>
					<strong>Application Deadline: </strong> #DateFormat(Deadline,"mmm dd, yyyy")#<br />
				</cfif>		
				<!--- <cfif Len(AcctWebsiteURL)>
					<cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>
					<p><strong>Website: </strong><a href="#LocalWebsiteURL#" target="_blank" onClick="clickThroughExternal(#ListingID#)">Go to Website</a><br />
	   				</p>
				</cfif>	 --->
				<cfif Len(LongDescr)>
					</p><p>&nbsp;</p><p>
					<strong>Position Description:</strong><br />#LongDescr#<br />
				</cfif>
   				</p>	
   				<p><br />
   				</p>
   			</div>	
		</cfcase>
		
		<cfcase value="13"><!--- Jobs & Employment Domestic Staff (seeking employment) --->
			 <div class="listings">
			 	<p class="greenlarge">#ListingTitle#</p>
				<cfif Len(ShortDescr)>
					<p>&nbsp;</p>
					<div style="width:530px;">#ShortDescr#</div>
				</cfif>
				<p><strong>Date Listed:</strong> #DateFormat(DateListed,'mmm d, yyyy')#<br />	
				<cfif Len(PublicEmail)>
					<p><strong>Email Address:</strong> <span id="EmailLister"><a href="javascript:void(0);" class="ELLink">Click to Email</a><br />
				</cfif>   				
				<cfif Len(PublicPhone)>
					<strong>Phone: </strong>#PublicPhone#<br />
				</cfif>
				<cfif Len(LongDescr)>
					</p><p>&nbsp;</p><p>
					<strong>Experience & Qualifications:</strong><br />#LongDescr#<br />
				</cfif>
   				</p>		
   				<p><br />
   				</p>
   			</div>	
		</cfcase>	
		
		<cfcase value="14"><!--- Community --->
			<cfquery name="getNGOTypes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select NT.Title
				From ListingNGOTypes LNT With (NoLock) inner join NGOTypes NT With (NoLock) on LNT.NGOTypeID=NT.NGOTypeID
				Where LNT.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
				and NT.Active=1
				and NT.NGOTypeID <> 1 <!--- Other --->
				Order By NT.OrderNum
			</cfquery>
			<cfset showELPLink="0">
			<cfsavecontent variable="ShortFieldsContent">
			<cfif getNGOTypes.RecordCount or Len(NGOTypeOther)>
				<p><strong>NGO Type<cfif getNGOTypes.RecordCount gt 1 or (getNGOTypes.RecordCount and Len(NGOTypeOther))>s</cfif>:</strong> #Replace(valueList(getNGOTypes.Title),",",", ","ALL")#<cfif getNGOTypes.RecordCount and Len(NGOTypeOther)>,</cfif> #NGOTypeOther#<br>
			</cfif>	
  				<p>&nbsp;</p>
			<cfif not PhoneOnlyListing_fl and Len(PublicEmail)>
				<p><strong>Email Address:</strong> <span id="EmailLister"><a href="javascript:void(0);" class="ELLink">Click to Email</a><br />
			</cfif>   								
			<cfif Len(PublicPhone)>
				<strong>Phone&nbsp;##: </strong>#PublicPhone#<br />
			</cfif> 				
			<cfif Len(PublicPhone2)>
				<strong>Fax&nbsp;##: </strong>#PublicPhone2#<br />
			</cfif>		
			<cfif Len(PublicPhone3)>
				<strong>Other Phone&nbsp;##: </strong>#PublicPhone3#<br />
			</cfif>		
			<cfif Len(PublicPhone4)>
				<strong>Other Phone&nbsp;##: </strong>#PublicPhone4#<br />
			</cfif>								
			<cfif Len(LocationTitles) or Len(LocationOther)>
				<cfset LocationCount=ListLen(LocationTitles)>
				<cfif Len(LocationOther)>
					<cfset LocationCount=LocationCount+1>
				</cfif>
				<strong>Area<cfif LocationCount gt 1>s</cfif>:</strong> <cfif Len(LocationTitles)>#Replace(LocationTitles,",",", ","ALL")#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#LocationOther#</cfif>
			</cfif>	
  				</p>
			</cfsavecontent>
			 <div class="listings">
				<cfset ShowELPTypeThumbnailImage=ELPTypeThumbnailImage>
				<cfif Len(ExpandedListingPDF) and FileExists("#Request.ListingUploadedDocsDir#\#ExpandedListingPDF#") and (not Len(ELPTypeThumbnailImage) or not FileExists("#Request.ListingUploadedDocsDir#\#ELPTypeThumbnailImage#"))>
					<cfinclude template="createELPThumbnail.cfm">
				</cfif>
				<table border="0" width="100%">
					<tr>
						<td align="left">									
		 					<cfif not PhoneOnlyListing_fl and ((Len(ExpandedListingHTML) or Len(ExpandedListingPDF)) and (Preview or (not ExpandedListingInProgress and DisplayExpandedListing and HasExpandedListing)))>
								<cfset ShowELPLink="1">
								<p class="bluelarge"><a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)">#ListingTitle#</a></p>
							<cfelse>
								<p class="greenlarge">#ListingTitle#</strong></p>
							</cfif>
							<cfif Len(LogoImage) and FileExists("#Request.ListingUploadedDocsDir#\#LogoImage#")>
								<cfif ShowELPLink>
									<a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="ListingUploadedDocs/#LogoImage#" alt="#ListingTitle# Logo" title="#ListingTitle# Logo" class="grayBorderImg"></a>
								<cfelse>
									<img src="ListingUploadedDocs/#LogoImage#" alt="#ListingTitle# Logo" title="#ListingTitle# Logo" class="grayBorderImg">
								</cfif>
								<br>							
							</cfif>
							#ShortFieldsContent#
						</td>
						<cfif ShowELPLink and Len(ShowELPTypeThumbnailImage) and FileExists("#Request.ListingUploadedDocsDir#\#ShowELPTypeThumbnailImage#")>
							<td align="center">
								<a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="ListingUploadedDocs/#ShowELPTypeThumbnailImage#" border="0" alt="#ListingTitle# #ELPType#" title="#ListingTitle# #ELPType#" class="grayBorderImg"></a>
								<br>
								<a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="images/inner/psd-magnifier-zoom-icons-2.png" style="padding: 5px 5px 0 0; ">Zoom our <cfif Len(ELPType)>#ELPType#<cfelse>Flier</cfif></a>
							</td>
						</cfif>
					</tr>
				</table>	
				<cfif not PhoneOnlyListing_fl>
					<cfif Len(WebsiteURL)>
						<cfif Left(WebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & WebsiteURL><cfelse><cfset LocalWebsiteURL=WebsiteURL></cfif>
						<p><strong>Website: </strong><a href="#LocalWebsiteURL#" target="_blank" onClick="clickThroughExternal(#ListingID#)">Go to Website</a><br />
		   				</p>
					</cfif>
	   				<cfif Len(ShortDescr)>
						<p>&nbsp;</p>
						<div style="width:530px;"><strong>About #ListingTitle#: </strong>#ShortDescr#</div>
					</cfif> 	
				</cfif>
				<cfif Len(LocationText)>
					<p>&nbsp;</p>
					<p><strong>Location/Directions: </strong>#LocationText#<br />
	   				</p>
				</cfif> 
				<cfif not PhoneOnlyListing_fl and ShowELPLink>
	   				<p><br />
	   				</p>
					<p><a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="images/inner/psd-magnifier-zoom-icons-2.png" style="padding: 5px 5px 0 0; ">Zoom our <cfif Len(ELPType)>#ELPType#<cfelse>Flier</cfif></a>
				</cfif>
   			</div>	
		</cfcase>
		
		<cfcase value="15"><!--- Events --->
			 <div class="listings">
				<cfsavecontent variable="ShortFieldsContent">
					<p>&nbsp;</p>				
					<cfif Len(EventStartDate)>
						<cfif Len(RecurrenceID)>
							<strong>Recurrence:</strong>
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
										from RecurrenceMonths  With (NoLock)
										where recurrenceMonthID = <cfqueryparam value="#RecurrenceMonthID#" cfsqltype="CF_SQL_INTEGER">			
									</cfquery>
									Repeats Monthly on the #ReplaceNoCase(getRecurrenceMonth.descr,"5th","Last")# of Each Month
								</cfcase>
							</cfswitch>
							&nbsp;#TimeFormat(EventStartDate)#<cfif Len(EventEndDate)> - #TimeFormat(EventEndDate)#</cfif><br>
						<cfelse>
							<strong>Event Date<cfif Len(EventEndDate)>s</cfif>:</strong> #DateFormat(EventStartDate,"mmm dd, yyyy")# #TimeFormat(EventStartDate)#<cfif Len(EventEndDate)> - #DateFormat(EventEndDate,"mmm dd, yyyy")# #TimeFormat(EventEndDate)#</cfif><br />
						</cfif>
					</cfif>
					<cfif Len(PublicEmail)>
						<p><strong>Email Address:</strong> <span id="EmailLister"><a href="javascript:void(0);" class="ELLink">Click to Email</a><br />
					</cfif>   				
					<cfif Len(PublicPhone)>
						<strong>Phone: </strong>#PublicPhone#<br />
					</cfif>		
					<cfif Len(LocationTitles) or Len(LocationOther)>
						<cfset LocationCount=ListLen(LocationTitles)>
						<cfif Len(LocationOther)>
							<cfset LocationCount=LocationCount+1>
						</cfif>
						<strong>Area<cfif LocationCount gt 1>s</cfif>:</strong> <cfif Len(LocationTitles)>#Replace(LocationTitles,",",", ","ALL")#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#LocationOther#</cfif>
					</cfif>	
	   				</p>
					<cfif Len(WebsiteURL)>
						<cfif Left(WebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & WebsiteURL><cfelse><cfset LocalWebsiteURL=WebsiteURL></cfif>
						<p><strong>Website: </strong><a href="#LocalWebsiteURL#" target="_blank" onClick="clickThroughExternal(#ListingID#)">Go to Website</a><br />
		   				</p>
					</cfif>
				</cfsavecontent>
				<cfset ShowELPLink="0">
				<cfset ShowELPTypeThumbnailImage=ELPTypeThumbnailImage>
				<cfif Len(ExpandedListingPDF) and FileExists("#Request.ListingUploadedDocsDir#\#ExpandedListingPDF#") and (not Len(ELPTypeThumbnailImage) or not FileExists("#Request.ListingUploadedDocsDir#\#ELPTypeThumbnailImage#"))>
					<cfinclude template="createELPThumbnail.cfm">
				</cfif>
				<table border="0" width="100%">
					<tr>	
						<td align="left">								
						 	<cfif (Len(ExpandedListingHTML) or Len(ExpandedListingPDF)) and ((Preview and Len(session.UserID) and (InProgressUserID is session.UserID or UserID is session.UserID or IsDefined('cookie.LHLoggedIn'))) or (not ExpandedListingInProgress and DisplayExpandedListing and HasExpandedListing))>
								<cfset ShowELPLink="1">
								<p class="bluelarge"><a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)">#ListingTitle#</a></p>
							<cfelse>
								<p class="greenlarge">#ListingTitle#</strong></p>
							</cfif>
							#ShortFieldsContent#
						</td>
						<cfif showELPLink and Len(ShowELPTypeThumbnailImage) and FileExists("#Request.ListingUploadedDocsDir#\#ShowELPTypeThumbnailImage#")>
							<td align="center">
								<a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="ListingUploadedDocs/#ShowELPTypeThumbnailImage#" border="0" alt="#ListingTitle# #ELPType#" title="#ListingTitle# #ELPType#" class="grayBorderImg"></a>
								<br>
								<a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="images/inner/psd-magnifier-zoom-icons-2.png" style="padding: 5px 5px 0 0; ">Zoom our <cfif Len(ELPType)>#ELPType#<cfelse>Flier</cfif></a>									
							</td>
						</cfif>
					</tr>
				</table>	
				<p><br></p>
   				<cfif Len(ShortDescr)>
					<p>&nbsp;</p>
					<div style="width:530px;"><strong>About #ListingTitle#: </strong>#ShortDescr#</div>
				</cfif> 	
				<cfif Len(LocationText)>
					<p>&nbsp;</p>
					<p><strong>Location/Directions: </strong>#LocationText#<br />
	   				</p>
				</cfif> 
    			<cfif showELPLink>	
	   				<p><br />
	   				</p>
					<p><a href="<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelseif Right(ExpandedListingPDF,3) contains "pdf">ListingUploadedDocs/#ExpandedListingPDF#<cfelse>#lh_getPageLink(Request.ImageBasedELPPageID,'zoomedlisting')##AmpOrQuestion#ListingID=#ListingID#</cfif>"  onClick="clickThroughExpanded(#ListingID#)"><img src="images/inner/psd-magnifier-zoom-icons-2.png" style="padding: 5px 5px 0 0; ">Zoom our <cfif Len(ELPType)>#ELPType#<cfelse>Flier</cfif></a>
				</cfif>
   			</div>
		</cfcase>		
	</cfswitch>
	
	<cfif Len(PublicEmail)>
		<cfif ListFind("10,12",ListingTypeID) and (not IsDefined('session.UserID') or not Len(session.UserID))>
			<div id="LoginToApplyForm" style="display:none;">&nbsp;
				<cfinclude template="LoginToApplyForm.cfm">
				<br>
				<a id="CancelLoginToApplyForm"><input type="button" name="cancel" id="cancel" value="Cancel"></a>
			</div>
		<cfelseif ListFind("10,12",ListingTypeID) and IsDefined('session.UserID') and Len(session.UserID) and Len(ClickCount) and ClickCount gte application.JobClickPerDayLimit>
			<div id="JobLimitPerDayReached" style="display:none;">&nbsp;
				<lh:MS_SitePagePart id="bodyJobClickLimit" class="body">
				<br>
				<a id="CancelJobLimitPerDayReached"><input type="button" name="cancel" id="cancel" value="Cancel"></a>
			</div>		
		<cfelseif ShowCodeOfConduct and ListFind("10,12",ListingTypeID) and IsDefined('session.UserID') and Len(session.UserID)>
			<div id="CodeOfConductForm" style="display:none;">&nbsp;
				<cfinclude template="CodeOfConductToApplyForm.cfm">
				<br>
				<a id="CancelCodeOfConductForm"><input type="button" name="cancel" id="cancel" value="Cancel"></a>
			</div>
		<cfelse>
			<div id="EmailForm" style="display:none;">&nbsp;
				<cfinclude template="EmailListerForm.cfm">
				<br>
				<a id="CancelEmailForm"><input type="button" name="cancel" id="cancel" value="Cancel"></a>
			</div>
		</cfif>
		<cfset HasPublicEmail="1">
	<cfelse>
		<p>&nbsp;</p>	
	</cfif>
	<span class="pagination float-right" id="BadListingDiv">
		<a href="javascript:void(0);" class="BLLink">Report Bad Listings</a>
	</span>
	<div id="BadListingForm" style="display:none;">&nbsp;
		<cfinclude template="BadListingForm.cfm">
		<br>
		<a id="CancelBadListingForm"><input type="button" name="cancel" id="cancel" value="Cancel"></a>
	</div>
</cfoutput>

	<script>
		$(document).ready(function() {
			<cfif HasPublicEmail>
				$('.ELLink').click(function() {
					<cfif ListFind("10,12",getListing.ListingTypeID) and (not IsDefined('session.UserID') or not Len(session.UserID))>
						$("#LoginToApplyForm").show("slow");
					  	$(".listings").hide("slow");	
				  	<cfelseif ListFind("10,12",getListing.ListingTypeID) and IsDefined('session.UserID') and Len(session.UserID) and Len(ClickCount) and ClickCount gte application.JobClickPerDayLimit>				  
						$("#JobLimitPerDayReached").show("slow");
					  	$(".listings").hide("slow");
					<cfelseif ShowCodeOfConduct and ListFind("10,12",getListing.ListingTypeID) and IsDefined('session.UserID') and Len(session.UserID)>
						$("#CodeOfConductForm").show("slow");
					  	$(".listings").hide("slow");
					<cfelse>
						captchaRefresh();
						$("#EmailForm").show("slow");
					  	$(".listings").hide("slow");
					</cfif>
				});
				<cfif IsDefined('statusMessage') and statusMessage is "MNS" and ListFind("10,12",getListing.ListingTypeID) and IsDefined('session.UserID') and Len(session.UserID) and Len(ClickCount) and ClickCount gte application.JobClickPerDayLimit>
					$("#JobLimitPerDayReached").show();
				  	$(".listings").hide();
				</cfif>
				$("#CancelEmailForm").click(function() {
					$("#EmailForm").hide("slow");
				  	$(".listings").show("slow");			
				});
				$("#CancelLoginToApplyForm").click(function() {
					$("#LoginToApplyForm").hide("slow");
				  	$(".listings").show("slow");
				});
				$("#CancelJobLimitPerDayReached").click(function() {
					$("#JobLimitPerDayReached").hide("slow");
				  	$(".listings").show("slow");
				});
				$("#CancelCodeOfConductForm").click(function() {
					$("#CodeOfConductForm").hide("slow");
				  	$(".listings").show("slow");
				});
				<cfif IsDefined('ShowEmail')>
					captchaRefresh();
					$("#EmailForm").show("slow");
				  	$(".listings").hide("slow");
				</cfif>
				<cfif IsDefined('msg') and Left(msg,16) is "Invalid username">
					$("#LoginToApplyForm").show();
					$(".listings").hide();
				<cfelseif ListFind("10,12",getListing.ListingTypeID) and IsDefined('session.UserID') and Len(session.UserID) and CE>
					<cfif ShowCodeOfConduct><!--- Need to fill out Code of Conduct --->
						$("#CodeOfConductForm").show();
					  	$(".listings").hide();
					<cfelse>
						captchaRefresh();
						$("#EmailForm").show();
					  	$(".listings").hide();
					</cfif>
				</cfif>
			</cfif>
			$('.BLLink').click(function() {
				captchaRefreshBL();
				$("#BadListingForm").show("slow");
				$("#BadListingDiv").hide("slow");
			  	$(".listings").hide("slow");
			});
			$("#CancelBadListingForm").click(function() {
				$("#BadListingForm").hide("slow");
			  	$(".listings").show("slow");	
				$("#BadListingDiv").show("slow");		
			});
		});
	</script>

	
