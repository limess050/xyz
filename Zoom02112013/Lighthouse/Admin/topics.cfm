<cfimport prefix="lh" taglib="../Tags">

<cfinclude template="checkPermission.cfm">

<cfset pg_title = "Manage Topics">
<cfinclude template="header.cfm">

<lh:MS_Table 
	table="#Request.dbprefix#_Topics"
	title="Topics"
	orderby="#Request.dbprefix#_Topics.Topic"
	persistentparams="adminFunction=topics">

	<lh:MS_TableColumn
		ColName="TopicID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="Yes" />

	<lh:MS_TableColumn
		ColName="Topic"
		Unicode="Yes"
		maxlength="255"
		Required="Yes" />

</lh:MS_Table>

<cfinclude template="footer.cfm">