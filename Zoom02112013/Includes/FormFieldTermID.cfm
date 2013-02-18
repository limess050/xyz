<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>

<cfif Action is "Form">	
	<cfquery name="Terms" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select TermID as SelectValue, Title as SelectText 
		From Terms
		Where Active=1
		Order By OrderNum
	</cfquery>
	
	<cfoutput>		
		<tr>
			<td class="rightAtd">
				*&nbsp;Term:
			</td>
			<td>
				<select name="TermID" ID="TermID">
					<option value="">-- Select --
					<cfloop query="Terms">
						<option value="#SelectValue#" <cfif SelectValue is caller.TermID>Selected</cfif>>#SelectText#
					</cfloop>
				</select>
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set TermID=<cfqueryparam value="#caller.TermID#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.TermID)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">			
		<!--- if (!checkText(formObj.elements["TermID"],"Term")) return false;	 --->				
</cfif>
