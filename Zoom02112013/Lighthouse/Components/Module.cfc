<cfcomponent name="Module" hint="Base class for modules.  All modules should extend this class." extends="Object">

	<cffunction name="Install" description="Installs the module." output="false" returntype="boolean">
		<cfreturn false>
	</cffunction>

	<cffunction name="IsInstalled" description="Performs a test to see if the module is installed." output="false" returntype="boolean">
		<cfreturn false>
	</cffunction>

	<cffunction name="Load" description="Performs any action necessary to make the module available for use." output="false" returntype="boolean">
		<cfreturn false>
	</cffunction>

</cfcomponent>