
<cfif IsDefined('pk') and Len(pk)>
	<cfquery name="MarkConfirmed" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Update LH_Users
		Set ConfirmedDate = <cfqueryparam cfsqltype="cf_sql_date" value="#application.CurrentDateInTZ#">
		Where UserID = <cfqueryparam cfsqltype="cf_sql_integer" value="#PK#">
		and ConfirmedDate is null
	</cfquery>
</cfif>
<cflocation url="Accounts.cfm?Action=edit&PK=#PK#&statusMessage=#UrlEncodedFormat("Account Confirmed")#" addToken="No">
<cfabort>