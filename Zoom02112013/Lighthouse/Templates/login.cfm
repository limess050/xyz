<cfparam name="username" default="">
<cfparam name="password" default="">
<cfparam name="RememberMe" default="No">
<cfparam name="logout" default="">
<cfparam name="doit" default="">
<cfparam name="redirectUrl" default="">

<cfset msg = "Please login.">

<cfif doit is "Y">
	<cfquery name="getUser" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT userID FROM #lighthouse_getTableName("Users")#
		WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(username)#">
			and password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(password)#"> 
			and active = 1
	</cfquery>
	<cfif getUser.recordCount gt 0>
		<cfif rememberMe is "Yes">
			<cfset lh_setClientInfo("userID",getUser.userID)>
			<cfset lh_setClientInfo("remote_addr",cgi.remote_addr)>
		<cfelse>
			<cfset session.userID = getUser.userID>
		</cfif>
		<cfset StructDelete(session,"User")>

		<cfif Len(redirectUrl) gt 0 and Not FindNoCase("login.cfm",redirecturl)>
			<cflocation url="#redirecturl#" addToken="No">
		<cfelseif len(pageid) gt 0>
			<cflocation url="../../page.cfm?pageid=#pageid#" addToken="No">
		<cfelse>
			<cflocation url="../../page.cfm" addToken="No">
		</cfif>
	</cfif>
	<cfset msg = "Invalid username / password.  Please try again.">
<cfelseif logout is "Y">
	<cfset msg = "You have been logged out.">
	<cfset lh_setClientInfo("userID","")>
	<cfset lh_setClientInfo("remote_addr","")>
	<cfset StructDelete(session,"UserID")>
	<cfset StructDelete(session,"User")>
</cfif>

<!--- Get current url, handle 404.cfm page --->
<cfif cgi.SCRIPT_NAME is Request.AppVirtualPath & "/Lighthouse/404.cfm">
	<cfif Len(cgi.query_string) gt 0>
		<!--- Get url in IIS --->
		<cfset redirectUrl = REReplace(cgi.query_string,"404;https?://[^/]+","")>
	<cfelseif Len(cgi.redirect_url) gt 0>
		<!--- Get url in Apache --->
		<cfset redirectUrl = cgi.redirect_url>
		<cfif Len(cgi.redirect_query_string) gt 0>
			<cfset redirectUrl = redirectUrl  & "?" & cgi.redirect_query_string>
		</cfif>
	</cfif>
	<cfset actionUrl = "#cgi.script_name#?404;http://x#redirectUrl#">
<cfelse>
	<cfset actionUrl = "#cgi.script_name#?#cgi.query_string#">
	<cfset redirectUrl = actionUrl>
</cfif>

<cfif FileExists("#Application.PhysicalPath#/templates\header.cfm")>
	<cfinclude template="../../templates/header.cfm">
</cfif>
<cfoutput>
<div class="title">Member Login</div> 
<p class=std>#msg#</p>
<form name="f1" action="#actionUrl#" method="post">
<input type="hidden" name="redirecturl" value="#Replace(redirectUrl,"&logout=Y","")#">
<table class=std>
	<tr><TD><label for="username">Username:</label></TD><TD><input type="text" name="username" id="username" value="#username#" style="width: 150px;"></td></tr>
	<tr><TD><label for="password">Password:</label></TD><TD><input type="password" name="password" id="password" value="" style="width: 150px;"></td></tr>
	<tr><td colspan=2 ><input type="checkbox" name="rememberMe" id="rememberMe" value="Yes"> <label for="rememberMe">Remember Me</label> </td></tr>
	<tr><td colspan=2 align=right><input type="submit" value="Log In"></td></tr>
</table>
<input type="hidden" name="doit" value="Y">
</form>
</cfoutput>
<cfif FileExists("#Application.PhysicalPath#/templates/footer.cfm")>
	<cfinclude template="../../templates/footer.cfm">
</cfif>
