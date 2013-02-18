<cfparam name="fieldName" default="">
<html>
<head>
	<title>it works</title>
	<script>
		function transpose() {
			<cfoutput>checkStr = parent.opener.#jsvar#;</cfoutput>

			// Replace character entities with actual characters.
			checkStr = checkStr.replace(/&lt;/,"<");
			checkStr = checkStr.replace(/&gt;/,">");

			document.SpellCheckForm.spellCheckContent.value = checkStr;
			document.SpellCheckForm.submit();
		}

	</script>
</head>
<body onload="transpose()">

<span id="checkerStatus" style="color:red; font-family:verdana; font-size:10px;">
&nbsp;&nbsp;Checking Spelling <cfif len(fieldName)>for <cfoutput>#fieldName#</cfoutput></cfif>...
</span>
</font>

<form name="SpellCheckForm" style="visibility:hidden;" action="spell.cfm" method="post" target="topframe">
	<textarea name="spellCheckContent" style="visibility:hidden;"></textarea>
	<cfoutput><input type="hidden" name="jsvar" value="#jsvar#"></cfoutput>
</form>

</body>
</html>