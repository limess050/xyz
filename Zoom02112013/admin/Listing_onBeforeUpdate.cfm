<!--- Get existing values for all fields
Compare to form fields values
If changed, add to Chenged string
if Len(ChangedString), insert update record --->

<cfquery name="getListingType" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select ListingTypeID
	From Listings L
	Where L.ListingID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>

<cfset CheckboxList="Four_Wheel_Drive,Active,Reviewed,Featured_Listing">
<cfset DateList="Event_Start_Date,Event_End_Date,Deadline,Date_Listed">
<cfset TitleLabel="Listing Title">
<cfset ShortDescrLabel="Short Description">
<cfset DeadlineLabel="Deadline">
<cfset LongDescrLabel="Long Description">
<cfset LocationTextLabel="Location">
<cfset UploadedDocLabel="Uploaded Document">
		
<cfswitch expression="#getListingType.ListingTypeID#">
	<cfcase value="1,20">
		<cfset TrackedColumns="Title,Parent_SectionID,CategoryID,Public_Phone,Public_Email,PriceRangeID,ShortDescr,LocationID,Location_Other,LocationText,WebsiteURL,Date_Listed,Active,Reviewed,Featured_Listing">
		<cfset TitleLabel="Business Name">
		<cfset ShortDescrLabel="Short Promo Copy">
		<cfset LocationTextLabel="Directions">
	</cfcase>
	<cfcase value="2">
		<cfset TrackedColumns="Title,Parent_SectionID,CategoryID,Public_Phone,Public_Email,CuisineID,CuisineOther,ShortDescr,LocationID,Location_Other,LocationText,WebsiteURL,Date_Listed,Active,Reviewed,Featured_Listing">
		<cfset TitleLabel="Business Name">
		<cfset ShortDescrLabel="Short Promo Copy">
		<cfset LocationTextLabel="Directions">
	</cfcase>
	<cfcase value="3">
		<cfset TrackedColumns="Title,Price_US,Price_TZS,Parent_SectionID,CategoryID,Public_Phone,Public_Email,ShortDescr,Date_Listed,Active,Reviewed">
		<cfset TitleLabel="Descriptive Title">
		<cfset ShortDescrLabel="Short Promo Copy">
	</cfcase>
	<cfcase value="4">
		<cfset TrackedColumns="Price_US,Price_TZS,Parent_SectionID,CategoryID,Vehicle_Year,MakeID,Model,Kilometers,Four_Wheel_Drive,TransmissionID,Public_Phone,Public_Email,Date_Listed,Active,Reviewed">
		<cfset ShortDescrLabel="Short Promo Copy">
	</cfcase>
	<cfcase value="5">
		<cfset TrackedColumns="Price_US,Price_TZS,Parent_SectionID,CategoryID,Vehicle_Year,Make,Model,Kilometers,Public_Phone,Public_Email,ShortDescr,Date_Listed,Active,Reviewed">
		<cfset ShortDescrLabel="Short Promo Copy">
	</cfcase>
	<cfcase value="6">
		<cfset TrackedColumns="Rent_US,Rent_TZS,Parent_SectionID,CategoryID,Public_Phone,Public_Email,TermID,Area_Plot,Bedrooms,Bathrooms,AmenityID,Amenity_Other,ShortDescr,LocationID,Location_Other,Location_Text,Date_Listed,Active,Reviewed">
		<cfset ShortDescrLabel="Short Promo Copy">
	</cfcase>
	<cfcase value="7">
		<cfset TrackedColumns="Rent_US,Rent_TZS,Parent_SectionID,CategoryID,Public_Phone,Public_Email,TermID,ShortDescr,LocationID,Location_Other,Location_Text,Date_Listed,Active,Reviewed">
		<cfset ShortDescrLabel="Short Promo Copy">
	</cfcase>
	<cfcase value="8">
		<cfset TrackedColumns="Price_US,Price_TZS,Parent_SectionID,CategoryID,Public_Phone,Public_Email,ShortDescr,LocationID,Location_Other,Location_Text,Date_Listed,Active,Reviewed">
		<cfset ShortDescrLabel="Short Promo Copy">
	</cfcase>
	<cfcase value="9">
		<cfset TrackedColumns="Title,Price_US,Price_TZS,Parent_SectionID,CategoryID,Public_Phone,Public_Email,Deadline,ShortDescr,Date_Listed,Active,Reviewed">
		<cfset TitleLabel="Descriptive Title">
		<cfset ShortDescrLabel="Short Promo Copy">
	</cfcase>
	<cfcase value="10">
		<cfset TrackedColumns="Title,Parent_SectionID,CategoryID,WebsiteURL,ShortDescr,Deadline,Event_Start_Date,LongDescr,UploadedDoc,Public_Phone,Public_Email,Date_Listed,Active,Reviewed">
		<cfset TitleLabel="Business Name">
		<cfset ShortDescrLabel="Position Title">
		<cfset LongDescrLabel="Position Description">
		<cfset UploadedDocLabel="Position Description Document">
	</cfcase>
	<cfcase value="11">
		<cfset TrackedColumns="Parent_SectionID,CategoryID,Title,ShortDescr,LongDescr,UploadedDoc,Public_Phone,Public_Email,Contact_Email,Date_Listed,Active,Reviewed">
		<cfset TitleLabel="Headline">
		<cfset LongDescrLabel="Resume/CV">
		<cfset UploadedDocLabel="Resume/CV Document">
	</cfcase>
	<cfcase value="12">
		<cfset TrackedColumns="Parent_SectionID,CategoryID,ShortDescr,LongDescr,Deadline,Public_Phone,Public_Email,Contact_Email,Date_Listed,Active,Reviewed">
		<cfset ShortDescrLabel="Position Title">
		<cfset LongDescrLabel="Position Description">
	</cfcase>
	<cfcase value="13">
		<cfset TrackedColumns="Parent_SectionID,CategoryID,Title,ShortDescr,LongDescr,Public_Phone,Public_Email,Contact_Email,Date_Listed,Active,Reviewed">	
		<cfset TitleLabel="Headline">	
		<cfset LongDescrLabel="Experience & Qualifications Summary">
	</cfcase>
	<cfcase value="14">
		<cfset TrackedColumns="Title,Parent_SectionID,CategoryID,Public_Phone,Public_Email,NGOTypeID,NGOTypeOther,ShortDescr,LocationID,Location_Other,Location_Text,WebsiteURL,Date_Listed,Active,Reviewed,Featured_Listing">
		<cfset TitleLabel="Organization Name">
	</cfcase>
	<cfcase value="15">
		<cfset TrackedColumns="Title,Event_Start_Date,Event_End_Date,Parent_SectionID,CategoryID,Public_Phone,Public_Email,LocationID,Location_Other,Location_Text,ShortDescr,Date_Listed,Active,Reviewed">
		<cfset TitleLabel="Event Title">
		<cfset ShortDescrLabel="Event Description">
	</cfcase>
