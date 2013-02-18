<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>



<cfif Action is "Form">	
	<cfquery name="Parks" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select ParkID as SelectValue, Title as SelectText 
		From Parks
		Where Active=1
		Order By OrderNum
	</cfquery>
	
	<cfoutput>		
		<tr>
			<td class="rightAtd">
				In what National Park or Wildlife Area are you located, or <strong>regularly</strong> provide trips to:<br />
				<span class="instructions">(Choose all that apply)<br />To multi-select, hold the “Ctrl” key and click each option desired.</span>
			</td>
			<td>
				<select name="ParkID" id="ParkID" multiple>
					<option value="">-- Select --
					<cfloop query="Parks">
						<option value="#SelectValue#" <cfif ListFind(caller.ParkID,SelectValue)>Selected</cfif>>#SelectText#
					</cfloop>
				</select>
			</td>
		</tr>
		<tr id="ParkOther_TR" style="display:none">
			<td class="rightAtd">National Park or Wildlife Area (Other):</td>
			<td>
				<!--- <input type="hidden" name="ParkID" value="#caller.ParkID#"> --->
				<input type="text" name="ParkOther" ID="ParkOther" value="#caller.ParkOther#">			
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set ParkOther=<cfqueryparam value="#caller.ParkOther#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.ParkOther)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfquery name="deleteExistingParks"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Delete From ListingParks
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfloop list="#ParkID#" index="i">		
		<cfquery name="insertParks"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Insert into ListingParks
			(ListingID, ParkID)
			VALUES
			(<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">,
			<cfqueryparam value="#i#" cfsqltype="CF_SQL_INTEGER">)
		</cfquery>
	</cfloop>
<cfelseif Action is "Validate">			
		<!--- if (!checkSelected(formObj.elements["ParkID"],"Area")) return false;	 --->
		var validateParkOtherField=0;
		$('##ParkID:selected').each(function(i, selected){
			if ($(selected).val()==1) {
				validateParkOtherField=1;
			}
		});
		if (validateParkOtherField==1) {
			if (!checkText(formObj.elements["ParkOther"],"National Park or Wilslife Area (Other)")) return false;	
		}				
</cfif>
