<!---
File Name: 	MS_TableChild.cfm
Author: 	David Hammond
Description:
	Use to define a child table, i.e. a table with a many-to-one relationship to the main table
Inputs:
	table (required)
--->

<!--- Get base tag data --->
<cfset data = GetBaseTagData("CF_MS_Table")>

<cfif thisTag.executionMode is "start">
	<!--- Add column to table --->
	<cfset TableObject = CreateObject("component","#Application.ComponentPath#.ChildTable").Init(attributes,data.TableObject)>
</cfif>
