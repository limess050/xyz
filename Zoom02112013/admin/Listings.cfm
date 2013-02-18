
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Listings">
<cfinclude template="../Lighthouse/Admin/Header.cfm">
<cfoutput><script language="JavaScript" src="#Request.HTTPSURL#/scripts/jquery-1.3.2.min.js" type="text/javascript"></script></cfoutput>

<cfparam name="Action" default="View">
<cfparam name="ListingTable" default="Listings">

<cfif ListFind("Search,View,DisplayOptions",Action)>
	<cfset ListingTable="ListingsView">
</cfif>

<cfif Action is "Edit">
	<cfset session.ListingReferer=CGI.HTTP_Referer>
	<cfquery name="getListingType" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select ListingTypeID 
		From Listings
		Where ListingID=<cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfswitch expression="#getListingType.ListingTypeID#">
		<cfcase value="1">		
			<cflocation url="ListingBUS1.cfm?Action=Edit&PK=#PK#" AddToken="No">
			<cfabort>
		</cfcase>
		<cfcase value="2">		
			<cflocation url="ListingBUS2.cfm?Action=Edit&PK=#PK#" AddToken="No">
			<cfabort>
		</cfcase>
		<cfcase value="3">		
			<cflocation url="ListingFSBO1.cfm?Action=Edit&PK=#PK#" AddToken="No">
			<cfabort>
		</cfcase>
		<cfcase value="4">		
			<cflocation url="ListingFSBO2.cfm?Action=Edit&PK=#PK#" AddToken="No">
			<cfabort>
		</cfcase>
		<cfcase value="5">		
			<cflocation url="ListingFSBO3.cfm?Action=Edit&PK=#PK#" AddToken="No">
			<cfabort>
		</cfcase>
		<cfcase value="6">		
			<cflocation url="ListingHR1.cfm?Action=Edit&PK=#PK#" AddToken="No">
			<cfabort>
		</cfcase>
		<cfcase value="7">		
			<cflocation url="ListingHR2.cfm?Action=Edit&PK=#PK#" AddToken="No">
			<cfabort>
		</cfcase>
		<cfcase value="8">		
			<cflocation url="ListingHR3.cfm?Action=Edit&PK=#PK#" AddToken="No">
			<cfabort>
		</cfcase>
		<cfcase value="9">
			<cflocation url="ListingTTT1.cfm?Action=Edit&PK=#PK#" AddToken="No">
			<cfabort>
		</cfcase>
		<cfcase value="10">
			<cflocation url="ListingJE1.cfm?Action=Edit&PK=#PK#" AddToken="No">
			<cfabort>
		</cfcase>
		<cfcase value="11">
			<cflocation url="ListingJE2.cfm?Action=Edit&PK=#PK#" AddToken="No">
			<cfabort>
		</cfcase>
		<cfcase value="12">
			<cflocation url="ListingJE3.cfm?Action=Edit&PK=#PK#" AddToken="No">
			<cfabort>
		</cfcase>
		<cfcase value="13">
			<cflocation url="ListingJE4.cfm?Action=Edit&PK=#PK#" AddToken="No">
			<cfabort>
		</cfcase>
		<cfcase value="14">
			<cflocation url="ListingCOM1.cfm?Action=Edit&PK=#PK#" AddToken="No">
			<cfabort>
		</cfcase>
		<cfcase value="15">
			<cflocation url="ListingEVE1.cfm?Action=Edit&PK=#PK#" AddToken="No">
			<cfabort>
		</cfcase>
		<cfcase value="20">		
			<cflocation url="ListingMOV.cfm?Action=Edit&PK=#PK#" AddToken="No">
			<cfabort>
		</cfcase>
		<cfdefaultcase>
			<p class="STATUSMESSAGE">No form for this Listing Type found.</p>
			<cfinclude template="../Lighthouse/Admin/Footer.cfm">
			<cfabort>	
		</cfdefaultcase>
	</cfswitch>
	<p class="STATUSMESSAGE">No Listing Type found.</p>
	<cfinclude template="../Lighthouse/Admin/Footer.cfm">
	<cfabort>	
</cfif>

