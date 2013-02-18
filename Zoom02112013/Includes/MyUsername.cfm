
<cfquery name="getMyUsername" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select Username, ContactFirstName, ContactLastName
	From LH_Users
	Where UserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>





