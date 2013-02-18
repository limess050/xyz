
<cfquery name="updateUpdateFields" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Update News
	Set DateUpdated=#application.CurrentDateInTZ#,
	UpdatedByID=<cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">
	Where NewsID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>
