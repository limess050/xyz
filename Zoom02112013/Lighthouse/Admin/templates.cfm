<!---
File Name: 	/admin/Templates.cfm
Author: 	David Hammond
Description:
--->
<cfimport prefix="lh" taglib="../Tags">

<cfinclude template="checkPermission.cfm">
<cfset pg_title = "Manage Page Templates">
<cfinclude template="header.cfm">

<lh:MS_Table
	table="#Request.dbprefix#_Templates"
	title="Templates"
	persistentparams="adminFunction=templates">
	<lh:MS_TableColumn
		ColName="TemplateID"
		type="integer"
		PrimaryKey="true"
		View="No"
		Search="No" />
	<lh:MS_TableColumn
		ColName="Name"
		Type="text"
		Unicode="Yes"
		Required="Yes"
		Maxlength="255" />
	<lh:MS_TableColumn
		ColName="FileName"
		Type="text"
		Unicode="Yes"
		Required="Yes"
		Maxlength="255" />
	<lh:MS_TableColumn
		ColName="DefaultTemplate"
		DispName="Default"
		Type="checkbox" />
	<lh:MS_TableColumn
		ColName="GlobalTemplate"
		DispName="Global"
		Type="checkbox" />
</lh:MS_Table>

<cfinclude template="footer.cfm">