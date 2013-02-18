<cfset Testing="1">
<cfif Testing><!--- Skip CC processing entirely and set fake transID --->
	<cfset CCTransactionID = "TESTING">
<cfelse>
	<cfif Request.environment is "Live">
		<cfset processCreditCards=1>
	<cfelse>
		<cfset processCreditCards=0>
	</cfif>
	<!--- <cfif Len(BillingStateID)>
		<cfquery name="getStateAbbrev" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select StateAbbrev
			From LH_States
			Where StateID=<cfqueryparam value="#BillingStateID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset BillingState=getStateAbbrev.StateAbbrev>
	</cfif> --->
	
	<cfhttp url="https://secure.authorize.net/gateway/transact.dll" method="post">
		<CFHTTPPARAM NAME="x_Version" TYPE="FormField" VALUE="3.1">
		<CFHTTPPARAM NAME="x_Login" TYPE="FormField" VALUE="5nRf3U25"><!---  --->
		<CFHTTPPARAM NAME="x_tran_key" TYPE="FormField" VALUE="5K237p8383cvDCNw"><!---  --->
		<CFHTTPPARAM NAME="x_Amount" TYPE="FormField" VALUE="#PaymentAmount#">
		<CFHTTPPARAM NAME="x_Card_Num" TYPE="FormField" VALUE="#CCNumber#">
		<CFHTTPPARAM NAME="x_exp_date" TYPE="FormField" VALUE="#CCExpireMonth#/#CCExpireYear#">
		<!--- <CFHTTPPARAM NAME="x_first_name" TYPE="FormField" VALUE="#BillingFirstName#">
		<CFHTTPPARAM NAME="x_last_name" TYPE="FormField" VALUE="#BillingLastName#">
		<CFHTTPPARAM NAME="x_address" TYPE="FormField" VALUE="#BillingAddress1#">
		<CFHTTPPARAM NAME="x_city" TYPE="FormField" VALUE="#BillingCity#">
		<CFHTTPPARAM NAME="x_state" TYPE="FormField" VALUE="#BillingState#">
		<CFHTTPPARAM NAME="x_zip" TYPE="FormField" VALUE="#BillingZip#">
		<CFHTTPPARAM NAME="x_invoice_num" TYPE="FormField" VALUE="NM#MemberID#"> --->
		<CFHTTPPARAM NAME="x_card_code" TYPE="FormField" VALUE="#CSV#">
		<cfhttpparam name="x_delim_data" type="formfield" value="TRUE">
		<cfhttpparam name="x_delim_char" type="formfield" value="|">
		<cfhttpparam name="x_relay_response" type="formfield" value="FALSE">
		<cfhttpparam name="x_method" type="formfield" value="CC">
		<cfhttpparam name="x_type" type="formfield" value="AUTH_CAPTURE">

		<cfif not processCreditCards>
			<CFHTTPPARAM NAME="x_Test_Request" TYPE="FormField" VALUE="TRUE">
		</cfif>
	</cfhttp>

	<cfset r = trim(cfhttp.fileContent)>

	<!--- Pad commas w/ spaces so listGetAt functions correctly --->
	<cfset r = replace(r, "|", " , ", "ALL")>

	<cfif r is "Invalid Merchant Login or Account Inactive" OR r is "Connection Failure">
		<cfset statusMessage = "There was a connection failure while trying to process your credit card.  Please try again.">					
		<cflocation addtoken="no" url="#PaymentErrorRedirect#&StatusMessage=#URLEncodedFormat(statusMessage)#">
		<cfabort>
	</cfif>

	<cfset responseCode = trim(listGetAt(r, 1))>

	<cfif responseCode neq 1>
		<cfset responseReasonCode = trim(listGetAt(r, 3))>
		<cfset responseReasonText = trim(listGetAt(r, 4))>
		<cfset responseAVSCode = trim(listGetAt(r, 6))>

		<cfif responseAVSCode is "E">
			<cfset statusMessage = "The billing address provided does not match the one on record for this credit card.">
		<cfelseif responseAVSCode is "N">
			<cfset statusMessage = "The billing address provided does not match the one on record for this credit card.">
		<cfelseif responseAVSCode is "R">
			<cfset statusMessage = "Credit card processing system is currently unavailable.">
		<cfelseif responseReasonCode is "6">
			<cfset statusMessage = "The credit card number provided is invalid. Please check to make sure that the number is correct and try again.">
		<cfelseif responseReasonCode is "8">
			<cfset statusMessage = "Credit card expiration date provided is invalid. Please check to make sure that the date is correct and try again.">
		<cfelseif listFind("19,20,21,22,23,24,25,26", responseReasonCode)>
			<cfset statusMessage = "Credit card processing system is currently unavailable.">
		<cfelse>
			<cfset statusMessage = "The following problem was encountered while processing credit card:<BR><BR>#responseReasonText#">
		</cfif>
							
		<cflocation addtoken="no" url="#Request.httpsURL#/#PaymentErrorRedirect#&StatusMessage=#statusMessage#">
		<cfabort>
	</cfif>

	<cfset CCTransactionID = trim(listGetAt(r, 7))>
</cfif>
				