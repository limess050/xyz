<!--- Takes inputs of a CategoryID, SectionID and ParentSectionID and finds all Relevant Links associated with the most specific of those values (meaning Category before Section before ParentSection) and displays one of the matching links at random.
Three possible scenarios are possible:
- CategoryID, SectionID and ParentsectionID are passed (on any Category or Listing Detail page except for For Sale Classifieds)
- Category and ParentSectionID are passed (on Category or Listing Detail page for For Sale Classifieds)
- Only ParentSectionID is passed (on templates/ShowAllEvents.cfm or Section Landing pages) --->
<cfif not IsDefined('Edit') or Edit is "0">
	<cfif Len(Attributes.CategoryID)>
		<cfquery name="getRelevantLinks" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select distinct(R.RelevantLinkID), R.Descr
			From RelevantLinks R
			Where R.Active=1
			and (
			exists (Select RelevantLinkID From RelevantLinkCategories Where CategoryID=<cfqueryparam value="#Attributes.CategoryID#" cfsqltype="CF_SQL_INTEGER"> and RelevantLinkID=R.RelevantLinkID)
			<cfif Len(attributes.sectionID)>
				or
				exists (Select RelevantLinkID From RelevantLinkSections Where SectionID=<cfqueryparam value="#Attributes.SectionID#" cfsqltype="CF_SQL_INTEGER"> and RelevantLinkID=R.RelevantLinkID)
			</cfif>
			or 
			exists (Select RelevantLinkID From RelevantLinkParentSections Where ParentSectionID=<cfqueryparam value="#Attributes.ParentSectionID#" cfsqltype="CF_SQL_INTEGER"> and RelevantLinkID=R.RelevantLinkID)
						
			)
			Order by R.RelevantLinkID
		</cfquery>
	<cfelseif Len(Attributes.ParentSectionID)><!--- In templates/ShowAllEvents.cfm or templates/SectionOverview.cfm --->
		<cfquery name="getRelevantLinks" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select distinct(R.RelevantLinkID), R.Descr
			From RelevantLinks R
			Where R.Active=1
			and exists (Select RelevantLinkID From RelevantLinkParentSections Where ParentSectionID=<cfqueryparam value="#Attributes.ParentSectionID#" cfsqltype="CF_SQL_INTEGER"> and RelevantLinkID=R.RelevantLinkID)
			Order by R.RelevantLinkID
		</cfquery>
	</cfif>
	
	<cfif getRelevantLinks.RecordCount>	
			<!-- Relevant Links -->
			<div class="clear15"></div>
			<div class="promotitle">Helpful Links</div>
			<div class="promo-tideandlunar">
				<ul>				
					<cfoutput query="getRelevantLinks">
						<li <cfif CurrentRow is RecordCount>class="last"</cfif>>#Descr#</li>
					</cfoutput>
				</ul>
			</div>
	</cfif>
</cfif>
