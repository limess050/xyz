<!--- This page shows all the events for a given date. --->

<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfif not IsDefined('application.SectionImpressions')>
	<cfset application.SectionImpressions= structNew()>
</cfif>
<cfif StructKeyExists(application.SectionImpressions,59)>
	<cfset application.SectionImpressions[59] = application.SectionImpressions[59] + 1>
<cfelse>
	<cfset application.SectionImpressions[59] = 1>
</cfif>
<cfset ImpressionSectionID = 59>

<cfinclude template="header.cfm">

<!--- <cfoutput>#Request.Page.GetCookieCrumb()#</cfoutput><br>
<cfoutput>#Request.Page.GetSectionName()#</cfoutput> --->

<!--- <lh:MS_SitePagePart id="title" class="title">
<lh:MS_SitePagePart id="body" class="body">

 --->

<cfparam name="startDate" default="#Now()#">
<cfparam name="endDate" default="#Now()#">

<cfoutput>
<div class="centercol-inner legacy">
 <div id="internalad2"><a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=46">Post an Event Here</a></div> <h1>Browse Listings</h1>
<cfmodule template="../includes/HelpfulHints.cfm" CategoryID="" SectionID="" ParentSectionID="46">
<cfmodule template="../includes/HelpfulHints.cfm" CategoryID="" SectionID="" ParentSectionID="46" HintTypeID="2">


 <!--- <div class="breadcrumb""><a href="##">Home</a> &gt; <!--- <a href="##">#getListings.ParentSection#</a> &gt; <a href="##">#getListings.SubSection#</a> &gt; <span class="bluelarge">#getListings.Category#</span> ---></div> --->
<p><br /></p>
</cfoutput>

<lh:MS_SitePagePart id="body" class="body">

<cfquery name="getUpcomingEvents"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	select l.listingID, l.eventStartDate, l.title, ld.ListingEventDate, L.ListingTitle, L.LocationOther,
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ# Then 1 Else 0 END as HasExpandedListing
	from ListingsView l
	inner join ListingEventDays ld on ld.listingID = l.listingID
	where l.listingTypeID = 15
	and l.DeletedAfterSubmitted=0 and L.Active=1 and L.Reviewed=1 
	and (L.ListingTypeID IN (15) <!--- or L.ExpirationDate >= #application.CurrentDateInTZ# --->)
	and ld.ListingEventDate >= <cfqueryparam value="#DateFormat(startDate,'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE">
	AND ld.ListingEventDate <= <cfqueryparam value="#DateFormat(endDate,'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE">	
	Order By ld.ListingEventDate ASC					
</cfquery>
<cfif getUpcomingEvents.recordcount>
	<cfoutput query="getUpcomingEvents" group="ListingEventDate">
		<cfquery name="GetLocationTitles"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select L.Title as Location
			From ListingLocations LL
			Inner Join Locations L on LL.LocationID=L.LocationID
			Where LL.ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			and L.LocationID <> 4
			Order by L.Title
		</cfquery>	
		<cfset LocationTitles=ValueList(getLocationTitles.Location)>
		<cfset LocationOutput="">
		<cfset LocationOutput=LocationTitles>
		<cfif Len(LocationOther)>
			<cfset LocationOutput=ListAppend(LocationOutput,LocationOther)>
		</cfif>
		<cfset LocationOutput=Replace(LocationOutput,",",", ","ALL")>
		<p><strong>#DateFormat(ListingEventDate,"mmmm d, yyyy")#</strong><br>&nbsp;<br />
		<cfoutput>
   		<p><cfif HasExpandedListing><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#">#ListingTitle#</a><cfif Len(LocationOutput)> - #LocationOutput#</cfif></cfif></p><br />
		</cfoutput>
		</p>
	</cfoutput>
<cfelse>
	<p>There are no events to display.</p>
</cfif>

</div>

<!-- END CENTER COL -->

<cfinclude template="footer.cfm">
