
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "FSBO1 Listing">
<cfinclude template="../Lighthouse/Admin/Header.cfm">
<cfoutput><script language="JavaScript" src="#Request.HTTPSURL#/scripts/jquery-1.3.2.min.js" type="text/javascript"></script></cfoutput>

<cfparam name="Action" default="Edit">

<cfinclude template="includes/CheckListing.cfm">

<cfparam name="ListingTable" default="Listings">

<cfif ListFind("Edit",Action)>
	<cfset ListingTable="ListingsView">
</cfif>

<cfset ListingDocsDir = "">
<cfif Request.environment is "DB">
	<cfset ListingDocsDir = ListingDocsDir & "DAR\Web\">
</cfif>
<cfset ListingDocsDir = ListingDocsDir & "ListingUploadedDocs">

<lh:MS_Table table="#ListingTable#" title="#pg_title#"
	DisallowedActions="Add,Delete,View,Search" >
	
	<lh:MS_TableColumn
		ColName="ListingID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Identity="true" />
			
	<lh:MS_TableColumn
		ColName="UserID2"
		DispName="Business Account"
		type="pseudo"
		Expression="'<a href=""Accounts.cfm?Action=Edit&PK=' + Cast(UserID as varchar(20)) +'"">' + Cast(UserID as varchar(20)) + '</a>'"
		Editable="No"
		ShowOnEdit="true" />
		
	<lh:MS_TableColumn
		ColName="PriceUS"
		DispName="Minimum Price US"
		type="integer" 
		MaxLength="200"
		FORMAT="_$_,___.__"  />
		
	<lh:MS_TableColumn
		ColName="PriceTZS"
		DispName="Minumum Price TZS"
		type="integer" 
		MaxLength="200"
		FORMAT="_$_,___.__"  />
		
	<lh:MS_TableColumn
		ColName="Deadline"
		DispName="Expiration Date"
		ShowDate="Yes" 
		type="Date"
		Required="Yes"
		Format="DD/MM/YYYY" />
		
	<lh:MS_TableColumn
		ColName="Title"
		DispName="Descriptive Title"
		type="text" 
		MaxLength="200"
		Required="Yes" />
		
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
		Required="No" />	
		
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
		ColName="ListingLink"
		DispName="Listing Edit Link"
		type="pseudo"
		Expression="'#Request.HTTPURL#/postalisting?Step=2&LinkID=' + Cast(LinkID as varchar(100))" 
		Search="false"
		ShowOnEdit="true" />
		 
	<lh:MS_TableColumn
		ColName="ListingFriendlyURL"
		DispName="Listing URL"
		type="pseudo"
		Expression="'#Request.HTTPURL#/ListingDetail?ListingID=' + Cast(ListingID as varchar(10))" 
		Search="false"
		ShowOnEdit="true" />

	<lh:MS_TableColumn
		ColName="LogoImage"
		DispName="Logo Image"
		type="File"
		Directory="#ListingDocsDir#"
		NameConflict="makeunique"
		DeleteWithRecord="Yes"
		ShowFileBrowser="Yes"
		Search="false" />

	<lh:MS_TableColumn
		ColName="ELPTypeThumbnailImage"
		DispName="Feature Image"
		type="File"
		Directory="#ListingDocsDir#"
		NameConflict="makeunique"
		DeleteWithRecord="Yes"
		ShowFileBrowser="Yes"
		Search="false" />
	
	<lh:MS_TableColumn
		ColName="ELPTypeID"
		DispName="ELP DocumentType"
		type="select"
		FKOrderBy="OrderNum"
		FKTable="ELPTypes"
		FKDescr="Descr" />	
		
	<lh:MS_TableColumn
		ColName="ELPTypeOther"
		DispName="ELP Type (Other)"
		type="text" 
		MaxLength="200" />
		
	<lh:MS_TableColumn
		ColName="PublicPhone"
		DispName="Public Phone"
		type="text" 
		MaxLength="20" />
		
	<lh:MS_TableColumn
		ColName="PublicEmail"
		DispName="Public Email"
		type="text" 
		MaxLength="200" />		
		
	<lh:MS_TableColumn
		ColName="ContactEmail"
		DispName="Contact Email"
		type="text" 
		MaxLength="200" />	
		
	<lh:MS_TableColumn
		ColName="AltContactEmail"
		DispName="Alt Contact Email"
		type="text" 
		MaxLength="200" />	
	
	<lh:MS_TableColumn
		ColName="ShortDescr"
		DispName="Short Promo Copy"
		type="textarea"
		allowHTML="No"
		SpellCheck="Yes"
		MaxLength="2000"
		View="No" />	
			
	<lh:MS_TableColumn
		ColName="ExpandedListing"
		DispName="Expanded Listing"
		type="pseudo"
		Expression="'<div id=ExpandedListingDiv></div>'"
		Editable="No"
		ShowOnEdit="true" />
		
	<lh:MS_TableColumn
		ColName="DateListed"
		DispName="Date Listed"
		ShowDate="Yes" 
		type="Date"
		Required="Yes"
		Format="DD/MM/YYYY" />
		
	<cfif Action neq "Add">
		<lh:MS_TableColumn
			ColName="DateSort"
			DispName="Sort Date"
			ShowDate="Yes" 
			type="Date"
			Required="#DateSortExists#"
			Editable="#DateSortExists#"
			Format="DD/MM/YYYY"  />
		<lh:MS_TableColumn
			ColName="ExpirationDate"
			DispName="Expiration Date"
			ShowDate="Yes" 
			type="Date"
			Required="#ExpDateExists#"
			Editable="#ExpDateExists#"
			Format="DD/MM/YYYY"  />
			
		<lh:MS_TableColumn
			ColName="ExpirationDateELP"
			DispName="ELP Expiration Date"
			ShowDate="Yes" 
			type="Date"
			Required="#ELPExpDateExists#"
			Editable="#ELPExpDateExists#"
			Format="DD/MM/YYYY"  />
	</cfif>
		
	<lh:MS_TableColumn 
		colname="Active" 
		DispName="Listing Active"
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="1" />
		
	<lh:MS_TableColumn
		ColName="Preview"
		DispName="Preview Listing"
		type="pseudo"
		showOnEdit="true"
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
		colname="FeaturedTravelListing" 
		DispName="Featured Travel Listing"
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="0" />
		
	<cfif ListFind("Edit",Action)>
		<lh:MS_TableColumn
			ColName="RelatedOrderID"
			DispName="Related Orders"
			type="select-multiple"
			FKTable="RelatedOrdersView"
			FKColName="RelatedOrderID"
			FKDescr="Distinct '<br>' + OrderLink"
			FKJoinTable="ListingRelatedOrdersView"
			Editable="no" />
	</cfif>	
	
	<lh:MS_TableColumn
		ColName="ListingPackageListings"
		DispName="Listing Package"
		type="pseudo"
		Search="no"
		Expression="'<a href=""Listings.cfm?Action=View&Searching=1&ListingPackageID=' + Cast(ListingsView.ListingPackageID as varchar(20)) +'"">' + Cast(ListingsView.ListingPackageID as varchar(20)) + '</a>'"
		ShowOnEdit="true" />
		
	<lh:MS_TableColumn 
		colname="DeletedAfterSubmitted" 
		DispName="Marked As Deleted"
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="0" />
		
	<lh:MS_TableColumn
		ColName="DeletedAfterSubmittedDate"
		DispName="Date Marked As Deleted"
		ShowDate="Yes" 
		type="Date"
		Required="No"
		Editable="No"
		Format="DD/MM/YYYY"  />
		
	<lh:MS_TableColumn
		ColName="Impressions"
		DispName="Number of Viewings"
		type="pseudo" 
		expression="(Select Count(ImpressionID) from Impressions Where ListingID=ListingsView.ListingID and ExpandedListingImpression=0 and ExternalURLImpression=0)"		
		ShowOnEdit="true" />
		
	<lh:MS_TableRowAction
		Type="Custom"
		ActionName="CustomOne"
		Label="Send Listing Email"
		HREF="javascript:void(0);"
		onClick="sendListingEmail(##PK##);"
		View="No"/>
	
	<lh:MS_TableRowAction
		Type="Custom"
		ActionName="CustomServiceOrder"
		Label="Add Service Order"
		HREF="ServiceOrder.cfm?ListingID=#PK#"
		View="No"/>
	
	<lh:MS_TableRowAction
		Type="Custom"
		ActionName="CustomThree"
		Label="Blacklist Account"
		HREF="javascript:void(0);"
		onClick="blacklistListingsAccount(this,##PK##);" />
	
	<lh:MS_TableRowAction
		Type="Custom"
		ActionName="CustomFour"
		Label="Un-Blacklist Account"
		HREF="javascript:void(0);"
		onClick="unblacklistListingsAccount(this,##PK##);" />

	<lh:MS_TableEvent
		EventName="OnBeforeUpdate"
		Include="../../admin/Listing_onBeforeUpdate.cfm" />

	<lh:MS_TableEvent
		EventName="OnAfterUpdate"
		Include="../../admin/Listings_onAfterUpdate.cfm" />
		
