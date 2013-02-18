<cfparam name="username" default="">
<cfparam name="password" default="">
<cfparam name="RememberMe" default="No">
<cfparam name="logout" default="">
<cfparam name="doit" default="">
<cfparam name="msg" default="Please login.">
<cfparam name="redirectUrl" default="#cgi.script_name#?#cgi.query_string#">

<cfif doit is "Y">
	<cfquery name="getUser" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT userID FROM #lighthouse_getTableName("Users")#
		WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stripCR(trim(username))#">
			and password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stripCR(trim(password))#">
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

		<!--- Use javascript to redirect. --->
		<cfoutput>
		<script type="text/javascript">
		<cfif Not FindNoCase("adminFunction=login",redirecturl)>
			window.location="#redirecturl#";
		<cfelse>
			window.location="index.cfm";
		</cfif>
		</script>
		</cfoutput>
		<cfabort>
	</cfif>
	<cfset msg = "Invalid username / password.  Please try again.">
<cfelseif logout is "Y">
	<cfset msg = "You have been logged out.">
	<cfset lh_setClientInfo("userID","")>
	<cfset lh_setClientInfo("remote_addr","")>
	<cfset StructDelete(session,"UserID")>
	<cfset StructDelete(session,"User")>
</cfif>

<!--- Save any submitted form information in the session --->
<cfif StructCount(form) gt 0>
	<cfset session.SavedFormScope = Duplicate(form)>
</cfif>

<cfoutput>
<!--- handle hidden frames --->
<cfif cgi.script_name is "#Request.AppVirtualPath#/Lighthouse/Admin/pageHiddenForm.cfm">
	<script type="text/javascript">
		parent.onbeforeunload = null;
		parent.location = "#Request.AppVirtualPath#/Admin/index.cfm?adminFunction=login&redirectUrl=#UrlEncodedFormat(cgi.script_name & '?' & cgi.query_string)#";
	</script>
<cfelse>
	<html>
	<head>
	<cfinclude template="headerIncludes.cfm">
	<title>#Request.glb_title#: Login</title>
	</head>
	<body onLoad="document.f1.username.focus()" class=NORMALTEXT>
	<p class="pagetitle">#Request.glb_title#: Login</p>
	<p class=statusmessage>#msg#</p>
	<form name="f1" action="index.cfm?AdminFunction=login" method="post">
		<input type="hidden" name="redirecturl" value="#redirectUrl#">
		<table class="NORMALTEXT">
			<tr><TD><label for="username">Username:</label></TD><TD><input type="text" name="username" id="username" value="#username#" size=20></td></tr>
			<tr><TD><label for="username">Password:</label></TD><TD><input type="password" name="password" id="password" value="" size=20></td></tr>
			<tr><td colspan=2 ><input type="checkbox" name="rememberMe" id="rememberMe" value="Yes"> <label for="rememberMe">Remember Me</label> </td></tr>
			<tr><td colspan=2 align=right><input type="submit" value="Login" class="button"></td></tr>
		</table>
		<input type="hidden" name="doit" value="Y">
	</form>
	</body>
	</html>
</cfif>
</cfoutput>
