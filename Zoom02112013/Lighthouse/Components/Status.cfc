<cfcomponent name="Status" hint="Handles statuses." extends="Object">

	<cffunction name="GetForUser" description="Gets a list of statuses available to a user" output="false" returntype="Query">
		<cfargument name="userID" type="numeric" required="true">
		<cfquery name="Statuses" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT s.statusID,s.descr
			FROM #Request.dbprefix#_UserStatus us 
				INNER JOIN #Request.dbprefix#_Statuses s ON us.statusID = s.statusID
			WHERE us.userID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#">
			ORDER BY orderNum
		</cfquery>
		<cfreturn Statuses>	
	</cffunction>
	
</cfcomponent>