<!--- This template expects a ListingID. --->

<cfset allFields="ListingID,HeaderID,BodyID,FooterID,BackgroundColorID,ExpandedListingHTML,DoIt">
<cfinclude template="../includes/setVariables.cfm">
<cfmodule template="../includes/_checkNumbers.cfm" fields="HeaderID,BodyID,FooterID,BackgroundColorID,DoIt">

<cfset Edit="0">
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfif Len(DoIt)>
	<!--- Check for existing Expanded PDF --->
	<cfquery name="getListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select ExpandedListingPDF, InProgress
		From Listings
		Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfif Len(getListing.ExpandedListingPDF)>		
		<cfif FileExists("#Request.ListingUploadedDocsDir#\#getListing.ExpandedListingPDF#")>
			<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#getListing.ExpandedListingPDF#">
		</cfif>
		
		<cfquery name="clearExpanded" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update Listings
			Set ExpandedListingPDF=null	
			Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	</cfif>
	
	
	<cfquery name="addHTML" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set ExpandedListingHTML=<cfqueryparam value="#ExpandedListingHTML#" cfsqltype="CF_SQL_VARCHAR">
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
<title>Edit Expanded HTML</title>
<meta http-equiv="X-UA-Compatible" content="IE=7" />
<link href="../style.css" rel="stylesheet" type="text/css" />
<link href="../expandedlisting.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../Lighthouse/Resources/js/lighthouse_all.js"></script>
<script>
	var CKEDITOR_BASEPATH='../ckeditor/';
</script>
<script type="text/javascript" src="../ckeditor/ckeditor.js"></script>
</head>
<body>
<!--- <script>alert( CKEDITOR.basePath );</script> --->
<cfoutput>
<div id="popoutWide">
	<!-- popout button --><!--<div id="popout-close"><a href="##"><img src="images/inner/btn.close.gif" width="61" height="17" alt="CLOSE" onclick="tb_remove()"/></a></div>-->
	<!-- popout content -->
	<div id="popout-content">
		<cfif not IsDefined('ListingID') or not Len(ListingID)>
			No Listing found.
		<cfelse>
			
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
					Select L.ListingID, L.ExpandedListingHTML
					From Listings L
					Where ListingID =  <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				<cfset ExpandedHTML=getListing.ExpandedListingHTML>
			</cfif>
			
			<form name="PDFForm" action="EditExpandedListingHTML.cfm" method="post">
				<input type="hidden" name="ListingID" ID="ListingID" value="#ListingID#">
				<input type="hidden" name="DoIt" ID="DoIt" value="1">
				<table>
					<tr>
						<td>
							*&nbsp;Expanded&nbsp;Listing&nbsp;Design
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
							<input type="submit" name="submit" id="submit" value="Save Design">
						</td>
					</tr>
				</table>
			</form>
			<script type="text/javascript">
			CKEDITOR.replace( 'ExpandedListingHTML',
				{
			        filebrowserImageUploadUrl : 'fileUpload.cfm',
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
			</script>
		</cfif>
	</div> 
</div>

</cfoutput>
</body>
</html>