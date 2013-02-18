<!----------------------------------------------

Sample useage:
<cfmodule template="spamChecker.cfm"
	siteURL="smartpayrollonline.com"
	siteKey="73714f7092af0cb4042379e8dab3d4bf"
	commenterName="Adam Polon"
	comments='here are my comments.  They are not spammy.'
>


------------------------------------------------>
<cftry>
	<cfhttp
		url="http://api.defensio.com/app/1.2/audit-comment/F2FE8BC3756A30F7D666BFEDE09046E9.xml"
		method="post"
	>

		<cfhttpparam type="formfield" name="owner-url" value="ZoomTanzania.com">
		<cfhttpparam type="formfield" name="user-ip" value="#cgi.remote_addr#">
		<cfhttpparam type="formfield" name="article-date" value="#dateFormat(now(), 'yyyy/mm/dd')#">
		<cfhttpparam type="formfield" name="comment-author" value="#attributes.commenterName#">
		<cfhttpparam type="formfield" name="comment-type" value="comment">
		<cfhttpparam type="formfield" name="comment-content" value="#attributes.comments#">
	</cfhttp>
	<cfcatch>
		<cfset caller.spamResults.spam = false>
		<cfset caller.spamResults.error = true>
		<cfset caller.spamResults.errorMsg = "Error calling web service">
		<cfexit>
	</cfcatch>
</cftry>

<cfset resp= replaceNoCase(cfhttp.fileContent, "defensio-result", "defensioResult", "all")>

<cftry>
	<cfset result = xmlParse(resp)>

	<cfcatch>
		<cfset caller.spamResults.spam = false>
		<cfset caller.spamResults.error = true>
		<cfset caller.spamResults.errorMsg = "Error parsing XML.">
		<cfexit>
	</cfcatch>
</cftry>

<cfset isSpam = result.defensioResult.spam.xmlText>

<cfif isSpam>
	The information you are attempting to submit has been flagged as spam and has not been submitted.
	<cfabort>
</cfif>

<cfset caller.spamResults.spam = isSpam>
<cfset caller.spamResults.error = false>
<cfset caller.spamResults.errorMsg = "">


