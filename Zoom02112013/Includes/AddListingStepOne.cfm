<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<!--- LisitngSectionID is used instead of SectionID to not conflict with the get pages SectionID. --->

<cfset allFields="ParentSectionID,ListingSectionID,CategoryID,ListingTypeID,ListingID,LinkID,TT">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="ParentSectionID,ListingSectionID,CategoryID,ListingTypeID,ListingID,TT">

<cfif IsDefined('session.UserID') and Len(session.UserID)>
<!--- See if Trip Listings allowed --->
	<cfinclude template="MyListings.cfm">
<cfelse>
	<cfset AllowTravel="0">
	<cfset AllowJAndEProfEmplOpp="0">	
</cfif>


<cfif not AllowTravel>
	<lh:MS_SitePagePart id="bodyTravel" class="body bodyTravel" style="display:none;">	
</cfif>
<cfquery name="ParentSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select PS.ParentSectionID as SelectValue, PS.Title as SelectText
	From ParentSectionsView PS
	Where PS.Active=1
	Order by PS.OrderNum
</cfquery>

<cfif Len(LinkID)>
	<cfquery name="getListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ListingID, L.ListingTypeID, L.InProgress, LPS.ParentSectionID, LS.SectionID as SectionID, LC.CategoryID
		From Listings L Inner Join ListingParentSections LPS on L.ListingID=LPS.ListingID
		Inner Join ListingCategories LC on L.ListingID=LC.ListingID
		Left Outer Join ListingSections LS on L.ListingID=LS.ListingID
		Where L.LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfif getListing.RecordCount>
		<cfquery name="getListingCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select LC.CategoryID
			From ListingCategories LC
			Where LC.ListingID=<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<cfif not getListing.InProgress>
			<cflocation url="#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=2&LinkID=#LinkID#" addToken="no">
			<cfabort>
		</cfif>
		<cfset ParentSectionID=getListing.ParentSectionID>
		<cfset ListingSectionID=getListing.SectionID>
		<cfset CategoryID=ValueList(getListingCategories.CategoryID)>
		<cfset ListingTypeID=getListing.ListingTypeID>
	<cfelse><!--- No record found so stop passing LinkID --->
		<cfset LinkID="">
		<div id="internalalert">Listing not found</div><br clear="all"></div>
		<cfinclude template="../templates/footer.cfm"></div></div></body></html>
		<cfabort>
	</cfif>
</cfif>

<script>
	function validateForm(formObj) {		
		if (!checkSelected(formObj.elements["ParentSectionID"],"Section")) return false;	
		if (!checkSelected(formObj.elements["CategoryID"],"Category")) return false;						
		if (formObj.elements["CheckListingType"].value==1) {
			if (!checkSelected(formObj.elements["ListingTypeID"],"Listing Type")) return false;
			<!--- <cfif not AllowJAndEProfEmplOpp>
				if (formObj.elements["ListingTypeID"].value=='10') {
					alert('You must have a business account and listing to post professional job opportunities.');
					return false;
				}
			</cfif> --->
		}
		<cfif not AllowTravel>
			if (formObj.elements["ListingTypeID"].value=='9') {
				alert($(".bodyTravel").text());
				return false;
			}
		</cfif>
		return true;
	}
</script>

<cfoutput>
<form name="f1" action="page.cfm?PageID=#Request.AddAListingPageID#" method="post" ONSUBMIT="return validateForm(this)">
	<table border="0" cellspacing="0" cellpadding="0" class="datatable">
		<cfif IsDefined('session.UserID') and session.UserID is request.PhoneOnlyUserID>		
			<tr>
				<td colspan="2">
					<p class="Important">Phone Only Listings Account in use.</p>
				</td>
			</tr>
		</cfif>
		<tr>
			<td colspan="2">
				<strong>Please identify in what section you would like your listing to appear.</strong>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<div ID="SelectionsFormDiv"></div>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>
				<div id="NextButtonDiv" style="display:none;"><input type="submit" name="Next" value="Next >>"></div>
				<input type="hidden" name="LinkID" value="#LinkID#">
				<input type="hidden" name="UpdateSAndC" value="1">
				<input type="hidden" name="Step" value="2">
			</td>
		</tr>
	</table>
	
	
	<div ID="AllowJAndEProfEmplOppDiv" style="display:none;"></div>
</form>
<script>
	<cfif Len(ParentSectionID)>
		var parentSectionID=#ParentSectionID#;
	<cfelse>
		var parentSectionID=0;
	</cfif>
	<cfif Len(ListingSectionID)>
		var sectionID=#ListingSectionID#;
	<cfelse>
		var sectionID=0;
	</cfif>
	<cfif Len(CategoryID)>
		var categoryID='#CategoryID#';
	<cfelse>
		var categoryID=0;
	</cfif>
	<cfif Len(ListingTypeID)>
		var listingTypeID=#ListingTypeID#;
	<cfelse>
		var listingTypeID=0;
	</cfif>
	$(document).ready(function()
	{		    
		getSelections();			
	});
	
	function getSelections() {
		if (sectionID=='') {sectionID=0;}
		var datastring = "ParentSectionID=" + parentSectionID + "&SectionID=" + sectionID + "&CategoryID=" + categoryID + "&ListingTypeID=" + listingTypeID; 
           
		$.ajax(
           {
			type:"POST",
               url:"#Request.HTTPURL#/includes/GetListingStepOneFormSelections.cfc?method=get&returnformat=plain",
               data:datastring,
               success: function(response)
               {
				var resp = jQuery.trim(response);
				$("##SelectionsFormDiv").html(resp);				
               }
           });
	}
</script>



<script language="javascript" type="text/javascript">
	
	$(function() {
		<cfif IsDefined('url.ListingSectionID') and url.ListingSectionID is "37">
			$(".bodyTravel").show();
		</cfif>			
	});
	
	function checkAllowTravel() {
		<cfif not AllowTravel>
		if (sectionID==37) {
			$(".bodyTravel").show('slow');
		}
		else {
			$(".bodyTravel").hide('slow');
		}
		</cfif>
	}
</script>

</cfoutput>
