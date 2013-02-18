<cfcomponent name="User" hint="Defines a user." extends="Row">

	<cffunction name="GetName" description="Gets a section name." output="false" returntype="String">
		<cfargument name="sectionID" type="numeric" required="true">

		<cfif arguments.sectionID gt 0>
			<cfquery name="getSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT descr
				FROM #Request.dbprefix#_Sections
				WHERE sectionID = <cfqueryparam value="#arguments.sectionID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<cfif getSection.recordcount gt 0>
				<cfreturn getSection.descr>
			</cfif>
		</cfif>
		<cfreturn "">
	</cffunction>
</cfcomponent>