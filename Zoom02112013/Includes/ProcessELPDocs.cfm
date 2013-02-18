<cfparam name="ELPOnlySubmission" default="">
<cfparam name="ELPOnStepTwo" default="0">

<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset Edit="0">
<cfset ImageDir=Request.ListingUploadedDocsDir>
<cfset ImageDirRel="ListingUploadedDocs">

<!--- Test all uploads for valid file types --->
<cfif IsDefined('LogoImage') and Len(LogoImage)>
	<cffile action="upload" filefield="LogoImage" destination="#Request.ListingUploadedDocsDir#" nameconflict="MakeUnique">
	<!--- Check file extension --->
	<cfif Not ListFindNoCase("gif,jpg,jpeg,png",cffile.ClientFileExt)>
		<cfif FileExists("#cffile.ServerDirectory#\#cffile.ServerFile#")> 
			<cffile action="Delete" file="#cffile.ServerDirectory#\#cffile.ServerFile#">
		</cfif>
		<cflocation url="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=3&LinkID=#LinkID#&StatusMessageFileType=#URLEncodedFormat('The Logo Image file you uploaded was not a JPG, GIF or PNG file. Please try again.')#" addToken="No">
		<cfabort>
	</cfif>
	<cfset fileName = file.serverFile>
	<cfset newLogoFileName = DateFormat(Now(),"DDMMYY") & TimeFormat(Now(),"HHmmss") & REReplaceNoCase(ReplaceNoCase(fileName,".jpeg",".jpg"),"[## ?&]","_","ALL")>
	<cfif fileName is not newLogoFileName>
		<cffile action="rename" source="#Request.ListingUploadedDocsDir#\#fileName#" destination="#Request.ListingUploadedDocsDir#\#newLogoFileName#">
	</cfif>
<cfelse>
	<cfset newLogoFileName="">
</cfif>

<cfif IsDefined('PDFFile') and Len(PDFFile)>
	<cffile action="upload" filefield="PDFFile" destination="#Request.ListingUploadedDocsDir#" nameconflict="MakeUnique">	
	<!--- Check file extension --->
	<cfif Not ListFindNoCase("pdf,jpg,jpeg,png,gif",cffile.ClientFileExt)>
		<cfif FileExists("#cffile.ServerDirectory#\#cffile.ServerFile#")> 
			<cffile action="Delete" file="#cffile.ServerDirectory#\#cffile.ServerFile#">
		</cfif>
		<cflocation url="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=3&LinkID=#LinkID#&StatusMessageFileType=#URLEncodedFormat('The Document Upload file you uploaded was not a JPG or PDF file. Please try again.')#" addToken="No">
		<cfabort>
	</cfif>
	<cfset fileName = file.serverFile>
	<cfset newFileName = DateFormat(Now(),"DDMMYY") & TimeFormat(Now(),"HHmmss") & REReplaceNoCase(ReplaceNoCase(fileName,".jpeg",".jpg"),"[## ?&]","_","ALL")>
	<cfif fileName is not newFileName>
		<cffile action="rename" source="#Request.ListingUploadedDocsDir#\#fileName#" destination="#Request.ListingUploadedDocsDir#\#newFileName#">
	</cfif>
	<cfif ELPOnStepTwo>
		<cfinclude template="WatermarkImage.cfm">
	</cfif>	
<cfelse>
	<cfset newFileName="">
</cfif>

