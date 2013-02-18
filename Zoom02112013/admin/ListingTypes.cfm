
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Listing Types">
<cfinclude template="../Lighthouse/Admin/Header.cfm">
<cfoutput><script language="JavaScript" src="#Request.HTTPSURL#/scripts/jquery-1.3.2.min.js" type="text/javascript"></script></cfoutput>

<cfparam name="Action" default="View">
<cfparam name="BasicFeeLabel" default="Basic Listing Fee">
<cfparam name="DiscountFeeLabel" default="">
<cfparam name="PriceOrRentLabel" default="Price">

<cfif Action is "Edit">
	<cfswitch expression="#PK#">
		<cfcase value="3,4,5">
			<cfset DiscountFeeLabel="FSBO4">
		</cfcase>
		<cfcase value="6,7,8">
			<cfset DiscountFeeLabel="HR4">
			<cfif ListFind("6,7",PK)>
				<cfset PriceOrRentLabel="Rent">
			</cfif>
		</cfcase>
		<cfcase value="9">
			<cfset BasicFeeLabel="Basic and Expanded Listing Fee">
		</cfcase>
	</cfswitch>
</cfif>
<lh:MS_Table 
	table="ListingTypes" 
	title="#pg_title#"
	DisallowedActions="Add,Delete,Search"
	OrderBy="OrderNum" >
	
	<lh:MS_TableColumn
		ColName="ListingTypeID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true" />		
		
	<lh:MS_TableColumn
		ColName="Title"
		type="text" 
		Required="Yes"
		MaxLength="50"
		Editable="No" />
	
	<cfif ListFind("View,DisplayOptions",Action) or (IsDefined('pk') and ListFind("1,2,9,10,11,12,13,14,15,20",PK))>
		<lh:MS_TableColumn
			ColName="BasicFee"
			DispName="#BasicFeeLabel#"
			type="integer" 
			Format="_$_,___.__" 
			Required="Yes" />
	</cfif>	
	
	<cfif Action neq "View" and IsDefined('pk') and ListFind("3,4,5,6,7,8",PK)>
		<lh:MS_TableChild 
			name="ListingTypesPricing" 
			Dispname="Child Table" 
			OrderBy="USPriceStart" 
			View="No" 
			Search="Yes"
			Required="Yes">
			
			<lh:MS_TableColumn 
				colname="USPriceStart" 
				DispName="#PriceOrRentLabel# Start USD"
				type="integer"
				Format="_$_,___.__" 
				required="Yes" />
			
			<lh:MS_TableColumn 
				colname="USPriceEnd" 
				DispName="#PriceOrRentLabel# End USD"
				type="integer"
				Format="_$_,___.__" 
				required="Yes" />
			
			<lh:MS_TableColumn 
				colname="TZSPriceStart" 
				DispName="#PriceOrRentLabel# Start TZS"
				type="integer"
				Format="_$_,___.__" 
				required="Yes" />
			
			<lh:MS_TableColumn 
				colname="TZSPriceEnd" 
				DispName="#PriceOrRentLabel# End TZS"
				type="integer"
				Format="_$_,___.__" 
				required="Yes" />
			
			<lh:MS_TableColumn 
				colname="ListingFee" 
				DispName="Listing Fee"
				type="integer"
				Format="_$_,___.__" 
				required="Yes" />
				
		</lh:MS_TableChild>
	</cfif>
	
	<cfif ListFind("View,DisplayOptions",Action) or (Isdefined('pk') and ListFind("1,2,10,11,12,13,14,15,20",PK))>
		<lh:MS_TableColumn
			ColName="ExpandedFee"
			DispName="Expanded Listing Fee"
			type="integer" 
			Format="_$_,___.__" 
			Required="Yes" />
	</cfif>
	
	<cfif ListFind("View,DisplayOptions",Action) or (Isdefined('pk') and ListFind("16,17,18",PK))>
		<lh:MS_TableColumn
			ColName="FivePerYearFee"
			DispName="5 Listings P/Y"
			type="integer" 
			Format="_$_,___.__" 
			Required="Yes" />
			
		<lh:MS_TableColumn
			ColName="TenPerYearFee"
			DispName="10 Listings P/Y"
			type="integer" 
			Format="_$_,___.__" 
			Required="Yes" />
			
		<lh:MS_TableColumn
			ColName="TwentyPerYearFee"
			DispName="20 Listings P/Y"
			type="integer" 
			Format="_$_,___.__" 
			Required="Yes" />
			
		<lh:MS_TableColumn
			ColName="UnlimitedPerYearFee"
			DispName="Unlimited Listings P/Y"
			type="integer" 
			Format="_$_,___.__" 
			Required="Yes" />
	</cfif>		
		
	<lh:MS_TableColumn
		ColName="TermExpiration"
		DispName="Term/Expiration"
		type="integer" 
		Required="Yes" />
		
	<lh:MS_TableColumn
		ColName="RenewReminder1"
		DispName="Renewal Reminder 1"
		type="integer" />
		
	<lh:MS_TableColumn
		ColName="RenewReminder2"
		DispName="Renewal Reminder 2"
		type="integer" />
		
	<lh:MS_TableColumn
		ColName="RenewReminder3"
		DispName="Renewal Reminder 3"
		type="integer" />
		
	<lh:MS_TableColumn 
		colname="AllowFreeRenewal" 
		DispName="Opt-in Free Renewal Allowed?"
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="1" />
		
	<lh:MS_TableColumn
		ColName="PaymentReminder1"
		DispName="Payment Reminder 1"
		type="integer" />
		
	<lh:MS_TableColumn
		ColName="PaymentReminder2"
		DispName="Payment Reminder 2"
		type="integer" />
		
	<lh:MS_TableColumn
		ColName="CheckInEmail"
		DispName="Check In Email"
		type="integer" />	
	
	<lh:MS_TableColumn
		ColName="CheckInText"
		DispName="Check In Email Text"
		type="textarea"
		allowHTML="Yes"
		SpellCheck="Yes"
		View="No" />	

	<lh:MS_TableAction
		ActionName="ListOrder"
		Label="Order Table"
		DescriptionColumn="Title"
		OrderColumn="OrderNum"
		View="No" />
		
	<lh:MS_TableEvent
		EventName="OnAfterUpdate"
		Include="../../admin/ListingTypes_onAfterUpdate.cfm" />
		
</lh:MS_Table>

<cfif ListFind("Search",Action)>	
	<cfset IncludeCats="1">
	<cfinclude template="includes/GetSubSectionsScript.cfm">	
</cfif>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">