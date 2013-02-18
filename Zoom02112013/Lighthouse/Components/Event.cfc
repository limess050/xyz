<cfcomponent name="Event" hint="Defines an event.">

	<cfinclude template="../Functions/LighthouseLib.cfm">

	<cffunction name="Init" description="Instantiate an event." output="false" returntype="Event">
		<cfargument name="Properties" required="true" type="struct">
		<cfargument name="Table" required="true" type="struct">

		<cfset This.Name = Properties.EventName>
		<cfset This.Include = GetProperty(Properties,"Include","")>

		<cfif Len(Properties.EventName) and Len(Properties.Include)>
			<cfif Not StructKeyExists(Table.events,Properties.EventName)>
				<cfset Table.events[This.Name] = This>
			</cfif>
		</cfif>
		
		<cfreturn This>
	</cffunction>

</cfcomponent>