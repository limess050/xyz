<cfset ImageDir=Request.ListingUploadedDocsDir>
<cfset ImageDirRel="ListingUploadedDocs">

<cfif ListFind("pdf,jpg,jpeg,png,gif",Right(ExpandedListingPDF,3))>

	<cfif Right(ExpandedListingPDF,3) is "pdf">
		<cfpdf action = "thumbnail" source="#Request.ListingUploadedDocsDir#\#ExpandedListingPDF#" overwrite="yes" destination="#Request.ListingUploadedDocsDir#" pages="1" scale="100" format="jpg"><!--- CF 8 doesn't allow width to be set by pixels, so make 100% scale image, then resize --->
		<cfset ELPTNFileName=ReplaceNoCase(ExpandedListingPDF,'.pdf','TN.jpg','All')>
		<cffile action="rename" source="#Request.ListingUploadedDocsDir#\#ReplaceNoCase(ExpandedListingPDF,'.pdf','_page_1.jpg','All')#" destination="#Request.ListingUploadedDocsDir#\#ELPTNFileName#">
		<cfset ResizeFileName=ELPTNFileName>
		<cfset TNLongestSide="200">
		<cfset TNTwoLongestSide="175">
		<cfinclude template="ResizeImage.cfm">
		<cfset newTNFileName=ELPTNFileName>
	<cfelse>
		<cfset ELPTNFileName=ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(ExpandedListingPDF,'.jp','TN.jp','All'),'.gi','TN.gi','All'),'.pn','TN.pn','All')>
		<cffile action="copy" source="#Request.ListingUploadedDocsDir#\#ExpandedListingPDF#" destination="#Request.ListingUploadedDocsDir#\#ELPTNFileName#">
		<cfset ResizeFileName=ELPTNFileName>
		<cfset TNLongestSide="200">
		<cfset TNTwoLongestSide="175">
		<cfinclude template="ResizeImage.cfm">
		<cfset newTNFileName=ELPTNFileName>
	</cfif>
	
	<cfquery name="updateELPTN" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set
		ELPTypeThumbnailImage = <cfqueryparam value="#newTNFileName#" cfsqltype="CF_SQL_VARCHAR">, 
		ELPThumbnailFromDoc=1
		Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_VARCHAR">		
	</cfquery>
	
	<cfset ShowELPTypeThumbnailImage=newTNFileName>
<cfelse>
	<cfset ShowELPTypeThumbnailImage="">
</cfif>
