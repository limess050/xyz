<cffunction name="Delete" access="remote" returntype="string" displayname="Deletes a Listing Image">
	<cfargument name="LinkID" required="yes">
	<cfargument name="FileName" required="yes">
	<cfset rString = "">
	
	<cfset FullSizeImageName="#listDeleteAt(FileName,listLen(FileName,"."),".")#FS.#ListLast(FileName,".")#">
	
	<cfif FileExists("#Request.ListingImagesDir#\#FileName#")>
		<cffile action="delete" file="#Request.ListingImagesDir#\#FileName#">	
	</cfif>	
	
	<cfif FileExists("#request.ListingImagesDir#\#FullSizeImageName#")>
		<cffile action="Delete" file="#request.ListingImagesDir#\#FullSizeImageName#">
	</cfif>
	
	 
	<cfquery name="DeleteImage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Delete From ListingImages		
		Where ListingID=(Select ListingID From Listings Where LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">)
		and FileName=<cfqueryparam value="#FileName#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	
	<cfset rString = "Success">
	
 	<cfreturn rString>
</cffunction>
