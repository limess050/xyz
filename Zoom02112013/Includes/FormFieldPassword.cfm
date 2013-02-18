NO LONGER IN USE<br>
FormFieldPassword.cfm
<cfabort>
<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif not IsDefined('session.UserID') or not Len(session.UserID)><!--- Skip completely if logged in. --->
	<cfif Action is "Form">	
		<cfoutput>	
				<tr>
					<td colspan="2">
						<hr>
						With your business listing, you will need to set up a username and password so you can go back and edit your listing, or post additional listings at a discounted rate, etc. etc. <strong>Your username is your primary contact email: </strong><br>&nbsp;
					</td>
				</tr>
				<tr>
					<td>
						<table>
							<tr>
								<td class="rightAtd">
									*&nbsp;Password:
								</td>
								<td>
									<input type="password" name="InProgressPassword" id="InProgressPassword" value="#caller.InProgressPassword#" maxLength="50" size="25">
								</td>
							</tr>
						</table>
					</td>
					<td>
						<table>
							<tr>
								<td class="rightAtd">
									*&nbsp;Retype&nbsp;Password:
								</td>
								<td>
									<input type="password" sname="ConfirmInProgressPassword" id="ConfirmInProgressPassword" value="<cfif Len(caller.InProgressPassword)>#caller.InProgressPassword#</cfif>" maxLength="50" size="25" onFocus="if (this.value=='confirm password') this.value=''">
								</td>
							</tr>
						
						</table>
					</td>
				</tr>		
		</cfoutput>
	<cfelseif Action is "Process">	
		<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update Listings
			Set InProgressPassword=<cfqueryparam value="#caller.InProgressPassword#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.InProgressPassword)#">
			Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>		
	<cfelseif Action is "Validate">	
			if (!checkText(formObj.elements["InProgressPassword"],"Password")) return false;			
			if (formObj.elements["InProgressPassword"].value!=formObj.elements["ConfirmInProgressPassword"].value) {
				alert('Password and Confirm Password must be identical.');
				document.f1.Password.focus();
				return false;
			}						
	</cfif>
</cfif>