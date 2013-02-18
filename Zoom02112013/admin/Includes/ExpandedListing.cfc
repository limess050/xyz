
<cfsetting showdebugoutput="no">

<cffunction name="Get" access="remote" returntype="string" displayname="Creates the HTML to be shown in the Expanded Listing div in the Add A Listing Step 3">
	<cfargument name="ListingID" required="yes">
	
	<cfset rString = "">
	 
	<cfquery name="getListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ListingID, IsNull(L.ListingFee,0) as ListingFee, L.ExpandedListingPDF, L.ExpandedListingHTML,
		IsNull(LT.ExpandedFee,0) as ExpandedFee
		From Listings L
		Inner Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
		Where ListingID =  <cfqueryparam value="#arguments.ListingID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfoutput>
		<cfif not Len(getListing.ExpandedListingPDF) and not Len(getListing.ExpandedListingHTML)>
			<cfset TotalListingFee=getListing.ListingFee>
			<cfsavecontent variable="rString">
				<div id="ExpandedListingOptions">
					<input type="button" name="PDFUpload" id="PDFUpload" value="PDF Upload" class="btn"  onClick="location.href='UploadExpandedListingPDF.cfm?ListingID=#ListingID#&height=500&width=500'" /><br />
					<input type="button" name="EditExpanded" id="EditExpanded" value="Choose a Template" class="btn" onClick="location.href='StandardTemplates.cfm?ListingID=#ListingID#'" /><br />
					<!--- <cfloop query="getExpandedTemplates">
						<input type="button" name="EditExpanded" id="EditExpanded" value="Use #TemplateTitle# Template" class="btn" onClick="location.href='#Request.HTTPSURL#/EditExpandedListingHTML.cfm?LinkID=#LinkID#&ExpandedTemplateID=#ExpandedTemplateID#&height=700&width=1052'" /><br />
					</cfloop> --->
					<input type="button" name="EditExpanded" id="EditExpanded" value="HTML Editor" class="btn" onClick="location.href='EditExpandedListingHTML.cfm?ListingID=#ListingID#&height=700&width=1052'" /><br />
				</div>
			</cfsavecontent>
		<cfelse>
			<cfset TotalListingFee=getListing.ListingFee + getListing.ExpandedFee>
			<cfsavecontent variable="rString">
				<cfif Len(getListing.ExpandedListingPDF)>
					<div id="ExpandedListingOptions">
						<strong>PDF</strong> <input type="button" name="ViewPDF" id="ViewPDF" value="View" class="btn" onClick="window.open('#Request.HTTPSURL#/ListingUploadedDocs/#getListing.ExpandedListingPDF#')" /> <a href="##" onClick="if(confirm('Are you sure you want to delete this?')){deleteExpandedListing();};"><input type="button" name="DeletePDF" id="DeletePDF" value="Delete" class="btn" /></a>
					</div>
				<cfelse>
					<div id="ExpandedListingOptions">
						<strong>HTML Template</strong> <input type="button" name="ViewHTML" id="ViewHTML" value="View" class="btn" onClick="window.open('#Request.HTTPSURL#/ExpandedListing.cfm?ListingID=#getListing.ListingID#')" /> <input type="button" name="EditHTML" id="EditHTML" value="Edit" class="btn" onClick="location.href='EditExpandedListingHTML.cfm?ListingID=#ListingID#'"/> <a href="##" onClick="if(confirm('Are you sure you want to delete this?')){deleteExpandedListing();};"><input type="button" name="DeleteHTML" id="DeleteHTML" value="Delete" class="btn" /></a>
					</div>
				</cfif>
			</cfsavecontent>
		</cfif>
	</cfoutput>
 	<cfreturn rString>
</cffunction>

<cffunction name="DelExL" access="remote" returntype="string" displayname="Deletes the expanded Listing data">
	<cfargument name="ListingID" required="yes">
	
	<cfset rString = "">
	 
	<cfquery name="getListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ExpandedListingPDF, L.ExpandedListingHTML, L.InProgress
		From Listings L
		Where ListingID =  <cfqueryparam value="#arguments.ListingID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfif Len(getListing.ExpandedListingPDF) and FileExists("#Request.ListingUploadedDocsDir#\#getListing.ExpandedListingPDF#")>
		<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#getListing.ExpandedListingPDF#">
	</cfif>
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set ExpandedListingPDF=null,
		<cfif getListing.InProgress>ExpandedListingFee=null,</cfif>
		ExpandedListingHTML=null
		Where ListingID =  <cfqueryparam value="#arguments.ListingID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
 	<cfreturn rString>
</cffunction>
