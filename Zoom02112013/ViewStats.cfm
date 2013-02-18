<!--- This template expects a ListingID. --->

<cfset Edit="0">
<cfimport prefix="lh" taglib="Lighthouse/Tags">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Everything DAR - Find What you Need &mdash; Fast!  |  View Stats</title>
<meta http-equiv="X-UA-Compatible" content="IE=7" />
<link href="style.css" rel="stylesheet" type="text/css" />
</head>
<body>
<br>
<cfset allFields="LinkID,ListingID">
<cfinclude template="includes/setVariables.cfm">
<cfmodule template="includes/_checkNumbers.cfm" fields="ListingID">

<cfquery name="getListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select L.ListingID,
	L.ListingTitle, IsNull(ELPT.Descr,'featured listing page') as ELPType
	From ListingsView L
	Left Outer Join Makes M on L.MakeID=M.MakeID
	Left Outer Join ELPTypes ELPT on L.ELPTypeID=ELPT.ELPTypeID
	Where L.LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>
<cfset ListingID=getListing.ListingID>

<cfquery name="getListingStats" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select L.ListingID, L.ImpressionsResultsPage, L.Impressions, L.ImpressionsExpanded,
	L.ImpressionsEmailInquiries, L.ImpressionsExternal
	From Listings L
	Where L.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>




<cfoutput query="getListingStats">
	<cfset TotalViews = ImpressionsResultsPage + Impressions + ImpressionsExpanded>

	<div id="popout">
		<div id="popout-content">
			
			
				<h1>Statistics for #getListing.ListingTitle#</h1>
				<p>Your listing has appeared on a results page <strong>#ImpressionsResultsPage#</strong> times.</p>
				<p>Your basic listing has been viewed <strong>#Impressions#</strong> times.</p>
				<p>Your #getListing.ELPType# has been viewed <strong>#ImpressionsExpanded#</strong> times.</p>
				<p>There have been <strong>#ImpressionsEmailInquiries#</strong> email inquiries submitted about this listing.</p>
				<p><strong>#ImpressionsExternal#</strong> users have clicked through to your website.</p>			
				<h1>Total Views: #TotalViews#</h1>
		</div> 
	</div>
</cfoutput>

</body>
</html>