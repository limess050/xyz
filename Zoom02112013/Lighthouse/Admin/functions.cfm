
<!--- include appropriate admin function template --->
<cfparam name="url.adminFunction" default="">
<cfif len(url.adminFunction) gt 0>
	<cfinclude template="#url.adminFunction#.cfm">
	<cfabort>
</cfif>