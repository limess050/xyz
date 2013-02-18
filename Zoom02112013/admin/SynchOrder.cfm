<!--- This template expects an OrderID. (If a contained Listing has a Separate ExpandedListingOrderID, that Order will be processed as well.)  --->



<cfif ListFind("Devel,Live",Request.environment)>
	<cfimport prefix="lh" taglib="../Lighthouse/Tags">
	<cfset pg_title = "Synch Orders">
	<cfinclude template="../Lighthouse/Admin/Header.cfm">

	<p class="STATUSMESSAGE">This template is not designed to run on the server. It runs on the laptops to move listings to the server.</p>
	<cfinclude template="../Lighthouse/Admin/Footer.cfm">
	<cfabort>
</cfif>

<cfset allFields="OrderID">
<cfinclude template="../includes/setVariables.cfm">
<cfmodule template="../includes/_checkNumbers.cfm" fields="OrderID">

<cfinclude template="../includes/getLaptopKey.cfm">
<cfinclude template="../includes/SynchURL.cfm">

<cfparam name="StatusMessage" default="No Order data passed">
<cfparam name="PartOfAccountSynch" default="0">

<cfset OrderColumns="OrderTotal,PaymentAmount,OrderDate,DueDate,PaymentDate,PaymentStatusID,PaymentMethodID,UserID,CheckNumber">
<cfset UpdateColumns="UpdateDate,UpdatedByID,Descr">
<cfset ListingColumns="ListingFee,LinkID,InProgress,ListingTypeID,Active,Reviewed,DateListed,Title,URLSafeTitle,ShortDescr,LongDescr,EventStartDate,EventEndDate,RecurrenceID,RecurrenceMonthID,ParentLocationID,LocationID,LocationOther,LocationText,VehicleYear,MakeID,ModelID,Make,Model,Kilometers,FourWheelDrive,TransmissionID,PriceUS,PriceTZS,PublicPhone,PublicPhone2,PublicPhone3,PublicPhone4,PublicEmail,OrgName,PromoCopy,WebsiteURL,ContactFirstName,ContactLastName,ContactEmail,ContactPhone,ContactSecondPhone,AltContactFirstName,AltContactLastName,AltContactEmail,AltContactPhone,AltContactSecondPhone,CuisineID,CuisineOther,NGOTypeOther,Area,RentUS,RentTZS,TermID,Bedrooms,Bathrooms,AmenityID,AmenityOther,Deadline,UploadedDoc,ExpandedListingHTML,ExpandedListingFullToolbar,Instructions,LinkedRecordsText,InProgressPassword,InProgressUserID,ExpandedListingPDF,ExpandedListingFee,ExpandedListingInProgress,ExpandedListingAddDate,ExpandedListingOrderID,ExpandedListingExpirationDateUpdated_Fl,ListingPackageID,ExpirationDate">

