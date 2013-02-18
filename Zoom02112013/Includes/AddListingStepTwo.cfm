<cfsetting requesttimeout="300">

<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<!--- SectionID conflicts with the getPage.SectionID, so rename it here. --->
<cfif IsDefined('form.SectionID')>
	<cfset ListingSectionID=form.SectionID>
</cfif>

<cfset ListingImagesVariables="">
<cfoutput>
	<cfloop from="1" to="12" index="i">
		<cfset ListingImagesVariables=ListAppend(ListingImagesVariables,"ListingImageID#i#,ListingImageFileName#i#")>
	</cfloop>
</cfoutput>
<cfset allFields="ParentSectionID,ListingSectionID,CategoryID,ListingTypeID,UpdateSAndC,ListingID,LinkID,ListingFee,ListingTitle,Price,PriceUS,PriceTZS,PriceType,PublicPhone,PublicPhone2,PublicPhone3,PublicPhone4,PublicEmail,CuisineID,CuisineOther,NGOTypeID,NGOTypeOther,PriceRangeID,ShortDescr,ListingCategoryID,LocationID,ParkID,ParkOther,RecurrenceID,RecurrenceDayID,RecurrenceMonthID,RepeatsMonthly,RepeatsMonthWeekDayNumber,RepeatsMonthWeekDay,LocationOther,LocationText,WebsiteURL,VehicleYear,MakeID,Make,Model,MakeOther,ModelOther,Kilometers,FourWheelDrive,TransmissionID,Rent,RentUS,RentTZS,TermID,Bedrooms,Bathrooms,AmenityID,AmenityOther,Amenities,Deadline,LongDescr,Instructions,UploadedDoc,EventStartDate,EventEndDate,EventStartTime,EventEndTime,SquareFeet,SquareMeters,ContactFirstName,ContactLastName,ContactEmail,ContactPhone,ContactSecondPhone,AltContactFirstName,AltContactLastName,AltContactEmail,AltContactPhone,AltContactSecondPhone,ContactEmail,InProgressCompanyName,InProgressPassword,#ListingImagesVariables#,InProgress,ExpirationDate,SaveListing,Previous,SaveForLater,Next,FT,DT,AgreedCodeOfConductID,ProcessELPDocs,MovieFees">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="ParentSectionID,ListingSectionID,ListingTypeID,ListingID,Price,PriceUS,PriceTZS,Rent,RentUS,RentTZS,TermID,Bedrooms,Bathrooms,RecurrenceID,VehicleYear,MakeID,FourWheelDrive,TransmissionID,RentUS,RentTZS,TermID,Bedrooms,Bathrooms,SquareFeet,SquareMeters,InProgress,AgreedCodeOfConductID">

<cfif IsDefined('session.UserID') and Len(session.UserID)>
<!--- See if Trip or J&E Prof Empl Opps Listings allowed --->
	<cfinclude template="MyListings.cfm">
<cfelse>
	<cfset AllowTravel="0">
	<cfset AllowJAndEProfEmplOpp="0">
</cfif>

<cfparam name="allowListing" default="1">

<cfset ListingID="">

<cfif Len(LinkID)>
	<cfinclude template="FindListing.cfm">
	<cfset ListingID=getListing.ListingID>
	<cfset ListingTypeID=getListing.ListingTypeID>
	<cfset ListingType=getListing.ListingType>
	<cfset ExpirationDate=getListing.ExpirationDate>
	<cfset ListingSectionID=getListing.ListingSectionID>
<cfelse><!--- Get Listing Type Descr for use in content title --->
	<cfquery name="getListingType" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select Descr as ListingType
		From ListingTypes
		Where ListingTypeID=<cfqueryparam value="#ListingTypeID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfset ListingType=getListingType.ListingType>
</cfif>

<cfquery name="getUserInfo" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select U.UserID, UCC.CodeOfConductID
	From LH_Users U
	Left Outer Join UserCodeOfConduct UCC on U.UserID=UCC.UserID
	Where U.UserID = <cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfif Len(AgreedCodeOfConductID) and not ListFind(ValueList(getUserInfo.CodeOfConductID),AgreedCodeOfConductID)>
	<cfquery name="getUserInfo" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Insert into UserCodeOfConduct
		(UserID, CodeOfConductID,AgreedDate)
		VALUES
		(<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">,
		<cfqueryparam value="#AgreedCodeOfConductID#" cfsqltype="CF_SQL_INTEGER">,
		<cfqueryparam cfsqltype="cf_sql_date" value="#application.CurrentDateInTZ#">)
	</cfquery>
	<cfquery name="getUserInfo" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select U.UserID, UCC.CodeOfConductID
		From LH_Users U
		Left Outer Join UserCodeOfConduct UCC on U.UserID=UCC.UserID
		Where U.UserID = <cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
</cfif>

<cfif Len(ParentSectionID) and Len(UpdateSAndC)><!--- Submission from previous form --->
	<cfif not AllowListing>
		<cflocation url="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#TT=0" addToken="No">
		<cfabort>
	</cfif>
	<cfif Len(ListingID)>
		<cfquery name="updateParentSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update ListingParentSections
			Set ParentSectionID=<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">
			Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<!--- Delete and re-add section, since section may or may not have existed before and may or may not be being added here. (Parent Section will always exist, so simple update is fine for it.) --->
		<cfquery name="deleteSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Delete From ListingSections
			Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfif Len(ListingSectionID)>
			<cfquery name="updateParentSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Insert into ListingSections
				(SectionID,ListingID)
				VALUES
				(<cfqueryparam value="#ListingSectionID#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">)
			</cfquery>
		</cfif>
		<!--- Delete Categories and Add back selected ones --->
		<cfquery name="deleteCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Delete From ListingCategories
			Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfloop list="#CategoryID#" index="i">
			<cfquery name="addCategory" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Insert into ListingCategories
				(CategoryID, ListingID)
				VALUES
				(<cfqueryparam value="#i#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">)
			</cfquery>	
		</cfloop>	
		<cfquery name="updateListingType" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update Listings
			Set ListingTypeID=<cfqueryparam value="#ListingTypeID#" cfsqltype="CF_SQL_INTEGER">
			Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfinclude template="ListingTitlesUpdater.cfm">
	</cfif>
