<!---
Site Search Template
Shows a search screen for site-wide search.
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfparam name="SearchString" default="">
<cfparam name="ParentSectionID" default="">

<cfif IsDefined('ParentSectionID') and ParentSectionID is "59">
	<cflocation url="searchEvents?SearchKeyword=#SearchString#">
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
		L.SquareFeet, L.SquareMeters,
		L.LogoImage, L.ELPTypeThumbnailImage, L.ELPThumbnailFromDoc,
		M.Title as Make, T.Title as Transmission,
		Te.Title as Term, 
		CASE WHEN L.ListingTypeID in (3,4,5,6,7,8) Then ((Select Top 1 FileName
			From ListingImages
			Where ListingID=L.ListingID
			Order By OrderNum, ListingImageID))
		ELSE null END as FileNameForTN,
		CASE WHEN L.UserID = <cfqueryparam value="#Request.PhoneOnlyUserID#" cfsqltype="CF_SQL_INTEGER"> THEN 1 ELSE 0 END as PhoneOnlyListing_fl
		FROM ListingsView L 
		Left Outer Join Makes M on L.MakeID=M.MakeID
		Left Outer Join Transmissions T on L.TransmissionID=T.TransmissionID
		Left outer Join Terms Te on L.TermID=Te.TermID
		Where L.ListingID like (<cfqueryparam value="%#SearchString#%" cfsqltype="CF_SQL_VARCHAR">) 
		<cfinclude template="../includes/LiveListingFilter.cfm">
		Order By L.ListingID
	</cfquery>
</cfif>

<cfoutput>
<div class="centercol-inner legacy">
<h1>Search By Listing ID</h1>
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
	<cfif getListings.RecordCount>
		<cfset PaginationPageLink="#lh_getPageLink(53,'search')##AmpOrQuestion#searchString=#URLEncodedFormat(SearchString)#&SearchByID=1">
		<cfset showDividers="0">
		<cfinclude template="../includes/ListingsResultsTable.cfm">	
	</cfif>
</cfif>
</div>


<cfinclude template="footer.cfm">