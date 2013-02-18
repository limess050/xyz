<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Service Order">
<cfinclude template="../Lighthouse/Admin/Header.cfm">

<cfif not IsDefined('ListingID') and not IsDefined('PK')>
	No ListingID or PK passed.
	<cfabort>
</cfif>

<cfparam name="PK" default="0">

<cfset allFields="PK,ListingID,AcctID,ServiceOrderAmount,ServiceDescr,DoIt">
<cfinclude template="../includes/setVariables.cfm">
<cfmodule template="../includes/_checkNumbers.cfm" fields="PK,ListingID,AcctID,ServiceOrderAmount,DoIt">
<cfif Len(DoIt)>	
	<cfif PK is "0">
		<cftransaction>
			<cfset SubtotalAmount=ServiceOrderAmount>
			<cfinclude template="../includes/VATCalc.cfm">
			<cfset ServiceOrderAmount=VAT+SubtotalAmount>
			<cfquery name="createOrder" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Insert into Orders
				(OrderTotal, PreVATTotal, VAT, OrderDate, PaymentMethodID, PaymentStatusID, UserID)
				VALUES
				(<cfqueryparam value="#ServiceOrderAmount#" cfsqltype="CF_SQL_MONEY" null="#NOT LEN(ServiceOrderAmount)#">,
				<cfqueryparam value="#SubtotalAmount#" cfsqltype="CF_SQL_MONEY" null="#NOT LEN(SubtotalAmount)#">,
				<cfqueryparam value="#VAT#" cfsqltype="CF_SQL_MONEY" null="#NOT LEN(VAT)#">,
				<cfqueryparam value="#OrderDate#" cfsqltype="CF_SQL_DATE" null="#NOT LEN(OrderDate)#">,
				1,
				1,
				<cfqueryparam value="#AcctID#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(AcctID)#">)
				
				Select Max(OrderID) as NewOrderID
				From Orders
			</cfquery>
			<cfquery name="createListingService" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Insert into ListingServices
				(ServiceOrderAmount, ListingID, OrderID, ServiceDate, ServiceDescr)
				VALUES
				(<cfqueryparam value="#SubtotalAmount#" cfsqltype="CF_SQL_MONEY" null="#NOT LEN(ServiceOrderAmount)#">,
				<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#createOrder.NewOrderID#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#OrderDate#" cfsqltype="CF_SQL_DATE" null="#NOT LEN(OrderDate)#">,
				<cfqueryparam value="#ServiceDescr#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(ServiceDescr)#">)
			</cfquery>
		</cftransaction>
		<cflocation url="Orders.cfm?Action=Edit&PK=#createOrder.NewOrderID#" addToken="No">
		<cfabort>
	<cfelse>
		<cfquery name="updateListingService" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update ListingServices
			Set ServiceDescr=<cfqueryparam value="#ServiceDescr#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(ServiceDescr)#">
			Where ListingServiceID=<cfqueryparam value="#PK#" cfsqltype="CF_SQL_INTEGER">
			
			Select OrderID 
			From ListingServices
			Where ListingServiceID=<cfqueryparam value="#PK#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cflocation url="Orders.cfm?Action=Edit&PK=#updateListingService.OrderID#&StatusMessage=#UrlEncodedFormat('Listing Service Description updated.')#" addToken="No">
		<cfabort>
	</cfif>
