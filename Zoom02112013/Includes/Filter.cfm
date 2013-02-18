<cfparam name="FilterForm" default="">
<cfparam name="FilterCriteria" default="">
<cfparam name="FitlerWhereClause" default="">
<cfparam name="FilterAction" default="#lh_getPageLink(2,'category')#">
<cfparam name="FilterParkCategory" default="0">
<cfparam name="FilterAdditionalParams" default="">
<cfparam name="CategoryPageFilter" default="1">


<cfset allFields="LocationID,CuisineID,NGOTypeID,ParkID,EventStartDate,EventEndDate,EventCategoryID,PriceType,PriceStart,PriceEnd,Kilometers,TransmissionID,MakeID,VehicleYear,VehicleYearStart,VehicleYearEnd,FourWheelDrive,Rent,RentType,RentStart,RentEnd,TermID,Baths,Beds,Amenities,AmenityID">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="LocationID,CuisineID,NGOTypeID,ParkID,PriceStart,PriceEnd,Kilometers,TransmissionID,MakeID,VehicleYear,VehicleYearStart,VehicleYearEnd,TermID,Baths,Beds,AmenityID">

<cfset ShowFilterFields="">

<cfswitch expression="#FilterListingTypeID#">
	<cfcase value="1,10,12,14">
		<cfset ShowFilterFields="Location">
		<cfif CategoryID is "157">
			<cfset ShowFilterFields=ListAppend(ShowFilterFields,"NGOType")>
		</cfif>
		<cfif FilterParkCategory>
			<cfset ShowFilterFields=ListAppend(ShowFilterFields,"Park")>
		</cfif>
	</cfcase>
	<cfcase value="2">
		<cfset ShowFilterFields="Location,Cuisine">
	</cfcase>
	<cfcase value="3">
		<cfset ShowFilterFields="Price">
	</cfcase>
	<cfcase value="4">
		<cfset ShowFilterFields="Price,Kilometers,Make,Transmission,VehicleYear,FourWheelDrive">
	</cfcase>
	<cfcase value="5">
		<cfset ShowFilterFields="Price,Kilometers,VehicleYear">
	</cfcase>	
	<cfcase value="6">
		<cfset ShowFilterFields="Rent,Term,Location,Baths,Beds,Amenities">
	</cfcase>
	<cfcase value="7">
		<cfset ShowFilterFields="Rent,Term,Location">
	</cfcase>
	<cfcase value="8">
		<cfset ShowFilterFields="Location,Price">
	</cfcase>
	<cfcase value="15">
		<cfset ShowFilterFields="EventDate,EventLocation,EventCategory">
	</cfcase>
</cfswitch>


