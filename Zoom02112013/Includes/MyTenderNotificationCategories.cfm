<cfquery name="getTenderNotificationCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select C.CategoryID, C.Title as Category
	From UserCategories UC 
	Inner Join Categories C on UC.CategoryID=C.CategoryID
	Where C.Active=1
	and UC.UserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">	
	Order By C.OrderNum
</cfquery>
