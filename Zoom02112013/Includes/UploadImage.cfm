
<cfsetting requesttimeout="1800">
<cfparam name="ImgPathDir" default="#request.ListingImagesDir#">
<cfparam name="IsMovieImage" default="0">

<cffile action="upload" filefield="#FieldName#" destination="#ImgPathDir#" nameconflict="MakeUnique">

<!--- Check file extension --->
<cfif Not ListFindNoCase("gif,jpg,jpeg,png",cffile.ClientFileExt)>
	<cfif FileExists("#cffile.ServerDirectory#\#cffile.ServerFile#")>
		<cffile action="Delete" file="#cffile.ServerDirectory#\#cffile.ServerFile#">
	</cfif>
	<cflocation url="page.cfm?PageID=#request.AddAListingPageID#&Step=2&LinkID=#LinkID#&FT=#cffile.ClientFileExt#" addToken="No">
</cfif>

<cfset fileName = file.serverFile>
<cfset newFileName = DateFormat(Now(),"DDMMYY") & TimeFormat(Now(),"HHmmss") & REReplaceNoCase(fileName,"[## ?&']","_","ALL")>
<cfif fileName is not newFileName>
	<cffile action="rename" source="#ImgPathDir#\#fileName#" destination="#ImgPathDir#\#newFileName#">
</cfif>

<cfif not IsMovieImage>
	<cfset newFullSizeFileName="#listDeleteAt(newFileName,listLen(newFileName,"."),".")#FS.#ListLast(newFileName,".")#">
	<cffile action="copy" source="#ImgPathDir#\#newFileName#" destination="#ImgPathDir#\#newFullSizeFileName#">
</cfif>

<cfif IsMovieImage>
	<cfset PageDisplayWidth = 216>
<cfelse>
	<cfset PageDisplayWidth = 225>
</cfif>

<cfset FullSizeWidth = 1000>

<cfset imgPath = "#ImgPathDir#\#newFileName#">
<cfimage source="#ImgPathDir#\#newFileName#" action="info" structName="NewImageInfo">

<cfif NewImageInfo.Width gt PageDisplayWidth><!--- Resize image --->
	<cfset ImageToResize=ImageNew("../ListingImages/#NewFileName#")>
	<cfset ImageResize(ImageToResize,"#PageDisplayWidth#","","mediumquality",1)>
	<cfimage source="#ImageToResize#" action="write" destination="#ImgPathDir#\#newFileName#" overwrite="yes">
<cfelse><!--- Resample image to reduce file size --->
	<cfset ImageToResize=ImageNew("../ListingImages/#NewFileName#")>
	<cfset ImageResize(ImageToResize,"#NewImageInfo.Width#","","mediumquality",1)>
	<cfimage source="#ImageToResize#" action="write" destination="#ImgPathDir#\#newFileName#" overwrite="yes">
</cfif>

<cfif not IsMovieImage>
	<cfimage source="#ImgPathDir#\#newFullSizeFileName#" action="info" structName="NewFullSizeImageInfo">
	<cfif NewFullSizeImageInfo.Width gt FullSizeWidth><!--- Resize image --->
		<cfset ImageToResize=ImageNew("../ListingImages/#newFullSizeFileName#")>
		<cfset ImageResize(ImageToResize,"#FullSizeWidth#","","mediumquality",1)>
		<cfimage source="#ImageToResize#" action="write" destination="#ImgPathDir#\#newFullSizeFileName#" overwrite="yes">
	<cfelse><!--- Resample image to reduce file size --->
		<cfset ImageToResize=ImageNew("../ListingImages/#newFullSizeFileName#")>
		<cfset ImageResize(ImageToResize,"#NewFullSizeImageInfo.Width#","","mediumquality",1)>
		<cfimage source="#ImageToResize#" action="write" destination="#ImgPathDir#\#newFullSizeFileName#" overwrite="yes">
	</cfif>

	<cfquery name="addImage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Insert into ListingImages
		(ListingID,FileName,OrderNum)
		VALUES
		(<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">,
		<cfqueryparam value="#newFileName#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#ImageOrderNum#" cfsqltype="CF_SQL_INTEGER">)
	</cfquery>
</cfif>
