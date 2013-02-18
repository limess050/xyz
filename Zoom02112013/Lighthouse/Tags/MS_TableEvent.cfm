<!---
File Name: 	MS_TableEvent.cfm
Author: 	David Hammond
Description:
	Specify actions to take when an event occurs
Inputs:
	Event
		onBeforeInsert
		onBeforeUpdate
		onAfterInsert
		onAfterUpdate
	Include - cf template to include
--->
<cfsilent>
<cfif thisTag.executionMode is "start">
	<cfset data = GetBaseTagData("CF_MS_TABLE")>
	<cfset CreateObject("component","#Application.ComponentPath#.Event").Init(attributes,data.TableObject)>
</cfif>
</cfsilent>