
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Relevant Links">
<cfinclude template="../Lighthouse/Admin/Header.cfm">
<cfoutput><script language="JavaScript" src="#Request.HTTPSURL#/scripts/jquery-1.3.2.min.js" type="text/javascript"></script></cfoutput>

<cfif IsDefined('Action') and ListFind("Add,Edit",Action)>
	<style>
		#ParentSectionID_TR { display: none;}
		#SectionID_TR { display: none;}
		#CategoryID_TR { display: none;}
		.ExpandableLink {color: #1a9b50; text-decoration: none;}
	</style>
</cfif>

<lh:MS_Table table="RelevantLinks" title="#pg_title#" >
	
	<lh:MS_TableColumn
		ColName="RelevantLinkID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true" />	
	
	<lh:MS_TableColumn
		ColName="Title"
		type="text" 
		MaxLength="200"
		Required="Yes" />
	
	<lh:MS_TableColumn
		ColName="Descr"
		DispName="Text Content"
		type="textarea"
		allowHTML="Yes"
		SpellCheck="Yes"
		MaxLength="2000"
		Required="Yes"
		View="No" />
		
	<lh:MS_TableColumn
		ColName="ParentSectionID"
		DispName="Display In Sections"
		type="checkboxgroup"
		FKTable="ParentSectionsView"
		FKColName="ParentSectionID"
		FKDescr="Title"
		FKJoinTable="RelevantLinkParentSections"
		SelectQuery="Select ParentSectionID as SelectValue, Title as SelectText From ParentSectionsView Order By OrderNum"
		Required="No"
		ShowCheckAll="false"
		checkboxcols="1" />		
		
	<lh:MS_TableColumn
		ColName="SectionID"
		DispName="Display In Sub-Sections"
		type="checkboxgroup"
		FKTable="Sections"
		FKColName="SectionID"
		FKDescr="Title"
		FKJoinTable="RelevantLinkSections"
		SelectQuery="Select SectionID as SelectValue, Title as SelectText From SectionsView Order By Title"
		Required="No"
		ShowCheckAll="false"
		checkboxcols="1" />	
		
	<lh:MS_TableColumn
		ColName="CategoryID"
		DispName="Display In Categories"
		type="checkboxgroup"
		FKTable="Categories"
		FKColName="CategoryID"
		FKDescr="Title"
		FKJoinTable="RelevantLinkCategories"
		FKORderBy="Title"
		Required="No"
		ShowCheckAll="false"
		checkboxcols="1" />	
		
	<lh:MS_TableColumn 
		colname="Active" 
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="1" />
		
</lh:MS_Table>
<cfif IsDefined('Action') and ListFind("Add,Edit",Action)>
	<cfquery name="getCategoryTree" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum,
		S.SectionID, S.Title as STitle, S.OrderNum as SOrderNum,
		C.CategoryID, C.Title as CTitle, C.OrderNum as COrderNum
		FROM Categories C
		Inner Join Sections S on C.SectionID=S.SectionID
		Inner Join ParentSectionsView PS on S.ParentSectionID=PS.ParentSectionID
		UNION
		SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum,
		PS.ParentSectionID*1000000 as SectionID, null as STitle, 0 as SOrderNum,
		C.CategoryID, C.Title as CTitle, C.OrderNum as COrderNum
		FROM Categories C
		Inner Join ParentSectionsView PS on C.ParentSectionID=PS.ParentSectionID and C.SectionID is null
		Order By PSOrderNum, SOrderNum, COrderNum
	</cfquery>
	<cfquery name="getSelectedParentSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT ParentSectionID
		FROM RelevantLinkParentSections 
		WHERE RelevantLinkID = <cfif Action is "Add">0<cfelse><cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER"></cfif> 
	</cfquery>
	<cfquery name="getSelectedSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT SectionID
		FROM RelevantLinkSections 
		WHERE RelevantLinkID = <cfif Action is "Add">0<cfelse><cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER"></cfif> 
	</cfquery>
	<cfquery name="getSelectedCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT CategoryID  
		FROM RelevantLinkCategories 
		WHERE RelevantLinkID = <cfif Action is "Add">0<cfelse><cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER"></cfif> 
	</cfquery>	
	<cfsavecontent variable="CategoryDrillDownTable">
			<cfoutput query="getCategoryTree" group="PSOrderNum">
				<input type="checkbox" class="ParentSection" value="#ParentSectionID#" <cfif ListFind(ValueList(getSelectedParentSections.ParentSectionID),ParentSectionID)>checked</cfif> onClick="checkParentSection(this,#ParentSectionID#)"><a href="javascript:showSections(#ParentSectionID#);" class="ExpandableLink">#PSTitle#</a><br>
				<span ID="ParentSection#ParentSectionID#ChildrenSpan">
					<cfoutput group="SOrderNum">
						<cfif SectionID lt 1000000>
						&nbsp;&nbsp;&nbsp;
						<input type="checkbox" class="ChildOfParentSection#ParentSectionID#" value="#SectionID#" <cfif ListFind(ValueList(getSelectedSections.SectionID),SectionID)>checked</cfif> onClick="checkSection(this,#SectionID#)"><a href="javascript:showCategories(#SectionID#);" class="ExpandableLink">#STitle#</a><br>
						<cfelse>
							<input type="hidden" class="ChildOfParentSection#ParentSectionID#" value="#SectionID#">
						</cfif>
						<span id="Section#SectionID#ChildrenSpan">
							<cfoutput>
								&nbsp;&nbsp;&nbsp;
								&nbsp;&nbsp;&nbsp;
								<input type="checkbox" class="ChildOfSection#SectionID#" value="#CategoryID#" <cfif ListFind(ValueList(getSelectedCategories.CategoryID),CategoryID)>checked</cfif> onClick="checkCategory(this,#CategoryID#)">#CTitle#<br>
							</cfoutput>
						</span>
					</cfoutput>
				</span>
			</cfoutput>
	</cfsavecontent>
	<cfoutput>
	<!--- #CategoryDrillDownTable# --->
	<script language="javascript" type="text/javascript">
		$(document).ready(function()
		{		    
			$("##MainAdminTable tr:last").prev().prev().before('<TR CLASS=ADDROW ID=\'DisplayIn_TR\'><TD CLASS=ADDLABELCELL><label for=\'DisplayIn\'>Display In:</label></TD><TD CLASS=ADDFIELDCELL>#JSStringFormat(CategoryDrillDownTable)#</TD></TR>');
			<!--- Loop through tree and show any spans that contain checked items --->
			$('.ParentSection').each(function(x,y){
				showSectionSpan=0;
				$('.ChildOfParentSection' + $(y).val()).each(function(a,b){
					if ($(b).attr('checked')==true) {
						showSectionSpan=1;
					}
					showCategorySpan=0;
					$('.ChildOfSection' + $(b).val()).each(function(c,d){
						if ($(d).attr('checked')==true) {
							showSectionSpan=1;
							showCategorySpan=1;
						}
					});
					if (showCategorySpan==0) {
						$("##Section" + $(b).val() + "ChildrenSpan").hide();
					}
				});
				if (showSectionSpan==0) {
					$("##ParentSection" + $(y).val() + "ChildrenSpan").hide();
				}
			});	
		});	
	</script> 
	</cfoutput>

	<script>
		
		function showSections(y) {
			if ($('#ParentSection' + y + 'ChildrenSpan').is(":hidden")==true) {
				$('#ParentSection' + y + 'ChildrenSpan').show();
				$('.ChildOfParentSection' + y).each(function(a,b){
					if ($(b).val() > 1000000) {
						$("#Section" + $(b).val() + "ChildrenSpan").show();
					}
				});						
			}
			else {
				showSectionSpan=0;
				$('.ChildOfParentSection' + y).each(function(a,b){
					if ($(b).attr('checked')==true) {
						showSectionSpan=1;
					}
					showCategorySpan=0;
					$('.ChildOfSection' + $(b).val()).each(function(c,d){
						if ($(d).attr('checked')==true) {
							showSectionSpan=1;
							showCategorySpan=1;
						}
					});
					if (showCategorySpan==0) {
						$("#Section" + $(b).val() + "ChildrenSpan").hide();
					}
				});				
				if (showSectionSpan==0) {
					$("#ParentSection" + y + "ChildrenSpan").hide();
				}
				else {
					alert('This Parent Section\'s Sections can not be hidden while any of its Sections or Categories are checked');
				}
			}			
		}
		
		function showCategories(b) {
			if ($('#Section' + b + 'ChildrenSpan').is(":hidden")==true) {
				$('#Section' + b + 'ChildrenSpan').show();
			}
			else {
				showCategorySpan=0;
				$('.ChildOfSection' + b).each(function(c,d){
					if ($(d).attr('checked')==true) {
						showCategorySpan=1;
					}
				});		
				if (showCategorySpan==0) {
					$("#Section" + b + "ChildrenSpan").hide();
				}
				else {
					alert('This  Section\'s Categories can not be hidden while any of its Categories are checked');
				}
			}			
		}
		
		function checkParentSection(t,x) {
			if ($(t).attr('checked')==true){
				parentSectionChecked=1;
			}
			else {
				parentSectionChecked=0;
			}
			for (i=0; i<document.f1.ParentSectionID.length; i++){
				if (document.f1.ParentSectionID[i].value==x) {
					document.f1.ParentSectionID[i].checked=parentSectionChecked;
				}
			}
		}
		
		function checkSection(t,x) {
			if ($(t).attr('checked')==true){
				sectionChecked=1;
			}
			else {
				sectionChecked=0;
			}
			for (i=0; i<document.f1.SectionID.length; i++){
				if (document.f1.SectionID[i].value==x) {
					document.f1.SectionID[i].checked=sectionChecked;
				}
			}
		}
		
		function checkCategory(t,x) {
			if ($(t).attr('checked')==true){
				categoryChecked=1;
			}
			else {
				categoryChecked=0;
			}
			for (i=0; i<document.f1.CategoryID.length; i++){
				if (document.f1.CategoryID[i].value==x) {
					document.f1.CategoryID[i].checked=categoryChecked;
				}
			}
		}
	</script>
</cfif>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">