</cfif>	

	<cfif PK>
		<cfquery name="getListingService"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select LS.ServiceDescr, LS.ServiceOrderAmount, LS.ServiceDate, LS.ListingID
			From ListingServices LS
			Where LS.ListingServiceID=<cfqueryparam value="#PK#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfif not getListingService.RecordCount>
			No Listing Service record found.
			<cfinclude template="../Lighthouse/Admin/Footer.cfm">
			<cfabort>
		</cfif>
		<cfset ListingID=getListingService.ListingID>
	</cfif>
	
	<cfquery name="getListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT UserID
		FROM ListingsView 
		Where ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfoutput>
	<script language="JavaScript" src="#Request.AppVirtualPath#/public.js" type="text/javascript"></script>
	</cfoutput>
	<script>
		function validateForm(formObj) {											
			if (!checkText(formObj.elements["OrderDate"],"Date")) return false;		
			if (!checkDateDDMMYYYY(formObj.elements["OrderDate"],"Date")) return false;								
			if (!checkText(formObj.elements["ServiceOrderAmount"],"Amount")) return false;							
			if (!checkNumber(formObj.elements["ServiceOrderAmount"],"Amount")) return false;						
			if (!checkText(formObj.elements["ServicDescr"],"Description of Services")) return false;		
							
			return true;
		}	
			
	</script>
		
	<cfoutput>
	<h1 style="margin: 0px;">Service Order:  <cfif PK is "0">Add<cfelse>Edit</cfif></h1>
	
	<FORM ACTION="ServiceOrder.cfm" METHOD="POST" NAME="f1" ONSUBMIT="return validateForm(this)">
	<INPUT TYPE="HIDDEN" NAME="pk" ID="pk" VALUE="#pk#">
	<INPUT TYPE="HIDDEN" NAME="AcctID" ID="AcctID" VALUE="#getListing.UserID#">
	<INPUT TYPE="HIDDEN" NAME="ListingID" ID="ListingID" VALUE="#ListingID#">
	<INPUT TYPE="HIDDEN" NAME="DoIt" VALUE="1"> 
	
		<TABLE CLASS=ADDTABLE CELLPADDING=5 CELLSPACING=0>		
				<TR CLASS=ADDROW ID="OrderDate_TR">	
					<td CLASS=ADDLABELCELL>
						<label for="OrderDate">*&nbsp;Date:</label>	
					</TD>
					<td  CLASS=ADDFIELDCELL>
						<cfif PK is "0">
							<script type="text/javascript">
							dojo.addOnLoad(function(){
								dojo.require("dojo.widget.*");
								dojo.require("dojo.widget.DatePicker");
								dojo.require("dojo.widget.PopupContainer");
						
							});
							</script>
							
							<input type="TEXT" id="OrderDate" name="OrderDate" value="" >
							<img style="vertical-align:middle;cursor:pointer;" alt="Select a date" 
								onclick="lh.ShowPopupCalendar(getEl('OrderDate'),'DD/MM/YYYY')"
								src="../Lighthouse/dojo/src/widget/templates/images/dateIcon.gif"/>		
						<cfelse>
							#DateFormat(getListingService.ServiceDate,'dd/mm/yyyy')#
							<input type="hidden" name="OrderDate" id="OrderDate" value="#DateFormat(getListingService.ServiceDate,'dd/mm/yyyy')#" >
						</cfif>
					</TD>
					
				</TR> 
				<TR CLASS=ADDROW ID="ServiceOrderAmount_TR">
					<td CLASS=ADDLABELCELL>
						<label for="ServiceOrderAmount">*&nbsp;Amount:</label>	
					</TD>
					<td CLASS=ADDFIELDCELL>	
						<cfif PK is "0">
							<INPUT TYPE="TEXT" NAME="ServiceOrderAmount" ID="ServiceOrderAmount" VALUE="" >	
						<cfelse>
							#DollarFormat(getListingService.ServiceOrderAmount)#
							<INPUT TYPE="hidden" NAME="ServiceOrderAmount" ID="ServiceOrderAmount" VALUE="#getListingService.ServiceOrderAmount#" >	
						</cfif>
					</TD>
				</TR>
				<TR CLASS=ADDROW ID="ServicDescr_TR">
					<td CLASS=ADDLABELCELL>
						<label for="ServicDescr">*&nbsp;Description of Services:</label>	
					</TD>
					<td CLASS=ADDFIELDCELL>	
						<textarea cols="50" rows="10" name="ServiceDescr" id="ServiceDescr"><cfif PK>#getListingService.ServiceDescr#</cfif></textarea>
					</TD>
				</TR>	
				<TR ID="AddEditFormBottomButtons">
				<td CLASS=SMALLTEXT>* Required Field</TD>
				<td CLASS=SMALLTEXT ALIGN=RIGHT>					
					<INPUT TYPE="SUBMIT" id="SubmitButton" VALUE="Submit" class=button>		
				</TD>
			</TR>				
			</TABLE>
	</FORM>
	</cfoutput>		


<cfinclude template="../Lighthouse/Admin/Footer.cfm">