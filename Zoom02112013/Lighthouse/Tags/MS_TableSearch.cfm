<!---
File Name: 	MS_TableSearch.cfm
Author: 	David Hammond
Description:

Inputs:
--->

<cffunction name="displaySearchField" output="true" returntype="void">
	<cfargument name="Column" required="true" type="struct">
	<cfargument name="Prefix" type="string" default="">

	<cfset parameterName = Prefix & Arguments.Column.Name>
	
	<cfif Not StructKeyExists(url,ParameterName)>
		<cfset url[ParameterName] = "">
	</cfif>
	<cfif Not StructKeyExists(url,ParameterName & "_nullOnly")>
		<cfset url[ParameterName & "_nullOnly"] = "">
	</cfif>

	<cfswitch expression="#Arguments.Column.Type#">
		<cfcase value="select,select-multiple,select-popup,select-multiple-popup">
			<cfset getValues = getValuesQuery(Arguments.Column)>
			<cfset selectsize = Min(getValues.recordcount,5)>
			<cfif Not Arguments.Column.Required><cfset selectsize = selectsize + 1></cfif>
			<cfoutput>
			<SELECT NAME="#ParameterName#" ID="#ParameterName#" MULTIPLE SIZE="#selectsize#">
				</cfoutput>
				<cfif Len(Arguments.Column.Group) gt 0>
					<cfif Not Arguments.Column.Required><optgroup label="None"><OPTION VALUE="null" <cfif ListFind(url[ParameterName],"none")>SELECTED</cfif>>-- None --</cfif></optgroup>
					<cfoutput query="getValues" group="groupname">
						<optgroup label="#groupname#">
						<cfoutput>
							<OPTION VALUE="#SelectValue#" <cfif ListFind(url[ParameterName],SelectValue)>SELECTED</cfif>>#SelectText#
						</cfoutput>
						</optgroup>
					</cfoutput>
				<cfelse>
					<cfif Not Arguments.Column.Required><OPTION VALUE="null" <cfif ListFind(url[ParameterName],"none")>SELECTED</cfif>>-- None --</cfif>
					<cfoutput query="getValues">
						<OPTION VALUE="#SelectValue#" <cfif ListFind(url[ParameterName],SelectValue)>SELECTED</cfif>>#SelectText#
					</cfoutput>
				</cfif>
			</SELECT>
		</cfcase>
		<cfcase value="radio,checkboxgroup">
			<cfset getValues = getValuesQuery(Arguments.Column)>
			<cfif Arguments.Column.Type is "radio">
				<cfset Arguments.Column.CheckboxCols = Arguments.Column.RadioCols>
			</cfif>
			<cfoutput>
			<TABLE>
				<cfif Not Arguments.Column.Required>
					<TR><TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" NAME="#ParameterName#" ID="#ParameterName#" VALUE="null" <cfif ListFind(url[ParameterName],"null")>CHECKED</cfif> #Arguments.Column.FormFieldParameters#>-- None --</TD>
					<cfset currRow = 1>
				<cfelse>
					<cfset currRow = 0>
				</cfif>
				</cfoutput>
				<cfif Len(Arguments.Column.Group) gt 0>
					<cfoutput query="getValues" group="groupname">
						<TR><TD COLSPAN=#Arguments.Column.CheckboxCols# CLASS=NORMALTEXT>
							<B>#groupname#</B>
							&nbsp;&nbsp;&nbsp;<a href="javascript:setChecked(document.f1,true,'#ParameterName#_#groupname#_[0-9]+')">Check All</a> | <a href="javascript:setChecked(document.f1,false,'#ParameterName#_#groupname#_[0-9]+')">Check None</a>
						</TD></TR>
						<cfset currRow = 1>
						<cfoutput>
							<cfif Arguments.Column.CheckboxCols is 1 or currRow mod Arguments.Column.CheckboxCols is 1><TR></cfif>
							<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="#ParameterName#_#groupname#_#currentRow#" NAME="#ParameterName#" VALUE="#SelectValue#" <cfif ListFind(url[ParameterName],SelectValue)>CHECKED</cfif> #Arguments.Column.FormFieldParameters#><LABEL FOR="#ParameterName#_#groupname#_#currentRow#">#SelectText#</LABEL></TD>
							<cfif currRow mod Arguments.Column.CheckboxCols is 0 or currentRow is recordCount></TR></cfif>
							<cfset currRow = currRow + 1>
						</cfoutput>
					</cfoutput>
				<cfelse>
					<cfoutput>
					<TR><TD COLSPAN=#Arguments.Column.CheckboxCols# CLASS=NORMALTEXT>
						<a href="javascript:setChecked(document.f1,true,'#ParameterName#_[0-9]+')">Check All</a> | <a href="javascript:setChecked(document.f1,false,'#ParameterName#_[0-9]+')">Check None</a>
					</TD></TR>
					</cfoutput>
					<cfoutput query="getValues">
						<cfset currRow = currRow + 1>
						<cfif Arguments.Column.CheckboxCols is 1 or currRow mod Arguments.Column.CheckboxCols is 1><TR></cfif>
						<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="#ParameterName#_#currentRow#" NAME="#ParameterName#" VALUE="#SelectValue#" <cfif ListFind(url[ParameterName],SelectValue)>CHECKED</cfif> #Arguments.Column.FormFieldParameters#><LABEL FOR="#ParameterName#_#currentRow#">#SelectText#</LABEL></TD>
						<cfif currRow mod Arguments.Column.CheckboxCols is 0 or currentRow is recordCount></TR></cfif>
					</cfoutput>
				</cfif>
			</TABLE>
		</cfcase>
		<cfcase value="Date,Timestamp">
			<cfif Not StructKeyExists(url,"#ParameterName#_end")>
				<cfset url[ParameterName & "_end"] = "">
			</cfif>
			<cfoutput>
			<label for="#ParameterName#">from</label>
			<input type="TEXT" id="#ParameterName#" name="#ParameterName#" size="15" value="#DateFormat(url[ParameterName],"#Column.Format#")#" #Arguments.Column.FormFieldParameters#>
			<img style="vertical-align:middle;cursor:pointer;" alt="Select a date" 
				onclick="lh.ShowPopupCalendar(getEl('#ParameterName#'),'#Column.Format#')"
				src="#Request.AppVirtualPath#/Lighthouse/dojo/src/widget/templates/images/dateIcon.gif"/>
			<label for="#ParameterName#_end">to</label>
			<input type="TEXT" name="#ParameterName#_end" id="#ParameterName#_end" size="15" value="#DateFormat(url[ParameterName & "_end"],"#Column.Format#")#" #Arguments.Column.FormFieldParameters#>
			<img style="vertical-align:middle;cursor:pointer;" alt="Select a date" 
				onclick="lh.ShowPopupCalendar(getEl('#ParameterName#_end'),'#Column.Format#')"
				src="#Request.AppVirtualPath#/Lighthouse/dojo/src/widget/templates/images/dateIcon.gif"/>
			<cfif Not Arguments.Column.Required>
				<br><INPUT TYPE="CHECKBOX" NAME="#ParameterName#_nullOnly" VALUE="Yes"
					ONCLICK="if(this.checked){document.f1.#ParameterName#.value='';document.f1.#ParameterName#_end.value='';}"
					<cfif Len(url[ParameterName & "_nullOnly"]) gt 0>checked</cfif>
				> Only show records with no value specified for #Arguments.Column.DispName#
			</cfif>
			</cfoutput>
		</cfcase>
		<cfcase value="Integer">
			<cfif Not StructKeyExists(url,"#ParameterName#_end")>
				<cfset url[ParameterName & "_end"] = "">
			</cfif>
			<cfoutput>
			<LABEL FOR="#ParameterName#">from</LABEL>
			<INPUT TYPE="TEXT" NAME="#ParameterName#" ID="#ParameterName#" SIZE="15" VALUE="#url[ParameterName]#" #Arguments.Column.FormFieldParameters#>
			<LABEL FOR="#ParameterName#_end">to</LABEL>
			<INPUT TYPE="TEXT" NAME="#ParameterName#_end" ID="#ParameterName#_end" SIZE="15" VALUE="#url[ParameterName & "_end"]#" #Arguments.Column.FormFieldParameters#>
			<cfif Not Arguments.Column.Required>
				<br><INPUT TYPE="CHECKBOX" NAME="#ParameterName#_nullOnly" VALUE="Yes"
					ONCLICK="if(this.checked){document.f1.#ParameterName#.value='';document.f1.#ParameterName#_end.value='';}"
					<cfif Len(url[ParameterName & "_nullOnly"]) gt 0>checked</cfif>
				> Only show records with no value specified for #Arguments.Column.DispName#
			</cfif>
			</cfoutput>
		</cfcase>
		<cfcase value="Pseudo">
			<cfif Not StructKeyExists(url,"#ParameterName#_end")>
				<cfset url[ParameterName & "_end"] = "">
			</cfif>
			<cfoutput>
			<LABEL FOR="#ParameterName#">from</LABEL>
			<INPUT TYPE="TEXT" NAME="#ParameterName#" ID="#ParameterName#" SIZE="15" VALUE="#url[ParameterName]#" #Arguments.Column.FormFieldParameters#>
			<LABEL FOR="#ParameterName#_end">to</LABEL>
			<INPUT TYPE="TEXT" NAME="#ParameterName#_end" ID="#ParameterName#_end" SIZE="15" VALUE="#url[ParameterName & "_end"]#" #Arguments.Column.FormFieldParameters#>
			</cfoutput>
		</cfcase>
		<cfcase value="Checkbox">
			<cfoutput>
			<cfset value = url[ParameterName]>
			<cfif Len(Arguments.Column.OffValue)>
				<INPUT TYPE="Radio" NAME="#ParameterName#" ID="#ParameterName#_On" VALUE="#Arguments.Column.OnValue#" <cfif value is Arguments.Column.OnValue>CHECKED</cfif>><LABEL FOR="#ParameterName#_On">#Arguments.Column.OnDisplayValue#</LABEL>
				<INPUT TYPE="Radio" NAME="#ParameterName#" ID="#ParameterName#_Off" VALUE="#Arguments.Column.OffValue#" <cfif value is Arguments.Column.OffValue>CHECKED</cfif>><LABEL FOR="#ParameterName#_Off">#Arguments.Column.OffDisplayValue#</LABEL>
				<INPUT TYPE="Radio" NAME="#ParameterName#" ID="#ParameterName#_Both" VALUE="" <cfif value is "">CHECKED</cfif>><LABEL FOR="#ParameterName#_Both">Both</LABEL>
			<cfelse>
				<INPUT TYPE="Checkbox" NAME="#ParameterName#" VALUE="#Arguments.Column.OnValue#" <cfif value is Arguments.Column.OnValue>CHECKED</cfif>>
			</cfif>
			</cfoutput>
		</cfcase>
		<cfcase value="ChildTable">
			<cfloop index="childColNum" from="1" to="#ArrayLen(Arguments.Column.ColumnOrder)#">
				<cfset ChildColumn = Arguments.Column.Columns[Arguments.Column.ColumnOrder[childColNum]]>
				<cfif ChildColumn.Search and Not ChildColumn.Hidden>
					<cfoutput>
					<TR>
						<TD CLASS=SEARCHLABELCELL SCOPE=row><LABEL FOR="#ParameterName#_#ChildColumn.Name#">#ChildColumn.DispName#</LABEL></TD>
						<TD CLASS=SEARCHFIELDCELL>#displaySearchField(ChildColumn,Arguments.Column.Name & "_")#</TD>
					</TR>
					</cfoutput>
				</cfif>
			</cfloop>
		</cfcase>
		<cfdefaultcase>
			<cfoutput>
			<INPUT TYPE="TEXT" NAME="#ParameterName#" ID="#ParameterName#" <cfif Len(Arguments.Column.MaxLength)>MAXLENGTH="#Arguments.Column.MaxLength#"</cfif> VALUE="#HTMLEditFormat(url[ParameterName])#" #Arguments.Column.FormFieldParameters#>
			<cfif Not Arguments.Column.Required>
				<br><INPUT TYPE="CHECKBOX" NAME="#ParameterName#_nullOnly" VALUE="Yes"
					ONCLICK="if(this.checked){document.f1.#ParameterName#.value='';}"
					<cfif Len(url[ParameterName & "_nullOnly"]) gt 0>checked</cfif>
				> Only show records with no value specified for #Arguments.Column.DispName#
			</cfif>
			</cfoutput>
		</cfdefaultcase>
	</cfswitch>
