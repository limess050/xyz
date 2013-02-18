<cfcomponent name="Object" hint="Base Lighthouse object.">

	<cffunction name="SetProperty" description="Sets the property from struct, using default if it's not defined." output="false" returntype="void">
		<cfargument name="Properties" required="true" type="Struct">
		<cfargument name="Property" required="true" type="String">
		<cfargument name="DefaultValue" required="true" type="Any">
		<cfif StructKeyExists(Properties,Property)>
			<cfset This[Property] = Properties[Property]>
		<cfelse>
			<cfset This[Property] = DefaultValue>
		</cfif>
	</cffunction>

	<cffunction name="GetInstance" description="Gets an instance of the object." output="false" returntype="Object">
		<cfreturn This>
	</cffunction>

</cfcomponent>