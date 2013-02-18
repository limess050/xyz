
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Listings">
<cfinclude template="../Lighthouse/Admin/Header.cfm">
<cfoutput><script language="JavaScript" src="#Request.HTTPSURL#/scripts/jquery-1.3.2.min.js" type="text/javascript"></script></cfoutput>

<cfparam name="Action" default="View">
<cfparam name="ListingTable" default="Listings">

<cfif ListFind("Search,View,DisplayOptions",Action)>
	<cfset ListingTable="ListingsView">
</cfif>



<lh:MS_Table table="#ListingTable#" title="#pg_title#"
	DisallowedActions="Add,Delete,Edit" >
	
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
		FKDescr="Title + ' - ' + Descr"
		View="No"/>
		
	<lh:MS_TableColumn
		ColName="ParentSectionID"
		DispName="Parent Section"
		type="select-multiple"
		FKTable="ParentSectionsView"
		FKColName="ParentSectionID"
		FKDescr="Title"
		FKJoinTable="ListingParentSections"
		SelectQuery="Select ParentSectionID as SelectValue, Title as SelectText From ParentSectionsView Order By OrderNum"
		Required="Yes"
		View="No" />		
		
	<lh:MS_TableColumn
		ColName="SectionID"
		DispName="Sub-Section"
		type="select-multiple"
		FKTable="Sections"
		FKColName="SectionID"
		FKDescr="Title"
		FKJoinTable="ListingSections"
		SelectQuery="Select SectionID as SelectValue, Title as SelectText From SectionsView Order By OrderNum"
		Required="Yes"
		View="No" />	
		
	<lh:MS_TableColumn
		ColName="CategoryID"
		DispName="Category"
		type="select-multiple"
		FKTable="Categories"
		FKColName="CategoryID"
		FKDescr="Title"
		FKJoinTable="ListingCategories"
		Required="Yes"
		View="No" />	
		
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
		Search="false"
		View="No" />
		 
	<lh:MS_TableColumn
		ColName="ListingFriendlyURL"
		DispName="Listing URL"
		type="pseudo"
		Expression="CASE WHEN ListingsView.ListingTypeID in (1,2,14) THEN '#Request.HTTPURL#/' + URLSafeTitle
ELSE '#Request.HTTPURL#/ListingDetail?ListingID=' + Cast(ListingID as varchar(10)) END" 
		Search="false"
		View="No" />
		
	<lh:MS_TableColumn
		ColName="UserID"
		DispName="Account Number"
		search="true"
		View="No"  />
		 
	<lh:MS_TableColumn
		ColName="AccountLink"
		DispName="Account Link"
		type="pseudo"
		Expression="'<a href=""Accounts.cfm?Action=Edit&PK=' + Cast(UserID as varchar(20)) +'"" target=""_blank"">' + Cast(UserID as varchar(20)) + '</a>'" 
		Search="false"
		View="No" />
		
	<lh:MS_TableColumn
		ColName="AccountName"
		DispName="Account Name"
		type="text" 
		Required="Yes"
		View="No" />
		
	<lh:MS_TableColumn 
		colname="Active" 
		DispName="Listing Active"
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="1"
		View="No" />
		
	<lh:MS_TableColumn 
		colname="InProgress" 
		DispName="Still In Progress"
		HelpText="Listings marked In Progress have never been submitted by the front end user as complete."
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="1"
		View="No" />
		
	<lh:MS_TableColumn
		ColName="LocationID"
		DispName="Areas"
		type="select-multiple"
		FKTable="Locations"
		FKColName="LocationID"
		FKDescr="Title"
		FKOrderBy="OrderNum"
		FKJoinTable="ListingLocations"
		View="No" />	
		
	<lh:MS_TableColumn
		ColName="Preview"
		DispName="Preview Listing"
		type="pseudo"
		Search="False"
		Expression="CASE WHEN ExpandedListingHTML is not null THEN '<a href=""#Request.HTTPSURL#/listingdetail?ListingID=' + Cast(ListingID as varchar(20)) +'&Preview=1"" target=""_blank"">Basic</a><br /><a href=""#Request.HTTPSURL#/ExpandedListing.cfm?ListingID=' + Cast(ListingID as varchar(20)) +'"" target=""_blank"">Expanded HTML</a>' 
