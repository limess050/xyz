<!---
This page is used for testing Lighthouse functionality and providing a sample
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Keywords">
<cfinclude template="../Lighthouse/Admin/Header.cfm">


<lh:MS_Table table="Keywords" title="#pg_title#"
	OrderBy="OrderNum">
	<lh:MS_TableColumn
		ColName="KeywordID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true"
		RelatedTables="PageKeywords.KeywordID" />
	
	<lh:MS_TableColumn
		ColName="Title"
		DispName="Keyword"
		type="text"
		Unique="Yes"
		required="Yes"
		MaxLength="200"
		DescriptionColumn="Yes" />
</lh:MS_Table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">