<cfquery name="testQuery" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT TOP 1 PageID FROM #Request.dbprefix#_Pages
</cfquery>OK