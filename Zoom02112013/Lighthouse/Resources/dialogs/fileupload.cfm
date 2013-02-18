<cfinclude template="../../Admin/checklogin.cfm">

<cfparam name="jsAction" default="">
<cfparam name="getTitle" default="false">
<cfparam name="redirectURL" default="">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<link rel=stylesheet href="../css/MSStandard.css" type="text/css">
<style>
html,body,form {
	margin: 0;
	padding: 0 !important;
	height:100%;
}
</style>
<script type="text/javascript" src="../js/dojo/dojo.js"></script>
<script type="text/javascript" src="../js/library.js"></script>
<script type="text/javascript" src="../js/wysiwyg.js"></script>
<script type="text/javascript"><!--
function validateForm(formObj) {
	return (
		checkText(formObj.elements["file"],"File")
	)
}
//--></script>
<title>File Upload</title>
<body id="dialog">

<cfoutput>
<form action="fileUpload_doit.cfm?jsAction=#jsAction#" method="post" enctype="multipart/form-data" name="f1" onsubmit="return validateForm(this)">
<input type="hidden" name="subDir" value="#subDir#">
<input type="hidden" name="redirectURL" value="#redirectURL#">
<table height=100% width=100% border=0><tr><td align=center valign=middle>
<table cellspacing=0 cellpadding=5>
<tr>
	<td align="right"><b>Select File:</b></td>
	<td><input type="file" name="file"></td>
</tr>
<cfif gettitle>
	<tr>
		<td align="right"><b>Title:</b></td>
		<td><input type="text" size=35 name="title"></td>
	</tr>
</cfif>
<tr>
	<td colspan=2 align=center>
		<input type="submit" value="Submit" class="button">
		<cfif Len(redirectURL) gt 0>
			<input type="button" onclick="window.location='#redirectURL#'" value="Cancel" class="button">
		</cfif>
	</td>
</tr>
</table>
</td></tr></table>
</form>
</cfoutput>

</body>
</html>