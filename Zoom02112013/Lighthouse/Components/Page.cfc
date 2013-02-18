<cfcomponent name="Page" hint="Defines a page in the website." extends="Row">

	<cffunction name="Init" description="Instantiate page row." output="false" returntype="Page">
		<cfargument name="Properties" required="true" type="struct">

		<cfset This.Table = Application.Tables.Pages>
		<cfloop collection="#This.Table.Columns#" item="colName">
			<cfif StructKeyExists(Properties,colName)>
				<cfset This[colName] = Properties[colName]>
			</cfif>
		</cfloop>
		<cfreturn This>
	</cffunction>
	
	<cffunction name="Delete" description="Deletes a row in the database" output="false" returntype="boolean">
		<cfquery name="checkpage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT name,CanDelete,dateModified FROM #Request.dbprefix#_Pages 
			WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.pageID#">
		</cfquery>
		<cfif checkpage.recordcount gt 0>
			<cfif checkpage.CanDelete is 1>
				<cfset name = checkpage.name>

				<!--- update child pages, if any --->
				<cfquery name="UPDATEPages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					UPDATE #Request.dbprefix#_Pages 
					SET parentpageid = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.parentPageID#" null="#Application.Lighthouse.IsEmpty(parentpageid)#">, 
						subordernum = <cfqueryparam cfsqltype="cf_sql_real" value="#This.subordernum#"> 
					WHERE parentpageid = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.pageID#">
				</cfquery>
				<cfquery name="UPDATEPages_Live" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					UPDATE #Request.dbprefix#_Pages_Live 
					SET parentpageid = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.parentPageID#" null="#Application.Lighthouse.IsEmpty(parentpageid)#">, 
						subordernum = <cfqueryparam cfsqltype="cf_sql_real" value="#this.subordernum#">
					WHERE parentpageid = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.pageID#">
				</cfquery>
				<cfquery name="UPDATEPages_Archive" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					UPDATE #Request.dbprefix#_Pages_Archive 
					SET parentpageid = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.parentPageID#" null="#Application.Lighthouse.IsEmpty(parentpageid)#">, 
						subordernum = <cfqueryparam cfsqltype="cf_sql_real" value="#this.subordernum#">
					WHERE parentpageid = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.pageID#">
				</cfquery>

				<!--- archive working record --->
				<cfquery name="saveArchivePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					INSERT INTO #Request.dbprefix#_Pages_Archive (pageID, parentPageID, name, sectionID, title, navTitle, dateModified, pageLevel, orderNum, subordernum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID)
					SELECT pageID, parentPageID, name, sectionID, title, navTitle, dateModified, pageLevel, orderNum, subordernum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID
					FROM #Request.dbprefix#_Pages
					WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.pageID#">
				</cfquery>
				<cfquery name="getID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT @@Identity as pageArchiveID
				</cfquery>
				<cfquery name="saveArchivePageParts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					INSERT INTO #Request.dbprefix#_PageParts_Archive (pagePartID, pageArchiveID, label, shortValue, longValue, orderNum)
					SELECT pagePartID,#getID.pageArchiveID#,label, shortValue, longValue, orderNum
					FROM #Request.dbprefix#_PageParts
					WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.pageID#">
				</cfquery>
				<!--- Delete working record --->
				<cfquery name="deletePages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					DELETE FROM #Request.dbprefix#_Pages 
					WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.pageID#">
				</cfquery>
				
				<!--- archive live record --->
				<cfquery name="checkLive" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT dateModified FROM #Request.dbprefix#_Pages_Live 
					WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.pageID#">
				</cfquery>
				<cfif checkLive.recordCount gt 0>
					<!--- Only archive if it is different from the working record --->
					<cfif checkLive.dateModified is not checkPage.dateModified>
						<!--- archive live record --->
						<cfquery name="saveArchivePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							INSERT INTO #Request.dbprefix#_Pages_Archive (pageID, parentPageID, name, sectionID, title, navTitle, dateModified, pageLevel, orderNum, subordernum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID)
							SELECT pageID, parentPageID, name, sectionID, title, navTitle, dateModified, pageLevel, orderNum, subordernum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID
							FROM #Request.dbprefix#_Pages_Live
							WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.pageID#">
						</cfquery>
						<cfquery name="getID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							SELECT @@Identity as pageArchiveID
						</cfquery>
						<cfquery name="saveArchivePageParts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							INSERT INTO #Request.dbprefix#_PageParts_Archive (pagePartID, pageArchiveID, label, shortValue, longValue, orderNum)
							SELECT pagePartID,#getID.pageArchiveID#,label, shortValue, longValue, orderNum
							FROM #Request.dbprefix#_PageParts_Live
							WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.pageID#">
						</cfquery>
					</cfif>
					
					<!--- delete live record --->
					<cfquery name="deleteLivePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						DELETE FROM #Request.dbprefix#_Pages_Live 
						WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#This.pageID#">
					</cfquery>
				</cfif>

				<cfset Application.PageAudit.InsertRow(PageID="#This.pageID#",PageName="#name#",User="#session.User#",Delete="1")>
				<cfset Application.Lighthouse.RepairPageHierarchy()>
				<cfreturn true>
			</cfif>
		</cfif>
		<cfreturn false>
	</cffunction>

	<cffunction name="Save" description="Saves a page." output="false" returntype="boolean">
	</cffunction>

	<cffunction name="GetWorkingPage" description="Get a page" output="false" returntype="Query">
		<cfargument name="PageID" required="true" type="numeric">
		<cfquery name="getPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT p.*,
				t.name as templateName, 
				s.descr as statusName,
				CASE WHEN l.pageID is null THEN 'No' ELSE 'Yes' END as LiveExists
			FROM #Request.dbprefix#_Pages p 
				LEFT JOIN #Request.dbprefix#_Templates t on p.templateID = t.templateID
				LEFT JOIN #Request.dbprefix#_Statuses s on p.statusID = s.statusID
				LEFT JOIN #Request.dbprefix#_Pages_Live l on p.pageID = l.pageID
			WHERE p.pageID = <cfqueryparam value="#Arguments.PageID#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfreturn getPage>	
	</cffunction>

	<cffunction name="GetTopLevelPages" description="Get all top-level pages" output="false" returntype="Query">
		<cfreturn GetChildren(0)>	
	</cffunction>

	<cffunction name="GetChildren" description="Get all children of the given page" output="false" returntype="Query">
		<cfargument name="ParentPageID" required="true" type="numeric">
		
		<cfquery name="Children" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT pageID, StatusID, MembersOnly, ShowInNav,
				case 
					when title is not null and Len(title) > 0 and title <> '<br>' then title
					when navtitle is not null and Len(navtitle) > 0 then navtitle
					else name
				end as title
			FROM #Request.dbprefix#_Pages
			WHERE parentPageID = <cfqueryparam value="#Arguments.ParentPageID#" cfsqltype="cf_sql_integer">
				<cfif Arguments.ParentPageID is 0>or ParentPageID is null</cfif>
			ORDER BY orderNum
		</cfquery>
	
		<cfreturn Children>	
	</cffunction>

	<cffunction name="GetTreeNodes" description="Get all children of the given page" output="false" returntype="Query">
		<cfargument name="ParentPageID" required="true" type="numeric">
		
		<cfquery name="nodes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT p.pageID as widgetId,
				case 
					when p.title is not null and Len(p.title) > 0 and p.title <> '<br>' then p.title
					when p.navtitle is not null and Len(p.navtitle) > 0 then p.navtitle
					else p.name
				end
				+ CASE p.membersOnly WHEN 1 THEN '<span class="indicator m">M</span>' ELSE '' END
				+ CASE p.ShowInNav WHEN 1 THEN '' ELSE '<span class="indicator h">H</span>' END
				+ CASE WHEN l.pageID is null THEN '<span class="indicator i">I</span>' ELSE '' END
				as title,
				CASE WHEN (SELECT count(*) FROM #Request.dbprefix#_Pages WHERE parentPageID = p.pageID) > 0 THEN 'true' ELSE 'false' END as isFolder
			FROM #Request.dbprefix#_Pages p LEFT JOIN #Request.dbprefix#_Pages_Live l ON p.pageID = l.pageID
			WHERE p.parentPageID = <cfqueryparam value="#Arguments.ParentPageID#" cfsqltype="cf_sql_integer">
			ORDER BY p.orderNum
		</cfquery>
	
		<cfreturn nodes>	
	</cffunction>

	<cffunction name="GetCookieCrumb" description="Generate cookie crumb for page" output="false" returnType="string">
		<cfargument name="delimiter" type="string" default="&gt; ">
		<cfset var cookieCrumbText = "">
		<cfif len(This.cookiecrumb) gt 0>
			<cfif this.version is "working">
				<cfquery name="crumbs" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT pageID as ccPageID, name as ccName, navTitle as ccNavtitle 
					FROM #Request.dbprefix#_Pages
					WHERE pageid in (<cfqueryparam value="#This.cookieCrumb#" cfsqltype="CF_SQL_INTEGER" list="yes">) 
					ORDER BY ordernum
				</cfquery>
			<cfelse>
				<cfquery name="crumbs" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT pageID as ccPageID, name as ccName, navTitle as ccNavtitle 
					FROM #Request.dbprefix#_Pages_Live
					WHERE pageid in (<cfqueryparam value="#This.cookieCrumb#" cfsqltype="CF_SQL_INTEGER" list="yes">)
					ORDER BY ordernum
				</cfquery>
			</cfif>
			<cfloop query="crumbs">
				<cfif Len(cookieCrumbText) gt 0>
					<cfset cookieCrumbText = cookieCrumbText & delimiter>
				</cfif>
				<cfset cookieCrumbText = cookieCrumbText & "<a href=""" & This.GetPageLink(ccPageID,ccName) & """>#ccNavtitle#</a>">
			</cfloop>
		</cfif>
		<cfreturn cookieCrumbText>
	</cffunction>

	<cffunction name="GetSectionName" description="Gets the page's section name." output="false" returntype="String">
		<cfreturn Application.Section.GetName(This.sectionID)>
	</cffunction>

	<cffunction name="GetPageLink" output="false" returnType="string">
		<cfargument name="pageID" type="string" required="true">
		<cfargument name="name" type="string" required="true">
		<cfif This.edit>
			<cfreturn "javascript:top.editPage(#arguments.pageID#)">
		<cfelse>
			<cfif Request.lh_useFriendlyUrls>
				<cfreturn Request.AppVirtualPath & "/" & arguments.name>
			<cfelse>
				<cfreturn Request.AppVirtualPath & "/page.cfm?pageID=" & arguments.pageID>
			</cfif>
		</cfif>
	</cffunction>
	
</cfcomponent>