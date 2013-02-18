<cfcomponent output="false">

	<cfset This.SpaminessThreshold = 0.51>
	<cfset This.AutoReport = true>
	
	<cffunction name="Init" output="false">
		<cfargument name="MessageID" type="numeric">
		<cfif structKeyExists(arguments,"MessageID")>
			<cfset This.MessageID = arguments.MessageID>
			<cfquery name="getMessage" datasource="#request.dsn#">
				SELECT FromAddress,
					ToAddress,
					Subject,
					Message,
					MessageWrapper,
					Attachments,
					ListingID,
					IsSpam,
					CFFormProtectPass,
					DefensioPass,
					DefensioSignature,
					DefensioSpaminess,
					IsSent
				FROM Messages
				WHERE MessageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.MessageID#">
			</cfquery>
			<cfloop list="#getMessage.ColumnList#" index="col">
				<cfset This[col] = getMessage[col][1]>
			</cfloop>
		<cfelse>
			<cfset This.MessageID = 0>
			<cfset This.DefensioSpaminess = 0>
			<cfset This.IsSpam = 0>
			<cfset This.IsSent = 0>
		</cfif> 
		<cfreturn this>
	</cffunction>

	<cffunction name="CheckCFFormProtect" output="false">
		<cfargument name="values" type="struct" required="true">
		<cfset var l = {
			cffp = CreateObject("component","cfformprotect.cffpVerify").init()
		}>
		<cfset This.CfFormProtectPass = l.cffp.testSubmission(values)>
		<cfif not This.CfFormProtectPass>
			<cfset This.IsSpam = 1>
		</cfif>
	</cffunction>
	
	<cffunction name="CheckDefensio" output="false">
		<cfset var l = {
			defensio = CreateObject("component","cfc.defensio.defensio").Init(Request.DefensioApi.Key, Request.DefensioApi.OwnerUrl)
		}>
		<cfif l.defensio.validateKey().isError is not 1>
			<cfset l.r = l.defensio.auditComment(
				userIP = cgi.REMOTE_HOST, 
				articleDate = DateFormat(Now(),"yyyy/mm/dd"),
				commentType = "comment",
				commentContent = This.Subject & ", " & This.Message,
				commentAuthor = This.FromAddress,
				commentAuthorEmail = This.FromAddress,
				referrer = cgi.HTTP_REFERER
			)>
			<cfif l.r.IsError is not 1>
				<cfset This.DefensioSignature = l.r.Signature>
				<cfset This.DefensioSpaminess = l.r.Spaminess>
			</cfif>
			<cfif structKeyExists(l.r,"Spam") and l.r.Spam is 1>
				<cfset This.DefensioPass = 0>
				<cfset This.IsSpam = 1>
			<cfelse>
				<cfset This.DefensioPass = 1>
			</cfif>
			<cfif This.AutoReport and This.DefensioPass is 0 and This.DefensioSpaminess lt This.SpaminessThreshold>
				<!--- Auto-report false positives --->
				<cfset l.defensio.reportFalsePositives(This.DefensioSignature)>
				<cfset This.IsSpam = 0>
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="OKToAutoSend" hint="Checks spaminess threshold." output="false" returntype="boolean">
		<cfreturn (This.IsSpam is 0 or This.DefensioSpaminess lt This.SpaminessThreshold)>
	</cffunction>

	<cffunction name="Save" output="false">
		<cfif This.MessageID gt 0>
			<cfquery datasource="#request.dsn#">
				UPDATE Messages
				SET FromAddress = <cfif structKeyExists(This,"FromAddress")>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#This.FromAddress#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_varchar" null=true>
					</cfif>,
					ToAddress = <cfif structKeyExists(This,"ToAddress")>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#This.ToAddress#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_varchar" null=true>
					</cfif>,
					Subject = <cfif structKeyExists(This,"Subject")>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#This.Subject#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_varchar" null=true>
					</cfif>,
					Message = <cfqueryparam cfsqltype="cf_sql_varchar" value="#This.Message#">,
					MessageWrapper = <cfif structKeyExists(This,"MessageWrapper")>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#This.MessageWrapper#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_varchar" null=true>
					</cfif>,
					Attachments = <cfif structKeyExists(This,"Attachments")>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#This.Attachments#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_varchar" null=true>
					</cfif>,
					ListingID = <cfif structKeyExists(This,"ListingID")>
						<cfqueryparam cfsqltype="cf_sql_integer" value="#This.ListingID#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_integer" null=true>
					</cfif>,
					IsSpam = <cfqueryparam cfsqltype="cf_sql_bit" value="#This.IsSpam#">,
					CFFormProtectPass = <cfif structKeyExists(This,"CFFormProtectPass")>
						<cfqueryparam cfsqltype="cf_sql_bit" value="#This.CFFormProtectPass#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_bit" null=true>
					</cfif>,
					DefensioPass = <cfif structKeyExists(This,"DefensioPass")>
						<cfqueryparam cfsqltype="cf_sql_bit" value="#This.DefensioPass#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_bit" null=true>
					</cfif>,
					DefensioSignature = <cfif structKeyExists(This,"DefensioSignature")>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#This.DefensioSignature#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_varchar" null=true>
					</cfif>,
					DefensioSpaminess = <cfif structKeyExists(This,"DefensioSpaminess") and isNumeric(This.DefensioSpaminess)>
						<cfqueryparam cfsqltype="cf_sql_float" value="#This.DefensioSpaminess#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_float" null=true>
					</cfif>,
					IsSent = <cfqueryparam cfsqltype="cf_sql_bit" value="#This.IsSent#">
				WHERE MessageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.MessageID#">
			</cfquery>
		<cfelse> 
			<cfquery result="newMessage" datasource="#request.dsn#">
				INSERT INTO Messages (
					FromAddress,
					ToAddress,
					Subject,
					Message,
					MessageWrapper,
					Attachments,
					ListingID,
					IsSpam,
					CFFormProtectPass,
					DefensioPass,
					DefensioSignature,
					DefensioSpaminess,
					IsSent
				) VALUES (
					<cfif structKeyExists(This,"FromAddress")>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#This.FromAddress#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_varchar" null=true>
					</cfif>,
	
					<cfif structKeyExists(This,"ToAddress")>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#This.ToAddress#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_varchar" null=true>
					</cfif>,
	
					<cfif structKeyExists(This,"Subject")>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#This.Subject#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_varchar" null=true>
					</cfif>,
	
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#This.Message#">,
	
					<cfif structKeyExists(This,"MessageWrapper")>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#This.MessageWrapper#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_varchar" null=true>
					</cfif>,
	
					<cfif structKeyExists(This,"Attachments")>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#This.Attachments#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_varchar" null=true>
					</cfif>,
	
					<cfif structKeyExists(This,"ListingID")>
						<cfqueryparam cfsqltype="cf_sql_integer" value="#This.ListingID#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_integer" null=true>
					</cfif>,
	
					<cfqueryparam cfsqltype="cf_sql_bit" value="#This.IsSpam#">,
	
					<cfif structKeyExists(This,"CFFormProtectPass")>
						<cfqueryparam cfsqltype="cf_sql_bit" value="#This.CFFormProtectPass#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_bit" null=true>
					</cfif>,
	
					<cfif structKeyExists(This,"DefensioPass")>
						<cfqueryparam cfsqltype="cf_sql_bit" value="#This.DefensioPass#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_bit" null=true>
					</cfif>,
	
					<cfif structKeyExists(This,"DefensioSignature")>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#This.DefensioSignature#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_varchar" null=true>
					</cfif>,
	
					<cfif structKeyExists(This,"DefensioSpaminess")>
						<cfqueryparam cfsqltype="cf_sql_float" value="#This.DefensioSpaminess#">
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_float" null=true>
					</cfif>,
					
					<cfqueryparam cfsqltype="cf_sql_bit" value="#This.IsSent#">
				)
			</cfquery>
			<cfset This.MessageID = newMessage.generatedKey>
			<cfif Not structKeyExists(application, "ReviewMessagesSentDate") or application.ReviewMessagesSentDate lt dateAdd("h",-23,Now())>
				<!--- Send message with a reminder to review --->
				<cfquery datasource="#request.dsn#" name="awaitingReview">
					SELECT count(*) as c FROM Messages WHERE Reviewed = 0
				</cfquery>
				<cfset reviewUrl = Request.httpsURL & "/admin/Messages.cfm?reviewing=1">
				<cfmail to="#Request.MailToFormsTo#" from="#Request.MailToFormsFrom#" subject="Messages awaiting review" type="HTML">
					<p>There are #awaitingReview.c# messages awaiting review</p>
					<p><a href="#reviewUrl#">#reviewUrl#</a></p>
				</cfmail>
				<cfset application.ReviewMessagesSentDate = Now()>
			</cfif>
		</cfif>
	</cffunction> 
	
	<cffunction name="Send" output="false">
		<cfset var AppMimeType = "">
		<cfset var i = 0>
		<cfset var EmailText = Replace(This.MessageWrapper,"##Message##",This.Message)>
		<cfmail to="#This.ToAddress#" from="#Request.MailToFormsFrom#" subject="#This.Subject#" 
				type="HTML" BCC="#Request.BCCEmail#">
			<cfloop List="#This.Attachments#" index="i">
				<cfif FileExists("#Request.ListingEmailedDocsDir#\#i#")>							
					<cfset FileExt=ListLast(i,".")>
					<cfif FileExt is "pdf">
						<cfset AppMimeType="application/PDF">
					<cfelseif ListFindNoCase("doc,docx",FileExt)>
						<cfset AppMimeType="application/msword">
					<cfelseif ListFindNoCase("jpg,jpeg",FileExt)>
						<cfset AppMimeType="image/jpeg">
					<cfelseif ListFindNoCase("gif",FileExt)>
						<cfset AppMimeType="image/gif">
					<cfelseif ListFindNoCase("xls,xlsx",FileExt)>
						<cfset AppMimeType="application/vnd.ms-excel">
					<cfelseif ListFindNoCase("txt",FileExt)>
						<cfset AppMimeType="text/plain">
					<cfelseif ListFindNoCase("tiff",FileExt)>
						<cfset AppMimeType="image/tiff">
					<cfelseif ListFindNoCase("rtf",FileExt)>
						<cfset AppMimeType="text/rtf">
					<cfelse>
						<cfset AppMimeType="application/octet-stream">
					</cfif>
					<cfmailparam file = "#Request.ListingEmailedDocsDir#\#i#" contentID="#createUUID()#" disposition="attachment" type="#AppMimeType#" remove="true">
				</cfif>
			</cfloop>
				
			<cfmailpart type="text/plain" charset="utf-8">#TextMessage(EmailText)#</cfmailpart>
			<cfmailpart type="text/html" charset="utf-8">#EmailText#</cfmailpart>
		</cfmail>
		<cfset This.IsSent = 1>
		<cfset This.Save()>
	</cffunction>

	<cffunction name="TextMessage" returntype="string" hint="Converts an html email message into a nicely formatted with line breaks plain text message">
	    <cfargument name="string" required="true" type="string">
	    <cfscript>
	        var pattern = "<br>";
	        var CRLF = chr(13) & chr(10);
	        var message = ReplaceNoCase(arguments.string, pattern, CRLF , "ALL");
	        pattern = "<[^>]*>";
	    </cfscript>
	    <cfreturn REReplaceNoCase(message, pattern, "" , "ALL")>
	</cffunction>

</cfcomponent>