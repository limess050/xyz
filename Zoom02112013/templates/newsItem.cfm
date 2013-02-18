<!---
News Item template
Simplified news article template
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfinclude template="header.cfm">

<lh:MS_SitePagePart id="title" class="title" title="Title of News Article">
<lh:MS_SitePagePart id="body" class="newsBody" title="Body of News Article">
<lh:MS_SitePagePart id="contact" class="newsContact" title="Contact Information">

<cfinclude template="footer.cfm">
