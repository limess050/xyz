
<cfscript>
function GetNthOccOfDayInMonth(NthOccurrence,TheDayOfWeek,TheMonth,TheYear)
{
Var TheDayInMonth=0;
if(TheDayOfWeek lt DayOfWeek(CreateDate(TheYear,TheMonth,1))){
TheDayInMonth= 1 + NthOccurrence*7 + (TheDayOfWeek - DayOfWeek(CreateDate(TheYear,TheMonth,1))) MOD 7;
}
else{
TheDayInMonth= 1 + (NthOccurrence-1)*7 + (TheDayOfWeek - DayOfWeek(CreateDate(TheYear,TheMonth,1))) MOD 7;
}
//If the result is greater than days in month or less than 1, return -1
if(TheDayInMonth gt DaysInMonth(CreateDate(TheYear,TheMonth,1)) OR TheDayInMonth lt 1){
return -1;
}
else{
return TheDayInMonth;
}
}

</cfscript>



<cfset ListingID=PK>

<cfquery name="setDeletedState" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Update Listings
	Set DeletedAfterSubmittedDate = null
	Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
	and DeletedAfterSubmitted=0
	
	Update Listings
	Set DeletedAfterSubmittedDate = getDate()
	Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
	and DeletedAfterSubmitted=1
	and DeletedAfterSubmittedDate is null
</cfquery>

<cfinclude template="../includes/ListingTitlesUpdater.cfm">

<cfquery name="getListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select L.ListingID, L.OrderID, L.ListingFee, L.Title as ListingTitle, L.DateListed,
	L.PriceUS, L.PriceTZS, L.PublicPhone, L.PublicEmail, 
	L.ShortDescr, 
	L.LocationID, L.LocationOther, L.LocationText,
	L.WebsiteURL, 
	L.ContactFirstName, L.ContactLastName, L.ContactEmail, L.ContactPhone,
	L.AltContactFirstName, L.AltContactLastName, L.AltContactEmail, L.AltContactPhone,
	L.VehicleYear, L.MakeID, L.Make, L.Model, L.Kilometers, L.FourWheelDrive, L.TransmissionID,
	L.Area, L.RentUS, L.RentTZS, L.TermID, L.Bedrooms, L.Bathrooms, L.AmenityOther,
	L.Deadline, L.LongDescr, L.Instructions, L.UploadedDoc,
	L.EventStartDate, L.EventEndDate, L.RecurrenceID, L.RecurrenceMonthID, 
	L.InProgress, L.ListingTypeID, L.InProgressPassword, L.ExpirationDate,
	L.ListingLiveEmailDateSent, L.Reviewed, L.FeaturedListing, L.FeaturedTravelListing, O.PaymentStatusID,
	Lo.Title as Location, L.LocationOther, L.LocationText,
	L.LogoImage, L.ELPTypeThumbnailImage, L.ELPTypeID, ELPTypeOther,
	M.Title as MakeLU, T.Title as Transmission, Te.Title as Terms
	From Listings L
	Left Outer Join Orders O on L.OrderID=O.OrderID
	Left Outer Join Makes M on L.MakeID=M.MakeID
	Left Join Locations Lo on L.LocationID=Lo.LocationID
	Left Outer Join Transmissions T on L.TransmissionID=T.TransmissionID
	Left Outer Join Terms Te on L.TermID=Te.TermID
	Where L.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfquery name="getELPOtherTypeID"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select ElpTypeID
	From ELPTypes
	Where Other_fl=1
</cfquery>

<!--- Update URLSafeTitle --->
<cfquery name="updateListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Update Listings
	Set URLSafeTitle=<cfqueryparam value="#REreplace(getListing.ListingTitle, "[^a-zA-Z0-9]","","all")#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(getListing.ListingTitle)#">
	Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>


<!--- Only calculate the Exp Date if none exists yet.  --->
<cfif not Len(getListing.ExpirationDate)>
	<cfinclude template="../includes/SetExpirationDate.cfm">
</cfif>

<cfif getListing.PaymentStatusID is "2" and not Len(getListing.ListingLiveEmailDateSent) and getListing.Reviewed>
	<cfset NewListingID=ListingID>
	<cfset SetDateLive="1">
	<cfinclude template="../includes/EmailListingLive.cfm">
</cfif>


