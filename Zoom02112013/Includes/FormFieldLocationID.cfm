<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>

<cfset MultiAreas="1">
<cfif ListFind("3,4,5",caller.ListingTypeID)>
	<cfset MultiAreas="0">
</cfif>


<cfif Action is "Form">	
	<cfquery name="Locations" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select LocationID as SelectValue, Title as SelectText 
		From Locations
		Where Active=1
		Order By OrderNum
	</cfquery>
	
	<cfoutput>		
		<tr>
			<td class="rightAtd">
				*&nbsp;Area:<br />
				<cfif MultiAreas>
					<span class="instructions">(Choose all that apply)<br />To multi-select, hold the “Ctrl” key and click each option desired.</span>
				</cfif>
			</td>
			<td>
				<select name="LocationID" id="LocationID" <cfif MultiAreas>multiple</cfif>>
					<option value="">-- Select --
					<cfloop query="Locations">
						<option value="#SelectValue#" <cfif ListFind(caller.LocationID,SelectValue)>Selected</cfif>>#SelectText#
					</cfloop>
				</select>
			</td>
		</tr>
		<tr id="LocationOther_TR" style="display:none">
			<td class="rightAtd">Area (Other):</td>
			<td>
				<!--- <input type="hidden" name="LocationID" value="#caller.LocationID#"> --->
				<input type="text" name="LocationOther" ID="LocationOther" value="#caller.LocationOther#">			
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set LocationOther=<cfqueryparam value="#caller.LocationOther#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.LocationOther)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfquery name="deleteExistingLocations"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Delete From ListingLocations
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfloop list="#LocationID#" index="i">		
		<cfquery name="insertLocations"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Insert into ListingLocations
			(ListingID, LocationID)
			VALUES
			(<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">,
			<cfqueryparam value="#i#" cfsqltype="CF_SQL_INTEGER">)
		</cfquery>
	</cfloop>
<cfelseif Action is "Validate">			
		if (!checkSelected(formObj.elements["LocationID"],"Area")) return false;	
		var validateLocationOtherField=0;
		$('#LocationID :selected').each(function(i, selected){
			if ($(selected).val()==4) {
				validateLocationOtherField=1;
			}
		});
		if (validateLocationOtherField==1) {
			if (!checkText(formObj.elements["LocationOther"],"Area (Other)")) return false;	
		}				
</cfif>
