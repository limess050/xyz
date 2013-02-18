<!---
Use this to include flash files in the site.  Eliminates the need to click on the object in IE to interact with it. 

Note that the calling page needs to have the "write" javascript function in an external javascript file.  
This is the entire write function:
function write(s){document.write(s);}
More information about this workaround: http://www.adobe.com/devnet/activecontent/articles/devletter.html
--->
<cfif thisTag.executionMode is "start">
	<cfparam name="attributes.src" type="string">
	<cfparam name="attributes.width" type="Numeric">
	<cfparam name="attributes.height" type="Numeric">
	<cfparam name="attributes.classid" type="string" default="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000">
	<cfparam name="attributes.codebase" type="string" default="https://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab##version=8,0,0,0">
	<cfparam name="attributes.quality" type="string" default="high">
	<cfparam name="attributes.wmode" type="string" default="opaque">
	<cfparam name="attributes.pluginspage" type="string" default="http://www.macromedia.com/go/getflashplayer">
	<cfparam name="attributes.type" type="string" default="application/x-shockwave-flash">
	<cfparam name="attributes.alt" type="string" default="<p>This site uses the Flash plugin: <a href=""#attributes.pluginspage#"">Download Macromedia Flash Player</a></p>">
	<cfoutput>
	<cfsavecontent variable="html">
		<object width=#attributes.width# height=#attributes.height# classid="#attributes.classid#" codebase="#attributes.codebase#">
			<param name="movie" value="#attributes.src#">
			<param name="quality" value="#attributes.quality#">
			<param name="wmode" value="#attributes.wmode#" /> 
			<embed src="#attributes.src#" quality="#attributes.quality#" 
				width=#attributes.width# height=#attributes.height# type="#attributes.type#" wmode="#attributes.wmode#"
				pluginspage="#attributes.pluginspage#"><noembed>#attributes.alt#</noembed></embed></object>
	</cfsavecontent>
	<script type="text/javascript">write("#JSStringFormat(trim(html))#");</script>
	<noscript>#html#</noscript>
	</cfoutput>
</cfif>