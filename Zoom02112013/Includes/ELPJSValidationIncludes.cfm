<cfparam name="ELPOnStepTwo" default="0">

if ($("#ProcessELPDocs").val()==1) {
	<cfif ListingTypeID neq "15" and ListingSectionID neq "37">
		<cfif not Len(getListing.LogoImage) or not FileExists("#Request.ListingUploadedDocsDir#\#getListing.LogoImage#")>
			if (!checkText(formObj.LogoImage,"Company Logo")) {
				return false;
			}
		</cfif>
	</cfif>
	<cfif not ELPOnStepTwo>
		if (!checkSelected(formObj.ELPTypeID,"Document Type")) {
			return false;
		}
	</cfif>	
	if ($("#ELPTypeID").val()==$("#ELPTypeOtherID").val()) {
		if (!checkText(formObj.ELPTypeOther,"Document Type (Other)")) {
			return false;
		}
	}
	<cfif not ELPOnStepTwo and (not Len(getListing.ExpandedListingPDF) or not FileExists("#Request.ListingUploadedDocsDir#\#getListing.ExpandedListingPDF#"))>
		if (!checkText(formObj.PDFFile,"Document Upload")) {
			return false;
		}
	</cfif>
}