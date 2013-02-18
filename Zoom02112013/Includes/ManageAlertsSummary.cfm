<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfparam name="Em" default="">

<cfinclude template="GetAlertSections.cfm">

<cfif ConfirmAlert>
	<lh:MS_SitePagePart id="bodyConfirmed" class="body">
	<p>&nbsp;</p>
<cfelse>
	<cfif Len(Em)>
		<p>&nbsp;</p>
		<div class="notice">That email address is already in use by another Alert record. Email address was not updated.</div>
	</cfif>
	<cfif GetAlertSections.RecordCount>
		<lh:MS_SitePagePart id="bodySummary" class="body">
	<cfelse>
		<lh:MS_SitePagePart id="bodySummaryNoAlerts" class="body">		
	</cfif>
</cfif>
<cfoutput>
	<cfif GetAlertSections.RecordCount>
		<form name="f2" id="f2" action="page.cfm?PageID=#Request.ManageAlertPageID#" method="post" 
			ONSUBMIT="return confirm('This will cancel your alert registration and you will no longer receive new Listing Email Alerts of any kind from ZoomTanzania.com. Are you sure you want to cancel your alert registration?');">
			<input type="hidden" name="Step" value="7">
			<input type="hidden" name="AlertID" value="#GetAlertSections.AlertID#">
			<input type="hidden" name="ConfirmationID" value="#ConfirmationID#">
			<table class="datatable">	
				<tr>
						<td>
							<input type="image" name="Next" ID="DAA" value="Delete All Alert" src="images/inner/btn.deleteAllAlerts_off.gif" align="absmiddle" 
							onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('DAA','','images/inner/btn.deleteAllAlerts_on.gif',1)">	
						</td>
				</tr>
			</table>
		</form>
	</cfif>
	<form name="f1" action="page.cfm?PageID=#Request.ManageAlertPageID#" method="post" ONSUBMIT="return validateForm(this)">
</cfoutput>
	<input type="hidden" name="Step" value="2">
<table class="alertsTable">	
		<cfoutput>
		<tr>
			<td>
				Email:
			</td>
			<td colspan="2">
				#GetAlert.Email#
			</td>
			<td>
				<a href="page.cfm?PageID=#Request.ManageAlertPageID#&Step=8&ConfirmationID=#ConfirmationID#">Update</a>
			</td>
		</tr>
		</cfoutput>
			<tr>
				<td colspan="4" class="noBorder">&nbsp;</td>
			</tr>
		<cfoutput query="GetAlertSections" group="AlertSectionID">
			<cfquery name="GetAlertSectionLocations" dbtype="query">
				Select Location
				From GetallAlertSectionLocations
				Where AlertSectionID =  <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#AlertSectionID#">
				Order By OrderNum
			</cfquery>
			<tr>
				<td>
					#AlertSection#
				</td>
				<td <cfif not GetAlertSectionLocations.RecordCount>colspan="2"</cfif>>
					<cfoutput>#Category#<br></cfoutput>
				</td>
				<cfif GetAlertSectionLocations.RecordCount>
					<td>
					<cfloop query="GetAlertSectionLocations">
						#Location#<br>
					</cfloop>
					</td>
				</cfif>
				<td>
					<a href="page.cfm?PageID=#Request.ManageAlertPageID#&AlertSectionID=#AlertSectionID#&Step=2&ConfirmationID=#ConfirmationID#">Update</a>
					| 
					<a href="page.cfm?PageID=#Request.ManageAlertPageID#&AlertSectionID=#AlertSectionID#&Step=4&ConfirmationID=#ConfirmationID#" onClick="return confirm('Are you sure you want to delete this Alert?');">Delete</a>
				</td>
			</tr>
			<cfif Len(PriceMinUS)>
				<tr>
					<td>&nbsp;</td>
					<td colspan="2">
						Min ($US): #NumberFormat(PriceMinUS,0)# - Max ($US): #NumberFormat(PriceMaxUS,0)#<br>
						Min (TSH): #NumberFormat(PriceMinTZS,0)# - Max (TSH): #NumberFormat(PriceMaxTZS,0)#
					</td>
					<td>&nbsp;</td>
				</tr>
			</cfif>
			<tr>
				<td colspan="4" class="noBorder">&nbsp;</td>
			</tr>
		</cfoutput>		
		<tr>
			<td colspan="4" class="noBorder">
				<cfoutput query="AlertSections">
					<a href="page.cfm?PageID=#Request.ManageAlertPageID#&NewAlertSectionID=#SelectValue#&Step=5&ConfirmationID=#ConfirmationID#">Add <cfif ListFind(ValueList(GetalertSections.SectionID),SelectValue)>another<cfelse>a</cfif> #SelectText# Alert</a><br>
				</cfoutput>	
			</td>
		</tr>			
	</table>
</form>
<cfif IsDefined('url.DeleteAll')>
	<script>
		$(document).ready(function(){
			$("#f2").submit();
	    });
	</script>
</cfif>


