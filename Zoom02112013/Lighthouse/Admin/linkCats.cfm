<cfimport prefix="lh" taglib="../Tags">

<cfinclude template="checkPermission.cfm">
<cfset pg_title = "Manage Admin Link Categories">
<cfinclude template="header.cfm">

<lh:MS_Table
	table="#Request.dbprefix#_LinkCats"
	title="Link Categories"
	persistentparams="adminFunction=linkCats">

	<lh:MS_TableColumn
		ColName="LinkCatID"
		DispName="ID"
		type="integer"
		FormFieldParameters="size=5"
		PrimaryKey="true"
		Identity="Yes" />

	<lh:MS_TableColumn
		ColName="Descr"
		Unicode="Yes"
		DispName="Category Name"
		Maxlength="50"
		OrderBy="desc"
		Required="Yes" />

	<lh:MS_TableAction
		ActionName="ListOrder"
		DescriptionColumn="descr" />

	<lh:MS_TableRowAction
		ActionName="ManageLinks"
		Type="Custom"
		Label="Manage Links"
		Href="index.cfm?adminFunction=links&linkCatID=##pk##&searching=1" />
	<lh:MS_TableRowAction
		ActionName="OrderLinks"
		Label="Order Links"
		Type="Custom"
		Href="index.cfm?adminFunction=links&action=ListOrder&LinkCatID=##pk##&lh_persistentParams=LinkCatID" />

</lh:MS_Table>

<cfinclude template="footer.cfm">