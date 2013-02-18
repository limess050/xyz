<!---
File Name: 	headerIncludes.cfm
Author: 	David Hammond
Description:
--->

<cfif not IsDefined("Request.AppVirtualPath") >
	<cfset Request.AppVirtualPath = "">
</cfif>
<cfif not IsDefined("Request.MCFStyle")>
	<cfset Request.MCFStyle = "MSStandard">
</cfif>
<cfheader name="Content-Type" value="text/html; charset=UTF-8">
<cfoutput>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script type="text/javascript">
var AppVirtualPath = "#Request.AppVirtualPath#";
var MCFResourcesPath = "#Request.AppVirtualPath#/Lighthouse/Resources";
</script>
<script type="text/javascript" src="#Request.AppVirtualPath#/Lighthouse/dojo/dojo.js"></script>
<script type="text/javascript" src="#Request.AppVirtualPath#/Lighthouse/Resources/js/lighthouse_all.js"></script>
<link rel=stylesheet href="#Request.AppVirtualPath#/Lighthouse/Resources/css/#Request.MCFStyle#.css" type="text/css">
</cfoutput>
