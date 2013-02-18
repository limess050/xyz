
<cfquery name="getMyBannerAds" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select B.*,O.*
	From BannerAds B inner join orders O on o.orderID = b.orderID
	Where B.InProgressUserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
	and B.InProgress=0
	Order By B.Impressions desc;
</cfquery>


