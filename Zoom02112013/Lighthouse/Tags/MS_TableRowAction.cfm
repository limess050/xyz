<!---
File Name: 	MS_TableRowAction.cfm
Author: 	David Hammond
Description:
	Define a custom action
Inputs:
--->
<cfif thisTag.executionMode is "start">
	<cfset data = GetBaseTagData("CF_MS_TABLE")>
	<cfset CreateObject("component","#Application.ComponentPath#.RowAction").Init(attributes,data.TableObject)>
</cfif>