</cfswitch>


<cfset ChangedString="">

<cfquery name="getOrig" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select #Replace(TrackedColumns,"_","","ALL")#
	From Listings L
	Left Outer Join ListingParentSections LPS on L.ListingID=LPS.ListingID
	Left Outer join ListingSections LS on L.ListingID=LS.ListingID
	Left Outer Join ListingCategories LC on L.ListingID=LC.ListingID
	Where L.ListingID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>
<cfquery name="ParentSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select ParentSectionID as SelectValue, Title as SelectText
	From ParentSectionsView
	Order By ParentSectionID
</cfquery>
<cfquery name="Sections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SectionID as SelectValue, Title as SelectText
	From SectionsView
	Order By SectionID
</cfquery>
<cfquery name="Categories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select CategoryID as SelectValue, Title as SelectText
	From Categories
	Order By CategoryID
</cfquery>
<cfif ListFind(TrackedColumns,"CuisineID")>
	<cfquery name="getOrigCuisines" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select Title
		From Cuisines C Inner Join ListingCuisines LC on C.CuisineID=LC.CuisineID
		Where LC.ListingID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
	</cfquery>
	<cfquery name="Cuisines" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select CuisineID as SelectValue, Title as SelectText
		From Cuisines
		Order By CuisineID
	</cfquery>
