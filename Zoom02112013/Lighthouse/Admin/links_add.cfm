<cfif isdefined("linktext")>

	<cfquery name="getLastID" datasource="modernsignal_sql" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT LastID FROM #Request.dbprefix#_tableids WHERE TableName = '#Request.dbprefix#_links'
	</cfquery>
	<cfif getLastID.recordCount gt 0>
		<cfset linkid = getLastID.LastID + 1>
		<cfquery name="updateLastID" datasource="modernsignal_sql" username="#Request.dbusername#" password="#Request.dbpassword#">
			UPDATE #Request.dbprefix#_tableids 
			SET LastID = <cfqueryparam cfsqltype="cf_sql_integer" value="#linkid#"> 
			WHERE TableName = '#Request.dbprefix#_links'
		</cfquery>
	<cfelse>
		<cfquery name="getMaxID" datasource="modernsignal_sql" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT max(linkid) as max FROM #Request.dbprefix#_links
		</cfquery>
		<cfif IsNumeric(getMaxID.max)>
			<cfset linkid = getMaxID.max + 1>
		<cfelse>
			<cfset linkid = 1>
		</cfif>
		<cfquery name="updateLastID" datasource="modernsignal_sql" username="#Request.dbusername#" password="#Request.dbpassword#">
			INSERT INTO #Request.dbprefix#_tableids (TableName,LastID) 
			VALUES (
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#Request.dbprefix#_links">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#linkid#">
			)
		</cfquery>
	</cfif>

	<cfquery name="addlink" datasource="modernsignal_sql" username="#Request.dbusername#" password="#Request.dbpassword#">
		insert into #Request.dbprefix#_links (linkid,userid,linktext,href,ordernum)
		values (
			<cfqueryparam cfsqltype="cf_sql_integer" value="#linkid#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#linktext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#href#">,
			1000
		)
	</cfquery>

	<script type="text/javascript">
	opener.location.reload();
	window.close();
	</script>

<cfelse>

	<cfparam name="ffparams" default="">
	<cfset href = cgi.http_referer>
	<cfif len(ffparams)>
		<cfif find("?",href)>
			<cfset href = "#href#&#ffparams#">
		<cfelse>
			<cfset href = "#href#?#ffparams#">
		</cfif>
	</cfif>

	<form action="links_add.cfm" method=post>
	<cfoutput>
	<input type="text" name="linktext" value="#htmleditformat(pg_title)#">
	<input type="hidden" name="href" value="#href#">
	<input type="submit" value="Go">
	</cfoutput>
	</form>

</cfif>