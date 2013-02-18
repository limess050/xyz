<!---
News Article template
Appropriate for general news articles and/or press releases.
To customize simply add or remove page parts.
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfscript>
function showField(fieldName) {
	var show = false;
	if (edit) {
		show = true;
	} else if (StructKeyExists(pageParts,fieldName)) {
		if (Trim(pageParts[fieldName]) is not "") {
			show = true;
		}
	}
	return show;
}
</cfscript>

<cfinclude template="header.cfm">


<p>
<lh:MS_SitePagePart id="Title" class="title" default="#variables.navTitle#">
<lh:MS_SitePagePart id="Subtitle">
</p>

<p><lh:MS_SitePagePart id="NewsDate" element="span" type="Date" default="#DateFormat(Now(),"mm/dd/yyyy")#" format="mmmm d, yyyy"></p>
<p>
<cfif showField("Source")>
	<div style="float:left">Source:&nbsp;</div>
	<table cellpadding=0 cellspacing=0><tr><td><lh:MS_SitePagePart id="Source"></td></tr></table>
</cfif>
<cfif showField("Issue")>
	<div style="float:left">Issue/Volume:&nbsp;</div>
	<table cellpadding=0 cellspacing=0><tr><td><lh:MS_SitePagePart id="Issue"></td></tr></table>
</cfif>
<cfif showField("Author")>
	<div style="float:left">Author:&nbsp;</div>
	<table cellpadding=0 cellspacing=0><tr><td><lh:MS_SitePagePart id="Author"></td></tr></table>
</cfif>
</p>

<p><lh:MS_SitePagePart id="Body" title="Article Content"></p>

<cfif showField("ContactInfo")>
	<p><b>Contact Information:</b><br><lh:MS_SitePagePart id="ContactInfo"></p>
</cfif>

<!--- Code in the template header will reorder news pages. --->
<!--- Set toolbar to reload page when it is saved so that reordering will happen immediately. --->
<cfif edit>
	<script type="text/javascript">
	try { top.getEl("reloadPage").value = "true"; } catch(ex) {}
	</script>
</cfif>

<cfinclude template="footer.cfm">