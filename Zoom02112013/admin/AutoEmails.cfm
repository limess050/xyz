<!---
This page is used for testing Lighthouse functionality and providing a sample
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Automatic Emails">
<cfinclude template="../Lighthouse/Admin/Header.cfm">


<lh:MS_Table table="AutoEmails" title="#pg_title#">
	<lh:MS_TableColumn
		ColName="AutoEmailID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true" />
		
	<lh:MS_TableColumn
		ColName="AutoEmailTypeID"
		DispName="Type"
		type="select"
		FKTable="AutoEmailTypes"
		FKColName="AutoEmailTypeID"
		FKDescr="Title"
		FKOrderBy="Title"
		Required="yes" />
	
	<lh:MS_TableColumn
		ColName="Title"
		DispName="Name"
		type="text"
		Unique="Yes"
		required="Yes"
		MaxLength="200"
		DescriptionColumn="Yes"
		FormFieldParameters="size='100'" />
	
	<lh:MS_TableColumn
		ColName="SubjectLine"
		DispName="Subject Line"
		type="text"
		required="Yes"
		MaxLength="200"
		FormFieldParameters="size='100'" />
							
	<lh:MS_TableColumn
		ColName="Body"
		Type="textarea"
		AllowHTML="yes"
		View="No"
		Search="yes"
		SearchType="contains"
		Required="yes"
		SpellCheck="Yes" />	
	
	<lh:MS_TableColumn
		ColName="InsertionVariables"
		DispName="Insertion Variables"
		type="text"
		required="Yes"
		MaxLength="200"
		FormFieldParameters="size='100'"
		Editable="No"
		View="No"
		HelpText="These are the variables available for use in the Body, which will be automatically replaced with the appropriate values when the email is sent." />
		
	<lh:MS_TableEvent
		EventName="OnAfterUpdate"
		Include="../../admin/AutoEmails_onAfterUpdate.cfm" />
		
</lh:MS_Table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">