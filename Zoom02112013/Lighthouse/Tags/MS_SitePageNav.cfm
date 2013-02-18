<!---

The appearance of the site navigation is designed to be controlled through the stylesheet.
The following classes are used:

ul.navMenu (main list)
li.navSelected (the selected item)
li.navChildSelected (a parent of the selected item)
li.navHighlighted (item being moused over)

Example Stylesheet for default navStyle:

<style>
/*******************/
/* Navigation menu */
/*******************/

/* main nav menu */
ul.navMenu li {
	padding:0px;
}
ul.navMenu ul li {
	padding:4px 0px;
}

/* top level list */
ul.navMenu, ul.navMenu ul {
	padding: 0px;
	margin: 0px 0px 0px 10px;
	list-style-type: none;
}
ul.navMenu * {
	color: #183477 !important;
	font-size : 11px !important;
	line-height: 20px !important;
	text-transform: uppercase;
	font-weight: bold;
}

/* 2+ level list */
ul.navMenu ul {
	margin-left: 0px;
}
ul.navMenu ul * {
	color: #5191CD !important;
	font-size: 10px !important;
	line-height: 10px !important;
	text-transform: none;
}

/* 3+ level list */
ul.navMenu ul ul {
	margin-left: 15px;
}
ul.navMenu ul ul * {
	color: #EEBD60 !important;
}

/* Show bullet for selected items */
ul.navMenu ul li.navSelected {
	padding-left: 8px;
	background-image: url(images/bullet.gif);
	background-repeat: no-repeat;
	background-position: 1px 7px;
}
</style>

--->

<cfif len(pageid) gt 0>
	<cfscript>
	// Initialize properties
	if (Not IsDefined("navShowParent")) navShowParent = true;
	if (Not IsDefined("navShowAllParents")) navShowAllParents = false;
	if (Not IsDefined("navShowSiblings")) navShowSiblings = true;
	if (Not IsDefined("navShowChildren")) navShowChildren = true;
	if (Not IsDefined("navShowLevel1")) navShowLevel1 = true;
	if (Not IsDefined("navShowAllLevel1")) navShowAllLevel1 = false;
	if (Not IsDefined("navStyle")) navStyle = 1;
	</cfscript>

	<cfquery name="nav" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT p.pageID as navPageID,
			p.name as navName,
			p.navTitle as navTitle,
			p.parentpageid as navParentPageID,
			p.pageLevel as navPageLevel,
			p.membersOnly as navMembersOnly
		FROM
			<cfif edit>
				#Request.dbprefix#_Pages p 
			<cfelse>
				#Request.dbprefix#_Pages_Live p 
			</cfif>
		WHERE (
			p.pageID = <cfqueryparam value="#pageID#" cfsqltype="CF_SQL_INTEGER">
			<cfif navShowAllParents and Len(cookieCrumb) gt 0>
				or p.parentPageID in (<cfqueryparam value="#cookieCrumb#" cfsqltype="CF_SQL_INTEGER" list="yes">)
				or p.pageID in (<cfqueryparam value="#cookieCrumb#" cfsqltype="CF_SQL_INTEGER" list="yes">)
			<cfelse>
				<cfif len(parentPageID) gt 0>
					<cfif navShowSiblings>
						or p.parentPageID = <cfqueryparam value="#parentPageID#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
					<cfif navShowParent>
						or p.pageID = <cfqueryparam value="#parentPageID#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
				</cfif>
			</cfif>
			<cfif navShowChildren>
				or p.parentPageID = <cfqueryparam value="#pageID#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif navShowAllLevel1>
				or p.pageLevel = 1
			</cfif>
			)
			<cfif not navShowLevel1>
				and p.pageLevel <> 1
			</cfif>
			and p.ShowInNav = 1

			<!--- Only show members-only pages to which the user has access, unless link is marked as public --->
			<cfif not edit>
				and (
					p.membersOnly = 0 or p.linkPublic = 1
					<cfif StructKeyExists(session,"UserID") and Len(session.userID) gt 0>
						or NOT EXISTS (SELECT * FROM #Request.dbprefix#_PageUserGroups pug WHERE pug.pageID = p.pageID)
						or EXISTS (
							SELECT * FROM #Request.dbprefix#_PageUserGroups_Live pug
							INNER JOIN #Request.dbprefix#_UserUserGroups uug on pug.userGroupID = uug.userGroupID
							WHERE pug.pageID = p.pageID and uug.userID = <cfqueryparam value="#session.userID#" cfsqltype="CF_SQL_INTEGER">
						)
					</cfif>
				)
			</cfif>
		ORDER BY p.OrderNum
	</cfquery>

	<cfoutput>
	<cfswitch expression="#navStyle#">
		<cfcase value="1">
			<cfset baseLevel = nav.navPageLevel>
			<cfset lastLevel = nav.navPageLevel>

			<ul class="navMenu">
			<cfloop query="nav">
				<!--- Open sub list.  Handle skipped levels because the parent by be hidden. --->
				<cfif navPageLevel gt lastLevel>#RepeatString("<ul><li>",navPageLevel-(lastLevel+1))#<ul>
				<!--- close sublist(s) --->
				<cfelseif navPageLevel lt lastLevel>#RepeatString("</li></ul>",lastLevel-navPageLevel)#
				<!--- close item --->
				<cfelseif currentrow gt 1></li></cfif>

				<!--- Selected item --->
				<cfif navPageID is pageID>
					<li class="navSelected"><div id="currentNavTitle" class="navSelected">#navTitle#</div>
				<!--- non-selected items --->
				<cfelse>
					<cfif ListFind(cookieCrumb,navPageID) gt 0><cfset navClass="navChildSelected"><cfelse><cfset navClass=""></cfif>
					<li class="#navClass#"><div onmouseover="this.className='navHighlighted #navClass#';" onmouseout="this.className='#navClass#';" class="#navClass#"><a href="#lh_getPageLink(navPageID,navName)#" target="_top">#navTitle#</a></div>
				</cfif>

				<cfset lastLevel = navPageLevel>
			</cfloop>
			<!--- close sublist(s) --->
			<cfif baseLevel lt lastLevel>#RepeatString("</li></ul>",lastLevel-baseLevel)#</cfif>
			</ul>
		</cfcase>

		<cfcase value="2">
			<cfset baseLevel = nav.navPageLevel>
			<cfloop query="nav">
				<cfset navClass = "navLevel" & (navPageLevel + 1 - baseLevel)>
				<cfif ListFind(cookieCrumb,navPageID) gt 0>
					<cfset navClass = navClass & " navOpen">
				</cfif>
				<cfif navPageID is pageID>
					<div class="nav navSelected #navClass#">#navTitle#</div>
				<cfelse>
					<a href="#lh_getPageLink(navPageID,navName)#" target="_top">
					<div class="nav #navClass#" ONMOUSEOVER="this.className='nav navHighlighted #navClass#';"
					ONMOUSEOUT="this.className='nav #navClass#';">#navTitle#</div></a>
				</cfif>
				<div class="navDivider"></div>
			</cfloop>
		</cfcase>
	</cfswitch>
	</cfoutput>
</cfif>