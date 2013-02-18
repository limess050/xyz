
<cfsetting showdebugoutput="no">

<cffunction name="GetFee" access="remote" returntype="string" displayname="Returns Listing Fee based on passed values">
	<cfargument name="ListingTypeID" required="yes">
	<cfargument name="LinkID" required="no">
	<cfargument name="Price" required="no" default="0">
	<cfargument name="PriceType" required="no" default="US">
	<cfargument name="UserID" required="no">
	
	<cfparam name="HasOpenHAndRPackages" default="0">
	<cfparam name="HasOpenVPackages" default="0">
	<cfparam name="HasOpenJRPackages" default="0">
	
	<cfset ListingFee="">
	<cfset responseVars = StructNew() />  

	
	<cfif isDefined("arguments.userID") AND Len(arguments.userID)>
		
		<!--- See if user has appropriate listing package --->
		<cfif ListFind("4,5,6,7,8,10,12",arguments.ListingTypeID) and IsDefined('session.UserID') and Len(Session.UserID)>
			<cfinclude template="ListingPackagesHAndRQueries.cfm">
			<cfinclude template="ListingPackagesVQueries.cfm">
			<cfinclude template="ListingPackagesJRQueries.cfm">
		</cfif>
	</cfif>
	
	<cfset ResponseVars["HasOpenHAndRPackages"]= "#HasOpenHAndRPackages#" /> 
	<cfset ResponseVars["HasOpenVPackages"]= "#HasOpenVPackages#" /> 
	<cfset ResponseVars["HasOpenJRPackages"]= "#HasOpenJRPackages#" /> 

	
	<cfswitch expression="#arguments.listingtypeID#">
		<!--- FSBO and H&R Listing Types --->
		<cfcase value="3,4,5,6,7,8">
			<cfif Len(arguments.price)><!--- Initial load of listing form will not have price entered. --->				
				<cfquery name="getListingPricing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					Select BasicFee
					from listingTypes
					where listingTypeID = <cfqueryparam value="#arguments.listingTypeID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>	
				<cfquery name="getListingPricingRanges"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					select listingFee
					from ListingTypesPricing
					where listingTypeID = <cfqueryparam value="#arguments.listingTypeID#" cfsqltype="CF_SQL_INTEGER">
					<cfif arguments.PriceType EQ "US">
						AND USPriceStart <= <cfqueryparam value="#arguments.Price#" cfsqltype="CF_SQL_DECIMAL">
						AND USPriceEND >= <cfqueryparam value="#arguments.Price#" cfsqltype="CF_SQL_DECIMAL">
					</cfif>
					<cfif arguments.PriceType EQ "TZ">
						AND TZSPriceStart <= <cfqueryparam value="#arguments.Price#" cfsqltype="CF_SQL_DECIMAL">
						AND TZSPriceEND >= <cfqueryparam value="#arguments.Price#" cfsqltype="CF_SQL_DECIMAL">
					</cfif>
				</cfquery>
				<cfif not getListingPricingRanges.RecordCount><!--- If no record found, set to highest fee in Listing Type --->
					<cfquery name="getListingPricingRanges"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						Select Max(ListingFee) as ListingFee
						from ListingTypesPricing
						where listingTypeID = <cfqueryparam value="#arguments.listingTypeID#" cfsqltype="CF_SQL_INTEGER">
					</cfquery>				
				</cfif>
				<cfif getListingPricingRanges.recordcount>
					<cfset ListingFee = getListingPricingRanges.ListingFee>
				<cfelse>	
					<cfset ListingFee="0"><!--- If no price range records found at all, set to zero --->
				</cfif>
			</cfif>
		</cfcase>
		<cfdefaultcase>
			<cfquery name="getListingPricing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				select BasicFee, AdditionalBasicFee
				from listingTypes
				where listingTypeID = <cfqueryparam value="#arguments.listingTypeID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>	
			<cfset ListingFee = getListingPricing.BasicFee>
			<cfif not Len(ListingFee)>
				<cfset ListingFee="0"><!--- If null found for fee, set to zero --->
			</cfif>			
		</cfdefaultcase>
	
	</cfswitch>
	
	<cfset ResponseVars["ListingFee"]= "#ListingFee#" />
	
	<cfif ListingFee is "0">
		<cfset ResponseVars["ListingFee"]= "Free" /> 
	</cfif> 
		
	<cfset rString=serializeJSON(ResponseVars)>
	
 	<cfreturn rString>
</cffunction>

