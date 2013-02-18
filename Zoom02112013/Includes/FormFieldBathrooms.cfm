<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td class="rightAtd">
				*&nbsp;Bathrooms:
			</td>
			<td>
				<input name="Bathrooms" id="Bathrooms" value="#caller.Bathrooms#" maxLength="4">
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set Bathrooms=<cfqueryparam value="#caller.Bathrooms#" cfsqltype="CF_SQL_FLOAT" null="#NOT LEN(caller.Bathrooms)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
	if (!checkText(formObj.elements["Bathrooms"],"Bathrooms")) return false;	
	if (!checkNumber(formObj.elements["Bathrooms"],"Bathrooms")) return false;	
</cfif>
