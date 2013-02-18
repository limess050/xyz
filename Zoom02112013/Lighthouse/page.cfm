<!--- 
/Lighthouse/page.cfm
All page display logic.  Meant to be included from /page.cfm.
 --->

<!--- TODO: Use Request.Page to handle all page-related information --->
<cfobject component="#Application.ComponentPath#.Page" name="Request.Page">

<!--- Initialize page properties --->
<cfif Not IsDefined("pageID")><cfset url.pageID = ""></cfif>
<cfif Not IsDefined("pageArchiveID")><cfset pageArchiveID = ""></cfif>
<cfif Not IsDefined("name")><cfset name = "Home"></cfif>
<cfif Not IsDefined("edit")><cfset edit = false></cfif>
<cfif Not IsDefined("pageVersion")><cfset pageVersion = "live"></cfif>
<cfif Len(pageArchiveID) gt 0><cfset pageVersion = "archive"></cfif>

<!--- Log user out if cookie doesn't exist. This effectively forces a log out when the browser is closed, since cookie will expire. --->
<cfif not Edit and IsDefined('session.UserID') and Len(session.UserID) and not IsDefined("cookie.LoggedIn")>
	<cfquery name="checkAdmin" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select AdminUser
		From LH_Users
		Where UserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif not checkAdmin.AdminUser>
		<cfset lh_setClientInfo("userID","")>
		<cfset lh_setClientInfo("remote_addr","")>
		<cfset StructDelete(session,"UserID")>
		<cfset StructDelete(session,"User")>
	</cfif>
</cfif>


<!--- Initialize member properties --->
<cfif Not IsDefined("session.userID")>
	<cfset lh_getClientInfo("userID")>
</cfif>
<cfif Not StructKeyExists(session,"User")>
	<cfif len(session.userID) gt 0>
		<cfset Session.User = CreateObject("component","#Application.ComponentPath#.User").GetRow(session.UserID)>
	<cfelse>
		<cfset Session.User = CreateObject("component","#Application.ComponentPath#.User").GetRow(0)>
	</cfif>
</cfif>

<!--- if edit mode, make sure user is logged in as admin --->
<cfif edit>
	<cfif Len(session.userID) gt 0>
		<cfquery name="checkAdminLogin" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT * FROM #lighthouse_getTableName("Users")# 
			WHERE userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">
				and adminUser = 1
		</cfquery>
		<cfif checkAdminLogin.recordcount is 0>
			<cfset edit = false>
		</cfif>
	<cfelse>
		<cfset edit = false>
	</cfif>
	<cfif not edit>
		<cfset pageVersion = "live">
	</cfif>
</cfif>

<!--- Initialize miscellaneous properties --->
<cfif edit>
	<cfset pageLinkScript = Request.AppVirtualPath & "/admin/index.cfm?adminFunction=editPage&">
<cfelse>
	<cfset pageLinkScript = Request.AppVirtualPath & "/page.cfm?">
</cfif>

<!--- If user lands here from an external link that ended with "/", redirect them to the cleaned URL. --->
<cfif Right(cgi.query_string,1) is "/">
	<cflocation url="#Request.httpURL#/#name#" addToken="no">
</cfif>