WHEN ExpandedListingPDF is not null THEN '<a href=""#Request.HTTPSURL#/listingdetail?ListingID=' + Cast(ListingID as varchar(20)) +'&Preview=1"" target=""_blank"">Basic</a><br /><a href=""#Request.HTTPSURL#/ListingUploadedDocs/' + ExpandedListingPDF +'"" target=""_blank"">Expanded PDF</a>' 
ELSE '<a href=""#Request.HTTPSURL#/listingdetail?ListingID=' + Cast(ListingID as varchar(20)) +'&Preview=1"" target=""_blank"">Basic</a>' END"
		View="No"  />
		
	<lh:MS_TableColumn 
		colname="Reviewed" 
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="0"
		View="No" />
		
	<lh:MS_TableColumn 
		colname="FeaturedListing" 
		DispName="Featured Business Listing"
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="0"
		View="No" />
		
	<lh:MS_TableColumn 
		colname="FeaturedTravelListing" 
		DispName="Featured Travel Listing"
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="0"
		View="No" />
		
	<lh:MS_TableColumn
		ColName="RelatedOrderID"
		DispName="Related Orders"
		type="select-multiple"
		FKTable="RelatedOrdersView"
		FKColName="RelatedOrderID"
		FKDescr="OrderLink"
		FKJoinTable="ListingRelatedOrdersView"
		View="No" />	
		
	<lh:MS_TableColumn
		ColName="RelOrders"
		DispName="Related Orders Two"
		type="pseudo"
		Expression="'#Request.HTTPURL#/postalisting?Step=2&LinkID=' + Cast(LinkID as varchar(100))" 
		Search="false"
		View="No" />
	
	<lh:MS_TableColumn
		ColName="ListingPackageID"
		type="radio"
		Hidden="true"
		Required="Yes"
		FKTable="ListingPackages"
		FKDescr="ListingPackageID"
		View="No" />
	
	<lh:MS_TableColumn
		ColName="ListingPackageListings"
		DispName="Listing Package"
		type="pseudo"
		Search="no"
		Expression="'<a href=""Listings.cfm?Action=View&Searching=1&ListingPackageID=' + Cast(ListingsView.ListingPackageID as varchar(20)) +'"">' + Cast(ListingsView.ListingPackageID as varchar(20)) + '</a>'"
		View="No" />
		
	<lh:MS_TableColumn
		ColName="DateListed"
		DispName="Date Added"
		ShowDate="Yes" 
		type="Date"
		Required="Yes"
		Format="DD/MM/YYYY"
		View="No" />
		
	<lh:MS_TableColumn
		ColName="DateSort"
		DispName="Sort Date"
		ShowDate="Yes" 
		type="Date"
		Editable="No"
		Format="DD/MM/YYYY"
		View="No" />

	<lh:MS_TableColumn
		ColName="ExpirationDate"
		DispName="Expiration Date"
		ShowDate="Yes" 
		type="Date"
		Required="No"
		Format="DD/MM/YYYY"
		View="No"  />

	<lh:MS_TableColumn
		ColName="ExpirationDateELP"
		DispName="ELP Expiration Date"
		ShowDate="Yes" 
		type="Date"
		Required="No"
		Format="DD/MM/YYYY"
		View="No"  />
		
	<lh:MS_TableColumn 
		colname="HasExpandedListing" 
		DispName="Has Optional Expanded Listing Page"
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="0"
		View="No" />
		
	<lh:MS_TableColumn 
		colname="DeletedAfterSubmitted" 
		DispName="Marked As Deleted"
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="0"
		Editable="false"
		View="No" />
		
	<lh:MS_TableColumn
		ColName="DeletedAfterSubmittedDate"
		DispName="Date Marked As Deleted"
		ShowDate="Yes" 
		type="Date"
		Required="No"
		Editable="No"
		Format="DD/MM/YYYY"
		View="No"  />
		
	<lh:MS_TableColumn
		ColName="PublicEmail"
		DispName="Public Email"
		type="text" 
		Required="Yes"
		View="No" />

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
			type="integer"
			View="No"  />
			
		<lh:MS_TableColumn
			ColName="ImpressionsResultsPage"
			DispName="Number of Results Pages Viewings"
			type="integer"
			View="No" />
		
		<lh:MS_TableColumn
			ColName="ImpressionsExpanded"
			DispName="Number of Expanded Listing Viewings"
			type="integer"
			View="No" />
			
		<lh:MS_TableColumn
			ColName="ImpressionsExternal"
			DispName="Number of External Website Viewings"
			type="integer"
			View="No" />
		
		<lh:MS_TableColumn
			ColName="ImpressionsEmailInquiries"
			DispName="Number of mail Inquiries"
			type="integer"
			View="No" />
	
	</lh:MS_TableColumnGroup>

	<lh:MS_TableRowAction
		ActionName="Select"
		ColName="ListingID"
		Descr="Title" />
		
</lh:MS_Table>

<cfif ListFind("Search",Action)>	
	<cfset IncludeCats="1">
	<cfinclude template="includes/GetSubSectionsScript.cfm">	
</cfif>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">

<cfoutput>
<script language="javascript" type="text/javascript">	
	
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
</script>
</cfoutput>
