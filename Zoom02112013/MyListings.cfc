
<cfinclude template="../application.cfm">
<cfset Edit="0">
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfsetting showdebugoutput="no">

<cffunction name="Get" access="remote" returntype="string" displayname="Creates the HTML to be displayed in the MyAccount template">
	<cfargument name="UserID" required="yes">
	<cfset rString = "">
	 
	<cfquery name="getMyListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ListingID, L.LinkID, L.Inprogress,
		IsNull(L.ListingFee,0) as ListingFee, IsNull(L.ExpandedListingFee,0) as ExpandedFee, L.ExpandedListingInProgress,
		CASE 
			WHEN L.ListingTypeID = 4 
				THEN Cast(L.VehicleYear as varchar(4)) + ' ' + M.Title + ' ' + IsNull(L.Model,'') 
			WHEN L.ListingTypeID = 5 
				THEN Cast(L.VehicleYear as varchar(4)) + ' ' + L.Make + ' ' + L.Model 
			WHEN L.ListingTypeID in (6,7,8)
				THEN L.AreaPlot
			WHEN L.ListingTypeID in (12)
				THEN L.ShortDescr
			ELSE L.Title 
			END as ListingTitle,
		L.ExpirationDate, L.RenewalPending, L.ListingTypeID, L.Reviewed,
		L.AreaPlot,
		L.Make as MakeOther, L.Model as ModelOther, L.VehicleYear, L.ExpandedListingPDF, L.ExpandedListingHTML,
		O.PaymentStatusID, O.OrderID,
		PSt.Title as PaymentStatus,
		PS.Title as ParentSection, S.SectionID, S.Title as Section, C.CategoryID, C.Title as Category,
		LT.TermExpiration,
		M.Title as Make, 
		CASE WHEN ExpandedListingInProgress = 0 and L.OrderID=L.ExpandedListingOrderID
		THEN IsNull(L.ListingFee,0) + IsNull(L.ExpandedListingFee,0) 
		ELSE IsNull(L.ListingFee,0) 
		END as TotalFee, 
		CASE WHEN L.OrderID<>L.ExpandedListingOrderID
		THEN L.ExpandedListingFee
		ELSE null 
		END as ExpandedListingSeparateFee,
		ELOPSt.Title as ExpandedListingPaymentStatus
		From ListingsView L
		Left Outer Join Orders O on L.OrderID=O.OrderID
		Left Outer Join PaymentStatuses PSt on O.PaymentStatusID=PSt.PaymentStatusID
		Left Outer Join Orders ELO on L.ExpandedListingOrderID=ELO.OrderID
		Left Outer Join PaymentStatuses ELOPSt on ELO.PaymentStatusID=ELOPSt.PaymentStatusID
		Inner Join ListingParentSections LPS on L.ListingID=LPS.ListingID
		Inner Join ParentSectionsView PS On LPS.ParentSectionID=PS.ParentSectionID
		Inner Join ListingCategories LC on L.ListingID=LC.ListingID
		Inner Join Categories C on LC.CategoryID=C.CategoryID
		Inner Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
		Left Outer Join ListingSections LS on L.ListingID=LS.ListingID
		Left Outer Join SectionsView S on LS.SectionID=S.SectionID
		Left Outer Join Makes M on L.MakeID=M.MakeID
		Where L.DeletedAfterSubmitted=0 
		and O.UserID=<cfqueryparam value="#UserID#" cfsqltype="CF_SQL_INTEGER">
		Order By PS.OrderNum, O.OrderDate desc, L.ListingID
	</cfquery>
	<cfif not GetMyListings.RecordCount>
		<cfset rString = "<p>No Listings Found</p>">
	<cfelse>
		<cfset ShowExpandedListingOrderColumn="0">
		<cfoutput query="getMyListings">
			<cfif Len(ExpandedListingSeparateFee)>
				<cfset ShowExpandedListingOrderColumn="1">
			</cfif>
		</cfoutput>
		<cfsavecontent variable="rString">
			 <table width="705" border="0" cellspacing="0" cellpadding="0" class="listingstable">
			    <tr class="listingstable-toprow">
			      <td>Listings</td>
			      <td class="centered">Site Location</td>
			      <td class="centered">Status</td>
			      <td class="centered"><strong>Expires On</strong></td>
			      <td class="centered">Payment</td>
				  <cfif ShowExpandedListingOrderColumn>
				      <td class="centered">Separate Expanded Listing Payment</td>
				  </cfif>
			      <td class="centered">Renew</td>
			    </tr>
				
				<cfoutput query="getMyListings">
				    <tr>
				      <td><strong>#ListingTitle#</strong>
				        <p><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#&Preview=1">Preview</a> | <a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=2&LinkID=#LinkID#">Edit</a><br />
				         <cfif not RenewalPending and Reviewed and ListFind("2,3",PaymentStatusID)> <a href="javascript: void(0);" onClick="document.f1.ListingID#ListingID#.checked=true;">Renew</a> | </cfif><a href="javascript:void(0);" onClick="deleteListing('#LinkID#')">Delete</a></p>
				        		
				        <cfif ListFind("1,2,9,15",ListingTypeID)>
							<cfif not Len(ExpandedListingPDF) and not Len(ExpandedListingHTML)>
								<p><span class="red">!</span> <a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=3&LinkID=#LinkID#">Add an expanded listing page</a></p>
							<cfelseif ExpandedListingInProgress>
								<p><span class="red">!</span> <a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=3&LinkID=#LinkID#">Submit the expanded listing you started.</a>
							<cfelse>
								This listing has an Expanded Listing.<br />
								<a href="javascript:void(0);" onClick="deleteExpandedListing('#LinkID#')">Delete Expanded Listing</a>
							</cfif>
						</cfif>
						</td>
				      <td class="centered">#ParentSection#&nbsp;&gt; <cfif Len(Section)>#Section#&nbsp;&gt; </cfif>#Category#</td>
				      <td class="centered"><cfif Reviewed and ListFind("2,3",PaymentStatusID)>Live<cfelseif Reviewed>Approved<cfelse>Pending Review</cfif></td>
				      <td class="centered"><cfif PaymentStatusID is "1"><span class="ltgray">#TermExpiration# days after payment received</span><cfelse>#DateFormat(ExpirationDate,"dd/mm/yyyy")#</cfif>&nbsp;</td>
				      <td class="centered">
					  	#DollarFormat(TotalFee)#
						<br />
						#PaymentStatus#
					  </td>
					  <cfif ShowExpandedListingOrderColumn>
					      <td class="centered">
						  	<cfif Len(ExpandedListingSeparateFee)>
							  	#DollarFormat(ExpandedListingSeparateFee)#
								<br />
								#ExpandedListingPaymentStatus#
							</cfif>
						  </td>
					  </cfif>
				      <td class="centered">
					  	<label class="red">
					  	 <cfif RenewalPending>
						 	Renewal Order Pending
					  	 <cfelseif Reviewed and ListFind("2,3",PaymentStatusID)>						 	
        						<cfif DateDiff('d',Now(),ExpirationDate) lte "10">Expiring Soon!<br></cfif>
							 	<input type="checkbox" ID="ListingID#ListingID#" class="ListingID" name="ListingID" value="#ListingID#">
						 </cfif>
						</label>
					  </td>
				    </tr>	
				</cfoutput>
			  </table>
		</cfsavecontent>
	</cfif>
	
 	<cfreturn rString>
