<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfset pg_title = "Lighthouse Test Table 2">
<cfinclude template="../Lighthouse/Admin/Header.cfm">

<lh:MS_Table
	table="LH_SampleLookup"
	title="First Names">

	<lh:MS_TableColumn
		ColName="SampleLookupID"
		type="integer"
		PrimaryKey="true" />
	<lh:MS_TableColumn
		ColName="Descr"
		type="text"
		required="Yes" />

	<lh:MS_TableRowAction
		ActionName="Select"
		ColName="LookupID"
		Descr="descr" />
</lh:MS_Table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">