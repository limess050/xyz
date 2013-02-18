<cfquery name="updatedBy" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Insert into Updates
	(UserID, UpdateDate, UpdatedByID, Descr)
	VALUES
	(<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">,
	GetDate(),
	<cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">,
	'Account Created')
</cfquery>

<cfquery name="updateUsername" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Update LH_Users
	Set Username=ContactEmail
	Where UserID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>
