<!---
This page is used for testing Lighthouse functionality and providing a sample
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Categories">
<cfinclude template="../Lighthouse/Admin/Header.cfm">
<cfoutput><script language="JavaScript" src="#Request.HTTPSURL#/scripts/jquery-1.3.2.min.js" type="text/javascript"></script></cfoutput>

<cfparam name="url.state" default="">

<lh:MS_Table table="Categories" title="#pg_title#">
	<lh:MS_TableColumn
		ColName="CategoryID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true"
		RelatedTables="ListingCategories.CategoryID" />
		
	<lh:MS_TableColumn
		ColName="Title"
		DispName="Category Name"
		type="text"
		required="Yes"
		MaxLength="200" />
	
	<lh:MS_TableColumn
		ColName="ParentSectionID"
		DispName="Parent Section"
		type="select"
		FKTable="Sections"
		FKDescr="Title"
		FKOrderBy="OrderNum"
		FKColName="SectionID"
		Required="Yes"
		SELECTQUERY="select SectionID as SelectValue, Title as SelectText from Sections Where ParentSectionID is null Order By OrderNum" />
	
	<lh:MS_TableColumn
		ColName="SectionID"
		DispName="Sub-Section"
		type="select"
		FKTable="Sections"
		FKDescr="Title"
		FKOrderBy="OrderNum"
		SELECTQUERY="select SectionID as SelectValue, Title as SelectText from SectionsView Order By OrderNum" />
		
	<lh:MS_TableColumn
		ColName="Descr"
		DispName="Post Ad Call-Out Text"
		type="text"
		Unique="Yes"
		MaxLength="2000"
		FormFieldParameters="size='100'" />
		
	<lh:MS_TableColumn
		ColName="BrowserTitle"
		DispName="Browser Title"
		type="text"
		MaxLength="200" />
		
	<lh:MS_TableColumn
		ColName="H1Text"
		DispName="H1 Text"
		type="text"
		required="Yes"
		MaxLength="200" />
		
	<lh:MS_TableColumn
		ColName="MetaDescr"
		DispName="Meta Description"
		type="text"
		MaxLength="500" />
		
	<lh:MS_TableColumn
		ColName="MetaKeywords"
		DispName="Meta Keywords"
		type="text"
		MaxLength="500" />

	<lh:MS_TableColumn
			ColName="ImageFile"
			DispName="Image File"
			type="File"
			Directory="#Request.MCFUploadsDir#/Categories"
			NameConflict="makeunique"
			DeleteWithRecord="Yes"
			Search="No"
		/>	
		
	<lh:MS_TableColumn 
		colname="Active" 
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="1" />
		
	<lh:MS_TableColumn
		ColName="KeywordID"
		DispName="Category Keywords"
		type="select-multiple"
		FKTable="Keywords"
		FKColName="KeywordID"		
		FKDescr="Title"
		FKJoinTable="CategoryKeywords"
		SelectQuery="Select KeywordID as SelectValue, Title as SelectText From Keywords Order By Title"
		Required="No" />
	
	<lh:MS_TableColumn
		ColName="ListingTypeID"
		DispName="Listing Types"
		type="checkboxgroup"
		required="Yes"
		FKTable="ListingTypes"
		FKDescr="Title + ' - ' + Descr"
		FKJoinTable="CategoryListingTypes"
		View="No"
		checkboxcols="1"
		SelectQuery="Select ListingTypeID as SelectValue, Title + ' - ' + Descr as SelectText from ListingTypes where ListingTypeID not in (16,17)" />

	<lh:MS_TableAction
		ActionName="ListOrder"
		Label="Order Table"
		DescriptionColumn="Title"
		OrderColumn="OrderNum"
		View="No"
		SelectQuery="SELECT C.CategoryID as selectValue, PS.Title + ' - ' + CASE WHEN S.Title is null THEN '' Else S.Title + ' - ' END + C.Title as selectText FROM Categories C Inner Join Sections PS on C.ParentSectionID=PS.SectionID Left Outer Join Sections S on C.SectionID=S.SectionID ORDER BY PS.OrderNum, S.OrderNum, C.OrderNum" />
		
	<lh:MS_TableColumn
		ColName="Impressions"
		DispName="Number of Viewings"
		type="integer"
		Editable="No" />

	<lh:MS_TableEvent
		EventName="OnBeforeInsert"
		Include="../../admin/Categories_onBeforeInsert.cfm" />

	<lh:MS_TableEvent
		EventName="OnBeforeUpdate"
		Include="../../admin/Categories_onBeforeInsert.cfm" />

	<lh:MS_TableEvent
		EventName="OnAfterUpdate"
		Include="../../admin/Categories_onAfterUpdate.cfm" />

</lh:MS_Table>

<cfif IsDefined('Action') and ListFind("Add,Edit,Search",Action)>
	<cfinclude template="includes/GetSubSectionsScript.cfm">	
</cfif>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">