<cfset UserID="4167">
	<cfset rString = "">
	 
	<cfquery name="getMyListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ListingID, L.LinkID, L.Inprogress,
		IsNull(L.ListingFee,0) as ListingFee, IsNull(L.ExpandedListingFee,0) as ExpandedFee, L.ExpandedListingInProgress,
		CASE 
			WHEN L.ListingTypeID = 4 
				THEN Cast(L.VehicleYear as varchar(4)) + ' ' + M.Title + ' ' + IsNull(L.Model,'') 
			WHEN L.ListingTypeID = 5 
				THEN Cast(L.VehicleYear as varchar(4)) + ' ' + L.Make + ' ' + L.Model 
			WHEN L.ListingTypeID in (12)
				THEN L.ShortDescr
			ELSE L.Title 
			END as ListingTitle,
		L.ShortDescr, L.ExpirationDate, L.RenewalPending, L.ListingTypeID, L.Reviewed,
		L.Make as MakeOther, L.Model as ModelOther, L.VehicleYear, L.ExpandedListingPDF, L.ExpandedListingHTML,
		O.PaymentStatusID, O.OrderID,
		PSt.Title as PaymentStatus,
		PS.Title as ParentSection, S.SectionID, S.Title as Section,  
		(Select Top 1 C.CategoryID From ListingCategories LC Inner Join Categories C on LC.CategoryID=C.CategoryID Where LC.ListingID=L.ListingID Order By C.OrderNum) as CategoryID, (Select Top 1 C.Title From ListingCategories LC Inner Join Categories C on LC.CategoryID=C.CategoryID Where LC.ListingID=L.ListingID Order By C.OrderNum) as Category,
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
		ELOPSt.Title as ExpandedListingPaymentStatus,
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ# Then 1 Else 0 END as HasExpandedListing
		From ListingsView L
		Left Outer Join Orders O on L.OrderID=O.OrderID
		Left Outer Join PaymentStatuses PSt on O.PaymentStatusID=PSt.PaymentStatusID
		Left Outer Join Orders ELO on L.ExpandedListingOrderID=ELO.OrderID
		Left Outer Join PaymentStatuses ELOPSt on ELO.PaymentStatusID=ELOPSt.PaymentStatusID
		Inner Join ListingParentSections LPS on L.ListingID=LPS.ListingID
		Inner Join ParentSectionsView PS On LPS.ParentSectionID=PS.ParentSectionID
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
		<cfsavecontent variable="rString">
			 <table width="705" border="0" cellspacing="0" cellpadding="0" class="listingstable">
			    <tr class="listingstable-toprow">
			      <td>Listings</td>
			      <td class="centered">Site Location</td>
			      <td class="centered">Status</td>
			      <td class="centered"><strong>Expires On</strong></td>
			      <td class="centered">Payment History</td>
			      <td class="centered">Renew</td>
			    </tr>
				
				<cfoutput query="getMyListings">					
					<cfquery name="getListingOrders" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						Select ROV.MyAccountInfo, ROV.OrderType, ROV.ListingFee, ROV.ExpandedListingFee, ROV.TotalListingFee,
						ROV.SepExpandedListingFee,
						ROV.RenewalListingFee, ROV.RenewalExpandedListingFee, ROV.RenewalTotalListingFee,
						ROV.ServiceOrderFee
						From ListingRelatedOrdersView LROV Inner Join RelatedOrdersView ROV on LROV.RelatedOrderID=ROV.RelatedOrderID and LROV.ListingID=ROV.ListingID
						Where LROV.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
					</cfquery>
				    <tr>
				      <td><strong><cfif ListingTypeID is "10">#ShortDescr#<cfelse>#ListingTitle#</cfif></strong>
					  	<cfif session.UserID is Request.PhoneOnlyUserID>
					  		<br>(Phone Only Listing)
					  	</cfif>
				        <p><a href="#lh_getPageLink(3,'listingdetail')##AmpOrQuestion#ListingID=#ListingID#&Preview=1">Preview</a> | <a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=2&LinkID=#LinkID#">Edit</a><br />
				         <cfif not RenewalPending and Reviewed and ListFind("2,3",PaymentStatusID)> <a href="javascript: void(0);" onClick="document.f1.ListingID#ListingID#.checked=true;">Renew</a> | </cfif><a href="javascript:void(0);" onClick="deleteListing('#LinkID#')">Delete</a></p>
				        <cfif ListFind("1,2,9,14",ListingTypeID) and session.UserID neq Request.PhoneOnlyUserID>
							<cfif not Len(ExpandedListingPDF) and not Len(ExpandedListingHTML)>
								<p><span class="red">!</span> <a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=3&LinkID=#LinkID#">Upgrade to a featured listing</a></p>
							<cfelseif ExpandedListingInProgress>
								<p><span class="red">!</span> <a href="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=3&LinkID=#LinkID#">Submit the featured listing you started.</a></p>
							<cfelse>
								<p>This listing has a Featured Listing.<br />
								<a href="javascript:void(0);" onClick="deleteExpandedListing('#LinkID#')">Delete Featured Listing</a></p>
							</cfif>
						</cfif>
						<cfif ListFind("1,2,14",ListingTypeID) and HasExpandedListing>
							<p>&nbsp;<br><a href="ViewStats.cfm?LinkID=#LinkID#&height=500&width=500" target="_blank">View Stats</a></p>
						</cfif>
						</td>
					<cfif ListFind("10,12",ListingTypeID)>
						<cfquery name="getListingCats" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							Select C.Title as Category
							From Categories C inner join ListingCategories LC on C.CategoryID=LC.CategoryID
							Where LC.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
							Order By C.OrderNum
						</cfquery>
						<td class="centered">
							#ParentSection#&nbsp;&gt; <cfif Len(Section)>#Section#&nbsp;&gt; </cfif><cfif getListingCats.RecordCount gt "1"><br /></cfif>#Replace(ValueList(getListingCats.Category),",",", ","All") #						
						</td>
					<cfelse>
						<td class="centered">#ParentSection#&nbsp;&gt; <cfif Len(Section)>#Section#&nbsp;&gt; </cfif>#Category#</td>
					</cfif>				      
				      <td class="centered"><cfif Reviewed and ListFind("2,3",PaymentStatusID)>Live<cfelseif Reviewed>Approved<cfelse>Pending Review</cfif></td>
				      <td class="centered"><cfif PaymentStatusID is "1"><span class="ltgray">#TermExpiration# days after payment received</span><cfelse>#DateFormat(ExpirationDate,"dd/mm/yyyy")#</cfif>&nbsp;</td>
				      <td class="centered">
					  	<cfloop query="getListingOrders">
							<cfswitch expression="#OrderType#">
								<cfcase value="Listing">
									#DollarFormat(TotalListingFee)#<cfif TotalListingFee>&nbsp;+&nbsp;VAT</cfif>&nbsp;Listing<cfif Len(ExpandedListingFee) and ExpandedListingFee>&nbsp;with&nbsp;Featured&nbsp;Listing</cfif>
								</cfcase>
								<cfcase value="Expanded Listing">
									#DollarFormat(SepExpandedListingFee)#<cfif SepExpandedListingFee>&nbsp;+&nbsp;VAT</cfif>&nbsp;Featured&nbsp;Listing
								</cfcase>
								<cfcase value="Renewal">
									#DollarFormat(RenewalTotalListingFee)#<cfif RenewalTotalListingFee>&nbsp;+&nbsp;VAT</cfif>&nbsp;Renewal<cfif Len(RenewalExpandedListingFee) and RenewalExpandedListingFee>&nbsp;with&nbsp;Featured&nbsp;Listing</cfif>
								</cfcase>
								<cfcase value="Service Order">
									#DollarFormat(ServiceOrderFee)#<cfif ServiceOrderFee>&nbsp;+&nbsp;VAT</cfif>&nbsp;Service&nbsp;Order
								</cfcase>
							</cfswitch>
							<br />
						</cfloop>
					  </td>
				      <td class="centered">
					  	<label class="red">
					  	 <cfif RenewalPending>
						 	Renewal Order Pending
					  	 <cfelseif Reviewed and ListFind("2,3",PaymentStatusID)>						 	
        						<cfif DateDiff('d',Now(),ExpirationDate) lte "-1">Expired<br /><cfelseif DateDiff('d',Now(),ExpirationDate) lte "10">Expiring Soon!<br /></cfif>
							 	<input type="checkbox" ID="ListingID#ListingID#" class="ListingID" name="ListingIDs" value="#ListingID#">
						 </cfif>
						</label>
					  </td>
				    </tr>	
				</cfoutput>
			  </table>
		</cfsavecontent>
	</cfif>
	<cfoutput>#rString#</cfoutput>