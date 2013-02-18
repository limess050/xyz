<cfimport prefix="lh" taglib="../Tags">

<cfinclude template="checkPermission.cfm">

<cfset pg_title = "Manage User Groups">
<cfinclude template="header.cfm">

<lh:MS_Table
	table="#Request.dbprefix#_UserGroups"
	title="User Groups"
	dsn="#Request.dsn#"
	username="#Request.dbusername#"
	password="#Request.dbpassword#"
	resourcesDir="#Request.AppVirtualPath#/Lighthouse/Resources"
	persistentparams="adminFunction=userGroups">

	<lh:MS_TableColumn
		ColName="UserGroupID"
		DispName="ID"
		type="integer"
		FormFieldParameters="size=5"
		PrimaryKey="true"
		Identity="Yes" />

	<lh:MS_TableColumn
		ColName="Name"
		Unicode="Yes"
		maxlength="255"
		Required="Yes" />

</lh:MS_Table>

<cfinclude template="footer.cfm">