</cffunction>

<cffunction name="getValuesQuery" output="false" returntype="query"
	description="Get query containing the possible values for the column.">
	<cfargument name="Column" required="true" type="struct">
	
	<cfif Len(Arguments.Column.ValueList) gt 0>
		<cfset getValues = listToQuery(Arguments.Column.ValueList, "SelectValue,SelectText")>
	<cfelse>
		<cfquery name="getValues" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			<cfif Len(Arguments.Column.SelectQuery) gt 0>
				#PreserveSingleQuotes(Arguments.Column.SelectQuery)#
			<cfelse>
				SELECT
					<cfif Len(Arguments.Column.Group) gt 0>#Arguments.Column.Group# as GroupName,</cfif>
					#Arguments.Column.FKColName# as SelectValue,
					#PreserveSingleQuotes(Arguments.Column.FKDescr)# as SelectText
				FROM #Arguments.Column.FKTable#
				<cfif Len(Arguments.Column.FKWhere) gt 0>WHERE #PreserveSingleQuotes(Arguments.Column.FKWhere)#</cfif>
				<cfif Len(Arguments.Column.FKOrderBy) gt 0>order by #PreserveSingleQuotes(Arguments.Column.FKOrderBy)#</cfif>
			</cfif>
		</cfquery>
	</cfif>
	
	<cfreturn getValues>
