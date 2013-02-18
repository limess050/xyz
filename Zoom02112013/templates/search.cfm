<!---
Site Search Template
Shows a search screen for site-wide search.
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfparam name="SearchString" default="">

<cfif IsDefined('ParentSectionID') and ParentSectionID is "59">
	<cflocation url="searchEvents?SearchKeyword=#SearchString#">
	<cfabort>
</cfif>


<cfinclude template="GoogleSearch.cfm">
<cfabort>
<cfif IsDefined('SearchByID')>
	<cfinclude template="searchByID.cfm">
	<cfabort>
</cfif>

<cfquery name="getImpressionSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SectionID
	From PageSections
	Where PageID = <cfqueryparam value="#PageID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfset ImpressionSectionID=getImpressionSection.SectionID>
<cfif not Len(ImpressionSectionID)>
	<cfset ImpressionSectionID = 0>
</cfif>

<cfif not IsDefined('application.SectionImpressions')>
	<cfset application.SectionImpressions= structNew()>
</cfif>
<cfif StructKeyExists(application.SectionImpressions,ImpressionSectionID)>
	<cfset application.SectionImpressions[ImpressionSectionID] = application.SectionImpressions[ImpressionSectionID] + 1>
<cfelse>
	<cfset application.SectionImpressions[ImpressionSectionID] = 1>
</cfif>

<cfinclude template="header.cfm">

<cfif IsDefined('searchString') and Len(searchString)>
	<cfquery name="getListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">		
		Select L.ListingID, L.ListingTypeID, L.ListingTitle, L.ShortDescr, L.DateListed, L.PriceUS, L.PriceTZS,
		L.RentUS, L.RentTZS, L.Bedrooms, L.Bathrooms, L.AmenityOther, L.LocationOther, L.LocationText,
		L.LongDescr, L.MakeID,
		L.Make as MakeOther, L.Model, L.Model as ModelOther, L.VehicleYear, L.Kilometers, L.FourWheelDrive,
		L.Deadline, L.WebsiteURL, L.PublicPhone,  L.PublicPhone2,  L.PublicPhone3,  L.PublicPhone4, L.PublicEmail, 
		L.EventStartDate, L.EventEndDate, L.RecurrenceID, L.RecurrenceMonthID,
		L.ExpandedListingHTML, L.ExpandedListingPDF,
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ# Then 1 Else 0 END as HasExpandedListing,
		L.CuisineOther, L.AccountName,
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ# Then 1 Else 0 END as HasExpandedListing,
		L.SquareFeet, L.SquareMeters,
		L.LogoImage, L.ELPTypeThumbnailImage, L.ELPThumbnailFromDoc,
		M.Title as Make, T.Title as Transmission,
		Te.Title as Term, 
		CASE WHEN L.ListingTypeID in (3,4,5,6,7,8) Then ((Select Top 1 FileName
			From ListingImages
			Where ListingID=L.ListingID
			Order By OrderNum, ListingImageID))
		ELSE null END as FileNameForTN,
		CASE WHEN L.UserID = <cfqueryparam value="#Request.PhoneOnlyUserID#" cfsqltype="CF_SQL_INTEGER"> THEN 1 ELSE 0 END as PhoneOnlyListing_fl,
		KEY_TBL.RANK
		FROM ListingsView L 
		Left Outer Join Makes M on L.MakeID=M.MakeID
		Left Outer Join Transmissions T on L.TransmissionID=T.TransmissionID
		Left outer Join Terms Te on L.TermID=Te.TermID
     	INNER JOIN FREETEXTTABLE(Listings, *, <cfqueryparam value="#SearchString#" cfsqltype="CF_SQL_VARCHAR">) AS KEY_TBL ON KEY_TBL.[KEY] = L.ListingID
		Where 
		L.DeletedAfterSubmitted=0
		and L.Active=1 and L.Reviewed=1 
		and (L.ListingTypeID IN (1,2,14,15) or (L.ExpirationDate >= #application.CurrentDateInTZ# and L.PaymentStatusID in (2,3)))
		and (L.Deadline is null or L.Deadline >= #application.CurrentDateInTZ#)
		<cfif Len(ParentSectionID)>
			and
			(Exists (Select LS.ListingID From ListingSections LS Where LS.SectionID in (<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER" list="Yes">) and LS.ListingID=L.ListingID)
			or exists (Select ListingID from ListingParentSections LPS Where LPS.ParentSectionID in (<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER" list="Yes">) and LPS.ListingID=L.ListingID))
		</cfif>
		ORDER BY KEY_TBL.RANK DESC
	</cfquery>
</cfif>

<cfoutput>
<div class="centercol-inner legacy">
<h1>Search Listings</h1>
<p><br />
</p>

 <div class="breadcrumb""><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/">Home</a> &gt; <span class="bluelarge">Search</span></div>

</cfoutput>
<div>&nbsp;</div>
<lh:MS_SitePagePart id="body" class="body">
<cfif edit>
	<p>Search results appear here when a front end user searches the site.
<cfelseif Len(SearchString)>	
	<cfoutput>
		Your search on '<strong><em>#HTMLEditFormat(SearchString)#</em></strong>' found <strong>#getListings.RecordCount#</strong> result<cfif getListings.RecordCount neq "1">s</cfif>.<br>
	</cfoutput>
	<cfset PaginationPageLink="#lh_getPageLink(4,'search')##AmpOrQuestion#searchString=#URLEncodedFormat(SearchString)#&ParentSectionID=#ParentSectionID#">
	<cfset showDividers="0">
	<cfinclude template="../includes/ListingsResultsTable.cfm">	
</cfif>
</div>


<cfinclude template="footer.cfm">