<cfoutput>
<cfsavecontent variable="FilterForm">
	<cfif Len(ShowFilterFields)>
		<script>
			function validateForm(f) {						
				<cfloop list="#ShowFilterFields#" index="i">
					<cfswitch expression="#i#">
						<cfcase value="EventDate">
							if (!checkDateDDMMYYYY(f.EventStartDate,"Date (Start)")) {
										return false;
							}
							if (!checkDateDDMMYYYY(f.EventEndDate,"Date (End)")) {
										return false;
							}
						</cfcase>
						<cfcase value="Price">							
							if (!checkNumber(f.PriceStart,"Price (Start)")) {
								return false;
							}					
							if (!checkNumber(f.PriceEnd,"Price (End)")) {
								return false;
							}
						</cfcase>
						<cfcase value="Kilometers">							
							if (!checkNumber(f.Kilometers,"Kilometers")) {
								return false;
							}		
						</cfcase>
						<cfcase value="VehicleYear">							
							if (!checkNumber(f.VehicleYearStart,"Year (Start)")) {
								return false;
							}					
							if (!checkNumber(f.VehicleYearEnd,"Year (End)")) {
								return false;
							}
						</cfcase>
						<cfcase value="Rent">							
							if (!checkNumber(f.RentStart,"Rent (Start)")) {
								return false;
							}					
							if (!checkNumber(f.RentEnd,"Rent (End)")) {
								return false;
							}
						</cfcase>
						<cfcase value="Baths">							
							if (!checkNumber(f.Baths,"Baths")) {
								return false;
							}		
						</cfcase>
						<cfcase value="Beds">							
							if (!checkNumber(f.Beds,"Beds")) {
								return false;
							}		
						</cfcase>
					</cfswitch>
				</cfloop>
				return true;
			}
		</script>
		<cfif ListLen(ShowFilterFields)>
			<form name="f1" id="f1" action="#FilterAction#" method="get"  ONSUBMIT="return validateForm(this)">
				<div class="notice">&nbsp;&nbsp;Filter listings by any combination of the fields below.</div><div class="clear5"></div>
						#FilterAdditionalParams#
						<cfloop list="#ShowFilterFields#" index="i">
							<cfswitch expression="#i#">
								<cfcase value="Location,EventLocation">		
									<cfquery name="Locations" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
										Select LocationID as SelectValue, Title as SelectText 
										From Locations
										Where Active=1
										Order By OrderNum
									</cfquery>
									<div class="filterField">&nbsp;&nbsp;
										<cfif i is "Location">
											<span class="filterLabel">Location: </span>
										</cfif>
										<select class="dining-locationsearch" name="LocationID" id="LocationID">
											<option value="">-- Select an Area --
											<cfloop query="Locations">
												<option value="#SelectValue#" <cfif ListFind(LocationID,SelectValue)>Selected</cfif>>#SelectText#
											</cfloop>
										</select>		
									</div>						
								</cfcase>
								<cfcase value="Cuisine">	
									<cfquery name="Cuisines" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
										Select CuisineID as SelectValue, Title as SelectText 
										From Cuisines
										Where Active=1
										Order By OrderNum
									</cfquery>
									<div class="filterField">&nbsp;&nbsp;
										<span class="filterLabel">Cuisine:</span>
										<select class="dining-locationsearch" name="CuisineID" id="CuisineID">
											<option value="">-- Select --
											<cfloop query="Cuisines">
												<option value="#SelectValue#" <cfif ListFind(CuisineID,SelectValue)>Selected</cfif>>#SelectText#
											</cfloop>
										</select>				
									</div>							
								</cfcase>
								<cfcase value="NGOType">	
									<cfquery name="NGOTypes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
										Select NGOTypeID as SelectValue, Title as SelectText 
										From NGOTypes
										Where Active=1
										Order By OrderNum
									</cfquery>
									<div class="filterField">&nbsp;&nbsp;
										<span class="filterLabel">NGO Type:</span>
										<select class="dining-locationsearch" name="NGOTypeID" id="NGOTypeID">
											<option value="">-- Select --
											<cfloop query="NGOTypes">
												<option value="#SelectValue#" <cfif ListFind(NGOTypeID,SelectValue)>Selected</cfif>>#SelectText#
											</cfloop>
										</select>	
									</div>							
								</cfcase>
								<cfcase value="Park">	
									<cfquery name="Parks" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
										Select ParkID as SelectValue, Title as SelectText 
										From Parks
										Where Active=1
										Order By OrderNum
									</cfquery>
									<div class="filterField">&nbsp;&nbsp;
										<span class="filterLabel">By Natl. Park:</span>
										<select class="dining-locationsearch" name="ParkID" id="ParkID">
											<option value="">-- Select Natl. Park  --
											<cfloop query="Parks">
												<option value="#SelectValue#" <cfif ListFind(ParkID,SelectValue)>Selected</cfif>>#SelectText#
											</cfloop>
										</select>	
									</div>							
								</cfcase>
								<cfcase value="EventDate">		
									<cfset NewStartDate="">	
									<cfset NewEndDate="">							
									<cfif Len(EventStartDate)>
										<cfset NewStartDate="#ListGetAt(EventStartDate,2,"/")#/#ListGetAt(EventStartDate,1,"/")#/#ListGetAt(EventStartDate,3,"/")#">
									</cfif>
									<cfif Len(EventEndDate)>
										<cfset NewEndDate="#ListGetAt(EventEndDate,2,"/")#/#ListGetAt(EventEndDate,1,"/")#/#ListGetAt(EventEndDate,3,"/")#">
									</cfif>	
									<div class="filterField">&nbsp;&nbsp;										
										<input class="dining-locationsearch" name="EventStartDate" id="EventStartDate" value="#EventStartDate#" size="10" maxLength="20"> - <input class="dining-locationsearch" name="EventEndDate" id="EventEndDate" value="#EventEndDate#" size="10" maxLength="20">			
									</div>		
									<script type="text/javascript">
										$(function() {
											$("##EventStartDate").datepicker({showOn: 'button', buttonImage: 'images/sitewide/date_16.png', buttonImageOnly: true, dateFormat: 'dd/mm/yy', changeMonth: true, changeYear: true});
											$("##EventEndDate").datepicker({showOn: 'button', buttonImage: 'images/sitewide/date_16.png', buttonImageOnly: true, dateFormat: 'dd/mm/yy', changeMonth: true, changeYear: true});
										});
									</script>							
								</cfcase>
								<cfcase value="Price">										
									<div class="filterField">&nbsp;&nbsp;
										<span class="filterLabel">Price: </span>
										<select class="dining-locationsearch" ID="PriceType" name="PriceType">
											<option value="US" <cfif PriceType neq "TZ">selected</cfif>>$US
											<option value="TZ" <cfif PriceType is "TZ">selected</cfif>>TSH
										</select>
										Min: <input name="PriceStart" id="PriceStart" value="#PriceStart#" size="5" maxLength="20"> - Max: <input name="PriceEnd" id="PriceEnd" value="#PriceEnd#" size="5" maxLength="20">			
									</div>		
								</cfcase>
								<cfcase value="Kilometers">		
									<div class="filterField">&nbsp;&nbsp;
										<span class="filterLabel">Year:</span>
										<input class="dining-locationsearch" name="VehicleYearStart" id="VehicleYearStart" value="#VehicleYearStart#" size="5" maxLength="4"> - <input name="VehicleYearEnd" id="VehicleYearEnd" value="#VehicleYearEnd#" size="5" maxLength="4">		
									</div>	
									<div class="filterField">&nbsp;&nbsp;
										<span class="filterLabel">Kilometers: (less than)</span>
										<input class="dining-locationsearch" name="Kilometers" id="Kilometers" value="#Kilometers#" size="8" maxLength="20">	
									</div>								
								</cfcase>
								<cfcase value="Transmission">											
									<cfquery name="Transmissions" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
										Select TransmissionID as SelectValue, Title as SelectText 
										From Transmissions
										Where Active=1
										Order By OrderNum
									</cfquery>
									<div class="filterField">&nbsp;&nbsp;
										<span class="filterLabel">Transmission:</span>
										<select class="dining-locationsearch" name="TransmissionID" id="TransmissionID">
											<option value="">-- Select --
											<cfloop query="Transmissions">
												<option value="#SelectValue#" <cfif ListFind(TransmissionID,SelectValue)>Selected</cfif>>#SelectText#
											</cfloop>
										</select>		
									</div>							
								</cfcase>
								<cfcase value="Make">											
									<cfquery name="Makes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
										Select MakeID as SelectValue, Title as SelectText 
										From Makes
										Where Active=1
										Order By OrderNum
									</cfquery>
									<div class="filterField">&nbsp;&nbsp;
										<span class="filterLabel">Make:</span>
										<select class="dining-locationsearch" name="MakeID" id="MakeID">
											<option value="">-- Select --
											<cfloop query="Makes">
												<option value="#SelectValue#" <cfif ListFind(MakeID,SelectValue)>Selected</cfif>>#SelectText#
											</cfloop>
										</select>	
									</div>								
								</cfcase>
								<cfcase value="Rent">		
									<cfquery name="Terms" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
										Select TermID as SelectValue, Title as SelectText 
										From Terms
										Where Active=1
										Order By OrderNum
									</cfquery>										
									<div class="filterField">&nbsp;&nbsp;
										<span class="filterLabel">Rent: </span>
										<select class="dining-locationsearch" ID="RentType" name="RentType">
											<option value="US" <cfif RentType neq "TZ">selected</cfif>>$US
											<option value="TZ" <cfif RentType is "TZ">selected</cfif>>TSH
										</select>
										Min: <input name="RentStart" id="RentStart" value="#RentStart#" size="5" maxLength="20"> - Max: <input name="RentEnd" id="RentEnd" value="#RentEnd#" size="5" maxLength="20">	
									</div>								
									<div class="filterField">&nbsp;&nbsp;
										<span class="filterLabel">Term: </span>
										<select class="dining-locationsearch" name="TermID" id="TermID">
											<option value="">-- Select --
											<cfloop query="Terms">
												<option value="#SelectValue#" <cfif ListFind(TermID,SelectValue)>Selected</cfif>>#SelectText#
											</cfloop>
										</select>	
									</div>				
								</cfcase>
								<cfcase value="Baths">	
									<div class="filterField">&nbsp;&nbsp;
										<span class="filterLabel">Minimum ## Baths:</span>
										<input class="dining-locationsearch" name="Baths" id="Baths" value="#Baths#" size="5" maxLength="4"> 
									</div>
									<div class="filterField">&nbsp;&nbsp;
										<span class="filterLabel">Minimum ## Beds:</span>
										<input class="dining-locationsearch" name="Beds" id="Beds" value="#Beds#" size="5" maxLength="4"> 
									</div>							
								</cfcase>							
								<cfcase value="Amenities">		
									<cfquery name="Amenities" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
										Select AmenityID as SelectValue, Title as SelectText 
										From Amenities
										Where Active=1
										Order By OrderNum
									</cfquery>
									<div class="filterField">&nbsp;&nbsp;
										<span class="filterLabel">Amenities:</span>
										<select class="dining-locationsearch" name="AmenityID" id="AmenityID">
											<option value="">-- Select --
											<cfloop query="Amenities">
												<option value="#SelectValue#" <cfif ListFind(AmenityID,SelectValue)>Selected</cfif>>#SelectText#
											</cfloop>
										</select>	
									</div>							
								</cfcase>					
								<cfcase value="EventCategory">		
									<cfquery name="EventCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
										Select AmenityID as SelectValue, Title as SelectText 
										From Amenities
										Where Active=1
										Order By OrderNum
									</cfquery>
									<cfquery name="EventCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
										Select C.SectionID, C.CategoryID as SelectValue,
										C.URLSafeTitle, C.Title as SelectText, C.OrderNum as CategoryOrderNum
										From Categories C 
										Where  C.ParentSectionID=59
										and C.Active=1
										Order By CategoryOrderNum
									</cfquery>
									<div class="filterField">&nbsp;&nbsp;
										<select class="dining-locationsearch" name="EventCategoryID" id="EventCategoryID">
											<option value="">-- Select a Type of Event --
											<cfloop query="EventCategories">
												<option value="#SelectValue#" <cfif ListFind(EventCategoryID,SelectValue)>Selected</cfif>>#SelectText#
											</cfloop>
										</select>	
									</div>
									<script>
										$(document).ready(function() {
											$('##EventCategoryID').change(function() {
												if ($(this).val() != '') {
													<cfloop query="EventCategories">
														if ($(this).val() == #SelectValue#) {
															$(this).closest("form").attr('action','#URLSafeTitle#');
														}
													</cfloop>													
												}
												else {
													$(this).closest("form").attr('action', '#filterAction#');
												}
											});
										});
									</script>					
								</cfcase>
							</cfswitch>
						</cfloop>
						<div class="filterField">&nbsp;&nbsp;
							<input name="btn-searchdining" id="btn-searchdining" type="image" value="Go" src="images/inner/btn.go_off.gif" alt="Go" align="absmiddle" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-searchdining','','images/inner/btn.go_on.gif',1)"  />
						</div>
			</form>
			<!--- <hr>
		</div> --->
		</cfif>
	</cfif>
