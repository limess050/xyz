<!---
Generates XML output Of Listings in the passed Category for use in Phone Book.
--->
<cfprocessingdirective pageencoding="utf-8"> 
<cfif not IsDefined('PhoneBookID') or not ListFind("kj5dsf$@8u7",PhoneBookID)>
	<cfabort>	
</cfif>
<cfif not IsDefined('CategoryID') or not Len(CategoryID) or not IsNumeric(CategoryID)>
	No CategoryID passed.
	<cfabort>
</cfif>
<cfinclude template="../includes/CleanHighAscii.cfm">
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset edit = "0">

<cfset XMLFeedFilterInner = "and L.listingTypeID in (3,4,5,6,7,8,10,15)">
<cfparam name="DisplayExpandedListing" default="1">

<cfquery name="getCategory" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select Title, ParentSectionID, SectionID, Descr as CallOut
	From Categories
	Where CategoryID=<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">	
</cfquery>

<cfif Len(getCategory.SectionID)>
	<!--- Listings in Sections with SubSections (Business, Travel, Real Estate, ...)  --->
	<cfquery name="getListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select L.ListingID, L.ListingTypeID, 
		L.ListingTitle,
		L.ShortDescr, L.DateListed, L.PriceUS, L.PriceTZS,
		L.RentUS, L.RentTZS, L.Bedrooms, L.Bathrooms, L.AmenityOther, L.LocationOther, L.LocationText,
		L.LongDescr, L.MakeID,
		L.Make as MakeOther, L.Model as ModelOther, L.VehicleYear, L.Kilometers, L.FourWheelDrive,
		L.Deadline, L.WebsiteURL, L.PublicPhone, L.PublicEmail, 
		L.EventStartDate, L.EventEndDate,		
		L.CuisineOther, L.AccountName, 
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ# Then 1 Else 0 END as HasExpandedListing,
		L.SquareFeet, L.SquareMeters,
		L.UserID as ListingUserID, L.InProgressUserID as ListingInProgressUserID, L.AcctWebsiteURL,		
		L.Instructions, L.UploadedDoc,
		R.Descr as Recurrence, RM.Descr as RecurrenceMonth,
		S.SectionID,
		C.CategoryID,
		M.Title as Make, T.Title as Transmission,
		Te.Title as Term
		From ParentSectionsView PS 
		Inner Join Sections S on PS.ParentSectionID=S.ParentSectionID	
		Inner Join Categories C on S.SectionID=C.SectionID
		Inner Join ListingCategories LC on C.CategoryID=LC.CategoryID
		Inner Join ListingsView L on LC.ListingID=L.ListingID  
		Left Outer Join Makes M on L.MakeID=M.MakeID
		Left Outer Join Transmissions T on L.TransmissionID=T.TransmissionID
		Left outer Join Terms Te on L.TermID=Te.TermID
		Left Outer Join Orders ELO on L.ExpandedListingOrderID=ELO.OrderID
		Left Outer Join Recurrences R on L.RecurrenceID=R.RecurrenceID
		Left Outer Join RecurrenceMonths RM on L.RecurrenceMonthID=RM.RecurrenceMonthID
		Where 
			C.CategoryID=<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">
			<cfinclude template="../includes/LiveListingFilter.cfm">
			#XMLFeedFilterInner#
			<cfif getCategory.ParentSectionID is "8"><!--- If in Jobs section, only show Prof Empl Opps --->
				and L.ListingTypeID in (10)<!--- Prof Empl Opportunities --->
			</cfif>
		Order By L.HasExpandedListing desc, ListingTitle
	</cfquery>