<cfif Len(OrderID)>
	<cfquery name="getOrder" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select OrderID, #OrderColumns#,
		(Select Count(O2.OrderID) From Orders O2 Where O2.UserID=O.UserID) as OrderCount
		From Orders O 
		Where O.OrderID=<cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif Len(getOrder.UserID)>
		<cfquery name="getServerUserID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select ServerUserID
			From LH_Users
			Where UserID=<cfqueryparam value="#getOrder.UserID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset ServerUserID=getServerUserID.ServerUserID>
	</cfif>
	<cfoutput query="getOrder">
		<cfset OrderInsert="">
		<cfloop List="#OrderColumns#" index="i">
			<cfif i is "UserID" and Len(getOrder.UserID) and Len(getServerUserID.ServerUserID)><!--- Get the Server's UserID (which will already have been set in the Accounts synching) and use that in the Order record. --->
				<cfset OrderInsert=ListAppend(OrderInsert,getServerUserID.ServerUserID)>
			<cfelse>
				<cfif Len(Evaluate(i))>
					<cfset OrderInsert=ListAppend(OrderInsert,Evaluate(i))>
				<cfelse>
					<cfset OrderInsert=ListAppend(OrderInsert,"null")>
				</cfif>			
			</cfif>
		</cfloop>	
		<cfquery name="getOrderUpdates" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select #UpdateColumns#
			From Updates
			Where OrderID=<cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	
		<cfset OrderUpdatesCount=getOrderUpdates.RecordCount>
	</cfoutput>
	
	<cfquery name="getListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select ListingID, #ListingColumns#
		From Listings
		Where OrderID=<cfqueryparam value="#getOrder.OrderID#" cfsqltype="CF_SQL_INTEGER">
		Order By ListingID
	</cfquery>	
	
	<cfset ListingsCount=getListings.RecordCount>
	
	<cfset ListingPackageIDs="">
	
	<cfoutput query="getListings">		
		<cfif Len(ListingPackageID)>
			<cfif not ListFind(ListingPackageIDs,ListingPackageID)>
				<cfset ListingPackageIDs=ListAppend(ListingPackageIDs,ListingPackageID)>
			</cfif>			
			<cfquery name="getServerListingPackageID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select ServerListingPackageID
				From ListingPackages
				Where ListingPackageID=<cfqueryparam value="#ListingPackageID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<cfset ServerListingPackageID=getServerListingPackageID.ServerListingPackageID>
		</cfif>
		<cfset ExpLOrderInsert="">
		<cfif Len(ExpandedListingOrderID) and ExpandedListingOrderID neq OrderID><!--- Synch Listing's Expanded Listing Order to live server --->
			<cfquery name="getExpLOrder" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select OrderID, #OrderColumns#
				From Orders O
				Where OrderID=<cfqueryparam value="#ExpandedListingOrderID#" cfsqltype="CF_SQL_INTEGER">
				Order by OrderID
			</cfquery>
			<cfif getExplOrder.RecordCount>
				<cfloop List="#OrderColumns#" index="i">
					<cfif i is "UserID" and Len(getOrder.UserID) and Len(getServerUserID.ServerUserID)><!--- Get the Server's UserID (which will already have been set in the Accounts synching) and use that in the Order record. --->
						<cfset ExpLOrderInsert=ListAppend(ExpLOrderInsert,getServerUserID.ServerUserID)>
					<cfelse>
						<cfif Len(Evaluate("getExplOrder." & i))>
							<cfset ExpLOrderInsert=ListAppend(ExpLOrderInsert,Evaluate("getExplOrder." & i))>
						<cfelse>
							<cfset ExpLOrderInsert=ListAppend(ExpLOrderInsert,"null")>
						</cfif>
					</cfif>
				</cfloop>			
			</cfif>
		</cfif>
		<cfset "Listing_#CurrentRow#_ExpLOrderInsert"=ExpLOrderInsert>
		
		<cfset "Listing_#CurrentRow#_ExpandedListingPDF"=ExpandedListingPDF>
		<cfset "Listing_#CurrentRow#_ExpandedListingHTML"=ExpandedListingHTML>
		
		<cfquery name="getListingCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select CategoryID
			From ListingCategories
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset "Listing_#CurrentRow#_CategoryInsert"=getListingCategories.CategoryID>
		<cfquery name="getListingCuisines" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select CuisineID
			From ListingCuisines
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset "Listing_#CurrentRow#_CuisinesInsert"=ValueList(getListingCuisines.CuisineID)>
		<cfquery name="getListingPriceRanges" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select PriceRangeID
			From ListingPriceRanges
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset "Listing_#CurrentRow#_PriceRangesInsert"=ValueList(getListingCuisines.CuisineID)>
		<cfquery name="getListingNGOTypes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select NGOTypeID
			From ListingNGOTypes
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset "Listing_#CurrentRow#_NGOTypesInsert"=ValueList(getListingNGOTypes.NGOTypeID)>
		<cfquery name="getListingAmenities" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select AmenityID
			From ListingAmenities
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset "Listing_#CurrentRow#_AmenitiesInsert"=ValueList(getListingAmenities.AmenityID)>
		<cfquery name="getListingEventDays" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select ListingEventDate
			From ListingEventDays
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset "Listing_#CurrentRow#_EventDaysInsert"=ValueList(getListingEventDays.ListingEventDate)>
		<cfquery name="getListingImages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select FileName
			From ListingImages
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			Order by OrderNum
		</cfquery>
		<cfset ExistingListingImages="">
		<cfif getListingImages.RecordCount>
			<cfloop list="#ValueList(getListingImages.FileName)#" index="i">
				<cfif FilesExists("#Request.ListingImagesDir#\#i#")>
					<cfset ExistingListingImages=ListAppend(ExistingListingImages,"")>
				</cfif>
			</cfloop>
		</cfif>
		<cfset "Listing_#CurrentRow#_ImagesInsert"=ExistingListingImages>
		<cfquery name="getListingLocations" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select LocationID
			From ListingLocations
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset "Listing_#CurrentRow#_LocationsInsert"=ValueList(getListingLocations.LocationID)>
		<cfquery name="getListingParentSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select ParentSectionID
			From ListingParentSections
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset "Listing_#CurrentRow#_ParentSectionInsert"=getListingParentSections.ParentSectionID>
		<cfquery name="getListingRecurrences" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select RecurrenceDayID
			From ListingRecurrences
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset "Listing_#CurrentRow#_RecurrencesInsert"=ValueList(getListingRecurrences.RecurrenceDayID)>
		<cfquery name="getListingSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select SectionID
			From ListingSections
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset "Listing_#CurrentRow#_SectionInsert"=getListingSections.SectionID>
		<cfset ExpLDocAndImageList="">
		<cfif Len(ExpandedListingHTML)><!--- Search for any uploaded images in the HTML --->
			<cfset start = 1 />
			<cfloop condition="true">
			  <cfset result = REFind('(ListingUploadedDocs/)(.*?)"', ExpandedListingHTML, start, true) />
			  <cfif result.pos[1] LT 1>
			    <cfbreak />
			  </cfif>
			  <cfset string = mid(ExpandedListingHTML, result.pos[3], result.len[3]) />
			  <cfset ExpLDocAndImageList=ListAppend(ExpLDocAndImageList,string)>
			  <cfset start = result.pos[1] + result.len[1] />
			</cfloop>
		</cfif>
		<cfset ExistingExpLDocAndImageList="">
		<cfloop list="#ExpLDocAndImageList#" index="i">
			<cfif FileExists("#Request.ListingUploadedDocsDir#\#i#")>
				<cfset ExistingExpLDocAndImageList=ListAppend(ExistingExpLDocAndImageList,i)>
			</cfif>
		</cfloop>
		<cfset "Listing_#CurrentRow#_ExpLDocAndImageList"=ExistingExpLDocAndImageList>
		<cfquery name="getListingUpdates#CurrentRow#" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select #UpdateColumns#
			From Updates
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset "Listing_#CurrentRow#_UpdatesCount"=Evaluate("getListingUpdates" & CurrentRow & ".RecordCount")>
	</cfoutput>	
	
	<cfif Len(OrderInsert) and ListingsCount>
		<cfhttp url="http://#SynchURL#/intTasks/SynchOrder.cfm" method="POST" timeout="600">
	   		<cfhttpparam type="FORMFIELD" name="OrderInsert" value="#OrderInsert#">
			<cfhttpparam type="FORMFIELD" name="OrderUpdatesCount" value="#OrderUpdatesCount#">
			<cfoutput query="getOrderUpdates">
				<cfloop List="#UpdateColumns#" index="i">
					<cfhttpparam type="FORMFIELD" name="OrderUpdate_#CurrentRow#_#i#" value="#Evaluate(i)#">					
				</cfloop>
			</cfoutput>
	   		<cfhttpparam type="FORMFIELD" name="ListingsCount" value="#ListingsCount#">
			<cfoutput query="getListings">
				<cfloop List="#ListingColumns#" index="i">
					<cfif i is "ListingPackageID" and Len(ListingPackageID) and Len(getServerListingPackageID.ServerListingPackageID)>
						<cfhttpparam type="FORMFIELD" name="Listing_#CurrentRow#_#i#" value="#getServerListingPackageID.ServerListingPackageID#">	
					<cfelse>
						<cfhttpparam type="FORMFIELD" name="Listing_#CurrentRow#_#i#" value="#Evaluate(i)#">	
					</cfif>				
				</cfloop>
	   			<cfhttpparam type="FORMFIELD" name="Listing_#CurrentRow#_ExpLOrderInsert" value="#Evaluate('Listing_' & CurrentRow & '_ExpLOrderInsert')#">
		   		<cfhttpparam type="FORMFIELD" name="Listing_#CurrentRow#_CategoryInsert" value="#Evaluate('Listing_' & CurrentRow & '_CategoryInsert')#">
		   		<cfhttpparam type="FORMFIELD" name="Listing_#CurrentRow#_CuisinesInsert" value="#Evaluate('Listing_' & CurrentRow & '_CuisinesInsert')#">
		   		<cfhttpparam type="FORMFIELD" name="Listing_#CurrentRow#_PriceRangesInsert" value="#Evaluate('Listing_' & CurrentRow & '_PriceRangesInsert')#">
		   		<cfhttpparam type="FORMFIELD" name="Listing_#CurrentRow#_NGOTypesInsert" value="#Evaluate('Listing_' & CurrentRow & '_NGOTypesInsert')#">
		   		<cfhttpparam type="FORMFIELD" name="Listing_#CurrentRow#_AmenitiesInsert" value="#Evaluate('Listing_' & CurrentRow & '_AmenitiesInsert')#">
		   		<cfhttpparam type="FORMFIELD" name="Listing_#CurrentRow#_EventDaysInsert" value="#Evaluate('Listing_' & CurrentRow & '_EventDaysInsert')#">
		   		<cfhttpparam type="FORMFIELD" name="Listing_#CurrentRow#_LocationsInsert" value="#Evaluate('Listing_' & CurrentRow & '_LocationsInsert')#">
		   		<cfhttpparam type="FORMFIELD" name="Listing_#CurrentRow#_ParentSectionInsert" value="#Evaluate('Listing_' & CurrentRow & '_ParentSectionInsert')#">
		   		<cfhttpparam type="FORMFIELD" name="Listing_#CurrentRow#_RecurrencesInsert" value="#Evaluate('Listing_' & CurrentRow & '_RecurrencesInsert')#">
		   		<cfhttpparam type="FORMFIELD" name="Listing_#CurrentRow#_SectionInsert" value="#Evaluate('Listing_' & CurrentRow & '_SectionInsert')#">
		   		<cfhttpparam type="FORMFIELD" name="Listing_#CurrentRow#_ImagesInsert" value="#Evaluate('Listing_' & CurrentRow & '_ImagesInsert')#">
				<cfset LoopCounter=1>
				<cfloop list="#Evaluate('Listing_' & CurrentRow & '_ImagesInsert')#" index="i">
					<cfhttpparam type="FILE" name="Listing_#CurrentRow#_ImageFile_#LoopCounter#" file="#Request.ListingImagesDir#\#i#" mimetype="multipart/form-data">
					<cfset LoopCounter=LoopCounter+1>
				</cfloop>
				<cfif Len(Evaluate('Listing_' & CurrentRow & '_ExpandedListingPDF')) and FileExists("#Request.ListingUploadedDocsDir#\#Evaluate('Listing_' & CurrentRow & '_ExpandedListingPDF')#")>
					<cfhttpparam type="FILE" name="Listing_#CurrentRow#_ExpandedListingPDFDoc" file="#Request.ListingUploadedDocsDir#\#Evaluate('Listing_' & CurrentRow & '_ExpandedListingPDF')#" mimetype="multipart/form-data">
				</cfif>
				<cfif Len(UploadedDoc) and fileExists("#Request.ListingUploadedDocsDir#\#UploadedDoc#")>
					<cfhttpparam type="FILE" name="Listing_#CurrentRow#_UploadedDocFile" file="#Request.ListingUploadedDocsDir#\#UploadedDoc#" mimetype="multipart/form-data">
				</cfif>
				<cfset LoopCounter=1>
				<cfif Len(Evaluate('Listing_' & CurrentRow & '_ExpLDocAndImageList'))>
					<cfhttpparam type="FORMFIELD" name="Listing_#CurrentRow#_ExpLDocAndImageCounter" value="#ListLen(Evaluate('Listing_' & CurrentRow & '_ExpLDocAndImageList'))#">
					<cfloop list="#Evaluate('Listing_' & CurrentRow & '_ExpLDocAndImageList')#" index="i">
						<cfhttpparam type="FILE" name="Listing_#CurrentRow#_ExpLDocOrImageFile_#LoopCounter#" file="#Request.ListingUploadedDocsDir#\#i#" mimetype="multipart/form-data">
						<cfset LoopCounter=LoopCounter+1>
					</cfloop>
				</cfif>
				<cfhttpparam type="FORMFIELD" name="Listing_#CurrentRow#_UpdatesCount" value="#Evaluate('Listing_' & CurrentRow & '_UpdatesCount')#">
				<cfif Evaluate('Listing_' & CurrentRow & '_UpdatesCount')>
					<cfset OuterQueryCurrentRow=CurrentRow>
					<cfset UpdateCounter=0>
					<cfloop query="getListingUpdates#CurrentRow#">
						<cfset UpdateCounter=UpdateCounter+1>
						<cfloop List="#UpdateColumns#" index="i">
							<cfhttpparam type="FORMFIELD" name="ListingUpdate_#OuterQueryCurrentRow#_#UpdateCounter#_#i#" value="#Evaluate(i)#">					
						</cfloop>
					</cfloop>
				</cfif>
			</cfoutput>			
			
	   		<cfhttpparam type="FORMFIELD" name="AdminUserID" value="#Session.UserID#">
	   		<cfhttpparam type="FORMFIELD" name="LapTopKey" value="#LapTopKey#">
		</cfhttp>
		
		<cfset ReturnValue=Trim(cfhttp.filecontent)>
	
		<!--- <cfoutput>
			#ReturnValue#<p>
		</cfoutput> --->
		<cfif IsNumeric(ReturnValue)><!--- Returning new Server OrderID --->
			
			<cftransaction>
				<cfoutput query="getListings">
					<cfquery name="deleteListingRelatedRecords" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						Delete From ListingCategories where ListingID in (<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">)
						
						Delete From ListingCuisines where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
						
						Delete From ListingPriceRanges where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
						
						Delete From ListingEventDays where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
						
						Delete From ListingImages where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
						
						Delete From ListingLocations where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
						
						Delete From ListingParentSections where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		
						Delete From ListingRecurrences where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		
						Delete From ListingSections where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
						
						Delete From Updates Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
					</cfquery>
					<cfquery name="deleteListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						Delete From Listings where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
					</cfquery>
					<cfif Len(ExpandedListingOrderID)>
						<cfquery name="deleteListingPackageOrderUpdates" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
							Delete From Updates Where OrderID=<cfqueryparam value="#ExpandedListingOrderID#" cfsqltype="CF_SQL_INTEGER">
						</cfquery>
						<cfquery name="deleteExpLOrder" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
							Delete From Orders where OrderID=<cfqueryparam value="#ExpandedListingOrderID#" cfsqltype="CF_SQL_INTEGER">
						</cfquery>
					</cfif>
				</cfoutput>
				
				<cfquery name="deleteOrderUpdates" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Delete From Updates Where OrderID=<cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				<cfquery name="deleteOrder" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Delete From Orders where OrderID=<cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				
				<cfif Len(ListingPackageIDs)><!--- If this order contained Listings with Listing Packages and no other orders exist using the Listing Package, delete the Listing Package and its Order. --->
					<cfloop list="#ListingPackageIDs#" index="i">
						<cfquery name="checkLPOrders" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
							Select O.OrderID
							From Orders O
							Inner Join Listings L on O.OrderID=L.OrderID
							Where L.ListingPackageID=<cfqueryparam value="#i#" cfsqltype="CF_SQL_INTEGER">
							and O.OrderID <> <cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER">
						</cfquery>
						<cfif not checkLPOrders.RecordCount>
							<cfquery name="getLPOrder" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
								Select O.OrderID
								From Orders O
								Inner Join ListingPackages LP on O.OrderID=LP.OrderID
								Where LP.ListingPackageID=<cfqueryparam value="#i#" cfsqltype="CF_SQL_INTEGER">
							</cfquery>
							<cfquery name="deleteListingPackage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
								Delete From ListingPackages Where ListingPackageID=<cfqueryparam value="#i#" cfsqltype="CF_SQL_INTEGER">
							</cfquery>
							<cfquery name="deleteListingPackageOrderUpdates" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
								Delete From Updates Where OrderID=<cfqueryparam value="#getLPOrder.OrderID#" cfsqltype="CF_SQL_INTEGER">
							</cfquery>
							<cfquery name="deleteListingPackageOrder" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
								Delete From Orders Where OrderID=<cfqueryparam value="#getLPOrder.OrderID#" cfsqltype="CF_SQL_INTEGER">
							</cfquery>
						</cfif>
					</cfloop>
				</cfif>
			</cftransaction>
			
			<cfif Len(getOrder.UserID)>
				<!--- If No Orders are left for the Account, delete it. --->
				<cfquery name="getRemainingAccountOrders" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Select O.OrderID
					From Orders O
					Where O.UserID=<cfqueryparam value="#getOrder.UserID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				<cfif not getRemainingAccountOrders.RecordCount>
					<cfquery name="deleteAccountUpdates" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						Delete From Updates where UserID=<cfqueryparam value="#getOrder.UserID#" cfsqltype="CF_SQL_INTEGER">
					</cfquery>
					<cfquery name="deleteAccount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						Delete From LH_Users where UserID=<cfqueryparam value="#getOrder.UserID#" cfsqltype="CF_SQL_INTEGER">
					</cfquery>
				</cfif>
			</cfif>
			
			<cfset StatusMessage="Order #OrderID# synching completed.">
			<cfset OrderStatusMessage=StatusMessage>
			<cfset OrderSynched="1">
		<cfelse>
			<cfset StatusMessage="Order #OrderID# synching failed.">
			<cfset OrderStatusMessage=StatusMessage>
			<cfset OrderSynched="0">
			<cfoutput>
				#ReturnValue#<p>
			</cfoutput>
			<cfabort>
		</cfif>
	</cfif>
</cfif>
<!--- <cfoutput>#StatusMessage#</cfoutput>
<cfabort> --->
<cfif not PartOfAccountSynch>
	<cflocation url="Synch.cfm?StatusMessage=#URLEncodedFormat(StatusMessage)#" addToken="no">
	<cfabort>
</cfif>

