<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td colspan="2">
				<hr>
				<span class="instructions">The following information will not be posted as part of your listing or appear anywhere on ZoomTanzania.com.  If we  have any questions or concerns related to this listing, who should ZoomTanzania.com contact? </span>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<table>	
					<cfif not IsDefined('session.UserID') or not Len(session.UserID)><!--- Skip if logged in. --->
						<tr>
							<td colspan="2">
								<table>
									<tr>
										<td class="rightAtd">
											*&nbsp;Registered&nbsp;Company&nbsp;Name:
											<br /><span class="instructions">This is required for your tax invoice</span>
										</td>
										<td>
											<input name="InProgressCompanyName" id="InProgressCompanyName" value="#caller.InProgressCompanyName#" maxLength="200" size="45">
										</td>										
									</tr>
								</table>
							</td>
						</tr>
					</cfif>
					<tr>
						<td>
							&nbsp;
						</td>
						<td>
							<span class="instructions">Although not required, we recommend you provide a second person in case we have difficulty reaching the first.</span>
						</td>
					</tr>			
					<tr>
						<td>
							<table>
								<tr>
									<td class="rightAtd">
										*&nbsp;Contact&nbsp;First&nbsp;Name:
									</td>
									<td>
										<input name="ContactFirstName" id="ContactFirstName" value="#caller.ContactFirstName#" maxLength="200">
									</td>
								</tr>
								<tr>
									<td class="rightAtd">
										*&nbsp;Contact&nbsp;Last&nbsp;Name:
									</td>
									<td>
										<input name="ContactLastName" id="ContactLastName" value="#caller.ContactLastName#" maxLength="200">
									</td>
								</tr>
								<tr>
									<td class="rightAtd">
										*&nbsp;Contact&nbsp;Phone:
									</td>
									<td>
										<input name="ContactPhone" id="ContactPhone" value="#caller.ContactPhone#" maxLength="20">
									</td>
								</tr>
								<tr>
									<td class="rightAtd">
										Contact Alternate Phone:
									</td>
									<td>
										<input name="ContactSecondPhone" id="ContactSecondPhone" value="#caller.ContactSecondPhone#" maxLength="20">
									</td>
								</tr>
								<tr>
									<td class="rightAtd">
										*&nbsp;Contact&nbsp;Email:
									</td>
									<td>
										<input name="ContactEmail" id="ContactEmail" value="#caller.ContactEmail#" maxLength="200" size="22"><br />
										<input name="ConfirmContactEmail" id="ConfirmContactEmail" value="<cfif Len(caller.ContactEmail)>#caller.ContactEmail#<cfelse>confirm email</cfif>" maxLength="200" size="22" onFocus="if (this.value=='confirm email') this.value=''">
									</td>
								</tr>
							</table>
						</td>
						<td>
							<table>
								<tr>
									<td class="rightAtd">
										Second&nbsp;Contact&nbsp;First&nbsp;Name:
									</td>
									<td>
										<input name="AltContactFirstName" id="AltContactFirstName" value="#caller.AltContactFirstName#" maxLength="200">
									</td>
								</tr>
								<tr>
									<td class="rightAtd">
										Second&nbsp;Contact&nbsp;Last&nbsp;Name:
									</td>
									<td>
										<input name="AltContactLastName" id="AltContactLastName" value="#caller.AltContactLastName#" maxLength="200">
									</td>
								</tr>
								<tr>
									<td class="rightAtd">
										Second&nbsp;Contact&nbsp;Phone:
									</td>
									<td>
										<input name="AltContactPhone" id="AltContactPhone" value="#caller.AltContactPhone#" maxLength="20">
									</td>
								</tr>
								<tr>
									<td class="rightAtd">
										Second&nbsp;Contact Alternate Phone:
									</td>
									<td>
										<input name="AltContactSecondPhone" id="AltContactSecondPhone" value="#caller.AltContactSecondPhone#" maxLength="20">
									</td>
								</tr>
								<tr>
									<td class="rightAtd">
										Second&nbsp;Contact&nbsp;Email:
									</td>
									<td>
										<input name="AltContactEmail" id="AltContactEmail" value="#caller.AltContactEmail#" maxLength="200" size="22"><br />
										<input name="ConfirmAltContactEmail" id="ConfirmAltContactEmail" value="<cfif Len(caller.AltContactEmail)>#caller.AltContactEmail#<cfelse>confirm email</cfif>" maxLength="200" size="22" onFocus="if (this.value=='confirm email') this.value=''">
									</td>
								</tr>
							</table>
						</td>
					</tr>				
				</table>
			</td>
		</tr>
		
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set 
		<cfif not IsDefined('session.UserID') or not Len(session.UserID)>
			InProgressCompanyName=<cfqueryparam value="#caller.InProgressCompanyName#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.InProgressCompanyName)#">,
		</cfif>
		ContactFirstName=<cfqueryparam value="#caller.ContactFirstName#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.ContactFirstName)#">,
		ContactLastName=<cfqueryparam value="#caller.ContactLastName#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.ContactLastName)#">,
		ContactEmail=<cfqueryparam value="#caller.ContactEmail#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.ContactEmail)#">,
		ContactPhone=<cfqueryparam value="#caller.ContactPhone#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.ContactPhone)#">,
		ContactSecondPhone=<cfqueryparam value="#caller.ContactSecondPhone#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.ContactSecondPhone)#">,
		AltContactFirstName=<cfqueryparam value="#caller.AltContactFirstName#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.AltContactFirstName)#">,
		AltContactLastName=<cfqueryparam value="#caller.AltContactLastName#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.AltContactLastName)#">,
		AltContactEmail=<cfqueryparam value="#caller.AltContactEmail#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.AltContactEmail)#">,
		AltContactPhone=<cfqueryparam value="#caller.AltContactPhone#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.AltContactPhone)#">,
		AltContactSecondPhone=<cfqueryparam value="#caller.AltContactSecondPhone#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.AltContactSecondPhone)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
	<cfif not IsDefined('session.UserID') or not Len(session.UserID)>
		if (!checkText(formObj.elements["InProgressCompanyName"],"Registered Company Name")) return false;	
	</cfif>
	if (!checkText(formObj.elements["ContactFirstName"],"Contact First Name")) return false;	
	if (!checkText(formObj.elements["ContactLastName"],"Contact Last Name")) return false;
	if (!checkText(formObj.elements["ContactPhone"],"Contact Phone")) return false;			
	if (!checkText(formObj.elements["ContactEmail"],"Contact Email")) return false;
	if (formObj.elements["ContactEmail"].value!=formObj.elements["ConfirmContactEmail"].value) {
		alert('Contact Email and Confirm Contact Email must be identical.');
		document.f1.ContactEmail.focus();
		return false;
	}									
	if (!checkEmail(formObj.elements["ContactEmail"],"Contact Email")) return false;	
	<!--- if (!checkText(formObj.elements["AltContactFirstName"],"Second Contact First Name")) return false;	
	if (!checkText(formObj.elements["AltContactLastName"],"Second Contact Last Name")) return false;	
	if (!checkText(formObj.elements["AltContactPhone"],"Second Contact Phone")) return false;	
	if (!checkText(formObj.elements["AltContactEmail"],"Second Contact Email")) return false;	 --->	
	if (!checkEmail(formObj.elements["AltContactEmail"],"Contact Email")) return false;	
	if (formObj.elements["AltContactEmail"].value!=formObj.elements["ConfirmAltContactEmail"].value && formObj.elements["ConfirmAltContactEmail"].value!='confirm email') {
		alert('Second Contact Email and Confirm Second Contact Email must be identical.');
		document.f1.AltContactEmail.focus();
		return false;
	}						
</cfif>
