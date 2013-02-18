No Longer in Use<br>
ParentLocations.cfm<Cfabort>
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Parent Locations">
<cfinclude template="../Lighthouse/Admin/Header.cfm">

<cfif not IsDefined('Action') or (IsDefined('Action') and Action is "View")>
	<cflocation url="Locations.cfm" AddToken="No">
	<cfabort>
</cfif>


<lh:MS_Table table="Locations" title="#pg_title#"
	AllowedActions="View"
	WhereClause="ParentLocationID is null"
	OrderBy="OrderNum">
	
	<lh:MS_TableColumn
		ColName="LocationID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true" />
		
	<lh:MS_TableColumn
		ColName="Title"
		DispName="Location Name"
		type="text"
		Unique="Yes"
		required="Yes"
		MaxLength="200"
		DescriptionColumn="Yes" />

	<lh:MS_TableRowAction
		ActionName="Custom"
		Label="Order Sub-Locations"
		HREF="SubLocations.cfm?Action=ListOrder&PSID=##PK##"
		View="No"/>

	<lh:MS_TableAction
		ActionName="ListOrder"
		Label="Order Table"
		DescriptionColumn="Title"
		OrderColumn="OrderNum"
		View="No"
		SelectQuery="Select LocationID as SelectValue, Title as SelectText From Locations Where ParentLocationID is Null Order By OrderNum" />
		
</lh:MS_Table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">