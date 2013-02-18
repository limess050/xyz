No longer in use (includes/FormFieldFluencyID.cfm<cfabort>

<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>



<cfif Action is "Form">	
	<cfquery name="Fluencies" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select FluencyID as SelectValue, Title as SelectText 
		From Fluencies
		Where Active=1
		Order By OrderNum
	</cfquery>
	
	<cfoutput>		
		<tr>
			<td class="rightAtd">
				
				<cfswitch expression="#caller.ListingTypeID#">
					<cfcase value="12">
						*&nbsp;Language&nbsp;Required:
					</cfcase>
					<cfdefaultCase>
						*&nbsp;English&nbsp;Proficiency:<br>
						<span class="instructions">What language skills should a customer expect when they call the phone numbers you provided above.</span>
					</cfdefaultcase>
				</cfswitch>
			</td>
			<td>
				<select name="FluencyID" ID="FluencyID">
					<option value="">-- Select --
					<cfloop query="Fluencies">
						<option value="#SelectValue#" <cfif SelectValue is caller.FluencyID>Selected</cfif>>#SelectText#
					</cfloop>
				</select>
			</td>
		</tr>	
		<tr style="display:none" id="FluencyOther_TR">
			<td class="rightAtd">
				*&nbsp;Other:
			</td>
			<td>
				<input type="text" name="FluencyOther" ID="FluencyOther" value="#caller.FluencyOther#" maxLength="200">
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set FluencyID=<cfqueryparam value="#caller.FluencyID#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(caller.FluencyID)#">,
		FluencyOther=<cfqueryparam value="#caller.FluencyOther#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.FluencyOther)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">			
		if (!checkSelected(formObj.elements["FluencyID"],"English Proficiency")) return false;		
		if (document.f1.FluencyID[document.f1.FluencyID.selectedIndex].value==4) {
			if (!checkText(formObj.elements["FluencyOther"],"English Proficiency (Other)")) return false;	
		}							
</cfif>