<cfelse>
	<!--- Listings in Sections with no SubSections (Events, FSBO, Entertainment, ...)  --->
	<cfquery name="getListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select L.ListingID, L.ListingTypeID,
		L.ListingTitle,
		L.ShortDescr, L.DateListed, L.PriceUS, L.PriceTZS,
		L.RentUS, L.RentTZS, L.Bedrooms, L.Bathrooms, L.AmenityOther, L.LocationOther, L.LocationText,
		L.LongDescr, L.MakeID,
		L.Make as MakeOther, L.Model, L.Model as ModelOther, L.VehicleYear, L.Kilometers, L.FourWheelDrive,
		L.Deadline, L.WebsiteURL, L.PublicPhone, L.PublicEmail,
		L.EventStartDate, L.EventEndDate,
		L.CuisineOther, L.AccountName,
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ# Then 1 Else 0 END as HasExpandedListing,
		L.SquareFeet, L.SquareMeters,
		L.UserID as ListingUserID, L.InProgressUserID as ListingInProgressUserID, L.AcctWebsiteURL,
		L.Instructions, L.UploadedDoc,
		R.Descr as Recurrence, RM.Descr as RecurrenceMonth,
		null as SectionID,
		C.CategoryID,
		M.Title as Make, T.Title as Transmission,
		Te.Title as Term
		From ParentSectionsView PS 
		Inner Join Categories C on PS.ParentSectionID=C.ParentSectionID
		Inner Join ListingCategories LC on C.CategoryID=LC.CategoryID
		Inner Join ListingsView L on LC.ListingID=L.ListingID
		Left Outer Join Makes M on L.MakeID=M.MakeID
		Left Outer Join Transmissions T on L.TransmissionID=T.TransmissionID
		Left Outer Join Terms Te on L.TermID=Te.TermID
		Left Outer Join Orders ELO on L.ExpandedListingOrderID=ELO.OrderID
		Left Outer Join Recurrences R on L.RecurrenceID=R.RecurrenceID 
		Left Outer Join RecurrenceMonths RM on L.RecurrenceMonthID=RM.RecurrenceMonthID
		Where 
			PS.Active=1		
			and C.CategoryID=<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">
			<cfinclude template="../includes/LiveListingFilter.cfm">
			#XMLFeedFilterInner#
			<cfif getCategory.ParentSectionID is "8"><!--- If in Jobs section, only show Prof Empl Opps --->
				and L.ListingTypeID in (10)<!--- Prof Empl Opportunities --->
			</cfif>
		Order By L.HasExpandedListing desc, ListingTitle
	</cfquery>
