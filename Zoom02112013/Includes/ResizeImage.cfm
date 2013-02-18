<!--- Resizes image so lognest side is resized to passed value of TNLongestSide
Expects:
	ImageDir
	ImageDirRel
	ResizeFileName
 --->
<cfparam name="TNLongestSide" default="225">
<cfparam name="TNTwoLongestSide" default="">
<cfparam name="ResizeToWidth" default="0">

<cfif IsDefined('resizeFileName')>
	<cfset imgPath = "#ImageDir#\#resizeFileName#">
	<cfimage source="#ImageDir#\#resizeFileName#" action="info" structName="NewImageInfo">
	
	<cfif Len(TNTwoLongestSide)><!--- Create second, smaller Thumbnail for use on Listing Results pages --->
		<cfset TNTwoFileName=ReplaceNoCase(resizeFileName,'.jpg','Two.jpg','All')>
		<cfset TNTwoFileName=ReplaceNoCase(TNTwoFileName,'.jpeg','Two.jpg','All')>
		<cfset TNTwoFileName=ReplaceNoCase(TNTwoFileName,'.gif','Two.gif','All')>
		<cfset TNTwoFileName=ReplaceNoCase(TNTwoFileName,'.png','Two.png','All')>
		<cfif NewImageInfo.Width gte NewImageInfo.Height and NewImageInfo.Width gt TNTwoLongestSide><!--- Resize image --->
			<cfset ImageToResize=ImageNew("../#ImageDirRel#/#resizeFileName#")>
			<cfset ImageResize(ImageToResize,"#TNTwoLongestSide#","","mediumquality",1)>
			<cfimage source="#ImageToResize#" action="write" destination="#ImageDir#\#TNTwoFileName#" overwrite="yes">
		<cfelseif NewImageInfo.Width lt NewImageInfo.Height and NewImageInfo.Height gt TNTwoLongestSide><!--- Resize image --->
			<cfset ImageToResize=ImageNew("../#ImageDirRel#/#resizeFileName#")>
			<cfset ImageResize(ImageToResize,"","#TNTwoLongestSide#","mediumquality",1)>
			<cfimage source="#ImageToResize#" action="write" destination="#ImageDir#\#TNTwoFileName#" overwrite="yes">
		<cfelse><!--- Resample image to reduce file size --->
			<cfset ImageToResize=ImageNew("../#ImageDirRel#/#resizeFileName#")>
			<cfset ImageResize(ImageToResize,"#NewImageInfo.Width#","","mediumquality",1)>
			<cfimage source="#ImageToResize#" action="write" destination="#ImageDir#\#TNTwoFileName#" overwrite="yes">
		</cfif>
	</cfif>
	
	 
	<cfif ResizeToWidth or (NewImageInfo.Width gte NewImageInfo.Height and NewImageInfo.Width gt TNLongestSide)><!--- Resize image --->
		<cfset ImageToResize=ImageNew("../#ImageDirRel#/#resizeFileName#")>
		<cfset ImageResize(ImageToResize,"#TNLongestSide#","","mediumquality",1)>
		<cfimage source="#ImageToResize#" action="write" destination="#ImageDir#\#resizeFileName#" overwrite="yes">
	<cfelseif NewImageInfo.Width lt NewImageInfo.Height and NewImageInfo.Height gt TNLongestSide><!--- Resize image --->
		<cfset ImageToResize=ImageNew("../#ImageDirRel#/#resizeFileName#")>
		<cfset ImageResize(ImageToResize,"","#TNLongestSide#","mediumquality",1)>
		<cfimage source="#ImageToResize#" action="write" destination="#ImageDir#\#resizeFileName#" overwrite="yes">
	<cfelse><!--- Resample image to reduce file size --->
		<cfset ImageToResize=ImageNew("../#ImageDirRel#/#resizeFileName#")>
		<cfset ImageResize(ImageToResize,"#NewImageInfo.Width#","","mediumquality",1)>
		<cfimage source="#ImageToResize#" action="write" destination="#ImageDir#\#resizeFileName#" overwrite="yes">
	</cfif>
</cfif>