<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>



<cfif Action is "Form">	
	<cfquery name="Amenities" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select AmenityID as SelectValue, Title as SelectText 
		From Amenities
		Where Active=1
		Order By OrderNum
	</cfquery>
	
	<cfoutput>		
		<tr>
			<td class="rightAtd">
				Amenities:<br />
				<span class="instructions">(Choose all that apply)<br />To multi-select, hold the “Ctrl” key and click each option desired.</span>
			</td>
			<td>
				<select name="AmenityID" id="AmenityID" size="8" multiple>
					<cfloop query="Amenities">
						<option value="#SelectValue#" <cfif ListFind(caller.AmenityID,SelectValue)>Selected</cfif>>#SelectText#
					</cfloop>
				</select>
			</td>
		</tr>	
		<tr style="display:none" id="AmenityOther_TR">
			<td class="rightAtd">
				*&nbsp;Amenity&nbsp;(Other):
			</td>
			<td>
				<input type="text" name="AmenityOther" ID="AmenityOther" value="#caller.AmenityOther#" maxLength="200">
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<!--- Delete existing records --->
	<cfquery name="insertListingAmenities"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Delete From ListingAmenities
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<!--- Add new records --->
	<cfloop list="#caller.AmenityID#" index="i">		
		<cfquery name="insertListingAmenities"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Insert into ListingAmenities
			(ListingID, AmenityID)
			VALUES
			(<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">,
			<cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">)
		</cfquery>			
		<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update Listings
			Set AmenityOther=<cfqueryparam value="#caller.AmenityOther#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.AmenityOther)#">
			Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cfloop>
<cfelseif Action is "Validate">			
		if (document.f1.AmenityID[document.f1.AmenityID.selectedIndex].value==1) {
			if (!checkText(formObj.elements["AmenityOther"],"Amenity (Other)")) return false;	
		}			
</cfif>