</lh:MS_Table>

<cfif ListFind("Add,Edit",Action)>
	<script>
		document.f1.ParentSectionID.removeAttribute('multiple');
		document.f1.ParentSectionID.size='1';
		document.f1.SectionID.size='1';
		document.f1.CategoryID.size='1';
	</script>
	<cfset IncludeCats="1">
	<cfinclude template="includes/GetSubSectionsScript.cfm">	
</cfif>

<cfif ListFind("Search",Action)>	
	<cfset IncludeCats="1">
	<cfinclude template="includes/GetSubSectionsScript.cfm">	
</cfif>

<cfif Action is "Edit">
	<cfquery name="getELPOtherTypeID"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select ElpTypeID
		From ELPTypes
		Where Other_fl=1
	</cfquery>
	<cfquery name="q2" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.DateListed,
		(Select Top 1 UpdateDate From Updates Where ListingID=L.ListingID Order by UpdateDate Desc) as UpdateDate,
		(Select Top 1 IsNull(Us.FirstName,'') + ' ' + IsNull(Us.LastName,'') From Updates Up Left Outer Join LH_Users Us on Up.UpdatedByID=Us.UserID Where ListingID=L.ListingID Order by UpdateDate Desc) as UpdatedBy, ELPTypeID
		From Listings L
		Where L.ListingID=<cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfquery name="UpdateHistory" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select U.UpdateDate, U.Descr,
		IsNull(Us.FirstName,'') + ' ' + IsNull(Us.LastName,'') as UpdatedBy
		From Updates U 
		Left Outer Join LH_Users Us on U.UpdatedByID=Us.UserID
		Where U.ListingID=<cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">
		Order By U.UpdateDate Desc
	</cfquery>
	<p>
	<cfoutput>Date Added: #DateFormat(q2.DateListed,'dd/mm/yyyy')# | Last Updated: #DateFormat(q2.UpdateDate,'dd/mm/yyyy')# | Updated By: #q2.UpdatedBy#</cfoutput>
	<cfif UpdateHistory.RecordCount>
		<p><strong>Listing Update History</strong><br>
		<cfoutput query="UpdateHistory">
			#DateFormat(UpdateDate,'dd/mm/yyyy')#: by #UpdatedBy#: <br>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#Replace(Descr,"|","<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;","ALL")#<br>
		</cfoutput>		
	</cfif>
