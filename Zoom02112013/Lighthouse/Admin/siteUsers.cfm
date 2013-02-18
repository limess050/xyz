<cfimport prefix="lh" taglib="../Tags">

<cfinclude template="checkPermission.cfm">
<cfset pg_title = "Manage Site Users">
<cfinclude template="header.cfm">

<lh:MS_Table
	table="#lighthouse_getTableName("Users")#"
	title="Site Users"
	dsn="#Request.dsn#"
	username="#Request.dbusername#"
	password="#Request.dbpassword#"
	resourcesDir="#Request.AppVirtualPath#/Lighthouse/Resources"
	persistentparams="adminFunction=siteUsers"
	whereClause="(adminUser = 0)">

	<lh:MS_TableColumn
		ColName="UserID"
		DispName="ID"
		Unicode="Yes"
		type="integer"
		FormFieldParameters="size=5"
		PrimaryKey="true"
		Identity="Yes"/>

	<lh:MS_TableColumn
		ColName="UserName"
		Unicode="Yes"
		maxlength="20"
		Required="Yes"
		Unique="Yes"/>

	<lh:MS_TableColumn
		ColName="Password"
		Unicode="Yes"
		maxlength="20"
		Required="Yes"
		View="No"/>

	<lh:MS_TableColumn
		ColName="FirstName"
		DispName="First Name"
		Unicode="Yes"
		maxlength="50"
		Required="Yes" />

	<lh:MS_TableColumn
		ColName="LastName"
		DispName="Last Name"
		Unicode="Yes"
		maxlength="50"
		Required="Yes" />

	<lh:MS_TableColumn
		ColName="UserGroupID"
		DispName="User Groups"
		Type="select-multiple"
		FKTable="#Request.dbprefix#_UserGroups"
		FKDescr="name"
		FKJoinTable="#Request.dbprefix#_UserUserGroups"
		HelpText="Select the groups to which this user belongs."/>

	<lh:MS_TableColumn
		ColName="Active"
		type="Checkbox"
		OnValue="1"
		OffValue="0" />

	<lh:MS_TableColumn
		ColName="AdminUser"
		DispName="Make Admin User"
		type="Checkbox"
		OnValue="1"
		OffValue="0"
		View="No"
		Search="No"
		HelpText="Once this user is marked as an admin user their information will be accessible from the Manage Admin Users screen."/>

</lh:MS_Table>

<cfinclude template="footer.cfm">