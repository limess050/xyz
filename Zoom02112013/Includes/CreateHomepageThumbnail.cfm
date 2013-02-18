<cfset ImageDir=Request.ListingImagesDir & "\HomepageThumbnails">
<cfset ImageDirRel="ListingImages/HomepageThumbnails">
<cfparam name="TNLongestSide" default="60">
<cfparam name="LIDir" default="#Request.ListingImagesDir#">

<cffile action="copy" source="#LIDir#\#FileNameForTN#" destination="#Request.ListingImagesDir#\HomepageThumbnails\#FileNameForTN#">
<cfset ResizeFileName=FileNameForTN>
<cfset ResizeToWidth="1">
<cfinclude template="ResizeImage.cfm">
