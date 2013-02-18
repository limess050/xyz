<!---
File Name: 	/includes/MS_TableDisplayOptions.cfm
Author: 	David Hammond
Description:
	Select columns to display
Inputs:
	allColumns (required) all available columns
	defaultColumns (opt)
	columns (required) columns currently selected
	actionURL (required)
--->

<cfif StructKeyExists(form,"formSubmitted")>
	<cfset redirectUrl = "#cgi.script_name#?action=View&#Request.Table.persistentParams#&#queryParams#">
	<cfif StructKeyExists(form,"remember")>
		<cfset Application.Lighthouse.lh_setClientInfo("dispColumns_#Request.Table.ID#",form.lh_ViewColumns)>
		<cfset Application.Lighthouse.lh_setClientInfo("maxRows_#Request.Table.ID#",form.MaxRows)>
		<cfset Application.Lighthouse.lh_setClientInfo("columnOrder_#Request.Table.ID#",form.lh_ColumnOrder)>
		<cflocation URL="#redirectUrl#">
	<cfelse>
		<cfset redirectUrl = Application.Lighthouse.RemoveQueryParam(redirectUrl,"lh_TempView") & "&lh_TempView=1">
		<cfset redirectUrl = Application.Lighthouse.RemoveQueryParam(redirectUrl,"lh_PersistentParams") & "&lh_PersistentParams=lh_TempView,lh_ViewColumns,lh_MaxRows,lh_ColumnOrder">
		<cfset redirectUrl = Application.Lighthouse.RemoveQueryParam(redirectUrl,"lh_ViewColumns") & "&lh_ViewColumns=#UrlEncodedFormat(form.lh_ViewColumns)#">
		<cfset redirectUrl = Application.Lighthouse.RemoveQueryParam(redirectUrl,"lh_MaxRows") & "&lh_MaxRows=#UrlEncodedFormat(form.MaxRows)#">
		<cfset redirectUrl = Application.Lighthouse.RemoveQueryParam(redirectUrl,"lh_ColumnOrder") & "&lh_ColumnOrder=#UrlEncodedFormat(form.lh_ColumnOrder)#">
		<cflocation URL="#redirectUrl#">
	</cfif>
</cfif>

<cfset allColumns = ArrayToList(Request.Table.ColumnOrder)>
<cfset defaultColumns = "">

<cfloop index="i" from="1" to="#ArrayLen(Request.Table.columnOrder)#">
	<cfif Request.Table.Columns[Request.Table.ColumnOrder[i]].DefaultView>
		<cfset defaultColumns = ListAppend(defaultColumns,Request.Table.ColumnOrder[i])>
	</cfif>
</cfloop>

<cfif StructKeyExists(url,"lh_TempView") and StructKeyExists(url,"lh_ViewColumns")>
	<cfset displayedColumns = url.lh_ViewColumns>
<cfelse>
	<cfset displayedColumns = Application.Lighthouse.lh_getClientInfo("dispColumns_#Request.Table.table#")>
	<cfif displayedColumns is "">
		<cfset displayedColumns = defaultColumns>
	</cfif>
</cfif>

<cfif StructKeyExists(url,"lh_TempView") and StructKeyExists(url,"lh_MaxRows")>
	<cfset maxRows = url.lh_MaxRows>
<cfelse>
	<cfset maxRows = Application.Lighthouse.lh_getClientInfo("maxRows_#Request.Table.table#","15")>
</cfif>

<cfif StructKeyExists(url,"lh_TempView") and StructKeyExists(url,"lh_ColumnOrder")>
	<cfset columnOrderList = url.lh_ColumnOrder>
<cfelse>
	<cfset columnOrderList = Application.Lighthouse.lh_getClientInfo("columnOrder_#Request.Table.table#",allColumns)>
</cfif>

