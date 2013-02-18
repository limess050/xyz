

<cfsetting showdebugoutput="no">

<cffunction name="Increment" access="remote" returntype="string" displayname="Increments the ClickThroughExpanded column for the listing">
	<cfargument name="BannerAdID" required="yes">
	<cfargument name="SectionID" required="yes">
	
	
	<cfif not IsDefined('application.BannerAdExpandedImpressions')>
		<cfset application.BannerAdExpandedImpressions = structNew()>
	</cfif>
	<cfset KeyExists=0>
	<cfif StructKeyExists(application.BannerAdExpandedImpressions,BannerAdID)>
		<cfset TestForKey=application.BannerAdExpandedImpressions[BannerAdID]>
		<cfif StructKeyExists(TestForKey,SectionID)>
			<cfset KeyExists=1>
		</cfif>
	</cfif>
	<cfif KeyExists>
		<cfset application.BannerAdExpandedImpressions[BannerAdID][SectionID] = application.BannerAdExpandedImpressions[BannerAdID][SectionID] + 1>
	<cfelse>
		<cfset application.BannerAdExpandedImpressions[BannerAdID][SectionID] = 1>
	</cfif>	
	

	<cfset rString = "">  

 	<cfreturn rString>
</cffunction>

