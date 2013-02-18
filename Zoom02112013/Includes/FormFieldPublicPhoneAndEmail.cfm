<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>



<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td class="rightAtd">
				*&nbsp;Primary Public Phone&nbsp;##:
			</td>
			<td>
				<input name="PublicPhone" id="PublicPhone" value="#caller.PublicPhone#" maxLength="20">
			</td>
		</tr>
		<cfif ListFind("1,2,14,20",caller.ListingTypeID)>
			<tr>
				<td class="rightAtd">
					Fax ##:
				</td>
				<td>
					<input name="PublicPhone2" id="PublicPhone2" value="#caller.PublicPhone2#" maxLength="20">
				</td>
			</tr>		
			<tr>
				<td class="rightAtd">
					Other Public Phone&nbsp;##:
				</td>
				<td>
					<input name="PublicPhone3" id="PublicPhone3" value="#caller.PublicPhone3#" maxLength="20">
				</td>
			</tr>		
			<tr>
				<td class="rightAtd">
					Other Public Phone&nbsp;##:
				</td>
				<td>
					<input name="PublicPhone4" id="PublicPhone4" value="#caller.PublicPhone4#" maxLength="20">
				</td>
			</tr>	
		</cfif>
		<tr>
			<td class="rightAtd">
				Public&nbsp;Email:<br>
				<span class="instructions">Although email is not a required field, we strongly recommend you provide one, but only if it will be checked at least 3 times a week.</span>
			</td>
			<td>
				<input name="PublicEmail" id="PublicEmail" value="#caller.PublicEmail#" maxLength="200" size="25"><p>
				<input name="ConfirmPublicEmail" id="ConfirmPublicEmail" value="<cfif Len(caller.PublicEmail)>#caller.PublicEmail#<cfelse>confirm email</cfif>" maxLength="200" size="25" onFocus="if (this.value=='confirm email') this.value=''">
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set PublicPhone=<cfqueryparam value="#caller.PublicPhone#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.PublicPhone)#">,
		<cfif ListFind("1,2,14,20",caller.ListingTypeID)>
			PublicPhone2=<cfqueryparam value="#caller.PublicPhone2#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.PublicPhone2)#">,
			PublicPhone3=<cfqueryparam value="#caller.PublicPhone3#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.PublicPhone3)#">,
			PublicPhone4=<cfqueryparam value="#caller.PublicPhone4#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.PublicPhone4)#">,
		</cfif>
		PublicEmail=<cfqueryparam value="#caller.PublicEmail#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.PublicEmail)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">				
		if (trim(formObj.elements["PublicPhone"].value)=='') {
			alert('You must provide a public phone.');
			document.f1.PublicPhone.focus();
			return false;
		}
		if (formObj.elements["PublicEmail"].value!=formObj.elements["ConfirmPublicEmail"].value && trim(formObj.elements["ConfirmPublicEmail"].value)!='confirm email') {
			alert('Public Email and Confirm Public Email must be identical.');
			document.f1.PublicEmail.focus();
			return false;
		}	
		if (!checkEmail(formObj.elements["PublicEmail"],"Public Email")) return false;		
</cfif>
