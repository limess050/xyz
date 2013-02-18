<!--- Expects ListingID--->

<cfsetting showdebugoutput="no">

<cffunction name="Increment" access="remote" returntype="string" displayname="Increments the ClickThroughExpanded column for the listing">
	<cfargument name="ListingID" required="yes">
	
	<cfif not IsDefined('application.ListingExpandedImpressions')>
		<cfset application.ListingExpandedImpressions= structNew()>
	</cfif>
	<cfif StructKeyExists(application.ListingExpandedImpressions,ListingID)>
		<cfset application.ListingExpandedImpressions[ListingID] = application.ListingExpandedImpressions[ListingID] + 1>
	<cfelse>
		<cfset application.ListingExpandedImpressions[ListingID] = 1>
	</cfif>

	<cfset rString = "">  

 	<cfreturn rString>
</cffunction>

