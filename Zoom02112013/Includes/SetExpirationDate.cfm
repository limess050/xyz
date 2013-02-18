<!--- Business Rules
	
	1.	When a listing is marked reviewed and its associated order is marked as paid, the expiration date should be set to the current date plus the listing type's term. (If the listings is for a Prof Job Opp (ListingTypeID=10), then it is set to the term based expiration date OR the Application Deadline, whichever is earlier.)  Do this only if the expiration date field is blank. LATER ADDITION: 6/16/2010 - If the Listing is ListingTypeID= 1,2,14,15 then set the ExpirationDate when marked Reviewed, even if the Order is not paid. (These listings are 'permanent' and the Order Status only determines whether the Expanded Listing (if any) is displayed.)
2.	When an order is updated, update associated listings (if already reviewed) with expiration date of the current date plus the listing type's term (unless ListingTypeID=10, as above). Do this only if the expiration date field is blank.
3.	When an order for an expanded listing is marked as paid, update the expiration date to the current date plus the listing type's term. (unless ListingTypeID=10, as above)
4.	Upon payment of a renewal order, all listings contained in that order get their expiration date extended by adding the listing type's term to the individual listing's current expiration dates (if listing is still active). If listing is already expired, the expiration date is set to the current date plus the listing type's term. (unless ListingTypeID=10, as above)
5.	If none of these scenarios apply, the expiration date is left blank (For example, the listing was never submitted and so is still marked as In Progress or the listing was submitted as part of an order that was never paid, etc.)
 --->
 
<cfparam name="ListingID" Default="">
<cfparam name="OrderID" default="">
<cfparam name="FromFrontEndListingForm" default="0">

