NO LONGER IN USE<cfabort>
<cfparam name="ConfirmationID" default="">

<cfquery name="Genders" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select GenderID as SelectValue, Descr as SelectText
	From Genders
	Order by OrderNum
</cfquery>
<cfquery name="AgeGroups" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select AgeGroupID as SelectValue, Descr as SelectText
	From AgeGroups
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

<script>
	function validateForm(formObj) {		
		if (!checkText(formObj.elements["FirstName"],"First Name")) return false;	
		if (!checkText(formObj.elements["Email"],"Email")) return false;	
		if (!checkEmail(formObj.elements["Email"],"Email")) return false;	
		if ($("#Email").val()!=$("#ConfirmEmail").val()) {
			alert("Email and Confirm Email values must be the same.");
			$("#Email").focus();
			return false;		
		}
		<cfif not Len(ConfirmationID)>
		if (!checkSelected(formObj.elements["AlertSectionIDs"],"Kinds of Alerts")) return false;	
		</cfif>
		if (!checkSelected(formObj.elements["GenderID"],"Gender")) return false;	
		if (!checkSelected(formObj.elements["AgeGroupID"],"Age Group")) return false;	
		if (!checkSelected(formObj.elements["SelfIdentifiedTypeID"],"Best Describe Yourself")) return false;	
		if (!checkSelected(formObj.elements["EducationLevelID"],"Highest Level of Education")) return false;	
		return true;
	}
</script>

<cfoutput>
<form name="f1" action="page.cfm?PageID=<cfif Len(ConfirmationID)>#Request.ManageAlertPageID#<cfelse>#Request.AddAlertPageID#</cfif>" method="post" ONSUBMIT="return validateForm(this)">
	
	<cfif Len(ConfirmationID)>
		<input type="hidden" name="ConfirmationID" value="#ConfirmationID#">
		<input type="hidden" name="Step" value="9">
	<cfelse>
		<input type="hidden" name="Step" value="2">
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
				<input type = "text" name = "ConfirmEmail" id = "ConfirmEmail" value = "<cfif Len(Email)>#Email#<cfelse>Confirm Email</cfif>" />
			</td>
		</tr>
		<cfif not Len(ConfirmationID)>
			<tr>
				<td class="rightAtd">
					*&nbsp;What kind of alert(s) do you want to receive?<br><strong>(Choose all that apply)</strong>
						<span class="instructions"><br />To multi-select, hold the "Ctrl" key and click each option desired.</span>
				</td>
				<td>
					<select name="AlertSectionIDs" id="AlertSectionIDs" multiple size=8>
						<!--- <option value = "">-- Select an Alert Type --</option> --->
						<cfloop query="AlertSections">
							<option value="#SelectValue#" <cfif ListFind(AlertSectionIDs,SelectValue)>selected</cfif>>#SelectText#</option>
						</cfloop>
						<!--- <option value = "55">Automotive Classifieds</option>
						<option value = "4">For Sale By Owner Classifieds</option>
						<option value = "8">Job Vacancies</option>
						<option value = "5">Real Estate Listings</option>
						<option value = "59">Special Events</option>
						<option value = "37">Travel Specials</option> --->
					</select>
				</td>
			</tr>
		</cfif>	
		<tr>
			<td valign="top" colspan=2>
				<lh:MS_SitePagePart id="bodyDemog" class="body">
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
				*&nbsp;What is your Age Group?
			</td>
			<td>
				<select name="AgeGroupID" id="AgeGroupID">
					<option value = "">-- Select your age group --</option>
					<cfloop query="AgeGroups">
						<option value="#SelectValue#" <cfif SelectValue is AgeGroupID>selected</cfif>>#SelectText#</option>
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
					<!--- <option  value = '1'>Black Tanzanian Citizen</option>
					<option  value = '2'>Indian Tanzanian Citizen</option>
					<option  value = '3'>Other Tanzanian Citizen</option>
					<option  value = '4'>Expatriate Residing in Tanzania</option>
					<option  value = '5'>Other</option> --->
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
					<!--- <option  value  = '1'>Primary School</option>
					<option  value = '2'>Secondary School</option>
					<option  value = '3'>Some College / University</option>
					<option  value = '4'>Completeted College / University</option>
					<option  value = '5'>Masters Degree or Higher</option> --->
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
