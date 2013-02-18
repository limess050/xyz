<!---
This page is used for testing Lighthouse functionality and providing a sample
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Locations">
<cfinclude template="../Lighthouse/Admin/Header.cfm">


<lh:MS_Table table="Locations" title="#pg_title#"
	OrderBy="OrderNum">
	<lh:MS_TableColumn
		ColName="LocationID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true"
		RelatedTables="ListingLocations.LocationID" />
	
	<lh:MS_TableColumn
		ColName="Title"
		DispName="Location Name"
		type="text"
		Unique="Yes"
		required="Yes"
		MaxLength="200"
		DescriptionColumn="Yes" />
		
	<lh:MS_TableColumn 
		colname="Active" 
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="1" />

	<lh:MS_TableAction
		ActionName="ListOrder"
		Label="Order Locations"
		DescriptionColumn="Title"
		View="No"/>
</lh:MS_Table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">