<!--- <cfif Len(ELPTypeThumbnailImage) and Len(ELPTypeThumbnailImage)>
	<cffile action="upload" filefield="ELPTypeThumbnailImage" destination="#Request.ListingUploadedDocsDir#" nameconflict="MakeUnique">	
	<!--- Check file extension --->
	<cfif Not ListFindNoCase("gif,jpg,jpeg,png",cffile.ClientFileExt)>
		<cfif FileExists("#cffile.ServerDirectory#\#cffile.ServerFile#")> 
			<cffile action="Delete" file="#cffile.ServerDirectory#\#cffile.ServerFile#">
		</cfif>
		<cflocation url="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=3&LinkID=#LinkID#&StatusMessageFileType=#URLEncodedFormat('The Feature Image file you uploaded was not a JPG, GIF or PNG file. Please try again.')#" addToken="No">
		<cfabort>
	</cfif>	
	<cfset fileName = file.serverFile>
	<cfset newTNFileName = DateFormat(Now(),"DDMMYY") & TimeFormat(Now(),"HHmmss") & REReplaceNoCase(ReplaceNoCase(fileName,".jpeg",".jpg"),"[## ?&]","_","ALL")>
	<cfif fileName is not newTNFileName>
		<cffile action="rename" source="#Request.ListingUploadedDocsDir#\#fileName#" destination="#Request.ListingUploadedDocsDir#\#newTNFileName#">
	</cfif>
<cfelse> --->
	<cfset newTNFileName="">
<!--- </cfif> --->



<cfset expandedFee = 0>
<cfif Len(LinkID)>
	<!--- Check for existing PDF --->
	<cfquery name="getListingPELP" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ExpandedListingPDF, L.InProgress, L.DateListed, L.OrderDate, L.OrderID, L.ExpandedListingFee, 
		IsNull(L.ListingFee,0) as ListingFee, L.ExpandedListingOrderID,
		IsNull(L.ExpandedFee,0) as ExpandedFee, L.DateSort
		From ListingsView L
		Where L.LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfif not getListingPELP.InProgress><!--- Listing already submitted (even if expandedFee is zero, prorating of ListingFee may still apply)  --->
		<cfif Len(getListingPELP.OrderDate)>
			<cfset PostingDate=getListingPELP.OrderDate>
		<cfelse>
			<cfset PostingDate=getListingPELP.DateListed>
		</cfif>
		<cfset expandedFee = getListingPELP.expandedFee>	
	<cfelse>
		<cfset expandedFee = getListingPELP.expandedFee>	
	</cfif>
	
	<cfquery name="clearExpanded" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set ExpandedListingPDF=null,
		ExpandedListingHTML=null,
		ELPTypeThumbnailImage=null,
		ELPTypeID=null,
		ELPTypeOther=null,
		LogoImage=null,
		ExpandedListingFullToolbar=0	
		Where LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
</cfif>

	
<cfif Len(newLogoFileName)><!--- Logo Uploaded --->
	<cfif IsDefined('HasLogoImage') and FileExists("#Request.ListingUploadedDocsDir#\#HasLogoImage#")>
		<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#HasLogoImage#">
	</cfif>	
	<cfset ResizeFileName=newLogoFileName>
	<cfset TNLongestSide="175">
	<cfinclude template="ResizeImage.cfm">
<cfelseif IsDefined('HasLogoImage') and FileExists("#Request.ListingUploadedDocsDir#\#HasLogoImage#")>
	<cfset NewLogoFileName=HasLogoImage>
</cfif>

<cfif Len(newTNFileName)><!--- Optional Feature Image Uploaded --->
	<cfif IsDefined('HasELPThumbnailImage')>
		<cfif FileExists("#Request.ListingUploadedDocsDir#\#HasELPThumbnailImage#")>
			<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#HasELPThumbnailImage#">
		</cfif>
		<cfset SecondThumbnailImageName=ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(HasELPThumbnailImage,'.jp','Two.jp'),'.gi','Two.gi'),'.pn','Two.pn')>
		<cfif FileExists("#Request.ListingUploadedDocsDir#\#SecondThumbnailImageName#")>
			<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#SecondThumbnailImageName#">
		</cfif>
	</cfif>
	<cfif IsDefined('HasELPDoc') and IsDefined('deleteDocTNs')>
		<cfset TNFileName=ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(HasELPDoc,'.jp','TN.jp'),'.gi','TN.gi'),'.pn','TN.pn'),'.pdf','TN.jpg')>
		<cfset TNTwoFileName=ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(TNFileName,'TN.jp','TNTwo.jp'),'TN.gi','TNTwo.gi'),'TN.pn','TNTwo.pn')>
		<cfif FileExists("#Request.ListingUploadedDocsDir#\#TNFileName#")>
			<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#TNFileName#">
		</cfif>
		<cfif FileExists("#Request.ListingUploadedDocsDir#\#TNTwoFileName#")>
			<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#TNTwoFileName#">
		</cfif>
	</cfif>
		
	<cfset ResizeFileName=newTNFileName>
	<cfset TNLongestSide="200">
	<cfset TNTwoLongestSide="175">
	<cfinclude template="ResizeImage.cfm">
	<cfset ELPThumbnailFromDoc="0">
