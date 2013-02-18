<cfparam name="NewOrderType" default="OneListing">
<cfparam name="edit" default="0">
<cfset allFields="NewOrderID">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="NewOrderID">

<cfquery name="getOrder" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select O.OrderID, O.OrderDate, O.PreVATTotal, O.VAT, O.OrderTotal, O.PaymentDate, O.PaymentStatusID, O.PaymentConfirmationEmailDateSent, 
	U.Company, U.UserID, U.Username, U.Password, U.ContactEmail, U.AltContactEmail,
	PS.Title as PaymentStatus
	From Orders O
	Inner Join PaymentStatuses PS on O.PaymentStatusID=PS.PaymentStatusID
	Left Outer Join LH_Users U on O.UserID=U.UserID
	Where O.OrderID = <cfqueryparam value="#NewOrderID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfif getOrder.PaymentStatusID is "2">
	<cfquery name="updateOrderPaymentConfirmationEmailDateSent" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Update Orders 
		Set PaymentConfirmationEmailDateSent=getDate()
		Where OrderID = <cfqueryparam value="#NewOrderID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
</cfif>

<cfquery name="getListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select L.ListingID, L.LinkID, 
	CASE WHEN L.ListingTypeID in (10,12) THEN L.ShortDescr ELSE L.ListingTitle END as ListingTitle, 
	L.ExpirationDate, L.OrderID, L.ExpandedListingOrderID, L.ContactEmail, L.AltContactEmail,
	IsNull(L.ListingFee,0) as ListingFee, 
	IsNull(L.ExpandedListingFee,0) as ExpandedListingFee,
		CASE WHEN L.ExpandedListingInProgress = 0 and L.OrderID=L.ExpandedListingOrderID
		THEN IsNull(L.ListingFee,0) + IsNull(L.ExpandedListingFee,0) 
		ELSE IsNull(L.ListingFee,0) 
		END as TotalListingFee
	From ListingsView L
	Where L.OrderID = <cfqueryparam value="#NewOrderID#" cfsqltype="CF_SQL_INTEGER"> or L.ExpandedListingOrderID = <cfqueryparam value="#NewOrderID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfquery name="getBannerAds" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select BA.BannerAdImage, BA.Impressions, BA.StartDate, BA.EndDate, BA.Price,
	P.Placement
	From BannerAds BA left join orders o on BA.OrderID = O.OrderID
	Left join BannerADPlacement P on BA.placementID = P.placementID
	Where BA.OrderID = <cfqueryparam value="#NewOrderID#" cfsqltype="CF_SQL_INTEGER">	
</cfquery>

<cfquery name="getListingRenewals" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select L.ListingID, L.LinkID, 
	CASE WHEN L.ListingTypeID in (10,12) THEN L.ShortDescr ELSE L.ListingTitle END as ListingTitle, 
	 L.ExpirationDate, LR.OrderID, L.ExpandedListingOrderID, L.ContactEmail, L.AltContactEmail,
	IsNull(LR.ListingFee,0) as ListingFee, 
	IsNull(LR.ExpandedListingFee,0) as ExpandedListingFee,
	IsNull(LR.ListingFee,0) + IsNull(LR.ExpandedListingFee,0) as TotalListingFee
	From ListingsView L
	Inner Join ListingRenewals LR on L.ListingID=LR.ListingID
	Where LR.OrderID = <cfqueryparam value="#NewOrderID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfquery name="getExpandedListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select L.ListingID, 
	CASE WHEN L.ListingTypeID in (10,12) THEN L.ShortDescr ELSE L.ListingTitle END as ListingTitle, 
	L.ExpirationDate, L.ExpandedListingOrderID,
	IsNull(L.ExpandedListingFee,0) as ListingFee
	From ListingsView L
	Where L.ExpandedListingOrderID = <cfqueryparam value="#NewOrderID#" cfsqltype="CF_SQL_INTEGER">
	and L.OrderID <> L.ExpandedListingOrderID
</cfquery>

