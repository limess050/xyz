<cfcomponent name="UserGroup" hint="Handles user groups." extends="Object">

	<cffunction name="GetAll" description="Gets a list of all available user groups" output="false" returntype="Query">
		<cfquery name="UserGroups" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT userGroupID,name FROM #Request.dbprefix#_UserGroups ORDER BY name
		</cfquery>
		<cfreturn UserGroups>	
	</cffunction>

</cfcomponent>