</cfsavecontent>

<cfsavecontent variable="FilterWhereClause">
	<cfif Len(LocationID)>
		and exists (Select LocationID from ListingLocations LL Where LL.LocationID=#LocationID# and LL.ListingID=L.ListingID)
	</cfif>
	<cfif Len(CuisineID)>
		and exists (Select CuisineID from ListingCuisines LC Where LC.CuisineID=#CuisineID# and LC.ListingID=L.ListingID)
	</cfif>
	<cfif Len(NGOTypeID)>
		and exists (Select NGOTypeID from ListingNGOTypes LN Where LN.NGOTypeID=#NGOTypeID# and LN.ListingID=L.ListingID)
	</cfif>
	<cfif Len(ParkID)>
		and exists (Select ParkID from ListingParks LP Where LP.ParkID=#ParkID# and LP.ListingID=L.ListingID)
	</cfif>
	<cfif Len(EventStartDate)>
		<cfset NewStartDate="#ListGetAt(EventStartDate,2,"/")#/#ListGetAt(EventStartDate,1,"/")#/#ListGetAt(EventStartDate,3,"/")#">
	</cfif>
	<cfif Len(EventEndDate)>
		<cfset NewEndDate="#ListGetAt(EventEndDate,2,"/")#/#ListGetAt(EventEndDate,1,"/")#/#ListGetAt(EventEndDate,3,"/")#">
	</cfif>
	<cfif Len(EventStartDate) and Len(EventEndDate)>
		and exists (Select ListingID from ListingEventDays LED Where (LED.ListingEventDate='#NewStartDate#' or LED.ListingEventDate='#NewEndDate#' or LED.ListingEventDate between '#NewStartDate#' and '#NewEndDate#') and LED.ListingID=L.ListingID)
	<cfelseif Len(EventStartDate)>
		and exists (Select ListingID from ListingEventDays LED Where LED.ListingEventDate='#NewStartDate#' and LED.ListingID=L.ListingID)
	</cfif>
	<cfif Len(EventCategoryID)>
		and C.CategoryID = #EventCategoryID#
	</cfif>
	<cfif Len(PriceStart) and Len(PriceEnd)>
		<cfif PriceType is "US">
			and L.PriceUS >= '#PriceStart#' and L.PriceUS <='#PriceEnd#'
		<cfelse>
			and L.PriceTZS >= '#PriceStart#' and L.PriceTZS <='#PriceEnd#'
		</cfif>
	<cfelseif Len(PriceStart)>
		<cfif PriceType is "US">
			and L.PriceUS >= '#PriceStart#' 
		<cfelse>
			and L.PriceTZS >= '#PriceStart#' 
		</cfif>
	<cfelseif Len(PriceEnd)>
		<cfif PriceType is "US">
			and L.PriceUS <='#PriceEnd#'
		<cfelse>
			and L.PriceTZS <='#PriceEnd#'
		</cfif>
	</cfif>
	<cfif Len(Kilometers)>
		and L.Kilometers <= #Kilometers#
	</cfif>
	<cfif Len(TransmissionID)>
		and L.TransmissionID=#TransmissionID# 
	</cfif>
	<cfif Len(MakeID)>
		and L.MakeID=#MakeID# 
	</cfif>
	<cfif Len(VehicleYearStart) and Len(VehicleYearEnd)>
		and L.VehicleYear >= '#VehicleYearStart#' and L.VehicleYear <='#VehicleYearEnd#'
	<cfelseif Len(VehicleYearStart)>
		and L.VehicleYear >= '#VehicleYearStart#' 
	<cfelseif Len(VehicleYearEnd)>
		and L.VehicleYear <='#VehicleYearEnd#'
	</cfif>
	<cfif Len(FourWheelDrive)>
		and L.FourWheelDrive=1
	</cfif><cfif Len(RentStart) and Len(RentEnd)>
		<cfif RentType is "US">
			and L.RentUS >= '#RentStart#' and L.RentUS <='#RentEnd#'
		<cfelse>
			and L.RentTZS >= '#RentStart#' and L.RentTZS <='#RentEnd#'
		</cfif>
	<cfelseif Len(RentStart)>
		<cfif RentType is "US">
			and L.RentUS >= '#RentStart#' 
		<cfelse>
			and L.RentTZS >= '#RentStart#' 
		</cfif>
	<cfelseif Len(RentEnd)>
		<cfif RentType is "US">
			and L.RentUS <='#RentEnd#'
		<cfelse>
			and L.RentTZS <='#RentEnd#'
		</cfif>
	</cfif>	
	<cfif Len(TermID)>
		and L.TermID=#TermID# 
	</cfif>
	<cfif Len(Baths)>
		and L.Bathrooms >= #Baths#
	</cfif>
	<cfif Len(Beds)>
		and L.Bedrooms >= #Beds#
	</cfif>
	<cfif Len(AmenityID)>
		and exists (Select AmenityID from ListingAmenities LA Where LA.AmenityID=#AmenityID# and LA.ListingID=L.ListingID)
	</cfif>
</cfsavecontent>


<cfif ListLen(ShowFilterFields)>
	<cfloop list="#ShowFilterFields#" index="i">
		<cfif i is "Location" and Len(LocationID)>
			<cfset FilterCriteria=FilterCriteria & "&LocationID=#LocationID#">
		<cfelseif i is "Cuisine" and Len(CuisineID)>
			<cfset FilterCriteria=FilterCriteria & "&CuisineID=#CuisineID#">
		<cfelseif i is "NGOType" and Len(NGOTypeID)>
			<cfset FilterCriteria=FilterCriteria & "&NGOTypeID=#NGOTypeID#">
		<cfelseif i is "Park" and Len(ParkID)>
			<cfset FilterCriteria=FilterCriteria & "&ParkID=#ParkID#">
		<cfelseif i is "EventDate" and ( Len(EventStartDate) or Len(EventEndDate) )>
			<cfif Len(EventStartDate)>
				<cfset FilterCriteria=FilterCriteria & "&EventStartDate=#EventStartDate#">
			</cfif>
			<cfif Len(EventEndDate)>
				<cfset FilterCriteria=FilterCriteria & "&EventEndDate=#EventEndDate#">
			</cfif>
		<cfelseif i is "Price" and ( Len(PriceStart) or Len(PriceEnd) )>
			<cfset FilterCriteria=FilterCriteria & "&PriceType=#PriceType#">
			<cfif Len(PriceStart)>
				<cfset FilterCriteria=FilterCriteria & "&PriceStart=#PriceStart#">
			</cfif>
			<cfif Len(PriceEnd)>
				<cfset FilterCriteria=FilterCriteria & "&PriceEnd=#PriceEnd#">
			</cfif>
		<cfelseif i is "Kilometers" and  Len(Kilometers)>
			<cfset FilterCriteria=FilterCriteria & "&Kilometers=#Kilometers#">
		<cfelseif i is "Transmission" and Len(TransmissionID)>
			<cfset FilterCriteria=FilterCriteria & "&TransmissionID=#TransmissionID#">
		<cfelseif i is "Make" and Len(MakeID)>
			<cfset FilterCriteria=FilterCriteria & "&MakeID=#MakeID#">
		<cfelseif i is "VehicleYear" and ( Len(VehicleYearStart) or Len(VehicleYearEnd) )>
			<cfif Len(VehicleYearStart)>
				<cfset FilterCriteria=FilterCriteria & "&VehicleYearStart=#VehicleYearStart#">
			</cfif>
			<cfif Len(VehicleYearEnd)>
				<cfset FilterCriteria=FilterCriteria & "&VehicleYearEnd=#VehicleYearEnd#">
			</cfif>
		<cfelseif i is "FourWheelDrive" and Len(FourWheelDrive)>
			<cfset FilterCriteria=FilterCriteria & "&FourWheelDrive=#FourWheelDrive#">
		<cfelseif i is "Rent" and ( Len(RentStart) or Len(RentEnd) )>
			<cfset FilterCriteria=FilterCriteria & "&RentType=#RentType#">
			<cfif Len(RentStart)>
				<cfset FilterCriteria=FilterCriteria & "&RentStart=#RentStart#">
			</cfif>
			<cfif Len(RentEnd)>
				<cfset FilterCriteria=FilterCriteria & "&RentEnd=#RentEnd#">
			</cfif>
		<cfelseif i is "Term" and Len(TermID)>
			<cfset FilterCriteria=FilterCriteria & "&TermID=#TermID#">
		<cfelseif i is "Baths" and Len(Baths)>
			<cfset FilterCriteria=FilterCriteria & "&Baths=#Baths#">
		<cfelseif i is "Beds" and Len(Beds)>
			<cfset FilterCriteria=FilterCriteria & "&Beds=#Beds#">
		<cfelseif i is "Amenities" and Len(AmenityID)>
			<cfset FilterCriteria=FilterCriteria & "&AmenityID=#AmenityID#">
		</cfif>
	</cfloop>
</cfif>


</cfoutput>