<cfoutput>
<script>
function setCols(colList) {
	selectObj = document.forms[0].lh_ViewColumns;
	defaultColumns = "," + colList + ",";
	for (var i = selectObj.length - 1; i >= 0; i --) {
		if (defaultColumns.indexOf("," + selectObj.options[i].value + ",") > -1) {
			selectObj.options[i].selected = true;
		} else {
			selectObj.options[i].selected = false;
		}
	}
}
function validateForm(formObj) {
	return (1 == 1
		&& checkSelected(formObj.elements["lh_ViewColumns"],"Columns to display")
		&& checkText(formObj.elements["maxRows"],"Number of rows per page")
		&& checkNumber(formObj.elements["maxRows"],"Number of rows per page")
	)
}
function setDefaultOrder() {
	<cfset i = 0>
	<cfloop index="colNum" from="1" to="#ArrayLen(Request.Table.ColumnOrder)#">
		<cfset Column = Request.Table.Columns[Request.Table.ColumnOrder[colNum]]>
		<cfif Not Column.Hidden>
			document.f1.lh_ColumnOrder.options[#i#].value = '#Column.Name#';
			document.f1.lh_ColumnOrder.options[#i#].text = '#Column.DispName#';
			<cfset i = i + 1>
		</cfif>
	</cfloop>
}
</script>
<FORM NAME="f1" ACTION="#cgi.script_name#?action=DisplayOptions&#Request.Table.persistentParams#&#queryParams#" METHOD=POST ONSUBMIT="selectAll(this.lh_ColumnOrder);return validateForm(this)">
<TABLE>
<TR VALIGN=TOP>
	<TD>
		<B>Select Columns <BR>to Display:<br></B>
		<SELECT id="lh_ViewColumns" name="lh_ViewColumns" size="#Min(20,ArrayLen(Request.Table.ColumnOrder))#" multiple>
		<cfloop index="colNum" from="1" to="#ArrayLen(Request.Table.ColumnOrder)#">
			<cfset Column = Request.Table.Columns[Request.Table.ColumnOrder[colNum]]>
			<cfif Not Column.Hidden and Column.AllowView>
				<OPTION VALUE="#Column.Name#" <cfif ListFind(displayedColumns,Column.Name)>SELECTED</cfif>>#Column.DispName#
			</cfif>
		</cfloop>
		</SELECT>
		<SPAN CLASS=SMALLTEXT>
		<br><font size="1">Hold down the Ctrl key to<br>select more than one item.</font>
		<cfif Len(defaultColumns)>
			<BR><A HREF="javascript:setCols('#defaultColumns#')">Set to Default Columns</A>
		</cfif>
		<BR><A HREF="javascript:sortOptions(getEl('lh_ViewColumns'))">Sort Columns Alphabetically</A>
		</SPAN>
	</TD>
	<TD>&nbsp;</TD>
	<TD>
		<p>
		<B>Number of Rows<BR>Displayed Per Page:</B></p>
		<p>
		<INPUT TYPE="TEXT" NAME="maxRows" VALUE="#maxRows#" SIZE=5><BR>
		<SPAN CLASS=SMALLTEXT>Enter 0 to show all rows</SPAN>
		</p>
		<input id="remember" type="checkbox" name="remember" <cfif Not StructKeyExists(url,"lh_TempView")>checked="true"</cfif>>
		<label for="remember">Remember my display preferences.</label>
		<p>
		<input type="hidden" name="formSubmitted" value="1">
		<INPUT TYPE="SUBMIT" VALUE="Submit">
		<INPUT TYPE="Reset" VALUE="Reset">
		</p>
	</TD>
	<TD>&nbsp;</TD>
	<TD>
		<B>Set column<br>order:<br></B>
		<SELECT name="lh_ColumnOrder" size="#Min(20,ArrayLen(Request.Table.ColumnOrder))#" multiple>
		<cfloop index="col" list="#columnOrderList#">
			<cfif StructKeyExists(Request.Table.Columns,col)>
				<cfif Not Request.Table.Columns[col].Hidden and Request.Table.Columns[col].AllowView>
					<cfset index = ListFind(allColumns,col)>
					<cfif index gt 0>
						<cfset allColumns = ListDeleteAt(allColumns,index)>
						<OPTION VALUE="#col#">#Request.Table.Columns[col].DispName#
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		<cfloop index="col" list="#allColumns#">
			<cfif Not Request.Table.Columns[col].Hidden>
				<OPTION VALUE="#col#">#Request.Table.Columns[col].DispName#
			</cfif>
		</cfloop>
		</SELECT>
		<SPAN CLASS=SMALLTEXT>
		<BR><A HREF="javascript:setDefaultOrder()">Set to Default Order</A>
		</SPAN>
	</TD>
	<TD ALIGN="CENTER" VALIGN="MIDDLE">
		<IMG SRC="#Request.Table.resourcesDir#/images/moveup.gif" ALT="Move Up" onClick="moveUp(document.f1.lh_ColumnOrder)" STYLE="cursor:hand;">
		<BR>
		<IMG SRC="#Request.Table.resourcesDir#/images/movedown.gif" ALT="Move Down" onClick="moveDown(document.f1.lh_ColumnOrder)" STYLE="cursor:hand;">
	</TD>
</TR>
</TABLE>
</FORM>
</cfoutput>