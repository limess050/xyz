<cfinclude template="../checkLogin.cfm">
<cfset checkPermissionFunction = "editPage">
<cfinclude template="../checkPermission.cfm">

<cfparam name="action" default="goToPage">
<cfset dialogType = "Go">
<cfset pg_title = "Go To Page">
<cfinclude template="header.cfm">

<script>
function go(pageID,name) {
<cfif action is "goToPage">
	opener.top.location.href = "index.cfm?adminFunction=editPage&pageID=" + pageID;
	window.close();
<cfelseif action is "getUrl">
	<cfif Request.lh_useFriendlyUrls>
		opener.document.getElementById("address").value = "<cfoutput>#Request.AppVirtualPath#</cfoutput>/" + name;
	<cfelse>
		opener.document.getElementById("address").value = "<cfoutput>#Request.AppVirtualPath#</cfoutput>/page.cfm?pageID=" + pageID;
	</cfif>
	window.close();
<cfelseif action is "selectMasterPage">
	mastePageIDField = opener.document.getElementById("masterPageID");
	mastePageIDField.value = pageID;
	mastePageIDField.form.submit();
	window.close();
</cfif>
}
</script>

<h1>Select a page</h1>

<div id="tabs"><span id="infotab" class="selected">Pages</span></div>
<div id="properties"><div id="info">
<cfinclude template="pageTree2.cfm">
</div></div>

<p>
<input type=button value=Cancel class="button" onclick="window.close(); return false;">
</p>
<cfinclude template="footer.cfm">
