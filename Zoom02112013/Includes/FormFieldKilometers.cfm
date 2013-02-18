<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td class="rightAtd">
				*&nbsp;Kilometers:
			</td>
			<td>
				<input name="Kilometers" id="Kilometers" value="#caller.Kilometers#" maxLength="8">
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set Kilometers=<cfqueryparam value="#caller.Kilometers#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(caller.Kilometers)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
	if (!checkText(formObj.elements["Kilometers"],"Kilometers")) return false;	
	if (!checkNumber(formObj.elements["Kilometers"],"Kilometers")) return false;	
</cfif>
