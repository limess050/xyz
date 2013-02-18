<cfparam name="getFilenameForTN" default="0">
<cfparam name="QID" default=""><!--- Refers to CategoryQueryID, used to display randomized results set across pagination pages --->
<cfparam name="PSQID" default=""><!--- Refers to ParentSectionQueryID, used to display randomized results set across pagination pages --->
<cfparam name="HasSections" default="1">
<cfparam name="InJobSectionOverview" default="0">

<!--- Check to see if QID records still exist. If not remove QID and set CurrentPage to 1 --->
<cfif Len(QID)>
	<cfquery name="checkQID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select CategoryQueryID
		From CategoryQueries
		Where CategoryQueryID = <cfqueryparam value="#QID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif not checkQID.RecordCount>
		<cfset QID = "">
		<cfset CurrentPage = 1>
	</cfif>
</cfif>

<cfif HasSections>
	<cfquery name="getListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select L.ListingID, L.ListingTypeID, L.ListingTitle, L.ShortDescr, L.DateListed, L.PriceUS, L.PriceTZS,
		L.RentUS, L.RentTZS, L.Bedrooms, L.Bathrooms, L.AmenityOther, L.LocationOther, L.LocationText,
		L.LongDescr, L.MakeID, L.DateSort,
		L.Make as MakeOther, L.Model as ModelOther, L.VehicleYear, L.Kilometers, L.FourWheelDrive,
		L.Deadline, L.WebsiteURL, L.PublicPhone,  L.PublicPhone2,  L.PublicPhone3,  L.PublicPhone4, L.PublicEmail, 
		L.EventStartDate, L.EventEndDate, L.RecurrenceID, L.RecurrenceMonthID,
		L.ExpandedListingHTML, L.ExpandedListingPDF,
		L.CuisineOther, L.AccountName,
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ# Then 1 Else 0 END as HasExpandedListing,
		L.SquareFeet, L.SquareMeters,
		L.LogoImage, L.ELPTypeThumbnailImage, L.ELPThumbnailFromDoc,
		PS.ParentSectionID, PS.Title as ParentSection, PS.URLSafeTitleDashed as ParentSectionURLSafeTitle,
		S.SectionID, S.Title as SubSection,
		C.CategoryID, C.Title as Category,
		M.Title as Make, T.Title as Transmission,
		Te.Title as Term,
		<cfif getFilenameForTN>
			(Select Top 1 FileName
			From ListingImages With (NoLock)
			Where ListingID=L.ListingID
			Order By OrderNum, ListingImageID)
		<cfelse>
			null
		</cfif> as FileNameForTN,
		<cfif Len(QID)>
			CQL.LineID as QLineID,
		<cfelseif Len(PSQID)>
			PSQL.LineID as QLineID,
		<cfelse>
			1 as QLineID,
		</cfif>
		CASE WHEN L.UserID = <cfqueryparam value="#Request.PhoneOnlyUserID#" cfsqltype="CF_SQL_INTEGER"> THEN 1 ELSE 0 END as PhoneOnlyListing_fl,
		NewID() as RandOrderID
		From ParentSectionsView PS With (NoLock)
		Inner Join Sections S With (NoLock) on PS.ParentSectionID=S.ParentSectionID	
		Inner Join Categories C With (NoLock) on S.SectionID=C.SectionID
		Inner Join ListingCategories LC With (NoLock) on C.CategoryID=LC.CategoryID
		Inner Join ListingsView L With (NoLock) on LC.ListingID=L.ListingID 
		<cfif Len(QID)>
			Inner Join CategoryQueries CQ With (NoLock) on C.CategoryID=CQ.CategoryID and CQ.CategoryQueryID=<cfqueryparam value="#QID#" cfsqltype="cf_sql_integer">
			Inner Join CategoryQueryLines CQL With (NoLock) on CQ.CategoryQueryID=CQL.CategoryQueryID and CQL.ListingID=L.ListingID
		<cfelseif Len(PSQID)>
			Inner Join ParentSectionQueries PSQ With (NoLock) on PS.ParentSectionID=PSQ.ParentSectionID and PSQ.ParentSectionQueryID=<cfqueryparam value="#PSQID#" cfsqltype="cf_sql_integer">
			Inner Join ParentSectionQueryLines PSQL With (NoLock) on PSQ.ParentSectionQueryID=PSQL.ParentSectionQueryID and PSQL.ListingID=L.ListingID
		</cfif>
		Left Outer Join Makes M With (NoLock) on L.MakeID=M.MakeID
		Left Outer Join Transmissions T With (NoLock) on L.TransmissionID=T.TransmissionID
		Left outer Join Terms Te With (NoLock) on L.TermID=Te.TermID
		Where S.Active=1
		<cfinclude template="LiveListingFilter.cfm">
		and C.CategoryID in (<cfqueryparam value="#CategoryIDs#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
		<!--- Job listings can have multiple categories, so limit to one category so the listing does not appear mulitple times on the Section Overview page. --->
		<cfif InJobSectionOverview>and LC.CategoryID = (Select Top 1 CategoryID From ListingCategories With (NoLock) where ListingID=L.ListingID)</cfif>
		<cfif ParentSectionID is "8" and Len(JETID)>
			<cfswitch expression="#JETID#">
				<cfcase value="1,3">
					and L.ListingTypeID in (10,12)
				</cfcase>
				<cfcase value="2,4">
					and L.ListingTypeID in (11,13)
				</cfcase>
			</cfswitch>
		</cfif>
		<cfif Len(FilterWhereClause)>#PreserveSingleQuotes(FilterWhereClause)#</cfif>
		<cfswitch expression="#SortBy#">
			<cfcase value="Year">
				Order By C.OrderNum, L.VehicleYear desc, L.Title, L.DateSort desc
			</cfcase>
			<cfcase value="MakeModel">
				<cfif CategoryID is "84">
					Order By QLineID, C.OrderNum, M.Title, L.Model, L.VehicleYear, L.Title, L.DateSort desc
				<cfelse><!--- Motorcycles, mopeds, etc where Make and Model are open text values --->
					Order By QLineID, C.OrderNum, L.Make, L.Model, L.VehicleYear, L.Title, L.DateSort desc
				</cfif>
			</cfcase>
			<cfcase value="MostRecent">
				Order By QLineID, L.DateSort desc, C.OrderNum, M.Title, L.Model, L.VehicleYear, L.Title
			</cfcase>
			<cfdefaultcase>
				Order By QLineID, HasExpandedListing desc, PhoneOnlyListing_fl, RandOrderID
			</cfdefaultcase>
		</cfswitch>
	</cfquery>

<cfelse>
	
	<cfquery name="getListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select L.ListingID, L.ListingTypeID, L.ListingTitle, L.ShortDescr, L.DateListed, L.PriceUS, L.PriceTZS,
		L.RentUS, L.RentTZS, L.Bedrooms, L.Bathrooms, L.AmenityOther, L.LocationOther, L.LocationText,
		L.LongDescr, L.MakeID, L.DateSort,
		L.Make as MakeOther, L.Model, L.Model as ModelOther, L.VehicleYear, L.Kilometers, L.FourWheelDrive,
		L.Deadline, L.WebsiteURL, L.PublicPhone,  L.PublicPhone2,  L.PublicPhone3,  L.PublicPhone4, L.PublicEmail,
		L.EventStartDate, L.EventEndDate, L.RecurrenceID, L.RecurrenceMonthID,
		L.ExpandedListingHTML, L.ExpandedListingPDF,
		L.CuisineOther, L.AccountName,
		(Select Min(ListingEventDate) From ListingEventDays With (NoLock) Where ListingID=L.ListingID) as StartDate, (Select Max(ListingEventDate) From ListingEventDays With (NoLock) Where ListingID=L.ListingID) as EndDate,
		L.CuisineOther, L.AccountName, L.ELPTypeThumbnailImage,
		<cfif SortBy is "EventSort">
			<cfinclude template="../includes/EventOrderingColumns.cfm">
		</cfif>
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ# Then 1 Else 0 END as HasExpandedListing,
		L.SquareFeet, L.SquareMeters,
		L.LogoImage, L.ELPTypeThumbnailImage, L.ELPThumbnailFromDoc,
		PS.ParentSectionID, PS.Title as ParentSection, PS.URLSafeTitleDashed as ParentSectionURLSafeTitle,
		null as SectionID, null as SubSection,
		C.CategoryID, C.Title as Category,
		M.Title as Make, T.Title as Transmission,
		Te.Title as Term,
		
		<cfif getFilenameForTN>
			(Select Top 1 FileName
			From ListingImages With (NoLock)
			Where ListingID=L.ListingID
			Order By OrderNum, ListingImageID)
		<cfelse>
			null
		</cfif> as FileNameForTN,
		<cfif Len(QID)>
			CQL.LineID as QLineID,
		<cfelseif Len(PSQID)>
			PSQL.LineID as QLineID,
		<cfelse>
			1 as QLineID,
		</cfif>
		CASE WHEN L.UserID = <cfqueryparam value="#Request.PhoneOnlyUserID#" cfsqltype="CF_SQL_INTEGER"> THEN 1 ELSE 0 END as PhoneOnlyListing_fl,
		NewID() as RandOrderID
		From ParentSectionsView PS With (NoLock) 
		Inner Join Categories C With (NoLock) on PS.ParentSectionID=C.ParentSectionID
		Inner Join ListingCategories LC With (NoLock) on C.CategoryID=LC.CategoryID
		Inner Join ListingsView L With (NoLock) on LC.ListingID=L.ListingID
		<cfif Len(QID)>
			Inner Join CategoryQueries CQ With (NoLock) on C.CategoryID=CQ.CategoryID and CQ.CategoryQueryID=<cfqueryparam value="#QID#" cfsqltype="cf_sql_integer">
			Inner Join CategoryQueryLines CQL With (NoLock) on CQ.CategoryQueryID=CQL.CategoryQueryID and CQL.ListingID=L.ListingID
		<cfelseif Len(PSQID)>
			Inner Join ParentSectionQueries PSQ With (NoLock) on PS.ParentSectionID=PSQ.ParentSectionID and PSQ.ParentSectionQueryID=<cfqueryparam value="#PSQID#" cfsqltype="cf_sql_integer">
			Inner Join ParentSectionQueryLines PSQL With (NoLock) on PSQ.ParentSectionQueryID=PSQL.ParentSectionQueryID and PSQL.ListingID=L.ListingID
		</cfif>
		Left Outer Join Makes M With (NoLock) on L.MakeID=M.MakeID
		Left Outer Join Transmissions T With (NoLock) on L.TransmissionID=T.TransmissionID
		Left Outer Join Terms Te With (NoLock) on L.TermID=Te.TermID
		Where PS.Active=1		
		<cfinclude template="LiveListingFilter.cfm">
		and C.CategoryID in (<cfqueryparam value="#CategoryIDs#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
		<cfif Len(FilterWhereClause)>#PreserveSingleQuotes(FilterWhereClause)#</cfif>
		<cfswitch expression="#SortBy#">
			<cfcase value="Year">
				Order By C.OrderNum, L.VehicleYear desc, L.Title, L.DateSort desc
			</cfcase>
			<cfcase value="MakeModel">
				<cfif CategoryID is "84">
					Order By QLineID, C.OrderNum, M.Title, L.Model, L.VehicleYear, L.Title, L.DateSort desc
				<cfelse><!--- Motorcycles, mopeds, etc where Make and Model are open text values --->
					Order By QLineID, C.OrderNum, L.Make, L.Model, L.VehicleYear, L.Title, L.DateSort desc
				</cfif>
			</cfcase>
			<cfcase value="MostRecent">
				Order By QLineID, L.DateSort desc, C.OrderNum, M.Title, L.Model, L.VehicleYear, L.Title
			</cfcase>
			<cfcase value="EventSort">
				Order By QLineID, EventSortDate, EventRank, L.DateSort desc, C.OrderNum, L.Title
			</cfcase>
			<cfdefaultcase>
				Order By QLineID, HasExpandedListing desc, PhoneOnlyListing_Fl, RandOrderID
			</cfdefaultcase>
		</cfswitch>
	</cfquery>
</cfif>
