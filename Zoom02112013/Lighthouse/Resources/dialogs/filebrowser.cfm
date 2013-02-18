<cfinclude template="../../Admin/checklogin.cfm">

<!--- <cfparam name="uploadDir" default=""> --->
<cfset uploadDir = Request.MCFUploadsDir>
<cfparam name="subDir" default="">
<cfparam name="action" default="">
<cfparam name="statusMessage" default="">
<cfif Left(uploadDir,1) is "/">
	<cfset theDir = Right(uploadDir,Len(uploadDir)-1)>
<cfelse>
	<cfset theDir = uploadDir>
</cfif>
<cfset theDir = theDir & subDir>
<cfset directory = ExpandPath(getBaseRelativePath() & theDir)>

<cfif action is "Delete">
	<cfset filePath = "#directory#/#fileName#">
	<cfif fileExists(filePath)><cffile action="delete" file="#filePath#"></cfif>
<cfelseif action is "CreateDir">
	<cfset dir = "#directory#/#REReplace(dirName,"[^[:alnum:]]","_","ALL")#">
	<cfif Not DirectoryExists(dir)><cfdirectory action="create" directory="#dir#"></cfif>
<cfelseif action is "DeleteDir">
	<cfset dir = "#directory#/#REReplace(dirName,"[^[:alnum:]]","_","ALL")#">
	<cfif DirectoryExists(dir)>
		<cftry>
			<cfdirectory action="delete" directory="#dir#">
			<cfcatch>
				<cfif FindNoCase("directory is not empty",cfcatch.detail) gt 0>
					<cfset statusMessage = "Error: The directory ""#dirName#"" cannot be deleted because it is not empty.">
				<cfelse>
					<cfset statusMessage = cfcatch.detail>
				</cfif>
			</cfcatch>
		</cftry>
	</cfif>
</cfif>

<cfdirectory action="list" directory="#directory#" name="dir" sort="type,name">

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>File Browser</title>
<link rel=stylesheet href="../css/MSStandard.css" type="text/css">
<script type="text/javascript" src="../js/dojo/dojo.js"></script>
<script type="text/javascript" src="../js/library.js"></script>
<script type="text/javascript" src="../js/wysiwyg.js"></script>
<script type="text/javascript">
var fileColumn = opener.dialogParams["fileColumn"];
var htmlToolbar = opener.dialogParams["htmlToolbar"];
var htmlField = opener.dialogParams["htmlField"];
var dialogName = opener.dialogParams["dialogName"];
var elementName = opener.dialogParams["elementName"];
var siteEditor = opener.dialogParams["siteEditor"];
var fileDir = opener.dialogParams["fileDir"];

window.onload = adjustImageSizes;
function adjustImageSizes() {
	var images = document.getElementsByName("selectableImage");
	var sizeSpans = document.getElementsByName("imageInfo");
	for (var i = 0; i < images.length; i ++) {
		adjustImageSize(images[i],sizeSpans[i]);
	}
}
function adjustImageSize(imgObj,sizeSpan) {
	sizeSpan.innerHTML = imgObj.width + " X " + imgObj.height + " pixels";
	if (imgObj.height > imgObj.width) {
		imgObj.style.height = "150px";
		imgObj.style.width = "auto";
	} else if (imgObj.width > imgObj.height) {
		imgObj.style.width = "150px";
		imgObj.style.height = "auto";
	}
}
function addFolder() {
	dirName = prompt("What would you like to call the new folder?","");
	if (dirName != null) {
		window.location.href = "fileBrowser.cfm?uploadDir=#URLEncodedFormat(uploadDir)#&subDir=#URLEncodedFormat(subDir)#&action=CreateDir&DirName=" + escape(dirName);
	}
}
function insertImage(imgName) {
	if (fileColumn) {
		fileColumn.setValue(imgName.replace("/" + fileColumn.DIRECTORY + "/",""));
	} else if (opener.dialogName && opener.dialogName == "link") {
		opener.setUrl(imgName);
	} else if (opener.dialogName && opener.dialogName == "img") {
		opener.setImageUrl(imgName);
	} else {
		var element;
		var rng = xGetSelectionRange(htmlField.contentWindow);
		if (rng.insertNode) {
			element = htmlField.contentWindow.document.createElement("IMG");
			element.src = imgName;
			rng.insertNode(element);
			rng.selectNodeContents(element);
			xSelectRange(htmlField.contentWindow,rng)
		} else {
			htmlField.contentWindow.document.execCommand("InsertImage",false,imgName)
			element = getCurrent(htmlField,"IMG")
		}
		element.onload = opener.imageSetSize;
		element.onresizeend = opener.imageSetSize;
		element.setAttribute("border","0");
		xSelectElement(htmlField.contentWindow,element);
		htmlToolbar.dialog("img");
	}
	window.close();
}
</script>
</head>
<body id="dialog">
<h1>File Browser</h1>
<cfif Len(statusMessage) gt 0>
	<p class=statusmessage>#statusMessage#</p>