<cfquery name="getListingPackage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select L.ListingPackageID, L.FiveListing, L.TenListing, L.TwentyListing, L.UnlimitedListing, L.ExpirationDate,
	LPT.Title as ListingPackageType
	From ListingPackages L
	Inner Join ListingPackageTypes LPT on L.ListingPackageTypeID=LPT.ListingPackageTypeID
	Where L.OrderID = <cfqueryparam value="#NewOrderID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfquery name="getListingService" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select LS.ServiceDescr, L.ContactEmail, L.AltContactEmail
	From ListingServices LS
	Inner Join Listings L on LS.ListingID=L.ListingID
	Where LS.OrderID = <cfqueryparam value="#NewOrderID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>


<cfquery name="getAutoEmail" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SubjectLine, Body
	From AutoEmails
	Where AutoEmailID = 
	<cfswitch expression="#NewOrderType#">
		<cfcase value="OneListing,MyCart,Synch,AdminOrderUpdate,Renewal">
			<cfif getOrder.PaymentStatusID is "2">
				6
			<cfelse>
				3
			</cfif>
		</cfcase>
		<cfcase value="ListingPackage,SynchListingPackage,AdminListingPackageOrderUpdate">
			<cfif getOrder.PaymentStatusID is "2">
				8
			<cfelse>
				5
			</cfif>
		</cfcase>
		<cfcase value="AdminServiceOrderUpdate">
			<cfif getOrder.PaymentStatusID is "2">
				16
			<cfelse>
				17
			</cfif>
		</cfcase>
	</cfswitch>
</cfquery>

