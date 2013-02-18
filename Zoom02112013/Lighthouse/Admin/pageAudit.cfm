<!---
File Name: 	/admin/pages.cfm
Author: 	David Hammond
Description:
--->
<cfimport prefix="lh" taglib="../Tags">

<cfset checkPermissionFunction = "pages">
<cfinclude template="checkPermission.cfm">
<cfset pg_title = "View Page History">
<cfinclude template="header.cfm">

<lh:MS_Table
	table="#Request.dbprefix#_Pages_Audit"
	title="Page History"
	dsn="#Request.dsn#"
	username="#Request.dbusername#"
	password="#Request.dbpassword#"
	resourcesDir="#Request.AppVirtualPath#/Lighthouse/Resources"
	persistentparams="adminFunction=pageAudit"
	allowedActions="View">

	<lh:MS_TableColumn
		ColName="PageAuditID"
		type="integer"
		PrimaryKey="true"
		View="No"
		Search="No" />
	<lh:MS_TableColumn
		ColName="PageID"
		Type="integer"
		View="No" />
	<lh:MS_TableColumn
		ColName="ActionDate"
		DispName="Date"
		type="date"
		showTime="yes"
		orderby="desc" />
	<lh:MS_TableColumn
		ColName="ActionDescr"
		DispName="Description"
		type="text"
		Maxlength="255" />

	<lh:MS_TableAction
		ActionName="Properties"
		Label="Page Properties"
		Type="Custom"
		Href="index.cfm?adminFunction=pages&action=Edit&pk=##pageID##" />

</lh:MS_Table>

<cfinclude template="footer.cfm">