<!--- This template expects a ListingID. --->
<cfset Edit=0>
<cfparam name="ListingID" default="0">

<cfif IsDefined('TB_iframe') or not IsDefined('CaptchaEntry')><!--- Web crawler following old cached link when Email form was thickbox pop-up --->
	<cfif ListingID neq "0">
		<cflocation url="listingdetail?ListingID=#ListingID#&ShowEmail=1" addToken="No">
	<cfelse>	
		<cflocation url="#Request.HTTPURL#" addToken="No">
	</cfif>
</cfif>

<cfparam name="AllowedExtensions" default="txt,pdf,doc,docx,rtf,xls,xlsx,ppt,pptx,gif,jpg,jpeg,tiff">

<script src="js/jquery-1.3.min.js"></script>
<script src='http://jquery-multifile-plugin.googlecode.com/svn/trunk/jquery.MultiFile.js' type="text/javascript" language="javascript"></script>
<script type="text/javascript" src="Lighthouse/Resources/js/lighthouse_all.js"></script>

<cfoutput>
	<cfset rString = "">
	<cfset captcha = CreateObject("component","cfc.Captcha").init()>
	<cfif Not captcha.Validate()>
		<cfset rString = "The letters you entered did not match the image. The email was not sent.">
	<cfelse>
		<cfset captcha.Use()>

		<cfquery name="getListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select L.ListingID, L.PublicEmail, L.ListingTypeID,
			CASE 
			WHEN L.ListingTypeID = 4 
				THEN Cast(L.VehicleYear as varchar(4)) + ' ' + M.Title + ' ' + L.Model 
			WHEN L.ListingTypeID = 5 
				THEN Cast(L.VehicleYear as varchar(4)) + ' ' + L.Make + ' ' + L.Model 
			WHEN L.ListingTypeID in (12)
				THEN L.ShortDescr
			ELSE L.Title 
			END as ListingTitle,
			CASE 
			WHEN L.ListingTypeID in (1,2,14)
				THEN '#Request.HTTPURL#/' + URLSafeTitle
			ELSE '#Request.HTTPURL#/ListingDetail?ListingID=' + Cast(ListingID as varchar(10))
			END as ListingFriendlyURL
			From Listings L With (NoLock)
			Left Outer Join Makes M With (NoLock) on L.MakeID=M.MakeID
			Where L.ListingID =  <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Check for JobClick limit. This check is necessary because a user could open multiple Job Posting pages, first and then submit them one by one, 
		defeating upfront check that is performed when the pages were loaded. --->
		<cfif ListFind("10,12",getListing.ListingTypeID)>
			<cfif IsDefined('session.UserID') and Len(session.UserID)>
				<cfquery name="getClickCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Select J.ClickCount
					From JobClicks J
					Where J.UserID = <cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
					and J.ClickDate = <cfqueryparam value="#application.CurrentDateInTZ#" cfsqltype="cf_sql_date">
				</cfquery>
			</cfif>
			<cfif not IsDefined('session.UserID') or not Len(session.UserID) or (getClickCount.RecordCount and getClickCount.ClickCount gte application.JobClickPerDayLimit)>
				<cflocation url="listingdetail?ListingID=#ListingID#&statusMessage=MNS" addToken="no">
				<cfabort>
			</cfif>			
		</cfif>
		
		<cfset OversizeFound="0">
		<cfset AttachedDocs = "">
		<cfset totalSize = 0>
		<!--- Loop through form fields and find all 'EmailFile%' fields. The multifile plugin renames the fields each time the form validation fails, so a file named "EmailFile1" can end up named "EmailFile111" upon submission. --->
		<cfset FileFields="">
		<cfloop list="#FieldNames#" index="fn">
			<cfif Left(fn,9) is "EmailFile">
				<cfset FileFields=ListAppend(FileFields,fn)>
			</cfif>
		</cfloop>
		<cfloop List="#FileFields#" index="i">
			<cfif not OversizeFound and isDefined("#i#") and Len(Evaluate(i))>
				<cffile action="upload" filefield="#i#" destination="#Request.ListingEmailedDocsDir#" nameconflict="MakeUnique" result="File#i#">
				<cfset totalSize = totalSize + Evaluate("File"&i&".fileSize")>
				<cfif totalsize GT (1024 *1000 * 2)>
					<cfloop List="#FileFields#" index="j">
						<cfif FileExists("#Request.ListingEmailedDocsDir#\#Evaluate('File'&j&'.serverFile')#")>
							<cffile action="Delete" file="#Request.ListingEmailedDocsDir#\#Evaluate('File'&j&'.serverFile')#">
						</cfif>
						<!--- Once the inner loop reaches the same point as the outer loop, stop, since subsequent field's files have not yet been uploaded. --->
						<cfif i is j>
							<cfbreak>
						</cfif>
					</cfloop>
					<cfset rString="Your upload exceeds the 2MB maximum size. The email was not sent.">
					<cfset OversizeFound="1">
				</cfif>
				<!--- Check file extension --->
				<cfif not OversizeFound and not ListFindNoCase(AllowedExtensions,Evaluate('File'&i&'.ClientFileExt'))>
					<cfset BadExtension=Evaluate('File'&i&'.ClientFileExt')>								
					<cfloop List="#FileFields#" index="j">
						<cfif FileExists("#Request.ListingEmailedDocsDir#\#Evaluate('File'&j&'.serverFile')#")>
							<cffile action="Delete" file="#Request.ListingEmailedDocsDir#\#Evaluate('File'&j&'.serverFile')#">
						</cfif>
						<!--- Once the inner loop reaches the same point as the outer loop, stop, since subsequent field's files have not yet been uploaded. --->
						<cfif i is j>
							<cfbreak>
						</cfif>
					</cfloop>
					<cfset rString="A file you uploaded was not an allowed file type. File type #BadExtension# is not allowed. Please try again.">
					<cfset OversizeFound="1">
				</cfif>
				<cfif not OversizeFound>
					<cfset CleanedFileName= REReplace(Evaluate('File' & i & '.serverFile'),"[^0-9A-Za-z.]","_","all")>
					<cfif CleanedFileName neq Evaluate('File' & i & '.serverFile')>
						<cffile action="rename" destination="#Request.ListingEmailedDocsDir#\#CleanedFileName#" source="#Request.ListingEmailedDocsDir#\#Evaluate('File' & i & '.serverFile')#">
					</cfif>
					<cfset AttachedDocs = ListAppend(AttachedDocs,"#CleanedFileName#")>
				</cfif>
			</cfif>	
		</cfloop>
		<cfif not getListing.RecordCount or not Len(getListing.PublicEmail)>
			<cfset rString="Listing Email Address not found. The email was not sent.">
		<cfelseif OversizeFound>
			<!--- <cfset rString="Your upload exceeds the 2MB maximum size. The email was not sent."> --->
		<cfelse>
			<!--- Record message and check for spam --->
			<cfset message = CreateObject("component","cfc.Message").init()>
			<cfset message.FromAddress = Email>
			<cfset message.ToAddress = getListing.PublicEmail>
			<cfset message.Subject = SubjectLine>
			<cfset message.Message = EmailBody>
			<cfsavecontent variable="message.MessageWrapper">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html><head><title>#SubjectLine#</title></head>
