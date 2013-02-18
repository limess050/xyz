<cfcomponent name="Row" hint="Defines a row in a data table" extends="Object">
	
	<cffunction name="Init" description="Instantiate a row." output="false" returntype="Row">
		<cfargument name="Properties" required="true" type="struct">
		<cfargument name="Table" required="true" type="struct">
		<cfset This.Values = Properties>
		<cfset This.Table = Table>
		<cfreturn This>
	</cffunction>
	
	<cffunction name="Create" description="Inserts a row in the database" output="false" returntype="void">
	</cffunction>
	
	<cffunction name="Update" description="Updates a row in the database" output="false" returntype="boolean">
		<cfset var QueryParam = StructNew()>
		<cfset var started = false>
		<cfquery name="updatePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			UPDATE #This.Table.table#
			SET 
				<cfloop collection="#This.Table.Columns#" item="colName">
					<cfif StructKeyExists(This,colName) and colName is not This.Table.PrimaryKey>
						<cfset QueryParam = This.Table.Columns[colName].getQueryParam(true,This[colName])>
						<cfif started>,</cfif>
						#colName# = <cfqueryparam cfsqltype="#This.Table.Columns[colName].CfSqlType#" null="#QueryParam.IsNull#" value="#QueryParam.Value#">
						<cfset started = true>
					</cfif>
				</cfloop>
			WHERE #This.Table.PrimaryKey# = <cfqueryparam value="#This[This.Table.PrimaryKey]#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfreturn true>
	</cffunction>

	<cffunction name="Delete" description="Deletes a row in the database" output="false" returntype="void">
	</cffunction>
</cfcomponent>