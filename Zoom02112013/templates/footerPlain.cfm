<!---
Simple footer used for Listing Images page
--->
		<div class="clear"></div>
		<!-- END HOME PAGE WRAPPER -->
	</div>
	<cfoutput>
	<div class="footer">
		<div class="footer-left float-left">Copyright &copy; #DateFormat(application.CurrentDateInTZ,'yyyy')#, All rights reserved</div>
		<div class="clear"></div>
	</div>
	</cfoutput>
	<!-- END WRAPPER -->
</div>
<cfparam name="useCustomTracker" default="0">
<cfif (Request.environment is "LIVE" or Request.environment is "Devel") and not edit and not useCustomTracker>
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("<cfif Request.environment is "Live">UA-15419468-1<cfelse>UA-15419468-2</cfif>");
pageTracker._trackPageview();
} catch(err) {}</script>
</cfif>