<cfif FromFrontEndListingForm>
	<cfquery name="GetExpDateInfo" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ExpirationDate, L.Reviewed, L.ListingTypeID, L.Deadline,
		O.PaymentStatusID,
		LT.TermExpiration
		From Listings L
		Inner Join Orders O on L.OrderID=O.OrderID
		Inner Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
		Where L.ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif GetExpDateInfo.RecordCount and GetExpDateInfo.Reviewed and ListFind("2,3,4",GetExpDateInfo.PaymentStatusID) and Len(GetExpDateInfo.ExpirationDate)>		
		<cfquery name="UpdateExpirationDate" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update Listings 
			Set ExpirationDate = 
			CASE WHEN DateAdd(day, #GetExpDateInfo.TermExpiration#, GetDate()) > Deadline THEN Deadline ELSE DateAdd(day, #GetExpDateInfo.TermExpiration#, GetDate()) END		
			Where ListingID = <cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cfif>
<cfelseif Len(OrderID)><!--- One-off listing, or renewal order, or cart order, or expanded Listing only order, or Order Admin update --->
	<cfquery name="checkPaymentStatus" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select O.PaymentStatusID
		From Orders O
		Where OrderID = <cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif ListFind("2,3,4",checkPaymentStatus.PaymentStatusID)>
	
		<!--- Loop through any listings renewed in this order --->
		<cfquery name="GetRenewalInfo" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select L.ListingID, L.ExpirationDate, L.ExpirationDateELP, L.ListingTypeID, L.Deadline,
			LR.ListingRenewalID, LR.IncludesExpandedListing,
			LT.TermExpiration,
			GetDate() as CurrentDate
			From ListingRenewals LR
			Inner Join Listings L on LR.ListingID=L.ListingID
			Inner Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
			Where LR.OrderID = <cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfoutput query="GetRenewalInfo">
			<cfquery name="UpdateExpirationDate" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Update Listings
				Set ExpirationDate = 
				<cfif ListingTypeID is 10 and Len(Deadline)>
					<!--- Set to earliest of the deadline or the term-based expiration date --->
					<cfif CurrentDate gt ExpirationDate>
						CASE WHEN DateAdd(day, #TermExpiration#, GetDate()) > Deadline THEN Deadline ELSE DateAdd(day, #TermExpiration#, GetDate()) END
					<cfelse>
						CASE WHEN DateAdd(day, #TermExpiration#, ExpirationDate) > Deadline THEN Deadline ELSE DateAdd(day, #TermExpiration#, ExpirationDate) END
					</cfif>
				<cfelse>
					<cfif CurrentDate gt ExpirationDate>
						DateAdd(day, #TermExpiration#, GetDate())
					<cfelse>
						DateAdd(day, #TermExpiration#, ExpirationDate)
					</cfif>
				</cfif>
				<cfif IncludesExpandedListing>
					, ExpirationDateELP=
					<cfif CurrentDate gt ExpirationDateELP>
						DateAdd(day, #TermExpiration#, GetDate())
					<cfelse>
						DateAdd(day, #TermExpiration#, ExpirationDateELP)
					</cfif>
				</cfif>
				Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfoutput>
		
		<!--- Loop through any listings in this order that were for an Expanded Listing being added to an existing listing --->
		<cfquery name="GetExpandedListingInfo" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select L.ListingID, L.ExpandedListingOrderID, L.ListingTypeID, L.Deadline,
			LT.TermExpiration
			From Listings L
			Inner Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
			Where L.ExpandedListingOrderID = <cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER">
			and L.OrderID <> L.ExpandedListingOrderID
			and L.ExpandedListingExpirationDateUpdated_Fl=0
		</cfquery>
		<cfoutput query="GetExpandedListingInfo">
			<cfquery name="UpdateExpirationDate" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Update Listings
				Set ExpirationDate = 
				<cfif ListingTypeID is 10 and Len(Deadline)>
					CASE WHEN DateAdd(day, #TermExpiration#, GetDate()) > Deadline THEN Deadline ELSE DateAdd(day, #TermExpiration#, GetDate()) END,
				<cfelse>
					DateAdd(day, #TermExpiration#, GetDate()),
				</cfif>
				ExpirationDateELP=				
				<cfif ListingTypeID is 10 and Len(Deadline)>
					CASE WHEN DateAdd(day, #TermExpiration#, GetDate()) > Deadline THEN Deadline ELSE DateAdd(day, #TermExpiration#, GetDate()) END,
				<cfelse>
					DateAdd(day, #TermExpiration#, GetDate()),
				</cfif>
				ExpandedListingExpirationDateUpdated_Fl=1
				Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfoutput>		
		
		<!--- Loop through any listing packages in this order that don't yet have an expiration date --->
		<cfquery name="GetListingsPackages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select LP.ListingPackageID
			From ListingPackages LP
			Where LP.OrderID = <cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER">
			and LP.ExpirationDate is null
		</cfquery>
		<cfoutput query="GetListingsPackages">
			<cfquery name="UpdateExpirationDate" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Update ListingPackages
				Set ExpirationDate = 
				<cfif Prelaunch>
					<cfqueryparam value="04/01/2010" cfsqltype="CF_SQL_DATE">
				<cfelse>
					DateAdd(day, 365, GetDate())
				</cfif>
				Where ListingPackageID = <cfqueryparam value="#ListingPackageID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfoutput>		
		
		<!--- Loop through any listings in this order that are Reviewed but don't yet have an expiration date --->
		<cfquery name="GetReviewedListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select L.ListingID, L.ListingTypeID, L.Deadline, 
			CASE WHEN (L.ExpandedListingPDF IS NULL OR
            L.ExpandedListingPDF = '') AND L.ExpandedListingHTML IS NULL THEN 0 ELSE 1 END AS HasExpandedListing,
			LT.TermExpiration
			From Listings L
			Inner Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
			Where L.OrderID = <cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER">
			and L.ExpirationDate is null
			and Reviewed = 1
		</cfquery>
		<cfoutput query="GetReviewedListings">
			<cfquery name="UpdateExpirationDate" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Update Listings
				Set ExpirationDate = 
				<cfif ListingTypeID is 10 and Len(Deadline)>
					CASE WHEN DateAdd(day, #TermExpiration#, GetDate()) > Deadline THEN Deadline ELSE DateAdd(day, #TermExpiration#, GetDate()) END
				<cfelse>
					DateAdd(day, #TermExpiration#, GetDate())
				</cfif>		
				<cfif ListFind("1,2,9,14,15",ListingTypeID) and HasExpandedListing>
					, ExpirationDateELP = DateAdd(day, #TermExpiration#, GetDate())
				</cfif>		
				Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfoutput>		
		
		<!--- Loop through any BUS1, BUS2, COM, EVE or TTT listings in this order that are Reviewed and have an ELP but don't yet have an ELP expiration date --->
		<cfquery name="GetReviewedListingsELP" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select L.ListingID, 
			CASE WHEN (L.ExpandedListingPDF IS NULL OR
            L.ExpandedListingPDF = '') AND L.ExpandedListingHTML IS NULL THEN 0 ELSE 1 END AS HasExpandedListing,
			LT.TermExpiration
			From Listings L
			Inner Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
			Where L.OrderID = <cfqueryparam value="#OrderID#" cfsqltype="CF_SQL_INTEGER">
			and L.ExpirationDateELP is null
			and L.Reviewed = 1
			and L.ListingTypeID in (1,2,9,14,15)
			<cfif GetReviewedListings.RecordCount>
				and L.ListingID not in (#ValueList(getReviewedListings.ListingID)#)
			</cfif>
		</cfquery>
		<cfoutput query="GetReviewedListingsELP">
			<cfif HasExpandedListing>
				<cfquery name="UpdateExpirationDateELP" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					Update Listings
					Set ExpirationDateELP =  DateAdd(day, #TermExpiration#, GetDate())
					Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
			</cfif>
		</cfoutput>		
		
	</cfif>
<cfelseif Len(ListingID)><!--- Listing being updated in Listing Admin pages --->
	<cfquery name="GetExpDateInfo" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ExpirationDate, L.Reviewed, L.ListingTypeID, L.Deadline, 
		CASE WHEN (L.ExpandedListingPDF IS NULL OR
        	L.ExpandedListingPDF = '') AND L.ExpandedListingHTML IS NULL THEN 0 ELSE 1 END AS HasExpandedListing,
		O.PaymentStatusID,
		LT.TermExpiration
		From Listings L
		Inner Join Orders O on L.OrderID=O.OrderID
		Inner Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
		Where L.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif GetExpDateInfo.RecordCount and GetExpDateInfo.Reviewed and (ListFind("1,2,9,14,15",GetExpDateInfo.ListingTypeID) or ListFind("2,3,4",GetExpDateInfo.PaymentStatusID))>
		<cfif not Len(GetExpDateInfo.ExpirationDate)>
			<cfquery name="UpdateExpirationDate" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Update Listings 
				Set ExpirationDate = 
				<cfif GetExpDateInfo.ListingTypeID is 10 and Len(GetExpDateInfo.Deadline)>
					CASE WHEN DateAdd(day, #GetExpDateInfo.TermExpiration#, GetDate()) > Deadline THEN Deadline ELSE DateAdd(day, #GetExpDateInfo.TermExpiration#, GetDate()) END
				<cfelse>
					DateAdd(day, #GetExpDateInfo.TermExpiration#, GetDate())
				</cfif>	
				<cfif ListFind("1,2,9,14,15",GetExpDateInfo.ListingTypeID) and GetExpDateInfo.HasExpandedListing and ListFind("2,3,4",getExpDateInfo.PaymentStatusID)>
					, ExpirationDateELP = DateAdd(day, #GetExpDateInfo.TermExpiration#, GetDate())
				</cfif>			
				Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		<cfelseif GetExpDateInfo.ListingTypeID is 10 and Len(GetExpDateInfo.Deadline)><!--- Admin user may have updated the Deadline on a listing that already has an exp date --->
			<cfquery name="UpdateExpirationDate" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Update Listings 
				Set ExpirationDate = 
				CASE WHEN DateAdd(day, #GetExpDateInfo.TermExpiration#, GetDate()) > Deadline THEN Deadline ELSE DateAdd(day, #GetExpDateInfo.TermExpiration#, GetDate()) END		
				Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfif>
	</cfif>
</cfif>

 
