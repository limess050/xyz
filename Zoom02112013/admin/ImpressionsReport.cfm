
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Impressions">
<cfinclude template="../Lighthouse/Admin/Header.cfm">
<cfif IsDefined('url.reportType') and url.reportType is "excel">
	<cfcontent type="application/x-msexcel" reset="Yes">
	<cfheader name="Content-Disposition" value="filename=ListingReport#DateFormat(now(),'ddmmyyyy')#.xls">
</cfif>
<cfoutput><script language="JavaScript" src="#Request.HTTPSURL#/scripts/jquery-1.3.2.min.js" type="text/javascript"></script></cfoutput>

<cfquery name="getHomePageImpressions" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select Count(ImpressionID) as ImpressionsCount
	From Impressions with (NOLOCK)
	Where HomePage=1
</cfquery>

<cfquery name="getAdminPageImpressions" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select Count(ImpressionID) as ImpressionsCount
	From Impressions with (NOLOCK)
	Where AdminPage=1
</cfquery>


<div id=bodyOfPageDiv>
	<cfif not IsDefined('url.reportType')>
		<h1 style="margin:0px"> Impressions Report:<cfoutput> #Dateformat(Now(),'dd/mm/yyyy')#</cfoutput> </h1>
		<P>
		<A HREF="ImpressionsReport.cfm?reportType=excel" class=normaltext>Export as Excel</A>
		<p>
	</cfif>
	<TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0 CLASS=VIEWTABLE>
	<thead>
		<tr id="viewgroupheaderrow">
			<td CLASS=VIEWHEADERCELL>Page</td>
			<td CLASS=VIEWHEADERCELL>Impressions</td>
		</tr>
	</thead>
	<tbody>
	<cfoutput>
		<tr class="VIEWROW">
			<td align="center">Home Page</td>
			<td align="center">#getHomePageImpressions.ImpressionsCount#</td>
		</tr>
		<tr class="VIEWROW">
			<td align="center">Admin Pages</td>
			<td align="center">#getAdminPageImpressions.ImpressionsCount#</td>
		</tr>
			
	</cfoutput>	
	</tbody>
	</table>

</div>
<cfinclude template="../Lighthouse/Admin/Footer.cfm">