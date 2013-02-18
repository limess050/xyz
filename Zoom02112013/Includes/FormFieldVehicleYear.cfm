<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td class="rightAtd">
				*&nbsp;Year:
			</td>
			<td>
				<input name="VehicleYear" id="VehicleYear" value="#caller.VehicleYear#" maxLength="4">
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set VehicleYear=<cfqueryparam value="#caller.VehicleYear#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(caller.VehicleYear)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
	if (!checkText(formObj.elements["VehicleYear"],"Year")) return false;	
	if (!checkNumber(formObj.elements["VehicleYear"],"Year")) return false;	
</cfif>
