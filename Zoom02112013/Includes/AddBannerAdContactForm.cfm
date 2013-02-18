<script language="javascript">
		function validateForm(formObj){
	
		if (!checkText(formObj.elements["InProgressCompanyName"],"Registered Company Name")) return false;	
			
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
	if (!checkEmail(formObj.elements["AltContactEmail"],"Contact Email")) return false;	
	if (formObj.elements["AltContactEmail"].value!=formObj.elements["ConfirmAltContactEmail"].value && formObj.elements["ConfirmAltContactEmail"].value!='confirm email') {
		alert('Second Contact Email and Confirm Second Contact Email must be identical.');
		document.f1.AltContactEmail.focus();
		return false;
	}
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
	
	if (formObj.elements["AllowContactEmail"].value==0) {
		alert('An account already exists with the primary email address.');
		}
		
		return true;
		}
	</script>
	<div class="centercol-inner-wide legacy legacy-wide">
	<form name="f1" action="page.cfm?PageID=<cfoutput>#Request.AddABannerAdPageID#</cfoutput>" method="post" ONSUBMIT="return validateForm(this)">
	<table style="padding-left:5px">
	<tr>
			<td colspan="2">
				<hr>
				<span class="instructions">You must have an account to purchase banner ads. If you already have an account,
				please <a href="/myaccount">login</a> to your "My Account" and click the "Add Banner Ad" button to proceed. If you do not have an account with us, please complete the contact information below.</span>
			<br>
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
											<input name="InProgressCompanyName" id="InProgressCompanyName" maxLength="200" size="45">
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
										<input name="ContactFirstName" id="ContactFirstName" maxLength="200">
									</td>
								</tr>
								<tr>
									<td class="rightAtd">
										*&nbsp;Contact&nbsp;Last&nbsp;Name:
									</td>
									<td>
										<input name="ContactLastName" id="ContactLastName" maxLength="200">
									</td>
								</tr>
								<tr>
									<td class="rightAtd">
										*&nbsp;Contact&nbsp;Phone:
									</td>
									<td>
										<input name="ContactPhone" id="ContactPhone" maxLength="20">
									</td>
								</tr>
								<tr>
									<td class="rightAtd">
										Contact Alternate Phone:
									</td>
									<td>
										<input name="ContactSecondPhone" id="ContactSecondPhone" maxLength="20">
									</td>
								</tr>
													
										
								
								<tr>
									<td class="rightAtd">
										*&nbsp;Contact&nbsp;Email:
									</td>
									<td>
										<input name="ContactEmail" id="ContactEmail"  maxLength="200" size="22"><br />
										<input name="ConfirmContactEmail" id="ConfirmContactEmail" maxLength="200" value="conrim email" size="22" onFocus="if (this.value=='confirm email') this.value=''">
									</td>
								</tr>
								
							
							</table>
						</td>
						<td valign="top">
							<table>
								<tr>
									<td class="rightAtd">
										Second&nbsp;Contact&nbsp;First&nbsp;Name:
									</td>
									<td>
										<input name="AltContactFirstName" id="AltContactFirstName" maxLength="200">
									</td>
								</tr>
								<tr>
									<td class="rightAtd">
										Second&nbsp;Contact&nbsp;Last&nbsp;Name:
									</td>
									<td>
										<input name="AltContactLastName" id="AltContactLastName" maxLength="200">
									</td>
								</tr>
								<tr>
									<td class="rightAtd">
										Second&nbsp;Contact&nbsp;Phone:
									</td>
									<td>
										<input name="AltContactPhone" id="AltContactPhone" maxLength="20">
									</td>
								</tr>
								<tr>
									<td class="rightAtd">
										Second&nbsp;Contact Alternate Phone:
									</td>
									<td>
										<input name="AltContactSecondPhone" id="AltContactSecondPhone" maxLength="20">
									</td>
								</tr>
								<tr>
									<td class="rightAtd">
										Second&nbsp;Contact&nbsp;Email:
									</td>
									<td>
										<input name="AltContactEmail" id="AltContactEmail" maxLength="200" size="22"><br />
										<input name="ConfirmAltContactEmail" id="ConfirmAltContactEmail" value="confirm email" maxLength="200" size="22" onFocus="if (this.value=='confirm email') this.value=''">
									</td>
								</tr>
								
							</table>
						</td>
					</tr>
									
				</table>
			</td>
		</tr>
		<tr>
					<td colspan="2">
						<hr>
						<ul>
							<li><span class="instructions">To edit this banner ad or post additional banner ads, you must login to your ‘My Account’ page with a <strong>Username</strong> and <strong>Password</strong>.<br><strong>Your username is your primary contact email: </span><span id="UsernameDisplay"></span>.&nbsp;<span id="EmailAlreadyInUse" style="color:red;"></span></strong></li>
							<li><span class="instructions">Please enter your password below. Please enter a password at least 4 characters long.</span></li>
						</ul>
					</td>
				</tr>
					<tr>
					<td class="rightAtd">
						*&nbsp;Password:
					</td>
					<td>
						<input type="password" name="InProgressPassword" id="InProgressPassword" maxLength="50" size="25">
					</td>
				</tr>
				<tr>
					<td class="rightAtd">
						*&nbsp;Retype&nbsp;Password:
					</td>
					<td>
						<input type="password" sname="ConfirmInProgressPassword" id="ConfirmInProgressPassword" maxLength="50" size="25">
				
					</td>
				</tr>
		
		<tr>
			<td>&nbsp;</td>
			<td>
				<div id="NextButtonDiv"><input type="submit" name="NewUser" value="Next >>"></div>
				<input type="hidden" name="AllowContactEmail" id="AllowContactEmail" value="1">
				<input type="hidden" name="Step" value="2">
			</td>
		</tr>
		</table>
		</form>
	</div>	
<cfoutput>
<script>
	$(document).ready(function()
	{
		$("##ContactEmail").change(handleEmailAsUsername); 
	
	});
	
	function handleEmailAsUsername() {
		$("##UsernameDisplay").html(document.f1.ContactEmail.value);	
		var datastring = "ContactEmail=" + encodeURIComponent(document.f1.ContactEmail.value);
		$.ajax(
           {
			type:"POST",					
               url:"#Request.HTTPURL#/includes/CheckAccountEmail.cfc?method=CheckEmail&returnformat=plain",
               data:datastring,
               success: function(response)
               {
				resp = jQuery.trim(response);					
                $("##EmailAlreadyInUse").html(resp);
				if (resp!=''){
					$("##ContactEmail").focus();
					$("##ContactEmail").val('');
					$("##UsernameDisplay").html('');	
					$("##AllowContactEmail").val('0');	
				}
				else {
					$("##UsernameDisplay").html(document.f1.ContactEmail.value);	
					$("##AllowContactEmail").val('1');	
				}
               }
           });
		
	}
</script>
</cfoutput>			