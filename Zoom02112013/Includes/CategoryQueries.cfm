<!--- This template runs early in the lighthouse/page.cfm template, in order to set the header title with the category info. --->

<cfset allFields="CategoryID">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="CategoryID">

<cfif Len(CategoryID)>
	<cfquery name="getCategoryInfo" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select Title, BrowserTitle, MetaDescr
		From Categories With (NoLock)
		Where CategoryID=<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif Len(getCategoryInfo.BrowserTitle)>
		<cfset CategoryHeaderTitle=getCategoryInfo.BrowserTitle>
	<cfelseif Len(getCategoryInfo.Title)>
		<cfset CategoryHeaderTitle=getCategoryInfo.Title>
	</cfif>
	<cfif Len(getCategoryInfo.MetaDescr)>
		<cfset CategoryMetaDescr=getCategoryInfo.MetaDescr>
	</cfif>
</cfif>