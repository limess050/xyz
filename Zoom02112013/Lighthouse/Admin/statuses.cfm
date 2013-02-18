<cfimport prefix="lh" taglib="../Tags">

<cfinclude template="checkPermission.cfm">

<cfset pg_title = "Manage Statuses">
<cfinclude template="header.cfm">

<lh:MS_Table 
	table="#Request.dbprefix#_Statuses"
	title="Statuses"
	persistentparams="adminFunction=Statuses">

	<lh:MS_TableColumn
		ColName="StatusID"
		DispName="ID"
		type="integer"
		PrimaryKey="true" />

	<lh:MS_TableColumn
		ColName="Descr"
		Unicode="Yes"
		DispName="Status"
		Maxlength="50"
		Required="Yes" />

	<lh:MS_TableColumn
		ColName="UserID"
		DispName="Available to"
		type="select-multiple"
		FKTable="#Request.dbprefix#_Users"
		FKJoinTable="#Request.dbprefix#_UserStatus"
		FKDescr="firstname + ' ' + lastname"
		FKWhere="active = 1"
		FKORDERBY="firstname,lastname"
		View="false" />

	<lh:MS_TableAction 
		ActionName="ListOrder"
		Label="Set Workflow Order"
		DescriptionColumn="descr" />

</lh:MS_Table>

<cfinclude template="footer.cfm">