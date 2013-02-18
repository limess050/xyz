<!--- check for login --->
<cfif Not StructKeyExists(session,"userID")>
	<cfset lh_getClientInfo("userID")>
</cfif>
<cfif StructKeyExists(Request,"UserQuery")>
	<!--- Already checked login --->
<cfelseif Len(session.userID) gt 0>
	<!--- TODO: Use session.User instead of glb_User query --->
	<cfif Not StructKeyExists(variables,"glb_User")>
		<cfquery name="glb_User" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT * FROM #lighthouse_getTableName("Users")# 
			WHERE userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">
		</cfquery>
	</cfif>
	<cfif Not StructKeyExists(session,"User")>
		<cfset Session.User = CreateObject("component","#Application.ComponentPath#.User").GetRow(session.UserID)>
	</cfif>

<!--- Use basic http authentication --->
<cfelseif StructKeyExists(url,"lh_auth")>
	<cfif Request.lh_authType is "basic">
		<cflogin>
			<cfif IsDefined("cflogin")>
				<cfquery name="getUser" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT userID FROM #lighthouse_getTableName("Users")#
					WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(cflogin.name)#"> 
						and password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(cflogin.password)#"> 
						and active = 1
				</cfquery>
				<cfif getUser.recordCount gt 0>
					<cfset session.userID = getUser.userID>
					<cfquery name="glb_User" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						SELECT * FROM #lighthouse_getTableName("Users")# 
						WHERE userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">
					</cfquery>
				<cfelse>
					<!--- authentication failed - send back 401 --->
					<cfsetting enablecfoutputonly="yes" showdebugoutput="no">
					<cfheader statuscode="401">
					<cfheader name="WWW-Authenticate" value="Basic realm=""#Request.glb_title#""">
					<cfoutput><cfinclude template="login.cfm"></cfoutput>
					<cfabort>
				</cfif>
			<cfelse>
				<!--- authentication failed - send back 401 --->
				<cfsetting enablecfoutputonly="yes" showdebugoutput="no">
				<cfheader statuscode="401">
				<cfheader name="WWW-Authenticate" value="Basic realm=""#Request.glb_title#""">
				<cfoutput><cfinclude template="login.cfm"></cfoutput>
				<cfabort>
			</cfif>
		</cflogin>
	<cfelseif Request.lh_authType is "auto">
		<cfif lighthouse_verifyLoginCode(url.lh_authCode)>
			<cfquery name="glb_User" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT * FROM #lighthouse_getTableName("Users")# 
				WHERE userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">
			</cfquery>
		<cfelse>
			<cfcontent type="text/xml" reset="Yes"><?xml version="1.0" encoding="UTF-8"?>
			<rss version="2.0">
			<channel>
				<cfoutput>
				<title>#Request.glb_title#</title>
				<description>RSS Feed</description>
				<generator>Modern Signal Lighthouse</generator>
				<link>#Request.httpsUrl#/admin/</link>
				<item>
					<title>This RSS Feed requires login</title>
					<link>#Request.httpsUrl#/admin/</link>
					<description><![CDATA[This RSS feed requires login. Please login to the site admin and check the "Remember Me" box.  If you are still unable to access the feed, refresh the url of the feed as your client identification information may have changed.<br/>
					#Request.httpsUrl#/admin]]></description>
				</item>
				</cfoutput>
			</channel>
			</rss>
			<cfabort>
		</cfif>
	</cfif>
<cfelse>
	<cfif StructKeyExists(variables,"exitFrameOnFailure")>
		<cfoutput>
		<script type="text/javascript">
			parent.window.location = "#Request.AppVirtualPath#/Admin/index.cfm?adminFunction=login";
		</script>
		</cfoutput>
	<cfelse>
		<cfinclude template="login.cfm">
	</cfif>
	<cfabort>
</cfif>