<!--- The InProgressPassword is only stored in a Business Listing Record until that record is submitted as complete. At that point, an Account is created in LH_Users and the password is moved there. Listings that are being edtied after the account is created will not include the password fields, since passwords should be updated only through the My Account pages. --->

<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>

<cfif not IsDefined('session.UserID') or not Len(session.UserID)><!--- Skip completely if logged in. --->
	<cfif not Len(caller.InProgress) or caller.InProgress>
		<cfif Action is "Form">	
			<cfoutput>	
				<tr>
					<td colspan="2">
						<hr>
						<p>To edit this listing and/or post additional listings as part of this account, you must login to your "My Account" page with a Username and Password.<br>&nbsp;<br>
						Your Username is: <strong><span id="UsernameDisplay">#caller.ContactEmail#</span>.&nbsp;<span id="EmailAlreadyInUse" style="color:red;"></span></strong><br>&nbsp;<br>
						Please choose a password below.  Your password must be at least 4 characters long.</p>
					</td>
				</tr>
				<tr>
					<td class="rightAtd">
						*&nbsp;Password:
					</td>
					<td>
						<input type="password" name="InProgressPassword" id="InProgressPassword" value="#caller.InProgressPassword#" maxLength="50" size="25">
					</td>
				</tr>
				<tr>
					<td class="rightAtd">
						*&nbsp;Retype&nbsp;Password:
					</td>
					<td>
						<input type="password" sname="ConfirmInProgressPassword" id="ConfirmInProgressPassword" value="#caller.InProgressPassword#" maxLength="50" size="25">
						<input type="hidden" name="AllowContactEmail" ID="AllowContactEmail" value="1">
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
				if (formObj.elements["InProgressPassword"].value.length < 4){
					alert('Password must be at least 4 characters.')
					return false;
				}
				if (formObj.elements["InProgressPassword"].value!=formObj.elements["ConfirmInProgressPassword"].value) {
					alert('Password and Confirm Password must be identical.');
					document.f1.InProgressPassword.focus();
					return false;
				}	
				handleEmailAsUsername();
				if (formObj.elements["AllowContactEmail"].value==0) {
					alert('An account already exists with the primary email address"' + formObj.elements["ContactEmail"].value + '". The primary email address is the accounts username and must be unique.');
					formObj.elements["ContactEmail"].focus();
					return false;
				}	
		</cfif>
	</cfif>
</cfif>
