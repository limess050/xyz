
<cfsetting showdebugoutput="no">

<cffunction name="SendEmail" access="remote" returntype="string" displayname="Sends the Welcome email">
	<cfargument name="PK" type="numeric" required="yes">
	<cfset NewListingID=PK>
	<cfinclude template="../includes/EmailListingLive.cfm">	

	<cfset rString = "">  

 	<cfreturn rString>

</cffunction>