<cfsavecontent variable="NewOrderTable">
	<table>
		<cfoutput>
			<cfif Len(getOrder.UserID)>
				<tr>
					<td colspan="3">
						<a href="#Request.HTTPSURL#/myaccount">Log in to My Account</a>
					</td>
				</tr>
				<tr>
					<td colspan="3">
						<cfset AccountName=getOrder.Company>
						<cfset UserID=getOrder.UserID>
						<cfset UserName=getOrder.UserName>
						<cfset Password=getOrder.Password>
						<cfinclude template="getAccountInfo.cfm">
						#AccountInfo#
					</td>
				</tr>
			</cfif>
			<tr>
				<td colspan="2">
					<strong>Order ##:</strong> #getOrder.OrderID#
				</td>
				<td>
					<strong>Order Date:</strong> #DateFormat(getOrder.OrderDate,"dd/mm/yyyy")#
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<strong>Order Status:</strong> #getOrder.PaymentStatus#
				</td>
			</tr>
		</cfoutput>
		<cfoutput query="getListings">
			<cfif not Len(ExpandedListingOrderID) or OrderID is ExpandedListingOrderID>
				<tr>
					<td>
						<strong>Listing:</strong> 
						<!--- If not tied to an account (one-off listing), make the Listing Title link to the listing submit form. --->
						<cfif not Len(getOrder.UserID)>
							<a href="#Request.HTTPSURL#/postalisting?Step=3&LinkID=#LinkID#">#ListingTitle# (#ListingID#)</a>
						<cfelse>
							#ListingTitle# (#ListingID#)
						</cfif>
					</td>
					<td>
						<cfif Len(ExpirationDate)><strong>Expires:</strong></cfif>&nbsp;#DateFormat(ExpirationDate,"dd/mm/yyyy")#
					</td>
					<td>						
						<cfif TotalListingFee is ListingFee>
							#DollarFormat(TotalListingFee)#
						<cfelse>
							#DollarFormat(ListingFee)# (Basic) - #DollarFormat(ExpandedListingFee)# (Expanded)
						</cfif>			
					</td>
				</tr>
			</cfif>
		</cfoutput>
		<cfoutput query="getBannerAds">
			<tr>
				<td>
					<strong>Banner Ad:</strong> 
					#BannerAdImage# (Placement: #Placement#)
				</td>
				<td>
					(#DateFormat(startDate,'dd/mm/yyyy')# - #DateFormat(endDate,'dd/mm/yyyy')#)
				</td>
				<td>						
					#DollarFormat(Price)#
				</td>
			</tr>
		</cfoutput>
		<cfoutput query="getListingRenewals">
			<tr>
				<td>
					<strong>Listing Renewal:</strong> 
					<!--- If not tied to an account (one-off listing), make the Listing Title link to the listing submit form. --->
					<cfif not Len(getOrder.UserID)>
						<a href="#Request.HTTPSURL#/postalisting?Step=3&LinkID=#LinkID#">#ListingTitle# (#ListingID#)</a>
					<cfelse>
						#ListingTitle# (#ListingID#)
					</cfif>
				</td>
				<td>
					<cfif Len(ExpirationDate)><strong>Expires:</strong></cfif>&nbsp;#DateFormat(ExpirationDate,"dd/mm/yyyy")#
				</td>
				<td>						
					<cfif TotalListingFee is ListingFee>
						#DollarFormat(TotalListingFee)#
					<cfelse>
						#DollarFormat(ListingFee)# (Basic) - #DollarFormat(ExpandedListingFee)# (Expanded)
					</cfif>			
				</td>
			</tr>
		</cfoutput>
		<cfoutput query="getExpandedListings">
			<tr>
				<td>
					<strong>Featured Listing For:</strong> #ListingTitle# (#ListingID#)
				</td>
				<td>
					<cfif Len(ExpirationDate)><strong>Expires:</strong></cfif>&nbsp;#DateFormat(ExpirationDate,"dd/mm/yyyy")#
				</td>
				<td>
					#DollarFormat(ListingFee)#
				</td>
			</tr>
		</cfoutput>
		<cfoutput query="getListingPackage">
			<tr>
				<td>
					<strong>Listing Package:</strong> #ListingPackageType# 
					<cfif FiveListing>
						(Five Listing Credits)
					<cfelseif TenListing>
						(Ten Listing Credits)
					<cfelseif TwentyListing>
						(Twenty Listing Credits)
					<cfelseif UnlimitedListing>
						(Unlimited Listing Credits)
					</cfif>
				</td>
				<td>
					<cfif Len(ExpirationDate)><strong>Expires:</strong></cfif>&nbsp;#DateFormat(ExpirationDate,"dd/mm/yyyy")#
				</td>
				<td>
					&nbsp;<!--- #DollarFormat(getOrder.PreVATTotal)# --->
				</td>
			</tr>
		</cfoutput>
		<cfoutput query="getListingService">
			<tr>
				<td>
					<strong>Listing Service:</strong> #ServiceDescr# 
				</td>
			</tr>
		</cfoutput>
		<cfoutput>		
			<tr>
				<td colspan="3">
					<strong>Subtotal:</strong> #DollarFormat(getOrder.PreVATTotal)#<br />
					<strong>VAT:</strong> #DollarFormat(getOrder.VAT)#<br />
					<strong>Total:</strong> #DollarFormat(getOrder.OrderTotal)#
				</td>
			</tr>
		</cfoutput>
	</table>
</cfsavecontent>

<cfset EmailBody=ReplaceNoCase(getAutoEmail.Body,"%InsertOrderTable%",NewOrderTable)>
<cfif getOrder.PaymentStatusID is "2">
	<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertPaymentDate%","#DateFormat(getOrder.PaymentDate,'dd/mm/yyyy')#")>
</cfif>
<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertMyAccountLink%","<a href='#Request.httpUrl#/MyAccount'>Click Here</a>")>
<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertHowToPayLink%","<a href='#Request.httpUrl#/HowToPay'>Click Here</a>")>
<cfset OrderEmailTo=getOrder.ContactEmail>
<cfif Len(getOrder.AltContactEmail)>
	<cfset OrderEmailTo=ListAppend(OrderEmailTo,getOrder.AltContactEmail)>
</cfif>
<cfif not Len(OrderEmailTo)>
	<cfset OrderEmailTo=getListings.ContactEmail>
	<cfif Len(getListings.AltContactEmail)>
		<cfset OrderEmailTo=ListAppend(OrderEmailTo,getListings.AltContactEmail)>
	</cfif>
</cfif>
<cfif not Len(OrderEmailTo)>
	<cfset OrderEmailTo=getListingService.ContactEmail>
	<cfif Len(getListingService.AltContactEmail)>
		<cfset OrderEmailTo=ListAppend(OrderEmailTo,getListingService.AltContactEmail)>
	</cfif>
</cfif>

<cfmail to="#OrderEmailTo#" from="#Request.MailToFormsFrom#" subject="#getAutoEmail.SubjectLine#" type="HTML" BCC="#Request.DevelCCEmail#">
	#EmailBody#	
</cfmail> 