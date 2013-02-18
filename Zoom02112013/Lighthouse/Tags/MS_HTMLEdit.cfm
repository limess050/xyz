<!---
File Name: 	MS_HTMLEdit.cfm
Author: 	David Hammond
Description:

--->

<!---
Attributes
Required: colName
Required: resourcesDir
// validate
--->
<cfinclude template="../Functions/LighthouseLib.cfm">
<cfparam name="attributes.htmlEditor" default="">
<cfparam name="attributes.htmlEditorParameters" default="">

<!--- Parse parameters --->
<cfif attributes.htmlEditorParameters is not "">
	<cfloop list="#attributes.htmlEditorParameters#" index="nameValue" delimiters="&">
		<cfset name = "#ListGetAt(nameValue, 1, "=")#">
		<cfset value = "#UrlDecode(ListGetAt(nameValue, 2, "="))#">
		<cfset foo = SetVariable(name,value)>
	</cfloop>
</cfif>

<cfparam name="attributes.DispName" default="#attributes.FieldName#">
<cfparam name="attributes.toolbars" default="Main,Tables">
<cfparam name="attributes.imageDir" default="">
<cfparam name="attributes.spellCheck" default="false">
<cfparam name="attributes.siteEditor" default="false">
<cfparam name="attributes.Value" default="">
<cfparam name="attributes.Style" default="">
<cfparam name="attributes.ClassName" default="">
<cfparam name="attributes.Stylesheet" default="css/MSStandard.css">

