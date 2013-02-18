<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<cfoutput>
<html>
<head>
<cfinclude template="../headerIncludes.cfm">
<title>#pg_title#</title>
<script>
if (opener != null) opener.name = "opener";
</script>
<script type="text/javascript">
var tabs, propertyGroups;
function initializeTabs(e) {
	//Initialize tabs and property groups
	if (getEl("tabs") && getEl("properties")) {
		tabs = getEl("tabs").getElementsByTagName("SPAN");
		propertyGroups = getEl("properties").getElementsByTagName("DIV");
		for (var i = 0; i < tabs.length; i ++) {
			tabs[i].onclick = selectTab;
		}
	}
}
function selectTab(e) {
	var tab = xGetEventSrcElement(e);

	for (var i = 0; i < propertyGroups.length; i ++) {
		if (propertyGroups[i].id + "tab" == tab.id) {
			propertyGroups[i].className = "selected";
			tab.className = "selected";
		} else if (getEl(propertyGroups[i].id + "tab") != null) {
			propertyGroups[i].className = "unselected";
			getEl(propertyGroups[i].id + "tab").className = "unselected";
		}
	}
}
xAddEvent(window,"load",initializeTabs);
</script>
</head>
<body id="dialog" class="NORMALTEXT">
</cfoutput>
