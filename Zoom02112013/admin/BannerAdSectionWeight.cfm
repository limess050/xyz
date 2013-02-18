
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Banner Ad Display By Section">
<cfinclude template="../Lighthouse/Admin/Header.cfm">
<cfparam name="ParentSectionID" default="">
<cfparam name="StatusMsg" default="">

<cfoutput><script language="JavaScript" src="#Request.HTTPSURL#/scripts/jquery-1.3.2.min.js" type="text/javascript"></script></cfoutput>

<cfinclude template="includes/BannerAdSectionWeightQueries.cfm">

<cfquery name="getParentSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select ParentSectionID, Title
	From PageSectionsView
	Where ParentSectionID < 10000
	Order By OrderNum
</cfquery>

<script>
function validateForm(formObj) {
	<cfif Len(ParentSectionID) and IsNumeric(ParentSectionID) and getParentSection.RecordCount>
		<cfoutput query="getPos1Ads">
			if (!checkText(document.f1.Weight#BannerAdID#,"Weight for Position 1 Ad ###BannerAdID#")) return false;
			if (!checkNumber(document.f1.Weight#BannerAdID#,"Weight for Position 1 Ad ###BannerAdID#")) return false;
		</cfoutput>
		<cfoutput query="getPos3Ads">
			if (!checkText(document.f1.Weight#BannerAdID#,"Weight for Position 3 Ad ###BannerAdID#")) return false;
			if (!checkNumber(document.f1.Weight#BannerAdID#,"Weight for Position 3 Ad ###BannerAdID#")) return false;
		</cfoutput>
	</cfif>
	return true;
}
</script>

<div id=bodyOfPageDiv>
	<cfoutput>
		<h1 style="margin:0px">#pg_title#</h1>	
		<cfif Len(StatusMsg)><p class="STATUSMESSAGE">#StatusMsg#</p></cfif>
	</cfoutput>
	<p>
	<cfif Len(ParentSectionID) and IsNumeric(ParentSectionID) and getParentSection.RecordCount>
		<table class="ACTIONBUTTONTABLE" border="0" cellpadding="1" cellspacing="1">
		<tbody><tr>
			<td class="ACTIONCELL"><a href="BannerAdSectionWeight.cfm">View All</a></td> 
		</tr>
		</tbody></table>
		<form name="f1" action="BannerAdSectionWeight_DoIt.cfm" method="post" ONSUBMIT="return validateForm(this)">
			<cfoutput><input type="hidden" name="ParentSectionID" value="#ParentSectionID#"></cfoutput>
			<TABLE CELLPADDING=5 CELLSPACING=0 BORDER=0>
			<thead>
				<tr>
					<td><strong>Section Name:</strong></td>
					<td><cfoutput>#getParentSection.Title#</cfoutput></td>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td colsspan="2">&nbsp;</td>
				</tr>
				<tr>
					<td valign="top"><strong>Position 1 Ads:</strong></td>
					<td>
						<cfif getPos1Ads.RecordCount>
							<TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0 CLASS=VIEWTABLE>
								<thead>
									<tr id="viewgroupheaderrow">
										<td CLASS=VIEWHEADERCELL>Banner Ad</td>
										<td CLASS=VIEWHEADERCELL>Weight</td>
									</tr>
								</thead>
								<tbody>
								<cfoutput query="getPos1Ads">
									<tr class="VIEWROW">
										<td><a href="BannerAds.cfm?action=Edit&PK=#BannerAdID#">#BannerAdID#: #BannerAdType# - #BannerAdImage# (#DateFormat(StartDate,'dd/mm/yyyy')# - #DateFormat(EndDate,'dd/mm/yyyy')#)</a></td>
										<td align="center"><input type="text" name="Weight#BannerAdID#" value="#NumberFormat(Weight,'_.__')#" size="5"></td>
									</tr>										
								</cfoutput>	
								</tbody>
							</table>
						</cfif>
					</td>
				</tr>
				<tr>
					<td colsspan="2">&nbsp;</td>
				</tr>
				<tr>
					<td valign="top"><strong>Position 3 Ads:</strong></td>
					<td>
						<cfif getPos3Ads.RecordCount>
							<TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0 CLASS=VIEWTABLE>
								<thead>
									<tr id="viewgroupheaderrow">
										<td CLASS=VIEWHEADERCELL>Banner Ad</td>
										<td CLASS=VIEWHEADERCELL>Weight</td>
									</tr>
								</thead>
								<tbody>
								<cfoutput query="getPos3Ads">
									<tr class="VIEWROW">
										<td><a href="BannerAds.cfm?action=Edit&PK=#BannerAdID#">#BannerAdID#: #BannerAdType# - #BannerAdImage# (#DateFormat(StartDate,'dd/mm/yyyy')# - #DateFormat(EndDate,'dd/mm/yyyy')#)</a></td>
										<td align="center"><input type="text" name="Weight#BannerAdID#" value="#NumberFormat(Weight,'_.__')#" size="5"></td>
									</tr>										
								</cfoutput>	
								</tbody>
							</table>
						</cfif>
					</td>
				</tr>
				<tr>
					<td colsspan="2">&nbsp;</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td><input type="Submit" value="Save"></td>
				</tr>		
			</tbody>
			</table>
		</form>
	<cfelse>
		<TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0 CLASS=VIEWTABLE>
			<thead>
				<tr id="viewgroupheaderrow">
					<td CLASS=VIEWHEADERCELL>Section Name</td>
					<!--- <td CLASS=VIEWHEADERCELL>&nbsp;</td> --->
				</tr>
			</thead>
			<tbody>
			<cfoutput query="getParentSections">
				<tr class="VIEWROW">
					<td>#Title#</td>
					<td class="VIEWACTIONCELL">
						<a href="BannerAdSectionWeight.cfm?ParentSectionID=#ParentSectionID#"">Manage Weights</a>
					</td>
				</tr>										
			</cfoutput>	
			</tbody>
		</table>
		<!--- <cfoutput query="getParentSections">
			<a href="BannerAdSectionWeight.cfm?ParentSectionID=#ParentSectionID#">#Title#</a><br>
		</cfoutput> --->
	</cfif>
</div>
<cfinclude template="../Lighthouse/Admin/Footer.cfm">