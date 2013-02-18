<cfquery name="getListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select Top 1000 ListingID
	From Listings
	Where ListingTitleForH1 is null
	Order By ListingID desc
</cfquery>

<cfoutput query="getListings">
	<cfinclude template="../includes/ListingTitlesUpdater.cfm">
</cfoutput>