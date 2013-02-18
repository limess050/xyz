
<cfsetting requesttimeout="1800">


<cfquery name="getImage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select FileName 
	From ListingImages
	Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	and ListingImageID=<cfqueryparam value="#DeleteImageID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfif getImage.RecordCount>
	<cfset FullSizeImageName="#listDeleteAt(getImage.FileName,listLen(getImage.FileName,"."),".")#FS.#ListLast(getImage.FileName,".")#">
	<cfif FileExists("#request.ListingImagesDir#\#getImage.FileName#")>
		<cffile action="Delete" file="#request.ListingImagesDir#\#getImage.FileName#">
	</cfif>
	<cfif FileExists("#request.ListingImagesDir#\#FullSizeImageName#")>
		<cffile action="Delete" file="#request.ListingImagesDir#\#FullSizeImageName#">
	</cfif>
	
	<cfquery name="deleteImage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Delete From ListingImages
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
		and ListingImageID=<cfqueryparam value="#DeleteImageID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
</cfif>
