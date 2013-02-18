<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>



<cfif Action is "Form">	
	<cfquery name="Models" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select ModelID as SelectValue, Title as SelectText 
		From Models
		Where Active=1
		AND MakeID = <cfqueryparam value="#caller.MakeID#">
		Order By OrderNum
	</cfquery>
	
	<cfoutput>		
		<tr id="ModelID_TR">
			<td class="rightAtd">
				*&nbsp;Model:
			</td>
			<td>
				<select name="ModelID" ID="ModelID">
					<option value="">-- Select A Make First --
					<cfloop query="Models">
						<option value="#SelectValue#" <cfif SelectValue is caller.ModelID>Selected</cfif>>#SelectText#
					</cfloop>
				</select>
			</td>
		</tr>
		<tr id="ModelOther_TR" <cfif caller.ModelID NEQ 0 AND caller.MakeID NEQ 0>style="display:none"</cfif>>
			<td class="rightAtd">
				&nbsp;Model Other:
			</td>
			<td>
				<input name="ModelOther" id="ModelOther" value="#caller.ModelOther#" maxLength="20">
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set 
		<cfif ModelID NEQ 0>
			ModelID=<cfqueryparam value="#caller.ModelID#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.ModelID)#">,
		</cfif>
		Model=<cfqueryparam value="#caller.ModelOther#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.ModelOther)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">			
		if (!checkText(formObj.elements["ModelID"],"Model")) return false;
		<cfif caller.ModelID EQ 0>
			if (!checkText(formObj.elements["ModelOther"],"Model Other")) return false;
		</cfif>						
</cfif>
