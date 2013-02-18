<cfimport prefix="lh" taglib="../../Tags">

<cfinclude template="../checkLogin.cfm">
<cfset checkPermissionFunction = "editPage">
<cfinclude template="../checkPermission.cfm">

<cfset pg_title = "Page Properties">
<cfinclude template="header.cfm">

<cfparam name="action" default="Edit">
<cfparam name="statusMessage" default="Edit page properties here.  For more options, <a href=""index.cfm?adminFunction=pages&action=Edit&pk=#pk#"" onclick=""window.resizeTo(750,550);"">click here</a>.">

<style>
#AddEditFormTopButtons,.ACTIONBUTTONTABLE { display:none; }
.STATUSMESSAGE { font-size:13px; }
</style>

<lh:MS_Table
	table="#Request.dbprefix#_Pages"
	title="#pg_title#"
	persistentparams="adminFunction=dialogs%2Fproperties"
	allowedActions="Add,Edit,View">

	<lh:MS_TableColumn
		ColName="PageID"
		type="integer"
		PrimaryKey="true"
		View="No"
		hidden="yes"/>

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
			Expression="('#Request.HttpUrl#/' + name)" 
			ShowOnEdit="true" />
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

	<lh:MS_TableColumn
		ColName="ShowInNav"
		DispName="Show In Navigation"
		Type="checkbox"
		OnValue="1"
		OffValue="0"
		DefaultValue="1"
		HelpText="If checked, links to this page will appear in the navigation."/>
		
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

	<lh:MS_TableEvent
		EventName="onAfterUpdate"
		Include="../Admin/dialogs/properties_onAfterUpdate.cfm"/>

</lh:MS_Table>

<cfif Request.lh_useFriendlyUrls>
	<script type="text/javascript">
	function updateLink() {
		getEl("Link_TR").getElementsByTagName("TD")[1].innerHTML = "<cfoutput>#Request.HttpUrl#/</cfoutput>" + getUrlName();
		if (getEl("Name").value.toLowerCase() != getUrlName()) {
			alert("The page name is used to contruct the url for the page, and can therefore only contain letters, numbers, dashes or underscores.\nOther characters, such as spaces, are not allowed.");
			getEl("Name").value = getUrlName();
		}
	}
	function getUrlName() {
		return getEl("Name").value.toLowerCase().replace(/[^0-9a-z-_]/g,"");
	}
	getEl("Name").onkeyup = updateLink;
	</script>
</cfif>

<cfinclude template="footer.cfm">