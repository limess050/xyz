<!---
File Name: 	MS_TableAddEdit.cfm
Author: 	David Hammond
Description:

Inputs:
--->
<cfset Column = attributes.Column>
<cfoutput>
<cfif Column.Required and Column.Editable>*&nbsp;</cfif><cfif
Len(Column.HelpText)><span class="HELPBUTTONUP" 
	onclick="javascript:showHide(getEl('#Column.Name#_HELP'),null,'rightOfElement',this);if (this.className == 'HELPBUTTONUP') { this.className = 'HELPBUTTONDOWN'; } else { this.className = 'HELPBUTTONUP'; } return true;">?</span><div
	id="#Column.Name#_HELP" class=HELPTEXT style="visibility:hidden">#Column.HelpText#</DIV>&nbsp;</cfif><label for="#Column.Name#">#Column.DispName#:</label>
</cfoutput>