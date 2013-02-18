<!--- Expects ListingID--->

<cfsetting showdebugoutput="no">

<cffunction name="Increment" access="remote" returntype="string" displayname="Increments the ClickThroughExpanded column for the listing">
	<cfargument name="BannerAdID" required="yes">
	<cfargument name="SectionID" required="yes">
	
		
	<cfif not IsDefined('application.BannerAdExternalImpressions')>
		<cfset application.BannerAdExternalImpressions = structNew()>
	</cfif>
	<cfset KeyExists=0>		
	<cfif StructKeyExists(application.BannerAdExternalImpressions,BannerAdID)>
		<cfset TestForKey=application.BannerAdExternalImpressions[BannerAdID]>
		<cfif StructKeyExists(TestForKey,SectionID)>
			<cfset KeyExists=1>
		</cfif>
	</cfif>
	<cfif KeyExists>
		<cfset application.BannerAdExternalImpressions[BannerAdID][SectionID] = application.BannerAdExternalImpressions[BannerAdID][SectionID] + 1>
	<cfelse>
		<cfset application.BannerAdExternalImpressions[BannerAdID][SectionID] = 1>
	</cfif>
	

	<cfset rString = "">  

 	<cfreturn rString>
</cffunction>

