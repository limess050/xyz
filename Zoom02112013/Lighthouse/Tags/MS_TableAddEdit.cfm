<!---
File Name: 	MS_TableAddEdit.cfm
Author: 	David Hammond
Description:

Inputs:
--->
<cfoutput>
<script type="text/javascript">
var monitor;
dojo.require("dojo.json");
function onBeforeUnload(){
	if (monitor.isChanged()) {
		var msg = "Your unsaved changes may be lost.\n\nThe following fields have changed:"
		for (var i=0;i<monitor.ChangedFields.length;i++){
			var f =  monitor.ChangedFields[i];
			msg += "\n - " + f.name;
			<!--- msg += "\n Original Value:\n" + f.baseValue;
			msg += "\n Currend Value:\n" + f.currentValue; --->
		}
		return msg;
	}
}
dojo.addOnLoad(function(){
	dojo.require("dojo.widget.*");
	dojo.require("dojo.widget.DatePicker");
	dojo.require("dojo.widget.PopupContainer");
	
	//Set up monitor
	monitor = new lh.ChangeMonitor(function(){
		if (monitor.isChanged()){
			if (getEl("SubmitButton1").value != "Save Changes"){
				getEl("SubmitButton1").value = "Save Changes";
				getEl("SubmitButton2").value = "Save Changes";
			}
		} else {
			if (getEl("SubmitButton1").value != "Submit"){
				getEl("SubmitButton1").value = "Submit";
				getEl("SubmitButton2").value = "Submit";
			}
		}
	});
	mainTable.monitorColumns(monitor);
	//Pause to give wysiwyg a chance to load
	window.setTimeout("monitor.start()",2000);
	window.onbeforeunload = onBeforeUnload;

	//Cancel onbeforeunload when mousing over javascript links.  Otherwise IE shows warning.
	var links = document.getElementsByTagName("A");
	for (var i = 0; i < links.length; i++) {
		if (links[i].href.indexOf("javascript:") == 0) {
			xAddEvent(links[i], "mouseover", cancelOnBeforeUnload);
			xAddEvent(links[i], "mouseout", setOnBeforeUnload);
		}
	}
});


