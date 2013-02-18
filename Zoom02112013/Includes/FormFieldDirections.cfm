NO LONGER IN USE includes/FormFieldDirections.cfm<cfabort>
<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>

<cfif Action is "Form">	
	<cfoutput>			
		<tr>
			<td class="rightAtd">
				*&nbsp;Directions:
			</td>
			<td>
				<textarea name="Directions" id="Directions" cols="35">#caller.Directions#</textarea>
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set Directions=<cfqueryparam value="#caller.Directions#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.Directions)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">			
		if (!checkText(formObj.elements["Directions"],"Directions")) return false;				
</cfif>

