
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Sub Sections">
<cfinclude template="../Lighthouse/Admin/Header.cfm">

<cfparam name="PSID" default="0">

<cfif not IsDefined('Action') or (IsDefined('Action') and Action is "View")>
	<cflocation url="Sections.cfm" AddToken="No">
	<cfabort>
</cfif>


<lh:MS_Table table="Sections" title="#pg_title#"
	allowedactions="View"	
	PersistentParams="PSID=#PSID#">
	
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
		Label="Order Sections"
		HREF="Sections.cfm?Action=ListOrder&PSID=##PK##"
		View="No"/>

	<lh:MS_TableAction
		ActionName="ListOrder"
		Label="Order Table"
		DescriptionColumn="Title"
		OrderColumn="OrderNum"
		View="No"
		SelectQuery="Select S.SectionID as SelectValue, IsNull(S2.Title,'') + ' - ' + IsNull(S.Title,'') as SelectText From Sections S Inner Join Sections S2 on S.ParentSectionID=S2.SectionID Where S2.SectionID=#psid# Order By S.OrderNum" />
		
</lh:MS_Table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">