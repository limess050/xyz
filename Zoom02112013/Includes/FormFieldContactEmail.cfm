<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td colspan="2">
				<hr>
				<span class="instructions">A contact email address is required in case there is a problem or question regarding the listing.</span><br />&nbsp;
			</td>
		</tr>
		<tr>
			<td class="rightAtd">
				*&nbsp;Contact&nbsp;Email:
			</td>
			<td>
				<input name="ContactEmail" id="ContactEmail" value="#caller.ContactEmail#" maxLength="200" size="25"><br />
				<input name="ConfirmContactEmail" id="ConfirmContactEmail" value="<cfif Len(caller.ContactEmail)>#caller.ContactEmail#<cfelse>confirm email</cfif>" maxLength="200" size="25" onFocus="if (this.value=='confirm email') this.value=''">
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set ContactEmail=<cfqueryparam value="#caller.ContactEmail#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.ContactEmail)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
		if (!checkText(formObj.elements["ContactEmail"],"Contact Email")) return false;	
		if (formObj.elements["ContactEmail"].value!=formObj.elements["ConfirmContactEmail"].value) {
			alert('Contact Email and Confirm Contact Email must be identical.');
			document.f1.ContactEmail.focus();
			return false;
		}								
		if (!checkEmail(formObj.elements["ContactEmail"],"Contact Email")) return false;	
</cfif>
