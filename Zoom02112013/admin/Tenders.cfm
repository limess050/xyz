<!---
This page is used for testing Lighthouse functionality and providing a sample
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Tenders">
<cfinclude template="../Lighthouse/Admin/Header.cfm">

<cfparam name="action" default="View">
<cfif ListFindNoCase("View",action)>
	<cfinclude template="Tenders_SendThenDeleteReviewed.cfm">
</cfif>
<cfparam name="PK" default="0">

<cfset ReviewEditable = "Yes">
<cfif action is "edit">
	<script language="Javascript">
		function checkPrimaryEmail() {
			if (!checkEmail(document.f1.Email,"Email")) {			
				return false
			}
			return true;
		}
	</script>
	<cfquery name="getTenderReview" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select Reviewed
		From Tenders
		Where TenderID = <cfqueryparam value="#PK#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif getTenderReview.Reviewed>
		<cfset ReviewEditable = "No">
	</cfif>
</cfif>

<lh:MS_Table table="Tenders" title="#pg_title#">
	<lh:MS_TableColumn
		ColName="TenderID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true" />
				
	<lh:MS_TableColumn
		ColName="Email"
		DispName="Email"
		type="text"
		required="Yes"
		MaxLength="200"
		Validate="checkPrimaryEmail()" />

	<lh:MS_TableColumn
		ColName="SubjectLine"
		DispName="Subject Line"
		type="text"
		required="Yes"
		MaxLength="150"
		DescriptionColumn="Yes" />

	<lh:MS_TableColumn
		ColName="EmailBody"
		DispName="Message"
		type="textarea"
		View="No"
		Required="Yes" />
	
	<lh:MS_TableColumn
		ColName="ListingID"
		type="select-multiple-popup"
		popupurl="ListingsPicker.cfm?select=yes"
		viewurl="Listings.cfm?select=yes&action=edit&pk=##pk##"
		FKTable="ListingsView"
		FKDescr="Title"
		FKJoinTable="TenderListings"
		View="No"
		Required="Yes" />
	
	<lh:MS_TableChild 
		name="TenderDocs" 
		Dispname="Attached Files" 
		View="No" 
		Search="Yes">
		<lh:MS_TableColumn
			ColName="FileName"
			DispName="File Upload"
			type="File"
			Directory="#Request.MCFTenderDocsDir#" />
	</lh:MS_TableChild>
		
	<lh:MS_TableColumn
		ColName="DateCreated"
		DispName="Date Submitted"
		ShowDate="Yes" 
		type="Date"
		Required="Yes"
		Format="DD/MM/YYYY"
		View="No"
		Editable="no" />
	
	<lh:MS_TableColumn
		ColName="Reviewed"
		type="Checkbox"
		View="No"
		OnValue="1"
		OffValue="0"
		AllowColumnEdit="true" />
	
	<!--- <lh:MS_TableColumn
		ColName="ReviewedByID"
		DispName="Reviewed By"
		type="select"
		Editable="No"
		FKTable="LH_Users"
		FKColName="UserID"
		FKDescr="FirstName + ' ' + LastName"
		View="No" />
		
	<lh:MS_TableColumn
		ColName="DateReviewed"
		DispName="Date Reviewed"
		ShowDate="Yes" 
		type="Date"
		Format="DD/MM/YYYY"
		View="No"
		Editable="no" /> --->
	
	<lh:MS_TableEvent
		EventName="OnAfterUpdate"
		Include="../../admin/Tenders_onAfterUpdate.cfm" />
</lh:MS_Table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">