<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>



<cfif Action is "Form">	
	<cfquery name="Makes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select MakeID as SelectValue, Title as SelectText 
		From Makes
		Where Active=1
		Order By OrderNum
	</cfquery>
	
	<cfoutput>		
		<tr>
			<td class="rightAtd">
				*&nbsp;Make:
			</td>
			<td>
				<select name="MakeID" ID="MakeID">
					<option value="">-- Select --
					<cfloop query="Makes">
						<option value="#SelectValue#" <cfif SelectValue is caller.MakeID>Selected</cfif>>#SelectText#
					</cfloop>
				</select>
			</td>
		</tr>
		<tr id="MakeOther_TR" <cfif caller.MakeID NEQ 0>style="display:none"</cfif>>
			<td class="rightAtd">
				&nbsp;Make Other:
			</td>
			<td>
				<input name="MakeOther" id="MakeOther" value="#caller.MakeOther#" maxLength="20">
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set 
		MakeID=<cfqueryparam value="#caller.MakeID#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.MakeID)#">,
		Make=<cfqueryparam value="#caller.MakeOther#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.MakeOther)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">			
		if (!checkText(formObj.elements["MakeID"],"Make")) return false;
		<cfif caller.MakeID EQ 1>
			if (!checkText(formObj.elements["MakeOther"],"Make Other")) return false;
		</cfif>					
</cfif>
