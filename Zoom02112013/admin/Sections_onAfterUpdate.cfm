<!--- Update any Category records to have the correct ParentSectionID. (Moving a Subsection from one section to another reassigns section.ParentSectionID but misses category.ParentSectionID. Also check to see if the Section.OrderNum is unique within the parent section. If not, set to Max + 1, as this means the section has been moved to a new parent section. --->

<cfquery name="getCategoriesForUpdating" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select
	C.CategoryID, C.ParentSectionID,
	S.ParentSectionID as SParentSectionID
	From Categories C
	left outer join Sections S on C.SectionID=S.SectionID
	Where C.ParentSectionID<>S.ParentSectionID
	and C.SectionID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
	Order by C.ParentSectionID, S.SectionID	
</cfquery>

<cfif getCategoriesForUpdating.RecordCount>
	<cfquery name="getCategoriesForUpdating" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		<cfoutput query="getCategoriesForUpdating">
			Update Categories
			Set ParentSectionID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SParentSectionID#">
			Where CategoryID = <cfqueryparam cfsqltype="cf_sql_integer" value="#CategoryID#">
			and SectionID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
		</cfoutput>
	</cfquery>
</cfif>

<cfquery name="getDupeOrderNum" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SectionID 
	From Sections 
	Where OrderNum = (Select OrderNum From Sections Where SectionID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">)
	and ParentSectionID = (Select ParentSectionID From Sections Where SectionID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">)
	and SectionID <> <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>

<cfif getDupeOrderNum.RecordCount>
	<cfquery name="getOrderNum" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select Max(OrderNum) as MaxOrderNum
		From Sections 
		Where ParentSectionID = (Select ParentSectionID From Sections Where SectionID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">)
	</cfquery>
	<cfquery name="getCategoriesForUpdating" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Update Sections
		Set OrderNum = <cfqueryparam cfsqltype="cf_sql_integer" value="#getOrderNum.MaxOrderNum#"> + 1
		Where SectionID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
	</cfquery>
</cfif>

<!--- Now call Categories_OnAfterUpdate, to correct all the associated ListingSections and ListingSubSections table records. --->
<cfinclude template="Categories_onAfterUpdate.cfm">




