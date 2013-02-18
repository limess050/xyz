<!--- This template runs at the beginning of the Tenders.cfm template, when the action is "View". It gets all Tenders that have been marked as Reviewed and processes them, sending out the eamils and then deleting the record. --->
<cfparam name="action" default="View">
<cffunction name="textMessage" access="public" returntype="string" hint="Converts an html email message into a nicely formatted with line breaks plain text message">
    <cfargument name="string" required="true" type="string">
    <cfscript>
        var pattern = "<br>";
        var CRLF = chr(13) & chr(10);
        var message = ReplaceNoCase(arguments.string, pattern, CRLF , "ALL");
        pattern = "<[^>]*>";
    </cfscript>
    <cfreturn REReplaceNoCase(message, pattern, "" , "ALL")>
</cffunction>

<cfquery name="getReviewedTenders" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select TenderID, Email, SubjectLine, EmailBody
	From Tenders
	Where Reviewed = 1
	Order By TenderID
</cfquery>

<cfoutput query="getReviewedTenders">
	<cfquery name="getListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select L.ListingID, L.Title, L.PublicEmail,
			CASE 
			WHEN L.ListingTypeID in (1,2,14)
				THEN '#Request.HTTPURL#/' + URLSafeTitle
			ELSE '#Request.HTTPURL#/ListingDetail?ListingID=' + Cast(L.ListingID as varchar(10))
			END as ListingFriendlyURL
		From ListingsView L
		Inner Join TenderListings TL on L.ListingID=TL.ListingID
		Where TL.TenderID = <cfqueryparam cfsqltype="cf_sql_integer" value="#TenderID#">
		and L.PublicEmail is not null and L.PublicEmail <> ''
		<cfinclude template="../includes/LiveListingFilter.cfm">
	</cfquery>
	<cfquery name="getDocs" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select D.FileName
		From TenderDocs D
		Where D.TenderID = <cfqueryparam cfsqltype="cf_sql_integer" value="#TenderID#">
		Order By D.TenderDocID
	</cfquery>
	
	<cfloop query="getListings">
		<cfsavecontent variable="EmailText">
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
	
	<html>
	<head>
		<title>#getReviewedTenders.SubjectLine#</title>
	</head>
	
	<body>
	A request regarding your listing on ZoomTanzania.com for #Title#:<br>
	Listing ID: #ListingID# - <a href="#ListingFriendlyURL#">#Title#</a><br>
	<p><strong>Please Do Not Reply to This Email.</strong> Instead, copy and paste the senders email address <a href="Mailto:#getReviewedTenders.Email#">#getReviewedTenders.Email#</a> into your email program.  
	<p>Message:
	<p>
	#getReviewedTenders.EmailBody#
	<br><p>Brought to you by your friends at <a href="#request.httpURL#">www.ZoomTanzania.com</a>.</p>
	</body>
	</html>
		</cfsavecontent>
		<cfmail to="#PublicEmail#" from="#Request.MailToFormsFrom#" subject="#getReviewedTenders.SubjectLine#" type="HTML" BCC="">
			<cfif getDocs.RecordCount>
				<cfloop query="getDocs">
					<cfif FileExists("#Request.TenderDocsDir#\#FileName#")>						
						<cfset FileExt=ListLast(FileName,".")>
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
						<cfmailparam file = "#Request.TenderDocsDir#\#FileName#" contentID="#createUUID()#" disposition="attachment" type="#AppMimeType#" remove="no">
					</cfif>
				</cfloop>
			</cfif>	
			<cfmailpart type="text/plain" charset="utf-8">#textMessage(EmailText)#</cfmailpart>
			<cfmailpart type="text/html" charset="utf-8">#EmailText#</cfmailpart>
		</cfmail>		
		<cfif not IsDefined('application.ListingEmailInquiryImpressions')>
			<cfset application.ListingEmailInquiryImpressions= structNew()>
		</cfif>
		<cfif StructKeyExists(application.ListingEmailInquiryImpressions,ListingID)>
			<cfset application.ListingEmailInquiryImpressions[ListingID] = application.ListingEmailInquiryImpressions[ListingID] + 1>
		<cfelse>
			<cfset application.ListingEmailInquiryImpressions[ListingID] = 1>
		</cfif>
	</cfloop>	
	
	<!--- Send Confirmation Email --->
	<cfmail to="#getReviewedTenders.Email#" from="#Request.MailToFormsFrom#" subject="Your Request has been sent" type="HTML" BCC="">
		<p>Your group inquiry entitled "#getReviewedTenders.SubjectLine#" has been sent to:</p>
		<p>
		<cfloop query="getListings">
			#Title#<br>
		</cfloop>
		</p>
		<p>
		Thank you for using <a href="#Request.HTTPURL#">www.ZoomTanzania.com</a> > Zoom It and Find What you Need – Fast!</p>
	</cfmail>
	<!--- Mark Docs with sent date.
	Delete any Docs with sentDate more than 1 day ago. (This allows multiple emails to be sent out with the same attachments, and removes the possiblity of the attachment being deleted before all the emails are sent.) --->

	<cfquery name="updateDocs" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Update TenderDocs
		Set DateSent = getDate()
		Where TenderID = <cfqueryparam cfsqltype="cf_sql_integer" value="#TenderID#">
	</cfquery>
	<cfquery name="DeleteListingRecords" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Delete From TenderListings
		Where TenderID = <cfqueryparam cfsqltype="cf_sql_integer" value="#TenderID#">
	</cfquery>
	<cfquery name="DeleteTender" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Delete From Tenders
		Where TenderID = <cfqueryparam cfsqltype="cf_sql_integer" value="#TenderID#">
	</cfquery>
	
	<cfset NowTime=Now()>
	<cfquery name="getDocsToDelete" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select D.FileName
		From TenderDocs D
		Where D.DateSent <  DATEADD(hh,-24,#NowTime#)
		Order By D.TenderDocID
	</cfquery>
	<cfif getDocsToDelete.RecordCount>
		<cfloop query="getDocsToDelete">
			<cfif FileExists("#Request.TenderDocsDir#\#FileName#")>
				<cffile action="Delete" file="#Request.TenderDocsDir#\#FileName#">
			</cfif>
		</cfloop>
	</cfif>
	<cfquery name="DeleteDocRecords" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Delete From TenderDocs
		Where DateSent <  DATEADD(hh,-24,#NowTime#)
	</cfquery>
</cfoutput>
