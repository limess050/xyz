<cfimport prefix="lh" taglib="../../Tags">

<cfinclude template="../checkLogin.cfm">
<cfset checkPermissionFunction = "editPage">
<cfinclude template="../checkPermission.cfm">

<cfset pg_title = "Choose Template">
<cfinclude template="header.cfm">

<cfparam name="statusMessage" default="Select a template for this page from the list below.">

<lh:MS_Table
	table="#Request.dbprefix#_Templates"
	title="Templates"
	dsn="#Request.dsn#"
	username="#Request.dbusername#"
	password="#Request.dbpassword#"
	resourcesDir="#Request.AppVirtualPath#/Lighthouse/Resources"
	persistentparams="adminFunction=dialogs%2Ftemplate"
	allowedActions="view">

	<lh:MS_TableColumn
		ColName="TemplateID"
		type="integer"
		PrimaryKey="true"
		View="No"
		Search="No" />
	<lh:MS_TableColumn
		ColName="Name"
		Type="text"
		Maxlength="255"
		orderby="asc"/>
	<lh:MS_TableColumn
		ColName="DefaultTemplate"
		DispName="Default"
		Type="checkbox" />
	<lh:MS_TableColumn
		ColName="GlobalTemplate"
		DispName="Global"
		Type="checkbox" />
	<lh:MS_TableRowAction
		ActionName="Select"
		ColName="TemplateID"
		Descr="name" />

</lh:MS_Table>

<p>
<input type=button value=Cancel class="button" onclick="window.close(); return false;">
</p>
<cfinclude template="footer.cfm">