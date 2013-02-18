<!---
File Name: 	/admin/pages.cfm
Author: 	David Hammond
Description:
--->
<cfimport prefix="lh" taglib="../Tags">

<cfinclude template="checkPermission.cfm">

<cfparam name="url.version" default="working">
<cfswitch expression="#url.version#">
	<cfcase value="live">
		<cfset tablesuffix = "_Live">
		<cfset editable = false>
		<cfset pg_title = "Live Pages">
	</cfcase>
	<cfcase value="archive">
		<cfset tablesuffix = "_Archive">
		<cfset editable = false>
		<cfset pg_title = "Archived Pages">
	</cfcase>
	<cfdefaultcase>
		<cfset tablesuffix = "">
		<cfset editable = true>
		<cfset pg_title = "Manage Site Pages">
	</cfdefaultcase>
</cfswitch>

<cfinclude template="header.cfm">

<cfif IsDefined("action")>
	<cfif action is "AddEditDoit">
		<cfset Application.PageAudit.InsertRow(PageID="#pk#",PageName="#name#",User="#session.User#")>
	</cfif>
</cfif>

<lh:MS_Table
	table="#Request.dbprefix#_Pages#tablesuffix#"
	title="#pg_title#"
	resourcesDir="#Request.AppVirtualPath#/Lighthouse/Resources"
	persistentparams="adminFunction=pages&version=#url.version#"
	allowedActions="View,Search,Edit,CreateExcel,DisplayOptions"
	editable=#editable#>

	<cfif url.version is "archive">
		<lh:MS_TableColumn
			ColName="PageArchiveID"
			type="integer"
			PrimaryKey="true"
			Search="No"
			View="No" />
		<lh:MS_TableColumn
			ColName="PageID"
			type="integer"
			View="No" />
	<cfelse>
		<lh:MS_TableColumn
			ColName="PageID"
			type="integer"
			PrimaryKey="true"
			View="No" />
	</cfif>

	<lh:MS_TableColumn
		ColName="Name"
		Type="text"
		Unicode="Yes"
		Unique="Yes"
		Maxlength="100"
		orderby="asc" />
	<cfif Request.lh_useFriendlyUrls>
		<lh:MS_TableColumn
			ColName="Link"
			Type="pseudo"
			Expression="('#Request.HttpUrl#/' + #Request.dbprefix#_Pages#tablesuffix#.name)" 
			ShowOnEdit="true"
			View="No"
			Search="No" />
	</cfif>
	<lh:MS_TableColumn
		ColName="Title"
		type="textarea"
		Unicode="Yes"
		Maxlength="500"
		FormFieldParameters="rows=2 cols=40"
		View="No"/>
	<lh:MS_TableColumn
		ColName="NavTitle"
		DispName="Navigation Title"
		HelpText="The navigation title is used in the subnavigation of the site.  Often this is the same as the title, but if the title is very long it is sometimes desirable to have a shorter navigation title."
		type="text"
		Unicode="Yes"
		Required="Yes"
		Maxlength="255"
		View="No"/>
	<lh:MS_TableColumn
		ColName="TitleTag"
		DispName="Browser Title"
		type="text"
		Unicode="Yes"
		Maxlength="500"
		HelpText="The browser title contains the title for your web page that appears in the top bar of the web browser.  An accurate, descriptive title here helps improve search engine rankings.  If no browser title is specified, the title will be used." />
	<lh:MS_TableColumn
		ColName="MetaDescription"
		DispName="Meta Description"
		type="textarea"
		Unicode="Yes"
		Maxlength="250"
		FormFieldParameters="Rows=3"
		HelpText="The meta description is a short description of the page that will not appear on your site but may display in search engine results.  Note that your meta description will generally not affect your search engine rankings, but a good description can result in increased traffic by increasing the likelihood that a user will click on your search result." />
		
	<lh:MS_TableChild name="#Request.dbprefix#_PageTopics" dispname="Topics" view="No">
		<lh:MS_TableColumn
			ColName="TopicID"
			DispName="Topic"
			Type="Select"
			FKTable="#Request.dbprefix#_Topics"
			FKDescr="Topic" />
	</lh:MS_TableChild>

	<lh:MS_TableColumn
		ColName="TemplateID"
		DispName="Template"
		Type="Select"
		FKTable="#Request.dbprefix#_Templates"
		FKDescr="name"
		View="No" />
	<!--- <lh:MS_TableColumn
		ColName="SectionID"
		DispName="Section"
		Type="Select"
		FKTable="#Request.dbprefix#_Sections"
		FKDescr="Descr"
		View="Yes"
		Editable="Yes"
		HelpText="Any page that is the child of another page will automatically inherit the section of its parent.  Therefore, only change the section if this a top level page." /> --->
		
	<lh:MS_TableColumn
		ColName="SectionID"
		DispName="Page Section"
		type="select-multiple"
		FKTable="PageSectionsView"
		FKColName="SectionID"		
		FKDescr="Title"
		FKJoinTable="PageSections"
		SelectQuery="Select SectionID as SelectValue, Title as SelectText From PageSectionsView Order By OrderNum"
		Required="Yes" />
		
	<lh:MS_TableColumn
		ColName="KeywordID"
		DispName="Page Keywords"
		type="select-multiple"
		FKTable="Keywords"
		FKColName="KeywordID"		
		FKDescr="Title"
		FKJoinTable="PageKeywords"
		SelectQuery="Select KeywordID as SelectValue, Title as SelectText From Keywords Order By Title"
		Required="No" />
		
	<cfif url.version is "working">
		<lh:MS_TableColumn
			ColName="StatusID"
			DispName="Status"
			Type="Select"
			FKTable="#Request.dbprefix#_Statuses"
			FKDescr="descr"
			View="Yes"
			Editable="No" />
		<lh:MS_TableColumn
			ColName="CanDelete"
			DispName="Can Be Deleted"
			Type="checkbox"
			OnValue="1"
			OffValue="0"
			DefaultValue="1"
			View="No"
			AllowColumnEdit="Yes"
			HelpText="Uncheck this box to ensure that this page cannot be deleted using the site editor.  This is useful to protect section home pages from being deleted accidentally." />
	</cfif>

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
		ColName="ShowInNav"
		DispName="Show In Navigation"
		Type="checkbox"
		OnValue="1"
		OffValue="0"
		DefaultValue="1"
		View="No"
		HelpText="If checked, links to this page will appear in the navigation."/>

	<lh:MS_TableColumn
		ColName="UserGroupID"
		DispName="Member User Groups"
		Type="select-multiple"
		FKTable="#Request.dbprefix#_UserGroups"
		FKDescr="name"
		FKJoinTable="#Request.dbprefix#_PageUserGroups#tablesuffix#"
		View="No"
		HelpText="For members-only pages, select the user groups who have access to this page.  If no user groups are selected, the page will be available to all members."/>

	<lh:MS_TableColumn
		ColName="DateModified"
		Type="timestamp" />

	<cfif Request.dbtype is "mysql">
		<cfset expr = "(select actiondescr from #Request.dbprefix#_Pages_Audit where pageID = #Request.dbprefix#_Pages#tablesuffix#.PageID order by actionDate desc limit 1)">
	<cfelse>
		<cfset expr = "(select top 1 actiondescr from #Request.dbprefix#_Pages_Audit where pageID = #Request.dbprefix#_Pages#tablesuffix#.PageID order by actionDate desc)">
	</cfif>
	<lh:MS_TableColumn
		ColName="LastAction"
		DispName="Last Action"
		Type="Pseudo"
		Expression="#expr#" />

	<!---
	<lh:MS_TableAction
		ActionName="ListOrder"
		Type="ListOrder"
		DescriptionColumn="(select descr from sections s where s.sectionID = pages.sectionID) & ': ' & Name"
		Label="Put Pages in Order" />
	--->

	<lh:MS_TableRowAction
		ActionName="Edit"
		Label="View/Edit Properties" />

	<lh:MS_TableRowAction
		ActionName="History"
		Label="View History"
		Type="Custom"
		Href="index.cfm?adminFunction=pageAudit&pageID=##pk##" />

	<lh:MS_TableRowAction
		ActionName="EditContents"
		Label="Edit Content"
		Type="Custom"
		Href="index.cfm?adminFunction=editPage&pageID=##pk##" />

	<!--- Select action --->
	<lh:MS_TableRowAction
		ActionName="SelectParent"
		Label="Select"
		Type="Select"
		ColName="ParentPageID"
		Descr="#Request.dbprefix#_Pages#tablesuffix#.navTitle"
		ConditionalParam="SelectParentPage" />

</lh:MS_Table>


<cfif IsDefined("action") and url.version is "working">
	<cfif action is "Add" or action is "Edit">
		<script>
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
		<cfif Request.lh_useFriendlyUrls>
			<script type="text/javascript">
			function updateLink() {
				getEl("Link_TR").getElementsByTagName("TD")[1].innerHTML = "<cfoutput>#Request.HttpUrl#/</cfoutput>" + getUrlName();
				if (getEl("Name").value.toLowerCase() != getUrlName()) {
					alert("The page name is used to contruct the url for the page, and can therefore only contain letters, numbers, dashes or underscores.\nOther characters, such as spaces, are not allowed.")
					getEl("Name").value = getUrlName();
				}
			}
			function getUrlName() {
				return getEl("Name").value.toLowerCase().replace(/[^0-9a-z-_]/g,"");
			}
			getEl("Name").onkeyup = updateLink;
			</script>
		</cfif>
	</cfif>
</cfif>

<cfinclude template="footer.cfm">