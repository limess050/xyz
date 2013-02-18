<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>



<cfif Action is "Form">	
	<cfquery name="NGOTypes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select NGOTypeID as SelectValue, Title as SelectText 
		From NGOTypes
		Where Active=1
		Order By OrderNum
	</cfquery>
	
	<cfoutput>		
		<tr>
			<td class="rightAtd">
				*&nbsp;NGO&nbsp;Type:<br />
				<span class="instructions">(Choose all that apply)<br />To multi-select, hold the “Ctrl” key and click each option desired.</span>
			</td>
			<td>
				<select name="NGOTypeID" id="NGOTypeID" size="8" multiple>
					<cfloop query="NGOTypes">
						<option value="#SelectValue#" <cfif ListFind(caller.NGOTypeID,SelectValue)>Selected</cfif>>#SelectText#
					</cfloop>
				</select>
			</td>
		</tr>	
		<tr style="display:none" id="NGOTypeOther_TR">
			<td class="rightAtd">
				*&nbsp;NGO Type&nbsp;(Other):
			</td>
			<td>
				<input type="text" name="NGOTypeOther" ID="NGOTypeOther" value="#caller.NGOTypeOther#" maxLength="200">
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<!--- Delete existing records --->
	<cfquery name="insertListingNGOTypes"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Delete From ListingNGOTypes
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<!--- Add new records --->
	<cfloop list="#caller.NGOTypeID#" index="i">		
		<cfquery name="insertListingNGOTypes"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Insert into ListingNGOTypes
			(ListingID, NGOTypeID)
			VALUES
			(<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">,
			<cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">)
		</cfquery>			
		<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update Listings
			Set NGOTypeOther=<cfqueryparam value="#caller.NGOTypeOther#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.NGOTypeOther)#">
			Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cfloop>
<cfelseif Action is "Validate">			
		if (!checkSelected(formObj.elements["NGOTypeID"],"NGO Type")) return false;		
		if (document.f1.NGOTypeID[document.f1.NGOTypeID.selectedIndex].value==1) {
			if (!checkText(formObj.elements["NGOTypeOther"],"NGO Type (Other)")) return false;	
		}			
</cfif>
