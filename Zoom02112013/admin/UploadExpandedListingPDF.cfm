<!--- This template expects a ListingID. --->

<cfset allFields="ListingID,DoIt">
<cfinclude template="../includes/setVariables.cfm">
<cfmodule template="../includes/_checkNumbers.cfm" fields="DoIt">

<cfset Edit="0">
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfif Len(DoIt)>
	<!--- Check for existing PDF --->
	<cfquery name="getListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select ExpandedListingPDF, InProgress
		From Listings
		Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfif Len(getListing.ExpandedListingPDF)>		
		<cfif FileExists("#Request.ListingUploadedDocsDir#\#getListing.ExpandedListingPDF#")>
			<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#getListing.ExpandedListingPDF#">
		</cfif>
	</cfif>
		
	<cfquery name="clearExpanded" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set ExpandedListingPDF=null,
		ExpandedListingHTML=null		
		Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	
	<cffile action="upload" filefield="PDFFile" destination="#Request.ListingUploadedDocsDir#" nameconflict="MakeUnique">
	
	<!--- Check file extension --->
	<cfif Not ListFindNoCase("pdf",cffile.ClientFileExt)>
		<cfif FileExists("#cffile.ServerDirectory#\#cffile.ServerFile#")>
			<cffile action="Delete" file="#cffile.ServerDirectory#\#cffile.ServerFile#">
		</cfif>
		<cflocation url="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=3&ListingID=#ListingID#&StatusMessage=#URLEncodedFormat('The file you uploaded was not a PDF. Please try again.')#" addToken="No">
	</cfif>
	
	<cfset fileName = file.serverFile>
	<cfset newFileName = REReplaceNoCase(fileName,"[## ?&]","_","ALL")>
	<cfif fileName is not newFileName>
		<cffile action="rename" source="#Request.ListingUploadedDocsDir#\#fileName#" destination="#Request.ListingUploadedDocsDir#\#newFileName#">
	</cfif>
	<cfquery name="addDoc" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set ExpandedListingPDF=<cfqueryparam value="#newFileName#" cfsqltype="CF_SQL_VARCHAR">
		<cfif getListing.InProgress>
			, ExpandedListingFee=(Select ExpandedFee From ListingTypes Where ListingTypeID=Listings.ListingTypeID)
		</cfif>
		Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cflocation url="Listings.cfm?Action=Edit&PK=#ListingID#" addToken="No">
	<cfabort>
	
</cfif>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Everything DAR - Find What you Need &mdash; Fast!  | Email Lister</title>
<meta http-equiv="X-UA-Compatible" content="IE=7" />
<link href="style.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../Lighthouse/Resources/js/lighthouse_all.js"></script>
<script>
	function validateForm(formObj) {	
		if (!checkText(formObj.elements["PDFFile"],"PDF File")) return false;	
		var fileNameLen=formObj.elements["PDFFile"].value.length;
		var lastThreeStartPoint=fileNameLen-3;
		if (formObj.elements["PDFFile"].value.substr(lastThreeStartPoint)!='pdf' && formObj.elements["PDFFile"].value.substr(lastThreeStartPoint)!='PDF') {
			alert('The uploaded file must be a PDF.');
			return false;
		}
		return true;
	}
</script>
</head>
<body>
<cfoutput>
<div id="popout">
	<!-- popout button --><!--<div id="popout-close"><a href="##"><img src="images/inner/btn.close.gif" width="61" height="17" alt="CLOSE" onclick="tb_remove()"/></a></div>-->
	<!-- popout content -->
	<div id="popout-content">
		<cfif not IsDefined('ListingID') or not Len(ListingID)>
			No Listing found.
		<cfelse>
			<form name="PDFForm" action="UploadExpandedListingPDF.cfm" ENCTYPE="multipart/form-data" method="post" onSubmit="return validateForm(this)">
				<input type="hidden" name="ListingID" ID="ListingID" value="#ListingID#">
				<input type="hidden" name="DoIt" ID="DoIt" value="1">
				<table>
					<tr>
						<td>
							*&nbsp;PDF&nbsp;File
						</td>
						<td>
							<input type="file" name="PDFFile" ID="PDFFile" size="42" maxlength="200" value="">
						</td>
					</tr>
					<tr>
						<td colspan="2">
							&nbsp;
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<input type="submit" name="submit" id="submit" value="Upload File">
						</td>
					</tr>
				</table>
			</form>
		</cfif>
	</div> 
</div>

</cfoutput>
</body>
</html>