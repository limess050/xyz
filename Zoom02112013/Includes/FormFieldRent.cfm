<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td class="rightAtd">
				*&nbsp;Rent:
			</td>
			<td>
				<input name="Rent" id="Rent" value="<cfif Len(caller.RentTZS)>#caller.RentTZS#<cfelse>#caller.RentUS#</cfif>" maxLength="20">&nbsp;<select ID="RentType" name="RentType">
						<option value="US" <cfif not Len(caller.RentTZS)>selected</cfif>>$US
						<option value="TZ" <cfif Len(caller.RentTZS)>selected</cfif>>TSH
					</select>
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set 
		<cfif Len(caller.Rent)>
			<cfif RentType is "US">
				RentUS=<cfqueryparam value="#caller.Rent#" cfsqltype="CF_SQL_MONEY">,
				RentTZS=null
			<cfelse>
				RentUS=null,
				RentTZS=<cfqueryparam value="#caller.Rent#" cfsqltype="CF_SQL_MONEY">
			</cfif>
		<cfelse>
			RentUS=null,
			RentTZS=null
		</cfif>		
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
	if (!checkText(formObj.elements["Rent"],"Rent")) return false;
	if (!checkNumber(formObj.elements["Rent"],"Rent")) return false;
	if (trim(formObj.elements["Rent"].value)!='') {
		if (!checkSelected(formObj.elements["RentType"],"Rent Currency Type")) return false;
	}	
</cfif>
