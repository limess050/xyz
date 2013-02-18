
<cfquery name="getMyCartListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select L.ListingID, L.LinkID, 
	IsNull(L.ListingFee,0) as ListingFee, IsNull(L.ExpandedListingFee,0) as ExpandedFee, 
	L.ListingTitle, L.ShortDescr,
	L.ExpirationDate, L.ListingTypeID,
	L.Make as MakeOther, L.Model as ModelOther, L.VehicleYear, L.ExpandedListingPDF, L.ExpandedListingHTML,
	PS.ParentSectionID, PS.Title as ParentSection, S.SectionID, S.Title as Section, 
	(Select Top 1 C.CategoryID From ListingCategories LC Inner Join Categories C on LC.CategoryID=C.CategoryID Where LC.ListingID=L.ListingID Order By C.OrderNum) as CategoryID, (Select Top 1 C.Title From ListingCategories LC Inner Join Categories C on LC.CategoryID=C.CategoryID Where LC.ListingID=L.ListingID Order By C.OrderNum) as  Category,
	LT.TermExpiration,
	M.Title as Make, 
	IsNull(L.ListingFee,0) + IsNull(L.ExpandedListingFee,0) as TotalFee
	From ListingsView L
	Inner Join ListingParentSections LPS on L.ListingID=LPS.ListingID
	Inner Join ParentSectionsView PS On LPS.ParentSectionID=PS.ParentSectionID
	Inner Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
	Left Outer Join ListingSections LS on L.ListingID=LS.ListingID
	Left Outer Join SectionsView S on LS.SectionID=S.SectionID
	Left Outer Join Makes M on L.MakeID=M.MakeID
	Where L.InProgressUserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
	and L.OrderID is null 
	and L.InProgress=1
	Order By TotalFee desc
</cfquery>

<cfset HasHAndRListingsInCart="0">
<cfset HasVListingsInCart="0">
<cfset HasJRListingsInCart="0">

<cfset ListingsInCart=getMyCartListings.RecordCount>
<cfset FeesInCart="0">
<cfoutput query="getMyCartListings">
	<cfif Len(TotalFee)>
		<cfset FeesInCart=FeesInCart+TotalFee>
	</cfif>
	<cfif ListFind("5",ParentSectionID) and ListFind("6,7,8",ListingTypeID)>
		<cfset HasHAndRListingsInCart="1">
	</cfif>
	<cfif ListFind("4",ParentSectionID) and ListFind("84,85,86",CategoryID)>
		<cfset HasVListingsInCart="1">
	</cfif>
	<cfif ListFind("10",ListingTypeID)>
		<cfset HasJRListingsInCart="1">
	</cfif>
</cfoutput>

