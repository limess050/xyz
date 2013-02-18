<!---
Generates XML output Of Listings in the passed Category for use in kiosk.
--->
<cfprocessingdirective pageencoding="utf-8"> 
<cfif not IsDefined('KioskID') or not ListFind("kjhdsf$@887",KioskID)>
	<cfabort>	
</cfif>
<cfif not IsDefined('CategoryID') or not Len(CategoryID) or not IsNumeric(CategoryID)>
	No CategoryID passed.
	<cfabort>
</cfif>
<cfinclude template="../includes/CleanHighAscii.cfm">

<cfparam name="DisplayExpandedListing" default="1">

<cfquery name="getCategory" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select Title, ParentSectionID, SectionID, Descr as CallOut
	From Categories
	Where CategoryID=<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">	
</cfquery>

<cfif Len(getCategory.SectionID)>
	<cfquery name="getListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select L.ListingID, L.ListingTypeID, 
		L.ListingTitle,
		L.ShortDescr, L.DateListed, L.PriceUS, L.PriceTZS,
		L.RentUS, L.RentTZS, L.Bedrooms, L.Bathrooms, L.AmenityOther, L.LocationOther, L.LocationText,
		L.LongDescr, L.MakeID,
		L.Make as MakeOther, L.Model as ModelOther, L.VehicleYear, L.Kilometers, L.FourWheelDrive,
		L.Deadline, L.WebsiteURL, L.PublicPhone,  L.PublicPhone2,  L.PublicPhone3,  L.PublicPhone4, L.PublicEmail, 
		L.EventStartDate, L.EventEndDate,
		L.ExpandedListingHTML, L.ExpandedListingPDF,
		L.CuisineOther, L.AccountName, 
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ# Then 1 Else 0 END as HasExpandedListing,
		L.ExpandedListingInProgress,
		L.SquareFeet, L.SquareMeters, L.NGOTypeOther,
		L.UserID as ListingUserID, L.InProgressUserID as ListingInProgressUserID, L.AcctWebsiteURL,		
		L.Instructions, L.UploadedDoc,
		R.Descr as Recurrence, RM.Descr as RecurrenceMonth,
		PS.ParentSectionID, PS.Title as ParentSection, 
		S.SectionID, S.Title as SubSection,
		C.CategoryID, C.Title as Category,
		M.Title as Make, T.Title as Transmission,
		Te.Title as Term,		
		ELO.PaymentStatusID as ExpandedListingPaymentStatusID
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
		Where S.Active=1
		and L.Active=1 and L.Reviewed=1 
		and (L.ListingTypeID IN (1,2,14,15) or (L.ExpirationDate >= #application.CurrentDateInTZ# and L.PaymentStatusID in (2,3)))
		and C.CategoryID=<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">
		and (L.Deadline is null or L.Deadline >= DATEADD(Day, 0, DATEDIFF(Day, 0, GetDate()))) and L.DeletedAfterSubmitted=0
		<cfif getCategory.ParentSectionID is "8">
			and L.ListingTypeID in (10)
		</cfif>
		Order By L.HasExpandedListing desc, ListingTitle
	</cfquery>
<cfelse>
	<cfquery name="getListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select L.ListingID, L.ListingTypeID,
		L.ListingTitle,
		L.ShortDescr, L.DateListed, L.PriceUS, L.PriceTZS,
		L.RentUS, L.RentTZS, L.Bedrooms, L.Bathrooms, L.AmenityOther, L.LocationOther, L.LocationText,
		L.LongDescr, L.MakeID,
		L.Make as MakeOther, L.Model, L.Model as ModelOther, L.VehicleYear, L.Kilometers, L.FourWheelDrive,
		L.Deadline, L.WebsiteURL, L.PublicPhone,  L.PublicPhone2,  L.PublicPhone3,  L.PublicPhone4, L.PublicEmail,
		L.EventStartDate, L.EventEndDate,
		L.ExpandedListingHTML, L.ExpandedListingPDF, L.ExpandedListingInProgress,
		L.CuisineOther, L.AccountName,
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ# Then 1 Else 0 END as HasExpandedListing,
		L.SquareFeet, L.SquareMeters, L.NGOTypeOther,
		L.UserID as ListingUserID, L.InProgressUserID as ListingInProgressUserID, L.AcctWebsiteURL,
		L.Instructions, L.UploadedDoc,
		R.Descr as Recurrence, RM.Descr as RecurrenceMonth,
		PS.ParentSectionID, PS.Title as ParentSection, 
		null as SectionID, null as SubSection,
		C.CategoryID, C.Title as Category,
		M.Title as Make, T.Title as Transmission,
		Te.Title as Term,		
		ELO.PaymentStatusID as ExpandedListingPaymentStatusID
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
		Where PS.Active=1
		and L.Active=1 and L.Reviewed=1 
		and (L.ListingTypeID IN (1,2,14,15) or (L.ExpirationDate >= #application.CurrentDateInTZ# and L.PaymentStatusID in (2,3)))
		and C.CategoryID=<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">
		and (L.Deadline is null or L.Deadline >= DATEADD(Day, 0, DATEDIFF(Day, 0, GetDate()))) and L.DeletedAfterSubmitted=0
		<cfif getCategory.ParentSectionID is "8">
			and L.ListingTypeID in (10)
		</cfif>
		Order By L.HasExpandedListing desc, ListingTitle
	</cfquery>
</cfif>

<cfsavecontent variable="ListingsXML"><?xml version="1.0" encoding="UTF-8"?>
<everythingdar>
	<category>
		<cfoutput><id>#CategoryID#</id>
		<label>#XMLFormat(getCategory.Title)#</label></cfoutput>
		<cfoutput query="getListings">	
			<cfsilent>
			<cfif ListFind("3,4,5,6,7,8,9",ListingTypeID)>
				<cfquery name="getListingImages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					Select FileName
					From ListingImages
					Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
					Order By OrderNum, ListingImageID
				</cfquery>
			</cfif>
			<cfif ListingTypeID is "2">
				<cfquery name="getListingCuisines" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					Select LC.CuisineID, C.Title
					From ListingCuisines LC
					Inner Join Cuisines C on LC.CuisineID=C.CuisineID
					Where LC.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
			<cfelseif ListingTypeID is "1">
				<cfquery name="getListingPriceRanges" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					Select LPR.PriceRangeID, PR.Title
					From ListingPriceRanges LPR
					Inner Join PriceRanges PR on LPR.PriceRangeID=PR.PriceRangeID
					Where LPR.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
			<cfelseif ListFind("6,8",ListingTypeID)>
				<cfquery name="getListingAmenities" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Select A.Title
					From ListingAmenities LA inner join Amenities A on LA.AmenityID=A.AmenityID
					Where LA.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
					and A.Active=1
					and A.AmenityID <> 1 <!--- Other) --->
					Order By A.OrderNum
				</cfquery>
			<cfelseif ListingTypeID is "14">
				<cfquery name="getListingNGOTypes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					Select LNT.NGOTypeID, NT.Title
					From ListingNGOTypes LNT
					Inner Join NGOTypes NT on LNT.NGOTypeID=NT.NGOTypeID
					Where LNT.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
			<cfelseif ListingTypeID is "15"><!--- Events --->
				<cfquery name="getListingRecurrenceDays" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					Select Descr as RecurrenceDay
					From ListingRecurrences LR
					Inner Join RecurrenceDays RD on LR.RecurrenceDayID=RD.RecurrenceDayID
					Where LR.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
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
			<cfif Len(ListingUserID) or Len(ListingInProgressUserID)>
				<cfquery name="getAccountQuals" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Select AQ.HR4Qualified, AQ.FSBO4Qualified
					From AccountsQualified AQ
					Where AQ.UserID=<cfif Len(ListingUserID)><cfqueryparam value="#ListingUserID#" cfsqltype="CF_SQL_INTEGER"><cfelse><cfqueryparam value="#ListingInProgressUserID#" cfsqltype="CF_SQL_INTEGER"></cfif>
				</cfquery>
				<cfif getAccountQuals.HR4Qualified>
					<cfset HR4Qualified=1>
				</cfif>
				<cfif getAccountQuals.FSBO4Qualified>
					<cfset FSBO4Qualified=1>
				</cfif>
			</cfif>
			
			<cfquery name="GetLocationTitles"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Select L.Title as Location
				From ListingLocations LL
				Inner Join Locations L on LL.LocationID=L.LocationID
				Where LL.ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
				and L.LocationID <> 4
				Order by L.Title
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
			<cfcase value="1"><!--- BUS 1 --->
		 	<title>#XMLFormat(ListingTitle)#</title>
			<priceranges>#XMLFormat(Replace(valueList(getListingPriceRanges.Title),",",", ","ALL"))#</priceranges>
  			<shortDescr>#XMLFormat(ShortDescr)#</shortDescr>
			<expandedlistingurl><cfif (Len(ExpandedListingHTML) or Len(ExpandedListingPDF)) and not ExpandedListingInProgress and DisplayExpandedListing and HasExpandedListing>#request.HTTPURL#/<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelse>ListingUploadedDocs/#ExpandedListingPDF#</cfif></cfif></expandedlistingurl>
   			<publicemail>#XMLFormat(PublicEmail)#</publicemail>
			<publicphone>#XMLFormat(PublicPhone)#</publicphone>
			<fax>#XMLFormat(PublicPhone2)#</fax>
			<otherpublicphone>#XMLFormat(PublicPhone3)#</otherpublicphone>
			<otherpublicphonetwo>#XMLFormat(PublicPhone4)#</otherpublicphonetwo>
			<area><cfif Len(LocationTitles) or Len(LocationOther)><cfset LocationCount=ListLen(LocationTitles)><cfif Len(LocationOther)><cfset LocationCount=LocationCount+1></cfif><cfif Len(LocationTitles)>#XMLFormat(Replace(LocationTitles,",",", ","ALL"))#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#XMLFormat(LocationOther)#</cfif></cfif></area>
			<locationdirections><cfif Len(LocationText)>#XMLFormat(LocationText)#</cfif></locationdirections>
			<websiteurl>#XMLFormat(WebsiteLink)#</websiteurl></cfcase>						
			<cfcase value="2"><!--- BUS 2 (Restaurant) ---> 
		 	<title>#XMLFormat(ListingTitle)#</title>
			<cuisines>#XMLFormat(Replace(valueList(getListingCuisines.Title),",",", ","ALL"))#<cfif getListingCuisines.RecordCount and Len(CuisineOther)>, </cfif>#XMLFormat(CuisineOther)#</cuisines>
  			<shortDescr>#XMLFormat(ShortDescr)#</shortDescr>
   			<expandedlistingurl><cfif (Len(ExpandedListingHTML) or Len(ExpandedListingPDF)) and not ExpandedListingInProgress and DisplayExpandedListing and HasExpandedListing>#request.HTTPURL#/<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelse>ListingUploadedDocs/#ExpandedListingPDF#</cfif></cfif></expandedlistingurl>
   			<publicemail>#XMLFormat(PublicEmail)#</publicemail>
			<publicphone>#XMLFormat(PublicPhone)#</publicphone>
			<fax>#XMLFormat(PublicPhone2)#</fax>
			<otherpublicphone>#XMLFormat(PublicPhone3)#</otherpublicphone>
			<otherpublicphonetwo>#XMLFormat(PublicPhone4)#</otherpublicphonetwo>
			<area><cfif Len(LocationTitles) or Len(LocationOther)><cfset LocationCount=ListLen(LocationTitles)><cfif Len(LocationOther)><cfset LocationCount=LocationCount+1></cfif><cfif Len(LocationTitles)>#XMLFormat(Replace(LocationTitles,",",", ","ALL"))#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#XMLFormat(LocationOther)#</cfif></cfif></area>
			<locationdirections><cfif Len(LocationText)>#XMLFormat(LocationText)#</cfif></locationdirections>
			<websiteurl><cfif Len(WebsiteURL)><cfif Left(WebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & WebsiteURL><cfelse><cfset LocalWebsiteURL=WebsiteURL></cfif>#XMLFormat(LocalWebsiteURL)#</cfif></websiteurl></cfcase>
			<cfcase value="3"><!--- General For Sale by Owner --->
			<title>#XMLFormat(ListingTitle)#</title>
			<priceus><cfif Len(PriceUS)>#XMLFormat('$US&nbsp;' & NumberFormat(PriceUS,","))#</cfif></priceus>
			<pricetsh><cfif Len(PriceTZS)>#XMLFormat('TSH&nbsp;' & NumberFormat(PriceTZS,","))#</cfif></pricetsh>
			<datelisted>#XMLFormat(DateFormat(DateListed,'dd/mm/yyyy'))#</datelisted>
   			<publicemail>#XMLFormat(PublicEmail)#</publicemail>
			<publicphone>#XMLFormat(PublicPhone)#</publicphone>
  			<shortDescr>#XMLFormat(ShortDescr)#</shortDescr><cfif getListingImages.RecordCount><cfloop query="GetListingImages">
			<image>#Request.HTTPURL#/ListingImages/#XMLFormat(listDeleteAt(FileName,listLen(FileName,"."),"."))#FS.#XMLFormat(ListLast(FileName,"."))#</image></cfloop></cfif></cfcase>
			<cfcase value="4"><!--- For Sale by Owner - Cars & Trucks --->
			<title>#XMLFormat(ListingTitle)#<cfif FSBO4Qualified is 1> - #XMLFormat('Reference ##: ')##ListingID#</cfif></title>						
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
			<websiteurl><cfif FSBO4Qualified is 1 and Len(AcctWebsiteURL)><cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>#XMLFormat(LocalWebsiteURL)#</cfif></websiteurl><cfif getListingImages.RecordCount><cfloop query="GetListingImages">
			<image>#Request.HTTPURL#/ListingImages/#XMLFormat(listDeleteAt(FileName,listLen(FileName,"."),"."))#FS.#XMLFormat(ListLast(FileName,"."))#</image></cfloop></cfif></cfcase>
			<cfcase value="5"><!--- FSBO Motorcycles, Mopeds, ATVs, & Vibajaji & FSBO Commercial Trucks --->
			<title>#XMLFormat(VehicleYear)#<cfif Len(MakeOther)>  #XMLFormat(MakeOther)#</cfif><cfif Len(ModelOther)> #XMLFormat(ModelOther)#</cfif><cfif FSBO4Qualified is 1> - #XMLFormat('Reference ##: ')##ListingID#</cfif></title>
  			<shortDescr>#XMLFormat(ShortDescr)#</shortDescr>				
			<priceus><cfif Len(PriceUS)>#XMLFormat('$US&nbsp;' & NumberFormat(PriceUS,","))#</cfif></priceus>
			<pricetsh><cfif Len(PriceTZS)>#XMLFormat('TSH&nbsp;' & NumberFormat(PriceTZS,","))#</cfif></pricetsh>
			<datelisted>#XMLFormat(DateFormat(DateListed,'dd/mm/yyyy'))#</datelisted>
			<publicemail>#XMLFormat(PublicEmail)#</publicemail>
			<publicphone>#XMLFormat(PublicPhone)#</publicphone>
  			<shortDescr>#XMLFormat(ShortDescr)#</shortDescr>
			<websiteurl><cfif FSBO4Qualified is 1 and Len(AcctWebsiteURL)><cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>#XMLFormat(LocalWebsiteURL)#</cfif></websiteurl>
			<accountname><cfif HR4Qualified  is 1>#AccountName#</cfif></accountname><cfif getListingImages.RecordCount><cfloop query="GetListingImages">
			<image>#Request.HTTPURL#/ListingImages/#XMLFormat(listDeleteAt(FileName,listLen(FileName,"."),"."))#FS.#XMLFormat(ListLast(FileName,"."))#</image></cfloop></cfif></cfcase>
			<cfcase value="6"><!--- Housing & Real Estate Housing Rentals --->
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
			<area><cfif Len(LocationTitles) or Len(LocationOther)><cfset LocationCount=ListLen(LocationTitles)><cfif Len(LocationOther)><cfset LocationCount=LocationCount+1></cfif><cfif Len(LocationTitles)>#XMLFormat(Replace(LocationTitles,",",", ","ALL"))#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#XMLFormat(LocationOther)#</cfif></cfif></area>
			<locationdirections><cfif Len(LocationText)>#XMLFormat(LocationText)#</cfif></locationdirections>
			<websiteurl><cfif Len(AcctWebsiteURL)><cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>#XMLFormat(LocalWebsiteURL)#</cfif></websiteurl>
			<accountname><cfif HR4Qualified  is 1>#AccountName#</cfif></accountname><cfif getListingImages.RecordCount><cfloop query="GetListingImages">
			<image>#Request.HTTPURL#/ListingImages/#XMLFormat(listDeleteAt(FileName,listLen(FileName,"."),"."))#FS.#XMLFormat(ListLast(FileName,"."))#</image></cfloop></cfif></cfcase>
			<cfcase value="7"><!--- Housing & Real Estate Commercial Rentals --->
			<title>#XMLFormat(ListingTitle)#<cfif Len(SquareFeet) or Len(SquareMeters)> #Round(LocalSquareFeet)# sq ft/#NumberFormat(LocalSquareMeters,",.9")# sq m</cfif><cfif HR4Qualified is 1> - #XMLFormat('Reference ##: ')##ListingID#</cfif></title>
			<squarefeet><cfif Len(LocalSquareFeet)>#Round(LocalSquareFeet)#</cfif></squarefeet>
			<squaremeters><cfif Len(LocalSquareMeters)>#NumberFormat(LocalSquareMeters,",.9")#</cfif></squaremeters>
  			<shortDescr>#XMLFormat(ShortDescr)#</shortDescr>
			<rentus><cfif Len(RentUS)>#XMLFormat('$US&nbsp;' & NumberFormat(RentUS,","))#<cfif Len(Term)>/#XMLFormat(Term)#</cfif></cfif></rentus>
			<renttsh><cfif Len(RentTZS)>#XMLFormat('TSH&nbsp;' & NumberFormat(RentTZS,","))#<cfif Len(Term)>/#XMLFormat(Term)#</cfif></cfif></renttsh>
			<datelisted>#XMLFormat(DateFormat(DateListed,'dd/mm/yyyy'))#</datelisted>
			<publicemail>#XMLFormat(PublicEmail)#</publicemail>
			<publicphone>#XMLFormat(PublicPhone)#</publicphone>
			<area><cfif Len(LocationTitles) or Len(LocationOther)><cfset LocationCount=ListLen(LocationTitles)><cfif Len(LocationOther)><cfset LocationCount=LocationCount+1></cfif><cfif Len(LocationTitles)>#XMLFormat(Replace(LocationTitles,",",", ","ALL"))#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#XMLFormat(LocationOther)#</cfif></cfif></area>
			<locationdirections><cfif Len(LocationText)>#XMLFormat(LocationText)#</cfif></locationdirections>
			<websiteurl><cfif Len(AcctWebsiteURL)><cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>#XMLFormat(LocalWebsiteURL)#</cfif></websiteurl>
			<accountname><cfif HR4Qualified is 1>#AccountName#</cfif></accountname><cfif getListingImages.RecordCount><cfloop query="GetListingImages">
			<image>#Request.HTTPURL#/ListingImages/#XMLFormat(listDeleteAt(FileName,listLen(FileName,"."),"."))#FS.#XMLFormat(ListLast(FileName,"."))#</image></cfloop></cfif></cfcase>
			<cfcase value="8"><!--- Housing & Real Estate For Sale --->
			<title>#XMLFormat(ListingTitle)#<cfif HR4Qualified is 1> - #XMLFormat('Reference ##: ')##ListingID#</cfif></title>
  			<shortDescr>#XMLFormat(ShortDescr)#</shortDescr>			
			<priceus><cfif Len(PriceUS)>#XMLFormat('$US&nbsp;' & NumberFormat(PriceUS,","))#</cfif></priceus>
			<pricetsh><cfif Len(PriceTZS)>#XMLFormat('TSH&nbsp;' & NumberFormat(PriceTZS,","))#</cfif></pricetsh>
			<datelisted>#XMLFormat(DateFormat(DateListed,'dd/mm/yyyy'))#</datelisted>
			<publicemail>#XMLFormat(PublicEmail)#</publicemail>
			<publicphone>#XMLFormat(PublicPhone)#</publicphone>
			<accountname><cfif HR4Qualified is 1>#AccountName#</cfif></accountname><cfif ListFind(CategoryID,"89")>
			<bedrooms>#Bedrooms#</bedrooms>
			<bathrooms>#Bathrooms#</bathrooms>
			<amenities><cfif getListingAmenities.RecordCount or Len(AmenityOther)>#Replace(valueList(getListingAmenities.Title),",",", ","ALL")#<cfif getListingAmenities.RecordCount and Len(AmenityOther)>, </cfif>#AmenityOther#</cfif></amenities></cfif>
			<area><cfif Len(LocationTitles) or Len(LocationOther)><cfset LocationCount=ListLen(LocationTitles)><cfif Len(LocationOther)><cfset LocationCount=LocationCount+1></cfif><cfif Len(LocationTitles)>#XMLFormat(Replace(LocationTitles,",",", ","ALL"))#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#XMLFormat(LocationOther)#</cfif></cfif></area>
			<locationdirections><cfif Len(LocationText)>#XMLFormat(LocationText)#</cfif></locationdirections>
			<websiteurl><cfif Len(AcctWebsiteURL)><cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>#XMLFormat(LocalWebsiteURL)#</cfif></websiteurl>			
			<accountname><cfif HR4Qualified is 1>#AccountName#</cfif></accountname><cfif getListingImages.RecordCount><cfloop query="GetListingImages">
			<image>#Request.HTTPURL#/ListingImages/#XMLFormat(listDeleteAt(FileName,listLen(FileName,"."),"."))#FS.#XMLFormat(ListLast(FileName,"."))#</image></cfloop></cfif></cfcase>
			<cfcase value="9"><!--- Travel & Tourism (Trip Listings) --->
			<title>#XMLFormat(ListingTitle)#</title>
			<expandedlistingurl><cfif (Len(ExpandedListingHTML) or Len(ExpandedListingPDF)) and not ExpandedListingInProgress and DisplayExpandedListing and HasExpandedListing>#request.HTTPURL#/<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelse>ListingUploadedDocs/#ExpandedListingPDF#</cfif></cfif></expandedlistingurl>
  			<shortDescr>#XMLFormat(ShortDescr)#</shortDescr>
			<minimumpriceus><cfif Len(PriceUS)>#XMLFormat('$US&nbsp;' & NumberFormat(PriceUS,","))#</cfif></minimumpriceus>
			<minimumpricetsh><cfif Len(PriceUS)>#XMLFormat('TSH&nbsp;' & NumberFormat(PriceTZS,","))#</cfif></minimumpricetsh>	
			<publicemail>#XMLFormat(PublicEmail)#</publicemail>
			<publicphone>#XMLFormat(PublicPhone)#</publicphone>
			<websiteurl><cfif Len(AcctWebsiteURL)><cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>#XMLFormat(LocalWebsiteURL)#</cfif></websiteurl></cfcase>
			<cfcase value="10"><!--- Jobs & Employment Professional (employment opportunities) --->
			<title>#XMLFormat(ShortDescr)#</title>
  			<shortDescr>#XMLFormat(ListingTitle)#</shortDescr>
			<datelisted>#XMLFormat(DateFormat(DateListed,'dd/mm/yyyy'))#</datelisted>
			<publicemail>#XMLFormat(PublicEmail)#</publicemail>
			<publicphone>#XMLFormat(PublicPhone)#</publicphone>
			<area><cfif Len(LocationTitles) or Len(LocationOther)><cfset LocationCount=ListLen(LocationTitles)><cfif Len(LocationOther)><cfset LocationCount=LocationCount+1></cfif><cfif Len(LocationTitles)>#XMLFormat(Replace(LocationTitles,",",", ","ALL"))#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#XMLFormat(LocationOther)#</cfif></cfif></area>
			<deadline>#DateFormat(Deadline,"dd/mm/yyyy")#</deadline>
			<startdate>#DateFormat(EventStartDate,"dd/mm/yyyy")#</startdate>
			<positiondescr>#XMLFormat(LongDescr)#</positiondescr>
			<positiondescrdoc>#XMLFormat(Request.httpurl & "/ListingUploadedDocs/" & UploadedDoc)#</positiondescrdoc>
			<instructions>#XMLFormat(Instructions)#</instructions>
			<websiteurl><cfif Len(WebsiteLink)>#WebsiteLink#<cfelseif Len(AcctWebsiteURL)><cfif Left(AcctWebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & AcctWebsiteURL><cfelse><cfset LocalWebsiteURL=AcctWebsiteURL></cfif>#XMLFormat(LocalWebsiteURL)#</cfif></websiteurl></cfcase>
			<cfcase value="14"><!--- Community --->			
		 	<title>#XMLFormat(ListingTitle)#</title>
			<ngotype>#XMLFormat(Replace(valueList(getListingNGOTypes.Title),",",", ","ALL"))#<cfif getListingNGOTypes.RecordCount and Len(NGOTypeOther)>, </cfif>#XMLFormat(NGOTypeOther)#</ngotype>
  			<shortDescr>#XMLFormat(ShortDescr)#</shortDescr>
			<expandedlistingurl><cfif (Len(ExpandedListingHTML) or Len(ExpandedListingPDF)) and not ExpandedListingInProgress and DisplayExpandedListing and HasExpandedListing>#request.HTTPURL#/<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelse>ListingUploadedDocs/#ExpandedListingPDF#</cfif></cfif></expandedlistingurl>
   			<publicemail>#XMLFormat(PublicEmail)#</publicemail>
			<publicphone>#XMLFormat(PublicPhone)#</publicphone>
			<fax>#XMLFormat(PublicPhone2)#</fax>
			<otherpublicphone>#XMLFormat(PublicPhone3)#</otherpublicphone>
			<otherpublicphonetwo>#XMLFormat(PublicPhone4)#</otherpublicphonetwo>
			<area><cfif Len(LocationTitles) or Len(LocationOther)><cfset LocationCount=ListLen(LocationTitles)><cfif Len(LocationOther)><cfset LocationCount=LocationCount+1></cfif><cfif Len(LocationTitles)>#XMLFormat(Replace(LocationTitles,",",", ","ALL"))#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#XMLFormat(LocationOther)#</cfif></cfif></area>
			<locationdirections><cfif Len(LocationText)>#XMLFormat(LocationText)#</cfif></locationdirections>
			<websiteurl><cfif Len(WebsiteURL)><cfif Left(WebsiteURL,1) neq "h"><cfset LocalWebsiteURL="http://" & WebsiteURL><cfelse><cfset LocalWebsiteURL=WebsiteURL></cfif>#XMLFormat(LocalWebsiteURL)#</cfif></websiteurl></cfcase>
			<cfcase value="15"><!--- Events --->					
		 	<title>#XMLFormat(ListingTitle)#</title>
  			<shortDescr>#XMLFormat(ShortDescr)#</shortDescr>
			<expandedlistingurl><cfif (Len(ExpandedListingHTML) or Len(ExpandedListingPDF)) and not ExpandedListingInProgress and DisplayExpandedListing and HasExpandedListing>#request.HTTPURL#/<cfif Len(ExpandedListingHTML)>ExpandedListing.CFM?ListingID=#ListingID#<cfelse>ListingUploadedDocs/#ExpandedListingPDF#</cfif></cfif></expandedlistingurl>
			<startdate><cfif Len(EventStartDate)>#DateFormat(EventStartDate,"dd/mm/yyyy")# #TimeFormat(EventStartDate)#</cfif></startdate>
			<enddate><cfif Len(EventEndDate)>#DateFormat(EventEndDate,"dd/mm/yyyy")# #TimeFormat(EventEndDate)#</cfif></enddate>
			<recurrence>#Recurrence#</recurrence>
			<recurrencemonth>#RecurrenceMonth#</recurrencemonth>
			<recurrenceday>#XMLFormat(Replace(valueList(getListingRecurrenceDays.RecurrenceDay),",",", ","ALL"))#</recurrenceday>
   			<publicemail>#XMLFormat(PublicEmail)#</publicemail>
			<publicphone>#XMLFormat(PublicPhone)#</publicphone>
			<area><cfif Len(LocationTitles) or Len(LocationOther)><cfset LocationCount=ListLen(LocationTitles)><cfif Len(LocationOther)><cfset LocationCount=LocationCount+1></cfif><cfif Len(LocationTitles)>#XMLFormat(Replace(LocationTitles,",",", ","ALL"))#</cfif><cfif Len(LocationOther)><cfif LocationCount gt 1>, </cfif>#XMLFormat(LocationOther)#</cfif></cfif></area>
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
