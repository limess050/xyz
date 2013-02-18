
<cfsetting showdebugoutput="no">


<cffunction name="Get" access="remote" returntype="string" displayname="Creates the HTML to be shown in the Expanded Listing div in the Add A Listing Step 3">
	<cfargument name="LinkID" required="yes">
	<cfargument name="ELPOnStepTwo" default="0">
	
	<cfset rString = "">
	 
	<cfquery name="getListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ListingID, L.ListingTypeID, IsNull(L.ListingFee,0) as ListingFee, L.ExpandedListingPDF, L.ExpandedListingHTML,
		L.OrderDate, L.ExpandedListingFee, L.OrderID, L.inProgress,
		IsNull(L.ExpandedFee,0)  as ExpandedFee,
		L.ExpandedListingOrderID
		From ListingsView L
		Where LinkID =  <cfqueryparam value="#arguments.LinkID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfif not Len(getListing.ExpandedListingOrderID) and Len(getListing.ExpandedListingFee) and getListing.ExpandedFee neq getListing.ExpandedListingFee>
		<cfquery name="getListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update Listings
			Set ExpandedListingFee=<cfqueryparam value="#getListing.ExpandedFee#" cfsqltype="CF_SQL_MONEY">
			Where LinkID =  <cfqueryparam value="#arguments.LinkID#" cfsqltype="CF_SQL_VARCHAR">
			
			Select L.ListingID, L.ListingTypeID, IsNull(L.ListingFee,0) as ListingFee, L.ExpandedListingPDF, L.ExpandedListingHTML,
			L.OrderDate, L.ExpandedListingFee, L.OrderID, L.inProgress,
			IsNull(L.ExpandedFee,0)  as ExpandedFee,
			L.ExpandedListingOrderID
			From ListingsView L
			Where LinkID =  <cfqueryparam value="#arguments.LinkID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	</cfif>
	 	
	<cfoutput>
		<cfif not Len(getListing.ExpandedListingPDF) and not Len(getListing.ExpandedListingHTML)>
			<cfif getListing.inProgress EQ 0>
				<cfset totalListingFee = 0>
			<cfelse>
				<cfset TotalListingFee=getListing.ListingFee>
			</cfif>	
			<cfsavecontent variable="ExpListingDisplayHTML">
				<cfset expandedFee = 0>
				<cfif getListing.orderDate NEQ "" AND getListing.expandedFee NEQ "">
					<cfset expandedFee = getListing.expandedFee>
				<cfelse>
					<cfset expandedFee = getListing.expandedFee>	
				</cfif>
				<div id="ExpandedListingIntro">
					<cfif arguments.ELPOnStepTwo>
						<strong>Upload a flier or other document that provides more information about this event.</strong>
					<cfelse>
						<strong><cfif Len(getListing.ExpandedListingOrderID)>This listing includes a Featured Listing. Use the buttons below to make edits, if necessary.<cfelse>Featured Listing Option <cfif ExpandedFee neq "0">= #DollarFormat(expandedFee)#<cfelse>at no additional fee.</cfif></cfif></strong> 
						&nbsp;&nbsp;<a href="FeaturedListingExample.pdf" target="_blank">See Featured Listing Example</a><br>
						Featured listings include your logo and allow you to upload and distribute your brochure, menu, flier, company profile, advert or any document you choose. Featured listings show first in all search results and are 215% more likely to be viewed than text only listings.
					
						<input type="hidden" name="ListingFee" id="ListingFee" value="<cfif getListing.InProgress>#getListing.ListingFee#<cfelse>0</cfif>">
						<input type="hidden" name="ExpandedListingFee" id="ExpandedListingFee" value="0">
						<input type="hidden" name="TotalListingFee" id="TotalListingFee" value="#TotalListingFee#">
					</cfif>
				</div>
				<br />
				<div id="ExpandedListingOptions">
					<table>
						<tr>
							<td>
								<input type="button" name="PDFUpload" id="PDFUpload" value="Add A Featured Listing" class="btn" onClick="openELPForm();" />&nbsp;&nbsp;
							</td>
							<!--- <td valign="top">
								<span>Easily upload JPG or PDF files (brochures, fliers, existing print advertisements, company profiles etc.).  IMPORTANT&nbsp;-&nbsp;Save significant upload time and ensure the majority of site can view your file by reading our <a href="fileoptimization" target="_blank">File Optimization Hints</a> before uploading.</span>
							</td> --->
						</tr>
					</table>
				</div>
				<hr>
			</cfsavecontent>
		<cfelse>
			<cfif getListing.InProgress>
				<cfset TotalListingFee=getListing.ListingFee + getListing.ExpandedFee>
			<cfelse>
				<cfset TotalListingFee=getListing.ExpandedFee>
			</cfif>	
			<cfsavecontent variable="ExpListingDisplayHTML">
				<cfif not arguments.ELPOnStepTwo>				
					<div style="display:none" id="expandedFee">#getListing.ExpandedFee#</div>
					<div id="ExpandedListingIntro">
						<strong>This listing includes a Featured Listing<cfif not Len(getListing.ExpandedListingOrderID)> for <cfif Len(getListing.ExpandedFee) and getListing.ExpandedFee neq "0">an additional #DollarFormat(getListing.ExpandedFee)#<cfelse>no additional fee</cfif></cfif>.</strong>
						<input type="hidden" name="ListingFee" id="ListingFee" value="<cfif getListing.InProgress>#getListing.ListingFee#<cfelse>0</cfif>">
						<input type="hidden" name="ExpandedListingFee" id="ExpandedListingFee" value="#getListing.ExpandedFee#">
						<input type="hidden" name="TotalListingFee" id="TotalListingFee" value="#TotalListingFee#">
					</div>
				</cfif>
				<br />
				<cfif Len(getListing.ExpandedListingPDF)>
					<div id="ExpandedListingOptions">
						Featured Listing File <input type="button" name="ViewPDF" id="ViewPDF" value="View" class="btn" onClick="window.open('#Request.HTTPSURL#/ListingUploadedDocs/#getListing.ExpandedListingPDF#')" /> <a href="##" onClick="if(confirm('Are you sure you want to delete this?')){deleteExpandedListing();};"><input type="button" name="DeletePDF" id="DeletePDF" value="Delete" class="btn" /></a> <a href="javascript:void(0);" onClick="openELPForm();"><input type="button" name="EditPDF" id="EditPDF" value="Edit" class="btn" /></a>
					</div>
				<cfelse>
					<div id="ExpandedListingOptions">
						Featured Listing Design <input type="button" name="ViewHTML" id="ViewHTML" value="View" class="btn" onclick="window.open('#Request.HTTPSURL#/ExpandedListing.cfm?ListingID=#getListing.ListingID#&Preview=1')" /> <input type="button" name="EditHTML" id="EditHTML" value="Edit" class="btn" onClick="location.href='#Request.HTTPSURL#/EditExpandedListingHTML.cfm?LinkID=#LinkID#&height=700&width=1052'" /> <a href="##" onClick="if(confirm('Are you sure you want to delete this?')){deleteExpandedListing();};"><input type="button" name="DeleteHTML" id="DeleteHTML" value="Delete" class="btn" /> <a href="##" onClick="if(confirm('Are you sure you want to replace this?')){deleteExpandedListing();};"><input type="button" name="DeleteHTML" id="DeleteHTML" value="Replace" class="btn" /></a>
					</div>
				</cfif>
				<hr>
			</cfsavecontent>
		</cfif>
	</cfoutput>
	<cfset SubtotalAmount=TotalListingFee>
	<cfinclude template="VATCalc.cfm">
	<cfset PaymentAmount=SubtotalAmount+VAT>
	<cfset ResponseVars["ExpListingDisplayHTML"]= "#ExpListingDisplayHTML#" />
	<cfset ResponseVars["SubtotalAmount"]= "#SubtotalAmount#" />
	<cfset ResponseVars["VAT"]= "#VAT#" />
	<cfset ResponseVars["PaymentAmount"]= "#PaymentAmount#" />
	<cfset rString=serializeJSON(ResponseVars)>
 	<cfreturn rString>
