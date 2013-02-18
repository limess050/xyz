<cfinclude template="checkPermission.cfm">

<cfparam name="orderBy" default="dateModified">
<cfquery name="getDeleted" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT pageID,null as pageArchiveID,coalesce(title,navTitle) as title,dateModified
	FROM #Request.dbprefix#_Pages_Live
	WHERE pageID NOT IN (SELECT pageID FROM #Request.dbprefix#_Pages)
	UNION
	SELECT pageID,pageArchiveID,coalesce(title,navTitle) as title,dateModified
	FROM #Request.dbprefix#_Pages_Archive
	WHERE pageID NOT IN (SELECT pageID FROM #Request.dbprefix#_Pages)
	ORDER BY 
	<cfif orderBy is "dateModified">
		dateModified desc
	<cfelse>
		title,dateModified desc
	</cfif>
</cfquery>

<cfset pg_title = "Restore Deleted Pages">
<cfinclude template="header.cfm">

<cfif getDeleted.recordCount gt 0>
	<h1>Restore Deleted Pages</h1>
	<p>The following deleted pages can be restored.</p>
	<p>Click on the page title to view archived versions of the page.</p>
	<table cellpadding=0 cellspacing=0 border=0 class="VIEWTABLE">
		<tr>
			<th CLASS=VIEWHEADERCELL><a href="index.cfm?adminFunction=restoreDeletedPages&orderBy=DateModified">Date Modified</a></th>
			<th CLASS=VIEWHEADERCELL><a href="index.cfm?adminFunction=restoreDeletedPages&orderBy=DateModified">Title</a></th>
		</tr>
		<cfoutput group="pageID" query="getDeleted">
			<tr>
				<td>#DateFormat(dateModified,"mmmm d, yyyy")#</td>
				<td><a href="index.cfm?adminFunction=versionsView&pageID=#pageID#&pageArchiveID=#pageArchiveID#" target="_blank">#title#</a></td>
			</tr>
		</cfoutput>
	</table>
<cfelse>
	<p>There are no deleted pages that can be restored.</p>
</cfif>

<cfinclude template="footer.cfm">