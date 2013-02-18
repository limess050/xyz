<cfcomponent name="Lighthouse">
	
	<cfset This.WorkInProgressStatus = 1>
	<cfset This.LiveStatus = 3>
	
	<cfinclude template="../Functions/LighthouseLib.cfm">

	<cffunction name="GetAboutXml" returntype="Any" output="false">
		<cfset xmlPath = "#GetDirectoryFromPath(GetCurrentTemplatePath())#..\about.xml">
		<cffile action="read" file="#xmlPath#" variable="xmlText">
		<cfreturn XmlParse(Trim(xmlText))>
	</cffunction>

	<cffunction name="GetProductInfo" returntype="Any" output="false">
		<cfargument name="name" required="true">
		<cfset about = This.GetAboutXml()> 
		<cfset productInfo = XmlSearch(about,"/about/product[name='#Arguments.name#']")>
		<cfreturn productInfo[1]>
	</cffunction>
	
	<cffunction name="RepairPageHierarchy" returntype="void" output="false" 
		description="Sets page properties (order and level) appropriately based on parent pages.">
		<cfscript>
		pageArray = ArrayNew(1);
		orderNum = 0;
		subOrderNum = 0;
		cookieCrumb = "";
		if (Request.dbtype is "mysql") {
			useStoredProcedures = false;
		} else {
			useStoredProcedures = true;
		}
		</cfscript>
		
		<!--- Get all pages without parents --->
		<cfif useStoredProcedures is true>
			<cfstoredproc procedure="usp_#Request.dbprefix#_selectChildPages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			   <cfprocresult name="children">
			   <cfprocparam type="in" value="0" CFSQLType="CF_SQL_INTEGER">
			</cfstoredproc>
		<cfelse>
			<cfquery name="children" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT
					pageID,
					orderNum as orderNum_old,
					subOrderNum as subOrderNum_old,
					pageLevel as pageLevel_old,
					sectionID as sectionID_old,
					parentPageID as parentPageID_old,
					cookieCrumb as cookieCrumb_old
				FROM #Request.dbprefix#_Pages
				WHERE parentPageID is null or parentPageID = 0
				ORDER BY subOrderNum
			</cfquery>
		</cfif>
		
		<!--- Add pages to array with old and new values --->
		<cfloop query=children>
			<cfscript>
			subOrderNum = subOrderNum + 1;
		
			page = StructNew();
			page.pageID = pageID;
			page.orderNum_old = orderNum_old;
			page.subOrderNum_old = subOrderNum_old;
			page.subOrderNum = subOrderNum;
			page.pageLevel_old = pageLevel_old;
			page.pageLevel = 1;
			page.sectionID_old = sectionID_old;
			page.sectionID = sectionID_old;
			page.parentPageID_old = "";
			page.parentPageID = "";
			page.cookieCrumb_old = cookieCrumb_old;
			page.cookieCrumb = "";
			ArrayAppend(pageArray,page);
			</cfscript>
		</cfloop>
		
		<cfloop condition="ArrayLen(pageArray) gt 0">
			<cfscript>
			// Set orderNum for current page.
			orderNum = orderNum + 1;
			page = pageArray[1];
			foo = ArrayDeleteAt(pageArray,1);
			</cfscript>
		
			<!--- Update info for this page --->
			<cfif page.orderNum_old neq orderNum
				or page.subOrderNum_old neq page.subOrderNum
				or page.pageLevel_old neq page.pageLevel
				or page.sectionID_old neq page.sectionID
				or page.parentPageID_old neq page.parentPageID
				or page.cookieCrumb_old neq page.cookieCrumb
				>
				<cfif useStoredProcedures>
					<cftry>
					<cfstoredproc procedure="usp_#Request.dbprefix#_updatePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						<cfprocparam type="in" value="#page.pageID#" 		CFSQLType="CF_SQL_INTEGER">
						<cfprocparam type="in" value="#orderNum#" 			CFSQLType="CF_SQL_INTEGER">
						<cfprocparam type="in" value="#page.subOrderNum#" 	CFSQLType="CF_SQL_INTEGER">
						<cfprocparam type="in" value="#page.pageLevel#" 	CFSQLType="CF_SQL_INTEGER">
						<cfprocparam type="in" value="#page.sectionID#" 	CFSQLType="CF_SQL_INTEGER">
						<cfprocparam type="in" value="#page.parentPageID#"	CFSQLType="CF_SQL_INTEGER" null="#IsEmpty(page.parentPageID)#">
						<cfif len(page.cookieCrumb) gt 0>
							<cfprocparam type="in" value="#page.cookieCrumb#" 	CFSQLType="CF_SQL_VARCHAR">
						</cfif>
					</cfstoredproc>
					<cfcatch><cfoutput>
					pageid:#page.pageid#,ordernum:#ordernum#,subordernum:#page.subordernum#,pagelevel:#page.pagelevel#,sectionID:#page.sectionID#,parentPageID:#page.parentPageID#,cookiecrumb:#page.cookiecrumb#<br>
					</cfoutput></cfcatch>
					</cftry>
				<cfelse>
					<cfquery name="updatePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						UPDATE #Request.dbprefix#_Pages
						SET ordernum = <cfqueryparam cfsqltype="cf_sql_integer" value="#orderNum#">,
							subordernum = <cfqueryparam cfsqltype="cf_sql_integer" value="#page.subOrderNum#">,
							pageLevel = <cfqueryparam cfsqltype="cf_sql_integer" value="#page.pageLevel#">,
							sectionID = <cfqueryparam cfsqltype="cf_sql_integer" value="#page.sectionID#">,
							parentPageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#page.parentPageID#" null="#IsEmpty(page.parentPageID)#">,
							cookieCrumb = <cfqueryparam cfsqltype="cf_sql_varchar" value="#page.cookieCrumb#">
						WHERE PageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#page.pageID#">
					</cfquery>
					<cfquery name="updatePageLive" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						UPDATE #Request.dbprefix#_Pages_Live
						SET ordernum = <cfqueryparam cfsqltype="cf_sql_integer" value="#orderNum#">,
							subordernum = <cfqueryparam cfsqltype="cf_sql_integer" value="#page.subOrderNum#">,
							pageLevel = <cfqueryparam cfsqltype="cf_sql_integer" value="#page.pageLevel#">,
							sectionID = <cfqueryparam cfsqltype="cf_sql_integer" value="#page.sectionID#">,
							parentPageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#page.parentPageID#" null="#IsEmpty(page.parentPageID)#">,
							cookieCrumb = <cfqueryparam cfsqltype="cf_sql_varchar" value="#page.cookieCrumb#">
						WHERE PageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#page.pageID#">
					</cfquery>
					<cfquery name="updatePageArchive" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						UPDATE #Request.dbprefix#_Pages_Archive
						SET ordernum = <cfqueryparam cfsqltype="cf_sql_integer" value="#orderNum#">,
							subordernum = <cfqueryparam cfsqltype="cf_sql_integer" value="#page.subOrderNum#">,
							pageLevel = <cfqueryparam cfsqltype="cf_sql_integer" value="#page.pageLevel#">,
							sectionID = <cfqueryparam cfsqltype="cf_sql_integer" value="#page.sectionID#">,
							parentPageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#page.parentPageID#" null="#IsEmpty(page.parentPageID)#">,
							cookieCrumb = <cfqueryparam cfsqltype="cf_sql_varchar" value="#page.cookieCrumb#">
						WHERE PageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#page.pageID#">
					</cfquery>
				</cfif>
			</cfif>
		
			<!--- get children --->
			<cfif useStoredProcedures is true>
				<cfstoredproc procedure="usp_#Request.dbprefix#_selectChildPages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				   <cfprocresult name="children">
				   <cfprocparam type="in" value="#page.pageID#" CFSQLType="CF_SQL_INTEGER">
				</cfstoredproc>
			<cfelse>
				<cfquery name="children" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT
						pageID,
						orderNum as orderNum_old,
						subOrderNum as subOrderNum_old,
						pageLevel as pageLevel_old,
						sectionID as sectionID_old,
						parentPageID as parentPageID_old,
						cookieCrumb as cookieCrumb_old
					FROM #Request.dbprefix#_Pages
					WHERE parentPageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#page.pageID#">
					ORDER BY SubOrderNum
				</cfquery>
			</cfif>
		
			<!--- insert children at beginning of page array --->
			<cfscript>
			subOrderNum = 0;
			pageLevel = page.pageLevel + 1;
			sectionID = page.sectionID;
			parentPageID = page.pageID;
			cookieCrumb = ListAppend(page.cookieCrumb,page.pageID);
			</cfscript>
		
			<cfloop query=children>
				<cfscript>
				subOrderNum = subOrderNum + 1;
				page = StructNew();
				page.pageID = pageID;
				page.orderNum_old = orderNum_old;
				page.subOrderNum_old = subOrderNum_old;
				page.subOrderNum = subOrderNum;
				page.pageLevel_old = pageLevel_old;
				page.pageLevel = pageLevel;
				page.sectionID_old = sectionID_old;
				page.sectionID = sectionID;
				page.parentPageID_old = parentPageID_old;
				page.parentPageID = parentPageID;
				page.cookieCrumb_old = cookieCrumb_old;
				page.cookieCrumb = cookieCrumb;
				if (ArrayLen(pageArray) gte subOrderNum) {
					ArrayInsertAt(pageArray,subOrderNum,page);
				} else {
					ArrayAppend(pageArray,page);
				}
				</cfscript>
			</cfloop>
		</cfloop>		
	</cffunction>

	<cffunction name="getInsertedId" output="false" returntype="numeric">
		<cfquery name="getID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT @@Identity as id
		</cfquery>
		<cfreturn getID.id>
	</cffunction>

	<cffunction name="AddTable" description="Adds a table to the application." output="false" returntype="Table">
		<cfreturn CreateObject("component","Table").Init(arguments)>
	</cffunction>
	
	<cffunction name="ShowTooltip" description="Shows a tip icon that displays a tooltip on mouseover" output="true" returntype="void">
		<cfargument name="name" type="string" required="true">
		<cfargument name="tip" type="string" required="true">
		<span id="#arguments.name#Tooltip" class="helpLink">[?]</span>
		<span dojoType="tooltip" connectId="#arguments.name#Tooltip" toggle="explode">#arguments.tip#</span>
	</cffunction>

</cfcomponent>