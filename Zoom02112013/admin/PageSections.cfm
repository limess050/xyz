<!---
This manages the Section Impressions value for CMS pages. It is NOT touching the SectionID that is part of the LightHouse CMS
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Page Sections">
<cfinclude template="../Lighthouse/Admin/Header.cfm">
<cfoutput><script language="JavaScript" src="#Request.HTTPSURL#/scripts/jquery-1.3.2.min.js" type="text/javascript"></script></cfoutput>


<lh:MS_Table 
	table="LH_Pages" 
	title="#pg_title#"
	OrderBy="Name"
	disallowedactions="Add,Delete"
	WhereClause="TemplateID not in (9,10,14,21,23,24,26,27,28,30)">	
	
	<lh:MS_TableColumn
		ColName="PageID"
		DispName="Page ID"
		type="integer"
		PrimaryKey="true"
		Identity="true" />
	
	<lh:MS_TableColumn
		ColName="Title"
		DispName="Page Title"
		type="text"
		DescriptionColumn="Yes" />
		
	<lh:MS_TableColumn
		ColName="SectionID"
		DispName="Section"
		type="select-multiple"
		FKTable="PageSectionsView"
		FKColName="SectionID"		
		FKDescr="Title"
		FKJoinTable="PageSections"
		SelectQuery="Select SectionID as SelectValue, Title as SelectText From PageSectionsView Order By OrderNum"
		Required="Yes" />
	
	<lh:MS_TableEvent
		EventName="OnBeforeUpdate"
		Include="../../admin/PageSections_onBeforeUpdate.cfm" />
	
	<lh:MS_TableEvent
		EventName="OnAfterUpdate"
		Include="../../admin/PageSections_onAfterUpdate.cfm" />
			
</lh:MS_Table>

<!--- By removing the multile and size attributes on the SectionID, we effectively use the select-multiple tag as a single select. This allows us to store the SectionID in a linking table, and so not touch LightHouse's LH_Page table; no new columns are added. Lighthouse expects to update at least one column in the table, so the Title is made readonly. This makes the update work without letting the user change the Title outside the CMS, where Lighthouse will properly managge the both the LH_Pages and LH_Pages_Live table records. The OnAfterUpdate ensures that only one record exists for each PageID in the PageSections linking table, should a JavaScript error prevent the SectionID attributes from being managed. The OnBeforeUpdate ensures that the Title not be edited even if the JS fails. --->
<script language="javascript" type="text/javascript">
	$(document).ready(function()
	{   
		$('#Title').attr("readonly", true);
		$('#SectionID').removeAttr('multiple');
		$('#SectionID').removeAttr('size');
	});
</script>


<cfinclude template="../Lighthouse/Admin/Footer.cfm">