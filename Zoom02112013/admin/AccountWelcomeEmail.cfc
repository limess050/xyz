
<cfsetting showdebugoutput="no">

<cffunction name="SendEmail" access="remote" returntype="string" displayname="Sends the Welcome email">
	<cfargument name="PK" type="numeric" required="yes">

	<cfquery name="getAccount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select UserID, UserName, ContactEmail, Password, Company, AltContactEmail
		From LH_Users
		Where UserID=<cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif Request.environment is "Live" or Request.environment is "Devel" or Request.environment is "DB">
		<cfset NewAccountID=getAccount.UserID>
		<cfset NewAccountName=getAccount.Company>
		<cfset NewUserName=getAccount.ContactEmail>
		<cfif Len(getAccount.AltContactEmail)>
			<cfset NewUserName=ListAppend(NewUserName,getAccount.AltContactEmail)>
		</cfif>
		<cfset NewPassword=getAccount.Password>
		<cfinclude template="../includes/EmailNewAccount.cfm">
	</cfif>

	<cfset rString = "">  

 	<cfreturn rString>

</cffunction>
