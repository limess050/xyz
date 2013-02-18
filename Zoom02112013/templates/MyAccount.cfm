
<cfset allFields="StatusMessage">
<cfinclude template="../includes/setVariables.cfm">

<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfquery name="getImpressionSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SectionID
	From PageSections
	Where PageID = <cfqueryparam value="#PageID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfset ImpressionSectionID=getImpressionSection.SectionID>
<cfif not Len(ImpressionSectionID)>
	<cfset ImpressionSectionID = 0>
</cfif>

<cfif not IsDefined('application.SectionImpressions')>
	<cfset application.SectionImpressions= structNew()>
</cfif>
<cfif StructKeyExists(application.SectionImpressions,ImpressionSectionID)>
	<cfset application.SectionImpressions[ImpressionSectionID] = application.SectionImpressions[ImpressionSectionID] + 1>
<cfelse>
	<cfset application.SectionImpressions[ImpressionSectionID] = 1>
</cfif>

<cfinclude template="header.cfm">
<cfoutput>
	<script type="text/javascript" src="#Request.HTTPSURL#/Lighthouse/Resources/js/lighthouse_all.js"></script>
	<script type="text/javascript" src="#Request.HTTPSURL#/js/jquery-1.3.2.min.js"></script>

  	<script type="text/javascript" src="#Request.HTTPSURL#/js/ui.core.js"></script>
	<script type="text/javascript" src="#Request.HTTPSURL#/js/ui.accordionCustom.js"></script>
	<script type="text/javascript" src="#Request.HTTPSURL#/js/coda.js"> </script>
	<script type="text/javascript" src="#Request.HTTPSURL#/js/thickbox.js"></script>
	<script type="text/javascript" src="#Request.HTTPSURL#/js/jquery-ui-1.7.2.custom.min.js"></script>
 </cfoutput>

<cfinclude template="../includes/MyCartListings.cfm">

<cfinclude template="../includes/MyCartBannerAds.cfm">

<cfinclude template="../includes/MyListings.cfm">

<cfinclude template="../includes/MyBannerAds.cfm">

<cfinclude template="../includes/MyUsername.cfm">

<script>
	function validateForm(formObj) {				
		if (!checkChecked(formObj.ListingID,"Listings to Renew")) {
			return false;
		}
		return true;
	}
</script>

<div class="centercol-inner-wide legacy legacy-wide">
<h1>My Account</h1>
<cfoutput>
Welcome, #getMyUsername.ContactFirstName# #getMyUsername.ContactLastName# (#getMyUsername.Username#)<br />
<a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/?Logout=Y">Log Out</a>
<cfif Len(StatusMessage)>
	<p><strong><em>#StatusMessage#</em></strong>
</cfif>		 
<lh:MS_SitePagePart id="body" class="body">

    <input type="button" name="postalisting" id="postalisting" value="Post a Listing" class="btn"  onClick="location.href='#lh_getPageLink(5,'postalisting')#'" />
	<cfif not ListFind("Live,LT",request.environment)><!---<input type="button" name="postabannerad" id="postabannerad" value="Post a Banner Ad" class="btn"  onClick="location.href='#lh_getPageLink(21,'postabannerad')#'" />---></cfif>
	<input name="postanevent" type="button" value="Post an Event" class="btn" id="postanevent" onClick="location.href='#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=59'" />
	<input name="postanevent" type="button" value="Post an Employment Opportunity" class="btn" id="postanemploymentopportunity" onClick="location.href='#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=8&ListingSectionID=19&ListingTypeID=10'" />
<cfif AllowVehicle><input name="postacarortruck" type="button" value="Post a Car or Truck Listing" class="btn" id="postacarortruck" onClick="location.href='#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=55&ListingSectionID=57&CategoryID=84'" /></cfif>
<cfif AllowHAndR><input name="postapropertyforrent" type="button" value="Post a Property for Rent or Sale" class="btn" id="postapropertyforrent" onClick="location.href='#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=5'" />  </cfif> 
<cfif AllowTravel><input name="postatravelspecial" type="button" value="Post a Travel Special/Deal" class="btn" id="postatravelspecial" onClick="location.href='#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=21&ListingSectionID=37&CategoryID=94'" /> </cfif>  

 <br />

<hr class="red" /> <h1> My Cart</h1>
	<cfif ListingsInCart OR BannerAdsInCart>
	  	<p>You have #ListingsInCart+BannerAdsInCart# item<cfif ListingsInCart  gt 1>s</cfif> in your cart with a total of #DollarFormat(FeesInCart+BannerFeesInCart)#. <a href="#lh_getPageLink(14,'mycart')#">View Cart</a></p>
	<cfelse>
		<p>Your cart is empty.</p>
	</cfif>&nbsp;
		
<hr class="red" /> <br />	
<cfif AllowHAndR>
	<cfinclude template="../includes/ListingPackagesHAndR.cfm">	
</cfif>

<cfif AllowVehicle>
	<cfinclude template="../includes/ListingPackagesV.cfm">	
</cfif>

<cfif AllowJobRecruiter>
	<cfinclude template="../includes/ListingPackagesJR.cfm">	
</cfif>
	
	
	
<form name="f1" action="page.cfm?PageID=#Request.RenwalCartPageID#" method="post" onSubmit="return validateForm(this);">

