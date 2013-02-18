<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>



<cfif Action is "Form">	
	<cfquery name="Transmissions" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select TransmissionID as SelectValue, Title as SelectText 
		From Transmissions
		Where Active=1
		Order By OrderNum
	</cfquery>
	
	<cfoutput>		
		<tr>
			<td class="rightAtd">
				*&nbsp;Transmission:
			</td>
			<td>
				<select name="TransmissionID" ID="TransmissionID">
					<option value="">-- Select --
					<cfloop query="Transmissions">
						<option value="#SelectValue#" <cfif SelectValue is caller.TransmissionID>Selected</cfif>>#SelectText#
					</cfloop>
				</select>
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set TransmissionID=<cfqueryparam value="#caller.TransmissionID#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.TransmissionID)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">			
		if (!checkText(formObj.elements["TransmissionID"],"Transmission")) return false;					
</cfif>