</cffunction>


<cfoutput>
<script type="text/javascript">
dojo.addOnLoad(function(){
	dojo.require("dojo.widget.*");
	dojo.require("dojo.widget.DatePicker");
	dojo.require("dojo.widget.PopupContainer");
});
	
function validateForm(formObj) {
	return (1 == 1
		<cfloop index="colNum" from="1" to="#ArrayLen(Request.Table.ColumnOrder)#">
			<cfset Column = Request.Table.Columns[Request.Table.ColumnOrder[colNum]]>
			<cfif Column.Search>
				<cfswitch expression="#Column.Type#">
					<cfcase value="Integer">
						&& checkNumber(formObj.elements["#Column.Name#"],"#Column.DispName#")
						&& checkNumber(formObj.elements["#Column.Name#_end"],"#Column.DispName#")
					</cfcase>
					<cfcase value="Pseudo">
						&& checkNumber(formObj.elements["#Column.Name#"],"#Column.DispName#")
						&& checkNumber(formObj.elements["#Column.Name#_end"],"#Column.DispName#")
					</cfcase>
					<cfcase value="Date">
						&& checkDate(formObj.elements["#Column.Name#"],"#Column.DispName#")
						&& checkDate(formObj.elements["#Column.Name#_end"],"#Column.DispName#")
					</cfcase>
				</cfswitch>
			</cfif>
		</cfloop>
	)
}
</script>
<FORM ACTION="#cgi.script_name#?#Request.Table.persistentParams#" METHOD=POST NAME="f1" ONSUBMIT="return validateForm(this)">
<INPUT TYPE="HIDDEN" NAME="Searching" VALUE="1">
<INPUT TYPE="HIDDEN" NAME="action" VALUE="View">
</cfoutput>

