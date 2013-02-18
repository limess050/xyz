	<cfset LocationIDs = "">
	<cfset NotLocationIDs = "">
	<cfif Len(SearchLocation)>
		<cfswitch expression="#SearchLocation#">
			<cfcase value="Dar">
				<cfset LocationIDs = "1">
			</cfcase>
			<cfcase value="Arusha/Moshi">
				<cfset LocationIDs = "9,16">
			</cfcase>
			<cfcase value="Zanzibar">
				<cfset LocationIDs = "13">
			</cfcase>
			<cfcase value="Other">
				<cfset NotLocationIDs = "1,9,16,13">
			</cfcase>
		</cfswitch>
	</cfif>
	<!--- Perform Search of Site --->
	
	
	<cfset FTSearchStr = NormalizeFullTextSearchTerm(SearchString)>
	<!--- Make all search terms stemmed by adding an asterisk before each closing quote. --->
	<cfset FTSearchStr = Replace(FTSearchStr,'" ','*" ','All')><!--- Adds * for all but last term --->
	<cfif Len(FTSearchStr)>
		<cfset FTSearchStr = Left(FTSearchStr,Len(FTSearchStr)-1) & '*"'><!--- Adds * to last term --->
	</cfif>
	<!--- 
	ResultOrder 1 Business and Comm
				2 Pages
				3 Other Listings
				4 Parent Sections, Sections, Categories
					
	ResultType: 1 Business Listings
				2 Pages
				3 Other Listings
				4 Parent Section
				5 Section
				6 Category
	 --->
	<cfquery name="getResults" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select L.ListingID, CASE WHEN L.ListingTypeID IN (1,2,14) THEN 1 ELSE 3 END as ResultOrder, CASE WHEN L.ListingTypeID IN (1,2,14) THEN 1 ELSE 3 END as ResultType,
		L.ListingID as PKID, L.URLSafeTitle, L.ListingTitle as ListingTitle,	
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and (L.ExpirationDateELP >= #application.CurrentDateInTZ# or L.ListingTypeID = 15) Then 1 Else 0 END as HasExpandedListing,
		L.LogoImage,
		CASE WHEN L.ListingTypeID in (3,4,5,6,7,8) THEN
			(Select Top 1 FileName
			From ListingImages With (NoLock)
			Where ListingID=L.ListingID
			Order By OrderNum, ListingImageID) ELSE null END as FileNameForTN,
		L.ListingTypeID, L.LocationOther, L.RecurrenceID, L.RecurrenceMonthID, L.ELPTypeThumbnailImage, L.ExpandedListingPDF,
		L.EventStartDate,
		Case When L.ListingTypeID = 15 THEN (Select Min(ListingEventDate) From ListingEventDays With (NoLock) Where ListingID=L.ListingID) ELSE null END as StartDate, 
		Case When L.ListingTypeID = 15 THEN (Select Max(ListingEventDate) From ListingEventDays With (NoLock) Where ListingID=L.ListingID) ELSE null END as EndDate,
		L.PriceUS, L.PriceTZS, L.MakeID, L.Make as MakeOther, L.Model as ModelOther, L.VehicleYear, L.RentUS, L.RentTZS, L.SquareFeet, L.SquareMeters, L.Deadline, L.ShortDescr,
		M.Title as Make, Te.Title as Term
		FROM ListingsView L With (NoLock)
		Inner Join Listings L2 on L.ListingID=L2.ListingID
		Left Outer Join Makes M With (NoLock) on L.MakeID=M.MakeID
		Left Outer Join Terms Te With (NoLock) on L.TermID=Te.TermID
		Where CONTAINS ((L2.Title,L2.ListingHeaderTitle,L2.ListingTitleForH1), <cfqueryparam value='#FTSearchStr#' cfsqltype="CF_SQL_VARCHAR">)
		<cfinclude template="LiveListingFilter.cfm">
		<cfif Len(LocationIDs)>
			and exists (Select ListingID from ListingLocations LL where LL.ListingID=L.ListingID and LL.LocationID in (<cfqueryparam value="#LocationIDs#" cfsqltype="CF_SQL_INTEGER" List="Yes">)) 
		<cfelseif Len(notLocationIDs)>
			and exists (Select ListingID from ListingLocations LL where LL.ListingID=L.ListingID and LL.LocationID not in (<cfqueryparam value="#notLocationIDs#" cfsqltype="CF_SQL_INTEGER" List="Yes">)) 
		</cfif> 
		<cfif not Len(LocationIDs)>
			UNION
			Select null as ListingID, 2 as ResultOrder, 2 as ResultType, P.PageID as PKID, Name as URLSafeTitle, Title as ListingTitle,
			0 as HasExpandedListing, null as LogoImage,
			null as FileNameForTN,
			0 as ListingTypeID, null as LocationOther, null as RecurrenceID, null as RecurrenceMonthID, null as ELPTypeThumbnailImage, null as ExpandedListingPDF,
			null as EventStartDate, null as StartDate, null as EndDate,
			null as PriceUS, null as PriceTZS, null as MakeID, null as MakeOther, null as ModelOther, null as VehicleYear, null as RentUS, null as RentTZS, 
			null as SquareFeet, null as SquareMeters, null as Deadline, null as ShortDescr, null as Make, null as Term
			From LH_Pages_Live P With (NoLock)
			Where CONTAINS ((P.Title, P.NavTitle, P.TitleTag), <cfqueryparam value='#FTSearchStr#' cfsqltype="CF_SQL_VARCHAR">)
			UNION
			Select null as ListingID, 4 as ResultOrder, CASE WHEN S.ParentSectionID is null then 4 ELSE 5 END as ResultType, S.SectionID as PKID, 
			CASE WHEN S.ParentSectionID is null THEN  PS2.URLSafeTitleDashed ELSE PS.URLSafeTitleDashed + '##S' + CAST(SectionID as varchar(10)) END as URSafeTitle,
			CASE WHEN S.ParentSectionID is null THEN S.Title WHEN S.ParentSectionID in (8) THEN PS.Title + ' - ' + S.Title ELSE S.Title END as ListingTitle,
			0 as HasExpandedListing, null as LogoImage,
			null as FileNameForTN,
			0 as ListingTypeID, null as LocationOther, null as RecurrenceID, null as RecurrenceMonthID, null as ELPTypeThumbnailImage, null as ExpandedListingPDF,
			null as EventStartDate, null as StartDate, null as EndDate,
			null as PriceUS, null as PriceTZS, null as MakeID, null as MakeOther, null as ModelOther, null as VehicleYear, null as RentUS, null as RentTZS, 
			null as SquareFeet, null as SquareMeters, null as Deadline, null as ShortDescr, null as Make, null as Term
			From Sections S With (NoLock)
			Left Outer Join ParentSectionsView PS With (NoLock) on S.ParentSectionID=PS.ParentSectionID
			Left Outer Join ParentSectionsView PS2 With (NoLock) on S.SectionID=PS2.ParentSectionID
			Where S.Active = 1
			and S.SectionID <> 57 <!--- Used Cars Trucks & Boats SubSection (hidden throughout site) --->
			and (CONTAINS ((S.Title,S.BrowserTitle,S.H1Text), <cfqueryparam value='#FTSearchStr#' cfsqltype="CF_SQL_VARCHAR">))
			UNION
			Select null as ListingID, 4 as ResultOrder, 6 as ResultType, C.CategoryID as PKID, C.URLSafeTitleDashed as URSafeTitle, C.Title as ListingTotle,
			0 as HasExpandedListing, null as LogoImage,
			null as FileNameForTN,
			0 as ListingTypeID, null as LocationOther, null as RecurrenceID, null as RecurrenceMonthID, null as ELPTypeThumbnailImage, null as ExpandedListingPDF,
			null as EventStartDate, null as StartDate, null as EndDate,
			null as PriceUS, null as PriceTZS, null as MakeID, null as MakeOther, null as ModelOther, null as VehicleYear, null as RentUS, null as RentTZS, 
			null as SquareFeet, null as SquareMeters, null as Deadline, null as ShortDescr, null as Make, null as Term
			From Categories C With (NoLock)
			Where C.Active = 1
			and C.SectionID <> 29 <!--- Old Tenders Categories  --->
			and (CONTAINS ((C.Title,C.BrowserTitle,C.H1Text), <cfqueryparam value='#FTSearchStr#' cfsqltype="CF_SQL_VARCHAR">))
		</cfif>
		Order By ResultOrder, ListingTitle
	</cfquery>