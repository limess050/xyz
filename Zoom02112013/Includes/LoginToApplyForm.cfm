<!--- This template expects a ListingID. --->

<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfparam name="username" default="">
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

<cfoutput>
	<cfif not IsDefined('ListingID') or not IsNumeric(ListingID) or not Len(ListingID)>
		No Listing found.
	<cfelse>
		<div class="body">
		<cfif IsDefined('msg') and Left(msg,16) is "Invalid username">
			#msg#<br><br>
		<cfelse>
			<lh:MS_SitePagePart id="bodyJobPleaseLogIn" class="body"><br><br>
		</cfif>
		</div>
		<form name="f10" action="#request.httpUrl#/templates/login.cfm" method="post">
		<input type="hidden" name="redirecturl" value="#Request.httpsUrl#/ListingDetail?ListingID=#ListingID#&CE=1">
		<table class=std>
	<tr><TD><a href="#lh_getPageLink(Request.CreateAccountPageID,'createaccount')#">Sign up for an Account</a></td></tr>
			<tr><TD><label for="username">Username:<br><span class="instructions">(Your Email Address)</span></label></TD><TD><input type="text" name="username" id="username" value="#username#" style="width: 150px;"></td></tr>
			<tr><TD><label for="password">Password:</label></TD><TD><input type="password" name="password" id="password" value="" style="width: 150px;"></td></tr>
			<tr><td colspan=2 align=right><input type="submit" value="Log In" class="btn"></td></tr>
			<tr><td colspan=2><a href='#request.httpURL#/forgotPassword'>Forgot Password</a></td></tr>
		</table>
		<input type="hidden" name="doit" value="Y">
		</form>
	</cfif>
</cfoutput>
