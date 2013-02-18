<!--- Search and replace any relative links. --->

<cfquery name="getCheckInText" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select CheckInText
	From ListingTypes
	Where ListingTypeID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>

<cfset CheckInText=getCheckInText.CheckInText>
<cfset CheckInText = replaceNoCase(CheckInText,' src="/',' src="#Request.httpurl#/','all')>
<cfset CheckInText = replaceNoCase(CheckInText,' href="/',' href="#Request.httpurl#/','all')>

<cfquery name="updateCheckInText" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Update ListingTypes
	Set CheckInText=<cfqueryparam value="#CheckInText#" cfsqltype="CF_SQL_VARCHAR">
	Where ListingTypeID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>
