<!---
Uses Google Site Search
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfparam name="SearchString" default="">

<cfif IsDefined('ParentSectionID') and ParentSectionID is "59">
	<cflocation url="searchEvents?SearchKeyword=#SearchString#">
	<cfabort>
</cfif>

<cfif IsDefined('SearchByID')>
	<cfinclude template="searchByID.cfm">
	<cfabort>
</cfif>

<cfquery name="getImpressionSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SectionID
	From PageSections
	Where PageID = <cfqueryparam value="#PageID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfset ImpressionSectionID=getImpressionSection.SectionID>
<cfif not Len(ImpressionSectionID)>
	<cfset ImpressionSectionID = 0>
</cfif>

<cfif not IsDefined('application.SectionImpressions')>
	<cfset application.SectionImpressions= structNew()>
</cfif>
<cfif StructKeyExists(application.SectionImpressions,ImpressionSectionID)>
	<cfset application.SectionImpressions[ImpressionSectionID] = application.SectionImpressions[ImpressionSectionID] + 1>
<cfelse>
	<cfset application.SectionImpressions[ImpressionSectionID] = 1>
</cfif>

<cfinclude template="header.cfm">

<cfoutput>
<div class="centercol-inner legacy">
<h1>Search</h1>
<p><br />
</p>

 <div class="breadcrumb""><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/">Home</a> &gt; <span class="bluelarge">Search</span></div>

</cfoutput>
<div>&nbsp;</div>
<lh:MS_SitePagePart id="body" class="body">
<cfif edit>
	<p>Google Search results appear here when a front end user searches the site.
<cfelse>
	<!-- Google Custom Search Element -->
<div id="content" style="width:100%;">Loading</div>
</cfif>
</div>
<script src="http://www.google.com/jsapi?key=ABQIAAAAs4bUrU3UYo3QuttRyzWeCBT4KXwjL5Js96inGw8gTzYiZ0o0gBSEzgoQza8Soaz0Mp1qnzRt13bU8A" type="text/javascript"></script>
<script>
google.load('search', '1');

function OnLoad() {
  // Create a custom search control that uses a CSE restricted to code.google.com
  var customSearchControl = new google.search.CustomSearchControl('004038081299251871320:g3htxkah5-g');

  // Draw the control in content div
  customSearchControl.draw('content'); 
  
  // run a query
  customSearchControl.execute('<cfoutput>#searchString#</cfoutput>');
}
google.setOnLoadCallback(OnLoad);


</script>
<cfinclude template="footer.cfm">