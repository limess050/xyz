<cfimport prefix="lh" taglib="../../Tags">

<cfinclude template="../checkLogin.cfm">
<cfset checkPermissionFunction = "editPage">
<cfinclude template="../checkPermission.cfm">

<cfset pg_title = "Page Archive">
<cfinclude template="header.cfm">

<lh:MS_Table
	table="#Request.dbprefix#_Pages_Archive"
	title="Page Archive"
	dsn="#Request.dsn#"
	username="#Request.dbusername#"
	password="#Request.dbpassword#"
	resourcesDir="#Request.AppVirtualPath#/Lighthouse/Resources"
	persistentparams="adminFunction=dialogs%2Farchive"
	allowedActions="View,Delete">

	<lh:MS_TableColumn
		ColName="pageArchiveID"
		type="integer"
		PrimaryKey="true"
		View="No"
		Search="No" />
	<lh:MS_TableColumn
		ColName="pageID"
		type="integer"
		View="No"
		Search="Yes" />
	<lh:MS_TableColumn
		ColName="Name"
		Type="text"/>
	<lh:MS_TableColumn
		ColName="DateModified"
		DispName="Date Saved"
		Type="text"
		orderby="asc" />
	<lh:MS_TableRowAction
		ActionName="View"
		Type="Custom"
		Href="../page.cfm?pageArchiveID=##pk##&pageVersion=archive"
		Target="_blank" />
	<lh:MS_TableRowAction
		ActionName="Restore"
		Type="Select"
		ColName="pageArchiveID"
		Descr="name" />

</lh:MS_Table>

<cfinclude template="footer.cfm">