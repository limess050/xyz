<cfparam name="ExpDateExists" default="No">
<cfparam name="ELPExpDateExists" default="No">
<cfparam name="DateLiveExists" default="No">
<cfparam name="DateSortExists" default="No">

<cfif not IsDefined('PK')>
	<p class="STATUSMESSAGE">No Listing ID was passed.</p>
	<cfinclude template="../../Lighthouse/Admin/Footer.cfm">
	<cfabort>
<cfelse>
	<!--- Get ExpirationDate. It is exists, it must continue to be required. --->
	<cfquery name="GetExpirationDate" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select ExpirationDate, ExpirationDateELP, DateLive, DateSort, IsNull(Blacklist_fl,0) as Blacklist_fl, UserID
		From ListingsView
		Where ListingID=<cfqueryparam value="#PK#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif Len(getExpirationDate.ExpirationDate)>
		<cfset ExpDateExists="Yes">
	</cfif>
	<cfif Len(getExpirationDate.ExpirationDateELP)>
		<cfset ELPExpDateExists="Yes">
	</cfif>
	<cfif Len(getExpirationDate.DateLive)>
		<cfset DateLiveExists="Yes">
	</cfif>
	<cfif Len(getExpirationDate.DateSort)>
		<cfset DateSortExists="Yes">
	</cfif>
</cfif>