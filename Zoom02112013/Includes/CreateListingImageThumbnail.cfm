<cfset ImageDir=Request.ListingImagesDir & "\CategoryThumbnails">
<cfset ImageDirRel="ListingImages/CategoryThumbnails">

<cffile action="copy" source="#Request.ListingImagesDir#\#FileNameForTN#" destination="#Request.ListingImagesDir#\CategoryThumbnails\#FileNameForTN#">
<cfset ResizeFileName=FileNameForTN>
<cfset TNLongestSide="100">
<cfinclude template="ResizeImage.cfm">
