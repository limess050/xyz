<cfimport prefix="lh" taglib="../../Tags">

<cfinclude template="../checkLogin.cfm">
<cfset checkPermissionFunction = "editPage">
<cfinclude template="../checkPermission.cfm">

<cfset pg_title = "Page Permissions">
<cfinclude template="header.cfm">

<cfparam name="action" default="Edit">
<cfparam name="statusMessage" default="You can designate each page on the site as ""members-only"" or ""public."" Public pages are viewable to all website users. Members-only content will require users to log in to view this content. For members-only pages, you may also select the user groups who have access to this page.  If no user groups are selected, the page will be available to all members.">

<style>
#AddEditFormTopButtons,.ACTIONBUTTONTABLE { display:none; }
.STATUSMESSAGE { font-size:13px; }
</style>

<lh:MS_Table
	table="#Request.dbprefix#_Pages"
	title="#pg_title#"
	dsn="#Request.dsn#"
	username="#Request.dbusername#"
	password="#Request.dbpassword#"
	resourcesDir="#Request.AppVirtualPath#/Lighthouse/Resources"
	persistentparams="adminFunction=dialogs%2Fpermissions"
	allowedActions="Edit">

	<lh:MS_TableColumn
		ColName="PageID"
		type="integer"
		PrimaryKey="true"
		View="No"
		hidden="yes"/>

	<lh:MS_TableColumn
		ColName="Name"
		DispName="Page Name"
		Type="text"
		editable = false />

	<lh:MS_TableColumn
		ColName="MembersOnly"
		DispName="Members Only"
		Type="checkbox"
		OnValue="1"
		OffValue="0" />

	<lh:MS_TableColumn
		ColName="LinkPublic"
		DispName="Public Link"
		Type="checkbox"
		OnValue="1"
		OffValue="0"
		HelpText="If checked, links to this page in the navigation will appear even for people who don't have access to view the page.  When the user clicks on the link, they will be presented with a login page."/>

	<lh:MS_TableColumn
		ColName="UserGroupID"
		DispName="Member User Groups"
		Type="select-multiple"
		FKTable="#Request.dbprefix#_UserGroups"
		FKDescr="name"
		FKJoinTable="#Request.dbprefix#_PageUserGroups"/>

	<lh:MS_TableEvent
		EventName="onAfterUpdate"
		Include="../Admin/dialogs/permissions_onAfterUpdate.cfm"/>

</lh:MS_Table>

<cfif action is "Add" or action is "Edit">
	<script type="text/javascript">
		document.getElementById("MembersOnly").onclick = showHideUserGroups;
		function showHideUserGroups(e) {
			document.getElementById("UserGroupID").disabled = !document.getElementById("MembersOnly").checked
			if (!document.getElementById("MembersOnly").checked) {
				for (i = 0; i < document.getElementById("UserGroupID").options.length; i ++) {
					document.getElementById("UserGroupID").options[i].selected = false;
				}
			}
		}
		showHideUserGroups();
	</script>
</cfif>

<cfinclude template="footer.cfm">