<cfif getListing.ListingTypeID EQ 15>		
	<cfquery name="getRecurrenceDays"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		select lr.RecurrenceDayID, rd.descr
		from ListingRecurrences lr
		inner join RecurrenceDays rd ON rd.recurrenceDayID = lr.recurrenceDayID
		where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<cfif Len(getListing.EventEndDate)>
		<cfset eventDuration = DateDiff("d",getListing.EventStartDate,getListing.EventEndDate) + 1>
	<cfelse>
		<cfset eventDuration = 1>
	</cfif>
	
	<cfquery name="deleteListingDays"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		delete from ListingEventDays
		where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
				
	<cfloop from="1" to="#EventDuration#" index="i">
		<cfset eventDate = DateAdd("d",Evaluate(i-1),getListing.EventStartDate)>	
		<cfquery name="insListingDates"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			insert into ListingEventDays(ListingID,ListingEventDate)
			values(<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">,
			<cfqueryparam value="#DateFormat(eventDate,'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE">)
		</cfquery>
	</cfloop>	
	
	<cfif Len(getListing.RecurrenceID)>
			
		<cfquery name="getTermExpiration"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			select TermExpiration
			from ListingTypes
			where ListingTypeID = 15
		</cfquery>
		<cfset listingEndDate = DateAdd("d",getTermExpiration.TermExpiration,Now())>		
		<cfswitch expression="#getListing.RecurrenceID#">
			<cfcase value="1">
				
				
				<cfset dayDiff = DateDiff("d",getListing.EventStartDate,listingEndDate)>
				<cfloop from="1" to="#dayDiff#" index="i">
					<cfset thisDate = DateAdd("d",i,getListing.EventStartDate)>
					
					<cfif ListFind(ValueList(getRecurrenceDays.descr),DayOfWeekAsString(DayOfWeek(thisDate)))>
						<cfloop from="1" to="#EventDuration#" index="i">
							<cfset eventDate = DateAdd("d",Evaluate(i-1),thisDate)>	
							<cfquery name="insListingDates"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
								insert into ListingEventDays(ListingID,ListingEventDate)
								values(<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">,
								<cfqueryparam value="#DateFormat(eventDate,'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE">)
							</cfquery>
						</cfloop>
						
					</cfif>	
				</cfloop>
				
			</cfcase>
			<cfcase value="2">
				
				<cfset dayDiff = DateDiff("d",getListing.EventStartDate,listingEndDate)>
				<cfset counter = 1>
				<cfset counter2 = ListLen(ValueList(getRecurrenceDays.descr))>
				<cfloop from="1" to="#dayDiff#" index="i">
					<cfset thisDate = DateAdd("d",i,getListing.EventStartDate)>
					
					<cfif ListFind(ValueList(getRecurrenceDays.descr),DayOfWeekAsString(DayOfWeek(thisDate)))>
						
						<cfif counter EQ ListLen(ValueList(getRecurrenceDays.descr)) AND counter2 NEQ 0>
							<cfset counter2 = counter2 - 1>
						<cfelse>	
							<cfloop from="1" to="#EventDuration#" index="i">
							<cfset eventDate = DateAdd("d",Evaluate(i-1),thisDate)>	
							<cfquery name="insListingDates"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
								insert into ListingEventDays(ListingID,ListingEventDate)
								values(<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">,
								<cfqueryparam value="#DateFormat(eventDate,'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE">)
							</cfquery>
							</cfloop>
							<cfset counter = counter + 1>
							<cfset counter2 = ListLen(ValueList(getRecurrenceDays.descr))>
							
						</cfif>
					</cfif>	
					<cfif counter2 EQ 0>
						<cfset counter = 0>
					</cfif>	
				</cfloop>
				
			</cfcase>
			<cfcase value="3">
				<cfquery name="getRecurrenceMonth"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					select descr, daily
					from RecurrenceMonths 
					where recurrenceMonthID = <cfqueryparam value="#getListing.RecurrenceMonthID#" cfsqltype="CF_SQL_INTEGER">			
				</cfquery>				
				<cfset monthDiff = DateDiff("m",getListing.EventStartDate,listingEndDate)>
				
				<cfloop from="1" to="#monthDiff#" index="i">
					<cfif getRecurrenceMonth.daily>
						<cfset thisDate = CreateDate(Year(DateAdd("m",i,getListing.EventStartDate)),Month(DateAdd("m",i,getListing.EventStartDate)),getListing.RecurrenceMonthID)>
					<cfelse>
						<cfset occurenceArray = StructNew()>
						<cfset occurenceArray["Sunday"] = 1>
						<cfset occurenceArray["Monday"] = 2>
						<cfset occurenceArray["Tuesday"] = 3>
						<cfset occurenceArray["Wednesday"] = 4>
						<cfset occurenceArray["Thursday"] = 5>
						<cfset occurenceArray["Friday"] = 6>
						<cfset occurenceArray["Saturday"] = 7>
						<cfset occurence = ListFirst(getRecurrenceMonth.descr," ")>
						<cfset occurenceDay = ListLast(getRecurrenceMonth.descr," ")>
						<cfset occurenceDayNumeric = occurenceArray["#occurenceDay#"]>
						<cfset occurenceNumeric = REReplace(occurence,"st|nd|rd|th","","ALL")>
						
						<cfset dayOfMonth = GetNthOccOfDayInMonth(occurenceNumeric,occurenceDayNumeric,Month(DateAdd("m",i,getListing.EventStartDate)),Year(DateAdd("m",i,getListing.EventStartDate)))>
						<cfif dayOfMonth EQ "" OR dayOfMonth EQ -1>
							<cfset dayOfMonth = GetNthOccOfDayInMonth(4,occurenceDayNumeric,Month(DateAdd("m",i,getListing.EventStartDate)),Year(DateAdd("m",i,getListing.EventStartDate)))>
						</cfif>
						<cfset thisDate = CreateDate(Year(DateAdd("m",i,getListing.EventStartDate)),Month(DateAdd("m",i,getListing.EventStartDate)),dayOfMonth)>
					</cfif>
					
					<cfloop from="1" to="#EventDuration#" index="i">
						<cfset eventDate = DateAdd("d",Evaluate(i-1),thisDate)>	
						<cfquery name="insListingDates"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							insert into ListingEventDays(ListingID,ListingEventDate)
							values(<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">,
							<cfqueryparam value="#DateFormat(eventDate,'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE">)
						</cfquery>
					</cfloop>
						
					
				</cfloop>
				
			</cfcase>
			<cfcase value="4">
							
				<cfset yearDiff = DateDiff("yyyy",getListing.EventStartDate,listingEndDate)>
				
				<cfloop from="1" to="#yearDiff#" index="i">
					
						<cfset thisDate = DateAdd("yyyy",i,getListing.EventStartDate)>
				
					<cfloop from="1" to="#EventDuration#" index="i">
						<cfset eventDate = DateAdd("d",Evaluate(i-1),thisDate)>	
						<cfquery name="insListingDates"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							insert into ListingEventDays(ListingID,ListingEventDate)
							values(<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">,
							<cfqueryparam value="#DateFormat(eventDate,'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE">)
						</cfquery>
					</cfloop>
						
				</cfloop>
				
			</cfcase>
		</cfswitch>
	</cfif>	