</cfif>
<cfif ListFind(TrackedColumns,"PriceRangeID")>
	<cfquery name="getOrigPriceRanges" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select Title
		From PriceRanges PR Inner Join ListingPriceRanges LPR on PR.PriceRangeID=LPR.PriceRangeID
		Where LPR.ListingID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
	</cfquery>
	<cfquery name="PriceRanges" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select PriceRangeID as SelectValue, Title as SelectText
		From PriceRanges
		Order By OrderNum
	</cfquery>
</cfif>
<cfif ListFind(TrackedColumns,"NGOTypeID")>
	<cfquery name="getOrigNGOTypes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select Title
		From NGOTypes NT Inner Join ListingNGOTypes LNT on NT.NGOTypeID=LNT.NGOTypeID
		Where LNT.ListingID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
	</cfquery>
	<cfquery name="NGOTypes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select NGOTypeID as SelectValue, Title as SelectText
		From NGOTypes
		Order By OrderNum
	</cfquery>
</cfif>
<cfif ListFind(TrackedColumns,"MakeID")>
	<cfquery name="Makes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select MakeID as SelectValue, Title as SelectText
		From Makes
		Order By MakeID
	</cfquery>
</cfif>
<cfif ListFind(TrackedColumns,"TransmissionID")>
	<cfquery name="Transmissions" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select TransmissionID as SelectValue, Title as SelectText
		From Transmissions
		Order By TransmissionID
	</cfquery>
</cfif>
<cfif ListFind(TrackedColumns,"TermID")>
	<cfquery name="Terms" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select TermID as SelectValue, Title as SelectText
		From Terms
		Order By TermID
	</cfquery>
</cfif>
<cfif ListFind(TrackedColumns,"LocationID")>
	<cfquery name="getOrigLocations" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select Title
		From Locations L Inner Join ListingLocations LL on L.LocationID=LL.LocationID
		Where LL.ListingID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
		Order By L.OrderNum
	</cfquery>
	<cfquery name="Locations" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select LocationID as SelectValue, Title as SelectText
		From Locations
		Order By OrderNum
	</cfquery>
</cfif>
<cfif ListFind(TrackedColumns,"AmenityID")>
	<cfquery name="getOrigAmenities" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select Title
		From Amenities A Inner Join ListingAmenities LA on A.AmenityID=LA.AmenityID
		Where LA.ListingID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
		Order By A.OrderNum
	</cfquery>
	<cfquery name="Amenities" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select AmenityID as SelectValue, Title as SelectText
		From Amenities
		Order By OrderNum
	</cfquery>
</cfif>