<lh:MS_Table table="#ListingTable#" title="#pg_title#"
	DisallowedActions="Add,Delete" >
	
	<lh:MS_TableColumn
		ColName="ListingID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true" />
	
	<lh:MS_TableColumn
		ColName="ListingTypeID"
		DispName="Category Listing Type"
		type="select"
		Required="Yes"
		FKTable="ListingTypes"
		FKDescr="Title + ' - ' + Descr"/>
		
	<lh:MS_TableColumn
		ColName="ParentSectionID"
		DispName="Parent Section"
		type="select-multiple"
		FKTable="ParentSectionsView"
		FKColName="ParentSectionID"
		FKDescr="Title"
		FKJoinTable="ListingParentSections"
		SelectQuery="Select ParentSectionID as SelectValue, Title as SelectText From ParentSectionsView Order By OrderNum"
		Required="Yes" />		
		
	<lh:MS_TableColumn
		ColName="SectionID"
		DispName="Sub-Section"
		type="select-multiple"
		FKTable="Sections"
		FKColName="SectionID"
		FKDescr="Title"
		FKJoinTable="ListingSections"
		SelectQuery="Select SectionID as SelectValue, Title as SelectText From SectionsView Order By OrderNum"
		Required="Yes" />	
		
	<lh:MS_TableColumn
		ColName="CategoryID"
		DispName="Category"
		type="select-multiple"
		FKTable="Categories"
		FKColName="CategoryID"
		FKDescr="Title"
		FKJoinTable="ListingCategories"
		Required="Yes" />	
		
	<lh:MS_TableColumn
		ColName="ListingTitle"
		DispName="Title"
		type="text" 
		MaxLength="200"
		Required="No" />
		 
	<lh:MS_TableColumn
		ColName="ListingLink"
		DispName="Listing Edit Link"
		type="pseudo"
		Expression="'#Request.HTTPURL#/postalisting?Step=2&LinkID=' + Cast(LinkID as varchar(100))" 
		Search="false" />
		 
	<lh:MS_TableColumn
		ColName="ListingFriendlyURL"
		DispName="Listing URL"
		type="pseudo"
		Expression="CASE WHEN ListingsView.ListingTypeID in (1,2,14) THEN '#Request.HTTPURL#/' + URLSafeTitle
ELSE '#Request.HTTPURL#/ListingDetail?ListingID=' + Cast(ListingID as varchar(10)) END" 
		Search="false" />
		
	<!--- <lh:MS_TableColumn
		ColName="ContactName"
		DispName="Contact Name"
		type="text" 
		Required="Yes" />
		
	<lh:MS_TableColumn
		ColName="ContactPhone"
		DispName="Contact Phone"
		type="text" 
		Required="Yes" />
		
	<lh:MS_TableColumn
		ColName="ContactEmail"
		DispName="Contact Email"
		type="text" 
		Required="Yes" /> --->
		
	<lh:MS_TableColumn
		ColName="UserID"
		DispName="Account Number"
		search="true"  />
		 
	<lh:MS_TableColumn
		ColName="AccountLink"
		DispName="Account Link"
		type="pseudo"
		Expression="'<a href=""Accounts.cfm?Action=Edit&PK=' + Cast(UserID as varchar(20)) +'"" target=""_blank"">' + Cast(UserID as varchar(20)) + '</a>'" 
		Search="false" />
		
	<lh:MS_TableColumn
		ColName="AccountName"
		DispName="Account Name"
		type="text" 
		Required="Yes" />
		
	<lh:MS_TableColumn 
		colname="Active" 
		DispName="Listing Active"
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="1" />
		
	<lh:MS_TableColumn 
		colname="InProgress" 
		DispName="Still In Progress"
		HelpText="Listings marked In Progress have never been submitted by the front end user as complete."
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="1" />
		
	<lh:MS_TableColumn
		ColName="LocationID"
		DispName="Areas"
		type="select-multiple"
		FKTable="Locations"
		FKColName="LocationID"
		FKDescr="Title"
		FKOrderBy="OrderNum"
		FKJoinTable="ListingLocations" />	
		
	<lh:MS_TableColumn
		ColName="Preview"
		DispName="Preview Listing"
		type="pseudo"
		Search="False"
		Expression="CASE WHEN ExpandedListingHTML is not null THEN '<a href=""#Request.HTTPSURL#/listingdetail?ListingID=' + Cast(ListingID as varchar(20)) +'&Preview=1"" target=""_blank"">Basic</a><br /><a href=""#Request.HTTPSURL#/ExpandedListing.cfm?ListingID=' + Cast(ListingID as varchar(20)) +'"" target=""_blank"">Expanded HTML</a>' 
