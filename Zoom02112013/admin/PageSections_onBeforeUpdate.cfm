
<cfquery name="checkTitle" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select Title
	From LH_Pages
	Where PageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
	Order by SectionID
</cfquery>

<cfif Trim(form.Title) neq checkTitle.Title>
	<cfset form.Title = checkTitle.Title>
</cfif>
