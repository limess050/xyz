<!--- This template expects a ListingID. --->

<cfset allFields="LinkID,DoIt">
<cfinclude template="includes/setVariables.cfm">
<cfmodule template="includes/_checkNumbers.cfm" fields="DoIt">

<cfset Edit="0">
<cfimport prefix="lh" taglib="Lighthouse/Tags">

<cfif Len(DoIt)>
	<!--- Check for existing PDF --->
	<cfquery name="getListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ExpandedListingPDF, L.InProgress, L.DateListed, L.OrderDate, L.OrderID, L.ExpandedListingFee, 
		IsNull(L.ListingFee,0) as ListingFee, L.ExpandedListingOrderID,
		IsNull(L.ExpandedFee,0) as ExpandedFee
		From ListingsView L
		Where L.LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfset expandedFee = 0>
	<cfif not getListing.InProgress><!--- Listing already submitted (even if expandedFee is zero, prorating of ListingFee may still apply)  --->
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
	</cfif>
		
	<cfquery name="clearExpanded" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set ExpandedListingPDF=null,
		ExpandedListingHTML=null,
		ExpandedListingFullToolbar=0	
		Where LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	
	<cffile action="upload" filefield="PDFFile" destination="#Request.ListingUploadedDocsDir#" nameconflict="MakeUnique">
	
	<!--- Check file extension --->
	<cfif Not ListFindNoCase("pdf,jpg,jpeg",cffile.ClientFileExt)>
		<cfif FileExists("#cffile.ServerDirectory#\#cffile.ServerFile#")> 
			<cffile action="Delete" file="#cffile.ServerDirectory#\#cffile.ServerFile#">
		</cfif>
		<cflocation url="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=3&LinkID=#LinkID#&StatusMessage=#URLEncodedFormat('The file you uploaded was not a JPG or PDF file. Please try again.')#" addToken="No">
	</cfif>
	
	<cfset fileName = file.serverFile>
	<cfset newFileName = DateFormat(Now(),"DDMMYY") & TimeFormat(Now(),"HHmmss") & REReplaceNoCase(fileName,"[## ?&]","_","ALL")>
	<cfif fileName is not newFileName>
		<cffile action="rename" source="#Request.ListingUploadedDocsDir#\#fileName#" destination="#Request.ListingUploadedDocsDir#\#newFileName#">
	</cfif>
	<cfquery name="addDoc" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set ExpandedListingPDF=<cfqueryparam value="#newFileName#" cfsqltype="CF_SQL_VARCHAR">
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
		<cflocation url="#lh_getPageLink(7,'myaccount')##AmpOrQuestion#Step=3&StatusMessage=#URLEncodedFormat('Featured Listing document uploaded.')#" addToken="No">
		<cfabort>	
	<cfelse>
		<cflocation url="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=3&LinkID=#LinkID#&StatusMessage=#URLEncodedFormat('Featured Listing document uploaded.')#" addToken="No">
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
<script type="text/javascript" src="Lighthouse/Resources/js/lighthouse_all.js"></script>
<script>
	function validateForm(formObj) {	
		if (!checkText(formObj.elements["PDFFile"],"PDF File")) return false;	
		var fileNameLen=formObj.elements["PDFFile"].value.length;
		var lastThreeStartPoint=fileNameLen-3;
		var lastFourStartPoint=fileNameLen-4;
		var allowUpload=0;
		if (formObj.elements["PDFFile"].value.substr(lastThreeStartPoint)=='pdf' || formObj.elements["PDFFile"].value.substr(lastThreeStartPoint)=='PDF' || formObj.elements["PDFFile"].value.substr(lastThreeStartPoint)=='jpg' || formObj.elements["PDFFile"].value.substr(lastThreeStartPoint)=='JPG' || formObj.elements["PDFFile"].value.substr(lastFourStartPoint)=='jpeg' || formObj.elements["PDFFile"].value.substr(lastFourStartPoint)=='JPEG') {
			allowUpload=1;
		}
		//alert(formObj.elements["PDFFile"].value.substr(lastThreeStartPoint));
		if (allowUpload==0) {
			alert('The uploaded file must be a JPG or PDF file.');
			return false;
		}
		return true;
	}
</script>
</head>
<body>
<cfoutput>
<p><br /></p>
<p><br /></p>
<p><br /></p>
		<cfif not IsDefined('LinkID') or not Len(LinkID)>
			No Listing found.
		<cfelse>
			<form name="PDFForm" action="UploadExpandedListingPDF.cfm" ENCTYPE="multipart/form-data" method="post" onSubmit="return validateForm(this)">
				<input type="hidden" name="LinkID" ID="LinkID" value="#LinkID#">
				<input type="hidden" name="DoIt" ID="DoIt" value="1">
				<table>
					<tr>
						<td>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						</td>
						<td>
							*&nbsp;JPG or PDF File:
						</td>
						<td>
							<input type="file" name="PDFFile" ID="PDFFile" size="42" maxlength="200" value="">
						</td>
					</tr>
					<tr>
						<td colspan="3">
							&nbsp;
						</td>
					</tr>
					<tr>
						<td>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						</td>
						<td>&nbsp;</td>
						<td>
							<input type="submit" name="submit" id="submit" value="Upload File">
							<input type="button" name="Cancel" id="Cancel" value="Cancel" onClick="javascript:history.back(1);">
						</td>
					</tr>
				</table>
			</form>
		</cfif>


</cfoutput>
</body>
</html>
