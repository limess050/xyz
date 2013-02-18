<cfquery name="getMyRenewalCartListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select L.ListingID, L.LinkID, 
	CASE WHEN LT.AllowFreeRenewal=1 THEN 0 ELSE IsNull(LT.BasicFee,0) END as ListingFee, 
	IsNull(LT.ExpandedFee,0) as ExpandedFee, 
	L.ListingTitle, L.ShortDescr, L.ExpirationDate, L.ListingTypeID,
	L.Make as MakeOther, L.Model as ModelOther, L.VehicleYear, L.ExpandedListingPDF, L.ExpandedListingHTML,
	PS.ParentSectionID, PS.Title as ParentSection, S.SectionID, S.Title as Section, 
	(Select Top 1 C.CategoryID From ListingCategories LC Inner Join Categories C on LC.CategoryID=C.CategoryID Where LC.ListingID=L.ListingID Order By C.OrderNum) as CategoryID, (Select Top 1 C.Title From ListingCategories LC Inner Join Categories C on LC.CategoryID=C.CategoryID Where LC.ListingID=L.ListingID Order By C.OrderNum) as  Category,
	LT.TermExpiration,
	M.Title as Make,
	CASE WHEN L.ExpandedListingHTML is null and L.ExpandedListingPDF is null  and LT.AllowFreeRenewal=0 THEN IsNull(LT.BasicFee,0)
	WHEN L.ExpandedListingHTML is null and L.ExpandedListingPDF is null  and LT.AllowFreeRenewal=1 THEN 0
	WHEN LT.AllowFreeRenewal=0 THEN IsNull(LT.BasicFee,0) + IsNull(LT.ExpandedFee,0)
	ELSE IsNull(LT.ExpandedFee,0) END as TotalFee
	From ListingsView L
	Inner Join ListingParentSections LPS on L.ListingID=LPS.ListingID
	Inner Join ParentSectionsView PS On LPS.ParentSectionID=PS.ParentSectionID
	Inner Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
	Left Outer Join ListingSections LS on L.ListingID=LS.ListingID
	Left Outer Join SectionsView S on LS.SectionID=S.SectionID
	Left Outer Join Makes M on L.MakeID=M.MakeID
	Where L.ListingID 	<cfif Len(ListingIDs)>
							in (<cfqueryparam value="#ListingIDs#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
						<cfelse><!--- When being viewed in CMS editor. --->
							= 0
						</cfif>
</cfquery>

<cfset HasHAndRListingsInCart="0">
<cfset HasVListingsInCart="0">
<cfset HasJRListingsInCart="0">

<cfset ListingsInCart=getMyRenewalCartListings.RecordCount>
<cfset FeesInCart="0">
<cfoutput query="getMyRenewalCartListings">
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

