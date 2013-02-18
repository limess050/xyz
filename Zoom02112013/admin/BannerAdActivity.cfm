
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Banner Ad Activity Report">
<cfinclude template="../Lighthouse/Admin/Header.cfm">
<cfparam name="BannerAdID" default="">
<cfparam name="StatusMsg" default="">

<cfset allFields="BannerAdID,StartDate,EndDate">
<cfinclude template="../includes/setVariables.cfm">
<cfmodule template="../includes/_checkNumbers.cfm" fields="BannerAdID">

<!--- If not on live site, process impressions, since the template is not a scheduled task on the devel server. --->
<cfif Request.environment neq "live">
	<!--- <cfinclude template="../intTasks/ImpressionsTracker.cfm"> --->
	<cfmodule template="../intTasks/ImpressionsTracker.cfm">
</cfif>

<cfoutput>
<script src="#Request.HTTPSURL#/Lighthouse/dojo/dojo.js" type="text/javascript">
<script language="JavaScript" src="#Request.HTTPSURL#/scripts/jquery-1.3.2.min.js" type="text/javascript"></script>
</cfoutput>

<cfoutput>
	<script language="JavaScript" src="#Request.AppVirtualPath#/public.js" type="text/javascript"></script>
</cfoutput>

<script>
dojo.addOnLoad(function(){
	dojo.require("dojo.widget.*");
	dojo.require("dojo.widget.DatePicker");
});
	
function validateForm(formObj) {
	if (formObj.elements["StartDate"].value=='' && formObj.elements["EndDate"].value=='') {
		alert('Please enter a Start Date or End Date.');
		return false;
	}
	return (1 == 1					
			&& checkDateDDMMYYYY(formObj.elements["StartDate"],"Start Date")
			&& checkDateDDMMYYYY(formObj.elements["EndDate"],"End Date")
			)
}
</script>