<!--- Get page from database --->
<cfswitch expression="#pageVersion#">
	<cfcase value="live">
		<cfquery name="getPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT * FROM #Request.dbprefix#_Pages_Live
			WHERE <cfif Len(pageID) gt 0>pageID = <cfqueryparam value="#pageID#" cfsqltype="CF_SQL_INTEGER">
				<cfelse>
					name = <cfqueryparam value="#name#" cfsqltype="CF_SQL_VARCHAR">
					or
					name = <cfqueryparam value="#Replace(name,"-","","All")#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
		</cfquery>

		<!--- if no page found, look for archived page name --->
		<cfif getPage.recordcount is 0>
			<cfif Len(name) gt 0 and name is not "Home">
				<!--- Look for page name in archived pages, to redirect to new page, if available. --->
				<cfquery name="getNewPageName" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT pageID FROM #Request.dbprefix#_Pages_Archive
					WHERE name = <cfqueryparam value="#name#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				<cfif getNewPageName.recordCount gt 0>
					<cfquery name="getPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						SELECT * FROM #Request.dbprefix#_Pages_Live
						WHERE pageID = <cfqueryparam value="#getNewPageName.pageID#" cfsqltype="cf_sql_integer">
					</cfquery>
					<cfif getPage.recordCount gt 0>
						<cfheader statuscode="301" statustext="Moved Permanently">
						<cfheader name="Location" value="#Request.AppVirtualPath#/#lh_getUrlPageName(getPage.name)#">
						<html>
							<head>
								<title>Page Moved Permanently</title>
							</head>
							<body>
								<h1>Page Moved Permanently</h1>
								<cfoutput>
								<p>The new location of the page is: <a href="#Request.HttpUrl#/#lh_getUrlPageName(getPage.name)#">#Request.HttpUrl#/#lh_getUrlPageName(getPage.name)#</a></p>
								</cfoutput>
							</body>
						</html>
						<cfabort>
					<cfelse>
						<cfheader statuscode="410">
						<html>
							<head>
								<title>Page Gone</title>
							</head>
							<body>
								<h1>Page Gone</h1>
								<p>The requested page, "<cfoutput>#HtmlEditFormat(name)#</cfoutput>", no longer exists on this server.</p>
							</body>
						</html>
						<cfabort>
					</cfif>
				<cfelse>
					<!--- Find Parent Section  --->
					<cfquery name="findParentSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						SELECT ParentSectionID, Title
						FROM ParentSectionsView
						Where URLSafeTitle = <cfqueryparam value="#REreplace(name, "[^a-zA-Z0-9]","","all")#" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
					<cfif findParentSection.RecordCount>
						<cfquery name="getPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							SELECT * FROM #Request.dbprefix#_Pages_Live
							WHERE pageID = <cfqueryparam value="#Request.SectionOverviewPageID#" cfsqltype="CF_SQL_INTEGER">
						</cfquery>
						<cfset ParentSectionID=findParentSection.ParentSectionID>
						<cfset SectionOverviewTitle=findParentSection.Title>
						<!--- <cfif ParentSectionID is "59">
							<cflocation url="CalInDAR" addToken="No">
							<cfabort>
						</cfif> --->
					<cfelse>
						<cfquery name="findCategory" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							SELECT CategoryID, ParentSectionID
							FROM Categories
							Where (URLSafeTitle = <cfqueryparam value="#REreplace(name, "[^a-zA-Z0-9/]","","all")#" cfsqltype="CF_SQL_VARCHAR">
							<cfif Right(Trim(name),3) is "CVs">
								or URLSafeTitle + 'CVs' = <cfqueryparam value="#REreplace(name, "[^a-zA-Z0-9/]","","all")#" cfsqltype="CF_SQL_VARCHAR">
								or URLSafeTitle + 'CVs' = <cfqueryparam value="#ReplaceNoCase(REreplace(name, "[^a-zA-Z0-9/]","","all"),"jobsintanzania","","all")#" cfsqltype="CF_SQL_VARCHAR">
							</cfif>)
							and Active=1
						</cfquery>
						<cfif findCategory.RecordCount>
							<cfquery name="getPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
								SELECT * FROM #Request.dbprefix#_Pages_Live
								WHERE pageID = 2<!--- Category Page --->
							</cfquery>
							<cfset CategoryID=findCategory.CategoryID>
							<cfif findCategory.ParentSectionID is "8" and Right(Trim(name),3) is "CVs">
								<cfset JETID=2>
							<cfelseif findCategory.ParentSectionID is "8">
								<cfset JETID=1>
							</cfif>
						<cfelse>
							<cfquery name="findBusinessListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
								SELECT ListingID
								FROM ListingsView
								Where URLSafeTitle = <cfqueryparam value="#REreplace(name, "[^a-zA-Z0-9]","","all")#" cfsqltype="CF_SQL_VARCHAR">
								and DeletedAfterSubmitted=0
								and Active=1 and Reviewed=1 
								and (ListingTypeID IN (1,2,14,15,20) or ExpirationDate >= #application.CurrentDateInTZ#)
								and (Deadline is null or Deadline >= GetDate())
								and ListingTypeID in (1,2,14,20)
							</cfquery>
							<cfif findBusinessListing.RecordCount>
								<cfquery name="getPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
									SELECT * FROM #Request.dbprefix#_Pages_Live
									WHERE pageID = 3<!--- Listing Detail Page --->
								</cfquery>
								<cfset ListingID=findBusinessListing.ListingID>
							<cfelse>
								<cfheader statuscode="404">
								<cfif FileExists(Application.PhysicalPath & "\templates\404.cfm")>
									<cfinclude template="../templates/404.cfm">
								<cfelse>
									<html>
										<head>
											<title>Page Not Found</title>
										</head>
										<body>
											<h1>Page Not Found</h1>
											<p>The requested page, "<cfoutput>#HtmlEditFormat(name)#</cfoutput>", does not exist on this server.</p>
											<cfoutput><p><a href="#Request.HttpUrl#">#Request.glb_title# Home Page</a></p></cfoutput>
										</body>
									</html>
								</cfif>
								<cfabort>
							</cfif>
						</cfif>
					</cfif>					
				</cfif>
			<cfelse>
				<!--- Get first page for the site --->
				<cfquery name="getPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					<cfif Request.dbtype is "mysql">
						SELECT * FROM #Request.dbprefix#_Pages_Live ORDER BY ordernum LIMIT 1
					<cfelse>
						SELECT TOP 1 * FROM #Request.dbprefix#_Pages_Live ORDER BY ordernum
					</cfif>
				</cfquery>
			</cfif>
		</cfif>

		<cfif getPage.recordcount gt 0>
			<cfquery name="getPageParts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT label,shortValue,longValue FROM #Request.dbprefix#_PageParts_Live
				WHERE pageID = 
					<cfif Val(getPage.masterPageID) gt 0>
						<cfqueryparam value="#getPage.masterPageID#" cfsqltype="CF_SQL_INTEGER">
					<cfelse>
						<cfqueryparam value="#getPage.pageID#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
				ORDER BY orderNum
			</cfquery>
		</cfif>
	</cfcase>

	<cfcase value="working">
		<cfquery name="getPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT * FROM #Request.dbprefix#_Pages
			WHERE <cfif Len(pageID) gt 0>pageID = <cfqueryparam value="#pageID#" cfsqltype="CF_SQL_INTEGER">
				<cfelse>name = <cfqueryparam value="#name#" cfsqltype="CF_SQL_VARCHAR"></cfif>
		</cfquery>
		<cfif getPage.recordcount gt 0>
			<cfquery name="getPageParts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT label,shortValue,longValue from #Request.dbprefix#_PageParts
				WHERE pageID = <cfif Val(getPage.masterPageID) gt 0><cfqueryparam value="#getPage.masterPageID#" cfsqltype="CF_SQL_INTEGER">
					<cfelse><cfqueryparam value="#getPage.pageID#" cfsqltype="CF_SQL_INTEGER"></cfif>
				ORDER BY orderNum
			</cfquery>
		</cfif>
	</cfcase>

	<cfcase value="archive">
		<cfquery name="getPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT * FROM #Request.dbprefix#_Pages_Archive
			WHERE pageArchiveID = <cfqueryparam value="#pageArchiveID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfif getPage.recordcount gt 0>
			<cfif Val(getPage.masterPageID) gt 0>
				<cfquery name="getPageParts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT label,shortValue,longValue FROM #Request.dbprefix#_PageParts
					WHERE pageID = <cfqueryparam value="#getPage.masterPageID#" cfsqltype="CF_SQL_INTEGER">
					ORDER BY orderNum
				</cfquery>
			<cfelse>
				<cfquery name="getPageParts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT label,shortValue,longValue FROM #Request.dbprefix#_PageParts_Archive
					WHERE pageArchiveID = <cfqueryparam value="#pageArchiveID#" cfsqltype="CF_SQL_INTEGER">
					ORDER BY orderNum
				</cfquery>
			</cfif>
		</cfif>
	</cfcase>
</cfswitch>
<cfsilent>

<!--- set page properties --->
<cfif getPage.recordcount gt 0>

	<cfset variables.pageid = getPage.pageid>
	<cfset variables.parentpageID = getPage.parentpageID>
	<cfset variables.name = getPage.name>
	<cfset variables.sectionID = getPage.sectionID>
	<cfset variables.cookieCrumb = getPage.cookieCrumb>
	<cfset variables.membersOnly = getPage.membersOnly>
	<cfset variables.templateID = getPage.templateID>
	<cfset variables.masterPageID = getPage.masterPageID>
	<cfset variables.pageParts = StructNew()>

	<cfset variables.title = getPage.title>
	<cfset variables.navTitle = getPage.navTitle>
	<cfset variables.titletag = getPage.titletag>
	<cfset variables.metaDescription = getPage.metaDescription>

	<!--- get master page info --->
	<cfif Len(masterPageID) gt 0>

		<cfswitch expression="#pageVersion#">
			<cfcase value="live">
				<cfquery name="getMasterPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT templateID FROM #Request.dbprefix#_Pages_Live
					WHERE pageID = <cfqueryparam value="#masterPageID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
			</cfcase>
			<cfcase value="working,archive">
				<cfquery name="getMasterPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT templateID FROM #Request.dbprefix#_Pages
					WHERE pageID = <cfqueryparam value="#masterPageID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
			</cfcase>
		</cfswitch>
		<cfset variables.masterTemplateID = getMasterPage.templateID>
	<cfelse>
		<cfset variables.masterTemplateID = "">
	</cfif>

	<!--- set page parts --->
	<cfset variables.pageParts["TITLE"] = title>
	<cfloop query="getPageParts">
		<cfif len(shortValue) gt 0>
			<cfif StructKeyExists(variables.pageParts,label)>
				<cfset variables.pageParts[label] = variables.pageParts[label] & shortValue>
			<cfelse>
				<cfset variables.pageParts[label] = shortValue>
			</cfif>
		<cfelse>
			<cfif StructKeyExists(variables.pageParts,label)>
				<cfset variables.pageParts[label] = variables.pageParts[label] & longValue>
			<cfelse>
				<cfset variables.pageParts[label] = longValue>
			</cfif>
		</cfif>
	</cfloop>
<cfelse>
	<cfset variables.pageid = "">
	<cfset variables.parentpageID = "">
	<cfset variables.name = name>
	<cfset variables.title = "">
	<cfset variables.navTitle = "">
	<cfset variables.titletag = "">
	<cfset variables.metaDescription = "">
	<cfset variables.sectionID = "">
	<cfset variables.cookieCrumb = "">
	<cfset variables.membersOnly = 0>
	<cfset variables.templateID = 0>
	<cfset variables.pageParts = StructNew()>
</cfif>

<!--- TODO: Request.Page should replace the variables scope for page properties. --->
<cfset Request.Page.version = pageVersion>
<cfset Request.Page.pageID = variables.pageID>
<cfset Request.Page.name = variables.name>
<cfset Request.Page.sectionID = variables.sectionID>
<cfset Request.Page.cookieCrumb = variables.cookieCrumb>
<cfset Request.Page.edit = edit>

<!--- If members-only and not logged in, check for auth --->
<cfif variables.membersOnly is 1>
	<cfif StructKeyExists(url,"lh_auth")>
		<cfinclude template="Admin/checklogin.cfm">
	</cfif>
</cfif>
</cfsilent>

<!--- If category page, include queries here so the header title tag can be set granularly. --->
<cfparam name="CategoryHeaderTitle" default="">
<cfparam name="CategoryMetaDescr" default="">
<cfif IsDefined('EventCategoryID') and Len(EventCategoryID) and IsNumeric(EventCategoryID)>
	<cfset CategoryID=EventCategoryID>
</cfif>
<cfif IsDefined('CategoryID') and Len(CategoryID) and IsNumeric(CategoryID)>
	<cfinclude template="../includes/CategoryQueries.cfm">
</cfif>
<!--- If listing page, include queries here so the header title tag can be set granularly. --->
<cfparam name="ListingHeaderTitle" default="">
<cfparam name="ListingMetaDescr" default="">
<cfif IsDefined('ListingID') and Len(ListingID) and IsNumeric(ListingID)>
	<cfinclude template="../includes/ListingQueries.cfm">
</cfif>
<!--- If listing page, include queries here so the header title tag can be set granularly. --->
<cfparam name="SectionHeaderTitle" default="">
<cfparam name="SectionMetaDescr" default="">
<cfif PageID is Request.SectionOverviewPageID>
	<cfinclude template="../includes/SectionQueries.cfm">
</cfif>

<cfparam name="SectionOverviewTitle" default="">
<cfset PageBrowserTitle=Request.glb_title>
<cfif Len(ListingHeaderTitle)>
	<cfset PageBrowserTitle=ListingHeaderTitle>
<cfelseif Len(CategoryHeaderTitle)>
	<cfset PageBrowserTitle=CategoryHeaderTitle>
<cfelseif Len(SectionHeaderTitle)>
	<cfset PageBrowserTitle=SectionHeaderTitle>
<cfelseif Len(SectionOverviewTitle)>
	<cfset PageBrowserTitle=SectionOverviewTitle>
<cfelseif len(titletag) gt 0>
	<cfset PageBrowserTitle=titletag>
<cfelse>
	<cfset PageBrowserTitle=Request.glb_title & ' | '> 
	<cfif len(title) gt 0>
		<cfset PageBrowserTitle = PageBrowserTitle & title>
	<cfelse>
		<cfset PageBrowserTitle = PageBrowserTitle & navtitle>	
	</cfif>
</cfif>


<cfset PDASuffix = "">
<cfset isPDA = "false">
<cfif IsDefined("Request.PDAUserAgents") and TemplateID is "28">
	<cfloop from="1" to="#ListLen(Request.PDAUserAgents,'|')#" index="a">
		<cfif FindNoCase(ListgetAt(Request.PDAUserAgents,a,'|'),CGI.HTTP_USER_AGENT)>
			<cfset isPDA = true>
			<cfset PDASuffix = "Mobile">
			<cfbreak>
		</cfif>
	</cfloop>
</cfif>

<cfif isPDA>
	<!DOCTYPE html>
	<!--[if IEMobile 7 ]>    <html class="no-js iem7"> <![endif]-->
	<!--[if (gt IEMobile 7)|!(IEMobile)]><!--> <html class="no-js"> <!--<![endif]-->
	    <head>
			<meta charset="utf-8">
	        <meta name="description" content="">
	        <meta name="HandheldFriendly" content="True">
	        <meta name="MobileOptimized" content="320">
	        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0">
	        <meta http-equiv="cleartype" content="on">
	
	        <link rel="apple-touch-icon-precomposed" sizes="144x144" href="mobile/img/touch/apple-touch-icon-144x144-precomposed.png">
	        <link rel="apple-touch-icon-precomposed" sizes="114x114" href="mobile/img/touch/apple-touch-icon-114x114-precomposed.png">
	        <link rel="apple-touch-icon-precomposed" sizes="72x72" href="mobile/img/touch/apple-touch-icon-72x72-precomposed.png">
	        <link rel="apple-touch-icon-precomposed" href="mobile/img/touch/apple-touch-icon-57x57-precomposed.png">
	        <link rel="shortcut icon" href="mobile/img/touch/apple-touch-icon.png">
	
	        <!-- Tile icon for Win8 (144x144 + tile color) -->
	        <meta name="msapplication-TileImage" content="mobile/img/touch/apple-touch-icon-144x144-precomposed.png">
	        <meta name="msapplication-TileColor" content="##222222">
	
	
	        <!-- For iOS web apps. -->
	        <meta name="apple-mobile-web-app-capable" content="yes">
	        <meta name="apple-mobile-web-app-status-bar-style" content="black">
	        <meta name="apple-mobile-web-app-title" content="">
	
	        <link rel="stylesheet" href="mobile/css/normalize.css">
	        <link rel="stylesheet" href="mobile/css/bootstrap.min.css">
	        <link rel="stylesheet" href="mobile/css/main.css">
	        <link href='http://fonts.googleapis.com/css?family=Droid+Serif' rel='stylesheet' type='text/css'>
	
	        <script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
	        <script type="text/javascript" src='js/boostrap.min.css'></script>
		</head>
		<body>	
<cfelse>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
	<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<META NAME="country" CONTENT="Tanzania">
		<cfoutput>
		<cfif edit>
			<script type="text/javascript">var AppVirtualPath = "#Request.AppVirtualPath#";</script>
			<script type="text/javascript" src="#Request.AppVirtualPath#/Lighthouse/dojo/dojo.js"></script>
			<script type="text/javascript" src="#Request.AppVirtualPath#/Lighthouse/Resources/js/lighthouse.js"></script>
			<script type="text/javascript" src="#Request.AppVirtualPath#/Lighthouse/Resources/js/library.js"></script>
			<script type="text/javascript" src="#Request.AppVirtualPath#/Lighthouse/Resources/js/wysiwyg.js"></script>
			<cfheader name="Expires" value="#Now()#">
			<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
			<base target="_top">
		</cfif>
	<!--- <meta http-equiv="X-UA-Compatible" content="IE=7" /> --->
		<link rel=stylesheet href="#Request.AppVirtualPath#/style.css?V=#DateFormat(Now(),'mmddyyyy')#" type="text/css">
		<script language="JavaScript" src="#Request.AppVirtualPath#/Lighthouse/Resources/js/public.js" type="text/javascript"></script>
		<script language="JavaScript" src="#Request.AppVirtualPath#/public.js" type="text/javascript"></script>
		<title>#PageBrowserTitle#</title>
		<cfif Len(ListingMetaDescr)>
			<META NAME="description" CONTENT="#ListingMetaDescr#">
		<cfelseif Len(CategoryMetaDescr)>
			<META NAME="description" CONTENT="#CategoryMetaDescr#">
		<cfelseif Len(SectionMetaDescr)>
			<META NAME="description" CONTENT="#SectionMetaDescr#">
		<cfelse>		
			<META NAME="description" CONTENT="#metaDescription#">
		</cfif>
		</cfoutput>
	</head>
	<body>
		
</cfif>
<cfif Len(name)>

	<!--- if page is membersOnly, make sure user logs in --->
	<cfif (not edit and membersOnly is 1 and session.userID is "") or IsDefined("url.logout")>

		<!--- show login page --->
		<cfinclude template="../#Application.LoginTemplate#">

	<!--- include template for file.  If not found, include default template. --->
	<cfelse>
		<cfset showPage = true>

		<!--- if page is membersOnly, make sure user has access --->
		<cfif not edit and membersOnly is 1>

			<!--- get groups for the page --->
			<cfquery name="getPageGroups" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT userGroupID FROM #Request.dbprefix#_PageUserGroups_Live
				WHERE pageID = <cfqueryparam value="#pageID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>

			<!--- if page has groups defined --->
			<cfif getPageGroups.recordcount gt 0>

				<!--- check to see if user belongs to any of the groups for the page --->
				<cfquery name="checkUserGroups" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT top 1 userGroupID FROM #Request.dbprefix#_UserUserGroups
					WHERE userID = <cfqueryparam value="#session.userID#" cfsqltype="CF_SQL_INTEGER">
						and userGroupID in (<cfqueryparam value="#ValueList(getPageGroups.userGroupID)#" cfsqltype="CF_SQL_INTEGER" list="true">)
				</cfquery>

				<!--- user does not have access --->
				<cfif checkUserGroups.recordcount is 0>
					<cfif FileExists("#GetDirectoryFromPath(GetBaseTemplatePath())#templates/header.cfm")>
						<cfinclude template="../templates/header.cfm">
					</cfif>
					Your login has not been granted access to this page.
					<cfif FileExists("#GetDirectoryFromPath(GetBaseTemplatePath())#templates/footer.cfm")>
						<cfinclude template="../templates/footer.cfm">
					</cfif>
					<cfset showPage = false>
				</cfif>
			</cfif>
		</cfif>

		<cfif showPage>
			<cfif len(templateID) gt 0>
				<cfquery name="getTemplate" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT fileName FROM #Request.dbprefix#_Templates 
					WHERE templateID = <cfqueryparam cfsqltype="cf_sql_integer" value="#templateID#">
				</cfquery>

				<cfif getTemplate.recordcount gt 0>
					<cfinclude template="../templates/#Replace(getTemplate.fileName,'.','#PDASuffix#.','ALL')#">
				<cfelse>
					<cfinclude template="../templates/default#PDASuffix#.cfm">
				</cfif>
			<cfelse>
				<cfinclude template="../templates/default#PDASuffix#.cfm">
			</cfif>
		</cfif>
	</cfif>
</cfif>
<!--- <cfif not edit>
<cfoutput>#Application.GoogleAnalyticsInclude#</cfoutput>
</cfif> --->
</body>
</html>