<cfelseif IsDefined('HasELPThumbnailImage') and IsDefined('DeleteELPThumbnailImage')>
	<cfif FileExists("#Request.ListingUploadedDocsDir#\#HasELPThumbnailImage#")>
		<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#HasELPThumbnailImage#">
	</cfif>
	<cfset SecondThumbnailImageName=ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(HasELPThumbnailImage,'.jp','Two.jp'),'.gi','Two.gi'),'.pn','Two.pn')>
	<cfif FileExists("#Request.ListingUploadedDocsDir#\#SecondThumbnailImageName#")>
		<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#SecondThumbnailImageName#">
	</cfif>
	<cfset ELPThumbnailFromDoc="1">
<cfelseif IsDefined('HasELPThumbnailImage') and FileExists("#Request.ListingUploadedDocsDir#\#HasELPThumbnailImage#")>
	<cfset newTNFileName=HasELPThumbnailImage>
	<cfset ELPThumbnailFromDoc="0">
<cfelse>	
	<cfset ELPThumbnailFromDoc="1">
</cfif>

<cfif Len(newFileName) or (IsDefined('HasELPDoc') and FileExists("#Request.ListingUploadedDocsDir#\#HasELPDoc#"))>
	<cfif Len(newFileName)>
		<cfif IsDefined('HasELPDoc')>
			<cfif FileExists("#Request.ListingUploadedDocsDir#\#HasELPDoc#")>
				<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#HasELPDoc#">
			</cfif>
		</cfif>
	<cfelse>
		<cfset NewFileName=HasELPDoc>
	</cfif>
	
	<cfif ELPThumbnailFromDoc is "1" and IsDefined('HasELPDoc')>
		<cfset TNFileName=ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(HasELPDoc,'.jp','TN.jp'),'.gi','TN.gi'),'.pn','TN.pn'),'.pdf','TN.jpg')>
		<cfset TNTwoFileName=ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(TNFileName,'TN.jp','TNTwo.jp'),'TN.gi','TNTwo.gi'),'TN.pn','TNTwo.pn')>
		<cfif FileExists("#Request.ListingUploadedDocsDir#\#TNFileName#")>
			<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#TNFileName#">
		</cfif>
		<cfif FileExists("#Request.ListingUploadedDocsDir#\#TNTwoFileName#")>
			<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#TNTwoFileName#">
		</cfif>
	</cfif>
	
	<cfif Right(newFileName,3) is "pdf">
		<cfpdf action = "thumbnail" source="#Request.ListingUploadedDocsDir#\#newFileName#" overwrite="yes" destination="#Request.ListingUploadedDocsDir#" pages="1" scale="100" format="jpg"><!--- CF 8 doesn't allow width to be set by pixels, so make 100% scale image, then resize --->
		<cfset ELPTNFileName=ReplaceNoCase(newFileName,'.pdf','TN.jpg','All')>
		<cffile action="rename" source="#Request.ListingUploadedDocsDir#\#ReplaceNoCase(newFileName,'.pdf','_page_1.jpg','All')#" destination="#Request.ListingUploadedDocsDir#\#ELPTNFileName#">
		<cfset ResizeFileName=ELPTNFileName>
		<cfset TNLongestSide="200">
		<cfset TNTwoLongestSide="175">
		<cfinclude template="ResizeImage.cfm">
		<cfif ELPThumbnailFromDoc is "1">
			<cfset newTNFileName=ELPTNFileName>
		</cfif>
	<cfelse>
		<cfset ELPTNFileName=ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(NewFileName,'.jp','TN.jp','All'),'.gi','TN.gi','All'),'.pn','TN.pn','All')>
		<cffile action="copy" source="#Request.ListingUploadedDocsDir#\#newFileName#" destination="#Request.ListingUploadedDocsDir#\#ELPTNFileName#">
		<cfset ResizeFileName=ELPTNFileName>
		<cfset TNLongestSide="200">
		<cfset TNTwoLongestSide="175">
		<cfinclude template="ResizeImage.cfm">
		<cfif ELPThumbnailFromDoc is "1">
			<cfset newTNFileName=ELPTNFileName>
		</cfif>
	</cfif>	
