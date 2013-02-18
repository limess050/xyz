<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td class="rightAtd">
				*&nbsp;<cfif ListFind("9",caller.ListingTypeID)>Minimum&nbsp;</cfif>Price:
			</td>
			<td>
				<input name="Price" id="Price" value="<cfif Len(caller.PriceTZS)>#NumberFormat(caller.PriceTZS,"_.__")#<cfelse>#NumberFormat(caller.PriceUS,"_.__")#</cfif>" maxLength="20">&nbsp;<select ID="PriceType" name="PriceType">
						<option value="US" <cfif not Len(caller.PriceTZS)>selected</cfif>>$US
						<option value="TZ" <cfif Len(caller.PriceTZS)>selected</cfif>>TSH
					</select>
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set 
		<cfif Len(caller.Price)>
			<cfif PriceType is "US">
				PriceUS=<cfqueryparam value="#caller.Price#" cfsqltype="CF_SQL_MONEY">,
				PriceTZS=null
			<cfelse>
				PriceUS=null,
				PriceTZS=<cfqueryparam value="#caller.Price#" cfsqltype="CF_SQL_MONEY">
			</cfif>
		<cfelse>
			PriceUS=null,
			PriceTZS=null
		</cfif>		
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
		if (!checkText(formObj.elements["Price"],"<cfif ListFind("9",caller.ListingTypeID)>Minimum </cfif>Price")) return false;
		if (!checkNumber(formObj.elements["Price"],"<cfif ListFind("9",caller.ListingTypeID)>Minimum </cfif>Price")) return false;
		if (trim(formObj.elements["Price"].value)!='') {
			if (!checkSelected(formObj.elements["PriceType"],"Currency Type")) return false;
		}	
</cfif>
