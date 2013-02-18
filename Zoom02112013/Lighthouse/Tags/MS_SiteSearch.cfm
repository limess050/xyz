<cfset topics = Application.Topic.GetAllActive()>

<form id="SearchForm" name="SearchForm" action="<cfoutput>#lh_getPageLink(pageID,name)#</cfoutput>" method="get">
<input id="s" name="s" type="text" size="30" maxlength="100" <cfif IsDefined("url.s")>value="<cfoutput>#HtmlEditFormat(url.s)#</cfoutput>"</cfif>>
<cfif topics.recordcount gt 0>
in
<select name="t">
	<option value="">All Topics</option>
	<cfoutput query="topics">
		<option value="#topicID#" <cfif StructKeyExists(url,"t")><cfif url.t is topicID>selected="true"</cfif></cfif>>#topic#</option>
	</cfoutput>
</select>
</cfif>
<input id="submit" type="submit" value="Go">
</form>
<cfif StructKeyExists(url,"s") or StructKeyExists(url,"t")>
	<cfset searchTitle = "case when title is null or title = '' then navTitle else title end">

	<cfif StructKeyExists(url,"s")>
		<cfset keyword1 = replace(url.s," ","%","ALL")>
		<cfset keyword2 = replace(url.s," ","%","ALL") & "[^a-z]%">
		<cfset keyword3 = "%[^a-z]" & replace(url.s," ","%","ALL")>
		<cfset keyword4 = "%[^a-z]" & replace(url.s," ","%","ALL") & "[^a-z]%">
	</cfif>

	<cfquery name="search" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT pageID as searchPageID,
			name as searchName,
			#searchTitle# as searchTitle,
			membersOnly as searchMembersOnly
			<cfif StructKeyExists(url,"s")>
				,CASE WHEN #searchTitle# like <cfqueryparam value="#keyword1#" cfsqltype="CF_SQL_VARCHAR"> THEN 1
					WHEN #searchTitle# like <cfqueryparam value="#keyword2#" cfsqltype="CF_SQL_VARCHAR"> THEN 2
					WHEN #searchTitle# like <cfqueryparam value="#keyword3#" cfsqltype="CF_SQL_VARCHAR"> THEN 3
					WHEN #searchTitle# like <cfqueryparam value="#keyword4#" cfsqltype="CF_SQL_VARCHAR"> THEN 3
					ELSE 4 END as matchLevel
			<cfelse>
				,1 as matchLevel
			</cfif>
		FROM #Request.dbprefix#_Pages_Live p
		WHERE masterPageID is null
			<cfif StructKeyExists(url,"s")>
				and (
					#searchTitle# like <cfqueryparam value="#keyword1#" cfsqltype="CF_SQL_VARCHAR">
					or #searchTitle# like <cfqueryparam value="#keyword2#" cfsqltype="CF_SQL_VARCHAR">
					or #searchTitle# like <cfqueryparam value="#keyword3#" cfsqltype="CF_SQL_VARCHAR">
					or #searchTitle# like <cfqueryparam value="#keyword4#" cfsqltype="CF_SQL_VARCHAR">
					or pageID in (
						SELECT pageID FROM #Request.dbprefix#_PageParts_Live
						WHERE shortValue like <cfqueryparam value="#keyword1#" cfsqltype="CF_SQL_VARCHAR">
							or shortValue like <cfqueryparam value="#keyword2#" cfsqltype="CF_SQL_VARCHAR">
							or shortValue like <cfqueryparam value="#keyword3#" cfsqltype="CF_SQL_VARCHAR">
							or shortValue like <cfqueryparam value="#keyword4#" cfsqltype="CF_SQL_VARCHAR">
							or longValue like <cfqueryparam value="#keyword1#" cfsqltype="CF_SQL_VARCHAR">
							or longValue like <cfqueryparam value="#keyword2#" cfsqltype="CF_SQL_VARCHAR">
							or longValue like <cfqueryparam value="#keyword3#" cfsqltype="CF_SQL_VARCHAR">
							or longValue like <cfqueryparam value="#keyword4#" cfsqltype="CF_SQL_VARCHAR">
					)
					or pageID in (
						SELECT pageID FROM #Request.dbprefix#_PageTopics_Live p
							INNER JOIN #Request.dbprefix#_Topics t ON p.topicID = t.topicID
						WHERE t.topic like <cfqueryparam value="#keyword4#" cfsqltype="CF_SQL_VARCHAR">
					)
				)
			</cfif>
			<cfif StructKeyExists(url,"t")>
				<cfif IsNumeric(url.t)>
					and pageID in (
						SELECT pageID FROM #Request.dbprefix#_PageTopics_Live
						WHERE topicID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.t#">
					)
				</cfif>
			</cfif>

			<!--- Only show members-only pages to which the user has access, unless link is marked as public --->
			and (
				membersOnly = 0 or linkPublic = 1
				<cfif Len(session.userID) gt 0>
					or NOT EXISTS (SELECT * FROM #Request.dbprefix#_PageUserGroups pug WHERE pug.pageID = p.pageID)
					or EXISTS (
						SELECT * FROM #Request.dbprefix#_PageUserGroups_Live pug
						INNER JOIN #Request.dbprefix#_UserUserGroups uug on pug.userGroupID = uug.userGroupID
						WHERE pug.pageID = p.pageID and uug.userID = <cfqueryparam value="#session.userID#" cfsqltype="CF_SQL_INTEGER">
					)
				</cfif>
			)

		ORDER BY matchLevel, pageLevel,OrderNum
	</cfquery>

	<cfset topicName = "">
	<cfif StructKeyExists(url,"t")>
		<cfif IsNumeric(url.t)>
			<cfset topic = Application.Topic.GetRow(url.t)>
			<cfif topic.recordcount gt 0>
				<cfset topicName = topic.topic>
			</cfif>
		</cfif>
	</cfif>

	<cfoutput>
	<p>Your search 
	<cfif StructKeyExists(url,"s")>for "#HtmlEditFormat(s)#"</cfif>
	<cfif Len(topicName) gt 0>in the topic "#topicName#"</cfif>
	produced #search.recordcount# result<cfif search.recordcount neq 1>s</cfif>.</p>
	</cfoutput>

	<ol class="searchResults" title="Search Results">
	<cfoutput query="search">
		<cfif StructKeyExists(url,"s")>
			<cfset href = AddQueryParamToUrl(lh_getPageLink(searchPageID,searchName),"s",url.s)>
		<cfelse>
			<cfset href = lh_getPageLink(searchPageID,searchName)>
		</cfif>
		<li	onmouseover="this.className='searchResultHighlighted';"
			onmouseout="this.className='';"
			onclick="top.location.href='#href#'"
			><a href="#href#" target="_top">#StripHtml(searchTitle)#</a></li>
	</cfoutput>
	</ol>
</cfif>
