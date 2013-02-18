<!---
This page is used for testing Lighthouse functionality and providing a sample
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Accounts">
<cfinclude template="../Lighthouse/Admin/Header.cfm">
<cfoutput><script language="JavaScript" src="#Request.HTTPSURL#/scripts/jquery-1.3.2.min.js" type="text/javascript"></script></cfoutput>

<cfparam name="UseCustom" default="0">
<cfparam name="Action" default="View">

<script language="Javascript">
	function checkPrimaryEmail() {
		if (!checkEmail(document.f1.ContactEmail,"Secondary Contact Email")) {			
			return false
		}
		return true;
	}
	function checkAltEmail() {
		if (!checkEmail(document.f1.AltContactEmail,"Secondary Contact Email")) {			
			return false
		}
		return true;
	}

</script>

<cfset UseCustom="1">
<cfif ListFind("Add,Edit",Action) and UseCustom>
	<cfinclude template="includes/AccountsCustomForm.cfm">
<cfelse>
<!--- Need to validate phone numbers and emails. --->
	<lh:MS_Table table="LH_Users" title="#pg_title#"
		WhereClause="adminUser=0">
		<lh:MS_TableColumn
			ColName="UserID"
			DispName="ID"
			type="integer"
			PrimaryKey="true"
			Identity="true"
			RelatedTables="Orders.UserID" />
			
		<lh:MS_TableColumn
			ColName="Company"
			DispName="Account Name"
			type="text"
			Unique="Yes"
			required="Yes"
			DescriptionColumn="Yes"
			MaxLength="200" />
	
		<lh:MS_TableColumnGroup groupname="Contact" label="Primary Contact">
				
			<lh:MS_TableColumn
				ColName="ContactFirstName"
				DispName="First Name"
				type="text"
				required="Yes"
				MaxLength="200" />
				
			<lh:MS_TableColumn
				ColName="ContactLastName"
				DispName="Last Name"
				type="text"
				required="Yes"
				MaxLength="200" />
				
			<lh:MS_TableColumn
				ColName="ContactPhoneLand"
				DispName="Phone (landline)"
				type="text"
				MaxLength="20" />
				
			<lh:MS_TableColumn
				ColName="ContactPhoneMobile"
				DispName="Phone (mobile)"
				type="text"
				MaxLength="20" />
				
			<lh:MS_TableColumn
				ColName="ContactOutsidePhoneCountryCode"
				DispName="Phone (outside TZ) Country Code"
				type="text"
				MaxLength="20"
				FormFieldParameters="Size='4'" />
				
			<lh:MS_TableColumn
				ColName="ContactOutsidePhone"
				DispName="Phone (outside TZ)"
				type="text"
				MaxLength="20" />
				
			<lh:MS_TableColumn
				ColName="ContactEmail"
				DispName="Email"
				type="text"
				required="Yes"
				MaxLength="200"
				Validate="checkPrimaryEmail()" />
				
		</lh:MS_TableColumnGroup>
		
		<lh:MS_TableColumnGroup groupname="AltContact" label="Secondary Contact">
				
			<lh:MS_TableColumn
				ColName="AltContactFirstName"
				DispName="First Name"
				type="text"
				MaxLength="200" />
				
			<lh:MS_TableColumn
				ColName="AltContactLastName"
				DispName="Last Name"
				type="text"
				MaxLength="200" />
				
			<lh:MS_TableColumn
				ColName="AltContactPhoneLand"
				DispName="Phone (landline)"
				type="text"
				MaxLength="20" />
				
			<lh:MS_TableColumn
				ColName="AltContactPhoneMobile"
				DispName="Phone (mobile)"
				type="text"
				MaxLength="20" />
				
			<lh:MS_TableColumn
				ColName="AltContactOutsidePhoneCountryCode"
				DispName="Phone (outside TZ) Country Code"
				type="text"
				MaxLength="20"
				FormFieldParameters="Size='4'" />
				
			<lh:MS_TableColumn
				ColName="AltContactOutsidePhone"
				DispName="Phone (outside TZ)"
				type="text"
				MaxLength="20" />
				
			<lh:MS_TableColumn
				ColName="AltContactEmail"
				DispName="Email"
				type="text"
				MaxLength="200"
				Validate="checkAltEmail()" />
				
		</lh:MS_TableColumnGroup>
	
	<lh:MS_TableColumn
		ColName="CategoryID"
		DispName="Tender Notification Categories"
		type="checkboxgroup"
		required="No"
		FKTable="Categories"
		FKDescr="Title"
		FKJoinTable="UserCategories"
		View="Yes"
		checkboxcols="2"
		SelectQuery="Select C.CategoryID as SelectValue, C.Title as SelectText From Sections S Left Outer Join Categories C on S.SectionID=C.SectionID or (C.ParentSectionID=S.SectionID and C.SectionID is null) Where S.Active=1 and C.Active=1 and C.ParentSectionID=8 and S.SectionID = 29 Order By C.OrderNum" />
			
		<lh:MS_TableColumn
			ColName="Password"
			type="text"
			required="Yes"
			MaxLength="20" />
	
		<lh:MS_TableColumn
			ColName="Active"
			type="Checkbox"
			View="No"
			OnValue="1"
			OffValue="0" />
	
	
		<lh:MS_TableColumn
			ColName="Blacklist_Fl"
			DispName="Blacklisted"
			type="Checkbox"
			View="No"
			OnValue="1"
			OffValue="0"
			DefaultValue="0" />
	
		<lh:MS_TableColumn
			ColName="ConfirmedDate"
			DispName="Date Confirmed"
			ShowDate="Yes" 
			type="Date"
			Editable="No"
			Search="No"
			Format="DD/MM/YYYY" />
		
		<lh:MS_TableColumn
			ColName="NumAlerts"
			DispName="Number of Alerts"
			type="Pseudo"
			Expression="(Select Count(A.AlertID) from Alerts A inner join AlertSections ASe on A.AlertID=ASe.AlertID Where A.UserID=LH_Users.UserID)"
			ShowOnEdit="true" />
			
		<cfif Request.environment is "Live" or Request.environment is "Devel" or Request.environment is "DB">
			<lh:MS_TableRowAction
				ActionName="CustomThree"
				Label="Resend Welcome Email"
				HREF="javascript:void(0);"
				onClick="sendAccountEmail(##PK##);"
				View="No"/>
				
			<lh:MS_TableRowAction
				ActionName="CustomTwo"
				Type="Custom"
				Label="Mark Account Confirmed"
				HREF="AccountMarkConfirmed.cfm?PK=##PK##"
				View="No"
				Condition="isDefined('ConfirmedDate') and not Len(ConfirmedDate)"/>
		</cfif>
		<lh:MS_TableRowAction
			ActionName="Custom"
			Label="Blacklist Account"
			HREF="javascript:void(0);"
			onClick="blacklistAccount(this,##PK##);"
			Condition="Blacklist_Fl is 0"/>
	
		<lh:MS_TableEvent
			EventName="OnAfterInsert"
			Include="../../admin/Accounts_onAfterInsert.cfm" />
	
		<lh:MS_TableEvent
			EventName="OnAfterUpdate"
			Include="../../admin/Accounts_onAfterUpdate.cfm" />
	
		<lh:MS_TableEvent
			EventName="OnBeforeUpdate"
			Include="../../admin/Accounts_onBeforeUpdate.cfm" />
		
		
	</lh:MS_Table>

