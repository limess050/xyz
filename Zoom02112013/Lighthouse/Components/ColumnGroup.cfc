<cfcomponent name="ColumnGroup" hint="Defines a group of columns in a table.">

	<cfinclude template="../Functions/LighthouseLib.cfm">

	<cffunction name="Init" description="Instantiate a column group." output="false" returntype="ColumnGroup">
		<cfargument name="Properties" required="true" type="struct">
		<cfargument name="Table" required="true" type="struct">

		<cfset This.Name = Properties.GroupName>		
		<cfset This.Label = GetProperty(Properties,"Label",This.Name)>
		<cfset Table.ColumnGroups[This.Name] = This>

		<cfreturn This>
	</cffunction>

</cfcomponent>