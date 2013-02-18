
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Sections">
<cfinclude template="../Lighthouse/Admin/Header.cfm">
<cfoutput><script language="JavaScript" src="#Request.HTTPSURL#/scripts/jquery-1.3.2.min.js" type="text/javascript"></script></cfoutput>


<cfquery name="ParentSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select ParentSectionID as SelectValue
	From ParentSectionsView
</cfquery>

<lh:MS_Table table="Sections" title="#pg_title#"
	OrderBy="CASE WHEN Sections.ParentSectionID is not null then (Select OrderNum from Sections S2 Where S2.SectionID=Sections.ParentSectionID) ELSE Sections.OrderNum END, Sections.ParentSectionID, Sections.OrderNum">
	<lh:MS_TableColumn
		ColName="SectionID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true"
		RelatedTables="SectionsView.ParentSectionID,Categories.SectionID,Categories.ParentSectionID" />
	
	<lh:MS_TableColumn
		ColName="ParentSectionID"
		DispName="Parent Section"
		type="select"
		FKTable="ParentSectionsView"
		FKDescr="Title"
		FKOrderBy="OrderNum" />
		
	<lh:MS_TableColumn
		ColName="Title"
		DispName="Section Name"
		type="text"
		required="Yes"
		MaxLength="200"
		DescriptionColumn="Yes" />
			
	<lh:MS_TableColumn
		ColName="Descr"
		DispName="Homepage Text"
		type="textarea"
		allowHTML="Yes"
		SpellCheck="Yes"
		imageDir="/uploads"
		View="No"
		MaxLength="2000" />		
		
	<lh:MS_TableColumn
		ColName="BrowserTitle"
		DispName="Browser Title"
		type="text"
		MaxLength="200"
		allowView="No" />
		
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
		MaxLength="500"
		allowView="No" />
		
	<lh:MS_TableColumn
		ColName="MetaKeywords"
		DispName="Meta Keywords"
		type="text"
		MaxLength="500"
		allowView="No" />

	<lh:MS_TableColumn
			ColName="ImageFile"
			DispName="Image File"
			type="File"
			Directory="#Request.MCFUploadsDir#/Sections"
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
		ColName="PlacementID1"
		DispName="Postion 1 PlacementID"
		type="integer"
		MaxLength="20" />
		
	<lh:MS_TableColumn
		ColName="PlacementID2"
		DispName="Postion 2 PlacementID"
		type="integer"
		MaxLength="20" />
		
	<lh:MS_TableColumn
		ColName="KeywordID"
		DispName="Section Keywords"
		type="select-multiple"
		FKTable="Keywords"
		FKColName="KeywordID"		
		FKDescr="Title"
		FKJoinTable="SectionKeywords"
		SelectQuery="Select KeywordID as SelectValue, Title as SelectText From Keywords Order By Title"
		Required="No" />
		
	<lh:MS_TableColumn
		ColName="Impressions"
		DispName="Number of Viewings"
		type="Pseudo"
		Expression="(Select Sum(Impressions) From Categories Where  SectionID=Sections.SectionID or ParentSectionID=Sections.SectionID)"
		ShowOnEdit="true" />

	<lh:MS_TableAction
		ActionName="Custom"
		Label="Order Parent Sections"
		HREF="ParentSections.cfm?Action=ListOrder"
		View="No"/>

	<lh:MS_TableRowAction
		ActionName="Custom"
		Label="Order Sub-Sections"
		HREF="SubSections.cfm?Action=ListOrder&PSID=##pk##"
		View="No"
		Condition="ListFind('#ValueList(ParentSections.SelectValue)#',pk)" />	

	<lh:MS_TableEvent
		EventName="OnBeforeInsert"
		Include="../../admin/Sections_onBeforeInsert.cfm" />

	<lh:MS_TableEvent
		EventName="OnBeforeUpdate"
		Include="../../admin/Sections_onBeforeInsert.cfm" />

	<lh:MS_TableEvent
		EventName="OnAfterUpdate"
		Include="../../admin/Sections_onAfterUpdate.cfm" />
		
</lh:MS_Table>



<script language="javascript" type="text/javascript">
	$(document).ready(function()
	{		    
		showHideMeta();
		
		$("#ParentSectionID").change(function(e)
		    {	
				showHideMeta();
		    });
	});	
	
	function showHideMeta() {
		if ($("#ParentSectionID").val()!='') {
			$("#BrowserTitle_TR").hide();
			$("#MetaDescr_TR").hide();
		}
		else {
			$("#BrowserTitle_TR").show();
			$("#MetaDescr_TR").show();
		}
	}
</script> 

<cfinclude template="../Lighthouse/Admin/Footer.cfm">