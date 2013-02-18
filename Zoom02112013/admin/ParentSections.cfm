
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Parent Sections">
<cfinclude template="../Lighthouse/Admin/Header.cfm">

<cfif not IsDefined('Action') or (IsDefined('Action') and Action is "View")>
	<cflocation url="Sections.cfm" AddToken="No">
	<cfabort>
</cfif>


<lh:MS_Table table="Sections" title="#pg_title#"
	AllowedActions="View"
	WhereClause="ParentSectionID is null"
	OrderBy="OrderNum">
	
	<lh:MS_TableColumn
		ColName="SectionID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true" />
		
	<lh:MS_TableColumn
		ColName="Title"
		DispName="Section Name"
		type="text"
		Unique="Yes"
		required="Yes"
		MaxLength="200"
		DescriptionColumn="Yes" />

	<lh:MS_TableRowAction
		ActionName="Custom"
		Label="Order Sub-Sections"
		HREF="SubSections.cfm?Action=ListOrder&PSID=##PK##"
		View="No"/>

	<lh:MS_TableAction
		ActionName="ListOrder"
		Label="Order Table"
		DescriptionColumn="Title"
		OrderColumn="OrderNum"
		View="No"
		SelectQuery="Select SectionID as SelectValue, Title as SelectText From Sections Where ParentSectionID is Null Order By OrderNum" />
		
</lh:MS_Table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">