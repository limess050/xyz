<cfquery name="GetCurrent" datasource="#request.dsn#">
	UPDATE Messages
	SET Reviewed = 1
	WHERE MessageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>