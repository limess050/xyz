<cfif Len(ParentSectionID) and IsNumeric(ParentSectionID)>
	<cfquery name="getParentSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select Title
		From PageSectionsView
		Where ParentSectionID = <cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfquery name="getPos1Ads" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select BA.BannerAdID,  BA.BannerAdImage, BA.StartDate, BA.EndDate,
		basw.Weight, 
		bat.BannerAdType
		from BannerAds BA With (NoLock) 
		inner join Orders O With (NoLock) on o.orderID = BA.OrderID
		LEFT Outer Join BannerAdTypes bat with (NOLOCK) on ba.BannerAdTypeID=bat.BannerAdTypeID
		Left Outer Join BannerAdSectionWeights basw with (NOLOCK) on ba.BannerAdID=basw.BannerAdID and basw.ParentSectionID=<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">
		Where BA.InProgress = 0 AND BA.PositionID = 1 AND BA.Active = 1 <!--- and BA.Reviewed = 1 --->
		AND BA.EndDate >= #application.CurrentDateInTZ#
		AND O.PaymentStatusID = 2
		AND BA.BannerAdID in (select BannerAdID from BannerAdParentSections where parentsectionID = <cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">)	
	</cfquery>
	<cfquery name="getPos3Ads" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select BA.BannerAdID,  BA.BannerAdImage, BA.StartDate, BA.EndDate,
		basw.Weight, 
		bat.BannerAdType
		from BannerAds BA With (NoLock) 
		inner join Orders O With (NoLock) on o.orderID = BA.OrderID
		LEFT Outer Join BannerAdTypes bat with (NOLOCK) on ba.BannerAdTypeID=bat.BannerAdTypeID
		Left Outer Join BannerAdSectionWeights basw with (NOLOCK) on ba.BannerAdID=basw.BannerAdID and basw.ParentSectionID=<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">
		Where BA.InProgress = 0 AND BA.PositionID = 3 AND BA.Active = 1 <!--- and BA.Reviewed = 1 --->
		AND BA.EndDate >= #application.CurrentDateInTZ#
		AND O.PaymentStatusID = 2
		AND BA.BannerAdID in (select BannerAdID from BannerAdParentSections where parentsectionID = <cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">)	
	</cfquery>
</cfif>