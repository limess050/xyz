<!---
File Name: 	MS_TableDisplay_Field.cfm
Author: 	David Hammond
Description:
	Displays interface for entering the value of a column.  Can be called from AddEdit or View pages.

Inputs:
--->

<cfinclude template="../Functions/LighthouseLib.cfm">

<cffunction name="addChildColumn" output="false" returntype="void">
	<cfargument name="ParentColumn" required="true" type="struct">
	<cfargument name="ChildColumn" required="true" type="struct">

	<cfif Not Arguments.ChildColumn.PrimaryKey>
		<cfif Arguments.ChildColumn.Required>
			<cfset ParentColumn.TableHeader = ParentColumn.TableHeader & "<th>*#ChildColumn.DispName#</th>">
		<cfelse>
			<cfset ParentColumn.TableHeader = ParentColumn.TableHeader & "<th>#ChildColumn.DispName#</th>">
		</cfif>
	</cfif>

	<cfswitch expression="#Arguments.ChildColumn.Type#">
		<cfcase value="select-popup">
			<cfset Arguments.ParentColumn.selectClause = ListAppend(Arguments.ParentColumn.selectClause,"#Arguments.ParentColumn.Name#.#Arguments.ChildColumn.Name#")>
			<cfset Arguments.ParentColumn.selectClause = ListAppend(Arguments.ParentColumn.selectClause,"#Arguments.ChildColumn.fktable#.#Arguments.ChildColumn.fkdescr# as #Arguments.ChildColumn.Name#_Descr")>
			<cfset Arguments.ParentColumn.fromClause = Arguments.ParentColumn.fromClause & " INNER JOIN #Arguments.ChildColumn.fktable# ON #Arguments.ParentColumn.Name#.#Arguments.ChildColumn.fkcolname# = #Arguments.ChildColumn.fktable#.#Arguments.ChildColumn.fkcolname#">
		</cfcase>
		<cfdefaultcase>
			<cfset Arguments.ParentColumn.selectClause = ListAppend(Arguments.ParentColumn.selectClause,"#Arguments.ParentColumn.Name#.#Arguments.ChildColumn.Name#")>
		</cfdefaultcase>
	</cfswitch>
</cffunction>

<cfset Column = attributes.Column>

<cfif Not StructKeyExists(attributes,"value")>
	<cfif StructKeyExists(caller,Column.Name)>
		<cfset attributes.value = caller[Column.Name]>
	<cfelse>
		<cfset attributes.value = "">
	</cfif>
</cfif>
<cfset fieldNameSuffix = "">
<cfif StructKeyExists(attributes,"pk")>
	<cfset pk = attributes.pk>
	<cfset fieldNameSuffix = "_" & pk>
<cfelseif not IsDefined("pk")>
	<cfset pk = "">
</cfif>
<cfset Column.FieldID = Column.Name & fieldNameSuffix>
<cfif StructKeyExists(attributes,"prefix")>
	<cfset Column.FieldID = attributes.prefix & Column.FieldID>
</cfif>

<cfif Column.Type is "Timestamp"><cfset Column.Editable = "No"></cfif>
<cfif Not Column.Editable>
	<cfif Request.Table.action is "Add" and Len(attributes.value) is 0>
		<cfset attributes.value = Column.DefaultValue>
	</cfif>
	<cfoutput>
	<input type="hidden" name="#Column.FieldID#_isEditable" value="false">
	<cfparam name="caller.#Column.Name#" default="">
	<input type="hidden" name="#Column.Name#" value="#HTMLEditFormat(attributes.value)#">
	<cftry>
	#Column.formatValue(attributes.value)#
	<cfcatch></cfcatch>
	</cftry>
	</cfoutput>
