
<cfquery name="getMyAlerts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select A.AlertID, A.ConfirmationID, A.ConfirmationReceived
	From Alerts A 
	Inner Join AlertSections ASe on A.AlertID=ASe.AlertID
	Where A.UserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfif getMyAlerts.RecordCount>
	<cfset ConfirmationID=getMyAlerts.ConfirmationID>
	<cfinclude template="GetAlertSections.cfm">
	<br>
	<table class="alertsTable">
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
			</tr>
			<cfif Len(PriceMinUS)>
				<tr>
					<td>&nbsp;</td>
					<td colspan="2">
						Min ($US): #NumberFormat(PriceMinUS,0)# - Max ($US): #NumberFormat(PriceMaxUS,0)#<br>
						Min (TSH): #NumberFormat(PriceMinTZS,0)# - Max (TSH): #NumberFormat(PriceMaxTZS,0)#
					</td>
				</tr>
			</cfif>
			<tr>
				<td colspan="3" class="noBorder">&nbsp;</td>
			</tr>
		</cfoutput>	
	</table>
	<cfoutput><a href="#lh_getPageLink(Request.ManageAlertPageID,'manageAlerts')#"><cfif Len(getMyAlerts.ConfirmationReceived)>Manage<cfelse>Activate</cfif> Your Alerts</a></cfoutput>
<cfelse>
	You currently have no Alerts.<br>
	<cfoutput><a href="#lh_getPageLink(Request.ManageAlertPageID,'manageAlerts')#">Create Alerts</a></cfoutput>
</cfif>






