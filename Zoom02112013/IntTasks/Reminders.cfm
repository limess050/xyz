

<!--- This is a scheduled template that runs every 10 minutes. It sends out a maximum number of emails on each iteration based on the variable MaxEmailsPerRun. --->
<cfset MaxEmailsPerRun="50">

<cfquery name="getNonAccountPaymentEmail"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select SubjectLine, Body
	From AutoEmails with (NOLOCK)
	Where  AutoEmailID = 11
</cfquery>

<cfquery name="getAccountPaymentEmail"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select SubjectLine, Body
	From AutoEmails with (NOLOCK)
	Where  AutoEmailID = 12
</cfquery>

<cfquery name="getAccountRenewalPaymentEmail"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select SubjectLine, Body
	From AutoEmails with (NOLOCK)
	Where  AutoEmailID = 13
</cfquery>

<cfquery name="getNonAccountRenewReminderEmail"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select SubjectLine, Body
	From AutoEmails with (NOLOCK)
	Where  AutoEmailID = 15
</cfquery>

<cfquery name="getAccountRenewReminderEmail"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select SubjectLine, Body
	From AutoEmails with (NOLOCK)
	Where  AutoEmailID = 14
</cfquery>

<cfset EmailsSent=0>

<cfloop From="2" To="1" Step="-1" index="i">
	<!--- Get all listings with their  payment reminder due --->
	<cfquery name="getPaymentListings#i#"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		select ListingID, 
		CASE WHEN ListingTypeID in (10,12) THEN ShortDescr ELSE ListingTitle END as ListingTitle, 
		OrderID, UserID, ContactEmail, AltContactEmail, AcctContactEmail, AcctAltContactEmail,
		DateDiff(d,orderdate,getDate()) as DaysSinceOrder, OrderDate, AccountName, UserName, Password, 
		IsNull(ListingFee,0) as ListingFee, IsNull(ExpandedListingFee,0) as ExpandedListingFee, 
		IsNull(ListingFee,0) + IsNull(ExpandedListingFee,0) as TotalListingFee
		From listingsView 
			where active = 1
			AND PaymentStatusID <> 2
			AND DateDiff(d,orderdate,getDate()) >= PaymentReminder#i#		
			and PaymentReminder#i#DateSent is null
			and PaymentReminder#i# is not null
			and PaymentReminder#i# > 0
			and DeletedAfterSubmitted=0
			and InProgress=0
		Order By UserID, AcctContactEmail, ContactEmail, AltContactEmail, OrderID
	</cfquery>
	<cfoutput query="getPaymentListings#i#" group="UserID">
		<cfif not Len(UserID)>
			<cfoutput group="ContactEmail">
				<cfoutput group="AltContactEmail">
					<cfset BCCEmail="">
					<cfset EmailTo=ContactEmail>
					<cfif Len(AltContactEmail)>
						<cfset EmailTo=Listappend(EmailTo,AltContactEmail)>
					</cfif>
					<cfif Len(Request.DevelCCEmail)>
						<cfset EmailTo=Request.DevelCCEmail>
						<cfset BCCEmail="">
					</cfif>
					
					<cfset ListingList="">
					<cfset ListingIDs="">
					<cfset SubTotalAmount="0">
					<cfoutput group="OrderID">
						<cfset ListingList=ListAppend(ListingList,"<p>**OrderID** #OrderID# (#DateFormat(OrderDate,'dd/mm/yyyy')#)","|")>
						<cfoutput>		
							<cfif TotalListingFee is ListingFee>
								<cfset ListingList=ListAppend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(TotalListingFee)#","|")>
							<cfelse>
								<cfset ListingList=ListAppend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(ListingFee)# (Basic) - #DollarFormat(ExpandedListingFee)# (Expanded)","|")>
							</cfif>
							<cfset SubTotalAmount=SubTotalAmount+TotalListingFee>			
							<cfset ListingIDs=ListAppend(ListingIDs,ListingID)>
						</cfoutput>
					</cfoutput>
					<cfinclude template="../includes/VATCalc.cfm">
					<cfset PaymentAmount=SubtotalAmount+VAT>
					<cfif ListLen(ListingList,"|") gt "1">
						<cfset ListingList=ListAppend(ListingList,"Subtotal: #DollarFormat(SubtotalAmount)#","|")>
					</cfif>
					<cfset ListingList=ListAppend(ListingList,"VAT: #DollarFormat(VAT)#","|")>
					<cfset ListingList=ListAppend(ListingList,"Total: #DollarFormat(PaymentAmount)#","|")>
					<cfset EmailBody=ReplaceNoCase(getNonAccountPaymentEmail.Body,"%insertOrderTable%",Replace(ListingList,"|","<br />","All"),"ALL")>
					<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertMyAccountLink%","<a href='#Request.httpUrl#/MyAccount'>Click Here</a>","ALL")>
					<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertHowToPayLink%","<a href='#Request.httpUrl#/HowToPay'>Click Here</a>","ALL")>
					<cfmail to="#EmailTo#" from="#Request.MailToFormsFrom#" subject="#getNonAccountPaymentEmail.SubjectLine#" type="html" BCC="#BCCEmail#">
					<p>#EmailBody#</p>
					</cfmail>
					<cfquery name="updateListings"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						Update Listings
						Set PaymentReminder#i#DateSent=getDate()
						<cfif i is "2">, PaymentReminder1DateSent = CASE WHEN PaymentReminder1DateSent is null THEN getDate() ELSE PaymentReminder1DateSent END</cfif><!--- If both 2nd and 1st payment reminders are unsent, mark both sent when sending the 2nd one, so as not to generate 2 emails on the same date. --->
						Where ListingID in (<cfqueryparam value="#ListingIDs#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
					</cfquery>
					<cfset EmailsSent=EmailsSent+1>
					<cfif EmailsSent gte MaxEmailsPerRun>
						<cfabort>
					</cfif>
				</cfoutput>
			</cfoutput>
		<cfelse>		
			<cfset BCCEmail="">
			<cfset EmailTo=AcctContactEmail>
			<cfif Len(AcctAltContactEmail)>
				<cfset EmailTo=Listappend(EmailTo,AcctAltContactEmail)>
			</cfif>	
			<cfif Len(Request.DevelCCEmail)>
				<cfset EmailTo=Request.DevelCCEmail>
				<cfset BCCEmail="">
			</cfif>
			
			<cfset ListingList="">
			<cfset ListingIDs="">
			<cfset SubtotalAmount=0>
			<cfoutput group="OrderID">
				<cfset ListingList=ListAppend(ListingList,"<p>**OrderID** #OrderID# (#DateFormat(OrderDate,'dd/mm/yyyy')#)","|")>		
				<cfoutput>
					<cfset ListingList=Listappend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(TotalListingFee)#","|")>
					<cfset ListingIDs=ListAppend(ListingIDs,ListingID)>
					<cfset SubtotalAmount=SubtotalAmount+TotalListingFee>	
				</cfoutput>
			</cfoutput>
			<cfinclude template="../includes/VATCalc.cfm">
			<cfset PaymentAmount=SubtotalAmount+VAT>
			<cfif ListLen(ListingList,"|") gt "1">
				<cfset ListingList=Listappend(ListingList,"Subtotal: #DollarFormat(SubtotalAmount)#","|")>
			</cfif>
			<cfset ListingList=ListAppend(ListingList,"VAT: #DollarFormat(VAT)#","|")>
			<cfset ListingList=ListAppend(ListingList,"Total: #DollarFormat(PaymentAmount)#","|")>
			<cfset EmailBody=ReplaceNoCase(getAccountPaymentEmail.Body,"%insertOrdertable%",Replace(ListingList,"|","<br />","All"),"ALL")>
			<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertMyAccountLink%","<a href='#Request.httpUrl#/MyAccount'>Click Here</a>","ALL")>
			<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertHowToPayLink%","<a href='#Request.httpUrl#/HowToPay'>Click Here</a>","ALL")>
			<cfinclude template="../includes/getAccountInfo.cfm">
			<cfmail to="#EmailTo#" from="#Request.MailToFormsFrom#" subject="#getAccountPaymentEmail.SubjectLine#" type="html" BCC="#BCCEmail#">
			<p>#EmailBody#</p>
			</cfmail>
			<cfquery name="updateListings"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Update Listings
				Set PaymentReminder#i#DateSent=getDate()
				<cfif i is "2">, PaymentReminder1DateSent = CASE WHEN PaymentReminder1DateSent is null THEN getDate() ELSE PaymentReminder1DateSent END</cfif><!--- If both 2nd and 1st payment reminders are unsent, mark both sent when sending the 2nd one, so as not to generate 2 emails on the same date. --->
				Where ListingID in (<cfqueryparam value="#ListingIDs#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
			</cfquery>
			<cfset EmailsSent=EmailsSent+1>
			<cfif EmailsSent gte MaxEmailsPerRun>
				<cfabort>
			</cfif>
		</cfif>
	</cfoutput>
	
	<!--- Get all account based renewals with their payment reminder due --->
	<cfquery name="getPaymentRenewals#i#"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ListingID, L.ListingTitle, 
		CASE WHEN L.ListingTypeID in (10,12) THEN L.ShortDescr ELSE L.ListingTitle END as ListingTitle, 
		L.UserID, L.AcctContactEmail, L.AcctAltContactEmail, 
		L.AccountName, L.PaymentReminder#i#, L.ExpirationDate, L.Username, L.Password, 
		IsNull(LR.ListingFee,0) as ListingFee, 
		IsNull(LR.ExpandedListingFee,0) as ExpandedListingFee,
		IsNull(LR.ListingFee,0) + IsNull(LR.ExpandedListingFee,0) as TotalListingFee,
		LR.ListingRenewalID, LR.OrderID,
		O.OrderDate
		From ListingRenewals LR with (NOLOCK) inner join Orders O with (NOLOCK) on LR.OrderID=O.OrderID
		Inner Join ListingsView L on LR.ListingID=L.ListingID
		Where O.PaymentStatusID <> 2
		AND DateDiff(d,O.OrderDate,getDate()) >= L.PaymentReminder#i#
		and LR.PaymentReminder#i#DateSent is null
		and L.active = 1
		and L.PaymentReminder#i# is not null
		and L.PaymentReminder#i# > 0
		and L.DeletedAfterSubmitted=0
		and L.InProgress=0
		and L.UserID is not null
		Order By UserID, AcctContactEmail, LR.OrderID
	</cfquery>
	
	<cfoutput query="getPaymentRenewals#i#" group="UserID">
		<cfset BCCEmail="">
		<cfset EmailTo=AcctContactEmail>
		<cfif Len(AcctAltContactEmail)>
			<cfset EmailTo=Listappend(EmailTo,AcctAltContactEmail)>
		</cfif>
		<cfif Len(Request.DevelCCEmail)>
			<cfset EmailTo=Request.DevelCCEmail>
			<cfset BCCEmail="">
		</cfif>
		
		<cfset ListingList="">
		<cfset ListingRenewalIDs="">
		<cfset SubTotalAmount=0>	
		<cfoutput group="OrderID">
			<cfset ListingList=ListAppend(ListingList,"<p>**OrderID** #OrderID# (#DateFormat(OrderDate,'dd/mm/yyyy')#)","|")>
			<cfoutput>
				<cfset SubTotalAmount=SubTotalAmount+TotalListingFee>		
				<cfif TotalListingFee is ListingFee>
					<cfset ListingList=Listappend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(TotalListingFee)# (Expires #DateFormat(ExpirationDate,'dd/mm/yyyy')#)","|")>
				<cfelse>
					<cfset ListingList=ListAppend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(ListingFee)# (Basic) - #DollarFormat(ExpandedListingFee)# (Expanded) - (Expires #DateFormat(ExpirationDate,'dd/mm/yyyy')#)","|")>
				</cfif>			
				<cfset ListingRenewalIDs=ListAppend(ListingRenewalIDs,ListingRenewalID)>
			</cfoutput>
		</cfoutput>	
		<cfinclude template="../includes/VATCalc.cfm">
		<cfset PaymentAmount=SubtotalAmount+VAT>
		<cfif ListLen(ListingList,"|") gt "1">
			<cfset ListingList=ListAppend(ListingList,"Subtotal: #DollarFormat(SubTotalAmount)#","|")>
		</cfif>
		<cfset ListingList=ListAppend(ListingList,"VAT: #DollarFormat(VAT)#","|")>
		<cfset ListingList=ListAppend(ListingList,"Total: #DollarFormat(PaymentAmount)#","|")>
		<cfset EmailBody=ReplaceNoCase(getAccountRenewalPaymentEmail.Body,"%insertOrderTable%",Replace(ListingList,"|","<br />","All"),"ALL")>
		<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertMyAccountLink%","<a href='#Request.httpUrl#/MyAccount'>Click Here</a>","ALL")>
		<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertHowToPayLink%","<a href='#Request.httpUrl#/HowToPay'>Click Here</a>","ALL")>
		<cfinclude template="../includes/getAccountInfo.cfm">
		<cfmail to="#EmailTo#" from="#Request.MailToFormsFrom#" subject="#getAccountRenewalPaymentEmail.SubjectLine#" type="html" BCC="#BCCEmail#">
		<p>#EmailBody#</p>
		</cfmail>
		<cfquery name="updateListingRenewals"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update ListingRenewals
			Set PaymentReminder#i#DateSent=getDate()
			<cfif i is "2">, PaymentReminder1DateSent = CASE WHEN PaymentReminder1DateSent is null THEN getDate() ELSE PaymentReminder1DateSent END</cfif><!--- If both 2nd and 1st payment reminders are unsent, mark both sent when sending the 2nd one, so as not to generate 2 emails on the same date. --->
			Where ListingRenewalID in (<cfqueryparam value="#ListingRenewalIDs#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
		</cfquery>
		<cfset EmailsSent=EmailsSent+1>
		<cfif EmailsSent gte MaxEmailsPerRun>
			<cfabort>
		</cfif>
	</cfoutput>
</cfloop>


<!--- Get all listings with their check-in email due --->
<cfquery name="getCheckIns"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select ListingID, LinkID,
	CASE WHEN ListingTypeID in (10,12) THEN ShortDescr ELSE ListingTitle END as ListingTitle,  
	UserID, ContactEmail, AltContactEmail, AcctContactEmail, AcctAltContactEmail, Username, Password,
	DateDiff(d,orderdate,getDate()) as DaysSinceOrder, OrderDate, AccountName, CheckInText
	From listingsView 
		where active = 1
		AND PaymentStatusID = 2
		AND DateDiff(d,orderdate,getDate()) >= CheckInEmail		
		and CheckInDateSent is null
		and CheckInEmail is not null 
		and CheckInEmail <> ''
		and CheckInEmail > 0
		and CheckInText is not null 
		and Len(Cast(CheckInText as nvarchar(200))) > 50
		and DeletedAfterSubmitted=0
		and InProgress=0
		and ContactEmail <> '' and ContactEmail is not null
	Order By UserID, AcctContactEmail, ContactEmail, AltContactEmail
</cfquery>
<cfoutput query="getCheckIns">
	<cfset BCCEmail="">
	<cfset EmailTo=ContactEmail>
	<cfif Len(AltContactEmail)>
		<cfset EmailTo=ListAppend(EmailTo,AltContactEmail)>
	</cfif>
	<cfif not Len(EmailTo)>
		<cfif Len(AcctContactEmail)>
			<cfset EmailTo=ListAppend(EmailTo,AcctContactEmail)>
		</cfif>
		<cfif Len(AcctAltContactEmail)>
			<cfset EmailTo=ListAppend(EmailTo,AcctAltContactEmail)>
		</cfif>
	</cfif>
	<cfif Len(Request.DevelCCEmail)>
		<cfset EmailTo=Request.DevelCCEmail>
		<cfset BCCEmail="">
	</cfif>
	
	<cfset EditListingLink="<a href='#request.HTTPSURL#/postalisting?Step=3&LinkID=#LinkID#'>Edit Listing</a>">	
	<cfset DeleteListingLink="<a href='#request.HTTPSURL#/postalisting?Step=3&LinkID=#LinkID#&DeleteListing=1'>Delete Listing</a>">
	
	<cfset EmailBody=CheckInText>
	
	<cfif Len(UserID)>
		<cfinclude template="../includes/getAccountInfo.cfm">
	<cfelse>
		<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertacctinfo%","","ALL")><!--- replace with Blank, since no Acct --->
	</cfif>
	<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertMyAccountLink%","<a href='#Request.httpUrl#/MyAccount'>Click Here</a>","ALL")>
	<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertListingTitle%",ListingTitle,"ALL")>
	<cfset EmailBody=ReplaceNoCase(EmailBody,"%deleteListingLink%",DeleteListingLink)>
	<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertEditLink%",EditListingLink)>
	<cfmail to="#EmailTo#" from="#Request.MailToFormsFrom#" subject="Checking in from ZoomTanzania" type="html" BCC="#BCCEmail#">
	<p>#EmailBody#</p>
	</cfmail>
	<cfquery name="updateListings"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set CheckInDateSent=getDate()
		Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfset EmailsSent=EmailsSent+1>
	<cfif EmailsSent gte MaxEmailsPerRun>
		<cfabort>
	</cfif>
</cfoutput>

<cfloop From="3" to="1" step="-1" index="i">
	<!--- Get all listings with their renewal reminder due --->
	<cfquery name="getRenewReminder#i#"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.RenewReminder#i#, L.ListingID, 
			CASE WHEN L.ListingTypeID in (10,12) THEN L.ShortDescr ELSE L.ListingTitle END as ListingTitle, 
			L.UserID, L.ContactEmail, L.AltContactEmail, L.AcctContactEmail, L.AcctAltContactEmail,
			DateDiff(d,getDate(),L.ExpirationDate) as DaysToExpiration, L.OrderDate, L.AccountName, L.ExpirationDate, L.LinkID, L.Username, L.Password,
			CASE WHEN LT.AllowFreeRenewal=0 THEN IsNull(LT.BasicFee,0) ELSE 0 END as ListingFee,
			CASE WHEN L.ExpandedListingHTML is not null or L.ExpandedListingPDF is not null THEN IsNull(LT.ExpandedFee,0) ELSE 0 END as ExpandedFee,
			CASE WHEN L.ExpandedListingHTML is null and L.ExpandedListingPDF is null  and LT.AllowFreeRenewal=0 THEN IsNull(LT.BasicFee,0)
			WHEN L.ExpandedListingHTML is null and L.ExpandedListingPDF is null  and LT.AllowFreeRenewal=1 THEN 0
			WHEN LT.AllowFreeRenewal=0 THEN IsNull(LT.BasicFee,0) + IsNull(LT.ExpandedFee,0)
			ELSE IsNull(LT.ExpandedFee,0) END as TotalListingFee
		From listingsView L
			Inner Join ListingTypes LT with (NOLOCK) on L.ListingTypeID=LT.ListingTypeID
		Where L.active = 1
			AND L.PaymentStatusID = 2
			AND DateDiff(d,getDate(),L.ExpirationDate) <= L.RenewReminder#i#	
			and L.RenewReminder#i#DateSent is null
			and L.RenewReminder#i# is not null
			and L.RenewReminder#i# > 0
			and L.DeletedAfterSubmitted=0
			and L.InProgress=0
			and not exists (Select ListingID from ListingRenewals LR with (NOLOCK) where LR.ListingID=L.ListingID)<!--- Already has a renewal, so reminders will be sent for that, rather than for the listing. --->
			and ContactEmail is not null and ContactEmail <> ''
		Order By L.UserID, L.AcctContactEmail, L.ContactEmail, L.AltContactEmail
	</cfquery>
	<cfoutput query="getRenewReminder#i#" group="UserID">
		<!--- <p><strong>#UserID#</strong><br> --->
		<cfif not Len(UserID)>
			<cfoutput group="ContactEmail">
				<cfoutput group="AltContactEmail">
					<cfset BCCEmail="">
					<cfset EmailTo=ContactEmail>
					<cfif Len(AltContactEmail)>
						<cfset EmailTo=Listappend(EmailTo,AltContactEmail)>
					</cfif>
					<cfif Len(Request.DevelCCEmail)>
						<cfset EmailTo=Request.DevelCCEmail>
						<cfset BCCEmail="">
					</cfif>
					
					<cfset ListingList="">
					<cfset ListingIDs="">
					<cfset SubtotalAmount=0>		
					<cfoutput>		
						<cfif TotalListingFee is ListingFee>
							<cfset ListingList=Listappend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(TotalListingFee)# (Expires #DateFormat(ExpirationDate,'dd/mm/yyyy')#)<br /><a href='#Request.HTTPURL#/listingdetail?ListingID=#ListingID#'>View</a>&nbsp;&nbsp;<a href='#Request.HTTPURL#/postalisting?Step=3&LinkID=#LinkID#'>Edit</a>&nbsp;&nbsp;<a href='#request.HTTPSURL#/postalisting?Step=3&LinkID=#LinkID#&DeleteListing=1'>Delete</a>","|")>
						<cfelse>
							<cfset ListingList=ListAppend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(ListingFee)# (Basic) - #DollarFormat(ExpandedFee)# (Expanded) - (Expires #DateFormat(ExpirationDate,'dd/mm/yyyy')#)<br /><a href='#Request.HTTPURL#/listingdetail?ListingID=#ListingID#'>View</a>&nbsp;&nbsp;<a href='#Request.HTTPURL#/postalisting?Step=3&LinkID=#LinkID#'>Edit</a>&nbsp;&nbsp;<a href='#request.HTTPSURL#/postalisting?Step=3&LinkID=#LinkID#&DeleteListing=1'>Delete</a>","|")>
						</cfif>							
						<cfset SubtotalAmount=SubtotalAmount+TotalListingFee>	
						<cfset ListingIDs=ListAppend(ListingIDs,ListingID)>
					</cfoutput>
					<cfinclude template="../includes/VATCalc.cfm">
					<cfset PaymentAmount=SubtotalAmount+VAT>
					<cfif ListLen(ListingList,"|") gt "1">
						<cfset ListingList=Listappend(ListingList,"Subtotal: #DollarFormat(SubtotalAmount)#","|")>
					</cfif>
					<cfset ListingList=ListAppend(ListingList,"VAT: #DollarFormat(VAT)#","|")>
					<cfset ListingList=ListAppend(ListingList,"Total: #DollarFormat(PaymentAmount)#","|")>
					<cfset EmailBody=ReplaceNoCase(getNonAccountRenewReminderEmail.Body,"%insertOrderTable%",Replace(ListingList,"|","<br />","All"),"ALL")>
					<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertMyAccountLink%","<a href='#Request.httpUrl#/MyAccount'>Click Here</a>","ALL")>
					<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertHowToPayLink%","<a href='#Request.httpUrl#/HowToPay'>Click Here</a>","ALL")>
					<cfmail to="#EmailTo#" from="#Request.MailToFormsFrom#" subject="#getNonAccountRenewReminderEmail.SubjectLine#" type="html" BCC="#BCCEmail#">
					<p>#EmailBody#</p>
					</cfmail>
					<cfquery name="updateListings"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						Update Listings
						Set RenewReminder#i#DateSent=getDate()
						<cfif i is "3">
							, RenewReminder2DateSent = CASE WHEN RenewReminder2DateSent is null THEN getDate() ELSE RenewReminder2DateSent END
							, RenewReminder1DateSent = CASE WHEN RenewReminder1DateSent is null THEN getDate() ELSE RenewReminder1DateSent END
						<cfelseif i is "2">
							, RenewReminder1DateSent = CASE WHEN RenewReminder1DateSent is null THEN getDate() ELSE RenewReminder1DateSent END
						</cfif>
						Where ListingID in (<cfqueryparam value="#ListingIDs#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
					</cfquery>
					<cfset EmailsSent=EmailsSent+1>
					<cfif EmailsSent gte MaxEmailsPerRun>
						<cfabort>
					</cfif>
				</cfoutput>
			</cfoutput>
		<cfelse>		
			<cfset BCCEmail="">
			<cfset EmailTo=AcctContactEmail>
			<cfif Len(AcctAltContactEmail)>
				<cfset EmailTo=Listappend(EmailTo,AcctAltContactEmail)>
			</cfif>
			<cfif Len(Request.DevelCCEmail)>
				<cfset EmailTo=Request.DevelCCEmail>
				<cfset BCCEmail="">
			</cfif>
			
			<cfset ListingList="">
			<cfset ListingIDs="">
			<cfset SubtotalAmount=0>		
			<cfoutput>	
				<cfif TotalListingFee is ListingFee>
					<cfset ListingList=Listappend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(TotalListingFee)# (Expires #DateFormat(ExpirationDate,'dd/mm/yyyy')#)","|")>
				<cfelse>
					<cfset ListingList=ListAppend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(ListingFee)# (Basic) - #DollarFormat(ExpandedFee)# (Expanded) - (Expires #DateFormat(ExpirationDate,'dd/mm/yyyy')#)","|")>
				</cfif>	
				<cfset SubtotalAmount=SubtotalAmount+TotalListingFee>	
				<cfset ListingIDs=ListAppend(ListingIDs,ListingID)>
			</cfoutput>
			<cfinclude template="../includes/VATCalc.cfm">
			<cfset PaymentAmount=SubtotalAmount+VAT>
			<cfif ListLen(ListingList,"|") gt "1">
				<cfset ListingList=Listappend(ListingList,"Subtotal: #DollarFormat(SubtotalAmount)#","|")>
			</cfif>
			<cfset ListingList=ListAppend(ListingList,"VAT: #DollarFormat(VAT)#","|")>
			<cfset ListingList=ListAppend(ListingList,"Total: #DollarFormat(PaymentAmount)#","|")>					
			<cfset EmailBody=ReplaceNoCase(getAccountRenewReminderEmail.Body,"%insertOrderTable%",Replace(ListingList,"|","<br />","All"),"ALL")>
			<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertMyAccountLink%","<a href='#Request.httpUrl#/MyAccount'>Click Here</a>","ALL")>
			<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertHowToPayLink%","<a href='#Request.httpUrl#/HowToPay'>Click Here</a>","ALL")>
			<cfinclude template="../includes/getAccountInfo.cfm">
			<cfmail to="#EmailTo#" from="#Request.MailToFormsFrom#" subject="#getAccountRenewReminderEmail.SubjectLine#" type="html" BCC="#BCCEmail#">
			<p>#EmailBody#</p>
			</cfmail>
			<cfquery name="updateListings"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Update Listings
				Set RenewReminder#i#DateSent=getDate()
				<cfif i is "3">
					, RenewReminder2DateSent = CASE WHEN RenewReminder2DateSent is null THEN getDate() ELSE RenewReminder2DateSent END
					, RenewReminder1DateSent = CASE WHEN RenewReminder1DateSent is null THEN getDate() ELSE RenewReminder1DateSent END
				<cfelseif i is "2">
					, RenewReminder1DateSent = CASE WHEN RenewReminder1DateSent is null THEN getDate() ELSE RenewReminder1DateSent END
				</cfif>
				Where ListingID in (<cfqueryparam value="#ListingIDs#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
			</cfquery>
			<cfset EmailsSent=EmailsSent+1>
			<cfif EmailsSent gte MaxEmailsPerRun>
				<cfabort>
			</cfif>
		</cfif>
	</cfoutput>
	
	<!--- Get all renewals with their renewal reminder due --->
	<cfquery name="getRenewReminderRenewals#i#"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ListingID, L.LinkID,  
		CASE WHEN L.ListingTypeID in (10,12) THEN L.ShortDescr ELSE L.ListingTitle END as ListingTitle, 
		L.UserID, L.ContactEmail, L.AltContactEmail, L.AcctContactEmail, L.AcctAltContactEmail, 
		L.AccountName, L.RenewReminder#i#, L.ExpirationDate, L.Username, L.Password,
		LR.ListingRenewalID, LR.OrderID,
		O.OrderDate,
		CASE WHEN LT.AllowFreeRenewal=0 THEN IsNull(LT.BasicFee,0) ELSE 0 END as ListingFee,
		IsNull(LT.ExpandedFee,0) as ExpandedListingFee,
		CASE WHEN L.ExpandedListingHTML is null and L.ExpandedListingPDF is null and LT.AllowFreeRenewal=0 THEN IsNull(LT.BasicFee,0)
		WHEN L.ExpandedListingHTML is null and L.ExpandedListingPDF is null and LT.AllowFreeRenewal=1 THEN 0
		WHEN LT.AllowFreeRenewal=0 THEN IsNull(LT.BasicFee,0) + IsNull(LT.ExpandedFee,0)
		ELSE IsNull(LT.ExpandedFee,0) END as TotalListingFee
		From ListingRenewals LR with (NOLOCK) inner join Orders O with (NOLOCK) on LR.OrderID=O.OrderID
		Inner Join ListingsView L on LR.ListingID=L.ListingID
		Inner Join ListingTypes LT with (NOLOCK) on L.ListingTypeID=LT.ListingTypeID
		Where O.PaymentStatusID = 2
		AND DateDiff(d,getDate(),L.ExpirationDate) <= L.RenewReminder#i#
		and LR.RenewReminder#i#DateSent is null
		and L.active = 1
		and L.RenewReminder#i# is not null
		and L.RenewReminder#i# > 0
		and L.DeletedAfterSubmitted=0
		and L.InProgress=0
		and LR.ListingRenewalID = (Select Top 1 ListingRenewalID from ListingRenewals LR2 with (NOLOCK) where LR2.ListingID=L.ListingID Order By ListingRenewalID desc)<!--- Only get most recent renewal record for a listing --->
		Order By UserID, AcctContactEmail, ContactEmail, AltContactEmail
	</cfquery>
	
	<cfoutput query="getRenewReminderRenewals#i#" group="UserID">
		<!--- <p><strong>#UserID#</strong><br> --->
		<cfif not Len(UserID)>
			<cfoutput group="ContactEmail">
				<cfoutput group="AltContactEmail">
					<cfset BCCEmail="">
					<cfset EmailTo=ContactEmail>
					<cfif Len(AltContactEmail)>
						<cfset EmailTo=Listappend(EmailTo,AltContactEmail)>
					</cfif>
					<cfif Len(Request.DevelCCEmail)>
						<cfset EmailTo=Request.DevelCCEmail>
						<cfset BCCEmail="">
					</cfif>
					
					<cfset ListingList="">
					<cfset ListingRenewalIDs="">
					<cfset SubtotalAmount=0>		
					<cfoutput>								
						<cfif TotalListingFee is ListingFee>
							<cfset ListingList=ListAppend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(TotalListingFee)# (Expires #DateFormat(ExpirationDate,'dd/mm/yyyy')#))<br /><a href='#Request.HTTPURL#/listingdetail?ListingID=#ListingID#'>View</a>&nbsp;&nbsp;<a href='#Request.HTTPURL#/postalisting?Step=3&LinkID=#LinkID#'>Edit</a>&nbsp;&nbsp;<a href='#request.HTTPSURL#/postalisting?Step=3&LinkID=#LinkID#&DeleteListing=1'>Delete</a>","|")>
						<cfelse>
							<cfset ListingList=ListAppend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(ListingFee)# (Basic) - #DollarFormat(ExpandedListingFee)# (Expanded) - (Expires #DateFormat(ExpirationDate,'dd/mm/yyyy')#)<br /><a href='#Request.HTTPURL#/listingdetail?ListingID=#ListingID#'>View</a>&nbsp;&nbsp;<a href='#Request.HTTPURL#/postalisting?Step=3&LinkID=#LinkID#'>Edit</a>&nbsp;&nbsp;<a href='#request.HTTPSURL#/postalisting?Step=3&LinkID=#LinkID#&DeleteListing=1'>Delete</a>","|")>
						</cfif>			
						<cfset SubtotalAmount=SubtotalAmount+TotalListingFee>
						<cfset ListingRenewalIDs=ListAppend(ListingRenewalIDs,ListingRenewalID)>
					</cfoutput>
					<cfinclude template="../includes/VATCalc.cfm">
					<cfset PaymentAmount=SubtotalAmount+VAT>
					<cfif ListLen(ListingList,"|") gt "1">
						<cfset ListingList=Listappend(ListingList,"Subtotal: #DollarFormat(SubtotalAmount)#","|")>
					</cfif>
					<cfset ListingList=ListAppend(ListingList,"VAT: #DollarFormat(VAT)#","|")>
					<cfset ListingList=ListAppend(ListingList,"Total: #DollarFormat(PaymentAmount)#","|")>
					<cfset EmailBody=ReplaceNoCase(getNonAccountRenewReminderEmail.Body,"%insertOrderTable%",Replace(ListingList,"|","<br />","All"),"ALL")>
					<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertMyAccountLink%","<a href='#Request.httpUrl#/MyAccount'>Click Here</a>","ALL")>
					<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertHowToPayLink%","<a href='#Request.httpUrl#/HowToPay'>Click Here</a>","ALL")>
					<cfmail to="#EmailTo#" from="#Request.MailToFormsFrom#" subject="#getNonAccountRenewReminderEmail.SubjectLine#" type="html" BCC="#BCCEmail#">
					<p>#EmailBody#</p>
					</cfmail>
					<cfquery name="updateListings"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						Update ListingRenewals
						Set RenewReminder#i#DateSent=getDate()
						<cfif i is "3">
							, RenewReminder2DateSent = CASE WHEN RenewReminder2DateSent is null THEN getDate() ELSE RenewReminder2DateSent END
							, RenewReminder1DateSent = CASE WHEN RenewReminder1DateSent is null THEN getDate() ELSE RenewReminder1DateSent END
						<cfelseif i is "2">
							, RenewReminder1DateSent = CASE WHEN RenewReminder1DateSent is null THEN getDate() ELSE RenewReminder1DateSent END
						</cfif>
						Where ListingRenewalID in (<cfqueryparam value="#ListingRenewalIDs#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
					</cfquery>
					<cfset EmailsSent=EmailsSent+1>
					<cfif EmailsSent gte MaxEmailsPerRun>
						<cfabort>
					</cfif>
				</cfoutput>
			</cfoutput>
		<cfelse>		
			<cfset BCCEmail="">
			<cfset EmailTo=AcctContactEmail>
			<cfif Len(AcctAltContactEmail)>
				<cfset EmailTo=Listappend(EmailTo,AcctAltContactEmail)>
			</cfif>
			<cfif Len(Request.DevelCCEmail)>
				<cfset EmailTo=Request.DevelCCEmail>
				<cfset BCCEmail="">
			</cfif>
			
			<cfset ListingList="">
			<cfset ListingRenewalIDs="">
			<cfset SubtotalAmount=0>		
			<cfoutput>							
				<cfif TotalListingFee is ListingFee>
					<cfset ListingList=ListAppend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(TotalListingFee)# (Expires #DateFormat(ExpirationDate,'dd/mm/yyyy')#))","|")>
				<cfelse>
					<cfset ListingList=ListAppend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(ListingFee)# (Basic) - #DollarFormat(ExpandedListingFee)# (Expanded) - (Expires #DateFormat(ExpirationDate,'dd/mm/yyyy')#)","|")>
				</cfif>			
				<cfset SubtotalAmount=SubtotalAmount+TotalListingFee>	
				<cfset ListingRenewalIDs=ListAppend(ListingRenewalIDs,ListingRenewalID)>
			</cfoutput>
			<cfinclude template="../includes/VATCalc.cfm">
			<cfset PaymentAmount=SubtotalAmount+VAT>
			<cfif ListLen(ListingList,"|") gt "1">
				<cfset ListingList=Listappend(ListingList,"Subtotal: #DollarFormat(SubtotalAmount)#","|")>
			</cfif>
			<cfset ListingList=ListAppend(ListingList,"VAT: #DollarFormat(VAT)#","|")>
			<cfset ListingList=ListAppend(ListingList,"Total: #DollarFormat(PaymentAmount)#","|")>
			<cfset EmailBody=ReplaceNoCase(getAccountRenewReminderEmail.Body,"%insertOrderTable%",Replace(ListingList,"|","<br />","All"),"ALL")>
			<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertMyAccountLink%","<a href='#Request.httpUrl#/MyAccount'>Click Here</a>","ALL")>
			<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertHowToPayLink%","<a href='#Request.httpUrl#/HowToPay'>Click Here</a>","ALL")>
			<cfinclude template="../includes/getAccountInfo.cfm">
			<cfmail to="#EmailTo#" from="#Request.MailToFormsFrom#" subject="#getAccountRenewReminderEmail.SubjectLine#" type="html" BCC="#BCCEmail#">
			<p>#EmailBody#</p>
			</cfmail>
			<cfquery name="updateListingRenewals"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Update ListingRenewals
				Set RenewReminder#i#DateSent=getDate()
				<cfif i is "3">
					, RenewReminder2DateSent = CASE WHEN RenewReminder2DateSent is null THEN getDate() ELSE RenewReminder2DateSent END
					, RenewReminder1DateSent = CASE WHEN RenewReminder1DateSent is null THEN getDate() ELSE RenewReminder1DateSent END
				<cfelseif i is "2">
					, RenewReminder1DateSent = CASE WHEN RenewReminder1DateSent is null THEN getDate() ELSE RenewReminder1DateSent END
				</cfif>
				Where ListingRenewalID in (<cfqueryparam value="#ListingRenewalIDs#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
			</cfquery>
			<cfset EmailsSent=EmailsSent+1>
			<cfif EmailsSent gte MaxEmailsPerRun>
				<cfabort>
			</cfif>
		</cfif>
	</cfoutput>
</cfloop> 
	