</cffunction>

<cffunction name="OpenForm" access="remote" returntype="string" displayname="Creates the upload form HTML to be shown in the Expanded Listing div in the Add A Listing Step 3">
	<cfargument name="LinkID" required="yes">
	<cfargument name="ELPOnStepTwo" default="0">
	<cfargument name="ListingTypeID" default="">
	
	<cfset rString = "">
	
	<cfif not ELPOnStepTwo or Len(LinkID)>
		<cfquery name="getListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select L.ListingID, L.ListingTypeID, IsNull(L.ListingFee,0) as ListingFee, L.ExpandedListingPDF, L.ExpandedListingHTML,
			L.OrderDate, L.ExpandedListingFee, L.OrderID, L.inProgress,
			IsNull(L.ExpandedFee,0)  as ExpandedFee,
			L.ExpandedListingOrderID, 
			L.LogoImage, L.ELPTypeID, L.ELPTypeOther, L.ELPTypeThumbnailImage, L.ELPThumbnailFromDoc,
			E.Descr as ELPType
			From ListingsView L
			Left Outer Join ELPTypes E on L.ELPTypeID=E.ELPTypeID
			Where LinkID =  <cfqueryparam value="#arguments.LinkID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<cfif not Len(getListing.ExpandedListingOrderID) and Len(getListing.ExpandedListingFee) and getListing.ExpandedFee neq getListing.ExpandedListingFee>
			<cfquery name="getListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Update Listings
				Set ExpandedListingFee=<cfqueryparam value="#getListing.ExpandedFee#" cfsqltype="CF_SQL_MONEY">
				Where LinkID =  <cfqueryparam value="#arguments.LinkID#" cfsqltype="CF_SQL_VARCHAR">
				
				Select L.ListingID, L.ListingTypeID, IsNull(L.ListingFee,0) as ListingFee, L.ExpandedListingPDF, L.ExpandedListingHTML,
				L.OrderDate, L.ExpandedListingFee, L.OrderID, L.inProgress,
				IsNull(L.ExpandedFee,0)  as ExpandedFee,
				L.ExpandedListingOrderID, 
				L.LogoImage, L.ELPTypeID, L.ELPTypeOther, L.ELPTypeThumbnailImage, L.ELPThumbnailFromDoc,
				E.Descr as ELPType
				From ListingsView L
				Left Outer Join ELPTypes E on L.ELPTypeID=E.ELPTypeID
				Where LinkID =  <cfqueryparam value="#arguments.LinkID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		</cfif>
	</cfif> 
	
	<cfif Len(LinkID) and (Len(getListing.LogoImage) or Len(getListing.ELPTypeThumbnailImage))>
		<cfset HasELPImages="1">
	<cfelse>
		<cfset HasELPImages="0">					
	</cfif>
	
	<cfquery name="getELPTypes"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select ElpTypeID as selectValue, Descr as SelectText, Other_Fl
		From ELPTypes
		Order By OrderNum
	</cfquery>
	 	
	<cfoutput>
		<cfif not arguments.ELPOnStepTwo>
			<cfif getListing.InProgress>
				<cfset TotalListingFee=getListing.ListingFee + getListing.ExpandedFee>
			<cfelse>
				<cfset TotalListingFee=getListing.ExpandedFee>
			</cfif>	
			<cfset expandedFee = getListing.expandedFee>
		</cfif>
		<cfsavecontent variable="ExpListingDisplayHTML">
			<cfif not ELPOnStepTwo and Len(getListing.OrderID)>
				<script>
					function validateELPOnlyForm(formObj) {
						<cfif getListing.ListingTypeID neq "15">
							<cfif not Len(getListing.LogoImage) or not FileExists("#Request.ListingUploadedDocsDir#\#getListing.LogoImage#")>
								if (!checkText(formObj.LogoImage,"Company Logo")) {
									return false;
								}
							</cfif>
						</cfif>
						if (!checkSelected(formObj.ELPTypeID,"Document Type")) {
							return false;
						}		
						if ($("##ELPTypeID").val()==$("##ELPTypeOtherID").val()) {
							if (!checkText(formObj.ELPTypeOther,"Document Type (Other)")) {
								return false;
							}
						}
						<cfif not Len(getListing.ExpandedListingPDF) or not FileExists("#Request.ListingUploadedDocsDir#\#getListing.ExpandedListingPDF#")>
							if (!checkText(formObj.PDFFile,"Document Upload")) {
								return false;
							}
						</cfif>
						return true;
					}
				</script>
				</form>
				<form name="f2" action="includes/ProcessELPDocs.cfm" method="post" ENCTYPE="multipart/form-data" ONSUBMIT="return validateELPOnlyForm(this)">
					<input type="hidden" name="ELPOnlySubmission" value="1">
			</cfif>
			<cfif not arguments.ELPOnStepTwo>
				<div id="ExpandedListingIntro">
					<strong><!--- <cfif Len(getListing.ExpandedListingOrderID)>This listing includes an Expanded Listing. Use the buttons below to make edits, if necessary.<cfelse>For <cfif ExpandedFee neq "0">an additional #DollarFormat(expandedFee)#<cfelse>no additional fee</cfif>, you can create an expanded listing.</cfif> ---></strong>
					<input type="hidden" name="ListingFee" id="ListingFee" value="<cfif getListing.InProgress>#getListing.ListingFee#<cfelse>0</cfif>">
					<input type="hidden" name="ExpandedListingFee" id="ExpandedListingFee" value="#getListing.ExpandedFee#">
					<input type="hidden" name="TotalListingFee" id="TotalListingFee" value="#TotalListingFee#">
				</div>
			</cfif>
			<br />
			<div id="ExpandedListingOptions">
				<cfif ELPOnStepTwo>
					Upload a flier or brochure about this <cfif ListingTypeID is "9">Travel Special<cfelse>event</cfif>.  JPG, GIF, PNG, PDF file formats are accepted.
				<cfelse>
					Featured listings <cfif getListing.ListingTypeID neq "15">include your logo and </cfif>allow you to upload and distribute your brochure, menu, flier, company profile, advert or any document you choose. Featured listings show first in all search results and are 251% more likely to be view than text only listings.	
				</cfif>
				
				<br><br>
				<cfif HasELPImages>
					<strong><em>Upload only the documents you want to replace.<br><br></em></strong>
				</cfif>
				
				<table>
					<cfif not ELPOnStepTwo and getListing.ListingTypeID neq "15">
						<tr>
							<td>
								&nbsp;&nbsp;
							</td>
							<td>
								*&nbsp;1. Your Company Logo - JPG, GIF or PNG Only:
							</td>
							<cfif HasELPImages>
								<td>
									<cfif Len(getListing.LogoImage) and FileExists("#Request.ListingUploadedDocsDir#\#getListing.LogoImage#")>
										<img src="ListingUploadedDocs/#getListing.LogoImage#" width="50">
										<input type="hidden" name="HasLogoImage" value="#getListing.LogoImage#">
									<cfelse>
										&nbsp;
									</cfif>									
								</td>
							</cfif>
							<td>
								<input type="file" name="LogoImage" ID="LogoImage" size="42" maxlength="200" value="">
							</td>
						</tr>
					</cfif>
					<tr>
						<td>
							&nbsp;&nbsp;
						</td>
						<td>
							<cfif not ELPOnStepTwo>*&nbsp;</cfif><cfif ELPOnStepTwo or getListing.ListingTypeID is "15">1<cfelse>2</cfif>. The Document I will upload is a :
						</td>
							<cfif HasELPImages>
								<td>
									&nbsp;								
								</td>
							</cfif>
						<td>
							<select name="ELPTypeID" ID="ELPTypeID">
								<option value="">
								<cfloop query="getELPTypes">
									<option value="#SelectValue#" <cfif (IsDefined('getListing.ELPTypeID') and getListing.ELPTypeID is SelectValue) or (ELPOnStepTwo and SelectValue is "3")>selected</cfif>>#SelectText#
								</cfloop>
							</select>
							<cfloop query="getELPTypes">
								<cfif Other_fl>
									<input type="hidden" name="ELPTypeOtherID" id="ELPTypeOtherID" value="#SelectValue#">
								</cfif>
							</cfloop>
							<div id="ELPTypeOtherDiv" style="display:<cfif Len(LinkID) and Len(getListing.ELPTypeOther)>block<cfelse>none</cfif>;">
								<input type="text" name="ELPTypeOther" value="<cfif Len(LinkID)>#getListing.ELPTypeOther#</cfif>">
							</div>
						</td>
					</tr>
					<tr>
						<td>
							&nbsp;&nbsp;
						</td>
						<td>
							<cfif not ELPOnStepTwo>*&nbsp;</cfif><cfif ELPOnStepTwo or getListing.ListingTypeID is "15">2<cfelse>3</cfif>. Document Upload - JPG, GIF, PNG or PDF Only:
						</td>
							<cfif HasELPImages>
								<td>
									<cfif Len(getListing.ExpandedListingPDF)>	
										<cfset TNFileName=ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(getListing.ExpandedListingPDF,'.jp','TN.jp'),'.gi','TN.gi'),'.pn','TN.pn'),'.pdf','TN.jpg')>
										<cfif FileExists("#Request.ListingUploadedDocsDir#\#TNFileName#")>
											<img src="ListingUploadedDocs/#TNFileName#" width="50">
										</cfif>
										<input type="hidden" name="HasELPDoc" value="#getListing.ExpandedListingPDF#">
										<input type="hidden" name="deleteDocTNs" value="1">
									<cfelse>
										&nbsp;
									</cfif>							
								</td>
							</cfif>
						<td>
							<input type="file" name="PDFFile" ID="PDFFile" size="42" maxlength="200" value="">
							<input type="hidden" name="ProcessELPDocs" id="ProcessELPDocs" value="1">
						</td>
					</tr>
				</table>		
				<!--- <br><br>To highlight your <span id="selectedDocType">#getListing.ELPType# </span>document on your listing page, Zoom will convert this document to a thumbnail image. If you would prefer to highlight your listing with a Feature Image, please upload it below.
				<br><br>	
				Optional Feature Image (JPG, GIF or PNG Only):<br>		
				<table>
					<tr>
						<cfif Len(getListing.ELPTypeThumbnailImage) and FileExists("#Request.ListingUploadedDocsDir#\#getListing.ELPTypeThumbnailImage#") and getListing.ELPThumbnailFromDoc is "0">
							<td>
								<input type="hidden" name="HasELPThumbnailImage" value="#getListing.ELPTypeThumbnailImage#">
								<img src="ListingUploadedDocs/#getListing.ELPTypeThumbnailImage#" width="50" style="margin-bottom: 5px;"><BR>
								<input type="checkbox" name="DeleteELPThumbnailImage" value="1">&nbsp;Delete
							</td>
						</cfif>
						<td>
							<input type="file" name="ELPTypeThumbnailImage" ID="ELPTypeThumbnailImage" size="42" maxlength="200" value="">
						</td>
					</tr>
				</table> --->	
										
				<br><br>						
				<cfif not ELPOnStepTwo><div style="float:right;"><input type="button" name="Cancel Featured Listing" onClick="getExpandedListing();" value="Cancel Featured Listing <cfif HasELPImages>Edits</cfif>" class="btn"></div><br clear="all"></cfif>
										
			</div>
			<cfif not ELPOnStepTwo and Len(getListing.OrderID)>
					<input type="hidden" name="LinkID" value="#LinkID#">
					<input type="submit" name="button" id="button" value="Submit" class="btn" />
				</form>
			</cfif>
			<hr>
		</cfsavecontent>
	</cfoutput>
	<cfif  ELPOnStepTwo>
		<cfset SubtotalAmount=0>
	<cfelse>
		<cfset SubtotalAmount=TotalListingFee>
	</cfif>
	
	<cfinclude template="VATCalc.cfm">
	<cfset PaymentAmount=SubtotalAmount+VAT>
	<cfset ResponseVars["ExpListingDisplayHTML"]= "#ExpListingDisplayHTML#" />
	<cfset ResponseVars["SubtotalAmount"]= "#SubtotalAmount#" />
	<cfset ResponseVars["VAT"]= "#VAT#" />
	<cfset ResponseVars["PaymentAmount"]= "#PaymentAmount#" />
	<cfset rString=serializeJSON(ResponseVars)>
 	<cfreturn rString>
