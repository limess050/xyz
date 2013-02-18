<cfcomponent name="TableAction" hint="Defines an action that can be performed on an entire table.">

	<cfinclude template="../Functions/LighthouseLib.cfm">

	<cffunction name="Init" description="Instantiate a table action." output="false" returntype="TableAction">
		<cfargument name="Properties" required="true" type="struct">
		<cfargument name="Table" required="true" type="struct">

		<cfset This.Name = Properties.ActionName>
		
		<cfif Not StructKeyExists(Table.Actions,This.Name)>
			<cfset ArrayAppend(Table.ActionOrder,This.Name)>
		</cfif>
		<cfset Table.Actions[This.Name] = This>

		<cfset This.Type = GetProperty(Properties,"Type",This.Name)>
		<cfset This.Label = GetProperty(Properties,"Label",This.Name)>
		<cfset This.ConditionalParam = GetProperty(Properties,"ConditionalParam","")>
		<cfset This.Layout = GetProperty(Properties,"Layout","")>
		<cfset This.Target = GetProperty(Properties,"Target","")>
	
		<cfif Len(This.ConditionalParam)>
			<cfif StructKeyExists(url,This.ConditionalParam)>
				<cfset Table.persistentParams = addQueryParam(Table.persistentParams,This.ConditionalParam,url[This.ConditionalParam])>
			</cfif>
		</cfif>
	
		<cfswitch expression="#This.Type#">
			<cfcase value="ListOrder">
				<cfset This.DescriptionColumn = GetProperty(Properties,"DescriptionColumn","Descr")>
				<cfset This.OrderColumn = GetProperty(Properties,"OrderColumn","OrderNum")>
				<cfset This.SelectQuery = GetProperty(Properties,"SelectQuery","")>
				<cfif Not StructKeyExists(url,"orderBy")>
					<cfset url.orderBy = Table.table & "." & This.OrderColumn>
				</cfif>
			</cfcase>
			<cfcase value="Custom">
				<cfset This.Href = GetProperty(Properties,"Href","")>
			</cfcase>
		</cfswitch>
		<cfreturn This>
	</cffunction>

</cfcomponent>