
<cfsetting requesttimeout="60000">
<cfquery name="getBannerAds"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		select BA.BannerAdID, BA.BannerAdUrl, BA.BannerAdImage, 'Banner' AS Type,
		ba.placementID,
 		ba.impressions,
 		ba.impressions - (select count(impressionID) from impressions i  where i.bannerADID = ba.bannerAdID) as impressionsRemaining,
		DateDiff(day,getDate(),ba.endDate) as daysRemaining
		from BannerAds BA inner join
		Orders O on o.orderID = BA.OrderID
		Where BA.InProgress = 0 AND BA.PositionID = 2 AND BA.Active = 1
		AND BA.Impressions > (select count(impressionID) from impressions where BannerADID = BA.BannerADID)
		AND BA.PositionID <> 1
		AND O.PaymentStatusID = 2
		
</cfquery>	

<cfoutput query="getBannerAds">
	<cfif daysremaining GT 0>
		<cfset impDay = impressionsRemaining/daysremaining>
	<cfelse>
		<cfset impDay = impressionsRemaining>
	</cfif>
	<cfquery name="updateBannerAd"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		update BannerAds
		set DailyImpressions = <cfqueryparam value="#Round(ImpDay)#" cfsqltype="CF_SQL_INTEGER">
		where bannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
</cfoutput>	