<!--- This template expects a LinkID. --->

<cfset allFields="LinkID,HeaderID,BodyID,FooterID,BackgroundColorID,ExpandedListingHTML,ExpandedListingFullToolbar,DoIt">
<cfinclude template="includes/setVariables.cfm">
<cfmodule template="includes/_checkNumbers.cfm" fields="HeaderID,BodyID,FooterID,BackgroundColorID,DoIt">

<cfset Edit="0">
<cfimport prefix="lh" taglib="Lighthouse/Tags">

<cfif Len(DoIt)>
	<!--- Check for existing Expanded PDF --->
	<cfquery name="getListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ExpandedListingPDF, L.InProgress, L.DateListed, L.OrderDate, L.OrderID, L.ExpandedListingFee, 
		IsNull(L.ListingFee,0) as ListingFee, L.ExpandedListingOrderID,
		IsNull(L.ExpandedFee,0) as ExpandedFee
		From ListingsView L
		Where L.LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfset expandedFee = 0>
	<cfif not getListing.InProgress><!--- Listing already submitted (even if expandedFee is zero, prorating of ListingFee may still apply) --->
		<cfif Len(getListing.OrderDate)>
			<cfset PostingDate=getListing.OrderDate>
		<cfelse>
			<cfset PostingDate=getListing.DateListed>
		</cfif>
		<cfset expandedFee = getListing.expandedFee>	
	<cfelse>
		<cfset expandedFee = getListing.expandedFee>	
	</cfif>
	<cfif Len(getListing.ExpandedListingPDF)>		
		<cfif FileExists("#Request.ListingUploadedDocsDir#\#getListing.ExpandedListingPDF#")>
			<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#getListing.ExpandedListingPDF#">
		</cfif>
		
		<cfquery name="clearExpanded" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update Listings
			Set ExpandedListingPDF=null	
			Where LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	</cfif>	

	<cfquery name="addHTML" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set ExpandedListingHTML=<cfqueryparam value="#ExpandedListingHTML#" cfsqltype="CF_SQL_VARCHAR">,
		ExpandedListingFullToolbar=<cfqueryparam value="#ExpandedListingFullToolbar#" cfsqltype="CF_SQL_INTEGER">
		<cfif not Len(getListing.ExpandedListingOrderID)><!--- If ExpandedListingOrderID exists, then they have already previously submitted an Expanded Listing, so we don't want to set it back to ExpandedListingInProgress=1 or reset the ExpandedListingFee, since they are editing the already existing Expanded Listing or uploading a new one after deleting the existing one. --->			
			,ExpandedListingFee=<cfqueryparam value="#ExpandedFee#" cfsqltype="CF_SQL_FLOAT">,
			ExpandedListinginProgress = 1
		</cfif>			
		Where LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">		
	</cfquery>
	
	<!--- If listing already has paid for an ELP and the listing has not expired, then just update the ELPHTML field; no need for a new order. --->
	
	<cfquery name="checkForPaidELP" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select ListingID
		From ListingsView
		Where LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">		
		and ( ExpirationDate is null or ExpirationDate >= #application.CurrentDateInTZ# )
		and ExpandedListingOrderID is not null
	</cfquery>
	
	<cfif checkForPaidELP.RecordCount>
		<cflocation url="#lh_getPageLink(7,'myaccount')##AmpOrQuestion#Step=3&StatusMessage=#URLEncodedFormat('Featured Listing saved.')#" addToken="No">
		<cfabort>	
	<cfelse>
		<cflocation url="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=3&LinkID=#LinkID#&StatusMessage=#URLEncodedFormat('Featured Listing saved.')#" addToken="No">
		<cfabort>		
	</cfif>
	
	
</cfif>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Everything DAR - Find What you Need &mdash; Fast!  | Email Lister</title>
<meta http-equiv="X-UA-Compatible" content="IE=7" />
<link href="style.css" rel="stylesheet" type="text/css" />
<link href="expandedlisting.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="Lighthouse/Resources/js/lighthouse_all.js"></script>
<script>
	var CKEDITOR_BASEPATH='ckeditor/';
</script>
<script type="text/javascript" src="ckeditor/ckeditor.js"></script>
</head>
<body>
<!--- <script>alert( CKEDITOR.basePath );</script> --->
<cfoutput>
<div id="popoutWide">
	<!-- popout button --><!--<div id="popout-close"><a href="##"><img src="images/inner/btn.close.gif" width="61" height="17" alt="CLOSE" onclick="tb_remove()"/></a></div>-->
	<!-- popout content -->
	<div id="popout-content">
		<cfif not IsDefined('LinkID') or not Len(LinkID)>
			No Listing found.
		<cfelse>
			<cfset ExpandedListingFullToolbar="1">
			<cfif Len(HeaderID) and Len(BodyID) and Len(FooterID)>
				<cfset ExpandedListingFullToolbar="0">
				<cfquery name="getHeader"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					Select HTML
					From Headers
					Where HeaderID =  <cfqueryparam value="#HeaderID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				<cfquery name="getBody"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					Select HTML
					From Bodies
					Where BodyID =  <cfqueryparam value="#BodyID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				<cfquery name="getFooter"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					Select HTML
					From Footers
					Where FooterID =  <cfqueryparam value="#FooterID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				
				<cfset ExpandedHTML=getHeader.HTML & ' ' & getBody.HTML & ' ' & getFooter.HTML>
				
				<cfif Len(BackgroundColorID)>
					<cfswitch expression="#BackgroundColorID#">
						<cfcase value="2">
							<cfset ExpandedHTML=ReplaceNoCase(ExpandedHTML,'class="white"','class="blue"','ALL')>
						</cfcase>
						<cfcase value="3">
							<cfset ExpandedHTML=ReplaceNoCase(ExpandedHTML,'class="white"','class="mint"','ALL')>
						</cfcase>
						<cfcase value="4">
							<cfset ExpandedHTML=ReplaceNoCase(ExpandedHTML,'class="white"','class="wheat"','ALL')>
						</cfcase>
						<cfcase value="5">
							<cfset ExpandedHTML=ReplaceNoCase(ExpandedHTML,'class="white"','class="lilac"','ALL')>
						</cfcase>
					</cfswitch>
				</cfif>
			<cfelse>
				<cfquery name="getListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					Select L.ListingID, L.ExpandedListingHTML, L.ExpandedListingFullToolbar
					From Listings L
					Where LinkID =  <cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				<cfset ExpandedHTML=getListing.ExpandedListingHTML>
				<cfif Len(ExpandedHTML)>				
					<cfset ExpandedListingFullToolbar=getListing.ExpandedListingFullToolbar>
				</cfif>
			</cfif>
			
			<div id="SpacerToForceToolbarDown">
				<p><br /></p>
				<p><br /></p>
			</div>
			<form name="PDFForm" action="EditExpandedListingHTML.cfm" method="post">
				<input type="hidden" name="LinkID" ID="LinkID" value="#LinkID#">
				<input type="hidden" name="ExpandedListingFullToolbar" ID="ExpandedListingFullToolbar" value="#ExpandedListingFullToolbar#">
				<input type="hidden" name="DoIt" ID="DoIt" value="1">
				<table>
					<tr>
						<td>
							<p class="greenlarge">Use the HTML editor below to create your featured listing, or upon request ZoomTanzania.com will create it for you.  For ZoomTanzania.com Featured Listing creation fees, <a href="ratecard" target="_blank">click here</a>.<br>&nbsp;<br>
							If you would rather upload a PDF, MS Word or PowerPoint document, use your browser's "Back" button and select "PDF/Word/PowerPoint Upload". <br>&nbsp;<br>
							<!--- Use the simple tool below to create your expanded listing.  For helpful tips on how to use this tool to include hyper-links to your website, or to pdf and other files that you can upload, <a href="#Request.HTTPURL#/expandedlistinginstructions" target="_blank">click here</a>. ---></p>
						</td>
					</tr>
					<tr>
						<td>
							<textarea name="ExpandedListingHTML" id="ExpandedListingHTML">#ExpandedHTML#</textarea>
						</td>
					</tr>
					<tr>
						<td>
							&nbsp;
						</td>
					</tr>
					<tr>
						<td>
							<input type="submit" name="submit" id="submit" value="Save Design"> <input type="button" name="Cancel" id="Cancel" value="Cancel" onClick="javascript:location.href='postalisting?Step=3&LinkID=#LinkID#';">
						</td>
					</tr>
				</table>
			</form>
			<script type="text/javascript">
			<cfif ExpandedListingFullToolbar><!--- Show fuller toolbar for Open template or Exp Listing that started as open template --->
				CKEDITOR.replace( 'ExpandedListingHTML',
					{
				        filebrowserImageUploadUrl : 'fileUpload.cfm',
						filebrowserUploadUrl : 'fileUpload.cfm',
						toolbar :
						[
							['Source'],
							['Cut','Copy','Paste','PasteText','PasteFromWord','-','Print', 'SpellChecker', 'Scayt'],
							['Undo','Redo','-','Find','Replace','-','SelectAll','RemoveFormat'],
							'/',
							['Bold','Italic','Underline','Strike','-','Subscript','Superscript'],
							['NumberedList','BulletedList','-','Outdent','Indent','Blockquote'],
							['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
							['Link','Unlink','Anchor'],
							['Image','Flash','Table','HorizontalRule','Smiley','SpecialChar','PageBreak'],
							['ShowBlocks'],
							'/',
							['Styles','Format','Font','FontSize'],
							['TextColor','BGColor']
						]
					});
			<cfelse><!--- Show simpler toolbar for editing templates or Exp Listings that started as preset templates --->
				CKEDITOR.replace( 'ExpandedListingHTML',
					{
				        filebrowserImageUploadUrl : 'fileUpload.cfm',
						filebrowserUploadUrl : 'fileUpload.cfm',
						toolbar :
						[
							['Cut','Copy','Paste','PasteText','-','Print', 'SpellChecker', 'Scayt'],
							['Undo','Redo','-','-','SelectAll'],
							['Link','Unlink'],
							['Image','Table','HorizontalRule','Smiley','SpecialChar'],
							'/',
							['Bold','Italic','-','Subscript','Superscript'],
							['NumberedList','BulletedList','-','Outdent','Indent'],
							['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
							['Font','FontSize'],
							['TextColor','BGColor']
						]
					});
			</cfif>
			</script>
		</cfif>
	</div> 
</div>
<div id="SpacerToForceScrollBar">
	<p><br /></p>
	<p><br /></p>
	<p><br /></p>
	<p><br /></p>
</div>
</cfoutput>
</body>
</html>