</cfif>

<p class=normaltext>
<a href="fileUpload.cfm?subDir=#URLEncodedFormat(subDir)#&redirectURL=#URLEncodedFormat("fileBrowser.cfm?uploadDir=#URLEncodedFormat(uploadDir)#&subDir=#URLEncodedFormat(subDir)#")#">Upload a New File</a>
| <a href="javascript:addFolder()">Create a new folder</a>
</p>

<!--- show breadcrumbs for directories --->
<cfif Len(subDir) gt 0>
	<p class=smalltext>
	&gt; <a href="fileBrowser.cfm?uploadDir=#URLEncodedFormat(uploadDir)#">Top</a>
	<cfset subDirLink = "">
	<cfloop index="theSubDir" list="#subDir#" delimiters="/">
	<cfset subDirLink = subDirLink & "/" & theSubDir>
	<cfif subDirLink is subDir>
		&gt; #theSubDir#
	<cfelse>
		&gt; <a href="fileBrowser.cfm?uploadDir=#URLEncodedFormat(uploadDir)#&subDir=#URLEncodedFormat(subDirLink)#">#theSubDir#</a>
	</cfif>
	</cfloop>
	</p>
</cfif>

<TABLE border=1 cellpadding=3 cellspacing=0 width=100% bordercolor=efefef>
<cfset i = 0>
<cfloop query="dir">
	<cfset extension = LCase(ListLast(name,"."))>
	<cfif name is not "." and name is not ".." and Not ListFindNoCase("cfm,cfc",extension)>
		<cfset i = i + 1>
		<cfif i mod 4 is 1><TR align=center></cfif>
		<TD class=smalltext>
			<cfif type is "Dir">
				#name#<br>
				<a href="fileBrowser.cfm?uploadDir=#URLEncodedFormat(uploadDir)#&subDir=#URLEncodedFormat(subDir & "/" & name)#"><img src="../images/dir.gif" border=0></a><br>
				<a href="fileBrowser.cfm?uploadDir=#URLEncodedFormat(uploadDir)#&subDir=#URLEncodedFormat(subDir)#&action=deletedir&dirName=#URLEncodedFormat(name)#" class=smalltext>Delete</a>
			<cfelse>
				<cfset extension = listLast(name,".")>
				#name#<br>(#Trim(NumberFormat(Evaluate(size/1000),"999999.9"))# KB, <span id="imageInfo" name="imageInfo"></span>)<br>
				<a href="javascript:insertImage('/#theDir#/#name#')" class=normaltext>
					<cfswitch expression="#extension#">
						<cfcase value="gif,jpeg,jpg,png">
							<img src="/#theDir#/#name#" border=0 name="selectableImage">
						</cfcase>
						<cfcase value="doc">
							<img src="../images/doc.gif" border=0>
						</cfcase>
						<cfcase value="pdf">
							<img src="../images/pdf.gif" border=0>
						</cfcase>
						<cfdefaultcase>
							<img src="../images/file.gif" border=0>
						</cfdefaultcase>
					</cfswitch>
				</a><br>
				<a href="/#theDir#/#name#" target="_blank">View</a> |
				<a href="javascript:insertImage('/#theDir#/#name#')" class=normaltext>Insert</a> |
				<a href="fileBrowser.cfm?uploadDir=#URLEncodedFormat(uploadDir)#&subDir=#URLEncodedFormat(subDir)#&action=delete&fileName=#URLEncodedFormat(name)#" class=smalltext onclick="return confirm('The file will be permanently deleted.  Continue?')">Delete</a>
			</cfif>
		</TD>
		<cfif i mod 4 is 0 or currentRow is recordCount></TR></cfif>
	</cfif>
</cfloop>
</cfoutput>
</TABLE>

</body>
</html>