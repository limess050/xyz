
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Parks">
<cfinclude template="../Lighthouse/Admin/Header.cfm">


<lh:MS_Table table="Parks" title="#pg_title#"
	OrderBy="OrderNum">
	<lh:MS_TableColumn
		ColName="ParkID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true"
		RelatedTables="ListingParks.ParkID" />
	
	<lh:MS_TableColumn
		ColName="Title"
		DispName="Park Name"
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
		Label="Order Parks"
		DescriptionColumn="Title"
		View="No"/>
</lh:MS_Table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">