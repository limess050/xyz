<cfimport prefix="lh" taglib="../Tags">

<cfinclude template="checkPermission.cfm">
<cfset pg_title = "Manage Admin Users">
<cfinclude template="header.cfm">

<cfif glb_user.super is 1>
	<cfset isSuperUser = true>
<cfelse>
	<cfset isSuperUser = false>
</cfif>

<!--- Determine access based on permissions access --->
<cfif isSuperUser>
	<cfset whereClause = "adminUser=1">
	<cfset clientWhere = "">
	<cfset proposalWhere = "">
	<cfset linkWhere = "">
<cfelse>
	<cfset whereClause = "super=0 and adminUser=1">

	<cfif lh_isModuleInstalled("clientUsers")>
		<cfquery name="getClients" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			select clientID from EX_clientUsers where userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#"> 
		</cfquery>
		<cfif getClients.recordCount gt 0>
			<cfset clientIds = ValueList(getClients.clientID)>
			<cfset clientWhere = "EX_Clients.clientID IN (" & clientIds & ")">
			<cfset whereClause = whereClause & " and not exists (SELECT * FROM EX_ClientUsers WHERE userID = #lighthouse_getTableName("Users")#.userID and clientID NOT IN (" & clientIds & "))">
		<cfelse>
			<cfset clientIDs = "">
			<cfset clientWhere = "">
			<cfset whereClause = whereClause & " and not exists (SELECT * FROM EX_ClientUsers WHERE userID = #lighthouse_getTableName("Users")#.userID)">
		</cfif>

		<cfquery name="getProposals" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			select proposalID from EX_ProposalUsers where userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">
		</cfquery>
		<cfif getProposals.recordCount gt 0>
			<cfset proposalIds = ValueList(getProposals.proposalID)>
			<cfset proposalWhere = "EX_Proposals.proposalID IN (" & proposalIds & ")">
			<cfset whereClause = whereClause & " and not exists (SELECT * FROM EX_ProposalUsers WHERE userID = #lighthouse_getTableName("Users")#.userID and proposalID NOT IN (" & proposalIds & "))">
		<cfelse>
			<cfset proposalIDs = "">
			<cfset proposalWhere = "">
			<cfset whereClause = whereClause & " and not exists (SELECT * FROM EX_ProposalUsers WHERE userID = #lighthouse_getTableName("Users")#.userID)">
		</cfif>
	</cfif>

	<cfquery name="getLinks" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		select linkID from #Request.dbprefix#_UserLinks where userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">
	</cfquery>
	<cfif getLinks.recordCount gt 0>
		<cfset linkIds = ValueList(getLinks.linkID)>
		<cfset linkWhere = "#Request.dbprefix#_Links.linkID IN (" & linkIds & ")">
		<cfset whereClause = whereClause & " and not exists (SELECT * FROM #Request.dbprefix#_UserLinks WHERE userID = #lighthouse_getTableName("Users")#.userID and linkID NOT IN (" & linkIds & "))">
	<cfelse>
		<cfset linkIDs = "">
		<cfset linkWhere = "">
		<cfset whereClause = whereClause & " and not exists (SELECT * FROM #Request.dbprefix#_UserLinks WHERE userID = #lighthouse_getTableName("Users")#.userID)">
	</cfif>

</cfif>

<lh:MS_Table
	table="#lighthouse_getTableName("Users")#"
	title="Admin Users"
	dsn="#Request.dsn#"
	username="#Request.dbusername#"
	password="#Request.dbpassword#"
	resourcesDir="#Request.AppVirtualPath#/Lighthouse/Resources"
	persistentparams="adminFunction=adminUsers"
	whereClause="#whereClause#"
	allowColumnEdit="yes">

	<lh:MS_TableColumn
		ColName="UserID"
		DispName="ID"
		type="integer"
		FormFieldParameters="size=5"
		PrimaryKey="true"
		Identity="Yes" />

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
		View="No" />

	<lh:MS_TableColumn
		ColName="FirstName"
		DispName="First Name"
		Unicode="Yes"
		maxlength="255"
		Required="Yes" />

	<lh:MS_TableColumn
		ColName="LastName"
		DispName="Last Name"
		Unicode="Yes"
		maxlength="255"
		Required="Yes" />

	<lh:MS_TableColumn
		ColName="Email"
		Unicode="Yes"
		maxlength="255"
		Validate="checkEmail(document.getElementById('Email'))" />

	<cfif lh_isModuleInstalled("siteEditor")>
		<lh:MS_TableColumn
			ColName="StatusID"
			DispName="Page Statuses"
			type="checkboxgroup"
			FKTable="#Request.dbprefix#_Statuses"
			FKJoinTable="#lighthouse_getTableName("UserStatus")#"
			FKDescr="descr"
			FKOrderBy="OrderNum"
			view="no"
			helpText="The user is allowed to assign the following statuses to pages." />
	</cfif>

	<lh:MS_TableColumn
		ColName="UserGroupID"
		DispName="User Groups"
		Type="select-multiple"
		FKTable="#Request.dbprefix#_UserGroups"
		FKDescr="name"
		FKJoinTable="#Request.dbprefix#_UserUserGroups"
		HelpText="Select the groups to which this user belongs."
		View="No"/>

	<!--- Clients --->
	<cfif lh_isModuleInstalled("clientUsers")>
		<lh:MS_TableColumn
			ColName="ClientID"
			DispName="Client"
			Type="select-multiple"
			FKTable="#lighthouse_getTableName("Clients")#"
			FKDescr="name"
			FKJoinTable="#lighthouse_getTableName("ClientUsers")#"
			FKWhere="#clientWhere#"
			ChildColumn="ProposalID"
			View="No"/>
		<lh:MS_TableColumn
			ColName="ProposalID"
			DispName="Project"
			type="select-multiple"
			FKTable="EX_Proposals"
			FKDescr="ProjectName"
			FKWhere="#proposalWhere#"
			FKJoinTable="EX_ProposalUsers"
			ParentColumn="ClientID"
			View="No" />
	</cfif>

	<lh:MS_TableColumn
		ColName="LinkID"
		DispName="Permissions"
		type="checkboxgroup"
		Group="(select descr from #Request.dbprefix#_LinkCats where linkCatID = #Request.dbprefix#_Links.linkCatID)"
		FKTable="#Request.dbprefix#_Links"
		FKJoinTable="#Request.dbprefix#_UserLinks"
		FKDescr="linkText"
		FKWhere="#linkWhere#"
		FKOrderBy="(select orderNum from #Request.dbprefix#_LinkCats where linkCatID = #Request.dbprefix#_Links.linkCatID),OrderNum"
		view="no"
		helpText="Superusers automatically have access to all function, regardless of checked permissions." />

	<lh:MS_TableColumn
		ColName="Active"
		type="Checkbox"
		OnValue="1"
		OffValue="0" />

	<cfif isSuperUser>
		<lh:MS_TableColumn
			ColName="Super"
			Dispname="Superuser"
			Type="checkbox"
			OnValue="1"
			OffValue="0"/>
	</cfif>

	<cfif glb_user.staff is 1>
		<lh:MS_TableColumn
			ColName="Staff"
			Type="checkbox"
			OnValue="1"
			OffValue="0"
			View="No"/>
	</cfif>
	
	<lh:MS_TableColumn
		ColName="AdminUser"
		Type="checkbox"
		OnValue="1"
		OffValue="0"
		hidden="yes"
		defaultvalue="1" />
</lh:MS_Table>

<cfinclude template="footer.cfm">