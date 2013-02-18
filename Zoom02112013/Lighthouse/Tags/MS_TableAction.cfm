<!---
File Name: 	MS_TableAction.cfm
Author: 	David Hammond
Description:
	Define a custom action
Inputs:

--->
<cfsilent>
<cfif thisTag.executionMode is "start">
	<cfset data = GetBaseTagData("CF_MS_TABLE")>
	<cfset CreateObject("component","#Application.ComponentPath#.TableAction").Init(attributes,data.TableObject)>
</cfif>
</cfsilent>