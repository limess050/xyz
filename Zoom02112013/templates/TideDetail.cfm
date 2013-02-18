
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfset ShowRightColumn="0">

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

<script type="text/javascript" src="Lighthouse/Resources/js/lighthouse_all.js"></script>


<div class="centercol-inner-wide legacy legacy-wide">

<cfif edit>
	<p>Text to display on page.</p>
	<lh:MS_SitePagePart id="body" class="body">
	
<cfelse>
 	
			<lh:MS_SitePagePart id="body" class="body">
			<!--- Section and Category --->
			<p>&nbsp;</p>
			<cfinclude template="../includes/TidesLunarDetail.cfm">
		
</cfif>
</div>

<!-- END CENTER COL -->
<cfinclude template="footer.cfm">
