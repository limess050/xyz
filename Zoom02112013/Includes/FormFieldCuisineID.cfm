<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>



<cfif Action is "Form">	
	<cfquery name="Cuisines" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select CuisineID as SelectValue, Title as SelectText 
		From Cuisines
		Where Active=1
		Order By OrderNum
	</cfquery>
	
	<cfoutput>		
		<tr>
			<td class="rightAtd">
				<cfif not caller.PhoneOnlyEntry>*&nbsp;</cfif>Cuisine&nbsp;Type:<br />
				<span class="instructions">(Choose all that apply)<br />To multi-select, hold the “Ctrl” key and click each option desired.</span>
			</td>
			<td>
				<select name="CuisineID" id="CuisineID" size="8" multiple>
					<cfloop query="Cuisines">
						<option value="#SelectValue#" <cfif ListFind(caller.CuisineID,SelectValue)>Selected</cfif>>#SelectText#
					</cfloop>
				</select>
			</td>
		</tr>	
		<tr style="display:none" id="CuisineOther_TR">
			<td class="rightAtd">
				*&nbsp;Cuisine&nbsp;(Other):
			</td>
			<td>
				<input type="text" name="CuisineOther" ID="CuisineOther" value="#caller.CuisineOther#" maxLength="200">
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<!--- Delete existing records --->
	<cfquery name="insertListingCuisines"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Delete From ListingCuisines
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<!--- Add new records --->
	<cfloop list="#caller.CuisineID#" index="i">		
		<cfquery name="insertListingCuisines"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Insert into ListingCuisines
			(ListingID, CuisineID)
			VALUES
			(<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">,
			<cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">)
		</cfquery>			
		<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update Listings
			Set CuisineOther=<cfqueryparam value="#caller.CuisineOther#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.CuisineOther)#">
			Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cfloop>
<cfelseif Action is "Validate">			
		<cfif not caller.PhoneOnlyEntry>if (!checkSelected(formObj.elements["CuisineID"],"Cuisine Type")) return false;</cfif>
		if (document.f1.CuisineID[document.f1.CuisineID.selectedIndex].value==4) {
			if (!checkText(formObj.elements["CuisineOther"],"Cuisine (Other)")) return false;	
		}			
</cfif>
