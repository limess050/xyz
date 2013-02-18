<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td class="rightAtd">
				*&nbsp;Area:
			</td>
			<td>
				<input name="Area" id="Area" value="#caller.Area#" maxLength="20">
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set Area=<cfqueryparam value="#caller.Area#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(caller.Area)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
	if (!checkText(formObj.elements["Area"],"Area")) return false;	
	if (!checkNumber(formObj.elements["Area"],"Area")) return false;	
</cfif>