<cfswitch expression="#attributes.htmlEditor#">

	<cfcase value="fckeditor">
		<cfmodule
			template="../..#path#/fckeditor.cfm"
			basePath="#path#/"
			instanceName="#attributes.FieldName#"
			value="#attributes.value#"
			width="550"
			height="300">
	</cfcase>

	<cfcase value="xstandard">

		<cfoutput>
		<script type="text/javascript">
		function #attributes.FieldName#_save() {
			try {
				if(typeof(document.getElementById('editor_#attributes.FieldName#').EscapeUnicode) == 'undefined') {
					throw "Error"
				} else {
					document.getElementById('editor_#attributes.FieldName#').EscapeUnicode = true;

					//strip default xml generated by xstandard so that it doesn't appear to have been entered when it hasn't.
					var xml = document.getElementById('editor_#attributes.FieldName#').value;
					xml = xml.replace(/<!-- Generated by XStandard [^-]+-->(<p>\&\##160\;<\/p>)+/gi,"");
					document.getElementById('#attributes.FieldName#').value = xml;
				}
			}
			catch(er) {
				document.getElementById('#attributes.FieldName#').value = document.getElementById('alternate_#attributes.FieldName#').value;
			}
			return true;
		}
		</script>
		<input id="#attributes.FieldName#" type="hidden" name="#attributes.FieldName#" value="#HTMLEditFormat(attributes.Value)#">
		<object type="application/x-xstandard" id="editor_#attributes.FieldName#" width="500" height="300" onblur="#attributes.FieldName#_save()">
			<param name="Value" value="#HTMLEditFormat(attributes.value)#" />
			<cfif IsDefined("styles")><param name="Styles" value="#styles#" /></cfif>
			<cfif IsDefined("css")><param name="CSS" value="#css#" /></cfif>
			<TEXTAREA NAME="alternate_#attributes.FieldName#" cols=50 rows=6>#HTMLEditFormat(attributes.Value)#</TEXTAREA
			><cfif attributes.spellcheck><BR><A HREF="javascript:spellCheckField('document.f1.alternate_#attributes.FieldName#.value','#attributes.DispName#')" CLASS=SMALLTEXT>Check Spelling</A></cfif>
			<br><a href="http://xstandard.com/" target="_blank">Download XStandard to edit this field with a wysiwyg editor.</a>
		</object>
		</cfoutput>
	</cfcase>

	<cfcase value="htmlArea,xinha">

		<cfoutput>
		<textarea id="#attributes.FieldName#" name="#attributes.FieldName#" cols=80 rows=20 style="width:100%">#HTMLEditFormat(attributes.Value)#</textarea>
		<!-- Configure the path to the editor.  We make it relative now, so that the
			example ZIP file will work anywhere, but please NOTE THAT it's better to
			have it an absolute path, such as '/htmlarea/'. -->
		<script type="text/javascript">
		_editor_url = "#path#/";
		</script>
		<!-- load the main HTMLArea file, this will take care of loading the CSS and other required core scripts. -->
		<script type="text/javascript" src="#path#/htmlarea.js"></script>
		<script type="text/javascript" src="#path#/lang/en.js"></script>
		<script type="text/javascript">
		var editor = null;
		function initEditor() {
			// create an editor for the textbox
			editor = new HTMLArea("#attributes.FieldName#");
			editor.generate();
			return false;
		}
		initEditor();
		</script>
		</cfoutput>

	</cfcase>

	<cfcase value="tinymce">

		<cfoutput>
		<cfparam name="width" default="100%">
		<script type="text/javascript" src="#path#/jscripts/tiny_mce/tiny_mce.js"></script>
		<script type="text/javascript">
			tinyMCE.init({
				<cfif IsDefined("content_css")>content_css : "#content_css#",
				<cfelse>content_css : "#attributes.Stylesheet#",</cfif>
				theme : "advanced",
				mode : "exact",
				elements : "#attributes.FieldName#"
			});
		</script>
		<textarea id="#attributes.FieldName#" name="#attributes.FieldName#" cols=80 rows=20 style="width:#width#" onchange="alert(this.value)">#HTMLEditFormat(attributes.Value)#</textarea>
		</cfoutput>

	</cfcase>

	<cfcase value="tgedit">

		<cfmodule template="../..#path#/tgedit.cfm"
			width=550
			height=300
			field="#attributes.FieldName#"
			form="f1"
			imgpath="#path#/tgimages/"
			complete=false
			editHTML=false
			baseURL="http://modernsignal/"
			html="#attributes.Value#">

	</cfcase>

	<cfdefaultcase>
		<cfoutput>
		<cfif browserSupportsMSHtml() or browserSupportsMidas()>
			<table border="0" cellspacing="0" cellpadding="0"><tr><td colspan=2>
			<cf_MS_HTMLEditToolbar
				FieldName="#attributes.FieldName#"
				ResourcesDir="#attributes.ResourcesDir#"
				DispName="#attributes.DispName#"
				Toolbars="#attributes.toolbars#"
				ImageDir="#attributes.ImageDir#"
				SpellCheck="#attributes.SpellCheck#"
				SiteEditor="#attributes.SiteEditor#">

			<input id="#attributes.FieldName#" type="hidden" name="#attributes.FieldName#">
			<div id="#attributes.FieldName#_workArea" style="visibility:hidden;position:absolute">#attributes.Value#</div>
		</cfif>

		<cfif browserSupportsMSHtml()>
			<div contenteditable
				align="left"
				id="#attributes.FieldName#_editArea"
				class="editable #attributes.ClassName#"
				style="#attributes.style#"
				oncontextmenu="return htmlFields['#attributes.FieldName#'].showContextMenu()"
				onkeyup="htmlToolbars['#attributes.FieldName#'].setCurrentStyle()"
				onclick="htmlToolbars['#attributes.FieldName#'].setCurrentStyle()"
				onfocus="tableSetGuidelines(this);"
				onblur="htmlFields['#attributes.FieldName#'].saveContents()"></div>
			<script type="text/javascript">
			htmlFields['#attributes.FieldName#'] = new htmlField("inline",window,"#attributes.FieldName#",htmlToolbars['#attributes.FieldName#']);
			</script>
		<cfelseif browserSupportsMidas()>
			<iframe 
				src="#attributes.ResourcesDir#/wysiwyg.html?#attributes.Stylesheet#" 
				id="#attributes.FieldName#_editArea" 
				class="editable #attributes.ClassName#"></iframe>
			<script type="text/javascript">
			xAddEvent(window,"load",wysiwygInit);
			</script>
		<cfelse>
			<TEXTAREA NAME="#attributes.FieldName#" ID="#attributes.FieldName#" cols=50 rows=6>#HTMLEditFormat(attributes.Value)#</TEXTAREA
			><cfif attributes.spellcheck><BR><A HREF="javascript:spellCheckField('document.f1.#attributes.FieldName#.value','#attributes.DispName#')" CLASS=SMALLTEXT>Check Spelling</A></cfif>
		</cfif>

		<cfif browserSupportsMSHtml() or browserSupportsMidas()>
			</td></tr></table>
		</cfif>
		</cfoutput>

	</cfdefaultcase>
</cfswitch>