</cfif>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">

<cfoutput>
<script language="javascript" type="text/javascript">
	
	function sendAccountEmail(x){
		var datastring = "PK=" + x;
		$.ajax(
           {
			type:"POST",
               url:"#Request.HTTPSURL#/Admin/AccountWelcomeEmail.cfc?method=SendEmail&returnformat=plain",
               data:datastring,
               success: function(response)
               {
				alert('Account Email Sent');
               }
           });
	}
	
	function blacklistAccount(t,x){
		if (confirm('Are you sure you want to Blacklist this Account?')) {
			var datastring = "PK=" + x;
			$.ajax(
	           {
				type:"POST",
	               url:"#Request.HTTPSURL#/Admin/BlacklistAccount.cfc?method=Add&returnformat=plain",
	               data:datastring,
	               success: function(response)
	               {
					$(t).parent().hide();
					$(".UBLBut").show();
					//alert('Account Blacklisted');
	               }
	           });	
		}		
	}
	
	function unblacklistAccount(t,x){
		if (confirm('Are you sure you want to Un-Blacklist this Account?')) {
			var datastring = "PK=" + x;
			$.ajax(
	           {
				type:"POST",
	               url:"#Request.HTTPSURL#/Admin/BlacklistAccount.cfc?method=Remove&returnformat=plain",
	               data:datastring,
	               success: function(response)
	               {
					$(t).parent().hide();
					$(".BLBut").show();
					//alert('Account Blacklisted');
	               }
	           });	
		}		
	}
	
</script>
</cfoutput>
