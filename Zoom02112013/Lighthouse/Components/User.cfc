<cfcomponent name="User" hint="Defines a user." extends="Row">

	<cffunction name="GetRow" description="Gets a user." output="false" returntype="User">
		<cfargument name="userID" type="numeric" required="true">

		<cfif arguments.userID gt 0>
			<cfquery name="getUser" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT firstName, lastName 
				FROM #Application.Lighthouse.lighthouse_getTableName("Users")#
				WHERE userID = <cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<cfif getUser.recordcount gt 0>
				<cfset This.UserID = arguments.UserID>
				<cfset This.FirstName = getUser.firstName>
				<cfset This.LastName = getUser.lastName>
				<cfset This.FullName = This.FirstName & " " & This.LastName>
				<cfreturn This>
			</cfif>
		</cfif>

		<cfset This.UserID = 0>
		<cfset This.FirstName = "">
		<cfset This.LastName = "">
		<cfset This.FullName = "">
		<cfreturn This>
	</cffunction>

	<cffunction name="GetWorkInProgress" description="Gets pages that the user has saved as work in progress." output="false" returntype="Query">
		<cfquery name="getWorkInProgress" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT p.pageID, 
				case 
					when p.title is not null and Len(p.title) > 0 and p.title <> '<br>' then p.title
					when p.navtitle is not null and Len(p.navtitle) > 0 then p.navtitle
					else p.name
				end as title
			FROM #Request.dbprefix#_Pages p
			WHERE p.statusID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Application.Lighthouse.WorkInProgressStatus#">
				and <cfqueryparam cfsqltype="cf_sql_integer" value="#This.UserID#"> = (
					SELECT TOP 1 userID 
					FROM #Request.dbprefix#_Pages_Audit
					WHERE StatusID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Application.Lighthouse.WorkInProgressStatus#">
						and pageID = p.pageID
					ORDER BY actionDate desc
				)
			ORDER BY p.title
		</cfquery>
		<cfreturn getWorkInProgress>	
	</cffunction>

	<cffunction name="GetWorkInProgressJson" description="Gets work in progress pages in json string." output="true" access="remote">
		<cfheader name="Expires" value="#Now()#">
		<cfif StructKeyExists(session,"User")>
			<cfset wip = Session.User.GetWorkInProgress()>
			/*[<cfoutput query="wip"><cfif currentRow gt 1>,</cfif>[#pageid#,"#JSStringFormat(title)#"]</cfoutput>]*/
		</cfif>
	</cffunction>

	<cffunction name="GetWorkflowItems" description="Gets pages in workflow by status." output="false" returntype="Query">
		<cfquery name="getWorkflowItems" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT s.descr as status, p.pageID, 
				case 
					when p.title is not null and Len(p.title) > 0 and p.title <> '<br>' then p.title
					when p.navtitle is not null and Len(p.navtitle) > 0 then p.navtitle
					else p.name
				end as title
			FROM #Request.dbprefix#_Pages p
				INNER JOIN #Request.dbprefix#_Statuses s ON p.statusID = s.statusID
			WHERE p.statusID NOT IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#Application.Lighthouse.WorkInProgressStatus#,#Application.Lighthouse.LiveStatus#" list="true">)
				AND s.orderNum < (
					SELECT max(s2.orderNum) 
					FROM #Request.dbprefix#_UserStatus us 
						INNER JOIN #Request.dbprefix#_Statuses AS s2 ON us.StatusID = s2.StatusID
					WHERE userID = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.UserID#">
				)
			ORDER BY s.orderNum, p.title
		</cfquery>
		<cfreturn getWorkflowItems>	
	</cffunction>

	<cffunction name="GetWorkflowItemsJson" description="Gets workflow pages in json string." output="true" access="remote">
		<cfheader name="Expires" value="#Now()#">
		<cfif StructKeyExists(session,"User")>
			<cfset started = false>
			<cfset workflow = Session.User.GetWorkflowItems()>
			/*[<cfoutput query="workflow" group="status">
				<cfif currentRow gt 1>,</cfif>["#JSStringFormat(status)#",[
					<cfoutput>
						<cfif started>,<cfelse><cfset started = true></cfif>
						[#pageid#,"#JSStringFormat(title)#"]
					</cfoutput>
				]]
				<cfset started = false>
			</cfoutput>]*/
		</cfif>
	</cffunction>
	
	<cffunction name="GetRecent" description="Gets pages that the user has saved as work in progress." output="false" returntype="Query">
		<cfquery name="getRecent" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT TOP 10 p.pageID, 
				case 
					when p.title is not null and Len(p.title) > 0 and p.title <> '<br>' then p.title
					when p.navtitle is not null and Len(p.navtitle) > 0 then p.navtitle
					else p.name
				end as title
			FROM #Request.dbprefix#_Pages p
				INNER JOIN #Request.dbprefix#_Pages_Audit A ON p.pageID = a.pageID
			WHERE p.statusID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Application.Lighthouse.LiveStatus#">
				and a.statusID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Application.Lighthouse.LiveStatus#">
				and a.userID = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.UserID#">
				and a.ActionDate = (
					SELECT Max(ActionDate) FROM #Request.dbprefix#_Pages_Audit
					WHERE userID = a.userID and pageID = p.pageID
				)
			ORDER BY a.actionDate desc
		</cfquery>
		<cfreturn getRecent>	
	</cffunction>

	<cffunction name="GetRecentJson" description="Gets work in progress pages in json string." output="true" access="remote">
		<cfheader name="Expires" value="#Now()#">
		<cfif StructKeyExists(session,"User")>
			<cfset wip = Session.User.GetRecent()>
			/*[<cfoutput query="wip"><cfif currentRow gt 1>,</cfif>[#pageid#,"#JSStringFormat(title)#"]</cfoutput>]*/
		</cfif>
	</cffunction>

	<cffunction name="GetSetting" description="Gets a client setting." output="true" access="remote">
		<cfargument name="setting" type="string" required="true">
		<cfheader name="Expires" value="#Now()#">
		<cfif StructKeyExists(session,"User")>
			/*"#JSStringFormat(Application.Lighthouse.lh_getClientInfo(arguments.setting))#"*/
		</cfif>
	</cffunction>

	<cffunction name="SaveSetting" description="Saves a client setting." output="true" access="remote">
		<cfargument name="setting" type="string" required="true">
		<cfargument name="data" type="string" required="true">
		<cfheader name="Expires" value="#Now()#">
		<cfif StructKeyExists(session,"User")>
			/*"#JSStringFormat(Application.Lighthouse.lh_setClientInfo(arguments.setting,arguments.data))#"*/
		</cfif>
	</cffunction>

</cfcomponent>