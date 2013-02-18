<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td class="rightAtd">
				Website:
			</td>
			<td>
				<input name="WebsiteURL" id="WebsiteURL" value="#caller.WebsiteURL#" size="45" maxLength="200">
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set WebsiteURL=<cfqueryparam value="#caller.WebsiteURL#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.WebsiteURL)#">	
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
	<!--- if (!checkText(formObj.elements["WebsiteURL"],"Website")) return false;	 --->
</cfif>
