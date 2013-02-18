<cfset createObject("component","CFC.Limiter").limiter()>
<cfparam name="Preview" default="0">
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfif not edit and Not IsDefined('ListingID')>
	<cfinclude template="header.cfm">
	<div class="centercol-inner legacy">
	<p class="STATUSMESSAGE">No Listing passed.</p>
	</div>
	<cfinclude template="footer.cfm">
	<cfabort>
<cfelseif edit>
	<cfset ListingID="1">
</cfif>

<cfif IsDefined('session.UserID') and Len(session.UserID)>
	<cfquery name="checkAdmin" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select AdminUser
		From LH_Users
		Where UserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
</cfif>

<cfquery name="getListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select L.ListingID, 
	L.ListingTitle, 
	L.ListingTypeID, L.ListingType, L.ExpandedListingPDF,
	LC.CategoryID, C.Title as Category,
	PS.ParentSectionID, PS.Title as ParentSection,
	S.SectionID, S.Title as SubSection,
	CASE WHEN L.ExpirationDate >= #application.CurrentDateInTZ# THEN 0 ELSE 1 END as ListingExpired
	From ListingsView L With (NoLock)
	Inner Join ListingCategories LC With (NoLock) on L.ListingID=LC.ListingID 
	Inner Join Categories C With (NoLock) on LC.CategoryID=C.CategoryID 
	Inner Join ParentSectionsView PS With (NoLock) on C.ParentSectionID=PS.ParentSectionID
	Left Outer Join Sections S With (NoLock) on C.SectionID=S.SectionID
	Where L.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
	and L.DeletedAfterSubmitted=0
	<cfif Preview>
		<cfif IsDefined('session.UserID') and Len(session.UserID) and not checkAdmin.AdminUser>
			and (L.InProgressUserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
				or L.UserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">)
		</cfif>
	<cfelse>
		and L.Active=1 and L.Reviewed=1 
		and (L.ListingTypeID IN (1,2,14,15) or (<!--- L.ExpirationDate >= #application.CurrentDateInTZ# and  --->L.PaymentStatusID in (2,3)))
	</cfif>
	and (L.Deadline is null or L.Deadline >= <cfqueryparam value="#application.CurrentDateInTZ#" cfsqltype="CF_SQL_date">)
	and PS.Active=1	
</cfquery>

<cfif getListing.ListingTypeID is "15">
	<cfset ShowBannerAds = "1">
</cfif>


<cfif not getListing.RecordCount>
	<cfinclude template="header.cfm">
	<!-- CENTER COL -->
	<div class="centercol-inner legacy">
	<p class="STATUSMESSAGE">Listing not found</p>
	
	<cfif edit>
		<lh:MS_SitePagePart id="body" class="body">
	</cfif>
	</div>
	<cfset ShowHintsAndRelLinks="0">
	<cfinclude template="footer.cfm">
	<cfabort>
</cfif>

<cfset ImpressionSectionID=getListing.ParentSectionID>

<cfset UseImageController = "0">
<cfinclude template="headerPlain.cfm">

<cfset CategoryID=getListing.CategoryID>

<cfif not Preview>
	<cfif not IsDefined('application.SectionImpressions')>
		<cfset application.SectionImpressions= structNew()>
	</cfif>
	<cfif StructKeyExists(application.SectionImpressions,getListing.ParentSectionID)>
		<cfset application.SectionImpressions[getListing.ParentSectionID] = application.SectionImpressions[getListing.ParentSectionID] + 1>
	<cfelse>
		<cfset application.SectionImpressions[getListing.ParentSectionID] = 1>
	</cfif>
	
	<cfif not IsDefined('application.CategoryImpressions')>
		<cfset application.CategoryImpressions= structNew()>
	</cfif>
	<cfif StructKeyExists(application.CategoryImpressions,CategoryID)>
		<cfset application.CategoryImpressions[CategoryID] = application.CategoryImpressions[CategoryID] + 1>
	<cfelse>
		<cfset application.CategoryImpressions[CategoryID] = 1>
	</cfif>
	
	<cfif not IsDefined('application.ListingImpressions')>
		<cfset application.ListingImpressions= structNew()>
	</cfif>
	<cfif StructKeyExists(application.ListingImpressions,ListingID)>
		<cfset application.ListingImpressions[ListingID] = application.ListingImpressions[ListingID] + 1>
	<cfelse>
		<cfset application.ListingImpressions[ListingID] = 1>
	</cfif>
</cfif>

<cfoutput>
<!--- <div class="centercol-inner legacy">
<div class="PTWrapper">

	<h1>#ListingTitleForH1#</h1>
</div> --->

</cfoutput>
<cfif getListing.RecordCount>
	<cfif not ListFind("1,2,14,15",getListing.ListingTypeID) and getListing.ListingExpired and not Preview>
		<cfoutput>
			<p>&nbsp;</p>
			<p class="greenlarge">#ListingTitleForH1#</p>
			<p>The listing you are attempting to view is expired. Please see other listings like it&nbsp;in&nbsp;>&nbsp;<a href="<cfif AmpOrQuestion is "?">#getListing.CategoryURLSafeTitle#<cfif JETID is "2">CVs</cfif><cfelse>#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#GetListing.CategoryID#<cfif Len(JETID)>&JETID=#JETID#</cfif></cfif>">#getListing.Category#</a>.
		</cfoutput>
	<cfelse>
		<cfif IsDefined('StatusMessage')>
			<p class="Important"><br><cfoutput>#StatusMessage#</cfoutput></p>
		</cfif>
		<div style="width: 1020px;margin: 0 auto">
			<cfoutput><img src="/ListingUploadedDocs/#getListing.ExpandedListingPDF#"></cfoutput>
		</div>
		<p>&nbsp;</p>		
	</cfif>
<cfelse>
	<p><br /></p>
	<p class="greenlarge">No current listing found.</p>
</cfif>

</div>

<!-- END CENTER COL -->
<cfoutput>

<cfset useCustomTracker="1">

<cfinclude template="footerPlain.cfm">

<cfif (Request.environment is "LIVE" or Request.environment is "Devel") and not edit>
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("<cfif Request.environment is "Live">UA-15419468-1<cfelse>UA-15419468-2</cfif>");
pageTracker._setCustomVar(1,"Category","#getListing.Category#",3 );
pageTracker._setCustomVar(2,"Section","#getListing.ParentSection#",3 );
pageTracker._setCustomVar(3,"SubSection","#getListing.SubSection#",3 );
pageTracker._setCustomVar(4,"ListingType","#getListing.ListingType#",3);
pageTracker._setCustomVar(4,"Listing","#getListing.ListingID# - #getListing.ListingTitle#",3 );
pageTracker._trackPageview();
} catch(err) {}</script>
</cfif>
</cfoutput>