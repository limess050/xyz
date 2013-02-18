<!--- This template runs whenever a Listing is updated, to keep the ListingHeaderTitle, ListingTitleForH1 and ListingMetaDescr up to date. This allows for searching on these fields. 
Previously, these values were parsed on the fly for use in the templates, but the need to search over them caused them to be moved to the database. --->

<cfset allFields="ListingID">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="ListingID">

<cfif Len(ListingID)>
	<cfquery name="getListingInfo" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select L.ListingTitle, L.ShortDescr, Lo.Title as Location, Lo.LocationID,
		L.ListingTypeID, C.CategoryID, C.Title as Category
		From ListingsView L With (NoLock)
		Left Outer Join ListingLocations LL With (NoLock) on L.ListingID=LL.ListingID
		Left Outer Join Locations Lo With (NoLock) on LL.LocationID=Lo.LocationID
		Inner Join ListingCategories LC With (NoLock) on L.ListingID=LC.ListingID
		Inner Join Categories C With (NoLock) on LC.CategoryID=C.CategoryID
		Where L.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		Order by Lo.OrderNum
	</cfquery>
	<cfset ListingHeaderTitle=getListingInfo.ListingTitle>
	<cfset ListingTitleForH1=getListingInfo.ListingTitle>
	<cfswitch expression="#getListingInfo.ListingTypeID#">
		<cfcase value="1,2,14">
			<cfset ListingHeaderTitle=getListingInfo.ListingTitle & " in ">
		</cfcase>
		<cfcase value="3,4,5,8">
			<cfset ListingHeaderTitle=getListingInfo.ListingTitle & " For Sale in ">
		</cfcase>
		<cfcase value="6,7">
			<cfset ListingHeaderTitle=getListingInfo.ListingTitle & " For Rent in ">
		</cfcase>
		<cfcase value="15">
			<cfset ListingHeaderTitle=getListingInfo.ListingTitle & " Event in ">
		</cfcase>
		<cfcase value="10,12">
			<cfset ListingHeaderTitle=getListingInfo.ShortDescr & " Job in ">
			<cfset ListingTitleForH1=getListingInfo.ShortDescr>
		</cfcase>
		<cfcase value="9">
			<cfif getListingInfo.CategoryID is "94">
				<cfset ListingHeaderTitle=getListingInfo.ListingTitle & " | Tanzania Cheap Flight Special ">
			<cfelse>
				<cfset ListingHeaderTitle=getListingInfo.ListingTitle & " Holiday Vacation in Tanzania ">
			</cfif>			
		</cfcase>
	</cfswitch>
	<cfquery name="getListingInfo2" dbtype="query">
		Select Distinct ListingTypeID, Location, LocationID
		From getListingInfo
	</cfquery>
	<cfset LocationCounter="1">
	<cfoutput query="getListingInfo2">
		<cfif Len(Location)>
			<cfif ListFind("1,2,3,4,5,6,7,8,10,12,14,15",ListingTypeID) and LocationCounter is "1">
				<cfset ListingHeaderTitle=ListingHeaderTitle & Location>
			<cfelse>
				<cfset ListingHeaderTitle=ListingHeaderTitle & ", " & Location>
			</cfif>		
			<cfset LocationCounter=LocationCounter+1>	
		</cfif>
	</cfoutput>
	<cfif ListFind("3,4,5,16",getListingInfo.ListingTypeID)>
		<cfset ListingHeaderTitle=ListingHeaderTitle & " Tanzania | Classified">
	<cfelseif not ListFind("9",getListingInfo.ListingTypeID)>
		<cfset ListingHeaderTitle=Application.Lighthouse.StripHtml(ListingHeaderTitle) & ", Tanzania">
	</cfif>
	
	<cfset ListingMetaDescr=ListingHeaderTitle>
	<cfif Len(getListingInfo.ShortDescr)>
		<cfset ListingMetaDescr=ListingMetaDescr & ". " & Application.Lighthouse.StripHtml(getListingInfo.ShortDescr)>
	</cfif>
	<cfquery name="updateListingHeaderTitle" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Update Listings
		Set ListingHeaderTitle = <cfqueryparam value="#ListingHeaderTitle#" cfsqltype="CF_SQL_VARCHAR">,
		ListingTitleForH1 = <cfqueryparam value="#ListingTitleForH1#" cfsqltype="CF_SQL_VARCHAR">,
		ListingMetaDescr = <cfqueryparam value="#ListingMetaDescr#" cfsqltype="CF_SQL_VARCHAR">
		Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
</cfif>

