<!--- This template runs early in the lighthouse/page.cfm template, in order to set the header title with the Section info. --->

<cfset allFields="ParentSectionID">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="ParentSectionID">
<cfif edit>
	<cfset ParentSectionID=2>
</cfif>
<cfif Len(SectionID)>
	<cfquery name="getParentSectionInfo" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select Title, BrowserTitle, MetaDescr
		From Sections With (NoLock)
		Where SectionID=<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif Len(getParentSectionInfo.BrowserTitle)>
		<cfset SectionHeaderTitle=getParentSectionInfo.BrowserTitle>
	<cfelseif Len(getParentSectionInfo.Title)>
		<cfset SectionHeaderTitle=getParentSectionInfo.Title>
	</cfif>
	<cfif Len(getParentSectionInfo.MetaDescr)>
		<cfset SectionMetaDescr=getParentSectionInfo.MetaDescr>
	</cfif>
</cfif>