<cfloop list="#TrackedColumns#" index="i">
	<cfset LabelName=Replace(Replace(i,"ID",":"),"_"," ","ALL")>
	<cfif ListFind("Title,ShortDescr,Deadline,LongDescr,UploadedDoc,LocationText",LabelName)>
		<cfset LabelName=Evaluate(LabelName & "Label")>
	<cfelseif LabelName is "Parent Location:">
		<cfset LabelName="Area:">
	<cfelseif LabelName is "Event Start Date" and getListingType.ListingTypeID is "10">
		<cfset LabelName="Start Date:">
	</cfif>
	<cfset ColumnName=Replace(i,"_","","ALL")>
	<cfset OldValue=Evaluate('getOrig.' & ColumnName)>
	
	<cfif ListFind("PriceUS,PriceTZS,RentUS,RentTZS",ColumnName)>
		<cfset OldValue=DollarFormat(OldValue)>	
	<cfelseif ListFind(DateList,i)>
		<cfset OldValue=DateFormat(OldValue,"dd/mm/yyyy")>
	<cfelseif ColumnName is "CuisineID">
		<cfset OldValue=ValueList(getOrigCuisines.Title)>
	<cfelseif ColumnName is "PriceRangeID">
		<cfset OldValue=ValueList(getOrigPriceRanges.Title)>
	<cfelseif ColumnName is "NGOTypeID">
		<cfset OldValue=ValueList(getOrigNGOTypes.Title)>
	<cfelseif ColumnName is "LocationID">
		<cfset OldValue=ValueList(getOrigLocations.Title)>
	<cfelseif ColumnName is "AmenityID">
		<cfset OldValue=ValueList(getOrigAmenities.Title)>
	</cfif>
	
	<cfif ListFind(CheckboxList,i)>
		<cfif IsDefined('#ColumnName#')>
			<cfif not OldValue>
				<cfset ChangedString=ListAppend(ChangedString,"#LabelName# checked.","|")>
			</cfif>
		<cfelseif OldValue>
			<cfset ChangedString=ListAppend(ChangedString,"#LabelName# unchecked.","|")>
		</cfif>
	<cfelse>
		
		<cfif IsDefined("#columnName#")>
			<cfset NewValue=Evaluate(ColumnName)>	
		<cfelse>
			<cfset NewValue="">	
		</cfif>
		
		
		<cfif ListFind("PriceUS,PriceTZS,RentUS,RentTZS",ColumnName)>
			<cfset NewValue=DollarFormat(NewValue)>
		</cfif>
		
		<cfif i is "UploadedDoc">
			<cfif Len(form.UploadedDoc)>
				<cfset NewValue=form.UploadedDoc>
			<cfelseif IsDefined('form.UploadedDoc_Delete')>
				<cfset NewValue="">				
			<cfelse>
				<cfset NewValue=OldValue>
			</cfif>
		<cfelseif i is "CuisineID">		
			<cfset NewValueString="">
			<cfloop query="Cuisines">
				<cfif Len(NewValue) and ListFind(NewValue,SelectValue)>
					<cfset NewValueString=ListAppend(NewValueString,SelectText)>
				</cfif>
			</cfloop>
			<cfif Len(NewValueString)>
				<cfset NewValue=NewValueString>
			</cfif>
		<cfelseif i is "PriceRangeID">		
			<cfset NewValueString="">
			<cfloop query="PriceRanges">
				<cfif Len(NewValue) and ListFind(NewValue,SelectValue)>
					<cfset NewValueString=ListAppend(NewValueString,SelectText)>
				</cfif>
			</cfloop>
			<cfif Len(NewValueString)>
				<cfset NewValue=NewValueString>
			</cfif>
		<cfelseif i is "NGOTypeID">		
			<cfset NewValueString="">
			<cfloop query="NGOTypes">
				<cfif Len(NewValue) and ListFind(NewValue,SelectValue)>
					<cfset NewValueString=ListAppend(NewValueString,SelectText)>
				</cfif>
			</cfloop>
			<cfif Len(NewValueString)>
				<cfset NewValue=NewValueString>
			</cfif>
		<cfelseif i is "LocationID">		
			<cfset NewValueString="">
			<cfloop query="Locations">
				<cfif Len(NewValue) and ListFind(NewValue,SelectValue)>
					<cfset NewValueString=ListAppend(NewValueString,SelectText)>
				</cfif>
			</cfloop>
			<cfif Len(NewValueString)>
				<cfset NewValue=NewValueString>
			</cfif>
		<cfelseif i is "AmenityID">		
			<cfset NewValueString="">
			<cfloop query="Amenities">
				<cfif Len(NewValue) and ListFind(NewValue,SelectValue)>
					<cfset NewValueString=ListAppend(NewValueString,SelectText)>
				</cfif>
			</cfloop>
			<cfif Len(NewValueString)>
				<cfset NewValue=NewValueString>
			</cfif>
		</cfif>	
		
		<cfif ListFind("ShortDescr,LongDescr,Instructions,LocationText,Directions",ColumnName)><!--- Front End and Admin Text Areas are slightly different and so show changes unless stripping out spaces and line breaks. --->
			<cfset OldValue=Replace(Replace(Replace(OldValue,' ','','ALL'),Chr(13),'','ALL'),Chr(10),'','ALL')>
			<cfset NewValue=Replace(Replace(Replace(NewValue,' ','','ALL'),Chr(13),'','ALL'),Chr(10),'','ALL')>
		</cfif>
		
		<cfif OldValue neq NewValue>
			<cfif ListFind("ParentSectionID,SectionID,CategoryID,,MakeID,TransmissionID,TermID",ColumnName)>
				<cfswitch expression="#ColumnName#">
					<cfcase value="ParentSectionID">
						<cfloop query="ParentSections">
							<cfif Len(NewValue) and SelectValue is NewValue>
								<cfset NewValue=SelectText>
							</cfif>
							<cfif Len(OldValue) and SelectValue is OldValue>
								<cfset OldValue=SelectText>
							</cfif>
						</cfloop>
					</cfcase>
					<cfcase value="SectionID">
						<cfloop query="Sections">
							<cfif Len(NewValue) and SelectValue is NewValue>
								<cfset NewValue=SelectText>
							</cfif>
							<cfif Len(OldValue) and SelectValue is OldValue>
								<cfset OldValue=SelectText>
							</cfif>
						</cfloop>
					</cfcase>
					<cfcase value="CategoryID">
						<cfloop query="Categories">
							<cfif Len(NewValue) and SelectValue is NewValue>
								<cfset NewValue=SelectText>
							</cfif>
							<cfif Len(OldValue) and SelectValue is OldValue>
								<cfset OldValue=SelectText>
							</cfif>
						</cfloop>
					</cfcase>
					<cfcase value="MakeID">
						<cfloop query="Makes">
							<cfif Len(NewValue) and SelectValue is NewValue>
								<cfset NewValue=SelectText>
							</cfif>
							<cfif Len(OldValue) and SelectValue is OldValue>
								<cfset OldValue=SelectText>
							</cfif>
						</cfloop>
					</cfcase>
					<cfcase value="TransmissionID">
						<cfloop query="Transmissions">
							<cfif Len(NewValue) and SelectValue is NewValue>
								<cfset NewValue=SelectText>
							</cfif>
							<cfif Len(OldValue) and SelectValue is OldValue>
								<cfset OldValue=SelectText>
							</cfif>
						</cfloop>
					</cfcase>
					<cfcase value="TermID">
						<cfloop query="Terms">
							<cfif Len(NewValue) and SelectValue is NewValue>
								<cfset NewValue=SelectText>
							</cfif>
							<cfif Len(OldValue) and SelectValue is OldValue>
								<cfset OldValue=SelectText>
							</cfif>
						</cfloop>
					</cfcase>
				</cfswitch>
			</cfif>
			<cfif Len(NewValue) gt 200 or Len(OldValue) gt 200><!--- Long strings just cause a huge confusing output on the Update History --->				
				<cfif not Len(NewValue)>
					<cfset ChangedString=ListAppend(ChangedString,"#LabelName# deleted.","|")>
				<cfelseif ColumnName is "UploadedDoc">
					<cfif not Len(OldValue)>
						<cfset ChangedString=ListAppend(ChangedString,"#LabelName# uploaded.","|")>
					<cfelse>
						<cfset ChangedString=ListAppend(ChangedString,"#LabelName# '#OldValue#' replaced.","|")>
					</cfif>
				<cfelseif Not Len(OldValue)>
					<cfset ChangedString=ListAppend(ChangedString,"#LabelName# text entered.","|")>
				<cfelse>
					<cfset ChangedString=ListAppend(ChangedString,"#LabelName# text changed.","|")>
				</cfif>
			<cfelse>
				<cfif not Len(NewValue)>
					<cfset ChangedString=ListAppend(ChangedString,"#LabelName# '#OldValue#' deleted.","|")>
				<cfelseif ColumnName is "UploadedDoc">
					<cfif not Len(OldValue)>
						<cfset ChangedString=ListAppend(ChangedString,"#LabelName# uploaded.","|")>
					<cfelse>
						<cfset ChangedString=ListAppend(ChangedString,"#LabelName# '#OldValue#' replaced.","|")>
					</cfif>
				<cfelseif Not Len(OldValue)>
					<cfset ChangedString=ListAppend(ChangedString,"#LabelName# '#NewValue#' entered.","|")>
				<cfelse>
					<cfset ChangedString=ListAppend(ChangedString,"#LabelName# '#OldValue#' changed to '#NewValue#'.","|")>
				</cfif>
			</cfif>
			
		</cfif>	
	</cfif>	
</cfloop>

<cfif Len(ChangedString)>
	<cfquery name="updatedBy" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Insert into Updates
		(ListingID, UpdateDate, UpdatedByID, Descr)
		VALUES
		(<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">,
		GetDate(),
		<cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">,
		<cfqueryparam value="#ChangedString#" cfsqltype="CF_SQL_VARCHAR" maxlength="2000">)
	</cfquery>
</cfif>

