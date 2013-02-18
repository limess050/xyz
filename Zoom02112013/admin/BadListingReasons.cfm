<!---
This page is used for testing Lighthouse functionality and providing a sample
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Bad Listing Reasons">
<cfinclude template="../Lighthouse/Admin/Header.cfm">


<lh:MS_Table table="BadListingReasons" title="#pg_title#"
	OrderBy="OrderNum">
	<lh:MS_TableColumn
		ColName="BadListingReasonID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true" />
	
	<lh:MS_TableColumn
		ColName="Title"
		type="text"
		Unique="Yes"
		required="Yes"
		MaxLength="100"
		DescriptionColumn="Yes" />
		
	<lh:MS_TableColumn 
		colname="Active" 
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="1" />

	<lh:MS_TableAction
		ActionName="ListOrder"
		Label="Order Reasons"
		DescriptionColumn="Title"
		View="No"/>
</lh:MS_Table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">