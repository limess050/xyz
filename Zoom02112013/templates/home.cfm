<!---
Home page template
Use this if the home page is different from the default template
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfset HPAccordion="1">

<cfset ContentStyle="content">

<cfinclude template="header.cfm">

<cfquery name="insertHPImpression" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">	
	Insert into Impressions
	(HomePage)
	Values 
	(1)
</cfquery>

<!--- <lh:MS_SitePagePart id="title" class="title">
<lh:MS_SitePagePart id="body" class="body"> --->


<!-- RIGHT COLUMN -->
<div id="hp-content">

<cfoutput>
 <div id="internalad1"><lh:MS_SitePagePart id="body" class="body"></div> <h1>Browse Listings</h1>
</cfoutput>
<!-- LOCAL BUSINESSES -->
<div id="accordionHP">
	<cfoutput query="Sections">
	<!--- <h3> --->
	<div class="hpcontent<cfif CurrentRow is "1"> toppadd</cfif>">
	  <div class="hpcontentlink">
	  	<cfif Request.lh_useFriendlyUrls>
			<a href="<cfif ParentSectionID is "59">CalInDAR<cfelse>#ParentSectionURLSafeTitle#</cfif>">
		<cfelse>
			<a href="<cfif ParentSectionID is "59">#lh_getPageLink(Request.SearchEventsPageID,'CalInDAR')#<cfelse>#lh_getPageLink(Request.SectionOverviewPageID,'sectionoverview')##AmpOrQuestion#ParentSectionID=#ParentSectionID#</cfif>">
		</cfif>#Title#</a></div>
	  <div class="hpcontenticon">
	  	<cfif Request.lh_useFriendlyUrls>
			<a href="<cfif ParentSectionID is "59">CalInDAR<cfelse>#ParentSectionURLSafeTitle#</cfif>">
		<cfelse>
			<a href="<cfif ParentSectionID is "59">#lh_getPageLink(Request.SearchEventsPageID,'CalInDAR')#<cfelse>#lh_getPageLink(Request.SectionOverviewPageID,'sectionoverview')##AmpOrQuestion#ParentSectionID=#ParentSectionID#</cfif>">
		</cfif>
		<img src="images/sitewide/icon.plusgreen.png" width="22" height="21" alt="Click to Expand" /></a></div>	
	</div>	 
	  <div class="hpcategory">#Descr#</div>
	<!--- </h3> --->

	
	<!--- <div>
		<cfinclude template="../includes/GetSectionLinksTable.cfm">
	</div> --->


	</cfoutput>

</div>
</div>
<div id="clear"></div>
</div>


<cfset ShowRightColumn="0">
<cfinclude template="footer.cfm">
</div>
</div>



