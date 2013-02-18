<cfswitch expression="#BannerAdPlacement#">
	<cfcase value="1">
		<cfset PriceMonthly = getBannerPricing.HomePageAdFeeMonthly>
	</cfcase>
	<cfcase value="2">
		<cfset PriceMonthly = getBannerPricing.SiteWidePosition1FeeMonthly>
		
	</cfcase>
	<cfcase value="3">
		<cfset PriceMonthly = getBannerPricing.SectionPosition1FeeMonthly>	
	</cfcase>
	<cfcase value="4">
		<cfset PriceMonthly = getBannerPricing.SubSectionPosition1FeeMonthly>
			
	</cfcase>
	<cfcase value="5">
		<cfset PriceMonthly = getBannerPricing.CategoryPosition1FeeMonthly>
	</cfcase>
	<cfcase value="6">
		<cfset PriceMonthly = getBannerPricing.AdminPosition1FeeMonthly>
	</cfcase>
</cfswitch>