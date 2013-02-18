<cfsetting showDebugOutput="no">



<CFFILE ACTION="Upload" FILEFIELD="upload" DESTINATION="#Request.ListingUploadedDocsDir#" NAMECONFLICT="makeUnique">

<cfset newFileName = DateFormat(Now(),"DDMMYY") & TimeFormat(Now(),"HHmmss") & REReplaceNoCase(file.serverFile,"[## ?&]","_","ALL")>

<cffile action="rename" source="#Request.ListingUploadedDocsDir#\#file.serverFile#" destination="#Request.ListingUploadedDocsDir#\#newFileName#">

<cfset ext = stripCR(trim(file.clientFileExt))>

<cfset fileError = "">
<cfif len(ext)>
	<cfif not listFindNoCase("jpg,jpeg,gif,png,tiff,doc,docx,pdf,xls,xlsx", ext)>
		<cfset fileError = "Invalid File Type">
	</cfif>
<cfelse>
	<cfset fileError = "Invalid File Type">
</cfif>

<cfif len(fileError)>
	<cffile action="delete" file="#Request.ListingUploadedDocsDir#\#newFileName#">
	<CFABORT>
</cfif>

<cfoutput>
<script language="javascript">
window.parent.CKEDITOR.tools.callFunction( "#url.CKEDITORFUNCNUM#", "ListingUploadedDocs/#newFileName#", "#fileError#");
</script>
</cfoutput>
Uploaded
