
<cfquery name="updateUsername" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Update LH_Users
	Set Username=ContactEmail
	Where UserID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>