</cfif>


<cfif Len(FT)>
	<div id="internalalert"><cfoutput>The uploaded file has the extension of "#FT#" which is not allowed.<br>
	File extensions that are allowed are: gif, jpg, jpeg and png.</cfoutput></div><br clear="all">		
<cfelseif Len(DT)>
	<div id="internalalert"><cfoutput>The uploaded file has the extension of "#DT#" which is not allowed.<br>
	File extensions that are allowed are: doc, docx, pdf and txt.</cfoutput></div><br clear="all">		
</cfif>

<cfif IsDefined('session.UserID') and session.UserID is request.PhoneOnlyUserID>	
	<p class="Important">Phone Only Listings Account in use.</p>
</cfif>

<cfset PhoneOnlyEntry="0">
<cfif IsDefined('session.UserID') and Len(session.UserID) and session.UserID is Request.PhoneOnlyUserID>
	<cfset PhoneOnlyEntry="1">
</cfif>

<cfif PhoneOnlyEntry and not ListFind("1,2,14",ListingTypeID)>	
	<p class="Important">This  Account can only be used to add Phone Only Listings for Business 1, Business 2 and Community listing types.</p>
	</div>
	<!-- END CENTER COL -->
	<cfinclude template="../templates/footer.cfm">
	<cfabort>
</cfif>

<cfswitch expression="#ListingTypeID#">
	<cfcase value="1"><!--- General Business Listing --->
		<cfif ListFind(Request.PriceRangeCategoryIDs,CategoryID) or ListFind(Request.ParkCategoryIDs,CategoryID)>
			<cfif ListFind(Request.PriceRangeCategoryIDs,CategoryID) and ListFind(Request.ParkCategoryIDs,CategoryID)>
				<cfset FieldsForForm="ListingFee,ListingTitle,PublicPhoneAndEmail,ShortDescr,PriceRangeID,ParkID,LocationID,LocationText,WebsiteURL,Contact,InProgressPassword">	
			<cfelseif ListFind(Request.PriceRangeCategoryIDs,CategoryID)>					
				<cfset FieldsForForm="ListingFee,ListingTitle,PublicPhoneAndEmail,ShortDescr,PriceRangeID,LocationID,LocationText,WebsiteURL,Contact,InProgressPassword">	
			<cfelse>
				<cfset FieldsForForm="ListingFee,ListingTitle,PublicPhoneAndEmail,ShortDescr,ParkID,LocationID,LocationText,WebsiteURL,Contact,InProgressPassword">	
			</cfif>	
		<cfelse>
			<cfset FieldsForForm="ListingFee,ListingTitle,PublicPhoneAndEmail,ShortDescr,LocationID,LocationText,WebsiteURL,Contact,InProgressPassword">		
		</cfif>			
	</cfcase>	
	<cfcase value="2"><!--- Restaurant Business Listing --->
		<cfset FieldsForForm="ListingFee,ListingTitle,CuisineID,PublicPhoneAndEmail,ShortDescr,LocationID,LocationText,WebsiteURL,Contact,InProgressPassword">
	</cfcase>
	<cfcase value="3"><!--- General For Sale by Owner --->
		<cfset FieldsForForm="ListingFee,ListingTitle,Price,PublicPhoneAndEmail,ShortDescr,LocationID,ListingImages,ContactEmail">
	</cfcase>
	<cfcase value="4"><!--- For Sale by Owner - Cars & Trucks --->
		<cfset FieldsForForm="ListingFee,VehicleYear,MakeID,Model,Kilometers,FourWheelDrive,TransmissionID,Price,PublicPhoneAndEmail,ShortDescr,LocationID,ListingImages,ContactEmail">	
	</cfcase>
	<cfcase value="5"><!--- FSBO Motorcycles, Mopeds, ATVs, & Vibajaji & FSBO Commercial Trucks --->
		<cfset FieldsForForm="ListingFee,VehicleYear,Make,Model,Kilometers,ShortDescr,Price,PublicPhoneAndEmail,LocationID,ListingImages,ContactEmail">	
	</cfcase>
	<cfcase value="6"><!--- Housing & Real Estate Housing Rentals --->
		<cfset FieldsForForm="ListingFee,ListingTitle,ShortDescr,Rent,TermID,Bedrooms,Bathrooms,AmenityID,LocationID,LocationText,PublicPhoneAndEmail,ListingImages,ContactEmail">	
	</cfcase>
	<cfcase value="7"><!--- Housing & Real Estate Commercial Rentals --->
		<cfset FieldsForForm="ListingFee,ListingTitle,ShortDescr,Rent,TermID,Square,LocationID,LocationText,PublicPhoneAndEmail,ListingImages,ContactEmail">	
	</cfcase>
	<cfcase value="8"><!--- Housing & Real Estate For Sale --->
		<cfif ListFind("89",CategoryID)>
			<cfset FieldsForForm="ListingFee,ListingTitle,ShortDescr,Price,Bedrooms,Bathrooms,AmenityID,LocationID,LocationText,PublicPhoneAndEmail,ListingImages,ContactEmail">		
		<cfelse>
			<cfset FieldsForForm="ListingFee,ListingTitle,ShortDescr,Price,LocationID,LocationText,PublicPhoneAndEmail,ListingImages,ContactEmail">		
		</cfif>			
	</cfcase>
	<cfcase value="9"><!--- Travel & Tourism (Trip Listings) --->
		<cfset FieldsForForm="ListingFee,ListingTitle,Price,Deadline,ShortDescr,PublicPhoneAndEmail">	
	</cfcase>
	<cfcase value="10"><!--- Jobs & Employment Professional (employment opportunities) --->
		<cfset FieldsForForm="ListingFee,ListingTitle,ListingCategories,WebsiteURL,LocationID,ShortDescrText,Deadline,StartDate,LongDescr,UploadedDoc,Instructions,PublicPhoneAndEmail,ContactEmail">	
	</cfcase>
	<cfcase value="11"><!--- Jobs & Employment Professional (seeking employment) --->
		<cfset FieldsForForm="ListingFee,ListingTitle,ShortDescr,LongDescr,UploadedDoc,PublicPhoneAndEmail,ContactEmail">	
	</cfcase>
	<cfcase value="12"><!--- Jobs & Employment Domestic Staff (employment opportunities) --->
		<cfset FieldsForForm="ListingFee,ShortDescrText,ListingCategories,LongDescr,LocationID,Deadline,PublicPhoneAndEmail,ContactEmail">	
	</cfcase>
	<cfcase value="13"><!--- Jobs & Employment Domestic Staff (seeking employment) --->
		<cfset FieldsForForm="ListingFee,ListingTitle,ShortDescr,LongDescr,PublicPhoneAndEmail,ContactEmail">	
	</cfcase>
	<cfcase value="14"><!--- Community --->
		<cfif ListFind("157",CategoryID)><!--- NGOs --->
			<cfset FieldsForForm="ListingFee,ListingTitle,PublicPhoneAndEmail,NGOTypeID,ShortDescr,LocationID,LocationText,WebsiteURL,Contact,InProgressPassword">		
		<cfelse>
			<cfset FieldsForForm="ListingFee,ListingTitle,PublicPhoneAndEmail,ShortDescr,LocationID,LocationText,WebsiteURL,Contact,InProgressPassword">
		</cfif>				
	</cfcase>
	<cfcase value="15"><!--- Events --->
		<cfset FieldsForForm="ListingFee,ListingTitle,EventDates,EventTimes,Recurrences,PublicPhoneAndEmail,LocationID,LocationText,WebsiteURL,ShortDescr,ContactEmail">	
	</cfcase>
	<cfcase value="20"><!--- Movie Theaters --->
		<cfset FieldsForForm="ListingFee,ListingTitle,PublicPhoneAndEmail,Movies,MovieFees,ShortDescr,LocationID,LocationText,WebsiteURL,Contact,InProgressPassword">
	</cfcase>