</cfif>

<!--- If Logo was uploaded, resize it --->
<cfif ListFind("1,2,9,14,15", getListing.ListingTypeID)>
	<cfset ImageDir=Request.ListingUploadedDocsDir>
	<cfset ImageDirRel="ListingUploadedDocs">
	<cfif Len(getListing.LogoImage)>
		<cfset ResizeFileName=getListing.LogoImage>
		<cfset TNLongestSide="175">
		<cfinclude template="../includes/ResizeImage.cfm">
	</cfif>
	<cfif Len(getListing.ELPTypeThumbnailImage)>
		<cfset ResizeFileName=getListing.ELPTypeThumbnailImage>
		<cfset TNLongestSide="200">
		<cfset TNTwoLongestSide="175">
		<cfinclude template="../includes/ResizeImage.cfm">
		<cfquery name="MarkELPImage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update Listings
			Set ELPThumbnailFromDoc=0
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cfif>
	<cfif getListing.ELPTypeID neq getELPOtherTypeID.ELPTypeID and Len(getListing.ELPTypeOther)>
		<cfquery name="ClearELPTypeOther" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update Listings
			Set ELPTypeOther=null
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cfif>
</cfif>

<cfif getListing.FeaturedListing>
	<cfquery name="ClearPreviousFeaturedListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set FeaturedListing=0
		Where FeaturedListing = 1
		and ListingID <> <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
</cfif>
	
<cfif getListing.FeaturedTravelListing>
	<cfquery name="ClearPreviousFeaturedTravelListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set FeaturedTravelListing=0
		Where FeaturedTravelListing = 1
		and ListingID <> <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
</cfif>
	
<cfif IsDefined('Session.ListingReferer') and Len(session.ListingReferer)>
	<cflocation url="#Session.ListingReferer#" addToken="No">
</cfif>
