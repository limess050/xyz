<cfinclude template="../../Admin/checklogin.cfm">

<cfsetting requesttimeout="1800">

<cfparam name="redirectURL" default="">

<cfset uploadDir = Request.MCFUploadsDir>
<cfif Left(uploadDir,1) is "/">
	<cfset uploadDir = Right(uploadDir,Len(uploadDir)-1)>
</cfif>
<cfset destination = ExpandPath(getBaseRelativePath() & uploadDir & subDir)>

<cftry>
	<cfset cffile = UploadFile(
		filefield = "file", 
		destination = destination,
		TempDirectory = Application.TempDirectory
	)>
	<cfset fileVirtualPath = "/#uploadDir#/#cffile.serverFile#">
	<cfcatch>
		<table height=100% width=100% border=0><tr><td align=center valign=middle>
		<cfoutput>
			<p>Error uploading file: #cfcatch.Message#</p>
			<p><a href="javascript:history.back()">Go Back</a></p>
		</cfoutput>
		</td></tr></table>
		<cfabort>
	</cfcatch>
</cftry>

<cfparam name="title" default="">
<cfoutput>
<cfif Len(jsAction) gt 0>
	<script type="text/javascript">
	window.blur();
	window.opener.#jsAction#('#fileVirtualPath#'<cfif Len(title)>,'#Replace(title,"'","\'","ALL")#'</cfif>);
	window.close();
	</script>
<cfelseif Len(redirectURL) gt 0>
	<cflocation url="#redirectURL#">
<cfelse>
	<table height=100% width=100% border=0><tr><td align=center valign=middle>
	File uploaded successfully.<br>
	#fileVirtualPath#
	</td></tr></table>
</cfif>
</cfoutput>