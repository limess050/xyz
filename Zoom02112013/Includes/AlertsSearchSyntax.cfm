<!--- <cfdump var="#getAlertSections#"> --->
<!--- Build up a subquery for each AlertSection record in the Alert --->
<cfset FirstRow = "1">
<cfsavecontent variable="AlertSectionsClauses">
	<cfoutput query="getAlertSections" group="AlertSectionID">
		<cfset HasLocations = "0">
		<cfoutput group="locationID">
			<cfif Len(LocationID)>
				<cfset HasLocations = "1">
			</cfif>
		</cfoutput>
		<cfif not FirstRow>or</cfif>
		(exists (Select ListingID From ListingCategories with (NOLOCK) Where CategoryID in (0<cfoutput group="CategoryID">,#CategoryID#</cfoutput>) and ListingID=L.ListingID)
		<cfif HasLocations>and  exists (Select ListingID From ListingLocations with (NOLOCK) Where LocationID in (0<cfoutput group="LocationID">,#LocationID#</cfoutput>) and ListingID=L.ListingID)</cfif>
		<cfif Len(PriceMinUS)>
			and (L.PriceUS is null or (L.PriceUS >= #PriceMinUS# and L.PriceUS <= #PriceMaxUS#))
			and (L.PriceTZS is null or (L.PriceTZS >= #PriceMinTZS# and L.PriceTZS <= #PriceMaxTZS#))
		</cfif>
		)
		<cfset FirstRow = "0">
	</cfoutput>
</cfsavecontent>
<!--- <cfoutput>#AlertSectionsClauses#</cfoutput> --->