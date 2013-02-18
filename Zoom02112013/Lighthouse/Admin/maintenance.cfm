<cfinclude template="checkPermission.cfm">

<cfset status="">
<cfif StructKeyExists(url,"action")>
	<cfswitch expression="#url.action#">
		<cfcase value="RepairPageHierarchy">
			<cfset Application.Lighthouse.RepairPageHierarchy()>
			<cfset status = "The page hierarchy has been repaired.">
		</cfcase>
	</cfswitch>
</cfif>

<cfset pg_title = "Site Maintenance">
<cfinclude template="header.cfm">
<cfoutput>
<h1>#pg_title#</h1>
<p class=STATUSMESSAGE>#status#</p>
<h2>Repair Page Hierarchy</h2>
<p>If pages are altered outside of the application, or if the page order is damaged for any reason, this will usually fix it.</p>
<p><a href="#Request.AppVirtualPath#/Lighthouse/Admin/maintenance.cfm?action=RepairPageHierarchy">Repair Page Hierarchy Now</a></p>
</cfoutput>
<cfinclude template="footer.cfm">