<cfquery name="GetAlertSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select ASe.AlertSectionID, ASe.PriceMinUS, ASe.PriceMaxUS, ASe.PriceMinTZS, ASe.PriceMaxTZS, ASeC.CategoryID, ASe.SectionID,
	C.Title as Category, S.Title as AlertSection,
	A.AlertID
	From Alerts A 
	Inner Join AlertSections ASe on A.AlertID=ASe.AlertID
	Inner Join Sections S on ASe.SectionID=S.SectionID
	Left Outer Join AlertSectionCategories ASeC on ASe.AlertSectionID=ASeC.AlertSectionID
	Left Outer Join Categories C on ASeC.CategoryID=C.CategoryID
	Where A.ConfirmationID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ConfirmationID#">
	Order by S.Title, ASe.AlertSectionID, C.OrderNum
</cfquery>

<cfquery name="GetAllAlertSectionLocations" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select ASe.AlertSectionID, L.Title as Location, L.OrderNum
	From Alerts A 
	Inner Join AlertSections ASe on A.AlertID=ASe.ALertID
	Inner Join AlertSectionLocations ASL on ASe.AlertSectionID = ASL.AlertSectionID
	Inner Join Locations L on ASL.LOcationID=L.LocationID
	Where A.ConfirmationID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ConfirmationID#">
	Order By ASe.AlertSectionID, L.OrderNUm
</cfquery>