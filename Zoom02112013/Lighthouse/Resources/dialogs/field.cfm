<cfscript>
Column = StructNew();
Column.Name = colName;
Column.DispName = dispName;
Column.Type = type;
Column.Format = format;
Column.Editable = true;
Column.FormFieldParameters = "";
Column.ShowDate = true;
Column.ShowTime = false;
MS_Table = StructNew();
</cfscript>

<html>
<cfif IsDefined("form.colName")>
	<cfscript>
	value = Evaluate(Column.Name);
	displayValue = value;
	switch (Column.Type) {
		case "Date": {
			if (value is not "" and Column.format is not "") {
				displayValue = DateFormat(value,Column.format);
			}
			break;
		}
	}
	</cfscript>
	<head>
	<script type="text/javascript">
	<cfoutput>
	opener.document.getElementById("#Column.Name#").value = "#JSStringFormat(value)#";
	opener.document.getElementById("#Column.Name#_editArea").innerHTML = "#JSStringFormat(displayValue)#";
	</cfoutput>
	window.close();
	</script>
	</head>
	<body></body>

<cfelse>

	<cfoutput>
	<head>
	<title>Edit #Column.DispName#</title>
	<script type="text/javascript" src="../../dojo/dojo.js"></script>
	<script type="text/javascript" src="../js/library.js"></script>
	<script type="text/javascript" src="../js/wysiwyg.js"></script>
	<link rel=stylesheet href="../css/MSStandard.css" type="text/css">
	</head>
	<body>

	<form name="f1" method="post">
	<input type="hidden" name="colName" value="#Column.Name#">
	<input type="hidden" name="dispName" value="#Column.DispName#">
	<input type="hidden" name="type" value="#Column.type#">
	<input type="hidden" name="format" value="#Column.format#">

	<p class="PAGETITLE">Edit #Column.DispName#</p>

	<p><cfmodule template="../../Tags/MS_TableDisplay_Field.cfm" column="#Column#" value="#url.value#"></p>

	<p>
	<input type="submit" value="OK">
	<input type="button" value="Cancel" onclick="window.close()">
	</p>

	</form>
	</body>
	</cfoutput>
</cfif>
</html>