</cfswitch>



<cfif Len(SaveListing)>
	<cfif Len(Previous)>
		<cflocation url="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=1&LinkID=#LinkID#" AddToken="No">
		<cfabort>
	</cfif>
	
	<cfif not Len(ListingID)>
		<cfquery name="addListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Insert into Listings
			(LinkID,InProgress,DateListed,ListingTypeID,InProgressUserID)
			VALUES
			('#CreateUUID()#',
			1,
			GetDate(),
			<cfqueryparam value="#ListingTypeID#" cfsqltype="CF_SQL_INTEGER">,
			<cfif IsDefined('session.UserID') and Len(session.UserID)><cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER"><cfelse>null</cfif>)
			
			Select Max(ListingID) as NewListingID
			From Listings
		</cfquery>
		<cfset ListingID=addListing.NewListingID>
		
		<cfquery name="getLinkID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select LinkID
			From Listings
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset LinkID=getLinkID.LinkID>
		<cfquery name="addParentSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Insert into ListingParentSections
			(ParentSectionID, ListingID)
			VALUES
			(<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">,
			<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">)
		</cfquery>
		<cfif Len(ListingSectionID)>		
			<cfquery name="addSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Insert into ListingSections
				(SectionID, ListingID)
				VALUES
				(<cfqueryparam value="#ListingSectionID#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">)
			</cfquery>
		</cfif>
		<cfloop list="#CategoryID#" index="i">
			<cfquery name="addCategory" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Insert into ListingCategories
				(CategoryID, ListingID)
				VALUES
				(<cfqueryparam value="#i#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">)
			</cfquery>	
		</cfloop>	
	<cfelse>
		<!--- Update Sort Date on any edit, but only if the sort date already exists. --->
		<cfquery name="updateDateSort" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update Listings
			Set DateSort=getDate()
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			and DateSort is not null
		</cfquery>
		<cfif ListingTypeID EQ 15>
			<cfinclude template="ListingEventDays.cfm">	
		</cfif>
	</cfif>	
	
	<cfif Len(ProcessELPDocs)>
		<cfset ELPOnStepTwo = "1">
		<cfinclude template="ProcessELPDocs.cfm">
	</cfif>
	
	<!--- Process UploadedDoc last, despite its order in the list, so if there is an upload file type error, the rest of the fields have already been proceesed before redirecting back with the file type status message. --->
	<cfloop list="#FieldsForForm#" index="i">
		<cfif i neq "UploadedDoc">
			<cfmodule template="FormField#i#.cfm" Action="Process">
		</cfif>
	</cfloop>
	<cfif ListFind(FieldsForForm,"UploadedDoc")>
		<cfmodule template="FormFieldUploadedDoc.cfm" Action="Process">
	</cfif>

	<cfinclude template="ListingTitlesUpdater.cfm">

	<cfif Len(SaveForLater)>
		<cflocation URL="Page.cfm?PageID=5&Step=5&LinkID=#LinkID#" addToken="No">
	<cfelse>
		<cflocation URL="#Request.HTTPSUrl#/Page.cfm?PageID=5&Step=3&LinkID=#LinkID#" addToken="No">
	</cfif>
	<cfabort>
</cfif>

<cfif Len(ListingID)>
	<cfset ListingFee=getListing.ListingFee>
	<cfset ListingTitle=getListing.ListingTitle>
	<cfset PriceUS=getListing.PriceUS>
	<cfset PriceTZS=getListing.PriceTZS>
	<cfset PublicPhone=getListing.PublicPhone>
	<cfset PublicPhone2=getListing.PublicPhone2>
	<cfset PublicPhone3=getListing.PublicPhone3>
	<cfset PublicPhone4=getListing.PublicPhone4>
	<cfset PublicEmail=getListing.PublicEmail>
	<cfset ShortDescr=getListing.ShortDescr>
	<cfset LocationOther=getListing.LocationOther>
	<cfset ParkOther=getListing.ParkOther>
	<cfset LocationText=getListing.LocationText>
	<cfset WebsiteURL=getListing.WebsiteURL>
	<cfset ContactFirstName=getListing.ContactFirstName>
	<cfset ContactLastName=getListing.ContactLastName>
	<cfset ContactEmail=getListing.ContactEmail>
	<cfset ContactPhone=getListing.ContactPhone>
	<cfset ContactSecondPhone=getListing.ContactSecondPhone>
	<cfset AltContactFirstName=getListing.AltContactFirstName>
	<cfset AltContactLastName=getListing.AltContactLastName>
	<cfset AltContactEmail=getListing.AltContactEmail>
	<cfset AltContactPhone=getListing.AltContactPhone>
	<cfset AltContactSecondPhone=getListing.AltContactSecondPhone>
	<cfset VehicleYear=getListing.VehicleYear>
	<cfset MakeID=getListing.MakeID>
	<cfset Make=getListing.MakeOther>
	<cfset MakeOther=getListing.MakeOther>
	<cfset Model=getListing.ModelOther>
	<cfset Kilometers=getListing.Kilometers>
	<cfset FourWheelDrive=getListing.FourWheelDrive>	
	<cfset TransmissionID=getListing.TransmissionID>
	<cfset RentUS=getListing.RentUS>
	<cfset RentTZS=getListing.RentTZS>
	<cfset SquareFeet=getListing.SquareFeet>
	<cfset SquareMeters=getListing.SquareMeters>
	<cfset TermID=getListing.TermID>
	<cfset Bedrooms=getListing.Bedrooms>
	<cfset Bathrooms=getListing.Bathrooms>
	<cfset AmenityOther=getListing.AmenityOther>
	<cfset Deadline=getListing.Deadline>
	<cfset Instructions=getListing.Instructions>
	<cfset LongDescr=getListing.LongDescr>
	<cfset UploadedDoc=getListing.UploadedDoc>
	<cfset EventStartDate=getListing.EventStartDate>
	<cfset EventEndDate=getListing.EventEndDate>
	<cfset EventStartTime=TimeFormat(getListing.EventStartDate,"h:mm tt")>
	<cfset EventEndTime=TimeFormat(getListing.EventEndDate,"h:mm tt")>
	<cfset RecurrenceID=getListing.RecurrenceID>
	<cfset RecurrenceDayID=ValueList(getRecurrenceDays.RecurrenceDayID)>
	<cfset RecurrenceMonthID=getListing.RecurrenceMonthID>
	<cfset InProgress=getListing.InProgress>
	<cfset InProgressPassword=getListing.InProgressPassword>
	<cfset InProgressCompanyName=getListing.InProgressCompanyName>
	<cfset ParentSectionID=getListing.ParentSectionID>
	<cfset MovieFees=getListing.MovieFees>
	<cfquery name="getListingCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select CategoryID
		From ListingCategories
		Where ListingID=<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfset CategoryID=ValueList(getListingCategories.CategoryID)>
	<cfquery name="getListingCuisines" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select CuisineID
		From ListingCuisines
		Where ListingID=<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfset CuisineID=ValueList(getListingCuisines.CuisineID)>
	<cfset CuisineOther=getListing.CuisineOther>
	<cfquery name="getListingPriceRanges" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select PriceRangeID
		From ListingPriceRanges
		Where ListingID=<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfset PriceRangeID=ValueList(getListingPriceRanges.PriceRangeID)>
	<cfquery name="getListingNGOTypes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select NGOTypeID
		From ListingNGOTypes
		Where ListingID=<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfset NGOTypeID=ValueList(getListingNGOTypes.NGOTypeID)>
	<cfset NGOTypeOther=getListing.NGOTypeOther>
	<cfquery name="getListingAmenities" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select AmenityID
		From ListingAmenities
		Where ListingID=<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfset AmenityID=ValueList(getListingAmenities.AmenityID)>
	<cfset AmenityOther=getListing.AmenityOther>
	<cfquery name="getListingImages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select ListingImageID, FileName
		From ListingImages
		Where ListingID=<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
		Order By OrderNum, ListingID
	</cfquery>
	<cfif getListingImages.RecordCount>
		<cfoutput query="getListingImages">
			<cfset "ListingImageID#CurrentRow#"=ListingImageID>
			<cfset "ListingImageFileName#CurrentRow#"=FileName>
		</cfoutput>		
	</cfif>

<!--- If user is logged in, pre-fill any blank fields with account information --->
<cfelseif IsDefined('session.UserID') and Len(session.UserID)>
	<cfquery name="getAccountInfo" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select ContactFirstName, ContactLastName, ContactPhoneLand, ContactPhoneMobile, ContactEmail, 
		AltContactFirstName, AltContactLastName, AltContactPhoneLand, AltContactPhoneMobile, AltContactEmail,
		Website
		From LH_Users
		Where UserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif not Len(ContactFirstName)>
		<cfset ContactFirstName=getAccountInfo.ContactFirstName>
	</cfif>
	<cfif not Len(ContactLastName)>
		<cfset ContactLastName=getAccountInfo.ContactLastName>
	</cfif>
	<cfif not Len(ContactPhone)>
		<cfset ContactPhone=getAccountInfo.ContactPhoneLand>
	</cfif>
	<cfif not Len(ContactSecondPhone)>
		<cfset ContactSecondPhone=getAccountInfo.ContactPhoneMobile>
	</cfif>
	<cfif not Len(ContactEmail)>
		<cfset ContactEmail=getAccountInfo.ContactEmail>
	</cfif>
	<cfif not Len(AltContactFirstName)>
		<cfset AltContactFirstName=getAccountInfo.AltContactFirstName>
	</cfif>
	<cfif not Len(AltContactLastName)>
		<cfset AltContactLastName=getAccountInfo.AltContactLastName>
	</cfif>
	<cfif not Len(AltContactPhone)>
		<cfset AltContactPhone=getAccountInfo.AltContactPhoneLand>
	</cfif>
	<cfif not Len(AltContactSecondPhone)>
		<cfset AltContactSecondPhone=getAccountInfo.AltContactPhoneMobile>
	</cfif>
	<cfif not Len(AltContactEmail)>
		<cfset AltContactEmail=getAccountInfo.AltContactEmail>
	</cfif>
	<!--- If Listings is HR or FSBO2/3 listing, pre-fill public fields based on best match from account's Business Listings, if they have HR4 or FSBO4 status --->
	<cfif ListFind("4,5,6,7,8",ListingTypeID)>
		<cfset AcctUserID=session.UserID>
		<cfinclude template="AcctQualified.cfm">	
		<cfswitch expression="#ListingTypeID#">
			<cfcase value="4,5">
				<cfif FSBO4Qualified>
					<!--- Find best Business Listing for Car Dealer --->
					<cfquery name="getBestBusinessListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						SELECT Top 1 L.ListingID, L.PublicPhone, L.PublicPhone2, L.PublicPhone3, L.PublicPhone4, L.PublicEmail, L.WebsiteURL
                        FROM ListingsView L 
						LEFT OUTER JOIN Orders O ON L.OrderID = O.OrderID
						INNER JOIN ListingParentSections LPS ON L.ListingID = LPS.ListingID
						LEFT OUTER JOIN ListingSections LS ON L.ListingID = LS.ListingID
                        WHERE L.DeletedAfterSubmitted = 0AND LS.SectionID = 28 AND L.ListingTypeID = 1
						AND O.UserID = <cfqueryparam value="#AcctUserID#" cfsqltype="CF_SQL_INTEGER"> 
						Order By O.PaymentStatusID desc, L.Reviewed desc, L.ExpirationDate
					</cfquery>
					<cfif not Len(PublicPhone)>
						<cfset PublicPhone=getBestBusinessListing.PublicPhone>
					</cfif>
					<cfif not Len(PublicPhone2)>
						<cfset PublicPhone2=getBestBusinessListing.PublicPhone2>
					</cfif>
					<cfif not Len(PublicPhone3)>
						<cfset PublicPhone3=getBestBusinessListing.PublicPhone3>
					</cfif>
					<cfif not Len(PublicPhone4)>
						<cfset PublicPhone4=getBestBusinessListing.PublicPhone4>
					</cfif>
					<cfif not Len(PublicEmail)>
						<cfset PublicEmail=getBestBusinessListing.PublicEmail>
					</cfif>
					<cfif not Len(WebsiteURL)>
						<cfset WebsiteURL=getBestBusinessListing.WebsiteURL>
					</cfif>
				</cfif>
			</cfcase>
			<cfcase value="6,7,8">
				<cfif HR4Qualified>
					<!--- Find Business Listing for Real Estate --->
					<cfquery name="getBestBusinessListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						SELECT Top 1 L.ListingID, L.PublicPhone, L.PublicPhone2, L.PublicPhone3, L.PublicPhone4, L.PublicEmail, L.WebsiteURL
                        FROM ListingsView L 
						LEFT OUTER JOIN Orders O ON L.OrderID = O.OrderID
						INNER JOIN ListingParentSections LPS ON L.ListingID = LPS.ListingID
						LEFT OUTER JOIN ListingSections LS ON L.ListingID = LS.ListingID
                        WHERE L.DeletedAfterSubmitted = 0 AND LPS.ParentSectionID = 5 AND L.ListingTypeID = 1
						AND O.UserID = <cfqueryparam value="#AcctUserID#" cfsqltype="CF_SQL_INTEGER"> 
						Order By O.PaymentStatusID desc, L.Reviewed desc, L.ExpirationDate
					</cfquery>
					<cfif not Len(PublicPhone)>
						<cfset PublicPhone=getBestBusinessListing.PublicPhone>
					</cfif>
					<cfif not Len(PublicPhone2)>
						<cfset PublicPhone2=getBestBusinessListing.PublicPhone2>
					</cfif>
					<cfif not Len(PublicPhone3)>
						<cfset PublicPhone3=getBestBusinessListing.PublicPhone3>
					</cfif>
					<cfif not Len(PublicPhone4)>
						<cfset PublicPhone4=getBestBusinessListing.PublicPhone4>
					</cfif>
					<cfif not Len(PublicEmail)>
						<cfset PublicEmail=getBestBusinessListing.PublicEmail>
					</cfif>
					<cfif not Len(WebsiteURL)>
						<cfset WebsiteURL=getBestBusinessListing.WebsiteURL>
					</cfif>
				</cfif>
			</cfcase>
		</cfswitch>
	</cfif>
</cfif>

<script>
	<cfoutput>$("##PostAListingTypeSpan").html(' #ListingType#');</cfoutput>
	function validateForm(formObj) {		
		<cfloop list="#FieldsForForm#" index="i">
			<cfmodule template="FormField#i#.cfm" Action="Validate">
		</cfloop>
		<cfif ListingTypeID is "15" or ListingSectionID is "37">
			<cfset ELPOnStepTwo = "1">
			<cfinclude template="ELPJSValidationIncludes.cfm">
		</cfif>
		<cfif ListFind("10,11",ListingTypeID)>		
			<cfif ListingTypeID is "11">
				CKEDITOR.instances.LongDescr.updateElement();
			</cfif>	
			if ($("#LongDescr").val()=='' && $("#UploadedDoc").val()=='' && $("#ExistingUploadedDoc").val()=='') {
				alert('You must complete the <cfif ListingTypeID is "10"><cfif CategoryID is "289">Tender<cfelse>Position</cfif> Description field or upload a <cfif CategoryID is "289">Tender<cfelse>Position</cfif> Description<cfelse>Resume/CV field or upload a Position Resume/CV</cfif> document.');
				return false;
			}
		</cfif>
		return true;
	}
</script>

<script>
	var CKEDITOR_BASEPATH='ckeditor/';
	<cfif ListingTypeID is "15" or ListingSectionID is "37">		
		<cfinclude template="ELPJSIncludes.cfm">
	</cfif>
</script>
<script type="text/javascript" src="ckeditor/ckeditor.js"></script>



<cfoutput>
<cfif ListingSectionID is "37" and not AllowTravel>
	<strong>You must have a business account and listing in the Travel & Tourism section to post Special Travel Offers.To submit your business listing, <a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=1&ParentSectionID=21&ListingSectionID=36">click here</a>.</strong>
<!--- <cfelseif ListingTypeID is "10" and not AllowJAndEProfEmplOpp>
	<strong>You must have a business account and listing to post professional job opportunities.  If you already have a business account, please login by clicking on the My Acount link at the bottom of the page.  To submit your business listing, <a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=1&ParentSectionID=1">click here</a>.</strong> --->
<cfelse>
	<!--- Check to see if user has appropriate Code of Conduct agreement on record. --->
	<cfswitch expression="#ListingTypeID#">
		<cfcase value="1,2,14,20"><!--- Business and Community Listings --->
			<cfset RequiredCodeOfConductID = 7>
		</cfcase>
		<cfcase value="3,4,5,6,7,8"><!--- Classifieds and Real Estate --->
			<cfset RequiredCodeOfConductID = 4>
		</cfcase>
		<cfcase value="10,12"><!--- Job Opps --->
			<cfset RequiredCodeOfConductID = 2>
		</cfcase>
		<cfcase value="15"><!--- Events --->
			<cfset RequiredCodeOfConductID = 1>
		</cfcase>
		<cfcase value="11,13"><!--- Job Seekers --->
			<cfset RequiredCodeOfConductID = 5>
		</cfcase>
		<cfcase value="9"><!--- Travel Specials --->
			<cfset RequiredCodeOfConductID = 6>
		</cfcase>
		<cfdefaultcase>
			<cfset RequiredCodeOfConductID = 4>			
		</cfdefaultcase>
	</cfswitch>
	<cfif not ListFind(ValueList(getUserInfo.CodeOfConductID),RequiredCodeOfConductID)>
		<cfinclude template="CodeOfConductForm.cfm">
	<cfelse>
		<lh:MS_SitePagePart id="bodyTwo" class="body">
		<p>&nbsp;</p>
		<form name="f1" action="page.cfm?PageID=#Request.AddAListingPageID#" method="post" ENCTYPE="multipart/form-data" ONSUBMIT="return validateForm(this)">
			<table border="0" cellspacing="0" cellpadding="0" class="datatable">
				<cfloop list="#FieldsForForm#" index="i">					
					<cfif i is "ContactEmail" and ListingTypeID is "15">
						<tr>
							<td colspan="2">
								<div id="ExpandedListingDiv">
			
								</div>
							</td>
						</tr>
					</cfif>
					<cfmodule template="FormField#i#.cfm" Action="Form">
					<cfif i is "PublicPhoneAndEmail" and ListingSectionID is "37">
						<tr>
							<td colspan="2">
								<div id="ExpandedListingDiv">
			
								</div>
							</td>
						</tr>
					</cfif>
				</cfloop>
				<tr>
					<td>&nbsp;</td>
					<td>
						&nbsp;<br>
						<input type="button" name="Previous" value="<< Previous" onClick="return confirm('Warning. Changes made on this page will be lost.');location.href='#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=1&LinkID=#LinkID#'" class="btn" >
						<input type="submit" name="SaveForLater" value="Save for Later" class="btn">
						<input type="submit" name="Next" value="Next >>" class="btn">
						<cfif Len(LinkID)>
							<cfinclude template="DeleteThisListing.cfm">
						</cfif>
						<input type="hidden" name="LinkID" value="#LinkID#">
						<input type="hidden" name="ParentSectionID" value="#ParentSectionID#">
						<input type="hidden" name="ListingSectionID" value="#ListingSectionID#">
						<input type="hidden" name="ListingTypeID" value="#ListingTypeID#">
						<input type="hidden" name="CategoryID" value="#CategoryID#">
						<input type="hidden" name="SaveListing" value="1">
						<input type="hidden" name="Step" value="2">
					</td>
				</tr>
			</table>
		</form>
	</cfif>
</cfif>
</cfoutput>

<cfoutput>
<script>
	$(document).ready(function()
	{	
		<cfif ListFind("15",ListingTypeID)>
			<cfif recurrenceID NEQ 1 AND recurrenceID NEQ 2> 
				document.getElementById('RecurrenceDayID_TR').style.display = 'none';
			</cfif>
			<cfif recurrenceID NEQ 3> 
				document.getElementById('RecurrenceMonthID_TR').style.display = 'none';	
			</cfif>				   
		</cfif>
		<cfif ListFind(FieldsForForm,"LocationID")>
			showLocationOther();	
		</cfif>
		<cfif ListFind(FieldsForForm,"ParkID")>
			showParkOther();	
		</cfif>
		<cfif ListFind(FieldsForForm,"CuisineID")>
			showCuisineOther();	
		</cfif> 
		<cfif ListFind(FieldsForForm,"NGOTypeID")>
			showNGOTypeOther();	
		</cfif>  
		<cfif ListFind(FieldsForForm,"AmenityID")>
			showAmenityOther();	
		</cfif>  		  
		getFee();  
		$("##Price").change(getFee);
		$("##PriceType").change(getFee); 	
		$("##Rent").change(getFee);
		$("##RentType").change(getFee); 	
		<cfif ListFind("1,2,14",ListingTypeID) and (not Len(InProgress) or InProgress)>
			$("##ContactEmail").change(handleEmailAsUsername); 	
		</cfif>
		<cfif ListFind("1,2,14",ListingTypeID)>
			$("##ListingTitle").change(checkListingTitleIsUnique); 
		</cfif>
		<cfif ListFind("10,11",ListingTypeID)>
			$("##UploadedDoc").change(checkPositionDescrField); 
		</cfif>
		<cfif ListFind("10,11",ListingTypeID)>
			$("##LongDescr").keyup(checkPositionDescrDoc); 
			$("##LongDescr").change(checkPositionDescrDoc); 
		</cfif>
				
		<cfif ListFind("4",ListingTypeID)>
		makeIDList=document.f1.MakeID.value;		
		
		if (makeIDList == 1)
			$("##MakeOther_TR").show();
				
			
		$("##MakeID").change(function(e)
	    {	
			makeIDList='';			
			
			//alert(document.f1.ParentSectionID.value);	
			makeIDList=document.f1.MakeID.value;
			
			if (makeIDList == 1){
			$("##MakeOther_TR").show();
			$("##ModelOther_TR").show();
			}
			else{
			$("##MakeOther_TR").hide();
			}
												       
	    });    
	    
		</cfif>
		
		$("##LocationID").change(function(e)
	    {	
			showLocationOther();					       
	    });
		
		$("##ParkID").change(function(e)
	    {	
			showParkOther();					       
	    });
		
		$("##CuisineID").change(function(e)
	    {	
			showCuisineOther();					       
	    });
		
		$("##NGOTypeID").change(function(e)
	    {	
			showNGOTypeOther();					       
	    });
		
		$("##AmenityID").change(function(e)
	    {	
			showAmenityOther();					       
	    });
		
	    $("##RecurrenceID").change(function(e)
	    {	
			if(document.f1.RecurrenceID.value == 1 || document.f1.RecurrenceID.value == 2)	
			document.getElementById('RecurrenceDayID_TR').style.display = '';
			else
			document.getElementById('RecurrenceDayID_TR').style.display = 'none';
			
			if(document.f1.RecurrenceID.value == 3)	
			document.getElementById('RecurrenceMonthID_TR').style.display = '';
			else
			document.getElementById('RecurrenceMonthID_TR').style.display = 'none';											       
	    });
		
	});
	
	function showLocationOther() {
		var showLocationOtherField=0;
		$('##LocationID :selected').each(function(i, selected){
			if ($(selected).val()==4) {
				showLocationOtherField=1;
			}
		});
		if (showLocationOtherField==1) {
			$("##LocationOther_TR").show();
		}
		else {
			$("##LocationOther").val('');
			$("##LocationOther_TR").hide();
		}
	}
	
	function showParkOther() {
		var showParkOtherField=0;
		$('##ParkID :selected').each(function(i, selected){
			if ($(selected).val()==1) {
				showParkOtherField=1;
			}
		});
		if (showParkOtherField==1) {
			$("##ParkOther_TR").show();
		}
		else {
			$("##ParkOther").val('');
			$("##ParkOther_TR").hide();
		}
	}
	
	function showCuisineOther() {
	 	if ($("##CuisineID option[value='4']").attr('selected')==1) {
			$("##CuisineOther_TR").show();
		}
		else {
			$("##CuisineOther").val('');
			$("##CuisineOther_TR").hide();
		}
	}
	function showNGOTypeOther() {
	 	if ($("##NGOTypeID option[value='1']").attr('selected')==1) {
			$("##NGOTypeOther_TR").show();
		}
		else {
			$("##NGOTypeOther").val('');
			$("##NGOTypeOther_TR").hide();
		}
	}
	
	function showAmenityOther() {
	 	if ($("##AmenityID option[value='1']").attr('selected')==1) {
			$("##AmenityOther_TR").show();
		}
		else {
			$("##AmenityOther").val('');
			$("##AmenityOther_TR").hide();
		}
	}
			
	function getFee() {
		if ($("##Price")[0]) {
			var strippedPrice=$("##Price").val().replace(/,/g,'');
			strippedPrice=strippedPrice.replace('$','');
			$("##Price").val(strippedPrice);
			if (!checkNumber(document.f1.elements["Price"],"<cfif ListFind("9",ListingTypeID)>Minimum </cfif>Price")) return false;
		}
		if ($("##Rent")[0]) {
			var strippedRent=$("##Rent").val().replace(/,/g,'');
			strippedRent=strippedRent.replace('$','');
			$("##Rent").val(strippedRent);
			if (!checkNumber(document.f1.elements["Rent"],"Rent")) return false;
		}
	 	var datastring = "ListingTypeID=#ListingTypeID#<cfif ListFind("3,4,5",ListingTypeID)>&Price="+$("##Price").val()+"&PriceType="+$("##PriceType").val()+"<cfelseif ListFind("6,7,8",ListingTypeID)>&Price="+$("##Rent").val()+"&PriceType="+$("##RentType").val()+"</cfif><cfif Len(LinkID)>&LinkID=#LinkID#</cfif><cfif isDefined("session.userID")>&userID=#session.userID#"</cfif>;
		$.ajax(
           {
			type:"POST",	
			dataType: 'json',				
               url:"#Request.HTTPURL#/includes/GetListingFee.cfc?method=GetFee&returnformat=plain",
               data:datastring,
               success: function(responseVars)
               {
				if (responseVars.ListingFee=='Free') {
					$("##ListingFeeSpan").html('FREE');		
					$("##ListingFee").val('0');	
				}
				else if (responseVars.ListingFee==''){
					$("##ListingFeeSpan").html('PRICE VARIES');
					$("##ListingFee").val(responseVars.ListingFee);
				}
				else {
					$("##ListingFeeSpan").html('$' + parseFloat(responseVars.ListingFee).toFixed(2));
					$("##ListingFee").val(responseVars.ListingFee);
				}			                
				if (responseVars.HasOpenHAndRPackages==1){
					$("##ApplyHAndRPackageDiv").html('H&R Package Credit may be<br />applied toward this fee.');
				}
				if (responseVars.HasOpenVPackages==1){
					$("##ApplyVPackageDiv").html('Vehicle Package Credit may be<br />applied toward this fee.');
				}
				if (responseVars.HasOpenJRPackages==1){
					$("##ApplyJRPackageDiv").html('Recruitment Package Credit may be<br />applied toward this fee.');
				}
				
               }
           }); 
	}
	
	function handleEmailAsUsername() {
		<cfif not IsDefined('session.UserID') or not Len(session.UserID)><!--- Skip completely if logged in. --->
		$("##UsernameDisplay").html(document.f1.ContactEmail.value);	
		var datastring = "ContactEmail=" + encodeURIComponent(document.f1.ContactEmail.value);
		$.ajax(
           {
			type:"POST",					
               url:"#Request.HTTPURL#/includes/CheckAccountEmail.cfc?method=CheckEmail&returnformat=plain",
               data:datastring,
               success: function(response)
               {
				resp = jQuery.trim(response);					
                $("##EmailAlreadyInUse").html(resp);
				if (resp!=''){
					$("##ContactEmail").focus();
					$("##ContactEmail").val('');
					$("##UsernameDisplay").html('');	
					$("##AllowContactEmail").val('0');	
				}
				else {
					$("##UsernameDisplay").html(document.f1.ContactEmail.value);	
					$("##AllowContactEmail").val('1');	
				}
               }
           });
		</cfif>
	}
	
	function checkListingTitleIsUnique() {
		var datastring = "ListingTitle=" + encodeURIComponent(document.f1.ListingTitle.value) <cfif Len(LinkID)> + "&LinkID=#LinkID#"</cfif>;
		$.ajax(
           {
			type:"POST",					
               url:"#Request.HTTPURL#/includes/CheckListingTitle.cfc?method=CheckTitle&returnformat=plain",
               data:datastring,
               success: function(response)
               {
				resp = jQuery.trim(response);	                
				if (resp!=''){					
					$("##ListingTitleWarningDiv").html(resp);	
					$("##ListingTitleWarningDiv").show('slow');	
					$("##AllowListingTitleSubmit").val('0');	
				}
				else {
					$("##ListingTitleWarningDiv").hide('slow');	
					$("##ListingTitleWarningDiv").html('');		
					$("##AllowListingTitleSubmit").val('1');	
				}
               }
           });
	}
	
	<!--- This is identical to the function above, but turns off the asynchronous aspect, so the form valiation function it is embedded in has to wait for the response before proceeding. (See includes/FormFieldListingTitle.cfm for the validation it is embedded in.)  --->
	function checkListingTitleIsUniqueSync() {
		var datastring = "ListingTitle=" + encodeURIComponent(document.f1.ListingTitle.value) <cfif Len(LinkID)> + "&LinkID=#LinkID#"</cfif>;
		$.ajax(
           {
			type:"POST",	
			async: false,				
               url:"#Request.HTTPURL#/includes/CheckListingTitle.cfc?method=CheckTitle&returnformat=plain",
               data:datastring,
               success: function(response)
               {
				resp = jQuery.trim(response);	                
				if (resp!=''){					
					$("##ListingTitleWarningDiv").html(resp);	
					$("##ListingTitleWarningDiv").show('slow');	
					$("##AllowListingTitleSubmit").val('0');	
				}
				else {
					$("##ListingTitleWarningDiv").hide('slow');	
					$("##ListingTitleWarningDiv").html('');		
					$("##AllowListingTitleSubmit").val('1');	
				}
               }
           });
	}
		
	function checkPositionDescrField(){
		<cfif ListingTypeID is "11">
			CKEDITOR.instances.LongDescr.updateElement();
			if ($("##UploadedDoc").val()!='' && $("##LongDescr").val()!='') {
				CKEDITOR.instances.LongDescr.destroy();
				$("##LongDescr").val('');
				CKLongDecr();
			}	
		<cfelse>
			if ($("##UploadedDoc").val()!='' && $("##LongDescr").val()!='') {
				$("##LongDescr").val('');
			}	
		</cfif>
	}
	
	function checkPositionDescrDoc(){	
		<cfif ListingTypeID is "11">
			CKEDITOR.instances.LongDescr.updateElement();
		</cfif>		
		if ($("##LongDescr").val()!='' && $("##UploadedDoc").val()!='') {
			$("##UploadedDoc").val('');
		}	
		$("##ExistingUploadedDocTN").html('');
	}
</script>
</cfoutput>