var mainTable = lh.addTable(#Application.Json.encode(Request.Table)#);
mainTable.addRow();

function validateForm(formObj) {
	window.onbeforeunload = null;
	<cfloop index="colNum" from="1" to="#ArrayLen(Request.Table.ColumnOrder)#">
		<cfset Column = Request.Table.Columns[Request.Table.ColumnOrder[colNum]]>
		<cfif Column.Name is not Request.Table.PrimaryKey and Column.Editable>

			<!--- Make sure htmleditor value is copied to field --->
			<cfif Column.Type is "Textarea">
				<cfswitch expression="#Column.HtmlEditor#">
					<cfcase value="xstandard">
						#Column.Name#_save();
					</cfcase>
					<cfcase value="tinymce">
						tinyMCE.triggerSave();
					</cfcase>
				</cfswitch>
			</cfif>

			<cfif Column.Required>
				<cfswitch expression="#Column.Type#">
					<cfcase value="Select">
						if (!checkSelected(formObj.elements["#Column.Name#"],"#Column.DispName#")) return false;
					</cfcase>
					<cfcase value="Radio,checkboxgroup">
						if (!checkChecked(formObj.elements["#Column.Name#"],"#Column.DispName#")) return false;
					</cfcase>
					<cfcase value="File">
						if (!checkFile(formObj,"#Column.Name#","#Column.DispName#")) return false;
					</cfcase>
					<cfcase value="ChildTable">
						<!--- handled by validate function below --->
					</cfcase>
					<cfdefaultcase>
						if (!checkText(formObj.elements["#Column.Name#"],"#Column.DispName#")) return false;
					</cfdefaultcase>
				</cfswitch>
			</cfif>

			<cfif Len(Column.Validate) gt 0>
				if (!#Column.Validate#) return false;
			</cfif>

			<cfswitch expression="#Column.Type#">
				<cfcase value="Textarea">
					<cfif Len(Column.MaxLength)>
						if (!checkLength(formObj.elements["#Column.Name#"],#Column.MaxLength#,"#Column.DispName#")) return false;
					</cfif>
				</cfcase>
				<cfcase value="Integer">
					if (!checkNumber(formObj.elements["#Column.Name#"],"#Column.DispName#")) return false;
				</cfcase>
				<cfcase value="Date">
					<cfif Column.ShowDate>
						if (!checkDate(formObj.elements["#Column.Name#"],"#Column.DispName#")) return false;
					</cfif>
					<cfif Column.ShowTime>
						if (!checkNumber(formObj.elements["#Column.Name#_Hour"],"#Column.DispName# Hour")) return false;
						if (!checkNumber(formObj.elements["#Column.Name#_Minute"],"#Column.DispName# Minute")) return false;
					</cfif>
				</cfcase>
				<cfcase value="childtable">
					if (!mainTable.Tables["#Column.Name#"].validate()) return false;
				</cfcase>
				<cfcase value="File">
					//Check file extension
			        var value = formObj.elements["#Column.Name#"].value;
			        var m = value.match(/^.+\.([a-z0-9]+)$/i);
			        var ext = (m == null ? "" : m[1]);
			        var allowed = "#GetAllowedExtensions()#";
			        if (value.length > 0 && !listFind(allowed, ext)) {
			            alert("The uploaded file has the extension of \"" + ext + "\" which is not allowed.  File extensions that are allowed are: " + allowed)
			            return false;
			        }
				</cfcase>
			</cfswitch>
		</cfif>
	</cfloop>
	return true;
}
function checkFile (formObj,colName,s) {
	var uploadFieldObj = formObj.elements[colName];
	if (isWhitespace(uploadFieldObj.value)) {
		if (formObj.elements[colName + "_OldFile"]) {
			var oldfileFieldObj = formObj.elements[colName + "_OldFile"];
			var deleteCheckbox = formObj.elements[colName + "_Delete"];
			if (isWhitespace(oldfileFieldObj.value) || deleteCheckbox.checked) {
				return warnEmpty (uploadFieldObj, s);
			} else {
				return true;
			}
		}
		return warnEmpty (uploadFieldObj, s);
	}
	return true;
}

<!--- Spell Check functions --->
<cfset i = 0>
var spellCheckFieldsArray = new Array();
<cfset showSpellCheckButton = false>
<cfloop index="colNum" from="1" to="#ArrayLen(Request.Table.ColumnOrder)#">
	<cfset Column = Request.Table.Columns[Request.Table.ColumnOrder[colNum]]>
	<cfif Column.SpellCheck>
		<cfset showSpellCheckButton = true>
		<cfif Column.Type is "Textarea">
			<cfset Application.Lighthouse.getBrowserVersion()>
			<cfif Column.AllowHTML and session.browserName is "MSIE" and session.browserVersion gte 5.5>
				spellCheckFieldsArray[#i#] = new Array("#Column.Name#_editArea.innerHTML","#Column.DispName#","#Column.Name#_editArea");
			<cfelse>
				spellCheckFieldsArray[#i#] = new Array("document.f1.#Column.Name#.value","#Column.DispName#","");
			</cfif>
		<cfelse>
			spellCheckFieldsArray[#i#] = new Array("document.f1.#Column.Name#.value","#Column.DispName#","");
		</cfif>
		<cfset i = i + 1>
	</cfif>
</cfloop>
<cfif showSpellCheckButton>
	var i = -1;
	var checkAll = false;
	var spellCheckWindow;
	function spellCheckField (jsvar,fieldName) {
		var top = (screen.availHeight - 232) / 2;
		var left = (screen.availWidth - 450) / 2;
		spellCheckWindow = window.open("#Request.AppVirtualPath#/Lighthouse/Resources/spellchecker/window.cfm?jsvar=" + jsvar + "&fieldName=" + fieldName, "SpellChecker", "height=242,width=450,top=" + top + ",left=" + left + ",status=no,toolbar=no,menubar=no,location=no");
		spellCheckWindow.focus();
	}
	function spellCheckAll (jsvar) {
		i = -1;
		checkAll = true;
		spellCheckNextField();
	}
	function spellCheckNextField () {
		if (checkAll) {
			if (spellCheckFieldsArray.length > i + 1) {
				i ++;
				// Focus htmledit fields so that onblur will save contents
				if (spellCheckFieldsArray[i][2] != "") {
					document.getElementById(spellCheckFieldsArray[i][2]).focus();
				}
				spellCheckField(spellCheckFieldsArray[i][0],spellCheckFieldsArray[i][1]);
				return true;
			} else { return false; }
		} else { return false; }
	}
</cfif>
</script>
<FORM ACTION="#cgi.script_name#?action=SpellCheck" METHOD="POST" NAME="SpellCheckForm" TARGET="SpellCheck">
<INPUT TYPE="HIDDEN" NAME="string">
<INPUT TYPE="HIDDEN" NAME="fieldObj">
</FORM>

<FORM ACTION="#cgi.script_name#?action=AddEditDoit&#Request.Table.persistentParams#" METHOD="POST" NAME="f1" ONSUBMIT="return validateForm(this)" ENCTYPE="multipart/form-data">
<INPUT TYPE="HIDDEN" NAME="pk" ID="pk" VALUE="#pk#">
<cfif IsDefined("queryParams")><INPUT TYPE="HIDDEN" NAME="queryParams" VALUE="#queryParams#"></cfif>


<cfif Len(ActionStruct.Layout) gt 0>

	<cfinclude template="#ActionStruct.Layout#">

<cfelse>

	<!--- Decide whether to show "Submit & Select" option --->

	<cfset selectOption = false>

	<cfif StructKeyExists(Request.Table.RowActions,"Select")>
		<cfset selectAction = Request.Table.RowActions["Select"]>
		<cfif Len(selectAction.ConditionalParam) gt 0>
			<cfif IsDefined("url.#selectAction.ConditionalParam#")>

				<cfif action is "Edit">
					<script type="text/javascript">
					<!--- Do automatic select --->
					<cfif IsDefined("url.SubmitAndSelectButton")>
						#selectAction.jsfunction#('#pk#','#JSStringFormat(Evaluate(selectAction.DescrColName))#');
						window.close();
					<cfelseif StructKeyExists(url,"statusMessage")>
						<!--- If Submitted and item is already selected, update opener. --->
						<cfif url.statusMessage is "Changes Saved.">
							if (opener.#selectAction.FieldID#_isSelected("#pk#")) {
								#selectAction.jsfunction#("#pk#","#JSStringFormat(Evaluate(selectAction.DescrColName))#");
							}
						</cfif>
					</cfif>

					function markSelectedItems() {
						var selBut = document.getElementById("selButton");
						if (selBut != undefined) {
							if (opener.#selectAction.FieldID#_isSelected(selBut.getAttribute("ROWID"))) {
								markSelectedItem(selBut);
								document.getElementById("SubmitAndSelectButton1").value = "Submit & Close"
								document.getElementById("SubmitAndSelectButton2").value = "Submit & Close"
							} else {
								markUnselectedItem(selBut);
							}
						}
					}
					function markSelectedItem(selBut) {
						selBut.onclick = deselectItem;
						selBut.innerHTML = "Deselect";
					}
					function markUnselectedItem(selBut) {
						selBut.onclick = selectItem;
						selBut.innerHTML = "#selectAction.Label#";
					}
					function selectItem(e) {
						selBut = xGetEventSrcElement(e)
						#selectAction.jsfunction#(selBut.getAttribute("ROWID"),selBut.getAttribute("ROWDESCR"));
						markSelectedItem(selBut);
					}
					function deselectItem(e) {
						selBut = xGetEventSrcElement(e)
						opener.#selectAction.FieldID#_delete(selBut.getAttribute("ROWID"));
						markUnselectedItem(selBut);
					}
					xAddEvent(window,"load",markSelectedItems);
					</script>
				</cfif>

				<!--- Show button --->
				<cfset selectOption = true>
			</cfif>
		</cfif>
	</cfif>

	<TABLE CLASS=ADDTABLE CELLPADDING=5 CELLSPACING=0 ID="MainAdminTable">
	<cfif Request.Table.editable>
		<TR ID="AddEditFormTopButtons">
			<TD CLASS=SMALLTEXT>* Required Field</TD>
			<TD CLASS=SMALLTEXT ALIGN=RIGHT>
				<cfif showSpellCheckButton><INPUT TYPE="Button" VALUE="Check Spelling" ONCLICK="spellCheckAll()" class=button></cfif>
				<INPUT TYPE="SUBMIT" id="SubmitButton1" VALUE="Submit" class=button>
				<cfif selectOption><INPUT TYPE="SUBMIT" id="SubmitAndSelectButton1" NAME="SubmitAndSelectButton" VALUE="Submit & Select" class=button></cfif>
				<INPUT TYPE="RESET" VALUE="Reset Form" class=button>
			</TD>
		</TR>
	</cfif>
	<cfloop index="colNum" from="1" to="#ArrayLen(Request.Table.ColumnOrder)#">
		<cfset Column = Request.Table.Columns[Request.Table.ColumnOrder[colNum]]>
		<cfif Column.Hidden>
			<cfif IsDefined(Column.Name)>
				<INPUT TYPE="HIDDEN" NAME="#Column.Name#" VALUE="#HTMLEditFormat(Evaluate(Column.Name))#">
			</cfif>
		<cfelseif (Request.Table.action is "Add" and (Column.Name is Request.Table.PrimaryKey or Column.Type is "timestamp")) or (Column.Type is "Pseudo" and Not Column.showOnEdit)>
		<cfelse>

			<!--- Column Groups --->
			<cfif Column.ColumnGroup is not Request.Table.CurrentColumnGroup>
				<cfif Len(Request.Table.CurrentColumnGroup) gt 0>
					</tbody>
					<cfset Request.Table.CurrentColumnGroup = "">
				</cfif>
				<cfif Len(Column.ColumnGroup) gt 0>
					<tbody class="columngroup" id="#Column.ColumnGroup#_Group">
					<tr class="columngroup"><td colspan=2><h2>#Request.Table.ColumnGroups[Column.ColumnGroup].Label#</h2></td></tr>
					<cfset Request.Table.CurrentColumnGroup = Column.ColumnGroup>
				</cfif>
			</cfif>

			<!--- Display Column --->
			<TR CLASS=ADDROW ID="#Column.Name#_TR">
				<TD CLASS=ADDLABELCELL>
					<cf_MS_TableDisplay_FieldLabel column="#Column#">
				</TD>
				<TD CLASS=ADDFIELDCELL>
					<cfif Column.Name is Request.Table.PrimaryKey and action is "Edit">
						#pk#
					<cfelse>
						<cf_MS_TableDisplay_Field column="#Column#">
					</cfif>
				</TD>
			</TR>
		</cfif>
	</cfloop>
	<cfif Request.Table.editable>
		<TR ID="AddEditFormBottomButtons">
			<TD CLASS=SMALLTEXT>* Required Field</TD>
			<TD CLASS=SMALLTEXT ALIGN=RIGHT>
				<cfif showSpellCheckButton><INPUT TYPE="Button" VALUE="Check Spelling" ONCLICK="spellCheckAll()" class=button></cfif>
				<INPUT TYPE="SUBMIT" id="SubmitButton2" VALUE="Submit" class=button>
				<cfif selectOption><INPUT TYPE="SUBMIT" id="SubmitAndSelectButton2" NAME="SubmitAndSelectButton" VALUE="Submit & Select" class=button></cfif>
				<INPUT TYPE="RESET" VALUE="Reset Form" class=button>
			</TD>
		</TR>
	</cfif>
	</TABLE>

	<script type="text/javascript">
	//Mark last rows in groups.

	var groups = document.getElementsByTagName("TBODY");
	var children;
	for (var i = 0; i < groups.length; i ++) {
		if (groups[i].className == "columngroup") {
			children = groups[i].childNodes;
			for (var j = children.length-1; j > -1; j--) {
				if (children[j].tagName == "TR") {
					children[j].className = "ADDROW lastrowingroup";
					break;
				}
			}
		}
	}
	</script>

</cfif>

</FORM>

</cfoutput>