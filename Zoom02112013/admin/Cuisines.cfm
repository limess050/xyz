<!---
This page is used for testing Lighthouse functionality and providing a sample
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Cuisines">
<cfinclude template="../Lighthouse/Admin/Header.cfm">


<lh:MS_Table table="Cuisines" title="#pg_title#"
	OrderBy="OrderNum">
	<lh:MS_TableColumn
		ColName="CuisineID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true"
		RelatedTables="ListingCuisines.CuisineID" />
	
	<lh:MS_TableColumn
		ColName="Title"
		DispName="Cuisine Name"
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
		Label="Order Cuisines"
		DescriptionColumn="Title"
		View="No"/>
</lh:MS_Table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">