<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfset allFields="LinkID">
<cfinclude template="setVariables.cfm">

<cfset ListingID="">

<cfinclude template="FindListing.cfm">

<cfif Len(getListing.ContactEmail)>
	<cfoutput>#getListing.ContactEmail#</cfoutput>
	<cfinclude template="SendListingLink.cfm">
</cfif>
