<cfparam name="Request.httpURL" default="">
<cfparam name="Request.httpsURL" default="">

<cfif Find("https",Request.httpsURL) gt 0 and cgi.server_port is not "443">
	<cflocation url="#Request.httpsURL##cgi.script_name#?#cgi.query_string#" addtoken="false">
</cfif>