<div id=bodyOfPageDiv>
	<cfoutput>
		<h1 style="margin:0px">#pg_title#</h1>	
		<cfif Len(StatusMsg)><p class="STATUSMESSAGE">#StatusMsg#</p></cfif>
	</cfoutput>
	<p>
	<!--- <table class="ACTIONBUTTONTABLE" border="0" cellpadding="1" cellspacing="1">
	<tbody><tr>
		<td class="ACTIONCELL"><a href="BannerAdSectionWeight.cfm">View All</a></td> 
	</tr>
	</tbody></table> --->
	<form name="f1" action="BannerAdActivity.cfm" method="post" ONSUBMIT="return validateForm(this)">
		<TABLE CELLPADDING=5 CELLSPACING=0 BORDER=0>
		<cfoutput>
		<tbody>
			<tr>
				<td align="right"><strong>Banner Ad ID:</strong></td>
				<td>
					<input type="text" name="BannerAdID" value="#BannerAdID#" Size="4">
				</td>
			</tr>
			<tr>
				<td align="right"><strong>Start Date:</strong></td>
				<td>
					<input id="StartDate" name="StartDate" size="15" value="#StartDate#" type="TEXT">
					<img style="vertical-align: middle; cursor: pointer;" alt="Select a date" onclick="lh.ShowPopupCalendar(getEl('StartDate'),'DD/MM/YYYY')" src="#Request.HTTPSUrl#/Lighthouse/dojo/src/widget/templates/images/dateIcon.gif">
				</td>
			</tr>
			<tr>
				<td align="right"><strong>End Date:</strong></td>
				<td>
					<input name="EndDate" id="EndDate" size="15" value="#EndDate#" type="TEXT">
					<img style="vertical-align: middle; cursor: pointer;" alt="Select a date" onclick="lh.ShowPopupCalendar(getEl('EndDate'),'DD/MM/YYYY')" src="#Request.HTTPSUrl#/Lighthouse/dojo/src/widget/templates/images/dateIcon.gif">
				</td>
			</tr>				
			<tr>
				<td>&nbsp;</td>
				<td><input type="Submit" value="Submit"></td>
			</tr>		
		</tbody>
		</cfoutput>
		</table>
	</form>
	<cfif Len(BannerAdID)>
		<!--- Convert to US Date Format for use in query --->
		<cfset InDate = StartDate>
		<cfinclude template="../includes/DateFormatter.cfm">
		<cfset Search_StartDate = OutDate>
		
		<cfset InDate = EndDate>
		<cfinclude template="../includes/DateFormatter.cfm">
		<cfset Search_EndDate = OutDate>
		<cfquery name="getBannerAd" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select ba.BannerAdID, ba.BannerAdImage,
			a.Company
			<cfif Len(StartDate) or Len(EndDate)>
				, (Select IsNull(Sum(Count),0)
					From BannerAdImpressions
					Where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
					<cfif Len(Search_StartDate)>
						and ImpressionDate >= <cfqueryparam value="#Search_StartDate#" cfsqltype="CF_SQL_DATE">
					</cfif>
					<cfif Len(Search_EndDate)>
						and ImpressionDate <= <cfqueryparam value="#Search_EndDate#" cfsqltype="CF_SQL_DATE">
					</cfif>
				) as ImpressionsCount,
				(Select IsNull(Sum(Count),0)
					From BannerAdExternalImpressions
					Where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
					<cfif Len(Search_StartDate)>
						and ImpressionDate >= <cfqueryparam value="#Search_StartDate#" cfsqltype="CF_SQL_DATE">
					</cfif>
					<cfif Len(Search_EndDate)>
						and ImpressionDate <= <cfqueryparam value="#Search_EndDate#" cfsqltype="CF_SQL_DATE">
					</cfif>
				) + 
				(Select IsNull(Sum(Count),0)
					From BannerAdExpandedImpressions
					Where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
					<cfif Len(Search_StartDate)>
						and ImpressionDate >= <cfqueryparam value="#Search_StartDate#" cfsqltype="CF_SQL_DATE">
					</cfif>
					<cfif Len(Search_EndDate)>
						and ImpressionDate <= <cfqueryparam value="#Search_EndDate#" cfsqltype="CF_SQL_DATE">
					</cfif>
				)
				as ExternalImpressionsCount				
			</cfif>
			From BannerAds ba
			Inner Join Orders o on ba.OrderID = o.OrderID
			inner join LH_Users a on o.UserID = a.UserID
			Where ba.BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfif getBannerAd.RecordCount>
			<cfoutput query="getBannerAd">
				<p>
				<strong>Banner Ad ID:</strong> <a href="BannerAds.cfm?Action=Edit&pk=#BannerAdID#">#BannerAdID#</a><br>
				<strong>Account Name:</strong> #Company#<br>
				<strong>Image:</strong> #BannerAdImage#
				</p>
				<cfif Len(StartDate) or Len(EndDate)>
					<p><strong>Banner Ad Activity for: <cfif Len(StartDate)>#StartDate# </cfif><cfif Len(StartDate) and Len(EndDate)>through </cfif><cfif Len(EndDate)>#EndDate# <cfif not Len(StartDate)>or earlier</cfif> <cfelse> or later</cfif></strong></p>
					<TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0 CLASS=VIEWTABLE>
						<thead>
							<tr id="viewgroupheaderrow">
								<td CLASS=VIEWHEADERCELL>Views</td>
								<td CLASS=VIEWHEADERCELL>Click-Throughs</td>
							</tr>
						</thead>
						<tbody>
						<tr class="VIEWROW">
							<td align="center">#ImpressionsCount#</td>
							<td align="center">#ExternalImpressionsCount#</td>
						</tr>		
						</tbody>
					</table>
				</cfif>
			</cfoutput>
		<cfelse>
			<p>No Banner Ad record found.</p>
		</cfif>
	</cfif>
	
</div>
<cfinclude template="../Lighthouse/Admin/Footer.cfm">