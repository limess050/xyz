<cfcomponent name="ChildTable" hint="Defines an child table." extends="Object">
	<cffunction name="Init" description="Instantiate a child table." output="false" returntype="ChildTable">
		<cfargument name="Properties" required="true" type="struct">
		<cfargument name="Table" required="true" type="struct">

		<cfscript>
		This.PrimaryKey = "";
		This.Columns = StructNew();
		This.ColumnOrder = ArrayNew(1);
		This.Name = Properties.Name;
		This.Type = "ChildTable";
		This.AllowColumnEdit = false;
		SetProperty(Properties,"editable",true);
	
		//general column parameters
		This.Order = StructCount(Table.Columns);
		This.View = false;
		This.ColumnGroup = Table.CurrentColumnGroup;
		This.CurrentColumnGroup = This.ColumnGroup;
		ArrayAppend(Table.ColumnOrder,This.Name);
	
		SetProperty(Properties,"DispName",Properties.Name);
		SetProperty(Properties,"EditByDefault",true);
		SetProperty(Properties,"OrderBy","");
		SetProperty(Properties,"Required",false);
	
		This.Validate = "";
		This.SpellCheck = false;
		This.Unique = false;
		SetProperty(Properties,"Editable",Table.editable);
		
		if (StructKeyExists(Properties,"View")) This.DefaultView = Properties.View;
		else This.DefaultView = true;
		
		SetProperty(Properties,"AllowView",true);
		SetProperty(Properties,"Search",false);
		if (Not This.Search) {
			for (ChildColumn in This.Columns) {
				This.Columns[ChildColumn].Search = false;
			}
		}
		SetProperty(Properties,"StyleID",false);
		SetProperty(Properties,"HelpText","");
		This.ShowTotal = false;
		SetProperty(Properties,"Hidden",false);
		SetProperty(Properties,"AllowColumnEdit",Table.AllowColumnEdit);
		SetProperty(Properties,"OrderColumn","");
		This.ParentColumn = "";
		This.ChildColumn = "";
	
		//add column to main list
		Table.Columns[Properties.Name] = This;
		</cfscript>
		<cfreturn This>
	</cffunction>

	<cffunction name="getValueFromQuery" output="false" returntype="string">
		<cfargument name="valueQuery" type="Query" default="#getRecords#">
		<cfargument name="MainQueryInfo" type="Struct">
	
		<!--- Get child table values --->
		<!--- CF automatically escapes single quotes in structure variables, but
			perversely doesn't allow dynamic structure variables in the preserveSingleQuotes function --->
		<cfset childTableSelectClause = Request.ChildTableQueryInfo[This.Name].selectClause>
		<cfquery name="childTableValues" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT #preserveSingleQuotes(childTableSelectClause)#
			FROM #Request.ChildTableQueryInfo[This.Name].fromClause#
			WHERE #Request.Table.PrimaryKey# = <cfqueryparam cfsqltype="cf_sql_integer" value="#valueQuery[Request.Table.PrimaryKey][valueQuery.CurrentRow]#">
			<cfif Len(This.OrderColumn) gt 0>
				ORDER BY #This.Name#.#This.OrderColumn#
			<cfelseif Len(This.OrderBy) gt 0>
				ORDER BY #This.OrderBy#
			</cfif>
		</cfquery>
		<cfif childTableValues.recordCount gt 0>
			<cfset value = "<table class=childtableview>" & Request.ChildTableQueryInfo[This.Name].tableHeader>
			<cfloop query="childTableValues">
				<cfset value = value & "<tr>">
				<cfloop index="childTableColNum" from="1" to="#ArrayLen(Request.ChildTableQueryInfo[This.Name].ViewColumns)#">
					<cfset value = value & "<td>" & Request.ChildTableQueryInfo[This.Name].ViewColumns[childTableColNum].getValueFromQuery(childTableValues) & "</td>">
				</cfloop>
				<cfset value = value & "</tr>">
			</cfloop>
			<cfset value = value & "</table>">
		<cfelse>
			<cfset value = "">
		</cfif>
		<cfreturn value>
	</cffunction>
	
	<cffunction name="getTotal" output="false" returntype="string">
		<cfreturn "">
	</cffunction>

</cfcomponent>