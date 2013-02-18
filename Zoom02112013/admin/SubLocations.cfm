No Longer in Use<br>
SubLocations.cfm<Cfabort>
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Sub Locations">
<cfinclude template="../Lighthouse/Admin/Header.cfm">

<cfparam name="PSID" default="0">

<cfif not IsDefined('Action') or (IsDefined('Action') and Action is "View")>
	<cflocation url="Locations.cfm" AddToken="No">
	<cfabort>
</cfif>


<lh:MS_Table table="Locations" title="#pg_title#"
	allowedactions="View"	
	PersistentParams="PSID=#PSID#">
	
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
		Label="Order Locations"
		HREF="Locations.cfm?Action=ListOrder&PSID=##PK##"
		View="No"/>

	<lh:MS_TableAction
		ActionName="ListOrder"
		Label="Order Table"
		DescriptionColumn="Title"
		OrderColumn="OrderNum"
		View="No"
		SelectQuery="Select L.LocationID as SelectValue, IsNull(L2.Title,'') + ' - ' + IsNull(L.Title,'') as SelectText From Locations L Inner Join Locations L2 on L.ParentLocationID=L2.LocationID Where L2.LocationID=#psid# Order By L.OrderNum" />
		
</lh:MS_Table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">