</cffunction>

<cffunction name="Delete" access="remote" returntype="string" displayname="Logically deletes a Listing">
	<cfargument name="LinkID" required="yes">
	<cfset rString = "">
	 
	<cfquery name="logicallyDeleteListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set DeletedAfterSubmitted=1,
		DeletedAfterSubmittedDate=convert(varchar(20), getdate(), 101)
		Where LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">		
	</cfquery>
	
 	<cfreturn rString>
</cffunction>

<cffunction name="DeleteNew" access="remote" returntype="string" displayname="Physically deletes a Listing that was never submitted">
	<cfargument name="LinkID" required="yes">
	<cfset rString = "">
	<!--- Check that is it really unSubmitted (InProgess still is "1") --->
	<cfquery name="checkListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select ListingID, InProgress, ExpandedListingPDF, UploadedDoc
		From Listings
		Where LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">		
	</cfquery>
	<cfif checkListing.RecordCount>
		<cfif checkListing.InProgress>
			<cfquery name="checkListingImages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Select FileName
				From ListingImages
				Where ListingID=<cfqueryparam value="#checkListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<cfif checkListingImages.RecordCount>
				<cfloop query="checkListingImages">
					<cfif FileExists("#Request.ListingImagesDir#\#FileName#")>
						<cffile action="delete" file="#Request.ListingImagesDir#\#FileName#">	
					</cfif>
				</cfloop>
			</cfif>
			<cfif Len(checkListing.ExpandedListingPDF)>
				<cfif FileExists("#Request.ListingUploadedDocsDir#\#ExpandedListingPDF#")>
					<cffile action="delete" file="#Request.ListingUploadedDocsDir#\#ExpandedListingPDF#">	
				</cfif>
			</cfif>
			<cfif Len(checkListing.UploadedDoc)>
				<cfif FileExists("#Request.ListingUploadedDocsDir#\#UploadedDoc#")>
					<cffile action="delete" file="#Request.ListingUploadedDocsDir#\#UploadedDoc#">	
				</cfif>
			</cfif>
			<cftransaction>
				<cfquery name="deleteLinkedRecords" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					Delete From ListingCategories
					Where ListingID=<cfqueryparam value="#checkListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
								
					Delete From ListingSections
					Where ListingID=<cfqueryparam value="#checkListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
					
					Delete From ListingParentSections
					Where ListingID=<cfqueryparam value="#checkListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
					
					Delete From ListingCuisines
					Where ListingID=<cfqueryparam value="#checkListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
					
					Delete From ListingLocations
					Where ListingID=<cfqueryparam value="#checkListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
					
					Delete From ListingImages
					Where ListingID=<cfqueryparam value="#checkListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				<cfquery name="deleteLinkedRecords" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					Delete from Listings
					Where ListingID=<cfqueryparam value="#checkListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
			</cftransaction>
			<cfset rString="Deleted">
		<cfelse>
			<cfset rString="Undeleteable">
		</cfif>
	<cfelse>		
		<cfset rString="No Listing">
	</cfif>
 	<cfreturn rString>
</cffunction>


