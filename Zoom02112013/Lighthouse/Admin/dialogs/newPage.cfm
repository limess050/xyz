<cfinclude template="../checkLogin.cfm">
<cfset checkPermissionFunction = "editPage">
<cfinclude template="../checkPermission.cfm">

<cfquery name="getTemplates" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT templateID,name,defaultTemplate FROM #Request.dbprefix#_Templates ORDER BY name
</cfquery>
<cfquery name="getUserGroups" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT userGroupID,name FROM #Request.dbprefix#_UserGroups ORDER BY name
</cfquery>

<cfset pg_title = "Create a New Page">
<cfinclude template="header.cfm">

<script type="text/javascript">
var nameTitleLock = true;
var nameNavTitleLock = true;
function initPage(e) {
	getEl("pLinkPublic").style.display = "none";
	if (getEl("pUserGroups")) {
		getEl("pUserGroups").style.display = "none";
	}
	getEl("membersOnly").onclick = moChecked;
	getEl("name").onfocus = setNameLock;
	getEl("name").onkeyup = nameChanged;
}
function moChecked(e) {
	if (getEl("membersOnly").checked) {
		getEl("pLinkPublic").style.display = "";
		if (getEl("pUserGroups")) {
			getEl("pUserGroups").style.display = "";
		}
	} else {
		getEl("pLinkPublic").style.display = "none";
		if (getEl("pUserGroups")) {
			getEl("pUserGroups").style.display = "none";
		}
	}
}
function setNameLock() {
	nameTitleLock = (getEl("title").value == getEl("name").value);
	nameNavTitleLock = (getEl("navTitle").value == getEl("name").value);
}
function nameChanged() {
	<cfif Request.lh_useFriendlyUrls>
		getEl("urlName").innerHTML = getUrlName();
	</cfif>
	if (nameTitleLock) {
		getEl("title").value = getEl("name").value;
	}
	if (nameNavTitleLock) {
		getEl("navTitle").value = getEl("name").value;
	}
}
function getUrlName() {
	return getEl("name").value.toLowerCase().replace(/[^0-9a-z-_\/]/g,"");
}

function doAdd(){
	opener.setPageStatus("Adding page.")
	setTimeout('window.close()',1000)
}
xAddEvent(window,"load",initPage);
</script>

<cfscript>
if (len(parentPageID) is 0) {
	parentPageID = #currentPageID#;
}
</cfscript>

<h1>Create a New Page</h1>

<cfoutput>
<form action="#Request.AppVirtualPath#/Lighthouse/Admin/pageHiddenForm.cfm" method="post" target="postback" onsubmit="doAdd()">
<input type="hidden" name="savePage" value="true">
<input type="hidden" name="newPage" value="true">
<input type="hidden" name="parentPageID" value="#parentPageID#">
<input type="hidden" name="sectionID" value="#sectionID#">

<div id="tabs">
	<span id="infotab" class="selected">Info</span>
	<!--<span id="advancedtab" class="unselected">Permissions</span>-->
</div>

<div id="properties">
	<div id="info">
		<p><label for="template"><b>Select a template:</b></label><br/>
		<select id="template" name="templateID"><cfloop query="getTemplates">
		<option value="#templateID#" <cfif defaultTemplate is "Y">selected</cfif>>#name#</option></cfloop></select></p>

		<p><label for="name"><b>Provide a unique name for the new page:</b></label><br/>
		<input type="text" size=50 id="name" name="name" value=""></p>
		
		<cfif Request.lh_useFriendlyUrls>
			<p><b>Page Url:</b> #Request.HttpUrl#/<span id="urlName"></span></p>
		</cfif>

		<p><label for="title"><b>Page Title:</b></label><br/>
		<input type="text" size=50 id="title" name="title" value=""></p>

		<p><label for="navTitle"><b>Navigation Title:</b></label><br/>
		<input type="text" size=50 id="navTitle" name="navTitle" value=""></p>

		<p><label for="ShowInNav"><b>Show in Navigation:</b></label><input type="checkbox" id="ShowInNav" name="ShowInNav" value="1" checked="true"></p>

	<!-- </div>
	<div id="advanced" class="unselected"> -->
	
		<p><label for="membersOnly"><b>Members Only:</b></label><input type="checkbox" id="membersOnly" name="membersOnly" value="1"></p>

		<p id="pLinkPublic"><label for="linkPublic"><b>Show Link to Public:</b></label><input type="checkbox" id="linkPublic" name="linkPublic" value="1"></p>

		<cfif getUserGroups.recordCount gt 0>
			<p id="pUserGroups"><label for="userGroups"><b>Member User Groups:</b></label><br/>
			<select id="userGroups" name="userGroupID" size="#getUserGroups.recordCount#" multiple="true"><cfloop query="getUserGroups">
			<option value="#userGroupID#">#name#</option></cfloop></select></p>
		</cfif>
	</div>
</div>

<p>
<input type=submit value=OK class="button">
<input type=button value=Cancel class="button" onclick="window.close(); return false;">
</p>

</form>
</cfoutput>

<cfinclude template="footer.cfm">
