<cfif Len(LinkID)>
	<cfquery name="getListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ListingID, L.LinkID, L.OrderID, L.ListingFee,
		L.ListingTitle,
		L.DateListed,
		L.PriceUS, L.PriceTZS, L.PublicPhone,  L.PublicPhone2,  L.PublicPhone3,  L.PublicPhone4, L.PublicEmail, 
		L.ShortDescr, L.CuisineOther, 
		L.LocationOther, L.LocationText,
		L.WebsiteURL, L.AccountName,
		L.ContactFirstName, L.ContactLastName, L.ContactEmail, L.ContactPhone, L.ContactSecondPhone,
		L.AltContactFirstName, L.AltContactLastName, L.AltContactEmail, L.AltContactPhone, L.AltContactSecondPhone,
		L.VehicleYear, L.MakeID, L.Make as MakeOther, L.Model as ModelOther, L.Kilometers, L.FourWheelDrive, L.TransmissionID,
		L.Area, L.RentUS, L.RentTZS, L.TermID, L.Bedrooms, L.Bathrooms, L.AmenityOther,
		L.SquareFeet, L.SquareMeters,
		L.Deadline, L.LongDescr, L.Instructions, L.UploadedDoc, L.OrderDate, IsNull(L.ExpandedFee,0) as ExpandedFee,
		L.EventStartDate, L.EventEndDate, L.RecurrenceID, L.RecurrenceMonthID, 
		L.InProgress, L.ListingTypeID, L.ListingType, L.InProgressPassword, L.Active, L.Reviewed, 
		L.ExpandedListingHTML, L.ExpandedListingPDF, L.ExpandedListingFee, L.ExpandedListingInProgress,
		L.ExpandedListingOrderID,
		L.PriceRangeID, L.NGOTypeOther, L.InProgressCompanyName,
		L.LocationOther, L.LocationText,
		M.Title as Make, T.Title as Transmission, Te.Title as Term,
		LS.SectionID as ListingSectionID, LPS.ParentSectionID, 
		L.AcctWebsiteURL,
		L.UserID, L.InProgressUserID, L.ExpirationDate,
		L.LogoImage, CASE WHEN L.ELPTypeOther is not null and ELPTypeOther <> '' THEN L.ELPTypeOther ELSE ELPT.Descr END as ELPType, L.ELPTypeOther, L.ELPTypeThumbnailImage,
		CASE WHEN L.UserID = <cfqueryparam value="#Request.PhoneOnlyUserID#" cfsqltype="CF_SQL_INTEGER"> THEN 1 ELSE 0 END as PhoneOnlyListing_fl,
		ParkOther, L.DateSort, L.MovieFees
		From ListingsView L
		Inner Join ListingParentSections LPS on L.ListingID=LPS.ListingID
		Left Outer Join ListingSections LS on L.ListingID=LS.ListingID
		Left Outer Join Makes M on L.MakeID=M.MakeID
		Left Outer Join Transmissions T on L.TransmissionID=T.TransmissionID
		Left Outer Join Terms Te on L.TermID=Te.TermID
		Left Outer Join ELPTypes ELPT on L.ELPTypeID=ELPT.ELPTypeID
		Where L.LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfif getListing.RecordCount>		
		<cfset ListingID=getListing.ListingID>
		<cfset expandedFee = 0>
		<cfif not getListing.inProgress><!--- Listing already submitted (even if expandedFee is zero, prorating of ListingFee may still apply --->
			<cfif Len(getListing.OrderDate)>
				<cfset PostingDate=getListing.OrderDate>
			<cfelse>
				<cfset PostingDate=getListing.DateListed>
			</cfif>
			<cfif DateDiff('d',PostingDate,Now()) LT 30>
				<cfset expandedFee = getListing.expandedFee>
			<cfelse>
				<cfset expandedFee = getListing.expandedFee + ((DateDiff('d',PostingDate,Now())/365)*getListing.ListingFee)>	
			</cfif>
		<cfelse>
			<cfset expandedFee = getListing.expandedFee>	
		</cfif>	
		
		<cfif Len(getListing.UserID)>
			<cfset AcctUserID=getListing.UserID>		
		<cfelse>
			<cfset AcctUserID=getListing.InProgressUserID>
		</cfif>
		<cfinclude template="AcctQualified.cfm">		
		
		<cfquery name="GetListingCategories"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select LC.CategoryID
			From ListingCategories LC
			Where LC.ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>	
		<cfset CategoryID=ValueList(getListingCategories.CategoryID)>
		
		<cfquery name="GetLocations"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select LL.LocationID, L.Title as Location
			From ListingLocations LL
			Inner Join Locations L on LL.LocationID=L.LocationID
			Where LL.ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfquery name="GetLocationTitles"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select L.Title as Location
			From ListingLocations LL
			Inner Join Locations L on LL.LocationID=L.LocationID
			Where LL.ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			and L.LocationID <> 4
			Order by L.Title
		</cfquery>
		<cfset LocationID=ValueList(getLocations.LocationID)>
		<cfset LocationTitles=ValueList(getLocationTitles.Location)>
		
		<cfquery name="GetParks"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select LP.ParkID, P.Title as Park
			From ListingParks LP
			Inner Join Parks P on LP.ParkID=P.ParkID
			Where LP.ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset ParkID=ValueList(getParks.ParkID)>
		
		<cfquery name="getRecurrenceDays"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			select lr.RecurrenceDayID, rd.descr
			from ListingRecurrences lr
			inner join RecurrenceDays rd ON rd.recurrenceDayID = lr.recurrenceDayID
			where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
	<cfelse>
		<cfset LinkID="">
		<div id="internalalert">Listing not found</div><br clear="all"></div>
		<cfinclude template="../templates/footer.cfm"></div></div></body></html>
		<cfabort>
	</cfif>	
	<cfif Len(getListing.OrderID)><!--- Used only on includes/AddListingStepFour.cfm, to generate 'receipt'. --->
		<cfquery name="getOrder"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select O.OrderID, O.PaymentMethodID, O.OrderTotal, O.DueDate, 
			O.CCLastFourDigits, O.CCExpireMonth, O.CCExpireYear,
			PM.Descr as PaymentMethod
			From Orders O Inner Join PaymentMethods PM on O.PaymentMethodID=PM.PaymentMethodID
			Where O.OrderID=
			<cfif Len(getListing.ExpandedListingOrderID) and getListing.ExpandedListingOrderID neq getListing.OrderID>
				<cfqueryparam value="#getListing.ExpandedListingOrderID#" cfsqltype="CF_SQL_INTEGER">
			<cfelse>
				<cfqueryparam value="#getListing.OrderID#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
		</cfquery>
	</cfif>
<cfelse>
	<div id="internalalert">Listing not found</div><br clear="all"></div>
	<cfinclude template="../templates/footer.cfm"></div></div></body></html>
	<cfabort>
</cfif>