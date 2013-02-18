
<cfimport prefix="lh" taglib="../Lighthouse/Tags">



<cfset ContentStyle="content">
<cfset ShowRightColumn="0">

<cfinclude template="header.cfm">
<script type="text/javascript" src="Lighthouse/Resources/js/lighthouse_all.js"></script>


<cfoutput>
<div class="centercol-inner-wide legacy legacy-wide">
	<h1>Tide Lunar Schedule</h1>


 <div class="breadcrumb""><a href="##">Home</a> &gt; <span id="crumb"></span></div>
	<div>&nbsp;</div>
</cfoutput>
<cfif edit>
	<p>Text to display on page.</p>
	<lh:MS_SitePagePart id="body" class="body">
	
<cfelse>
 	
			<lh:MS_SitePagePart id="body" class="body">
			<!--- Section and Category --->
			<p>&nbsp;</p>
			<cfinclude template="../includes/TidesLunarDetail.cfm">
		
</cfif>

</div>

<!-- END CENTER COL -->
<cfinclude template="footer.cfm">
