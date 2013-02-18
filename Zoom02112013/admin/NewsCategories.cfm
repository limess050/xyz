<!---
This page is used for testing Lighthouse functionality and providing a sample
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "News Categories">
<cfinclude template="../Lighthouse/Admin/Header.cfm">


<lh:MS_Table table="NewsCategories" title="#pg_title#"
	OrderBy="OrderNum">
	<lh:MS_TableColumn
		ColName="NewsCategoryID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true"
		RelatedTables="NewsNewsCategories.NewsCategoryID" />
	
	<lh:MS_TableColumn
		ColName="Title"
		DispName="Category"
		type="text"
		Unique="Yes"
		required="Yes"
		MaxLength="2000"
		DescriptionColumn="Yes" />
		
	<lh:MS_TableColumn 
		colname="Active" 
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="1" />

	<lh:MS_TableAction
		ActionName="ListOrder"
		Label="Order News Categories"
		DescriptionColumn="Title"
		View="No"/>
</lh:MS_Table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">