<h1> My Listings</h1>
	<div ID="MyListingsDiv"></div>
  	<br />

    <div class="btn-right" ID="CheckoutButton" style="display:none"><input type="submit" name="Renew" id="Renew" value="Renew Now" class="btn" /></div>


</form>
<hr class="red" /> <br />	

<h1>My Banner Ads</h1>
<cfif getMyBannerAds.recordCount>
	<table width="705" border="0" cellspacing="0" cellpadding="0" class="listingstable">
    	<tr class="listingstable-toprow">
      	<td>Banner Ads</td>
      	<td class="centered">Position</td>
      	<td class="centered">Site Location</td>
      	<td class="centered">Dates</td>
      	<td class="centered">Payment</td>
		</tr>
		<cfloop query="getMyBannerAds">
			<cfquery name="getBannerAd" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Select B.*,BPS.ParentSectionID,
				B.ImpressionsExpanded + B.ImpressionsExternal as ClickThroughs
				From BannerAds B Left Join BannerAdParentSections BPS on B.BannerAdID=BPS.BannerAdID
				Where B.BannerAdID=<cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<cfquery dbType="query" name="getParentSectionIDs">
				select distinct(ParentSectionID)
				from getBannerAd
			</cfquery>
			<cfset ParentSectionIDs = ValueList(getParentSectionIDs.ParentsectionID)>
			
			<cfquery name="getOrders" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				select * from RelatedBannerAdOrdersView
				where BannerAdID2 = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>			
			
			<cfif Len(ParentSectionIDs)>
				<cfquery name="getSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum, BSW.Weight
					FROM  PageSectionsView PS
					Left Join BannerAdSectionWeights BSW on PS.ParentSectionID=BSW.ParentSectionID and BSW.BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
					WHERE PS.ParentSectionID IN (<cfqueryparam value="#ParentSectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)					
				</cfquery>
			<cfelse>
				<cfquery name="getSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT Top 1 PS.ParentSectionID, '<em>No Site Locations selected</em>' as PSTitle, PS.OrderNum as PSOrderNum, '' as Weight
					FROM  PageSectionsView PS
					Order By ParentSectionID
				</cfquery>
			</cfif>
			<cfloop query="getSections">
				
				<tr>
				<cfif currentRow EQ 1>
					<td rowspan="#getSections.recordcount#" valign="top">
					<img src="#request.httpurl#/uploads/bannerAds/#getBannerAd.BannerAdImage#" width="200">
					</td>
					<td rowspan="#getSections.recordcount#" valign="top">Position #getBannerAd.positionID#</td>
				</cfif>
				<td valign="top">#PSTitle#&nbsp;<cfif Len(Weight)>=&nbsp;#NumberFormat(Weight,'_.__')#%<cfelse>(%&nbsp;Pending)</cfif><br>
							
				</td>
				<cfif currentRow EQ 1>
					<td rowspan="#getSections.recordcount#" valign="top">
						<cfif Len(getBannerAd.impressions)>#getBannerAd.impressions# Impressions<br><br></cfif>
						<cfif Len(getBannerAd.ClickThroughs)>#getBannerAd.ClickThroughs# Click Throughs<br><br></cfif>
						#DateFormat(getBannerAd.startDate,"dd/mm/yyyy")# - #DateFormat(getBannerAd.endDate,"dd/mm/yyyy")#
					</td>
					<td rowspan="#getSections.recordcount#" valign="top"><cfloop query="getOrders">#myAccountInfo#<br></cfloop></td>
				</cfif>
				</tr>
			</cfloop>			
		</cfloop>
	</table>	

<cfelse>
	No Banner Ads Found
</cfif>

<hr class="red" /> <h1> My Alerts</h1>
<cfinclude template="../includes/MyAlerts.cfm">

</cfoutput>
  <!-- END CENTER COL -->

<!-- RIGHT COL -->


</div>

<!-- END CENTER COL -->
<cfoutput>
<script>
	$(document).ready(function()
	{		    
		getMyListings();
	});
	
	
	function getMyListings() {
		var datastring = "UserID=#session.UserID#";
           
		$.ajax(
           {
			type:"POST",
               url:"#Request.HTTPURL#/includes/MyListings.cfc?method=Get&returnformat=plain",
               data:datastring,
               success: function(response)
               {
					var resp = jQuery.trim(response);
	                $("##MyListingsDiv").html(resp);
					tb_init('a.thickbox');
					if ($(".ListingID").length!=0) {
						$("##CheckoutButton").show();
					}							
               }
           });
	}
	
	function deleteListing(x){
		if (confirm('Are you sure you want to delete this listing?')) {
			var datastring = "LinkID=" + x;
	           
			$.ajax(
	           {
				type:"POST",
	               url:"#Request.HTTPURL#/includes/MyListings.cfc?method=Delete&returnformat=plain",
	               data:datastring,
	               success: function(response)
	               {
						getMyListings();					
	               }
	           });
		}
	}
	
	function deleteExpandedListing(x) {
		if (confirm('Are you sure you want to delete this featured listing?')) {
			var datastring = "LinkID=" + x;
			$.ajax(
	           {
				type:"POST",
	               url:"#Request.HTTPSURL#/includes/ExpandedListing.cfc?method=DelExL&returnformat=plain",
	               data:datastring,
	               success: function(response)
	               {				
						getMyListings();
	               }
	           });
		}
	}
</script>
</cfoutput>

<cfset ShowRightColumn="0">
<cfinclude template="footer.cfm">
