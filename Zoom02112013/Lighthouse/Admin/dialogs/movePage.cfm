<cfinclude template="../checkLogin.cfm">
<cfset checkPermissionFunction = "editPage">
<cfinclude template="../checkPermission.cfm">

<cfparam name="currentpageid" default="">
<cfset dialogType = "Move">
<cfset pg_title = "Move Page">
<cfinclude template="header.cfm">

<script>
function go(pageID,parentPageID,subordernum) {
	switch (document.f1.placement.options[document.f1.placement.selectedIndex].value) {
		case "child" :
			newParentPageID = pageID;
			newSubordernum = 999;
			break;
		case "above" :
			newParentPageID = parentPageID;
			newSubordernum = subordernum - 0.5;
			break;
		case "below" :
			newParentPageID = parentPageID;
			newSubordernum = subordernum + 0.5;
			break;
	}
	opener.getEl("postback").contentWindow.getEl("toolbarForm").parentpageid.value = newParentPageID;
	opener.getEl("postback").contentWindow.getEl("toolbarForm").subordernum.value = newSubordernum;
	opener.getEl("postback").contentWindow.getEl("toolbarForm").movePage.value = "true";
	opener.saveChanges();
	window.close();
}
</script>

<h1>Move page:</h1>

<div id="tabs"><span id="infotab" class="selected">Pages</span></div>
<div id="properties"><div id="info">
<form name="f1">
<select name="placement">
	<option value="child">Move page to child of selected page</option>
	<option value="above">Move page above selected page</option>
	<option value="below">Move page below selected page</option>
</select>
<cfinclude template="pageTree2.cfm">
</form>
</div></div>

<p>
<input type=button value=Cancel class="button" onclick="window.close(); return false;">
</p>
<br/>
<cfinclude template="footer.cfm">
