<cfparam name="ConfirmationID" default="">
<cfparam name="NewAccount" default="0">
<cfparam name="IncludeAlertSectionSelect" default="1">

<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfif not Len(ConfirmationID)>
	<cfset NewAccount = "1">
</cfif>
<cfquery name="Areas" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select AreaID as SelectValue, Descr as SelectText
	From Areas
	Order by OrderNum
</cfquery>
<cfquery name="Genders" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select GenderID as SelectValue, Descr as SelectText
	From Genders
	Order by OrderNum
</cfquery>
<cfquery name="SelfIdentifiedTypes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select SelfIdentifiedTypeID as SelectValue, Descr as SelectText
	From SelfIdentifiedTypes
	Order by OrderNum
</cfquery>
<cfquery name="EducationLevels" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select EducationLevelID as SelectValue, Descr as SelectText
	From EducationLevels
	Order by OrderNum
</cfquery>

<!--- Get "bodyDemog" pagePart from Request.CreateAccountPageID page to use regardless of whther theu user is on the Manage Alert Page, Sign Up For Alerts page, or Create Account page.--->

<cfquery name="getDemogrPagePart" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT label,shortValue,longValue 
	FROM LH_PageParts_Live
	WHERE pageID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Request.CreateAccountPageID#">
	and Label='BodyDemogrQuestionsHeader'
</cfquery>
<cfif len(getDemogrPagePart.shortValue) gt 0>
	<cfset BodyDemogrQuestionsHeader = getDemogrPagePart.shortValue>
<cfelse>
	<cfset BodyDemogrQuestionsHeader = getDemogrPagePart.longValue>
</cfif>

<cfoutput>
<script>
	function validateForm(formObj) {		
		if (!checkText(formObj.elements["FirstName"],"First Name")) return false;	
		if (!checkText(formObj.elements["Email"],"Email")) return false;	
		if (!checkEmail(formObj.elements["Email"],"Email")) return false;	
		if ($("##Email").val()!=$("##ConfirmEmail").val()) {
			alert("Email and Confirm Email values must be the same.");
			$("##Email").focus();
			return false;		
		}
		<cfif NewAccount>
			if (formObj.elements["Password"].value.length < 4){
					alert('Password must be at least 4 characters.')
					document.f1.Password.focus();
					return false;
				}
				if (formObj.elements["Password"].value!=formObj.elements["ConfirmPassword"].value) {
					alert('Password and Confirm Password must be identical.');
					document.f1.Password.focus();
					return false;
				}	
				if (formObj.elements["AllowEmail"].value==0) {
					alert('An account already exists with the primary email address"' + formObj.elements["Email"].value + '". The primary email address is the accounts username and must be unique.');
					formObj.elements["Email"].focus();
					return false;
				}
			<cfif IncludeAlertSectionSelect>
				if (!checkSelected(formObj.elements["AlertSectionIDs"],"Kinds of Alerts")) return false;
			</cfif>	
		</cfif>
		if (!checkSelected(formObj.elements["AreaID"],"Area")) return false;
		if (!checkSelected(formObj.elements["GenderID"],"Gender")) return false;
		if (!checkSelected(formObj.elements["BirthMonthID"],"Birth Month")) return false;
		if (!checkSelected(formObj.elements["BirthYearID"],"Birth Year")) return false;
		if (!checkSelected(formObj.elements["SelfIdentifiedTypeID"],"Best Describe Yourself")) return false;	
		if (!checkSelected(formObj.elements["EducationLevelID"],"Highest Level of Education")) return false;	
		return true;
	}
	
	
	$(document).ready(function()
	{
		$("##Email").change(handleEmailAsUsername);
		
		<cfif NewAccount>
			$('##password-clear').show();
			$('##ConfirmPassword').hide();
			$('##email-clear').show();
			$('##ConfirmEmail').hide();
		
			$('##password-clear').focus(function() {
				$('##password-clear').hide();
				$('##ConfirmPassword').show();
				$('##ConfirmPassword').focus();
			});
			$('##ConfirmPassword').blur(function() {
				if($('##ConfirmPassword').val() == '') {
					$('##password-clear').show();
					$('##ConfirmPassword').hide();
				}
			});
			
			$('##email-clear').show();
			$('##ConfirmEmail').hide();
		
			$('##email-clear').focus(function() {
				$('##email-clear').hide();
				$('##ConfirmEmail').show();
				$('##ConfirmEmail').focus();
			});
			$('##ConfirmEmail').blur(function() {
				if($('##ConfirmEmail').val() == '') {
					$('##email-clear').show();
					$('##ConfirmEmail').hide();
				}
			});
		<cfelse>
			$('##ConfirmEmail').show();
			$('##email-clear').hide();
		</cfif>
			
	
	});
	
	function handleEmailAsUsername() {
		$("##UsernameDisplay").html(document.f1.Email.value);	
		var datastring = "ContactEmail=" + encodeURIComponent(document.f1.Email.value);
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
					$("##Email").focus();
					$("##Email").val('');
					$("##UsernameDisplay").html('');	
					$("##AllowEmail").val('0');	
				}
				else {
					$("##UsernameDisplay").html(document.f1.Email.value);	
					$("##AllowEmail").val('1');	
				}
               }
           });
		
	}

</script>