</cfif>

<cfoutput>

<script type="text/javascript" src="#Request.HTTPSURL#/js/thickbox.js"></script>
<script language="javascript" type="text/javascript">
	$(document).ready(function()
	{		    
		getExpandedListing();
		<cfif Action is "Edit">
			<cfif q2.ELPTypeID neq getELPOtherTypeID.ELPTypeID>
				$("##ELPTypeOther_TR").hide();
			</cfif>
			$("##ELPTypeID").change(function(e)
		    {	
				if ($("##ELPTypeID").val()==#getELPOtherTypeID.ELPTypeID#) {
					$("##ELPTypeOther_TR").show();
				}	
				else {
					$("##ELPTypeOther_TR").hide();
				}				       
		    });
		</cfif>	   
	});
	
	function getExpandedListing(){
		var datastring = "ListingID=#pk#";
		$.ajax(
           {
			type:"POST",
               url:"#Request.HTTPSURL#/Admin/includes/ExpandedListing.cfc?method=Get&returnformat=plain",
               data:datastring,
               success: function(response)
               {
				var resp = jQuery.trim(response);
				$("##ExpandedListingDiv").html(resp);
               }
           });
	}
	
	
	function deleteExpandedListing() {
		var datastring = "ListingID=#PK#";
		$.ajax(
           {
			type:"POST",
               url:"#Request.HTTPSURL#/Admin/includes/ExpandedListing.cfc?method=DelExL&returnformat=plain",
               data:datastring,
               success: function(response)
               {				
				getExpandedListing();	
               }
           });
	}
	
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
		<cfif not Len(getExpirationDate.UserID)>
			$("td.ACTIONCELL:last").hide();
			$("td.ACTIONCELL:last").prev().hide();
		<cfelseif getExpirationDate.Blacklist_fl>
			$("td.ACTIONCELL:last").prev().hide();
		<cfelse>
			$("td.ACTIONCELL:last").hide();
		</cfif>
		<cfset ListingEditTemplate = "1">
		<cfinclude template="includes/BlacklistingJS.cfm">
</script>
</cfoutput>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">