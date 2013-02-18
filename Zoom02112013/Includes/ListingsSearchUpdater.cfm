<!--- Update LinkedRecordsText column in Listings any time a listing is created or updated. This column is a roll-up of linked text values, etc, for use in a full text search. --->

<cfquery name="getT" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT L.ListingID, C.Title AS Category, S.Title AS Section, M.Title as Make,
		CASE WHEN L.FourWheelDrive = 1 THEN 'Four Wheel Drive' ELSE NULL END AS FourWheelDrive, 
		T.Title as Transmission, 
		Lo.Title AS Location, 
		A.Title AS Account
	FROM Listings AS L 
	LEFT OUTER JOIN ListingCategories AS LC ON L.ListingID = LC.ListingID 
   	LEFT OUTER JOIN Categories AS C ON LC.CategoryID = C.CategoryID 
   	LEFT OUTER JOIN Sections AS S ON C.SectionID = S.SectionID 
   	LEFT OUTER JOIN Locations AS Lo ON L.LocationID = Lo.LocationID 
   	LEFT OUTER JOIN Orders AS O ON L.OrderID = O.OrderID 
   	LEFT OUTER JOIN LH_Users AS A ON O.UserID = A.UserID
   	LEFT OUTER JOIN Makes M on L.MakeID=M.MakeID
   	LEFT OUTER JOIN Transmissions T on L.TransmissionID=T.TransmissionID
	Where L.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER" list="Yes">
</cfquery>
<cfset LinkedRecordsText="">
<cfif Len(getT.Category)>
	<cfset LinkedRecordsText=ListAppend(LinkedRecordsText,getT.Category)>
</cfif>
<cfif Len(getT.Section)>
	<cfset LinkedRecordsText=ListAppend(LinkedRecordsText,getT.Section)>
</cfif>
<cfif Len(getT.Make)>
	<cfset LinkedRecordsText=ListAppend(LinkedRecordsText,getT.Make)>
</cfif>
<cfif Len(getT.FourWheelDrive)>
	<cfset LinkedRecordsText=ListAppend(LinkedRecordsText,getT.FourWheelDrive)>
</cfif>
<cfif Len(getT.Transmission)>
	<cfset LinkedRecordsText=ListAppend(LinkedRecordsText,getT.Transmission)>
</cfif>
<cfif Len(getT.Location)>
	<cfset LinkedRecordsText=ListAppend(LinkedRecordsText,getT.Location)>
</cfif>
<cfif Len(getT.Account)>
	<cfset LinkedRecordsText=ListAppend(LinkedRecordsText,getT.Account)>
</cfif>
<cfquery name="getCuisines" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select C.Title
	From Cuisines C Inner join ListingCuisines LC on C.CuisineID=LC.CuisineID
	Where LC.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfif getCuisines.RecordCount>
	<cfset LinkedRecordsText=ListAppend(LinkedRecordsText,ValueList(getCuisines.Title))>
</cfif>
<cfquery name="getPriceRanges" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select PR.Title
	From PriceRanges PR Inner join ListingPriceRanges LPR on PR.PriceRangeID=LPR.PriceRangeID
	Where LPR.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfif getPriceRanges.RecordCount>
	<cfset LinkedRecordsText=ListAppend(LinkedRecordsText,ValueList(getPriceRanges.Title))>
</cfif>
<cfquery name="getNGOTypes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select NT.Title
	From NGOTypes NT Inner join ListingNGOTypes LNT on NT.NGOTypeID=LNT.NGOTypeID
	Where LNT.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfif getNGOTypes.RecordCount>
	<cfset LinkedRecordsText=ListAppend(LinkedRecordsText,ValueList(getNGOTypes.Title))>
</cfif>
<cfquery name="updateListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Update Listings
	Set LinkedRecordsText=<cfqueryparam value="#LinkedRecordsText#" cfsqltype="CF_SQL_VARCHAR">
	Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
