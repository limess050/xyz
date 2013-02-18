<cfparam name="AllowHAndR" default="0">
<cfparam name="AllowVehicle" default="0">
<cfparam name="AllowJobRecruiter" default="0">
<cfparam name="AllowTravel" default="0">
<cfparam name="AllowJAndEProfEmplOpp" default="0">

<cfquery name="getMyListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select L.ListingID, L.LinkID, L.Inprogress,
	IsNull(L.ListingFee,0) as ListingFee, IsNull(L.ExpandedListingFee,0) as ExpandedFee, 
	L.ListingTitle, L.ExpirationDate, L.ListingTypeID, L.Reviewed,
	L.Make as MakeOther, L.Model as ModelOther, L.VehicleYear, L.ExpandedListingPDF, L.ExpandedListingHTML,
	CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ# Then 1 Else 0 END as HasExpandedListing,
	O.PaymentStatusID, O.OrderID,
	PSt.Title as PaymentStatus,
	PS.Title as ParentSection, PS.ParentSectionID, S.SectionID, S.Title as Section,  
	(Select Top 1 C.CategoryID From ListingCategories LC Inner Join Categories C on LC.CategoryID=C.CategoryID Where LC.ListingID=L.ListingID Order By C.OrderNum) as CategoryID, (Select Top 1 C.Title From ListingCategories LC Inner Join Categories C on LC.CategoryID=C.CategoryID Where LC.ListingID=L.ListingID Order By C.OrderNum) as  Category,
	LT.TermExpiration,
	M.Title as Make, 
	IsNull(L.ListingFee,0) + IsNull(L.ExpandedListingFee,0) as TotalFee
	From ListingsView L
	Left Outer Join Orders O on L.OrderID=O.OrderID
	Left Outer Join PaymentStatuses PSt on O.PaymentStatusID=PSt.PaymentStatusID
	Inner Join ListingParentSections LPS on L.ListingID=LPS.ListingID
	Inner Join ParentSectionsView PS On LPS.ParentSectionID=PS.ParentSectionID
	Inner Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
	Left Outer Join ListingSections LS on L.ListingID=LS.ListingID
	Left Outer Join SectionsView S on LS.SectionID=S.SectionID
	Left Outer Join Makes M on L.MakeID=M.MakeID
	Where L.DeletedAfterSubmitted=0 
	and  O.UserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
	Order By PS.OrderNum, O.OrderDate desc, L.ListingID
</cfquery>


<cfoutput query="getMyListings">
	<!--- Allow permission if listing exists that is either submitted but not yet reviewed or current --->
	<cfif InProgress is "0" and (not Len(ExpirationDate) or DateCompare(Now(),ExpirationDate,"d") neq "1")>
		<cfif ListingTypeID is "1" and SectionID is "36" and HasExpandedListing>
			<cfset AllowTravel="1">
		</cfif>		
		<cfif ListingTypeID is "1" and ParentSectionID is "5">
			<cfset AllowHAndR="1">
		</cfif>
		<cfif ListingTypeID is "1" and SectionID is "28">
			<cfset AllowVehicle="1">
		</cfif>
		<cfif ListingTypeID is "1" and CategoryID is "133">
			<cfset AllowJobRecruiter="1">
		</cfif>
		<cfif ListFind("1,2,14",ListingTypeID)>
			<cfset AllowJAndEProfEmplOpp="1">
		</cfif>
	</cfif>
</cfoutput>




