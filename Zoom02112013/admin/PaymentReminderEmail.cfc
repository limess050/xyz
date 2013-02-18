<!--- Based on admin/AccountWelcomeEmail.cfm and inttasks/Reminders.cfm --->
<cfsetting showdebugoutput="no">

<cffunction name="SendEmail" access="remote" returntype="string" displayname="Sends the Payment Reminder email">
	<cfargument name="PK" type="numeric" required="yes">

	<cfquery name="getNonAccountPaymentEmail"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select SubjectLine, Body
		From AutoEmails
		Where  AutoEmailID = 11
	</cfquery>
	
	<cfquery name="getAccountPaymentEmail"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select SubjectLine, Body
		From AutoEmails
		Where  AutoEmailID = 12
	</cfquery>
	
	<cfquery name="getAccountRenewalPaymentEmail"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select SubjectLine, Body
		From AutoEmails
		Where  AutoEmailID = 13
	</cfquery>
	
	
	<!--- Get all listings in the Order --->
	<cfquery name="getPaymentListings"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		select ListingID, ListingTitle, UserID, ContactEmail, AltContactEmail, AcctContactEmail, AcctAltContactEmail,
		OrderDate, AccountName, Username, Password, OrderID, 
		IsNull(ListingFee,0) as ListingFee,
		IsNull(ExpandedListingFee,0) as ExpandedListingFee,
		IsNull(ListingFee,0) + IsNull(ExpandedListingFee,0) as TotalListingFee
		From listingsView 
		Where OrderID=<cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">
		Order By UserID, AcctContactEmail, ContactEmail, AltContactEmail
	</cfquery>
	<cfoutput query="getPaymentListings" group="UserID">
		<cfif not Len(UserID)>
			<cfoutput group="ContactEmail">
				<cfoutput group="AltContactEmail">
					<cfset EmailTo=ContactEmail>
					<cfif Len(AltContactEmail)>
						<cfset EmailTo=Listappend(EmailTo,AltContactEmail)>
					</cfif>
					<cfif Len(Request.DevelCCEmail)>
						<cfset EmailTo=Request.DevelCCEmail>
					</cfif>					
					<cfset ListingList="">
					<cfset ListingIDs="">	
					<cfset SubtotalAmount="0">	
					<cfset ListingList=ListAppend(ListingList,"<p>**OrderID** #pk# (#DateFormat(OrderDate,'dd/mm/yyyy')#)","|")>
					<cfoutput>		
						<cfif TotalListingFee is ListingFee>
							<cfset ListingList=ListAppend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(TotalListingFee)#","|")>
						<cfelse>
							<cfset ListingList=ListAppend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(ListingFee)# (Basic) - #DollarFormat(ExpandedListingFee)# (Expanded)","|")>
						</cfif>				
						<cfset SubTotalAmount=SubTotalAmount+TotalListingFee>	
						<cfset ListingIDs=ListAppend(ListingIDs,ListingID)>
					</cfoutput>
					<cfinclude template="../includes/VATCalc.cfm">
					<cfset PaymentAmount=SubtotalAmount+VAT>
					<cfif ListLen(ListingList,"|") gt "1">
						<cfset ListingList=Listappend(ListingList,"Subtotal: #DollarFormat(SubtotalAmount)#","|")>
					</cfif>
					<cfset ListingList=ListAppend(ListingList,"VAT: #DollarFormat(VAT)#","|")>
					<cfset ListingList=ListAppend(ListingList,"Total: #DollarFormat(PaymentAmount)#","|")>
					<cfset EmailBody=ReplaceNoCase(getNonAccountPaymentEmail.Body,"%insertOrderTable%",Replace(ListingList,"|","<br />","All"))>
					<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertMyAccountLink%","<a href='#Request.httpUrl#/MyAccount'>Click Here</a>")>
					<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertHowToPayLink%","<a href='#Request.httpUrl#/HowToPay'>Click Here</a>")>
					<cfmail to="#EmailTo#" from="#Request.MailToFormsFrom#" subject="#getNonAccountPaymentEmail.SubjectLine#" type="html">
					<p>#EmailBody#</p>
					</cfmail>
				</cfoutput>
			</cfoutput>
		<cfelse>		
			<cfset EmailTo=AcctContactEmail>
			<cfif Len(AcctAltContactEmail)>
				<cfset EmailTo=Listappend(EmailTo,AcctAltContactEmail)>
			</cfif>	
			<cfif Len(Request.DevelCCEmail)>
				<cfset EmailTo=Request.DevelCCEmail>
			</cfif>
			
			<cfset ListingList="">
			<cfset ListingIDs="">
			<cfset SubtotalAmount=0>	
			<cfset ListingList=ListAppend(ListingList,"<p>**OrderID** #OrderID# (#DateFormat(OrderDate,'dd/mm/yyyy')#)","|")>			
			<cfoutput>		
				<cfif TotalListingFee is ListingFee>
					<cfset ListingList=ListAppend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(TotalListingFee)#","|")>
				<cfelse>
					<cfset ListingList=ListAppend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(ListingFee)# (Basic) - #DollarFormat(ExpandedListingFee)# (Expanded)","|")>
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
			<cfset EmailBody=ReplaceNoCase(getAccountPaymentEmail.Body,"%insertOrderTable%",Replace(ListingList,"|","<br />","All"))>			
			<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertMyAccountLink%","<a href='#Request.httpUrl#/MyAccount'>Click Here</a>")>
			<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertHowToPayLink%","<a href='#Request.httpUrl#/HowToPay'>Click Here</a>")>
			<cfinclude template="../includes/getAccountInfo.cfm">
			<cfmail to="#EmailTo#" from="#Request.MailToFormsFrom#" subject="#getAccountPaymentEmail.SubjectLine#" type="html">
			<p>#EmailBody#</p>
			</cfmail>
		</cfif>
	</cfoutput>
	
	<!--- Get all account based renewals with their payment reminder due --->
	<cfquery name="getPaymentRenewals"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ListingID, L.ListingTitle, L.UserID, L.AcctContactEmail, L.AcctAltContactEmail, 
		L.AccountName, L.ExpirationDate, L.Username, L.Password, 
		IsNull(LR.ListingFee,0) as ListingFee,
		IsNull(LR.ExpandedListingFee,0) as ExpandedListingFee,
		IsNull(LR.ListingFee,0) + IsNull(LR.ExpandedListingFee,0) as TotalListingFee,
		LR.ListingRenewalID, LR.OrderID,
		O.OrderDate
		From ListingRenewals LR inner join Orders O on LR.OrderID=O.OrderID
		Inner Join ListingsView L on LR.ListingID=L.ListingID
		Where O.OrderID=<cfqueryparam value="#PK#" cfsqltype="CF_SQL_INTEGER">
		and L.active = 1
		and L.DeletedAfterSubmitted=0
		and L.InProgress=0
		and L.UserID is not null
		Order By UserID, AcctContactEmail
	</cfquery>
	
	<cfoutput query="getPaymentRenewals" group="UserID">
		<!--- <p><strong>#UserID#</strong><br> --->		
		<cfset EmailTo=AcctContactEmail>
		<cfif Len(AcctAltContactEmail)>
			<cfset EmailTo=Listappend(EmailTo,AcctAltContactEmail)>
		</cfif>
		<cfif Len(Request.DevelCCEmail)>
			<cfset EmailTo=Request.DevelCCEmail>
		</cfif>
		
		<cfset ListingList="">
		<cfset ListingRenewalIDs="">
		<cfset SubtotalAmount=0>	
		<cfset ListingList=ListAppend(ListingList,"<p>**OrderID** #OrderID# (#DateFormat(OrderDate,'dd/mm/yyyy')#)","|")>		
		<cfoutput>	
			<cfif TotalListingFee is ListingFee>
				<cfset ListingList=ListAppend(ListingList,"ListingID #ListingID# - #ListingTitle# - #DollarFormat(TotalListingFee)# (Expires #DateFormat(ExpirationDate,'dd/mm/yyyy')#)","|")>
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
		<cfset EmailBody=ReplaceNoCase(getAccountRenewalPaymentEmail.Body,"%insertOrdertable%",Replace(ListingList,"|","<br />","All"))>		
		<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertMyAccountLink%","<a href='#Request.httpUrl#/MyAccount'>Click Here</a>")>
		<cfset EmailBody=ReplaceNoCase(EmailBody,"%insertHowToPayLink%","<a href='#Request.httpUrl#/HowToPay'>Click Here</a>")>
		<cfinclude template="../includes/getAccountInfo.cfm">
		<cfmail to="#EmailTo#" from="#Request.MailToFormsFrom#" subject="#getAccountRenewalPaymentEmail.SubjectLine#" type="html">
		<p>#EmailBody#</p>
		</cfmail>
	</cfoutput>
	
	<cfif not getPaymentListings.RecordCount and not getPaymentRenewals.RecordCount>
		<cfset rString="No Listings or Renewals found.">
	<cfelse>
		<cfset rString="Payment Reminder sent.">	
	</cfif>

 	<cfreturn rString>

</cffunction>