</cfif>
<cfset ListingUserIDs = Replace(Replace(ValueList(getListings.ListingUserID),",,",",","All"),",,",",","All")>
<cfset ListingInProgressUserIDs = Replace(Replace(ValueList(getListings.ListingInProgressUserID),",,",",","All"),",,",",","All")>
<cfquery name="getAccountsQualifiedMaster" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select AQ.HR4Qualified, AQ.FSBO4Qualified, AQ.UserID
	From AccountsQualified AQ
	Where AQ.UserID in (<cfif ListLen(ListingUserIDs)>#ListingUserIDs#<cfelse>0</cfif>)
	or AQ.UserID in (<cfif ListLen(ListingInProgressUserIDs)>#ListingInProgressUserIDs#<cfelse>0</cfif>)
</cfquery>
<cfquery name="GetLocationTitlesMaster"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select L.Title as Location, LL.ListingID
	From ListingLocations LL
	Inner Join Locations L on LL.LocationID=L.LocationID
	Where LL.ListingID in (<cfif ListLen(ValueList(getListings.ListingID))>#ValueList(getListings.ListingID)#<cfelse>0</cfif>)
	and L.LocationID <> 4
	Order by L.Title
</cfquery>	
<cfquery name="getListingAmenitiesMaster" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select A.Title, A.OrderNum, LA.ListingID
	From ListingAmenities LA inner join Amenities A on LA.AmenityID=A.AmenityID
	Where LA.ListingID in (<cfif ListLen(ValueList(getListings.ListingID))>#ValueList(getListings.ListingID)#<cfelse>0</cfif>)
	and A.Active=1
	and A.AmenityID <> 1 <!--- Other) --->
	Order By A.OrderNum
</cfquery>
<cfquery name="getListingRecurrenceDaysMaster" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select Descr as RecurrenceDay, LR.ListingID
	From ListingRecurrences LR
	Inner Join RecurrenceDays RD on LR.RecurrenceDayID=RD.RecurrenceDayID
	Where LR.ListingID in (<cfif ListLen(ValueList(getListings.ListingID))>#ValueList(getListings.ListingID)#<cfelse>0</cfif>)
</cfquery>
<cfsavecontent variable="ListingsXML"><?xml version="1.0" encoding="UTF-8"?>
<everythingdar>
	<category>
		<cfoutput><id>#CategoryID#</id>
		<label>#XMLFormat(getCategory.Title)#</label></cfoutput>
		<cfoutput query="getListings">	
			<cfsilent>
			<cfif ListFind("6,8",ListingTypeID)>
				<cfquery name="getListingAmenities" dbtype="Query">
					Select Title, OrderNum
					From getListingAmenitiesMaster
					Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
					Order By OrderNum
				</cfquery>
			<cfelseif ListingTypeID is "15"><!--- Events --->
				<cfquery name="getListingRecurrenceDays" dbtype="query">
					Select RecurrenceDay
					From getListingRecurrenceDaysMaster
					Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
			</cfif>
			<cfif Len(WebsiteURL)>
				<cfset WebsiteLink=WebsiteURL>
				<cfif Left(WebsiteLink,4) neq "http">
					<cfset WebsiteLink="http://" & WebsiteLink>
				</cfif>
			<cfelse>
				<cfset WebsiteLink="">
			</cfif>
			<cfset HR4Qualified=0>
			<cfset FSBO4Qualified=0>
			<cfif ListFind("4,5,6,7,8",ListingTypeID) and (Len(ListingUserID) or Len(ListingInProgressUserID))>
				<cfquery name="getAccountQuals" dbtype="query">
					Select HR4Qualified, FSBO4Qualified
					From getAccountsQualifiedMaster
					Where UserID=<cfif Len(ListingUserID)><cfqueryparam value="#ListingUserID#" cfsqltype="CF_SQL_INTEGER"><cfelse><cfqueryparam value="#ListingInProgressUserID#" cfsqltype="CF_SQL_INTEGER"></cfif>
				</cfquery>
				<cfif getAccountQuals.HR4Qualified>
					<cfset HR4Qualified=1>
				</cfif>
				<cfif getAccountQuals.FSBO4Qualified>
					<cfset FSBO4Qualified=1>
				</cfif>
			</cfif>
			
			<cfquery name="GetLocationTitles" dbtype="query">
				Select Location
				From GetLocationTitlesMaster
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
					
			<cfif Len(SquareFeet) or Len(SquareMeters)>
				<cfif Len(SquareFeet)>
					<cfset LocalSquareFeet=SquareFeet>
					<cfset LocalSquareMeters=0.092903*SquareFeet>
				<cfelse>
					<cfset LocalSquareMeters=SquareMeters>
					<cfset LocalSquareFeet=10.7639*SquareMeters>
				</cfif>
			<cfelse>
				<cfset LocalSquareFeet=''>
				<cfset LocalSquareMeters=''>
			</cfif>
			</cfsilent>
		<content><cfswitch expression="#ListingTypeID#">	
			<cfcase value="3"><!--- General For Sale by Owner --->
			<listingID>#XMLFormat(ListingID)#</listingID>
			<listinglink>#Request.httpURL##lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#</listinglink>
			<title>#XMLFormat(ListingTitle)#</title>
			<priceus><cfif Len(PriceUS)>#XMLFormat('$US&nbsp;' & NumberFormat(PriceUS,","))#</cfif></priceus>
			<pricetsh><cfif Len(PriceTZS)>#XMLFormat('TSH&nbsp;' & NumberFormat(PriceTZS,","))#</cfif></pricetsh>
			<datelisted>#XMLFormat(DateFormat(DateListed,'dd/mm/yyyy'))#</datelisted>
   			<publicemail>#XMLFormat(PublicEmail)#</publicemail>
			<publicphone>#XMLFormat(PublicPhone)#</publicphone>
  			<shortDescr>#XMLFormat(ShortDescr)#</shortDescr>
			<area>#XMLFormat(LocationOutput)#</area></cfcase>
			<cfcase value="4"><!--- For Sale by Owner - Cars & Trucks --->
			<listingID>#XMLFormat(ListingID)#</listingID>
			<listinglink>#Request.httpURL##lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#</listinglink>
			<title>#XMLFormat(ListingTitle)#<cfif FSBO4Qualified is 1> - #XMLFormat('Reference ##: ')##ListingID#</cfif></title>	
			<vehicleyear>#XMLFormat(VehicleYear)#</vehicleyear>
			<vehiclemake><cfif Len(MakeOther)>#XMLFormat(MakeOther)#<cfelse>#XMLFormat(Make)#</cfif></vehiclemake>
			<vehiclemodel>#XMLFormat(ModelOther)#</vehiclemodel>					
			<priceus><cfif Len(PriceUS)>#XMLFormat('$US&nbsp;' & NumberFormat(PriceUS,","))#</cfif></priceus>
			<pricetsh><cfif Len(PriceTZS)>#XMLFormat('TSH&nbsp;' & NumberFormat(PriceTZS,","))#</cfif></pricetsh>
			<datelisted>#XMLFormat(DateFormat(DateListed,'dd/mm/yyyy'))#</datelisted>
			<kilometers>#XMLFormat(Kilometers)#</kilometers>
			<fourwheeldrive><cfif FourWheelDrive>Yes</cfif></fourwheeldrive>
			<transmission>#XMLFormat(Transmission)#</transmission>
			<datelisted>#XMLFormat(DateFormat(DateListed,'dd/mm/yyyy'))#</datelisted>
			<publicemail>#XMLFormat(PublicEmail)#</publicemail>
			<publicphone>#XMLFormat(PublicPhone)#</publicphone>
  			<shortDescr>#XMLFormat(ShortDescr)#</shortDescr>
			<area>#XMLFormat(LocationOutput)#</area>
			<websiteurl><cfif FSBO4Qualified is 1 and Len(AcctWebsiteURL)><cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>#XMLFormat(LocalWebsiteURL)#</cfif></websiteurl></cfcase>
			<cfcase value="5"><!--- FSBO Motorcycles, Mopeds, ATVs, & Vibajaji & FSBO Commercial Trucks --->
			<listingID>#XMLFormat(ListingID)#</listingID>
			<listinglink>#Request.httpURL##lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#</listinglink>
			<title>#XMLFormat(VehicleYear)#<cfif Len(MakeOther)>  #XMLFormat(MakeOther)#</cfif><cfif Len(ModelOther)> #XMLFormat(ModelOther)#</cfif><cfif FSBO4Qualified is 1> - #XMLFormat('Reference ##: ')##ListingID#</cfif></title>
  			<shortDescr>#XMLFormat(ShortDescr)#</shortDescr>
			<vehicleyear>#XMLFormat(VehicleYear)#</vehicleyear>
			<vehiclemake><cfif Len(MakeOther)>#XMLFormat(MakeOther)#<cfelse>#XMLFormat(Make)#</cfif></vehiclemake>
			<vehiclemodel>#XMLFormat(ModelOther)#</vehiclemodel>
			<priceus><cfif Len(PriceUS)>#XMLFormat('$US&nbsp;' & NumberFormat(PriceUS,","))#</cfif></priceus>
			<pricetsh><cfif Len(PriceTZS)>#XMLFormat('TSH&nbsp;' & NumberFormat(PriceTZS,","))#</cfif></pricetsh>
			<datelisted>#XMLFormat(DateFormat(DateListed,'dd/mm/yyyy'))#</datelisted>
			<publicemail>#XMLFormat(PublicEmail)#</publicemail>
			<publicphone>#XMLFormat(PublicPhone)#</publicphone>
			<area>#XMLFormat(LocationOutput)#</area>
			<websiteurl><cfif FSBO4Qualified is 1 and Len(AcctWebsiteURL)><cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>#XMLFormat(LocalWebsiteURL)#</cfif></websiteurl>
			<accountname><cfif HR4Qualified  is 1>#AccountName#</cfif></accountname></cfcase>
			<cfcase value="6"><!--- Housing & Real Estate Housing Rentals --->
			<listingID>#XMLFormat(ListingID)#</listingID>
			<listinglink>#Request.httpURL##lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#</listinglink>
			<title>#XMLFormat(ListingTitle)#<cfif HR4Qualified is 1> - #XMLFormat('Reference ##: ')##ListingID#</cfif></title>
  			<shortDescr>#XMLFormat(ShortDescr)#</shortDescr>
			<rentus><cfif Len(RentUS)>#XMLFormat('$US&nbsp;' & NumberFormat(RentUS,","))#<cfif Len(Term)>/#XMLFormat(Term)#</cfif></cfif></rentus>
			<renttsh><cfif Len(RentTZS)>#XMLFormat('TSH&nbsp;' & NumberFormat(RentTZS,","))#<cfif Len(Term)>/#XMLFormat(Term)#</cfif></cfif></renttsh>
			<datelisted>#XMLFormat(DateFormat(DateListed,'dd/mm/yyyy'))#</datelisted>
			<publicemail>#XMLFormat(PublicEmail)#</publicemail>
			<publicphone>#XMLFormat(PublicPhone)#</publicphone>
			<bedrooms>#Bedrooms#</bedrooms>
			<bathrooms>#Bathrooms#</bathrooms>
			<amenities><cfif getListingAmenities.RecordCount or Len(AmenityOther)>#Replace(valueList(getListingAmenities.Title),",",", ","ALL")#<cfif getListingAmenities.RecordCount and Len(AmenityOther)>, </cfif>#AmenityOther#</cfif></amenities>			
			<area>#XMLFormat(LocationOutput)#</area>
			<locationdirections><cfif Len(LocationText)>#XMLFormat(LocationText)#</cfif></locationdirections>
			<websiteurl><cfif Len(AcctWebsiteURL)><cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>#XMLFormat(LocalWebsiteURL)#</cfif></websiteurl>
			<accountname><cfif HR4Qualified  is 1>#AccountName#</cfif></accountname></cfcase>
			<cfcase value="7"><!--- Housing & Real Estate Commercial Rentals --->
			<listingID>#XMLFormat(ListingID)#</listingID>
			<listinglink>#Request.httpURL##lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#</listinglink>
			<title>#XMLFormat(ListingTitle)#<cfif Len(SquareFeet) or Len(SquareMeters)> #Round(LocalSquareFeet)# sq ft/#NumberFormat(LocalSquareMeters,",.9")# sq m</cfif><cfif HR4Qualified is 1> - #XMLFormat('Reference ##: ')##ListingID#</cfif></title>
			<squarefeet><cfif Len(LocalSquareFeet)>#Round(LocalSquareFeet)#</cfif></squarefeet>
			<squaremeters><cfif Len(LocalSquareMeters)>#NumberFormat(LocalSquareMeters,",.9")#</cfif></squaremeters>
  			<shortDescr>#XMLFormat(ShortDescr)#</shortDescr>
			<rentus><cfif Len(RentUS)>#XMLFormat('$US&nbsp;' & NumberFormat(RentUS,","))#<cfif Len(Term)>/#XMLFormat(Term)#</cfif></cfif></rentus>
			<renttsh><cfif Len(RentTZS)>#XMLFormat('TSH&nbsp;' & NumberFormat(RentTZS,","))#<cfif Len(Term)>/#XMLFormat(Term)#</cfif></cfif></renttsh>
			<datelisted>#XMLFormat(DateFormat(DateListed,'dd/mm/yyyy'))#</datelisted>
			<publicemail>#XMLFormat(PublicEmail)#</publicemail>
			<publicphone>#XMLFormat(PublicPhone)#</publicphone>
			<area>#XMLFormat(LocationOutput)#</area>
			<locationdirections><cfif Len(LocationText)>#XMLFormat(LocationText)#</cfif></locationdirections>
			<websiteurl><cfif Len(AcctWebsiteURL)><cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>#XMLFormat(LocalWebsiteURL)#</cfif></websiteurl>
			<accountname><cfif HR4Qualified is 1>#AccountName#</cfif></accountname></cfcase>
			<cfcase value="8"><!--- Housing & Real Estate For Sale --->
			<listingID>#XMLFormat(ListingID)#</listingID>
			<listinglink>#Request.httpURL##lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#</listinglink>
			<title>#XMLFormat(ListingTitle)#<cfif HR4Qualified is 1> - #XMLFormat('Reference ##: ')##ListingID#</cfif></title>
  			<shortDescr>#XMLFormat(ShortDescr)#</shortDescr>			
			<priceus><cfif Len(PriceUS)>#XMLFormat('$US&nbsp;' & NumberFormat(PriceUS,","))#</cfif></priceus>
			<pricetsh><cfif Len(PriceTZS)>#XMLFormat('TSH&nbsp;' & NumberFormat(PriceTZS,","))#</cfif></pricetsh>
			<datelisted>#XMLFormat(DateFormat(DateListed,'dd/mm/yyyy'))#</datelisted>
			<publicemail>#XMLFormat(PublicEmail)#</publicemail>
			<publicphone>#XMLFormat(PublicPhone)#</publicphone><cfif ListFind(CategoryID,"89")>
			<bedrooms>#Bedrooms#</bedrooms>
			<bathrooms>#Bathrooms#</bathrooms>
			<amenities><cfif getListingAmenities.RecordCount or Len(AmenityOther)>#Replace(valueList(getListingAmenities.Title),",",", ","ALL")#<cfif getListingAmenities.RecordCount and Len(AmenityOther)>, </cfif>#AmenityOther#</cfif></amenities></cfif>
			<area>#XMLFormat(LocationOutput)#</area>
			<locationdirections><cfif Len(LocationText)>#XMLFormat(LocationText)#</cfif></locationdirections>
			<websiteurl><cfif Len(AcctWebsiteURL)><cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>#XMLFormat(LocalWebsiteURL)#</cfif></websiteurl>			
			<accountname><cfif HR4Qualified is 1>#AccountName#</cfif></accountname></cfcase>
			<cfcase value="10"><!--- Jobs & Employment Professional (employment opportunities) --->
			<listingID>#XMLFormat(ListingID)#</listingID>
			<listinglink>#Request.httpURL##lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#</listinglink>
			<title>#XMLFormat(ShortDescr)#</title>
  			<shortDescr>#XMLFormat(ListingTitle)#</shortDescr>
			<datelisted>#XMLFormat(DateFormat(DateListed,'dd/mm/yyyy'))#</datelisted>
			<area><cfif Len(LocationTitles) or Len(LocationOther)><cfset LocationCount=ListLen(LocationTitles)><cfif Len(LocationOther)><cfset LocationCount=LocationCount+1></cfif><cfif Len(LocationTitles)>#XMLFormat(Replace(LocationTitles,",",", ","ALL"))#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#XMLFormat(LocationOther)#</cfif></cfif></area>
			<deadline>#DateFormat(Deadline,"dd/mm/yyyy")#</deadline>
			<startdate>#DateFormat(EventStartDate,"dd/mm/yyyy")#</startdate>
			<positiondescr>#XMLFormat(LongDescr)#</positiondescr>
			<positiondescrdoc><cfif Len(UploadedDoc)>#XMLFormat(Request.httpurl & "/ListingUploadedDocs/" & UploadedDoc)#</cfif></positiondescrdoc>
			<instructions>#XMLFormat(Instructions)#</instructions>
			<websiteurl><cfif Len(WebsiteLink)>#WebsiteLink#<cfelseif Len(AcctWebsiteURL)><cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>#XMLFormat(LocalWebsiteURL)#</cfif></websiteurl></cfcase>
			<cfcase value="15"><!--- Events --->
			<listingID>#XMLFormat(ListingID)#</listingID>
			<listinglink>#Request.httpURL##lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#</listinglink>
		 	<title>#XMLFormat(ListingTitle)#</title>
  			<shortDescr>#XMLFormat(ShortDescr)#</shortDescr>			
			<startdate><cfif Len(EventStartDate)>#DateFormat(EventStartDate,"dd/mm/yyyy")# #TimeFormat(EventStartDate)#</cfif></startdate>
			<enddate><cfif Len(EventEndDate)>#DateFormat(EventEndDate,"dd/mm/yyyy")# #TimeFormat(EventEndDate)#</cfif></enddate>
			<recurrence>#Recurrence#</recurrence>
			<recurrencemonth>#RecurrenceMonth#</recurrencemonth>
			<recurrenceday>#XMLFormat(Replace(valueList(getListingRecurrenceDays.RecurrenceDay),",",", ","ALL"))#</recurrenceday>
   			<publicemail>#XMLFormat(PublicEmail)#</publicemail>
			<publicphone>#XMLFormat(PublicPhone)#</publicphone>
			<area>#XMLFormat(LocationOutput)#</area>
			<locationdirections><cfif Len(LocationText)>#XMLFormat(LocationText)#</cfif></locationdirections>
			<websiteurl><cfif Len(WebsiteURL)><cfif Left(WebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & WebsiteURL><cfelse><cfset LocalWebsiteURL=WebsiteURL></cfif>#XMLFormat(LocalWebsiteURL)#</cfif></websiteurl></cfcase>
			</cfswitch>
		</content></cfoutput>
	</category>
</everythingdar>
</cfsavecontent>
<!--- <cfdump var="#ListingsXML#"> --->
<CFCONTENT
TYPE="text/plain"
RESET="Yes"><CFOUTPUT>#ToString(CleanHighAscii(ListingsXML))#</CFOUTPUT>
