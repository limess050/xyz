
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "NGO Types">
<cfinclude template="../Lighthouse/Admin/Header.cfm">


<lh:MS_Table table="NGOTypes" title="#pg_title#"
	OrderBy="OrderNum">
	<lh:MS_TableColumn
		ColName="NGOTypeID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true"
		RelatedTables="ListingNGOTypes.NGOTypeID" />
	
	<lh:MS_TableColumn
		ColName="Title"
		DispName="NGO Type Name"
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
		Label="Order NGO Types"
		DescriptionColumn="Title"
		View="No"/>
</lh:MS_Table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">