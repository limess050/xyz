
<cfquery name="checkForDupes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SectionID
	From PageSections
	Where PageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
	Order by SectionID
</cfquery>

<cfif checkForDupes.RecordCount gt 1>
	<cfoutput query="checkForDupes" StartRow="2">
		<cfquery name="removeDupes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Delete From PageSections
			Where PageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
			and SectionID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SectionID#">
		</cfquery>
	</cfoutput>
</cfif>
