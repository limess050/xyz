<cfimport prefix="lh" taglib="../Tags">

<!--- <cfinclude template="checkPermission.cfm"> --->
<cfset pg_title = "Manage Admin Links">
<cfparam name="linkCatID" default="">
<cfparam name="linktext" default="">
<cfparam name="href" default="">
<cfif Request.dbtype is "mysql">
	<cfset userDescrExpression = "concat(firstName,' ',lastName)">
<cfelse>
	<cfset userDescrExpression = "firstName + ' ' + lastName">
</cfif>
<cfinclude template="header.cfm">

<cfif glb_user.super is 1>
	<cfset whereClause = "">
<cfelse>
	<cfset whereClause = "linkID IN (SELECT linkID FROM #Request.dbprefix#_UserLinks WHERE userID = #session.userID#) AND linkID NOT IN (SELECT linkID FROM #Request.dbprefix#_UserLinks WHERE userID <> #session.userID#)">
</cfif>

<lh:MS_Table
	table="#Request.dbprefix#_Links"
	title="Admin Links"
	dsn="#Request.dsn#"
	username="#Request.dbusername#"
	password="#Request.dbpassword#"
	whereClause="#whereClause#"
	resourcesDir="#Request.AppVirtualPath#/Lighthouse/Resources"
	persistentparams="adminFunction=links"
	allowColumnEdit="yes">

	<lh:MS_TableColumn
		ColName="LinkID"
		DispName="ID"
		type="integer"
		FormFieldParameters="size=5"
		PrimaryKey="true"
		Identity="Yes" />

	<lh:MS_TableColumn
		ColName="LinkCatID"
		DispName="Category"
		type="select"
		fktable="#Request.dbprefix#_linkCats"
		fkdescr="descr"
		Required="yes"
		DefaultValue="#linkcatid#" />

	<lh:MS_TableColumn
		ColName="UserID"
		DispName="Available to"
		type="select-multiple"
		FKTable="#lighthouse_getTableName("Users")#"
		FKJoinTable="#Request.dbprefix#_UserLinks"
		FKDescr="#userDescrExpression#"
		FKWhere="adminUser=1"
		Editable="#Evaluate("glb_user.super is 1")#"
		DefaultValue="#session.userID#"
		view="No" />

	<lh:MS_TableColumn
		ColName="LinkText"
		Unicode="Yes"
		Maxlength="255"
		Required="Yes"
		DefaultValue="#linkText#" />

	<lh:MS_TableColumn
		ColName="Href"
		Unicode="Yes"
		Maxlength="1000"
		View="No"
		Required="Yes"
		DefaultValue="#href#" />

	<lh:MS_TableColumn
		Unicode="Yes"
		Maxlength="255"
		View="No"
		ColName="Onclick" />

	<lh:MS_TableColumn
		Unicode="Yes"
		Maxlength="255"
		View="No"
		ColName="Target" />


	<cfif glb_user.super is 1>
		<lh:MS_TableColumn
			ColName="Super"
			DispName="Superuser"
			Type="checkbox"
			OnValue="1"
			OffValue="0"
			HelpText="Superuser links appear to Superusers regardless of whether they have been specifically assigned." />

		<cfif StructKeyExists(url,"lh_persistentParams")>
			<cfif ListFindNoCase(url.lh_persistentParams,"LinkCatID")>
				<lh:MS_TableAction
					ActionName="ListOrder"
					DescriptionColumn="linktext" 
					SelectQuery="select linkID as selectValue, linkText as selectText from #Request.dbprefix#_Links where linkCatID = #url.linkCatID# order by orderNum" />
			</cfif>
		</cfif>
	</cfif>
</lh:MS_Table>

<cfinclude template="footer.cfm">