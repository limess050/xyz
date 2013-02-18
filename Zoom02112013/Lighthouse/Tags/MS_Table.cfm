<!---
File Name: 	TableObject.cfm
Author: 	David Hammond
Description:
	Main display tag
Inputs:
	table (required)
	dsn (required)
	action (opt)
	template (opt)
--->
<cfif thisTag.executionMode is "start">
	<cfset TableObject = CreateObject("component","#Application.ComponentPath#.Table").Init(attributes)>
<cfelseif thisTag.executionMode is "end">
	<cfif StructKeyExists(Attributes,"VariableName")>
		<cfset SetVariable(Attributes.VariableName,TableObject)>
	<cfelse>
		<cfset TableObject.render(PageVariables=caller)>
	</cfif>
</cfif>