<!---
File Name: 	MS_TableColumnGroup.cfm
Author: 	David Hammond
Description:
	Define a column group
Inputs:
	GroupName (required)
--->

<cfif thisTag.executionMode is "start">

	<!--- Get base tag data --->
	<cfset data = GetBaseTagData("CF_MS_Table")>
	<!--- Create new column structure and set attributes. --->
	<cfset CreateObject("component","#Application.ComponentPath#.ColumnGroup").Init(attributes,data.TableObject)>
	<cfset data.TableObject.CurrentColumnGroup = data.TableObject.ColumnGroups[Attributes.GroupName].Name>

<cfelse>

	<cfset data.TableObject.CurrentColumnGroup = "">

</cfif>