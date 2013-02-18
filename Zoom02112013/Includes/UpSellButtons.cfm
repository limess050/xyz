<!--- Upsell Buttons determined by ListingTypeID --->
<cfquery name="getListingType" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select ListingTypeID
	From Listings
	Where LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<cfoutput>

<cfsavecontent variable="PostAListing">
	<input type="button" name="postalisting" id="postalisting" value="Post a Listing" class="btn" onClick="location.href='#lh_getPageLink(5,'postalisting')#'" />
</cfsavecontent>

<cfsavecontent variable="PostAnEvent">
	<input name="postanevent" type="button" value="Post an Event" class="btn" id="postanevent" onClick="location.href='#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=46'"/>
</cfsavecontent>

<cfsavecontent variable="PostAnEmployentOpportunity">
	<input name="postanevent" type="button" value="Post an Employment Opportunity" class="btn" id="postanemploymentopportunity" onClick="location.href='#lh_getPageLink(5,'postalisting')##AmpOrQuestion#ParentSectionID=8&ListingSectionID=19&ListingTypeID=10'" />
</cfsavecontent>

<cfswitch expression="#getListingType.ListingTypeID#">
	<cfcase value="1,2,14">
		#PostAListing#
		#PostAnEvent#
		#PostAnEmployentOpportunity#		
	</cfcase>
</cfswitch>
	
</cfoutput>
