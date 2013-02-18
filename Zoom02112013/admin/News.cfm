<!---
This page is used for testing Lighthouse functionality and providing a sample
--->


<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "News">
<cfinclude template="../Lighthouse/Admin/Header.cfm">

<lh:MS_Table 
	table="News" 
	title="#pg_title#"
	OrderBy="News.DatePosted desc"
	AllowColumnEdit="true">
		
	<lh:MS_TableColumn
		ColName="NewsID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true" />
	
	<lh:MS_TableColumn
		ColName="Headline"
		type="text"
		required="Yes"
		MaxLength="2000"
		DescriptionColumn="Yes" />
	
	<lh:MS_TableColumn
		ColName="WebsiteURL"
		DispName="URL"
		type="text"
		required="Yes"
		MaxLength="2000" />
	
	<lh:MS_TableColumn
		ColName="Source"
		type="text"
		required="Yes"
		MaxLength="2000" />
		
	<lh:MS_TableColumn
		ColName="DatePosted"
		DispName="Date Posted"
		ShowDate="Yes" 
		type="Date"
		Required="Yes"
		Format="DD/MM/YYYY" />
	
	<lh:MS_TableColumn
		ColName="NewsCategoryID"
		DispName="Categories"
		type="select-multiple"
		FKTable="NewsCategories"
		FKColName="NewsCategoryID"
		FKDescr="Title"
		FKJoinTable="NewsNewsCategories"
		View="No" />
	
	<lh:MS_TableColumn 
		colname="Homepage_fl" 
		DispName="Feature On Homepage"
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="0" />
	
	<lh:MS_TableColumn 
		colname="Active" 
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="1" />
	
	<lh:MS_TableEvent
		EventName="OnAfterInsert"
		Include="../../admin/News_onAfterInsert.cfm" />

	<lh:MS_TableEvent
		EventName="OnAfterUpdate"
		Include="../../admin/News_onAfterUpdate.cfm" />
		
</lh:MS_Table>
<cfif IsDefined('Action') and Action is "Edit">
	<cfquery name="q2" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select N.DateAdded, N.DateUpdated, N.DateUpdated,
		IsNull(U.FirstName,'') + ' ' + IsNull(U.LastName,'') as AddedByName,
		IsNull(U2.FirstName,'') + ' ' + IsNull(U2.LastName,'') as UpdatedByName
		From News N 
		Left Outer Join LH_Users U on N.AddedByID=U.UserID
		Left Outer Join LH_Users U2 on N.UpdatedByID=U2.UserID
		Where N.NewsID=<cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<p>
	<cfoutput>Date Added: #DateFormat(q2.DateAdded,'dd/mm/yyyy')# | Added By: #q2.AddedByName# <cfif Len(q2.DateUpdated)>| Last Updated: #DateFormat(q2.DateUpdated,'dd/mm/yyyy')# | Updated By: #q2.UpdatedByName#</cfif></cfoutput>
</cfif>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">