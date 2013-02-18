<!---
File Name: 	MS_HTMLEdit.cfm
Author: 	David Hammond
Description:

--->

<cfscript>
if (Not IsDefined("attributes.DispName")) 		attributes.DispName="#attributes.FieldName#";
if (Not IsDefined("attributes.toolbars")) 		attributes.toolbars="Main,Tables";
if (Not IsDefined("attributes.imageDir")) 		attributes.imageDir="";
if (Not IsDefined("attributes.spellCheck")) 	attributes.spellCheck=false;
if (Not IsDefined("attributes.siteEditor")) 	attributes.siteEditor=false;

tdstyle="CLASS=TOOLBARBUTTONUP NOWRAP ONMOUSEOVER=""this.className='TOOLBARBUTTONMOUSEOVER'"" ONMOUSEOUT=""this.className='TOOLBARBUTTONUP'"" ONMOUSEDOWN=""this.className='TOOLBARBUTTONDOWN'"" ONMOUSEUP=""if (this.className=='TOOLBARBUTTONMOUSEOVER') this.className='TOOLBARBUTTONUP'; else this.className='TOOLBARBUTTONMOUSEOVER'""";
</cfscript>

<cfoutput>
<cfif ListFindNoCase(attributes.toolbars,"Main")>
	<table border="1" cellspacing="0" cellpadding="0" CLASS=TOOLBARTABLE width="100%">
	<tr align=center>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/cut.gif" width=23 height=23 alt="Cut" title="Cut"						 								onclick="htmlToolbars['#attributes.FieldName#'].doEdit('cut');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/copy.gif" width=23 height=23 alt="Copy" title="Copy"													onclick="htmlToolbars['#attributes.FieldName#'].doEdit('copy');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/paste.gif" width=23 height=23 alt="Paste" title="Paste"												onclick="htmlToolbars['#attributes.FieldName#'].doEdit('paste');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/undo.gif" width=23 height=23 alt="Undo" title="Undo"													onclick="htmlToolbars['#attributes.FieldName#'].doEdit('Undo');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/redo.gif" width=23 height=23 alt="Redo" title="Redo"													onclick="htmlToolbars['#attributes.FieldName#'].doEdit('Redo');" unselectable="on"></td>

		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/createLink.gif" width=23 height=23 alt="Create Link" title="Create Link"								onclick="htmlToolbars['#attributes.FieldName#'].dialog('link',<cfif attributes.siteEditor>true<cfelse>false</cfif><cfif Len(attributes.imageDir) gt 0>,'#attributes.imageDir#'</cfif>)" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/removeLink.gif" width=23 height=23 alt="Remove Link" title="Remove Link"								onclick="htmlToolbars['#attributes.FieldName#'].doEdit('Unlink');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/createBookmark.gif" width=23 height=23 alt="Create Bookmark" title="Create Bookmark"					onclick="htmlToolbars['#attributes.FieldName#'].dialog('anchor')" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/bold.gif" width=23 height=23 alt="Bold" title="Bold"													onclick="htmlToolbars['#attributes.FieldName#'].doEdit('Bold');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/italic.gif" width=23 height=23 alt="Italic" title="Italic"												onclick="htmlToolbars['#attributes.FieldName#'].doEdit('Italic');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/underline.gif" width=23 height=23 alt="Underline" title="Underline"						  			onclick="htmlToolbars['#attributes.FieldName#'].doEdit('Underline');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/superscript.gif" width=23 height=23 alt="SuperScript" title="SuperScript"					 	 		onclick="htmlToolbars['#attributes.FieldName#'].doEdit('SuperScript');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/subscript.gif" width=23 height=23 alt="SubScript" title="SubScript"						  			onclick="htmlToolbars['#attributes.FieldName#'].doEdit('SubScript');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/inserthr.gif" width=23 height=23 alt="Insert Horizontal Rule" title="Insert Horizontal Rule"				onclick="htmlToolbars['#attributes.FieldName#'].doEdit('InsertHorizontalRule');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/insertOrderedList.gif" width=23 height=23 alt="Insert Ordered List" title="Insert Ordered List"		onclick="htmlToolbars['#attributes.FieldName#'].doEdit('InsertOrderedList');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/insertUnorderedList.gif" width=23 height=23 alt="Insert Unordered List" title="Insert Unordered List"	onclick="htmlToolbars['#attributes.FieldName#'].doEdit('InsertUnorderedList');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/outdent.gif" width=23 height=23 alt="Outdent" title="Outdent"					 						onclick="htmlToolbars['#attributes.FieldName#'].doEdit('Outdent');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/indent.gif" width=23 height=23 alt="Indent" title="Indent"												onclick="htmlToolbars['#attributes.FieldName#'].doEdit('Indent');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/justifyleft.gif" width=23 height=23 alt="Justify Left" title="Justify Left"							onclick="htmlToolbars['#attributes.FieldName#'].doEdit('JustifyLeft');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/justifyright.gif" width=23 height=23 alt="Justify Right" title="Justify Right"							onclick="htmlToolbars['#attributes.FieldName#'].doEdit('JustifyRight');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/justifycenter.gif" width=23 height=23 alt="Justify Center" title="Justify Center"						onclick="htmlToolbars['#attributes.FieldName#'].doEdit('JustifyCenter');" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/justifyfull.gif" width=23 height=23 alt="Justify Full" title="Justify Full"							onclick="htmlToolbars['#attributes.FieldName#'].doEdit('JustifyFull');" unselectable="on"></td>
		<cfif Len(attributes.imageDir) gt 0>
			<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/insertImage.gif" width=23 height=23 alt="Insert Image" title="Insert Image"						onclick="htmlToolbars['#attributes.FieldName#'].dialog('img',false,'#attributes.imageDir#');" unselectable="on"></td>
		</cfif>
	</tr>
	</table>
