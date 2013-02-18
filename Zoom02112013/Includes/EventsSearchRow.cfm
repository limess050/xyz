<cfquery name="EventLocations" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select LocationID as SelectValue, Title as SelectText
	From Locations
	Where Active=1
	and LocationID <> 4
	Order By OrderNum
</cfquery>


<cfquery name="EventCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select C.SectionID, 
	C.CategoryID, C.Title as Category, C.OrderNum as CategoryOrderNum,
	(Select Count(L.ListingID) 
		From ListingsView L Inner Join ListingCategories LC on L.ListingID=LC.ListingID
		Where LC.CategoryID=C.CategoryID
		<cfinclude template="../includes/LiveListingFilter.cfm"> )
		as ListingCount
	From Categories C 
	Where  C.ParentSectionID=59
	and C.Active=1
	Order By CategoryOrderNum
</cfquery>

<cfparam name="SearchKeyword" default="">
<cfparam name="EventStartDate" default="">
<cfparam name="EventEndDate" default="">
<cfparam name="EventCategoryID" default="">
<cfparam name="LocationID" default="">
<cfparam name="OnEventLanding" default="0">

<div class="eventsearchtools">
	<cfoutput>
	<form action="#lh_getPageLink(Request.SearchEventsPageID,'searchEvents')#" method="get" ONSUBMIT="return validateForm(this)">
		<div class="notice"><cfif OnEventLanding><strong>Search</strong><em> by date range, location, event type or any combination of these.</em><cfelse>Filter listings by any combination of the fields below.</cfif></div><div class="<cfif OnEventLanding>clear15<cfelse>clear5</cfif>"></div>
		<div class="filterField<cfif OnEventLanding> filterFieldTall</cfif>">&nbsp;&nbsp;
			<input class="dining-locationsearch" name="EventStartDate" type="text" id="EventStartDate" size="10" maxlength="20" value="#EventStartDate#" />&nbsp;-&nbsp;<input class="dining-locationsearch" name="EventEndDate" type="text" id="EventEndDate" size="10" maxlength="20" value="#EventEndDate#" />
		</div>
		</cfoutput>
		<div class="filterField<cfif OnEventLanding> filterFieldTall</cfif>">&nbsp;&nbsp;
			<select class="dining-locationsearch" name="LocationID" ID="LocationID">
			  <option value="">-- Select an Area --</option>
			  <cfoutput query="EventLocations">
			  	<option value="#SelectValue#" <cfif SelectValue is LocationID>selected</cfif>> #SelectText#
			  </cfoutput>
			</select>
		</div>
		<div class="filterField<cfif OnEventLanding> filterFieldTall</cfif>">&nbsp;&nbsp;
		<select class="dining-locationsearch" name="EventCategoryID" ID="EventCategoryID">
		  <option value="">-- Select a Type of Event --</option>
		  <cfoutput query="EventCategories">
		  	<option value="#CategoryID#" <cfif CategoryID is EventCategoryID>selected</cfif>> #Category# (#ListingCount#)
		  </cfoutput>
		</select></div>
		<div class="filterField<cfif OnEventLanding> filterFieldTall</cfif>">&nbsp;&nbsp;
		    <label>
				<cfif OnEventLanding>
		     		<input name="go" id="btn-searchevents" type="image" value="Go" src="images/inner/btn.searchevents_off.gif" alt="Search" align="absmiddle" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-searchevents','','images/inner/btn.searchevents_on.gif',1)"  />
				<cfelse>
		     		<input name="go" id="btn-searchevents" type="image" value="Go" src="images/inner/btn.go_off.gif" alt="Go" align="absmiddle" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-searchevents','','images/inner/btn.go_on.gif',1)"  />
				</cfif>
		    </label>
		</div>
	</form>
</div>

<script>
	$(function() {
		$("#EventStartDate").datepicker({showOn: 'button', buttonImage: 'images/sitewide/date_16.png', buttonImageOnly: true, dateFormat: 'dd/mm/yy', changeMonth: true, changeYear: true
});
		$("#EventEndDate").datepicker({showOn: 'button', buttonImage: 'images/sitewide/date_16.png', buttonImageOnly: true, dateFormat: 'dd/mm/yy', changeMonth: true, changeYear: true
});
	});
	
	function validateForm(formObj) {		
		if (!checkDateDDMMYYYY(formObj.elements["EventStartDate"],"Search Start Date")) return false;		
		if (!checkDateDDMMYYYY(formObj.elements["EventEndDate"],"Search End Date")) return false;	
		return true;
	}
</script>