<cfelse>
	<cfset NewFileName="">
</cfif>

<cfif not ELPOnStepTwo or Len(NewFileName)>
	<cfquery name="addDoc" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set ExpandedListingPDF=<cfqueryparam value="#newFileName#" cfsqltype="CF_SQL_VARCHAR">,
		ELPTypeThumbnailImage = <cfqueryparam value="#newTNFileName#" cfsqltype="CF_SQL_VARCHAR">, 
		ELPTypeID=<cfif Len(ELPTypeID)><cfqueryparam value="#ELPTypeID#" cfsqltype="CF_SQL_INTEGER"><cfelse>3</cfif>,
		ELPTypeOther=<cfif IsDefined('ELPTypeOther') and Len(ELPTypeOther) and ELPTypeID is ELPTypeOtherID><cfqueryparam value="#ELPTypeOther#" cfsqltype="CF_SQL_VARCHAR"><cfelse>null</cfif>,
		LogoImage=<cfqueryparam value="#newLogoFileName#" cfsqltype="CF_SQL_VARCHAR">,
		ELPThumbnailFromDoc=<cfqueryparam value="#ELPThumbnailFromDoc#" cfsqltype="CF_SQL_INTEGER">
		<cfif Len(getListingPELP.DateSort)>
			,DateSort=getDate()
		</cfif>
		<cfif ELPOnStepTwo>
			, ExpirationDateELP = ExpirationDate
		</cfif>
		<cfif not Len(getListingPELP.ExpandedListingOrderID) and not ELPOnStepTwo><!--- If ExpandedListingOrderID exists, then they have already previously submitted an Expanded Listing, so we don't want to set it back to ExpandedListingInProgress=1 or reset the ExpandedListingFee, since they are editing the already existing Expanded Listing or uploading a new one after deleting the existing one. --->			
			,ExpandedListingFee=<cfqueryparam value="#ExpandedFee#" cfsqltype="CF_SQL_FLOAT">,
			ExpandedListinginProgress = 1
		</cfif>	
		Where LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">		
	</cfquery>
</cfif>

<cfif Len(ELPOnlySubmission)>
		
	<cfquery name="checkForPaidELP" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select ListingID
		From ListingsView
		Where LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">		
		and ( ExpirationDate is null or ExpirationDate >= #application.CurrentDateInTZ# )
		and ExpandedListingOrderID is not null
	</cfquery>
	
	<cfif checkForPaidELP.RecordCount>
		<cflocation url="#lh_getPageLink(7,'myaccount')##AmpOrQuestion#Step=3&StatusMessage=#URLEncodedFormat('Featured Listing document uploaded.')#" addToken="No">
		<cfabort>	
	<cfelse>
		<cflocation url="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=3&LinkID=#LinkID#&StatusMessage=#URLEncodedFormat('Featured Listing document uploaded.')#" addToken="No">
		<cfabort>		
	</cfif>
</cfif>





