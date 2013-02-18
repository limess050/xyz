<!--- Expects ListingID--->

<cfsetting showdebugoutput="no">

<cffunction name="Increment" access="remote" returntype="string" displayname="Increments the ClickThroughExpanded column for the listing">
	<cfargument name="ListingID">
	
	<cfif IsDefined('arguments.ListingID')>		
		<cfif not IsDefined('application.ListingExternalImpressions')>
			<cfset application.ListingExternalImpressions= structNew()>
		</cfif>
		<cfif StructKeyExists(application.ListingExternalImpressions,ListingID)>
			<cfset application.ListingExternalImpressions[ListingID] = application.ListingExternalImpressions[ListingID] + 1>
		<cfelse>
			<cfset application.ListingExternalImpressions[ListingID] = 1>
		</cfif>
	</cfif>

	<cfset rString = "">  

 	<cfreturn rString>
</cffunction>

