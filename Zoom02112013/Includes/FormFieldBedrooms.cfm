<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td class="rightAtd">
				*&nbsp;Bedrooms:
			</td>
			<td>
				<input name="Bedrooms" id="Bedrooms" value="#caller.Bedrooms#" maxLength="4">
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set Bedrooms=<cfqueryparam value="#caller.Bedrooms#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(caller.Bedrooms)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
	if (!checkText(formObj.elements["Bedrooms"],"Bedrooms")) return false;	
	if (!checkNumber(formObj.elements["Bedrooms"],"Bedrooms")) return false;	
</cfif>
