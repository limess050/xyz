<!--- This query finds all qualified Banner Ads, joins them to a Pivot table so that the Inner table has number of rows per Banner Ad relative to the Banner Ad's weight, selects one of these records at random by using Top 1 and ordering by NewID() and then joins this one winner to the outer query to get the required data. A more complete explanation is available at: http://www.bennadel.com/blog/1472-Ask-Ben-Selecting-A-Random-Row-From-A-Weighted-Filtered-Record-Set.htm
Note that the Weight is multipled by 100 to account for the two decimal places possible in the Weight value. The Pivot table contains 10000 rows, so the sum of the weights can not exceed 100. The limit is enforced in the Admin/BannerAdSectionWeights_DoIt.cfm template. --->

<cfparam name="BAPosition" default="1">
<cfquery name="getBannerAdPos"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">		
	select BA.BannerAdID, BA.BannerAdUrl, BA.BannerAdImage, BA.BannerAdLinkFile
	from BannerAds BA With (NoLock)
	INNER JOIN 
		(select Top 1 BA.BannerAdID
		from BannerAds BA With (NoLock) inner join
		Orders O With (NoLock) on o.orderID = BA.OrderID
		Inner Join BannerAdParentSections baps on ba.BannerAdID=baps.BannerAdID
		Inner Join BannerAdSectionWeights basw on ba.BannerAdID=basw.BannerAdID
		Inner Join Pivot10000 p on basw.Weight*100 >= p.PivotID
		Where BA.InProgress = 0 AND BA.Active = 1 <!--- and BA.Reviewed = 1 --->
		AND BA.PositionID = <cfqueryparam value="#BAPosition#" cfsqltype="CF_SQL_INTEGER"> 
		AND BA.StartDate <= #application.CurrentDateInTZ#
		AND BA.EndDate >= #application.CurrentDateInTZ#
		AND O.PaymentStatusID = 2
		AND baps.parentsectionID = <cfqueryparam value="#ImpressionSectionID#" cfsqltype="CF_SQL_INTEGER">
		and basw.ParentSectionID = <cfqueryparam value="#ImpressionSectionID#" cfsqltype="CF_SQL_INTEGER">
		Order By NEWID() desc) as WinningBannerAd on BA.BannerAdID=WinningBannerAd.BannerAdID
</cfquery>
<!--- If no qualifying Banner Ad, see if there are qualifying ads that have no wieght assigned.  --->
<cfif not getBannerAdPos.RecordCount>
	<cfquery name="getBannerAdPos"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">	
		select Top 1 BA.BannerAdID, BA.BannerAdUrl, BA.BannerAdImage, BA.BannerAdLinkFile
		from BannerAds BA With (NoLock) inner join
		Orders O With (NoLock) on o.orderID = BA.OrderID
		Inner Join BannerAdParentSections baps on ba.BannerAdID=baps.BannerAdID
		Where BA.InProgress = 0 AND BA.Active = 1 <!--- and BA.Reviewed = 1 --->
		AND BA.PositionID = <cfqueryparam value="#BAPosition#" cfsqltype="CF_SQL_INTEGER"> 
		AND BA.StartDate <= #application.CurrentDateInTZ#
		AND BA.EndDate >= #application.CurrentDateInTZ#
		AND O.PaymentStatusID = 2
		AND baps.parentsectionID = <cfqueryparam value="#ImpressionSectionID#" cfsqltype="CF_SQL_INTEGER">
		Order By NewID() desc		
	</cfquery>
</cfif>
<!--- If no qualifying Banner Ad, select a random current Banner Ad for Position  --->
<cfif not getBannerAdPos.RecordCount>
	<cfquery name="getBannerAdPos"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">	
		select Top 1 BA.BannerAdID, BA.BannerAdUrl, BA.BannerAdImage, BA.BannerAdLinkFile
		from BannerAds BA With (NoLock) inner join
		Orders O With (NoLock) on o.orderID = BA.OrderID
		Where BA.InProgress = 0 AND BA.Active = 1 <!--- and BA.Reviewed = 1 --->
		AND BA.PositionID = <cfqueryparam value="#BAPosition#" cfsqltype="CF_SQL_INTEGER"> 
		AND BA.StartDate <= #application.CurrentDateInTZ#
		AND BA.EndDate >= #application.CurrentDateInTZ#
		AND O.PaymentStatusID = 2
		Order By NewID() desc		
	</cfquery>
</cfif>
<cfset "getBannerAdPos#BAPosition#" = getBannerAdPos>
