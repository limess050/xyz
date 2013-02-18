<cfimport prefix="lh" taglib="../Tags">
<cfinclude template="checkPermission.cfm">
<cfinclude template="header.cfm">

<cfif Not StructKeyExists(Application.Tables,"Section")>
	<lh:MS_Table
		table="#Request.dbprefix#_Sections"
		title="Sections"
		persistentparams="adminFunction=sections"
		VariableName="Application.Tables.Section">
		<lh:MS_TableColumn 
			ColName="SectionID"
			type="integer"
			PrimaryKey="true"
			relatedtables="#Request.dbprefix#_Pages.SectionID" />
		<lh:MS_TableColumn
			ColName="Descr"
			Type="text"
			Unicode="Yes"
			Unique="Yes"
			Maxlength="50" />
		<lh:MS_TableAction
			ActionName="ListOrder"
			Type="ListOrder"
			DescriptionColumn="Descr"
			Label="Put Sections in Order" />
	</lh:MS_Table>
</cfif>

<cfset Application.Tables.Section.Render(Variables)>

<cfinclude template="footer.cfm">