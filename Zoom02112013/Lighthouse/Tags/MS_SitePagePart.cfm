<cfinclude template="../Functions/LighthouseLib.cfm">
<cfscript>
if (Not StructKeyExists(attributes,"class")) attributes.class = "body";
if (Not StructKeyExists(attributes,"style")) attributes.style = "";
if (Not StructKeyExists(attributes,"title")) attributes.title = attributes.id;
if (Not StructKeyExists(attributes,"type")) attributes.type = "Text";

// Get value
if (StructKeyExists(caller.pageParts, attributes.id)) {
	value = caller.pageParts[attributes.id];
} else {
	value = "";
}

//Set attributes specific to editing
if (caller.edit) {
	if (Not StructKeyExists(attributes,"default")) attributes.default = "";
	if (Not StructKeyExists(attributes,"required")) attributes.required = false;
	if (value is "") value = attributes.default;
}

displayValue = value;;
// Set display value
switch (attributes.Type) {
	case "Date": {
		if (value is not "" and IsDefined("attributes.format")) {
			displayValue = DateFormat(value,attributes.format);
		}
		break;
	}
}
</cfscript>

<cfoutput>
<cfif caller.edit>
	<input id="#attributes.id#" type="hidden" name="editableAreaInput" value="">
	<cfswitch expression="#attributes.type#">
		<cfcase value="Text">
			<div id="#attributes.id#_workArea" style="visibility:hidden;position:absolute">#displayValue#</div>
			<cfif browserSupportsMSHtml()>
				<div contenteditable id=#attributes.id#_editArea
					oncontextmenu="return htmlFields['#attributes.id#'].showContextMenu()"
					onkeyup="if (top.htmlToolbars['main']) {top.htmlToolbars['main'].setCurrentStyle()}"
					onclick="if (top.htmlToolbars['main']) {top.htmlToolbars['main'].setCurrentStyle()}"
					onfocus="if (top.htmlToolbars['main']) {top.htmlToolbars['main'].htmlField = htmlFields['#attributes.id#']; htmlFields['#attributes.id#'].htmlToolbar = top.htmlToolbars['main'];}"
					onblur="htmlFields['#attributes.id#'].saveContents()"
					class="#attributes.class# editable"
					style="#attributes.style#"
					title="#attributes.title#"
					></div>
				<script type="text/javascript">
				htmlFields['#attributes.id#'] = new top.htmlField("inline",window,"#attributes.id#",null)
				</script>
			<cfelse>
				<iframe id="#attributes.id#_editArea" 
					src="#Request.AppVirtualPath#/Lighthouse/Resources/wysiwyg.html" 
					class="#attributes.class# editable" 
					title="#attributes.title#" 
					scrolling="no"></iframe>
				<script type="text/javascript">
				htmlFieldClasses['#attributes.id#'] = "#attributes.class#";
				xAddEvent(window,"load",wysiwygInit);
				</script>
			</cfif>
		</cfcase>
		<cfcase value="Date">
			<div class="#attributes.class#" style="#attributes.style#" title="#attributes.title#">
				<span id="#attributes.id#_editArea">#displayValue#</span>
				<img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/toolbar/pageproperties.gif" width=19 height=19 alt="Edit" onclick="#attributes.id#_editField()" style="cursor:pointer">
			</div>
			<script type="text/javascript">
			document.getElementById("#attributes.id#").value = "#JSStringFormat(value)#";
			function #attributes.id#_editField() {
				var url = "#Request.AppVirtualPath#/Lighthouse/Resources/dialogs/field.cfm";
				url += "?ColName=#UrlEncodedFormat(attributes.id)#";
				url += "&DispName=#UrlEncodedFormat(attributes.title)#";
				url += "&Type=#UrlEncodedFormat(attributes.type)#";
				url += "&format=#UrlEncodedFormat(attributes.format)#";
				url += "&value=" + escape(document.getElementById("#attributes.id#").value);
				url += "&resourcesDir=#Request.AppVirtualPath#/Lighthouse/Resources";
				fieldDialog = popupDialog("editField",500,400,null,url);
			}
			</script>
		</cfcase>
	</cfswitch>
<cfelse>
	<div class="#attributes.class# pagepart" style="#attributes.style#">
		<cfif StructKeyExists(url,"s")>#HighlightKeywords(displayValue,url.s)#<cfelse>#displayValue#</cfif>
	</div>
</cfif>
</cfoutput>