</cfif>
<cfif ListFindNoCase(attributes.toolbars,"Tables")>
	<table border="1" cellspacing="0" cellpadding="0" CLASS=TOOLBARTABLE width="100%">
	<tr align=center>
		<td #tdstyle# id="#attributes.FieldName#_showStylesMenuButton"><img src="#attributes.resourcesDir#/images/toolbar/class.gif" width=23 height=23 alt="Styles" title="Styles"	onclick="htmlToolbars['#attributes.FieldName#'].showStylesMenu();" unselectable="on"></td>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/removeFormatting.gif" width=23 height=23 alt="Remove All Styles" title="Remove All Styles"					onclick="htmlToolbars['#attributes.FieldName#'].doEdit('RemoveFormatting')" unselectable="on"></td>
		<td class=TOOLBARDIVIDER><img src=#attributes.resourcesDir#/images/spacer.gif width=1 height=1></TD>
		<cfif ListFindNoCase(attributes.toolbars,"Tables")>
			<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/createTable.gif" width=23 height=23 alt="Create Table" title="Create Table" 							onclick="htmlToolbars['#attributes.FieldName#'].dialog('tableCreate')" unselectable="on"></td>
			<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/tableProperties.gif" width=23 height=23 alt="Table Properties" title="Table Properties" 				onclick="htmlToolbars['#attributes.FieldName#'].dialog('table')" unselectable="on"></td>
			<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/rowProperties.gif" width=23 height=23 alt="Row Properties" title="Row Properties" 						onclick="htmlToolbars['#attributes.FieldName#'].dialog('tr')" unselectable="on"></td>
			<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/cellProperties.gif" width=23 height=23 alt="Cell Properties" title="Cell Properties" 					onclick="htmlToolbars['#attributes.FieldName#'].dialog('td')" unselectable="on"></td>
			<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/insertRowAbove.gif" width=23 height=23 alt="Insert Row Above" title="Insert Row Above" 				onclick="top.tableInsertRow(htmlToolbars['#attributes.FieldName#'],0)" unselectable="on"></td>
			<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/insertRowBelow.gif" width=23 height=23 alt="Insert Row Below" title="Insert Row Below" 				onclick="top.tableInsertRow(htmlToolbars['#attributes.FieldName#'],1)" unselectable="on"></td>
			<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/deleteRow.gif" width=23 height=23 alt="Delete Row" title="Delete Row" 									onclick="top.tableDeleteRow(htmlToolbars['#attributes.FieldName#'])" unselectable="on"></td>
			<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/insertColumnBefore.gif" width=23 height=23 alt="Insert Column Before" title="Insert Column Before" 	onclick="top.tableInsertColumn(htmlToolbars['#attributes.FieldName#'],0)" unselectable="on"></td>
			<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/insertColumnAfter.gif" width=23 height=23 alt="Insert Column After" title="Insert Column After" 		onclick="top.tableInsertColumn(htmlToolbars['#attributes.FieldName#'],1)" unselectable="on"></td>
			<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/deleteColumn.gif" width=23 height=23 alt="Delete Column" title="Delete Column" 						onclick="top.tableDeleteColumn(htmlToolbars['#attributes.FieldName#'])" unselectable="on"></td>
			<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/increaseColumnSpan.gif" width=23 height=23 alt="Increase Column Span" title="Increase Column Span" 	onclick="top.tableIncreaseColSpan(htmlToolbars['#attributes.FieldName#'])" unselectable="on"></td>
			<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/decreaseColumnSpan.gif" width=23 height=23 alt="Decrease Column Span" title="Decrease Column Span" 	onclick="top.tableDecreaseColSpan(htmlToolbars['#attributes.FieldName#'])" unselectable="on"></td>
			<!---
			<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/increaseRowSpan.gif" width=23 height=23 alt="Increase Row Span" title="Increase Row Span" onclick="top.tableIncreaseRowSpan(htmlToolbars['#attributes.FieldName#'])" unselectable="on"></td>
			<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/decreaseRowSpan.gif" width=23 height=23 alt="Decrease Row Span" title="Decrease Row Span" onclick="top.tableDecreaseRowSpan(htmlToolbars['#attributes.FieldName#'])" unselectable="on"></td>
			--->
			<td class=TOOLBARDIVIDER><img src="#attributes.resourcesDir#/images/spacer.gif" width=1 height=1></TD>
		</cfif>
		<cfif attributes.spellcheck>
			<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/spellcheck.gif" width=23 height=23 alt="Spell Check" title="Spell Check"		  						onclick="htmlToolbars['#attributes.FieldName#'].dialog('spellCheck')" unselectable="on"></td>
		</cfif>
		<td #tdstyle#><img src="#attributes.resourcesDir#/images/toolbar/code.gif" width=38 height=23 alt="Edit HTML" title="Edit HTML"												onclick="htmlToolbars['#attributes.FieldName#'].dialog('editHtml')" unselectable="on"></td>
		</tr>
	</table>
</cfif>
<script>
// create toolbar object
htmlToolbars['#attributes.FieldName#'] = new top.htmlToolbar(window,"#attributes.fieldName#");
</script>
</cfoutput>