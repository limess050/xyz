<cfparam name="username" default="">
<cfparam name="password" default="">
<cfparam name="RememberMe" default="No">
<cfparam name="logout" default="">
<cfparam name="doit" default="">
<cfparam name="redirectUrl" default="">

<cfparam name="msg" default = "Please login.">

<cfif doit is "Y">
	<cfquery name="getUser" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT userID, IsNull(ContactFirstName,'') + ' ' + IsNull(ContactLastName,'') as UserName, ConfirmedDate,
		AreaID, GenderID, BirthMonthID, BirthYearID, EducationLevelID, SelfIdentifiedTypeID, Blacklist_fl
		FROM LH_Users
		WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(username)#">
			and password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(password)#"> 
			and active = 1
	</cfquery>
	<cfif getUser.recordCount gt 0>
		<cfif getUser.Blacklist_fl>
			<cfset msg = "Blacklisted">
		<cfelseif Len(getUser.ConfirmedDate)>
			<cfinclude template="../includes/LoginSetVars.cfm">
			
			<cfif Len(redirectUrl) gt 0 and Not FindNoCase("login.cfm",redirecturl)>
				<cflocation url="#redirecturl#" addToken="No">
				<cfabort>
			<cfelseif len(pageid) gt 0>
				<cflocation url="../../page.cfm?pageid=#pageid#" addToken="No">
				<cfabort>
			<cfelse>
				<cflocation url="../../page.cfm" addToken="No">
				<cfabort>
			</cfif>
		<cfelse>
			<cfset msg = "This account has not been confirmed.  Please open the confirmation email you received when creating an account and follow the link provided in the email.">
		</cfif>		
	<cfelse>
		<cfset msg = "Invalid username / password.  Please try again.">
	</cfif>
	<cfif RedirectURL contains "?">
			<cflocation url="#redirecturl#&msg=#URLEncodedFormat(msg)#" addToken="No">
	<cfelse>
		<cflocation url="#redirecturl#?msg=#URLEncodedFormat(msg)#" addToken="No">
	</cfif>
	<cfabort>
<cfelseif logout is "Y">
	<cfset msg = "You have been logged out.">
	<cfset lh_setClientInfo("userID","")>
	<cfset lh_setClientInfo("username","")>
	<cfset lh_setClientInfo("remote_addr","")>
	<cfset StructDelete(session,"UserID")>
	<cfset StructDelete(session,"User")>
	<cflocation url="myAccount" addToken="No">
	<cfabort>
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
	<cfinclude template="header.cfm">
</cfif>
<cfoutput>
<div class="centercol-inner legacy">
<p>&nbsp;</p>
<h1>Account Login</h1> 
<cfif Len(msg)>
	
		<cfif msg is "Blacklisted">
			<p>
				This account has been blacklisted due to abuse!  Blacklisting occurs for any of the following reasons:</p>
	 			<ol>
					<li>Posting scams</li>
					<li>Failure to honor the posted price of a classified</li>
					<li>False advertising</li>
					<li>Sending SPAM or unwanted solicitations through the "Click to Email" feature of any listing on the site</li>
					<li>Other attempts to post inaccurate or deceitful information</li>
				</ol>
			<p>	
				If you feel you have been improperly blacklisted, you can appeal by calling +255 786 264 687.  We will review your account, and if it is determined that you were improperly blacklisted, then we will reactivate your account immediately.
			</p>
		<cfelse>
			<p class=std>#msg#</p>
		</cfif>	
</cfif>
<cfif ListFind("#Request.AddAListingPageID#,#Request.MyAccountPageID#",PageID)>
	<cfquery name="getPostingPagePart" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT label,shortValue,longValue FROM LH_PageParts_Live
			WHERE pageID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Request.AddAListingPageID#">
			and label=<cfqueryparam cfsqltype="cf_sql_varchar" value="bodyPleaseLogIn">
	</cfquery>
	<cfif getPostingPagePart.RecordCount>
		<div class="body">#getPostingPagePart.ShortValue##getPostingPagePart.LongValue#<br></div>
	</cfif>	
</cfif>
<cfset RedirectURL=Replace(redirectUrl,"&logout=Y","")>
<cfif ListLen(RedirectURL,"?") gt 1>
	<cfset RedirectURLName=ListGetAt(RedirectURL,1,"?")>
	<cfset RedirectURLVars=ListGetAt(RedirectURL,2,"?")>
	<cfset RedirectURLVarsStripped = "">
	<cfloop list="#RedirectURLVars#" index="v" delimiters="&">
		<cfif Left(v,4) neq "msg=">
			<cfset RedirectURLVarsStripped = ListAppend(RedirectURLVarsStripped,v,"&")>
		</cfif>
	</cfloop>
	<cfset RedirectURL = "#RedirectUrlName#?#RedirectURLVarsStripped#">
</cfif>
<form name="f1" action="#actionUrl#" method="post">
<input type="hidden" name="redirecturl" value="#RedirectUrl#">
<table class=std>
	<tr><TD><a href="#lh_getPageLink(Request.CreateAccountPageID,'createaccount')#">Sign up for an Account</a></td></tr>
	<tr><TD><label for="username">Username:<br><span class="instructions">(Your Email Address)</span></label></TD><TD><input type="text" name="username" id="username" value="#username#" style="width: 150px;"></td></tr>
	<tr><TD><label for="password">Password:</label></TD><TD><input type="password" name="password" id="password" value="" style="width: 150px;"></td></tr>
	<tr><td colspan=2 align=right><input type="submit" value="Log In" class="btn"></td></tr>
	<tr><td colspan=2><a href='#request.httpURL#/forgotPassword'>Forgot Password</a></td></tr>
</table>
<input type="hidden" name="doit" value="Y">
</form>
</div>
</cfoutput>
<cfif FileExists("#Application.PhysicalPath#/templates/footer.cfm")>
	<cfinclude template="footer.cfm">
</cfif>