<body>
An inquiry regarding your listing on ZoomTanzania.com for #getListing.ListingTitle#:<br>
Listing ID: #getListing.ListingID# - <a href="#getListing.ListingFriendlyURL#">#getListing.ListingTitle#</a><br>
<p><strong>Please Do Not Reply to This Email.</strong> Instead, copy and paste the senders email address <a href="Mailto:#Email#">#Email#</a> into your email program.  
<p>
##Message##
<p>Brought to you by your friends at <a href="#request.httpURL#">www.ZoomTanzania.com</a>.</p>
</body></html>
			</cfsavecontent>
			<cfset message.Attachments = AttachedDocs>
			<cfset message.listingID = ListingID>
			<cfset message.CheckCFFormProtect(form)>
			<cfset message.CheckDefensio()>
			<cfset message.Save()>
			<cfif message.OKtoAutoSend()>
				<cfset message.Send()>

				<cfif not IsDefined('application.ListingEmailInquiryImpressions')>
					<cfset application.ListingEmailInquiryImpressions= structNew()>
				</cfif>
				<cfif StructKeyExists(application.ListingEmailInquiryImpressions,ListingID)>
					<cfset application.ListingEmailInquiryImpressions[ListingID] = application.ListingEmailInquiryImpressions[ListingID] + 1>
				<cfelse>
					<cfset application.ListingEmailInquiryImpressions[ListingID] = 1>
				</cfif>
			</cfif>
			<cfset rString="MS">
			<cfif ListFind("10,12",getListing.ListingTypeID)>
				<cfquery name="countJobClick" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					<!--- Delete any records older than today, to keep number of rows in the table to a minuimum. --->
					Delete From JobClicks
					Where ClickDate <> <cfqueryparam value="#application.CurrentDateInTZ#" cfsqltype="cf_sql_date">
					
					Update JobClicks
					Set ClickCount=ClickCount+1
					Where UserID = <cfqueryparam value="#session.UserID#" cfsqltype="cf_sql_integer"> 
					and ClickDate = <cfqueryparam value="#application.CurrentDateInTZ#" cfsqltype="cf_sql_date">
					
					IF @@ROWCOUNT = 0 
					BEGIN
						Insert into JobClicks
						(UserID,ClickDate,ClickCount)
						VALUES
						(<cfqueryparam value="#session.UserID#" cfsqltype="cf_sql_integer"> ,<cfqueryparam value="#application.CurrentDateInTZ#" cfsqltype="cf_sql_date">,1)					
					END
				</cfquery>	
			</cfif>
		</cfif>
	</cfif>
	#rstring#
</cfoutput>

<cfquery name="getListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select L.ListingID, L.ListingTypeID, L.ListingTitle
	From ListingsView L With (NoLock)
	Where L.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="cf_sql_integer">
</cfquery>

<cfif ListFind("1,2,14",getListing.ListingTypeID)>
	<cfsavecontent variable="ListingURL">
	<cfoutput>
	<cfif AmpOrQuestion is "?">#REReplace(Replace(Replace(getListing.ListingTitle," - ","-","All")," ","-","All"), "[^a-zA-Z0-9\-]","","all")#?StatusMessage=#rstring#<cfelse>#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#&StatusMessage=#rstring#</cfif>
	</cfoutput>
	</cfsavecontent>
<cfelse>
	<cfset ListingURL="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#&StatusMessage=#rString#">
</cfif>

<cflocation url="#ListingURL#" addtoken="no">
<cfabort>
