
<cfquery name="updateAddedByID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Update News
	Set AddedByID=<cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">
	Where NewsID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>