<form name="f1" action="page.cfm?PageID=<cfif PageID is Request.CreateAccountPageID>#Request.CreateAccountPageID#<cfelseif NewAccount>#request.AddAlertPageID#<cfelse>#Request.ManageAlertPageID#</cfif>" method="post" ONSUBMIT="return validateForm(this)">
	
	<cfif NewAccount>
		<input type="hidden" name="Step" value="2">
		<input type="hidden" name="AllowEmail" ID="AllowEmail" value="1">
	<cfelse>
		<input type="hidden" name="ConfirmationID" value="#ConfirmationID#">
		<input type="hidden" name="Step" value="9">
	</cfif>
<table border="0" cellspacing="0" cellpadding="0" class="datatable">
		<tr>
			<td valign="top" colspan=2>
				<strong>Please complete the form below. Required fields are marked with an *.</strong>
			</td>
		</tr>
		<tr>
			<td class="rightAtd">
				*&nbsp; First Name or Alias:
			</td>
			<td>
				<input type = "text" name = "FirstName" id = "FirstName" max="100" value="#FirstName#" />
			</td>
		</tr>		
		
		<tr>
			<td class="rightAtd">
				*&nbsp;Email:
			</td>
			<td>
				<input type = "text" name = "Email" id = "Email" value="#Email#"/><br>
				<input type = "text" name = "ConfirmEmail" id = "ConfirmEmail" value = "#Email#" />
				<input id="email-clear" type="text" value="Confirm Email" autocomplete="off" />
				<div id="EmailAlreadyInUse" style="color:red; width: 330px;"></div>
			</td>
		</tr>
		<cfif NewAccount>		
			<tr>
				<td class="rightAtd">
					*&nbsp;Password:
				</td>
				<td>
					<input type = "password" name = "Password" id = "Password" value=""/><br>
					<input type = "password" name = "ConfirmPassword" id = "ConfirmPassword" value = ""  />
					<input id="password-clear" type="text" value="Confirm Password" autocomplete="off" />
				</td>
			</tr>
			<cfif IncludeAlertSectionSelect>
				<tr>
					<td class="rightAtd">
						*&nbsp;What kind of alert(s) do you want to receive?<br><strong>(Choose all that apply)</strong>
							<span class="instructions"><br />To multi-select, hold the "Ctrl" key and click each option desired.</span>
					</td>
					<td>
						<select name="AlertSectionIDs" id="AlertSectionIDs" multiple size=8>
							<cfloop query="AlertSections">
								<option value="#SelectValue#" <cfif ListFind(AlertSectionIDs,SelectValue)>selected</cfif>>#SelectText#</option>
							</cfloop>
						</select>
					</td>
				</tr>
			</cfif>
		</cfif>	
		<tr>
			<td valign="top" colspan=2>
				<div class="body pagepart" style="">#BodyDemogrQuestionsHeader#</div>
			</td>
		</tr>
		<tr>
			<td class="rightAtd">
				*&nbsp;Area
				<br><span class="instructions">Please choose the area closest to where you live.</span>
			</td>
			<td>
				<select name="AreaID" id="AreaID">
					<option value = "">-- Select your area --</option>
					<cfloop query="Areas">
						<option value="#SelectValue#" <cfif SelectValue is AreaID>selected</cfif>>#SelectText#</option>
					</cfloop>
				</select>
			</td>
		</tr>		
		<tr>
			<td class="rightAtd">
				*&nbsp;What is your Gender?
			</td>
			<td>
				<select name="GenderID" id="GenderID">
					<option value = "">-- Select your gender --</option>
					<cfloop query="Genders">
						<option value="#SelectValue#" <cfif SelectValue is GenderID>selected</cfif>>#SelectText#</option>
					</cfloop>
				</select>
			</td>
		</tr>		
		<tr>
			<td class="rightAtd">
				*&nbsp;When were you born?
			</td>
			<td>
				<select name="BirthMonthID" id="BirthMonthID">
					<option value = "">-- Select month --</option>
					<cfloop from="1" to="12" index="m">
						<option value="#m#" <cfif m is BirthMonthID>selected</cfif>>#MonthAsString(m)#</option>
					</cfloop>
				</select>
				<select name="BirthYearID" id="BirthYearID">
					<option value = "">-- Select year --</option>
					<cfloop from="2012" to="1950" step="-1" index="y">
						<option value="#y#" <cfif y is BirthYearID>selected</cfif>>#y#</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td class="rightAtd">
				*&nbsp;How would you best describe yourself?
			</td>
			<td>
				<select name="SelfIdentifiedTypeID" id="SelfIdentifiedTypeID">
					<option value = ''>-- Select One --</option>
					<cfloop query="SelfIdentifiedTypes">
						<option value="#SelectValue#" <cfif SelectValue is SelfIdentifiedTypeID>selected</cfif>>#SelectText#</option>
					</cfloop>
				</select>
			</td>
		</tr>		
		<tr>
			<td class="rightAtd">
				*&nbsp;What is the hightest level of education you have achieved?
			</td>
			<td>
				<select name="EducationLevelID" id="EducationLevelID">
					<option value = ''>-- Select One --</option>
					<cfloop query="EducationLevels">
						<option value="#SelectValue#" <cfif SelectValue is EducationLevelID>selected</cfif>>#SelectText#</option>
					</cfloop>
				</select>
			</td>
		</tr>		
		<tr>
				<td>&nbsp;</td>
				<td>
					&nbsp;<br>
					<input type="submit" name="Next" value="Next >>" class="btn">
				</td>
		</tr>
	</table>
</form>

</cfoutput>
