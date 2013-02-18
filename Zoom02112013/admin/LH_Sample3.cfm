<!---
File Name: 	/leads/leads.cfm
Author: 	David Hammond
Description:
	Screen to view prospects
Inputs:
	startRow (opt)
	orderBy (opt)
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Lighthouse Sample Table">
<cfinclude template="../Lighthouse/Admin/Header.cfm">

<lh:MS_Table
	table="LH_SampleLookup2"
	title="The Topics">

	<lh:MS_TableColumn
		ColName="SampleLookup2ID"
		type="integer"
		PrimaryKey="true" />
	<lh:MS_TableColumn
		ColName="Fname"
		type="text"
		required="Yes" />
	<lh:MS_TableColumn
		ColName="Lname"
		type="text"
		required="Yes" />

	<lh:MS_TableRowAction
		ActionName="Select"
		ColName="SampleLookup2ID"
		Descr="fname + ' ' + lname" />

</lh:MS_Table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">