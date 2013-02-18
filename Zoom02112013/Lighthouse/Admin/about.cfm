<cfset pg_title = "About Lighthouse">
<cfset LighthouseInfo = Application.Lighthouse.GetProductInfo("Lighthouse")>
<cfset DojoInfo = Application.Lighthouse.GetProductInfo("Dojo Toolkit")>

<cfset showMetrics = true>
<cftry>
	<cfset pmData = GetMetricData("PERF_MONITOR") >
	<cfcatch><cfset showMetrics = false></cfcatch>
</cftry>
<cfinclude template="header.cfm">

<h1>About This Application</h1>

<cfoutput>
<h2>Lighthouse</h2>
<p>
	Initialized on #DateFormat(Application.TimeInitialized)# #TimeFormat(Application.TimeInitialized)# --
	<a href="#Request.AppVirtualPath#/Admin/index.cfm?adminFunction=about&lh_Initialize=1">Initialize Now</a>
</p>
<table class="info" cellspacing="0">
	<tr>
		<th>Product</th>
		<th>Version</th>
	</tr>
	<tr>
		<td>Lighthouse</td>
		<td>#LighthouseInfo.version.XmlText#</td>
	</tr>
	<tr>
		<td>Dojo Toolkit</td>
		<td>#DojoInfo.version.XmlText#</td>
	</tr>
</table>
<h3>Installed Modules:</h3>
<ul>
<cfif lh_isModuleInstalled("siteEditor")><li>Site Editor</li></cfif>
<cfif lh_isModuleInstalled("spellcheck")><li>Spell Check</li></cfif>
</ul>

<h2>ColdFusion</h2>
<h3>Platform</h3>
<table class="info" cellspacing="0">
	<tr>
		<th>Name</th>
		<th>Value</th>
	</tr>
	<tr>
		<td>ColdFusion Server</td>
		<td>#Server.ColdFusion.ProductName# #Server.ColdFusion.ProductLevel# #Server.ColdFusion.ProductVersion#</td>
	</tr>
	<tr>
		<td>Operating System</td>
		<td>#Server.OS.Name# #Server.OS.AdditionalInformation#</td>
	</tr>
	<tr>
		<td>Web Server</td>
		<td>#cgi.SERVER_SOFTWARE#</td>
	</tr>
	<cftry>
		<cfset dss = CreateObject("java","coldfusion.server.ServiceFactory").getDataSourceService().getDatasources()>
		<cfif StructKeyExists(dss,Request.dsn)>
			<cfset ds = dss[Request.dsn]>
			<tr>
				<td>Database Driver</td>
				<td>
					#ds.driver#
					<!--- <cfdump var="#ds#"> --->
				</td>
			</tr>
		</cfif>
		<cfcatch></cfcatch>
	</cftry>
</table>

<cfif showMetrics>
	<h3>Performance Monitor</h3>
	<table class="info" cellspacing="0">
		<tr>
			<th>Metric</th>
			<th>Value</th>
		</tr>
		<tr>
			<td>PageHits</td>
			<td>#pmData.PageHits#</td>
		</tr>
		<tr>
			<td>Requests Queued</td>
			<td>#pmData.ReqQueued#</td>
		</tr>
		<tr>
			<td>DBHits</td>
			<td>#pmData.DBHits#</td>
		</tr>
		<tr>
			<td>Requests Running</td>
			<td>#pmData.ReqRunning#</td>
		</tr>
		<tr>
			<td>Requests Timed Out</td>
			<td>#pmData.ReqTimedOut#</td>
		</tr>
		<tr>
			<td>Bytes In</td>
			<td>#pmData.BytesIn#</td>
		</tr>
		<tr>
			<td>Bytes Out</td>
			<td>#pmData.BytesOut#</td>
		</tr>
		<tr>
			<td>Avg. Queue Time</td>
			<td>#pmData.AvgQueueTime#</td>
		</tr>
		<tr>
			<td>Avg. Request Time</td>
			<td>#pmData.AvgReqTime#</td>
		</tr>
		<tr>
			<td>Avg. DB Time</td>
			<td>#pmData.AvgDBTime#</td>
		</tr>
	</table>
</cfif>

</cfoutput>

<cfinclude template="footer.cfm">