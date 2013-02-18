<cfcomponent name="Topic" hint="Handles topics." extends="Object">

	<cffunction name="GetRow" description="Gets a topic" output="false" returntype="Query">
		<cfargument name="id" type="numeric" required="true">
		<cfquery name="row" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT topic
			FROM #Request.dbprefix#_Topics
			WHERE topicID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfreturn row>	
	</cffunction>

	<cffunction name="GetAll" description="Gets a list of all available topics" output="false" returntype="Query">
		<cfargument name="search" type="string" default="">
		<cfquery name="topics" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT topicID,topic
			FROM #Request.dbprefix#_Topics
			<cfif Len(Arguments.search) gt 0>
				WHERE topic like <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.search#%">
			</cfif>
			ORDER BY topic
		</cfquery>
		<cfreturn topics>	
	</cffunction>
	
	<cffunction name="GetAllActive" description="Gets a list of all topics associated to live pages." output="false" returntype="Query">
		<cfquery name="topics" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT topicID,topic
			FROM #Request.dbprefix#_Topics t
			WHERE topicID IN (SELECT topicID FROM #Request.dbprefix#_PageTopics_Live)
			ORDER BY topic
		</cfquery>
		<cfreturn topics>	
	</cffunction>

	<cffunction name="GetForPage" description="Gets all topics associated to a page" output="false" returntype="Query">
		<cfargument name="pageID" type="numeric" required="true">
		<cfquery name="topics" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT t.topicID,t.topic
			FROM #Request.dbprefix#_Topics t INNER JOIN #Request.dbprefix#_PageTopics_Live p ON t.topicID = p.topicID
			WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageID#">
			ORDER BY topic
		</cfquery>
		<cfreturn topics>	
	</cffunction>
</cfcomponent>