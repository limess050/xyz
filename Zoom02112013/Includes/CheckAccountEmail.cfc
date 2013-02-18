
<cfsetting showdebugoutput="no">

<cffunction name="CheckEmail" access="remote" returntype="string" displayname="Returns Listing Type ID Select list for passed SectionID">
	<cfargument name="ContactEmail" required="yes">
	
	
	<cfquery name="checkEmail"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select UserID
		From LH_Users
		Where ContactEmail =  <cfqueryparam value="#Trim(arguments.ContactEmail)#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

	<cfset rString = "">       
	
	<cfif checkEmail.RecordCount>	
		<cfset rString="<br>An account already exists with the primary email address '#arguments.ContactEmail#'. The primary email address is the account's username and must be unique. Click on ""My Account"" in the upper-left to log in as '#arguments.ContactEmail#', or enter a different email address to continue. <a href='#request.httpURL#/forgotPassword'>Click here</a> to have your password emailed to you.">	
	</cfif> 	

 	<cfreturn rString>
</cffunction>