WHEN ExpandedListingPDF is not null THEN '<a href=""#Request.HTTPSURL#/listingdetail?ListingID=' + Cast(ListingID as varchar(20)) +'&Preview=1"" target=""_blank"">Basic</a><br /><a href=""#Request.HTTPSURL#/ListingUploadedDocs/' + ExpandedListingPDF +'"" target=""_blank"">Expanded PDF</a>' 
ELSE '<a href=""#Request.HTTPSURL#/listingdetail?ListingID=' + Cast(ListingID as varchar(20)) +'&Preview=1"" target=""_blank"">Basic</a>' END"  />
		
	<lh:MS_TableColumn 
		colname="Reviewed" 
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="0" />
		
	<lh:MS_TableColumn 
		colname="FeaturedListing" 
		DispName="Featured Business Listing"
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="0" />
		
	<lh:MS_TableColumn 
		colname="FeaturedTravelListing" 
		DispName="Featured Travel Listing"
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="0" />
		
	<lh:MS_TableColumn
		ColName="RelatedOrderID"
		DispName="Related Orders"
		type="select-multiple"
		FKTable="RelatedOrdersView"
		FKColName="RelatedOrderID"
		FKDescr="OrderLink"
		FKJoinTable="ListingRelatedOrdersView" />	
		
	<lh:MS_TableColumn
		ColName="RelOrders"
		DispName="Related Orders Two"
		type="pseudo"
		Expression="'#Request.HTTPURL#/postalisting?Step=2&LinkID=' + Cast(LinkID as varchar(100))" 
		Search="false" />
	
	<lh:MS_TableColumn
		ColName="ListingPackageID"
		type="radio"
		Hidden="true"
		Required="Yes"
		FKTable="ListingPackages"
		FKDescr="ListingPackageID"/>
	
	<lh:MS_TableColumn
		ColName="ListingPackageListings"
		DispName="Listing Package"
		type="pseudo"
		Search="no"
		Expression="'<a href=""Listings.cfm?Action=View&Searching=1&ListingPackageID=' + Cast(ListingsView.ListingPackageID as varchar(20)) +'"">' + Cast(ListingsView.ListingPackageID as varchar(20)) + '</a>'" />
		
	<lh:MS_TableColumn
		ColName="DateListed"
		DispName="Date Added"
		ShowDate="Yes" 
		type="Date"
		Required="Yes"
		Format="DD/MM/YYYY" />
		
	<!--- <lh:MS_TableColumn
		ColName="DateLive"
		DispName="Date Live"
		ShowDate="Yes" 
		type="Date"
		Editable="No"
		Format="DD/MM/YYYY" /> --->
		
	<lh:MS_TableColumn
		ColName="DateSort"
		DispName="Sort Date"
		ShowDate="Yes" 
		type="Date"
		Editable="No"
		Format="DD/MM/YYYY" />

	<lh:MS_TableColumn
		ColName="ExpirationDate"
		DispName="Expiration Date"
		ShowDate="Yes" 
		type="Date"
		Required="No"
		Format="DD/MM/YYYY"  />

	<lh:MS_TableColumn
		ColName="ExpirationDateELP"
		DispName="ELP Expiration Date"
		ShowDate="Yes" 
		type="Date"
		Required="No"
		Format="DD/MM/YYYY"  />
		
	<lh:MS_TableColumn 
		colname="HasExpandedListing" 
		DispName="Has Optional Expanded Listing Page"
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="0" />
		
	<lh:MS_TableColumn 
		colname="DeletedAfterSubmitted" 
		DispName="Marked As Deleted"
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="0"
		Editable="false" />
		
	<lh:MS_TableColumn
		ColName="DeletedAfterSubmittedDate"
		DispName="Date Marked As Deleted"
		ShowDate="Yes" 
		type="Date"
		Required="No"
		Editable="No"
		Format="DD/MM/YYYY"  />
		
	<lh:MS_TableColumn
		ColName="PublicEmail"
		DispName="Public Email"
		type="text" 
		Required="Yes" />

	<lh:MS_TableColumnGroup groupname="LContacts" label="Listing Contacts">
	
		<lh:MS_TableColumn
			ColName="ContactFirstName"
			DispName="L Contact First Name"
			type="text"
			View="No" />		
		
		<lh:MS_TableColumn
			ColName="ContactLastName"
			DispName="L Contact Last Name"
			type="text"
			View="No" />		
		
		<lh:MS_TableColumn
			ColName="ContactPhone"
			DispName="L Contact Phone"
			type="text"
			View="No" />		
		
		<lh:MS_TableColumn
			ColName="ContactEmail"
			DispName="L Contact Email"
			type="text"
			View="No" />
	
		<lh:MS_TableColumn
			ColName="AltContactFirstName"
			DispName="L Alt Contact First Name"
			type="text"
			View="No" />		
		
		<lh:MS_TableColumn
			ColName="AltContactLastName"
			DispName="L Alt Contact Last Name"
			type="text"
			View="No" />		
		
		<lh:MS_TableColumn
			ColName="AltContactPhone"
			DispName="L Alt Contact Phone"
			type="text"
			View="No" />		
		
		<lh:MS_TableColumn
			ColName="AltContactEmail"
			DispName="L Alt Contact Email"
			type="text"
			View="No" />
	
	</lh:MS_TableColumnGroup>
		
	

	<lh:MS_TableColumnGroup groupname="AcctContacts" label="Account Contacts">
	
		<lh:MS_TableColumn
			ColName="AcctContactFirstName"
			DispName="Acct Contact First Name"
			type="text"
			View="No" />		
		
		<lh:MS_TableColumn
			ColName="AcctContactLastName"
			DispName="Acct Contact Last Name"
			type="text"
			View="No" />		
		
		<lh:MS_TableColumn
			ColName="AcctContactPhone"
			DispName="Acct Contact Phone"
			type="text"
			View="No" />		
		
		<lh:MS_TableColumn
			ColName="AcctContactEmail"
			DispName="Acct Contact Email"
			type="text"
			View="No" />
	
		<lh:MS_TableColumn
			ColName="AcctAltContactFirstName"
			DispName="Acct Alt Contact First Name"
			type="text"
			View="No" />		
		
		<lh:MS_TableColumn
			ColName="AcctAltContactLastName"
			DispName="Acct Alt Contact Last Name"
			type="text"
			View="No" />		
		
		<lh:MS_TableColumn
			ColName="AcctAltContactPhone"
			DispName="Acct Alt Contact Phone"
			type="text"
			View="No" />		
		
		<lh:MS_TableColumn
			ColName="AcctAltContactEmail"
			DispName="Acct Alt Contact Email"
			type="text"
			View="No" />
	
	</lh:MS_TableColumnGroup>
	
	
	<lh:MS_TableColumnGroup groupname="Impressions" label="Impressions">
		
		<lh:MS_TableColumn
			ColName="Impressions"
			DispName="Number of Basic Listing Viewings"
			type="integer"  />
			
		<lh:MS_TableColumn
			ColName="ImpressionsResultsPage"
			DispName="Number of Results Pages Viewings"
			type="integer"  />
		
		<lh:MS_TableColumn
			ColName="ImpressionsExpanded"
			DispName="Number of Expanded Listing Viewings"
			type="integer"  />
			
		<lh:MS_TableColumn
			ColName="ImpressionsExternal"
			DispName="Number of External Website Viewings"
			type="integer"  />
		
		<lh:MS_TableColumn
			ColName="ImpressionsEmailInquiries"
			DispName="Number of mail Inquiries"
			type="integer"  />
	
	</lh:MS_TableColumnGroup>	
	
	<lh:MS_TableColumn
		ColName="Blacklist_Fl"
		DispName="Blacklisted"
		type="Checkbox"
		OnValue="1"
		OffValue="0"
		DefaultValue="0" />
		
	<!--- <lh:MS_TableColumn
		ColName="Impressions"
		DispName="Number of Viewings"
		type="pseudo" 
		expression="(Select Count(ImpressionID) from Impressions Where ListingID=ListingsView.ListingID and ExpandedListingImpression=0 and ExternalURLImpression=0)" />
	
	<lh:MS_TableColumn
		ColName="ImpressionsExpanded"
		DispName="Number of Expanded Listing Viewings"
		type="pseudo" 
		expression="(Select Count(ImpressionID) from Impressions Where ListingID=ListingsView.ListingID and ExpandedListingImpression=1)" />
		
	<lh:MS_TableColumn
		ColName="ImpressionsExternal"
		DispName="Number of External Website Viewings"
		type="pseudo" 
		expression="(Select Count(ImpressionID) from Impressions Where ListingID=ListingsView.ListingID and ExternalURLImpression=1)" /> --->
		
	<cfif Request.environment is "Live" or Request.environment is "Devel" or Request.environment is "DB">
		<lh:MS_TableRowAction
			ActionName="CustomTwo"
			Label="Send Listing Email"
			HREF="javascript:void(0);"
			onClick="sendListingEmail(##PK##);"
			View="No"/>
	</cfif>
	
	<lh:MS_TableRowAction
		ActionName="Custom"
		Label="Blacklist Account"
		HREF="javascript:void(0);"
		onClick="blacklistListingsAccount(this,##PK##);"
		Condition="Blacklist_Fl is 0"/>
		
