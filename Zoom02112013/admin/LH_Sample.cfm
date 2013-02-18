<!---
This page is used for testing Lighthouse functionality and providing a sample
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Lighthouse Sample Table">
<cfinclude template="../Lighthouse/Admin/Header.cfm">

<cfparam name="url.state" default="">

<lh:MS_Table table="LH_Sample" title="#pg_title#">
	<lh:MS_TableColumn
		ColName="SampleID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true" />

	<lh:MS_TableColumnGroup groupname="Text" label="Text Columns">
		<lh:MS_TableColumn
			ColName="Name"
			DispName="Text"
			type="text"
			Unique="Yes"
			required="Yes"
			DescriptionColumn="Yes"
			HelpText="This is a required text field, and it must be unique." />
	
		<lh:MS_TableColumn
			ColName="Notes"
			DispName="Textarea"
			type="textarea"
			allowHTML="Yes"
			SpellCheck="Yes"
			imageDir="/images"
			helptext="You can put any relevant notes in here at all.  It doesn't matter.  Go ahead and have fun with it. You can put any relevant notes in here at all.  It doesn't matter.  Go ahead and have fun with it.You can put any relevant notes in here at all.  It doesn't matter.  Go ahead and have fun with it.You can put any relevant notes in here at all.  It doesn't matter.  Go ahead and have fun with it."
			View="No" />
	</lh:MS_TableColumnGroup>

	<lh:MS_TableColumnGroup groupname="File" label="File Column">
		<lh:MS_TableColumn
			ColName="FilePath"
			DispName="File Upload"
			type="File"
			Directory="#Request.MCFUploadsDir#"
			NameConflict="makeunique"
			DeleteWithRecord="Yes"
			ShowFileBrowser="Yes"
			Search="false" />

		<lh:MS_TableColumn
			ColName="FilePathLink"
			DispName="Pseudo column"
			type="pseudo"
			Expression="'<a href=""test.cfm"">' + FilePath + '</a>'"
			View="false"
			Search="false"
			ShowOnEdit="Yes"
			HelpText="This is not a real column in the database but displays a link to the file uploaded by the File Upload column. It is an example of how the data from one or more columns can be transformed and displayed as a pseudo-column" />
	</lh:MS_TableColumnGroup>

	<lh:MS_TableColumnGroup groupname="Numeric" label="Number and Date Columns">
		<lh:MS_TableColumn
			ColName="MoneyValue"
			DispName="Money"
			type="Integer"
			Format="_$_,___.__"
			showtotal="Yes"
			View="false"
			HelpText="This is a numeric field that is formatted as money." />

		<lh:MS_TableColumn
			ColName="DoubleMoney"
			DispName="Double Money"
			type="Pseudo"
			Format="_$_,___.__"
			expression="MoneyValue * 2"
			showtotal="Yes"
			View="false"
			HelpText="This is another pseudo column that doubles the value of the Money column." />

		<lh:MS_TableColumn
			ColName="DateValue"
			DispName="Date and Time"
			ShowDate="Yes"
			ShowTime="Yes"
			type="Date"
			HelpText="A date and time column.  Can optionally show just the date or just the time." />
	</lh:MS_TableColumnGroup>
	
	<lh:MS_TableColumnGroup groupname="Single" label="Single Select Columns">
		<lh:MS_TableColumn
			ColName="StateID"
			DispName="Select"
			type="select"
			group="left(descr,1)"
			Required="Yes"
			FKTable="LH_SampleStates"
			FKType="text"
			FKDescr="Descr"
			DefaultValue="#url.state#"
			HelpText="A drop-down select column." />
	
		<lh:MS_TableColumn
			ColName="SampleLookup5ID"
			DispName="Radio Buttons"
			type="radio"
			FKTable="LH_SampleLookup5"
			FKColName="SampleLookup5ID"
			FKDescr="descr"
			RadioCols="4"
			HelpText="A radio button column." />
	
		<lh:MS_TableColumn
			ColName="Checkbox"
			type="Checkbox"
			View="No"
			HelpText="A checkbox column, used for binary (Yes/No) data." />

		<lh:MS_TableColumn
			ColName="LookupID"
			DispName="Select-Popup Column"
			type="select-popup"
			popupurl="LH_Sample2.cfm?select=yes"
			viewurl="LH_Sample2.cfm?select=yes&action=edit&pk=##pk##"
			FKTable="LH_SampleLookup"
			FKColName="SampleLookupID"
			FKDescr="descr"
			required="yes"
			editable="yes" />
	</lh:MS_TableColumnGroup>

	<lh:MS_TableColumnGroup groupname="Multiple" label="Multiple Select Columns">
		<lh:MS_TableColumn
			ColName="StateID2"
			DispName="Select Multiple Values"
			type="select-multiple"
			FKTable="LH_SampleStates"
			FKColName="StateID"
			FKType="text"
			FKDescr="Descr"
			FKJoinTable="LH_SampleJoin4"
			View="No" />
	
		<lh:MS_TableColumn
			ColName="SampleLookup3ID"
			DispName="Checkbox Group"
			type="checkboxgroup"
			required="Yes"
			FKTable="LH_SampleLookup3"
			FKDescr="Descr"
			FKJoinTable="LH_SampleJoin3"
			View="No" />
	
		<lh:MS_TableColumn
			ColName="SampleLookup2ID"
			type="select-multiple-popup"
			popupurl="LH_Sample3.cfm?select=yes"
			viewurl="LH_Sample3.cfm?select=yes&action=edit&pk=##pk##"
			FKTable="LH_SampleLookup2"
			FKDescr="fname + ' ' + lname"
			FKJoinTable="LH_SampleJoin"
			View="No"/>
	</lh:MS_TableColumnGroup>
	
	<lh:MS_TableChild 
		name="LH_SampleChildTable" 
		Dispname="Child Table" 
		OrderColumn="OrderNum" 
		View="No" 
		Search="Yes"
		Required="Yes">
		<lh:MS_TableColumn 
			colname="Name" 
			type="text"
			maxlength="50" 
			formfieldparameters="size=15"
			required="true"/>
		<lh:MS_TableColumn
			ColName="FilePath"
			DispName="File Upload"
			type="File"
			Directory="#Request.MCFUploadsDir#" />
		<lh:MS_TableColumn 
			colname="Checkbox" 
			type="checkbox" 
			OnValue="1" 
			Offvalue="0"/>
	</lh:MS_TableChild>

	<!--- <lh:MS_TableColumn
		ColName="Notes2"
		type="textarea"
		spellcheck="yes"
		View="No"/> --->

	<!--- <lh:MS_TableAction
		ActionName="Add"
		Label="Add a New One"/> --->

	<!--- <lh:MS_TableRowAction
		ActionName="Edit"
		Type="Edit"
		Label="Change"
		View="No"/> --->

	<lh:MS_TableAction
		ActionName="ListOrder"
		Label="Order Table"
		DescriptionColumn="convert(varchar(32),SampleID) + ': ' + Name"
		OrderColumn="OrderNum"
		View="No"/>

	<!--- <lh:MS_TableAction
		ActionName="ListOrder2"
		Type="ListOrder"
		Label="Order Table 2"
		DescriptionColumn="Name"
		OrderColumn="OrderNum2"
		View="No"/> --->

	<!--- <lh:MS_TableRowAction
		ActionName="Select"
		Type="Custom"
		Href="javascript:alert('This is the custom action!\nID:##pk##\nText:##name##')"
		View="No" /> --->
</lh:MS_Table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">