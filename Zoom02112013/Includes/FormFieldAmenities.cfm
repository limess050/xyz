No longer in use. Includes/FormFieldAmenities.cfm<cfabort>

<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>

<cfif Action is "Form">	
	<cfoutput>			
		<tr>
			<td class="rightAtd">
				Amenities:			
			</td>
			<td>
				<textarea name="Amenities" id="Amenities" cols="35">#caller.Amenities#</textarea>
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set Amenities=<cfqueryparam value="#caller.Amenities#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.Amenities)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
	
</cfif>