<cfelse>

	<cfoutput><input type="hidden" name="#Column.FieldID#_isEditable" value="true"></cfoutput>

	<cfif Column.Type is "select" or Column.Type is "select-multiple" or Column.Type is "checkboxgroup" or Column.Type is "radio">
		<cfif Not IsDefined("caller.getValues_#Column.Name#")>
			<cfif Len(Column.ValueList) gt 0>
				<cfset SetVariable("caller.getValues_#Column.Name#",listToQuery(Column.ValueList, "SelectValue,SelectText"))>
			<cfelse>
				<cfquery name="caller.getValues_#Column.Name#" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					<cfif Len(Column.SelectQuery) gt 0>
						#PreserveSingleQuotes(Column.SelectQuery)#
					<cfelse>
						SELECT
							<cfif Len(Column.ParentColumn) gt 0>#PreserveSingleQuotes(Column.ParentColumn)# as ParentCol,</cfif>
							<cfif Len(Column.Group) gt 0>#PreserveSingleQuotes(Column.Group)# as GroupName,</cfif>
							#Column.FKColName# as SelectValue,
							#PreserveSingleQuotes(Column.FKDescr)# as SelectText
						FROM #Column.FKTable#
						<cfif Len(Column.FKWhere) gt 0>WHERE #PreserveSingleQuotes(Column.FKWhere)#</cfif>
						<cfif Len(Column.FKOrderBy) gt 0>
							ORDER BY
							<cfif Len(Column.Group) gt 0>#PreserveSingleQuotes(Column.Group)#,</cfif>
							#PreserveSingleQuotes(Column.FKOrderBy)#
						</cfif>
					</cfif>
				</cfquery>
			</cfif>
		</cfif>
	</cfif>
	<cfswitch expression="#Column.Type#">
		<cfcase value="Textarea">
			<cfoutput>
			<cfif Column.AllowHTML>
				<cf_MS_HTMLEdit
					HtmlEditor="#Column.HtmlEditor#"
					HtmlEditorParameters="#Column.HtmlEditorParameters#"
					FieldName="#Column.FieldID#"
					resourcesDir="#Request.AppVirtualPath#/Lighthouse/Resources"
					dispName="#Column.DispName#"
					toolbars="#Column.toolbars#"
					imageDir="#Column.imageDir#"
					spellcheck="#Column.spellcheck#"
					className="#Column.ClassName#"
					SiteEditor="#Column.SiteEditor#"
					Value="#attributes.value#"
					setHeader="false">
			<cfelse>
				<!--- Insert default FormFieldParameters --->
				<!--- Cols --->
				<cfif REFindNoCase("[[:space:]]+COLS[[:space:]]*="," #Column.FormFieldParameters#") is 0>
					<cfset Column.FormFieldParameters = Column.FormFieldParameters & " COLS=50">
				</cfif>
				<!--- Rows --->
				<cfif REFindNoCase("[[:space:]]+ROWS[[:space:]]*="," #Column.FormFieldParameters#") is 0>
					<cfset Column.FormFieldParameters = Column.FormFieldParameters & " ROWS=6">
				</cfif>
				<TEXTAREA NAME="#Column.FieldID#" ID="#Column.FieldID#" #Column.FormFieldParameters#>#HTMLEditFormat(attributes.value)#</TEXTAREA
				><cfif Column.SpellCheck><BR><A HREF="javascript:spellCheckField('document.f1.#Column.Name#.value','#Column.DispName#')" CLASS=SMALLTEXT>Check Spelling</A></cfif>
			</cfif>
			</cfoutput>
		</cfcase>
		<cfcase value="Select">
			<cfoutput>
			<cfset Column.SelectedList = attributes.value>
			<select name="#Column.FieldID#" id="#Column.FieldID#" #Column.FormFieldParameters# 
				<cfif Len(Column.ChildColumn) gt 0>onChange="mainTable.Columns.#Column.Name#.populateChildSelectList('#fieldNameSuffix#',this)"</cfif>>
				</cfoutput>
				<cfif Len(Column.ParentColumn) is 0>
					<cfif Len(Column.Group) gt 0>
						<cfoutput><optgroup label=""><option value="">--- Select #Column.DispName# ---</optgroup></cfoutput>
						<cfoutput query="caller.getValues_#Column.Name#" group="groupname">
							<optgroup label="#groupname#">
							<cfoutput>
								<option value="#SelectValue#" <cfif SelectValue is attributes.value>selected</cfif>>#SelectText#</option>
							</cfoutput>
							</optgroup>
						</cfoutput>
					<cfelse>
						<cfoutput><option value="">--- Select #Column.DispName# ---</option></cfoutput>
						<cfoutput query="caller.getValues_#Column.Name#">
							<option value="#SelectValue#" <cfif SelectValue is attributes.value>selected</cfif>>#SelectText#</option>
						</cfoutput>
					</cfif>
				</cfif>
			</select>
			<cfif Len(Column.ParentColumn) gt 0>
				<cfoutput><input type="hidden" id="#Column.FieldID#_ChildColumnValuesAuthToken" value="#Column.GetChildColumnValuesAuthToken()#"></cfoutput>
				<cfset selectedValuesList = "#Column.SelectedList#">
				<cfif StructKeyExists(Request.Table.Columns[Column.ParentColumn],"SelectedList")>
					<cfset synchValuesList = "#Request.Table.Columns[Column.ParentColumn].SelectedList#">
				<cfelseif Request.Table.Columns[Column.ParentColumn].Type is "select" and pk is not "">
					<cfquery name="getParentSelected" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						SELECT #Column.ParentColumn# as ColName FROM #Request.Table.table# 
						WHERE #Request.Table.PrimaryKey# = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
					</cfquery>
					<cfset synchValuesList = "#getParentSelected.ColName#">
				<cfelseif Request.Table.Columns[Column.ParentColumn].Type is "select-multiple" and pk is not "">
					<cfquery name="getParentSelected" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						SELECT #Column.ParentColumn# as ColName FROM #Request.Table.Columns[Column.ParentColumn].FKJoinTable# 
						WHERE #Request.Table.Columns[Column.ParentColumn].PKColName# = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
					</cfquery>
					<cfset synchValuesList = "#ValueList(getParentSelected.ColName)#">
				<cfelse>
					<cfset synchValuesList = "">
				</cfif>
				<script type="text/javascript">
					<cfoutput>
					xAddEvent(window,"load",function(){
						mainTable.Columns.#Column.Name#.populateSelectList("#fieldNameSuffix#",split("#selectedValuesList#",","),split("#synchValuesList#",","));
					})
					</cfoutput>
				</script>
			</cfif>
		</cfcase>
		<cfcase value="Radio">
			<TABLE>
			<cfif Len(Column.Group) gt 0>
				<cfoutput query="caller.getValues_#Column.Name#" group="groupname">
					<TR><TD COLSPAN=#Column.RadioCols# CLASS=NORMALTEXT><B>#groupname#</B></TD></TR>
					<cfset currRow = 1>
					<cfoutput>
						<cfif Column.RadioCols is 1 or currRow mod Column.RadioCols is 1><TR></cfif>
						<TD CLASS=NORMALTEXT><INPUT TYPE="Radio" NAME="#Column.FieldID#" ID="#Column.Name#_#groupname#_#currentRow#" VALUE="#SelectValue#" <cfif SelectValue is attributes.value>CHECKED</cfif> #Column.FormFieldParameters#><label for="#Column.Name#_#groupname#_#currentRow#">#SelectText#</label></TD>
						<cfif currRow mod Column.RadioCols is 0 or currRow is recordCount></TR></cfif>
						<cfset currRow = currRow + 1>
					</cfoutput>
				</cfoutput>
			<cfelse>
				<cfoutput query="caller.getValues_#Column.Name#">
					<cfif Column.RadioCols is 1 or currentRow mod Column.RadioCols is 1><TR></cfif>
					<TD CLASS=NORMALTEXT><INPUT TYPE="Radio" NAME="#Column.FieldID#" ID="#Column.Name#_#currentRow#" VALUE="#SelectValue#" <cfif SelectValue is attributes.value>CHECKED</cfif> #Column.FormFieldParameters#><label for="#Column.Name#_#currentRow#">#SelectText#</label></TD>
					<cfif currentRow mod Column.RadioCols is 0 or currentRow is recordCount></TR></cfif>
				</cfoutput>
			</cfif>
			</TABLE>
		</cfcase>
		<cfcase value="Checkboxgroup">
			<cfif len(pk) gt 0>
				<cfquery name="getSelected" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT #Column.FKColName# as ColName 
					FROM #Column.FKJoinTable# 
					WHERE #Column.PKColName# = 
						<cfif Column.FKType is "text">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#pk#">
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
						</cfif>
				</cfquery>
				<cfset selectedList = ValueList(getSelected.ColName)>
			</cfif>
			<TABLE CLASS=ADDTABLE>
			<cfif Len(Column.Group) gt 0>
				<cfoutput query="caller.getValues_#Column.Name#" group="groupname">
					<TR><TD COLSPAN=#Column.CheckboxCols# CLASS=NORMALTEXT>
						<B>#groupname#</B>
						<cfif Column.ShowCheckAll>&nbsp;&nbsp;&nbsp;<a href="javascript:setChecked(document.f1,true,'#Column.Name#_#groupname#_[0-9]+')">Check All</a> | <a href="javascript:setChecked(document.f1,false,'#Column.Name#_#groupname#_[0-9]+')">Check None</a></cfif>
					</TD></TR>
					<cfset currRow = 1>
					<cfoutput>
						<cfif Column.CheckboxCols is 1 or currRow mod Column.CheckboxCols is 1><TR></cfif>
						<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="#Column.Name#_#groupname#_#currentRow#" NAME="#Column.FieldID#" VALUE="#SelectValue#" <cfif len(pk) gt 0><cfif ListFind(selectedList,SelectValue)>CHECKED</cfif></cfif> #Column.FormFieldParameters#><label for="#Column.Name#_#groupname#_#currentRow#">#SelectText#</label></TD>
						<cfif currRow mod Column.CheckboxCols is 0 or currRow is recordCount></TR></cfif>
						<cfset currRow = currRow + 1>
					</cfoutput>
				</cfoutput>
			<cfelse>
				<cfif Column.ShowCheckAll>
					<cfoutput>
					<TR><TD COLSPAN=#Column.CheckboxCols# CLASS=NORMALTEXT>
						<a href="javascript:setChecked(document.f1,true,'#Column.Name#_[0-9]+')">Check All</a> | <a href="javascript:setChecked(document.f1,false,'#Column.Name#_[0-9]+')">Check None</a>
					</TD></TR>
					</cfoutput>
				</cfif>
				<cfoutput query="caller.getValues_#Column.Name#">
					<cfif Column.CheckboxCols is 1 or currentRow mod Column.CheckboxCols is 1><TR></cfif>
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="#Column.Name#_#currentRow#" NAME="#Column.FieldID#" VALUE="#SelectValue#" <cfif len(pk) gt 0><cfif ListFind(selectedList,SelectValue)>CHECKED</cfif></cfif> #Column.FormFieldParameters#><label for="#Column.Name#_#currentRow#">#SelectText#</label></TD>
					<cfif currentRow mod Column.CheckboxCols is 0 or currentRow is recordCount></TR></cfif>
				</cfoutput>
			</cfif>
			</TABLE>
		</cfcase>
		<cfcase value="Select-Multiple">
			<cfif len(pk) gt 0>
				<cfquery name="getSelected" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT #Column.FKColName# as ColName 
					FROM #Column.FKJoinTable# 
					WHERE #Column.PKColName# = 
						<cfif Column.FKType is "text">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#pk#">
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
						</cfif>
				</cfquery>
				<cfset Column.SelectedList = ValueList(getSelected.ColName)>
			<cfelse>
				<cfset Column.SelectedList = Column.DefaultValue>
			</cfif>
			<!--- Insert default FormFieldParameters --->
			<!--- Size --->
			<cfif REFindNoCase("[[:space:]]+size[[:space:]]*="," #Column.FormFieldParameters#") is 0>
				<cfset selectboxsize = Min(Evaluate("caller.getValues_#Column.Name#.recordcount"),10)>
				<cfset Column.FormFieldParameters = Column.FormFieldParameters & " size=" & selectboxsize>
			</cfif>
			<cfoutput>
			<SELECT NAME="#Column.FieldID#" ID="#Column.FieldID#" MULTIPLE #Column.FormFieldParameters# <cfif Len(Column.ChildColumn) gt 0>onChange="mainTable.Columns.#Column.Name#.populateChildSelectList('#fieldNameSuffix#',this)"</cfif>>
				</cfoutput>
				<cfif Len(Column.ParentColumn) is 0>
					<cfif Len(Column.Group) gt 0>
						<cfoutput query="caller.getValues_#Column.Name#" group="groupname">
							<optgroup label="#groupname#">
							<cfoutput>
								<OPTION VALUE="#SelectValue#" <cfif ListFind(Column.SelectedList,SelectValue)>SELECTED</cfif>>#SelectText#
							</cfoutput>
							</optgroup>
						</cfoutput>
					<cfelse>
						<cfoutput query="caller.getValues_#Column.Name#">
							<OPTION VALUE="#SelectValue#" <cfif ListFind(Column.SelectedList,SelectValue)>SELECTED</cfif>>#SelectText#
						</cfoutput>
					</cfif>
				</cfif>
			</SELECT>
			<cfif Len(Column.ParentColumn) gt 0>
				<cfoutput><input type="hidden" id="#Column.FieldID#_ChildColumnValuesAuthToken" value="#Column.GetChildColumnValuesAuthToken()#"></cfoutput>
				<script type="text/javascript">
					<cfoutput>
					<cfif StructKeyExists(Column,"SelectedList")>
						selectedValuesList = "#Column.SelectedList#";
					<cfelse>
						selectedValuesList = "";
					</cfif>
					<cfif StructKeyExists(Request.Table.Columns[Column.ParentColumn],"SelectedList")>
						synchValuesList = "#Request.Table.Columns[Column.ParentColumn].SelectedList#";
					<cfelseif Request.Table.Columns[Column.ParentColumn].Type is "select" and pk is not "">
						<cfquery name="getParentSelected" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							SELECT #Column.ParentColumn# as ColName FROM #Request.Table.table# 
							WHERE #Request.Table.PrimaryKey# = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
						</cfquery>
						synchValuesList = "#getParentSelected.ColName#";
					<cfelseif Request.Table.Columns[Column.ParentColumn].Type is "select-multiple" and pk is not "">
						<cfquery name="getParentSelected" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							SELECT #Column.ParentColumn# as ColName FROM #Request.Table.Columns[Column.ParentColumn].FKJoinTable# 
							WHERE #Request.Table.Columns[Column.ParentColumn].PKColName# = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
						</cfquery>
						synchValuesList = "#ValueList(getParentSelected.ColName)#";
					<cfelse>
						synchValuesList = "";
					</cfif>
					mainTable.Columns.#Column.Name#.populateSelectList("#fieldNameSuffix#",split(selectedValuesList,","),split(synchValuesList,","));
					</cfoutput>
				</script>
			</cfif>
		</cfcase>
		<cfcase value="Select-Popup">
			<cfoutput>
			<input type=hidden id="#Column.FieldID#" name="#Column.FieldID#" value="">
			<table id="#Column.FieldID#_SelectButton"><tr><td class=button onclick="lh.Cells['#Column.FieldID#'].select()">Select</td></tr></table>
			<table class="SelectPopup" cellspacing=3 cellpadding=1 border=0><tbody id="#Column.FieldID#_table"></tbody></table>
			<cfif fieldNameSuffix is not "_0">
				<script type="text/javascript">
					mainTable.Rows[0].addCell("#Column.Name#").render();
					<cfif Len(attributes.value)>
						<cfquery name="getSelected" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							SELECT #Column.FKColName# as id, #preservesinglequotes(Column.FKDescr)# as Descr
							FROM #Column.FKTable# 
							WHERE #Column.FKColName# = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.value#">
						</cfquery>
						<cfloop query="getSelected">
							lh.Cells["#Column.FieldID#"].add("#id#","#JSStringFormat(Descr)#");
						</cfloop>
					</cfif>
				</script>
			</cfif>
			</cfoutput>
		</cfcase>
		<cfcase value="Select-multiple-Popup">
			<cfoutput>
			<script type="text/javascript">
			var #Column.FieldID#_SelectWindow;
			function #Column.FieldID#_add(pk,descr) {
				// Make sure it's not already selected
				if (!#Column.FieldID#_isSelected(pk)) {
					var row = document.createElement("TR");
					row.setAttribute("rowID",pk);
					row.setAttribute("rowDescription",descr);
					var rowObj = document.getElementById("#Column.FieldID#_table").appendChild(row);

					var cell1 = document.createElement("TD");
					var cell1Obj = rowObj.appendChild(cell1);
					var cell2 = document.createElement("TD");
					var cell2Obj = rowObj.appendChild(cell2);
					<cfif Len(Column.ViewURL)>
						var cell3 = document.createElement("TD");
						var cell3Obj = rowObj.appendChild(cell3);
					</cfif>
					<cfif Len(Column.OrderColumn)>
						var cell4 = document.createElement("TD");
						rowObj.appendChild(cell4);
					</cfif>

					// Set contents of cells
					cell1Obj.innerHTML = descr;
					cell2Obj.innerHTML = "<A href=javascript:void(0) onclick=#Column.FieldID#_delete(" + pk + ")>Delete</A>";
					<cfif Len(Column.ViewURL)>
						cell3Obj.innerHTML = "<A href=\"javascript:void(0);\" onclick=\"popupDialog('#Column.FieldID#_SelectWindow',750,500,'resizable=1,scrollbars=1','#ReplaceNoCase(Column.ViewURL,"##pk##",""" + pk + """)#')\">View</A>";
					</cfif>

					#Column.FieldID#_setOrderBy()
				} else {
					var row = #Column.FieldID#_getRow(pk)
					row.firstChild.innerHTML = descr;
				}					
			}
			// Set move up/move down buttons
			function #Column.FieldID#_setOrderBy () {
					var rows = document.getElementById("#Column.FieldID#_table").getElementsByTagName("TR");
					var idArray = new Array(rows.length);
					for (var r = 0; r < rows.length; r ++) {
						<cfif Len(Column.OrderColumn)>
							foo = "";
							if (r != rows.length - 1) {
								foo += "<A href=\"javascript:void(0)\" onclick=\"#Column.FieldID#_moveDown(this.parentNode.parentNode)\"><img src=#Request.AppVirtualPath#/Lighthouse/Resources/images/arrowdn.gif alt=\"Move Down\" border=0></A>";
							} else {
								foo += "<img src=#Request.AppVirtualPath#/Lighthouse/Resources/images/spacer.gif alt=\"\" width=11>"
							}
							if (r != 0) {
								foo += "<A href=\"javascript:void(0)\" onclick=\"#Column.FieldID#_moveUp(this.parentNode.parentNode)\"><img src=#Request.AppVirtualPath#/Lighthouse/Resources/images/arrowup.gif alt=\"Move Up\" border=0></A>";
							}
							rows[r].lastChild.innerHTML = foo;
						</cfif>
						idArray[r] = rows[r].getAttribute("rowID");
					}
					document.f1.#Column.FieldID#.value = idArray.join();
			}
			// Check to see if an item is already selected
			function #Column.FieldID#_isSelected(pk) {
				var row = #Column.FieldID#_getRow(pk);
				if (row == null) {
					return false;
				} else {
					return true;
				}
			}
			// Get row for an item
			function #Column.FieldID#_getRow(pk) {
				var rows = document.getElementById("#Column.FieldID#_table").getElementsByTagName("TR");
				if (rows.length > 0) {
					for (var r = 0; r < rows.length; r ++) {
						if (pk == rows[r].getAttribute("rowID")) {
							return rows[r];
						}
					}
				}
				return null;
			}
			function #Column.FieldID#_delete(pk) {
				row = #Column.FieldID#_getRow (pk)
				row.parentNode.removeChild(row);
				#Column.FieldID#_setOrderBy()
			}
			function #Column.FieldID#_moveUp(obj) {
				moveObjUp(obj);
				#Column.FieldID#_setOrderBy()
			}
			function #Column.FieldID#_moveDown (obj) {
				moveObjDown(obj);
				#Column.FieldID#_setOrderBy()
			}
			</script>
			<INPUT type=hidden value="" name=#Column.FieldID#>
			<TABLE CLASS=ADDTABLE CELLSPACING=0 CELLPADDING=3 BORDER=1>
				<TR><TD COLSPAN=2><A HREF="#Column.PopupURL#" ONCLICK="#Column.FieldID#_SelectWindow = popupDialog('#Column.Name#',750,500,'resizable=1,scrollbars=1')" TARGET="#Column.Name#">Add New</A></TD></TR>
			</TABLE>
			<TABLE CLASS=ADDTABLE CELLSPACING=0 CELLPADDING=3 BORDER=1><TBODY ID="#Column.FieldID#_table">
			</TBODY></TABLE>
			<cfif len(pk) gt 0>
				<cfquery name="getSelected" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT #Column.FKTable#.#Column.FKColName# as ColName, #preservesinglequotes(Column.FKDescr)# as Descr
					FROM #Column.FKTable# inner join #Column.FKJoinTable# on #Column.FKTable#.#Column.FKColName# = #Column.FKJoinTable#.#Column.FKColName#
					WHERE #Column.FKJoinTable#.#Column.PKColName# = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
					<cfif Len(Column.OrderColumn)>ORDER BY #Column.OrderColumn#</cfif>
				</cfquery>
				<script type="text/javascript"><cfloop query="getSelected">
					#Column.FieldID#_add("#ColName#","#JSStringFormat(Descr)#");
				</cfloop></script>
			</cfif>

			</cfoutput>
		</cfcase>
		<cfcase value="Date">
			<cfoutput>
			<cfif Column.ShowDate>
				<cfif Not StructKeyExists(request,"DateDojoVarsSet")>
					<script type="text/javascript">
					dojo.addOnLoad(function(){
						dojo.require("dojo.widget.*");
						dojo.require("dojo.widget.DatePicker");
						dojo.require("dojo.widget.PopupContainer");
				
					});
					</script>
					<cfset Request.DateDojoVarsSet = 1>
				</cfif>
				<input type="TEXT" id="#Column.FieldID#" name="#Column.FieldID#" value="#DateFormat(attributes.value,Column.Format)#" #Column.FormFieldParameters#>
				<img style="vertical-align:middle;cursor:pointer;" alt="Select a date" 
					onclick="lh.ShowPopupCalendar(getEl('#Column.FieldID#'),'#Column.Format#')"
					src="#Request.AppVirtualPath#/Lighthouse/dojo/src/widget/templates/images/dateIcon.gif"/>
			</cfif>
			<cfif Column.ShowTime>
				<INPUT TYPE="TEXT" SIZE=2 MAXLENGTH=2 NAME="#Column.FieldID#_Hour" id="#Column.FieldID#_Hour" VALUE="#TimeFormat(attributes.value,"hh")#" STYLE="font-family:courier new"
				>:<INPUT TYPE="TEXT" SIZE=2 MAXLENGTH=2 NAME="#Column.FieldID#_Minute" id="#Column.FieldID#_Minute" VALUE="#TimeFormat(attributes.value,"mm")#" STYLE="font-family:courier new"
				><cfset ampm = TimeFormat(attributes.value,"tt")
				><SELECT NAME="#Column.FieldID#_AMPM" id="#Column.FieldID#_AMPM" STYLE="font-family:courier new">
					<OPTION <cfif ampm is "AM">selected</cfif>>AM</OPTION>
					<OPTION <cfif ampm is "PM">selected</cfif>>PM</OPTION>
				</SELECT>
			</cfif>
			</cfoutput>
		</cfcase>
		<cfcase value="Timestamp">
			<!--- On edit Timestamp will be treated as a non-editable date --->******
		</cfcase>
		<cfcase value="Integer">
			<cfoutput>
			<cfif Len(Column.Format) gt 0 and Len(attributes.value) gt 0>
				<cfset attributes.value = Trim(NumberFormat(attributes.value,Column.Format))>
			</cfif>
			<INPUT TYPE="TEXT" NAME="#Column.FieldID#" ID="#Column.FieldID#" VALUE="#attributes.value#" <cfif Len(Column.MaxLength) gt 0>MAXLENGTH="#Column.MaxLength#"</cfif> #Column.FormFieldParameters#>
			</cfoutput>
		</cfcase>
		<cfcase value="Checkbox">
			<cfoutput>
			<INPUT TYPE="Checkbox" NAME="#Column.FieldID#" ID="#Column.FieldID#" VALUE="#Column.OnValue#" #Column.FormFieldParameters# <cfif attributes.value is Column.OnValue>CHECKED</cfif>>
			</cfoutput>
		</cfcase>
		<cfcase value="File">
			<cfoutput>
				<input type="File" name="#Column.FieldID#" id="#Column.FieldID#" #Column.FormFieldParameters#>
				<span id="#Column.FieldID#_FileBrowserLink" class="button">Choose a File on the Server</span>
				<div id="#Column.FieldID#_CurrentFileDisplay">
					Current File: <a id="#Column.FieldID#_Link" target="_blank">#attributes.value#</a>
					<INPUT TYPE="CHECKBOX" NAME="#Column.FieldID#_Delete" ID="#Column.FieldID#_Delete" VALUE="Y"><label for="#Column.FieldID#_Delete">Delete this file.</label>
				</div>
				<input type="HIDDEN" id="#Column.FieldID#_OldFile" name="#Column.FieldID#_OldFile">
				<cfif fieldNameSuffix is not "_0">
					<script type="text/javascript">
						mainTable.Rows[0].addCell("#Column.Name#").render().setValue("#attributes.value#");
					</script>
				</cfif>
			</cfoutput>
		</cfcase>
		<cfcase value="ChildTable">
			<cfset Column.SelectClause = "">
			<cfset Column.FromClause = Column.Name>
			<cfset Column.TableHeader = "">
			<cfloop index="childColNum" from="1" to="#ArrayLen(Column.ColumnOrder)#">
				<cfset addChildColumn(Column,Column.Columns[Column.ColumnOrder[childColNum]])>
			</cfloop>
			<cfoutput>
			<span class="button" onclick="mainTable.Tables['#Column.Name#'].addRow().render()" title="Add a new record">Add #Column.DispName#</span>
			<table id="#Column.Name#_Table" class="childtableedit" style="display:none;">
				<thead><tr>#Column.TableHeader#</tr></thead>
				<tbody></tbody>
			</table>
			<!--- Create a row to use as a template. --->
			<cfloop collection="#Column.Columns#" item="key">
				<cfset ChildColumn = Column.Columns[key]>
				<cfif Not ChildColumn.PrimaryKey>
					<div id="#Column.Name#_#ChildColumn.Name#_Template" style="display:none">
						<cf_MS_TableDisplay_Field Column="#ChildColumn#" Value="#ChildColumn.DefaultValue#" pk="0" prefix="#Column.Name#_">
					</div>
				</cfif>
			</cfloop>
			<script type="text/javascript">
			xAddEvent(window,"load",function(){
				<!--- Display current records --->
				<cfif len(pk) gt 0>
					<cfquery name="getChildRecords" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						SELECT #PreserveSingleQuotes(Column.SelectClause)#
						FROM #Column.FromClause#
						WHERE #Column.Name#.#Request.Table.PrimaryKey# = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
						<cfif Len(Column.OrderColumn) gt 0>
							ORDER BY #Column.OrderColumn#
						<cfelseif Len(Column.OrderBy) gt 0>
							ORDER BY #Column.OrderBy#
						</cfif>
					</cfquery>
					<cfloop query="getChildRecords">
						<cfset valuesArray = ArrayNew(1)>
						<cfloop index="childColNum" from="1" to="#ArrayLen(Column.ColumnOrder)#">
							<cfset ChildColumn = Column.Columns[Column.ColumnOrder[childColNum]]>
							<cfswitch expression="#ChildColumn.Type#">
								<cfcase value="select-popup">
									<cfset ArrayAppend(valuesArray,ChildColumn.formatValue(getChildRecords[ChildColumn.Name][currentrow],false,true,getChildRecords[ChildColumn.Name&"_Descr"][currentrow]))>
								</cfcase>
								<cfdefaultcase>
									<cfset ArrayAppend(valuesArray,"""" & ChildColumn.formatValue(getChildRecords[ChildColumn.Name][currentrow],false,true) & """")>
								</cfdefaultcase>
							</cfswitch>
						</cfloop>
						mainTable.Tables["#Column.Name#"].addRow().render([#ArrayToList(valuesArray)#]);
					</cfloop>
				</cfif>
			});
			</script>
			</cfoutput>
		</cfcase>
		<cfdefaultcase>
			<cfoutput>
			<INPUT TYPE="TEXT" NAME="#Column.FieldID#" ID="#Column.FieldID#" <cfif Len(Column.MaxLength) gt 0>MAXLENGTH="#Column.MaxLength#"</cfif> VALUE="#HTMLEditFormat(attributes.value)#" #Column.FormFieldParameters#>
			</cfoutput>
		</cfdefaultcase>
	</cfswitch>
</cfif>