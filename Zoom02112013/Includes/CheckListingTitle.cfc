
<cfsetting showdebugoutput="no">

<cffunction name="CheckTitle" access="remote" returntype="string" displayname="Checks for uniqueness of listing title among business listings">
	<cfargument name="ListingTitle" required="yes">
	<cfargument name="LinkID" required="no">
	<cfargument name="PK" required="no">
	
	<cfif IsDefined('arguments.LinkID')>
		<cfset LinkID=arguments.LinkID>
	<cfelse>
		<cfset LinkID="">
	</cfif>
	
	<cfif IsDefined('arguments.PK')>
		<cfset PK=arguments.PK>
	<cfelse>
		<cfset PK="">
	</cfif>
	
	
	
	
	<cfquery name="checkTitle"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select ListingID
		From Listings
		Where URLSafeTitle =  <cfqueryparam value="#REreplace(arguments.ListingTitle, "[^a-zA-Z0-9]","","all")#" cfsqltype="CF_SQL_VARCHAR">
		and DeletedAfterSubmitted=0 and Active=1<!--- Should old, possibly expired, listings exist with the same name, an Administrator could uncheck Active, or if it is the same account holder's old ad, they could use the Delete function in their My Account page to free up the name. --->
		and ListingTypeID in (1,2,14)
		<cfif Len(LinkID)>and LinkID <> <cfqueryparam value="#Trim(LinkID)#" cfsqltype="CF_SQL_VARCHAR"></cfif>
		<cfif Len(PK)>and ListingID <> <cfqueryparam value="#Trim(PK)#" cfsqltype="CF_SQL_VARCHAR"></cfif>
	</cfquery>

	<cfset rString = "">       
	
	<cfif checkTitle.RecordCount>	
		<cfif Len(PK)>
			<cfset rString="A business listing already exists with the name '#arguments.ListingTitle#'. The business name must be unique.">
		<cfelse>
			<cfset rString="A business listing already exists with the name<br />'<strong>#arguments.ListingTitle#</strong>'.<br />The business name must be unique.">	
		</cfif>
	</cfif> 	

 	<cfreturn rString>
</cffunction>

