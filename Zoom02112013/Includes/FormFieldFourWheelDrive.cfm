<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>



<cfif Action is "Form">	
	
	<cfoutput>		
		<tr>
			<td class="rightAtd">
				Four&nbsp;Wheel&nbsp;Drive:
			</td>
			<td>
				<input type="checkbox" name="FourWheelDrive" id="FourWheelDrive" value="1" <cfif caller.FourWheelDrive is "1">checked</cfif>>
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set FourWheelDrive=<cfif caller.FourWheelDrive is "1">1<cfelse>0</cfif>
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">			
						
</cfif>
