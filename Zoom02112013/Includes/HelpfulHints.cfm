<!--- Takes inputs of a CategoryID, SectionID and ParentSectionID and finds all Hints associated with the most specific of those values (meaning Category before Section before ParentSection) and displays one of the matching hints at random.
Three possible scenarios are possible:
- CategoryID, SectionID and ParentsectionID are passed (on any Category or Listing Detail page except for For Sale Classifieds)
- Category and ParentSectionID are passed (on Category or Listing Detail page for For Sale Classifieds)
- Only ParentSectionID is passed (on templates/ShowAllEvents.cfm or templates/SectionOverview.cfm) --->
<cfparam name="Attributes.HintTypeID" default="1">
<cfparam name="Attributes.OnSectionOverview" default="0">

<cfif not IsDefined('Edit') or Edit is "0">
	<cfif attributes.HintTypeID is "1"><!--- Page Text 'Hints' --->
		<cfif Len(Attributes.CategoryID)>
			<cfquery name="getHint" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select Top 1 H.HintID, H.Descr
				From Hints H
				Where H.Active=1
				and H.HintTypeID=1
				and exists (Select HintID From HintCategories Where CategoryID=<cfqueryparam value="#Attributes.CategoryID#" cfsqltype="CF_SQL_INTEGER"> and HintID=H.HintID)
			Order by NewID()
			</cfquery>
			<cfif not getHint.RecordCount><!--- No Category Hints found so look for Section Hints --->
				<cfif Len(Attributes.SectionID)><!---  SectionID may not exist, like in For Sale Classifieds --->
					<cfquery name="getHint" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						Select Top 1 H.HintID, H.Descr
						From Hints H
						Where H.Active=1
						and H.HintTypeID=1
						and exists (Select HintID From HintSections Where SectionID=<cfqueryparam value="#Attributes.SectionID#" cfsqltype="CF_SQL_INTEGER"> and HintID=H.HintID)
					Order by NewID()
					</cfquery>			
					<cfif not getHint.RecordCount><!--- No Section Hints found so look for Parent Section Hints --->
						<cfquery name="getHint" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
							Select Top 1 H.HintID, H.Descr
							From Hints H
							Where H.Active=1
							and H.HintTypeID=1
							and exists (Select HintID From HintParentSections Where ParentSectionID=<cfqueryparam value="#Attributes.ParentSectionID#" cfsqltype="CF_SQL_INTEGER"> and HintID=H.HintID)
						Order by NewID()
						</cfquery>
					</cfif>
				<cfelse><!--- For Sale Classifieds --->		
					<cfif not getHint.RecordCount><!--- No Category Hints found so look for Parent Section Hints --->
						<cfquery name="getHint" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
							Select Top 1 H.HintID, H.Descr
							From Hints H
							Where H.Active=1
							and H.HintTypeID=1
							and exists (Select HintID From HintParentSections Where ParentSectionID=<cfqueryparam value="#Attributes.ParentSectionID#" cfsqltype="CF_SQL_INTEGER"> and HintID=H.HintID)
						Order by NewID()
						</cfquery>
					</cfif>	
				</cfif>
			</cfif>
		<cfelseif Len(Attributes.ParentSectionID)><!--- In templates/ShowAllEvents.cfm or tempaltes/SectionOverview.cfm --->
			<cfquery name="getHint" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select Top 1 H.HintID, H.Descr
				From Hints H
				Where H.Active=1
				and H.HintTypeID=1
				and exists (Select HintID From HintParentSections Where ParentSectionID=<cfqueryparam value="#Attributes.ParentSectionID#" cfsqltype="CF_SQL_INTEGER"> and HintID=H.HintID)
			Order by NewID()
			</cfquery>
		</cfif>
		
			
		<cfif getHint.RecordCount>
			<cfoutput query="getHint">
				#Descr#
			</cfoutput>
		<cfelse>
			<p><br />
			</p>
		</cfif>
	<cfelse><!--- You May Also Be Interested Into 'Hints' HintTypeID = "2" --->
		
		<cfif Len(Attributes.CategoryID)>
			<cfquery name="getHints" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select Top 3 H.HintID, H.Descr
				From Hints H
				Where H.Active=1
				and H.HintTypeID=2
				and exists (Select HintID From HintCategories Where CategoryID=<cfqueryparam value="#Attributes.CategoryID#" cfsqltype="CF_SQL_INTEGER"> and HintID=H.HintID)
			Order by NewID()
			</cfquery>
			<cfif not getHints.RecordCount><!--- No Category Hints found so look for Section Hints --->
				<cfif Len(Attributes.SectionID)><!---  SectionID may not exist, like in For Sale Classifieds --->
					<cfquery name="getHints" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						Select Top 3 H.HintID, H.Descr
						From Hints H
						Where H.Active=1
						and H.HintTypeID=2
						and exists (Select HintID From HintSections Where SectionID=<cfqueryparam value="#Attributes.SectionID#" cfsqltype="CF_SQL_INTEGER"> and HintID=H.HintID)
					Order by NewID()
					</cfquery>			
					<cfif not getHints.RecordCount><!--- No Section Hints found so look for Parent Section Hints --->
						<cfquery name="getHints" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
							Select Top 3 H.HintID, H.Descr
							From Hints H
							Where H.Active=1
							and H.HintTypeID=2
							and exists (Select HintID From HintParentSections Where ParentSectionID=<cfqueryparam value="#Attributes.ParentSectionID#" cfsqltype="CF_SQL_INTEGER"> and HintID=H.HintID)
						Order by NewID()
						</cfquery>
					</cfif>
				<cfelse><!--- For Sale Classifieds --->		
					<cfif not getHints.RecordCount><!--- No Category Hints found so look for Parent Section Hints --->
						<cfquery name="getHints" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
							Select Top 3 H.HintID, H.Descr
							From Hints H
							Where H.Active=1
							and H.HintTypeID=2
							and exists (Select HintID From HintParentSections Where ParentSectionID=<cfqueryparam value="#Attributes.ParentSectionID#" cfsqltype="CF_SQL_INTEGER"> and HintID=H.HintID)
						Order by NewID()
						</cfquery>
					</cfif>	
				</cfif>
			</cfif>
		<cfelseif Len(Attributes.ParentSectionID)><!--- In templates/ShowAllEvents.cfm or tempaltes/SectionOverview.cfm --->
			<cfquery name="getHints" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select Top 3 H.HintID, H.Descr
				From Hints H
				Where H.Active=1
				and H.HintTypeID=2
				and exists (Select HintID From HintParentSections Where ParentSectionID=<cfqueryparam value="#Attributes.ParentSectionID#" cfsqltype="CF_SQL_INTEGER"> and HintID=H.HintID)
			Order by NewID()
			</cfquery>
		</cfif>
		
			
		<cfif getHints.RecordCount>
			<cfset OneThirdOfLinks=int(getHints.RecordCount/3)>
			<cfif not OneThirdOfLinks>
				<cfset OneThirdOfLinks="1">
			</cfif>
			<cfset LinksShown="0">
			<div class="youmayalsolike">
            	<div class="youmayalsolike-title">You May Also Be Interested In</div>
               	<table width="100%" border="0">
					<tr>
   						<td> 
							<ul class="youmayalsolike-skin">
								<cfoutput query="getHints" maxRows="#OneThirdOfLinks#">
									<li>#Trim(ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(Descr,'</p>','','All'),'<p>','','All'),'<br>','','All'))#</li>
									<cfset LinksShown=LinksShown+1>
								</cfoutput>
              				</ul>
						</td>
						<td> 
							<cfif LinksShown neq GetHints.RecordCount>	
								<cfset StartRow=LinksShown+1>						
								<ul class="youmayalsolike-skin">
									<cfoutput query="getHints" startRow="#StartRow#" maxRows="#OneThirdOfLinks#">
										<li>#Trim(ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(Descr,'</p>','','All'),'<p>','','All'),'<br>','','All'))#</li>
										<cfset LinksShown=LinksShown+1>
									</cfoutput>
								</ul>
							<cfelse>
								<div style="width: 159px;">&nbsp;</div>
							</cfif>
						</td>
						<td>
							<cfif LinksShown neq GetHints.RecordCount>	
								<cfset StartRow=LinksShown+1>						
								<ul class="youmayalsolike-skin">
									<cfoutput query="getHints" startRow="#StartRow#" maxRows="#OneThirdOfLinks#">
										<li>#Trim(ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(Descr,'</p>','','All'),'<p>','','All'),'<br>','','All'))#</li>
										<cfset LinksShown=LinksShown+1>
									</cfoutput>
								</ul>
							<cfelse>			
								<div style="width: 159px;">&nbsp;</div>
							</cfif>
						</td>
					</tr>
				</table>
			</div>
		</cfif>
	
	</cfif>
		
</cfif>
