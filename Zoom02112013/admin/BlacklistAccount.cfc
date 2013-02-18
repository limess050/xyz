
<cfsetting showdebugoutput="no">

<cffunction name="Add" access="remote" returntype="string" displayname="Adds the Blacklist to the Account">
	<cfargument name="PK" type="numeric" required="yes">

	<cfquery name="blAccount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update LH_Users
		Set Blacklist_fl = 1
		Where UserID=<cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>

	<cfset rString = "">  

 	<cfreturn rString>

</cffunction>

<cffunction name="Remove" access="remote" returntype="string" displayname="Adds the Blacklist to the Account">
	<cfargument name="PK" type="numeric" required="yes">

	<cfquery name="blAccount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update LH_Users
		Set Blacklist_fl = 0
		Where UserID=<cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>

	<cfset rString = "">  

 	<cfreturn rString>

</cffunction>



<cffunction name="AddByListing" access="remote" returntype="string" displayname="Adds the Blacklist to the Account">
	<cfargument name="PK" type="numeric" required="yes">

	<cfquery name="blAccount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update LH_Users
		Set Blacklist_fl = 1
		Where UserID = (Select UserID From ListingsView Where ListingID = <cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">)
	</cfquery>

	<cfset rString = "">  

 	<cfreturn rString>

</cffunction>

<cffunction name="RemoveByListing" access="remote" returntype="string" displayname="Adds the Blacklist to the Account">
	<cfargument name="PK" type="numeric" required="yes">

	<cfquery name="blAccount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update LH_Users
		Set Blacklist_fl = 0
		Where UserID = (Select UserID From ListingsView Where ListingID = <cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">)
	</cfquery>

	<cfset rString = "">  

 	<cfreturn rString>

</cffunction>