<TABLE CLASS=ADDTABLE CELLPADDING=5 CELLSPACING=0>
<TR>
	<TD COLSPAN=2 ALIGN=RIGHT>
		<INPUT TYPE="SUBMIT" VALUE="Search" class=button>
		<INPUT TYPE="RESET" VALUE="Reset Form" class=button>
	</TD>
</TR>

<cfloop index="colNum" from="1" to="#ArrayLen(Request.Table.ColumnOrder)#">
	<cfset Column = Request.Table.Columns[Request.Table.ColumnOrder[colNum]]>
	<cfif Column.Search and Not Column.Hidden>

		<cfif Column.Type is "ChildTable">
			<!--- Close previous column group --->
			<cfif Len(Request.Table.CurrentColumnGroup) gt 0></tbody></cfif>
			<!--- Open new column group --->
			<cfset Request.Table.CurrentColumnGroup = Column.Name>
			<tbody class="columngroup" id="#Column.Name#_Group">
			<tr class="columngroup"><td colspan=2><h2><cfoutput>#Column.DispName#</cfoutput></h2></td></tr>
			<cfoutput>#displaySearchField(Column)#</cfoutput>
		<cfelse>
			<!--- Column Groups --->
			<cfif Column.ColumnGroup is not Request.Table.CurrentColumnGroup>
				<cfif Len(Request.Table.currentColumnGroup) gt 0>
					</tbody>
					<cfset Request.Table.CurrentColumnGroup = "">
				</cfif>
				<cfif Len(Column.ColumnGroup) gt 0>
					<tbody class="columngroup" id="#Column.ColumnGroup#_Group">
					<tr class="columngroup"><td colspan=2><h2><cfoutput>#Request.Table.ColumnGroups[Column.ColumnGroup].Label#</cfoutput></h2></td></tr>
					<cfset Request.Table.CurrentColumnGroup = Column.ColumnGroup>
				</cfif>
			</cfif>
	
			<cfoutput>
			<TR id="#Column.Name#_TR">
				<TD CLASS=SEARCHLABELCELL SCOPE=row><LABEL FOR="#Column.Name#">#Column.DispName#</LABEL></TD>
				<TD CLASS=SEARCHFIELDCELL>#displaySearchField(Column)#</TD>
			</TR> 
			</cfoutput>
		</cfif>
	</cfif>
</cfloop>
<cfif Len(Request.Table.currentColumnGroup) gt 0>
	</tbody>
</cfif>

<TR>
	<TD COLSPAN=2 ALIGN=RIGHT>
		<INPUT TYPE="SUBMIT" VALUE="Search" class=button>
		<INPUT TYPE="RESET" VALUE="Reset Form" class=button>
	</TD>
</TR>
</TABLE>
</FORM>

<script type="text/javascript">
//Mark last rows in groups.
var groups = document.getElementsByTagName("TBODY");
var children;
for (var i = 0; i < groups.length; i ++) {
	if (groups[i].className == "columngroup") {
		children = groups[i].childNodes;
		for (var j = children.length-1; j > -1; j--) {
			if (children[j].tagName == "TR") {
				children[j].className = "lastrowingroup";
				break;
			}
		}
	}
}
</script>
