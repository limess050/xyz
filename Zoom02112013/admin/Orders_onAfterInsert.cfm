<cfquery name="updatedBy" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Insert into Updates
	(OrderID, UpdateDate, UpdatedByID, Descr)
	VALUES
	(<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">,
	GetDate(),
	<cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">,
	'Order Created')
</cfquery>
