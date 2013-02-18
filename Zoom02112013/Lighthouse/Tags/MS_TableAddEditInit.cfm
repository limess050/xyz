<!---
File Name: 	MS_TableAddEdit.cfm
Author: 	David Hammond
Description:

Inputs:
--->
<cfsilent>
<cfif IsDefined("pk")>
	<cfquery name="q" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT #Request.Table.table#.*
		<!--- Select special columns, if any --->
		<cfloop index="i" from="1" to="#ArrayLen(Request.Table.SpecialColumns)#"><cfset specColExpr = Request.Table.SpecialColumns[i].Expression>
			,#PreserveSingleQuotes(specColExpr)# as #Request.Table.SpecialColumns[i].Name#
		</cfloop>
		FROM #Request.Table.table# 
		WHERE #Request.Table.PrimaryKey# = <cfqueryparam cfsqltype="#Request.Table.Columns[Request.Table.PrimaryKey].CfSqlType#" value="#pk#">
	</cfquery>
<cfelse>
	<cfset pk = 0>
</cfif>

<!--- Initialize variables --->
<cfloop index="colNum" from="1" to="#ArrayLen(Request.Table.ColumnOrder)#">
	<cfset Column = Request.Table.Columns[Request.Table.ColumnOrder[colNum]]>
	<cfif Not ListFindNoCase("select-multiple,select-multiple-popup,checkboxgroup,Pseudo,ChildTable",Column.Type)>
		<cfif Request.Table.action is "Add">
			<cfset foo = SetVariable(Column.Name,Column.DefaultValue)>
			<!---
			If a column is not editable and has no default value then:
			if the column is required, it is made editable (because add would otherwise be impossible)
			if the column is not required, then the column is hidden
			--->
			<cfif Len(Column.defaultValue) is 0 and not Column.Editable>
				<cfif Column.Required>
					<cfset Column.Editable = true>
				<cfelse>
					<cfset Column.Hidden = true>
				</cfif>
			</cfif>
			<!--- Display error --->
			<cfif Column.Required and Column.Hidden and Len(Column.defaultValue) is 0>
				<cfset lighthouse_addError("The #Column.DispName# column is required, hidden, and has no default value.  If a column must be required and hidden, you must supply a default value.")>
			</cfif>
		<cfelse>
			<cfset foo = SetVariable(Column.Name,q[Column.Name])>
			<!--- Check editable property --->
			<cfif Len(Evaluate(Column.Name)) is 0 and Column.Required and not Column.Editable><cfset Column.Editable = true></cfif>
		</cfif>
	</cfif>
</cfloop>

<!--- Set special columns --->
<cfloop index="i" from="1" to="#ArrayLen(Request.Table.SpecialColumns)#">
	<cfif Request.Table.action is "Edit">
		<cfset foo = SetVariable(Request.Table.SpecialColumns[i].Name,Evaluate("q.#Request.Table.SpecialColumns[i].Name#"))>
	</cfif>
</cfloop>
</cfsilent>