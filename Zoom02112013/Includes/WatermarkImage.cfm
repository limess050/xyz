<cfif isImageFile("#Request.ListingUploadedDocsDir#\#newFileName#")>
	<!--- From: http://www.bennadel.com/blog/775-Learning-ColdFusion-8-CFImage-Part-III-Watermarks-And-Transparency.htm
	and http://www.raymondcamden.com/index.cfm/2010/6/4/Automating-watermarking-of-images-with-ColdFusion --->
	
	<!--- Read in the original image. --->
	<cfset objImage = ImageRead( "#Request.ListingUploadedDocsDir#\#newFileName#" ) />
	 
	<!--- Read in the Kinky Solutions watermark. --->
	<cfset objWatermark = ImageNew(
		"#Request.ListingUploadedDocsDir#\WatermarkImage.png"
		) />
	 
	 
	<!---
		Turn on antialiasing on the existing image
		for the pasting to render nicely.
	--->
	<cfset ImageSetAntialiasing(
		objImage,
		"on"
		) />
	 
	<!---
		When we paste the watermark onto the photo, we don't
		want it to be fully visible. Therefore, let's set the
		drawing transparency to 50% before we paste.
	--->
	<cfset ImageSetDrawingTransparency(
		objImage,
		25
		) />
	 
	<!---
		Paste the watermark on to the image. We are going
		to paste this into the bottom, right corner.
	--->
	<cfset ImagePaste(
		objImage,
		objWatermark,
		((objImage.GetWidth() - objWatermark.GetWidth())/2),
		((objImage.GetHeight() - objWatermark.GetHeight())/2)
		) />
	 
	<!--- 
	<!--- Write it to the browser. --->
	<cfimage
		action="writetobrowser"
		source="#objImage#"
		/> --->
		
	<cfset imageWrite(objImage, "#Request.ListingUploadedDocsDir#/" & newFileName, true)>
</cfif>