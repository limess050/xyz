<!---
File Name: 	MS_TableColumn.cfm
Author: 	David Hammond
Description:
	Define a column
Inputs:
	ColName (required)
	DispName
	Type
	Length
	Validate
	View
	Search
--->
<cfif thisTag.executionMode is "start">
	<!--- Get base tag data --->
	<cfif ListGetAt(getBaseTagList(),2) is "CF_MS_TABLECHILD">
		<cfset data = GetBaseTagData("CF_MS_TABLECHILD")>
	<cfelse>
		<cfset data = GetBaseTagData("CF_MS_TABLE")>
	</cfif>
	<!--- Add column to table --->
	<cfset CreateObject("component","#Application.ComponentPath#.Column").Init(attributes,data.TableObject)>
</cfif>