</cffunction>

<cffunction name="DelExL" access="remote" returntype="string" displayname="Deletes the expanded Listing data">
	<cfargument name="LinkID" required="yes">
	
	<cfset rString = "">
	 
	<cfquery name="getListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ExpandedListingPDF, L.ExpandedListingHTML, L.OrderID, ExpandedListingOrderID,
		L.LogoImage, L.ELPTypeThumbnailImage
		From Listings L
		Where LinkID =  <cfqueryparam value="#arguments.LinkID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfif Len(getListing.ExpandedListingPDF) and FileExists("#Request.ListingUploadedDocsDir#\#getListing.ExpandedListingPDF#")>
		<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#getListing.ExpandedListingPDF#">
	</cfif>
	<cfif Len(getListing.LogoImage) and FileExists("#Request.ListingUploadedDocsDir#\#getListing.LogoImage#")>
		<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#getListing.LogoImage#">
	</cfif>
	<cfif Len(getListing.ELPTypeThumbnailImage) and FileExists("#Request.ListingUploadedDocsDir#\#getListing.ELPTypeThumbnailImage#")>
		<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#getListing.ELPTypeThumbnailImage#">
	</cfif>
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set ExpandedListingPDF=null,
		ExpandedListingHTML=null,
		ExpandedListingInProgress = 0,
		ExpandedListingFullToolbar=0,
		ELPTypeThumbnailImage=null,
		ELPTypeID=null,
		ELPTypeOther=null,
		LogoImage=null
		<cfif not Len(getListing.ExpandedListingOrderID)><!--- If not yet submitted (and so no Order record exists yet) remove the ELPFee --->
			, ExpandedListingFee=null
		</cfif>
		Where LinkID =  <cfqueryparam value="#arguments.LinkID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
 	<cfreturn rString>
</cffunction>
