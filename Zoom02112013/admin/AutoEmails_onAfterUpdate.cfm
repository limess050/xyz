<!--- Search and replace any relative links. --->

<cfquery name="getBody" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select Body
	From AutoEmails
	Where AutoEmailID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>

<cfset EmailBody=getBody.Body>
<cfset EmailBody = replaceNoCase(EmailBody,' src="/',' src="#Request.httpurl#/','all')>
<cfset EmailBody = replaceNoCase(EmailBody,' href="/',' href="#Request.httpurl#/','all')>

<cfquery name="updateBody" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Update AutoEmails
	Set Body=<cfqueryparam value="#EmailBody#" cfsqltype="CF_SQL_VARCHAR">
	Where AutoEmailID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>
