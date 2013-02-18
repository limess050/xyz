<!---
Shadow Template
Allows the user to select a page to shadow.
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfif edit>

	<cfinclude template="header.cfm">
	<cfif IsDefined("form.masterPageID")>
		<cfquery name="getMasterPageTemplate" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			select templateID 
			from #Request.dbprefix#_Pages 
			where pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.masterPageID#"> 
		</cfquery>
		<cfif getMasterPageTemplate.templateID is templateID>
			<cfoutput>
			You cannot shadow a page that is itself a shadow.<br>
			<a href="page.cfm?pageID=#pageID#&pageVersion=working&edit=true" target="_self">&lt;&lt;Back</a>
			</cfoutput>
		<cfelse>
			<cfquery name="updateMasterPageID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				update #Request.dbprefix#_Pages 
				set masterPageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.masterPageID#">
				where pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#PageID#">
			</cfquery>
			<cflocation url="page.cfm?pageID=#pageID#&pageVersion=working&edit=true">
		</cfif>

	<cfelse>
		<cfoutput>
		<form action="page.cfm?pageID=#pageID#&pageVersion=working&edit=true" method=post target="_self">
		<input type="hidden" name="masterPageID" id="masterPageID" value="#masterPageID#">
		<cfif Len(masterPageID) gt 0>
			<lh:MS_SitePagePart id="title" class="title">
			<p>This page uses the shadow template, which means that it's content exactly mirrors the content of a "master" page elsewhere in the site.</p>
			<p>Select an action below:</p>
			<ul>
			<li><a href="#Request.AppVirtualPath#/admin/index.cfm?adminFunction=editPage&pageID=#masterPageID#">Edit the master page</a>.
			<li><a href="#Request.AppVirtualPath#/admin/index.cfm?adminFunction=dialogs%2FgoToPage&action=selectMasterPage" target="dialog2" onclick="popupDialog('dialog2',600,500,'resizable=1,scrollbars=1,status=1')">Select a different page to shadow</a>
			</ul>
		<cfelse>
			The Shadow page template allows you to create a page that exactly shadows a page in another part of the site.  <a href="/admin/index.cfm?adminFunction=dialogs%2FgoToPage&action=selectMasterPage" target="dialog2" onclick="popupDialog('dialog2',600,500,'resizable=1,scrollbars=1,status=1')"><b>Click here</b></a> to choose a page to shadow.
		</cfif>
		</form>
		</cfoutput>
	</cfif>
	<cfinclude template="footer.cfm">

<cfelse>

	<cfif len(masterTemplateID) gt 0>
		<cfquery name="getTemplate" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			select fileName 
			from #Request.dbprefix#_Templates 
			where templateID = <cfqueryparam cfsqltype="cf_sql_integer" value="#masterTemplateID#">
		</cfquery>

		<cfif getTemplate.recordcount gt 0>
			<cfinclude template="#getTemplate.fileName#">
		<cfelse>
			<cfinclude template="default.cfm">
		</cfif>
	<cfelse>
		<cfinclude template="default.cfm">
	</cfif>

</cfif>