</lh:MS_Table>

<cfif ListFind("Search",Action)>	
	<cfset IncludeCats="1">
	<cfinclude template="includes/GetSubSectionsScript.cfm">	
</cfif>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">

<cfoutput>
	
<script language="javascript" type="text/javascript">
	
	function sendListingEmail(x){
		var datastring = "PK=" + x;
		$.ajax(
           {
			type:"POST",
               url:"#Request.HTTPSURL#/Admin/ListingEmail.cfc?method=SendEmail&returnformat=plain",
               data:datastring,
               success: function(response)
               {
				alert('Listing Email Sent');
               }
           });
	}
	
	function checkDate(x,y) {
		return checkDateDDMMYYYY(x,y);
	}
	
	function checkDateDDMMYYYY(fieldObj, s) {
		dateStr = fieldObj.value;
		if (isEmpty(dateStr)) return true;
	
		var datePat = /^(\d{1,2})(\/|-)(\d{1,2})(\/|-)((\d{2}|\d{4}))$/;
		var matchArray = dateStr.match(datePat); // is the format ok?
		if (matchArray == null) {
			return warnInvalid (fieldObj,"Value in field " + s + " must be in the form of dd/mm/yyyy.");
		}
		month = matchArray[3]; // parse date into variables
		day = matchArray[1];
		year = matchArray[5];
		if (month < 1 || month > 12) { // check month range
			return warnInvalid (fieldObj,"Month must be between 1 and 12 for field " + s + ".");
		}
		if (day < 1 || day > 31) {
			return warnInvalid (fieldObj,"Day must be between 1 and 31 for field " + s + ".");
		}
		if (year < 1900 || year > 2078) {
			return warnInvalid (fieldObj,"Year must be between 1900 and 2078 for field " + s + ".");
		}
		if ((month==4 || month==6 || month==9 || month==11) && day==31) {
			return warnInvalid (fieldObj,"Month "+month+" doesn't have 31 days for field " + s + ".")
		}
		if (month == 2) { // check for february 29th
			var isleap = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
			if (day > 29 || (day==29 && !isleap)) {
				return warnInvalid (fieldObj,"February " + year + " doesn't have " + day + " days for field " + s + ".");
			}
		}
		return true; // date is valid
	}
	
	<cfinclude template="includes/BlacklistingJS.cfm">
</script>
</cfoutput>
