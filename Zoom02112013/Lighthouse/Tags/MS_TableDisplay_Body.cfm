<!---
File Name: 	MS_TableDisplay_*.cfm
Author: 	David Hammond
Description:
	Display tag
Inputs:
--->
<!--- Include the appropriate template --->
<cfswitch expression="#ActionStruct.Type#">
	<cfcase value="View">
		<cfinclude template="MS_TableView.cfm">
	</cfcase>
	<cfcase value="Search">
		<cfinclude template="MS_TableSearch.cfm">
	</cfcase>
	<cfcase value="Add">
		<cfinclude template="MS_TableAddEdit.cfm">
	</cfcase>
	<cfcase value="Edit">
		<cfinclude template="MS_TableAddEdit.cfm">
	</cfcase>
	<cfcase value="Delete">
		<cfinclude template="MS_TableDelete.cfm">
	</cfcase>
	<cfcase value="DisplayOptions">
		<cfinclude template="MS_TableDisplayOptions.cfm">
	</cfcase>
	<cfcase value="ListOrder">
		<cfinclude template="MS_TableListOrder.cfm">
	</cfcase>
</cfswitch>