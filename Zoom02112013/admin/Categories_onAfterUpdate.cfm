<!--- Look for listings that have a mismatch between their ParentSectionID or SectionID and the ParentSectionID and SectionID of the Listing's Category, so that any time a Category is moved, the listing's ParentSectionID  and SectionID are properly updated. --->
<!--- THIS TEMPLATE DOES NOT REFERENCE "PK" AT ALL. THE TEMPLATE IS INCLUDED IN SECTIONS_ONAFTERUPDATE.CFM. IF ANY REFERNCE TO PK IS ADDED TO THIS TEMPLATE, THE INCLUSION IN SECTIONS_ONAFTERUPDATE.CFM WILL BREAK!!! --->
<cfquery name="getMismatches" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select Distinct l.ListingID, l.Title, 
	lps.ParentSectionID  as ListingParentSectionID,
	ls.SectionID as ListingSectionID, ps.ParentSectionID as CategoryParentSectionID, s.SectionID as CategorySectionID
	From Listings l with (NOLOCK)
	Inner Join ListingCategories lc with (NOLOCK) on l.ListingID=lc.ListingID 
	Inner Join ListingParentSections lps with (NOLOCK) on l.ListingID=lps.ListingID
	Inner Join Categories c with (NOLOCK) on lc.CategoryID=c.CategoryID
	Inner Join ParentSectionsView ps with (NOLOCK) on c.ParentSectionID=ps.ParentSectionID
	Left Join Sections s with (NOLOCK) on c.SectionID=s.SectionID
	Left join ListingSections ls with (NOLOCK) on l.ListingID=ls.ListingID
	Where (lps.ParentSectionID <> ps.ParentSectionID
	or ls.SectionID <> s.SectionID	
	or (ls.SectionID is null and c.SectionID is not null)
	or (ls.SectionID is not null and c.SectionID is null))
	Order by l.ListingID 
</cfquery>

<cfoutput query="getMismatches">
	<cfif ListingParentSectionID neq CategoryParentSectionID>
		<cfquery name="fixParentSectionID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Update ListingParentSections
			Set ParentSectionID = <cfqueryparam value="#CategoryParentSectionID#" cfsqltype="CF_SQL_INTEGER">
			Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cfif>
	<cfif ListingSectionID neq CategorySectionID>
		<cfif Len(CategorySectionID)>
			<cfif Len(ListingSectionID)>
				<cfquery name="fixSectionID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Update ListingSections
					Set SectionID = <cfqueryparam value="#CategorySectionID#" cfsqltype="CF_SQL_INTEGER">
					Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
			<cfelse>
				<cfquery name="insertSectionID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Insert into ListingSections
					(ListingID, SectionID)
					VALUES
					(<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">, <cfqueryparam value="#CategorySectionID#" cfsqltype="CF_SQL_INTEGER">)
				</cfquery>
			</cfif>
		<cfelseif Len(ListingSectionID)>
			<cfquery name="deleteSectionID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Delete From ListingSections
				Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfif>
	</cfif>
</cfoutput>

