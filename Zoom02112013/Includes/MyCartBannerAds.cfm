
<cfquery name="getMyCartBannerAds" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select B.*
	From BannerAds B
	Where B.InProgressUserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
	and B.OrderID is null 
	and B.InProgress=1
	Order By B.Impressions desc
</cfquery>


<cfset BannerAdsInCart=getMyCartBannerAds.RecordCount>


<cfset BannerFeesInCart="0">
<cfoutput query="getMyCartBannerAds">
	<cfif Len(Price)>
		<cfset BannerFeesInCart=BannerFeesInCart+Price>
	</cfif>
</cfoutput>