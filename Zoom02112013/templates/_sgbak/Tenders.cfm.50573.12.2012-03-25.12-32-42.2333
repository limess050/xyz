<!---
Tenders Template
This template expects form fields of CategoryID and either ListingResults or ListingResultsQID
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfif edit>
	<cfinclude template="header.cfm">
	<cfoutput>
	<div class="centercol-inner legacy">
	 	<h1><lh:MS_SitePagePart id="title" class="title"></h1>
		<p>&nbsp;</p>
	
	 	<div class="breadcrumb"><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/">Home</a> &gt; </div>
		<lh:MS_SitePagePart id="body" class="body">	
		<p>Request form appears here.
		<p>This is the text that appears above the Listing checkboxes.
		<lh:MS_SitePagePart id="bodyListings" class="body">	
		<p>This is the text that appears after a successful submission.
		<lh:MS_SitePagePart id="bodyTY" class="body">		
	</div>
	</cfoutput>
<cfelse>
	<cfif IsDefined('ListingIDs')>
		<!--- Do form submission --->
		<cfif not IsDefined('CaptchaEntry')>
			<cfif not IsDefined('CategoryID') and not IsDefined('CategoryURL')>
				<cflocation url="#Request.HTTPURL#" addToken="no">
			<cfelseif IsDefined('CategoryURL')>
				<cflocation url="#CategoryURL#" addToken="no">
			<cfelse>
				<cflocation url="#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#CategoryID#" addToken="no">
			</cfif>
		</cfif>
		
		<cfparam name="AllowedExtensions" default="txt,pdf,doc,docx,rtf,xls,xlsx,ppt,pptx,gif,jpg,jpeg,tiff">
		
		<cfset rString = "">
		<cfset captcha = CreateObject("component","cfc.Captcha").init()>
		<cfif Not captcha.Validate()>
			<cfset rString = "The letters you entered did not match the image. The email was not sent.">
		<cfelse>
			<cfset captcha.Use()>
			<cfset OversizeFound="0">
			<cfset AttachedDocs = "">
			<cfif fileCount GT 0>
				<cfset totalSize = 0>
				<!--- Loop through form fields and find all 'EmailFile%' fields. The multifile plugin renames the fields each time the form validation fails, so a file named "EmailFile1" can end up named "EmailFile111" upon submission. --->
				<cfset FileFields="">
				<cfloop list="#FieldNames#" index="fn">
					<cfif Left(fn,9) is "EmailFile">
						<cfset FileFields=ListAppend(FileFields,fn)>
					</cfif>
				</cfloop>
				<cfloop List="#FileFields#" index="i">
					<cfif not OversizeFound and isDefined("#i#")>
						<cffile action="upload" filefield="#i#" destination="#Request.TenderDocsDir#" nameconflict="MakeUnique" result="File#i#">
						<cfset totalSize = totalSize + Evaluate("File"&i&".fileSize")>
						<cfif totalsize GT (1024 *1000 * 2)>
							<cfloop List="#FileFields#" index="j">
								<cfif FileExists("#Request.TenderDocsDir#\#Evaluate('File'&j&'.serverFile')#")>
									<cffile action="Delete" file="#Request.TenderDocsDir#\#Evaluate('File'&j&'.serverFile')#">
								</cfif>
								<!--- Once the inner loop reaches the same point as the outer loop, stop, since subsequent field's files have not yet been uploaded. --->
								<cfif i is j>
									<cfbreak>
								</cfif>
							</cfloop>
							<cfset rString="Your upload exceeds the 2MB maximum size. The submission was not sent.">
							<cfset OversizeFound="1">
						</cfif>
						<!--- Check file extension --->
						<cfif not OversizeFound and not ListFindNoCase(AllowedExtensions,Evaluate('File'&i&'.ClientFileExt'))>
							<cfset BadExtension=Evaluate('File'&i&'.ClientFileExt')>								
							<cfloop List="#FileFields#" index="j">
								<cfif FileExists("#Request.TenderDocsDir#\#Evaluate('File'&j&'.serverFile')#")>
									<cffile action="Delete" file="#Request.TenderDocsDir#\#Evaluate('File'&j&'.serverFile')#">
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
								<cffile action="rename" destination="#Request.TenderDocsDir#\#CleanedFileName#" source="#Request.TenderDocsDir#\#Evaluate('File' & i & '.serverFile')#">
							</cfif>
							<cfset AttachedDocs = ListAppend(AttachedDocs,"#CleanedFileName#")>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
			<cfif not Len(rString)>
				<!--- Save all form data --->
				<cfquery name="saveRequest" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Insert into Tenders
					(Email, SubjectLine, EmailBody)
					Values
					(<cfqueryparam value="#Email#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#SubjectLine#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#EmailBody#" cfsqltype="CF_SQL_VARCHAR">)
					
					Select Max(TenderID) as TenderID
					From Tenders
				</cfquery>
				<cfset TenderID = saveRequest.TenderID>
				<cfquery name="saveRequestListingsAndDocs" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					<cfloop list="#ListingIDs#" index="L">
						Insert into TenderListings
						(TenderID, ListingID)
						Values
						(<cfqueryparam value="#TenderID#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#L#" cfsqltype="CF_SQL_INTEGER">)
					</cfloop>
					<cfloop list="#AttachedDocs#" index="AD">
						Insert into TenderDocs
						(TenderID, FileName)
						Values
						(<cfqueryparam value="#TenderID#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#AD#" cfsqltype="CF_SQL_VARCHAR">)
					</cfloop>
				</cfquery>
			</cfif>
		</cfif>
		
		
		
		<cfinclude template="header.cfm">
		<cfoutput>
		<div class="centercol-inner legacy">
		 	<h1><lh:MS_SitePagePart id="title" class="title"></h1>
			<p>&nbsp;</p>
		
		 	<div class="breadcrumb"><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/">Home</a> &gt; </div>
			
			<cfif Len(rString)>
				#rString#
			<cfelse>
				<lh:MS_SitePagePart id="bodyTY" class="body">
			</cfif>		
		</div>
		</cfoutput>
	<cfelse>
		<cfif not IsDefined('ListingResults') and not IsDefined('ListingResultsQID')>
			<cfif not IsDefined('CategoryID') and not IsDefined('CategoryURL')>
				<cflocation url="#Request.HTTPURL#" addToken="no">
			<cfelseif IsDefined('CategoryURL')>
				<cflocation url="#CategoryURL#" addToken="no">
			<cfelse>
				<cflocation url="#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#CategoryID#" addToken="no">
			</cfif>
		</cfif>
		
		<cfquery name="getImpressionSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select SectionID
			From PageSections
			Where PageID = <cfqueryparam value="#PageID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset ImpressionSectionID=getImpressionSection.SectionID>
		<cfif not Len(ImpressionSectionID)>
			<cfset ImpressionSectionID = 0>
		</cfif>
		
		<cfif not IsDefined('application.SectionImpressions')>
			<cfset application.SectionImpressions= structNew()>
		</cfif>
		<cfif StructKeyExists(application.SectionImpressions,ImpressionSectionID)>
			<cfset application.SectionImpressions[ImpressionSectionID] = application.SectionImpressions[ImpressionSectionID] + 1>
		<cfelse>
			<cfset application.SectionImpressions[ImpressionSectionID] = 1>
		</cfif>
		<cfinclude template="../includes/Filter.cfm">
		<cfquery name="getListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select L.ListingID, L.ListingTitle, L.LogoImage,
			CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ# Then 1 Else 0 END as HasExpandedListing,
			'#Request.HTTPURL#/' + URLSafeTitle as ListingFriendlyURL
			From ListingsView L With (NoLock)
			<cfif IsDefined('ListingResultsQID')>
				Inner Join CategoryQueryLines CQL With (NoLock) on CQL.ListingID=L.ListingID
				Inner Join CategoryQueries CQ With (NoLock) on CQL.CategoryQueryID=CQ.CategoryQueryID 
			</cfif>
			Where L.PublicEmail is not null 
				and L.PublicEmail <> ''
				and L.ListingTypeID in (1,2,14)
				<cfif IsDefined('ListingResults')>			
					and L.ListingID in (<cfqueryparam value="#ListingResults#" cfsqltype="cf_sql_integer" list="true">)
				<cfelse>
					and CQ.CategoryQueryID=<cfqueryparam value="#ListingResultsQID#" cfsqltype="cf_sql_integer">
				</cfif>
				<cfinclude template="../includes/LiveListingFilter.cfm">
				#FilterWhereClause#
			Order By HasExpandedListing desc, L.ListingTitle
		</cfquery>
		<cfif getListings.RecordCount is "0">
			<!--- if no results, see if any exists when not filtering on PublicEmail --->
			<cfquery name="getListings2" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select L.ListingID
				From ListingsView L With (NoLock)
				<cfif IsDefined('ListingResultsQID')>
					Inner Join CategoryQueryLines CQL With (NoLock) on CQL.ListingID=L.ListingID
					Inner Join CategoryQueries CQ With (NoLock) on CQL.CategoryQueryID=CQ.CategoryQueryID 
				</cfif>
				Where 
					<cfif IsDefined('ListingResults')>			
						L.ListingID in (<cfqueryparam value="#ListingResults#" cfsqltype="cf_sql_integer" list="true">)
					<cfelse>
						CQ.CategoryQueryID=<cfqueryparam value="#ListingResultsQID#" cfsqltype="cf_sql_integer">
					</cfif>					
					and L.ListingTypeID in (1,2,14)
					<cfinclude template="../includes/LiveListingFilter.cfm">
					#FilterWhereClause#
				Order By HasExpandedListing desc, L.ListingTitle
			</cfquery>
			<cfif not IsDefined('CategoryID') and not IsDefined('CategoryURL')>
				<cflocation url="#Request.HTTPURL#" addToken="no">
			<cfelseif IsDefined('CategoryURL')>
				<cfif getListings2.RecordCount>
					<cflocation url="#CategoryURL#?#FilterCriteria#&TME=1" addToken="no">
				<cfelse>
					<cflocation url="#CategoryURL#?#FilterCriteria#" addToken="no">
				</cfif>
			<cfelse>
				<cfif getListings2.RecordCount>
					<cflocation url="#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#CategoryID##FilterCriteria#&TME=1" addToken="no">
				<cfelse>
					<cflocation url="#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#CategoryID##FilterCriteria#" addToken="no">
				</cfif>
			</cfif>
			<cfabort>
		</cfif>
		
		<cfinclude template="header.cfm">
		<script src="js/jquery-1.3.min.js"></script>
		<script src='http://jquery-multifile-plugin.googlecode.com/svn/trunk/jquery.MultiFile.js' type="text/javascript" language="javascript"></script>
		<script>
			function validateForm(f) {	
				
				if (!checkText(f.Email,"Email")) return false;
				if (!checkText(f.ConfirmEmail,"Email Confirm")) return false;
				if (!checkEmail(f.Email,"Email")) return false;
				if (f.Email.value!=f.ConfirmEmail.value) {
					alert('"Your Email Address" and "Confirm Email Address" must be identical.');
					f.Email.focus();
					return false;
				}
				if (!checkText(f.CaptchaEntry,"Match Text")) return false;
				if (!captchaValidate()) return false;
				if (!checkText(f.SubjectLine,"Subject Line")) return false;
				if (!checkText(f.EmailBody,"Message Body")) return false;
							
				if (!checkChecked(f.ListingIDs,"Listings Checkboxes")) {
					return false;
				}
				if ($("input[type=checkbox][name=ListingIDs]:checked").length > 6) {
					alert('There is a limit of six Listings per submission.');
					return false;
				}
				return true;
			}
			$(document).ready(function(){
		        $('#RequestForm').submit(function(){
		            var files = $('#RequestForm input:file');
		            var count=1;
		            files.attr('name',function(){return this.name+''+(count++);});
		            $('#fileCount').val(count-2);
		        });
				
				$('.ListingIDs').click(function() {	
					if ($("input[type=checkbox][name=ListingIDs]:checked").length > 6) {
						alert('Choose up to 6 businesses only.');
						return false;
					}
				});
				
		    });
		</script>
		
		<cfoutput>
		<div class="centercol-inner legacy">
		 	<h1><lh:MS_SitePagePart id="title" class="title"></h1>
			<p>&nbsp;</p>
		
		 	<div class="breadcrumb"><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/">Home</a> &gt; </div>
		
		</cfoutput>
		
			<lh:MS_SitePagePart id="body" class="body">
			<br><br>
			<div id="Listings">
				<cfif not getListings.RecordCount>
					<cfif not getListings2.RecordCount>
						No listings found.
					<cfelse>
						None of the possible listings has an email address, so no request can be sent.
					</cfif>
				<cfelse>
					<cfoutput>
					<form name="RequestForm" id="RequestForm" action="page.cfm?PageID=#Request.TenderPageID#" method="post" enctype="multipart/form-data" ONSUBMIT="return validateForm(this)">
						<cfset captcha = CreateObject("component","cfc.Captcha").init()>
						#captcha.renderScripts()#
						<input type="hidden" name="FileCount" id="fileCount" value="0">
						<input type="hidden" name="CategoryID" id="CategoryID" value="#CategoryID#">
						<input type="hidden" name="CategoryURL" id="CategoryURL" value="#CategoryURL#">
						<table cellpadding="5" cellspacing="0">
							<tr>
								<td style="font:12px Arial,Helvetica,sans-serif;">
									*&nbsp;Your&nbsp;Email&nbsp;Address
								</td>
								<td>
									<input type="text" name="Email" ID="Email" size="42" maxlength="200" value="" style="border:2px solid ##000">
								</td>
							</tr>
							<tr>
								<td style="font:12px Arial,Helvetica,sans-serif;">
									*&nbsp;Confirm&nbsp;Email&nbsp;Address
								</td>
								<td>
									<input type="text" name="ConfirmEmail" ID="ConfirmEmail" size="42" maxlength="200" value="" style="border:2px solid ##000">
								</td>
							</tr>
							<tr>
								<td style="font:12px Arial,Helvetica,sans-serif;" valign="top">
									File
								</td>
								<td style="font:12px Arial,Helvetica,sans-serif;">
									<input type="file" name="EmailFile" ID="EmailFile" maxlength="5" value="" class="multi" accept="txt|pdf|doc|docx|rtf|xls|xlsx|ppt|pptx|gif|jpg|jpeg|tiff" style="border:2px solid ##000">
									
									To attach more than 1 file, click the "Browse" button again. 2MB maximum file size.
								</td>
								
							</tr>
							<tr>
								<td valign="top" style="font:12px Arial,Helvetica,sans-serif;">
									*&nbsp;Match Text<br>
									To protect against spam, please prove you are a real person by typing 
									what you see to the right.  If you can't read it clearly, please click 
									#captcha.renderRefreshButton("refresh")#.
								</td>
								<td>
									#captcha.renderImage()#
									<p>#captcha.renderEntry()#</p>
								</td>
							</tr>
							<tr>
								<td colspan="2">
									<br><strong>Do not use ALL CAPS in the subject line or in your message.  Spam filters consider ALL CAPS to be "shouting", and using all caps can result in your message going into the recipients Spam Folder.</strong>
		<br><br>
								</td>
							</tr>
							<tr>
								<td valign="top" style="font:12px Arial,Helvetica,sans-serif;">
									*&nbsp;Subject&nbsp;Line
								</td>
								<td>
									<input type="text" name="SubjectLine" size="42" maxlength="150" style="border:2px solid ##000">
								</td>
							</tr>
							<tr>
								<td valign="top" style="font:12px Arial,Helvetica,sans-serif;">
									*&nbsp;Your&nbsp;Message
								</td>
								<td>
									<textarea cols="30" rows="5" name="EmailBody" id="EmailBody" id="EmailBody" style="border:2px solid ##000"></textarea>
								</td>
							</tr>
						</table>
						</cfoutput>
						<br>
						<lh:MS_SitePagePart id="bodyListings" class="body">
						<br>
						<table width="100%">
							<cfoutput query="getListings">	
								<cfif CurrentRow mod 2 is "1">
									<tr>
								</cfif>
								<td>
									<input type="checkbox" name="ListingIDs" id="ListingIDs#ListingID#" class="ListingIDs" value="#ListingID#">
								</td>
								<td>
									<a href="#ListingFriendlyURL#" target="_blank"><cfif HasExpandedListing and Len(LogoImage) and FileExists("#Request.ListingUploadedDocsDir#\#LogoImage#")>
										<img src="ListingUploadedDocs/#LogoImage#" alt="#ListingTitle#" width="75"><br>
									</cfif>
									#ListingTitle#</a>
								</td>
								<cfif CurrentRow mod 2 is "1">
									<td>&nbsp;&nbsp;</td>
								<cfelse>
									</tr>
								</cfif>
							</cfoutput>
							<cfif getListings.RecordCount mod 2 is "1">
								<td colspan="2">&nbsp;</td>
								</tr>
							</cfif>
						</table>
						<br>
						<input type="image" id="SIN" name="SIN" value="Send Inquiry Now" src="images/inner/btn.sendinquirynow_off.gif" align="absmiddle" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('SIN','','images/inner/btn.sendinquirynow_on.gif',1)">
					</form>
				</cfif>
			</div>
		
		</div>
	</cfif>
</cfif>
<!-- END CENTER COL -->

<cfinclude template="footer.cfm">
