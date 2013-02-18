<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td class="rightAtd">
				Square&nbsp;Feet/Meters:
			</td>
			<td>
				<input name="Square" id="Square" value="<cfif Len(caller.SquareFeet)>#caller.SquareFeet#<cfelseif Len(caller.SquareMeters)>#caller.SquareMeters#</cfif>" maxLength="20">&nbsp;<select ID="SquareType" name="SquareType">
						<option value="">-- Select Unit Type --
						<option value="M" <cfif Len(caller.SquareMeters)>selected</cfif>>Square Meters
						<option value="F" <cfif Len(caller.SquareFeet)>selected</cfif>>Square Feet
					</select>
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set 
		<cfif Len(caller.Square)>
			<cfif SquareType is "M">
				SquareMeters=<cfqueryparam value="#caller.Square#" cfsqltype="CF_SQL_MONEY">,
				SquareFeet=null
			<cfelse>
				SquareMeters=null,
				SquareFeet=<cfqueryparam value="#caller.Square#" cfsqltype="CF_SQL_MONEY">
			</cfif>
		<cfelse>
			SquareMeters=null,
			SquareFeet=null
		</cfif>		
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
		if (!checkNumber(formObj.elements["Square"],"Square Meters/Feet")) return false;
		if (trim(formObj.elements["Square"].value)!='') {
			if (!checkSelected(formObj.elements["SquareType"],"Square Meters/Feet Unit Type")) return false;
		}	
</cfif>
