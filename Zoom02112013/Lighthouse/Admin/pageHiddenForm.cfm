<cfset variables.exitFrameOnFailure = true>
<cfinclude template="checkLogin.cfm">
<cfset checkPermissionFunction = "editPage">
<cfinclude template="checkPermission.cfm">
<cfsilent>
<cfimport prefix="lh" taglib="../Tags">
<cfobject component="#Application.ComponentPath#.Page" name="p">

<cffunction name="SetProperty" description="Sets the property from struct, using default if it's not defined." output="false" returntype="void">
	<cfargument name="Property" required="true" type="String">
	<cfargument name="DefaultValue" required="true" type="Any">
	<cfif IsDefined(Property)>
		<cfset p[Property] = Evaluate(property)>
	<cfelse>
		<cfset p[Property] = DefaultValue>
	</cfif>
</cffunction>

<!--- If there is no form information, try to load saved form scope. 
	Form scope is saved on the login page if the form is submitted after a session has expired. --->
<cfif StructCount(form) is 0 and not StructKeyExists(url,"pageID")>
	<cfif StructKeyExists(session,"SavedFormScope")>
		<cfset StructAppend(form,session.SavedFormScope)>
	</cfif>
</cfif>

<cfset SetProperty("pageID","")>
<cfset SetProperty("name","Home")>
<cfset p.name = REReplace(LCase(p.name),"[^0-9a-z-_/]","","ALL")>
<cfset SetProperty("navtitle",p.name)>
<cfif IsDefined("PAGEPART_TITLE")>
	<cfset p.title = form.PAGEPART_TITLE>
<cfelseif IsDefined("title")>
	<cfset p.title = title>
<cfelse>
	<cfset p.title = p.navtitle>
</cfif>
<cfset SetProperty("sectionID",0)>
<cfset SetProperty("sectionID",0)>
<cfset SetProperty("templateID","")>
<cfset SetProperty("parentPageID","")>
<cfset SetProperty("subordernum","999")>
<cfset SetProperty("statusID",Application.Lighthouse.WorkInProgressStatus)>
<cfif Len(p.statusID) is 0><cfset p.statusID = Application.Lighthouse.WorkInProgressStatus></cfif>
<cfset SetProperty("membersOnly",0)>
<cfset SetProperty("titleTag","")>
<cfset SetProperty("metaDescription","")>
<cfset SetProperty("topics","")>
<!--- linkPublic and userGroupID currently only used for adding new pages --->
<cfset SetProperty("linkPublic",0)>
<cfset SetProperty("ShowInNav",0)>
<cfset SetProperty("userGroupID","")>
<cfset SetProperty("dateModified","")>

<cfparam name="savePage" default="false">
<cfparam name="deletePage" default="false">
<cfparam name="deleteVersion" default="false">
<cfparam name="movePage" default="false">
<cfparam name="reloadPage" default="false">
<cfparam name="reloadTop" default="false">
<cfparam name="runInit" default="false">
<cfparam name="newPage" default="false">
<cfparam name="deactivateLive" default="false">

<!--- 
set the length of the long database value
64000 is used if db column is type text (32000 for ntext) because ColdFusion by default does return values longer than 64k from database.
It is possible to over-ride this setting in the CF administrator, but that's often not possible on shared systems 
--->
<cfset longValueCharLimit = 32000>

<cfif savePage>
<cflock name="#Request.dbprefix#_savePage" type="exclusive" timeout="30">
<cftransaction>
<cftry>

	<cfif deletePage>

		<cfif p.delete()>
			<cfif Len(parentPageID) gt 0>
				<cfquery name="getPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT name FROM #Request.dbprefix#_Pages 
					WHERE pageid = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.parentPageID#">
				</cfquery>
				<cfset p.pageID = parentPageID>
			<cfelse>
				<cfset p.pageID = "">
			</cfif>
	
			<cfset dateModified = "">
			<cfset reloadTop = true>
		</cfif>

	<cfelse>

		<!--- check to see if page name exists --->
		<cfquery name="checkpage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT * FROM #Request.dbprefix#_Pages
			WHERE 
			<cfif Len(p.pageID) gt 0>
				pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
			<cfelse>
				name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#p.name#">
			</cfif>
		</cfquery>
		<cfif checkpage.recordcount gt 0>
			<cfset foundPage = true>
			<cfset pageID = checkpage.pageID>
			<cfset name = checkpage.name>
		<cfelse>
			<cfset foundPage = false>
		</cfif>

		<!--- if creating a new page, make the name unique if it isn't already --->
		<cfif newPage>
			<cfloop condition="foundPage">
				<cfset foo = REFind("(.+)([0-9]+)$",name,1,true)>
				<cfif ArrayLen(foo.len) gt 1>
					<cfset num = Mid(p.name,foo.pos[3],foo.len[3])>
					<cfset newNum = num + 1>
					<cfset p.name = Mid(p.name,foo.pos[2],foo.len[2]) & newNum>
				<cfelse>
					<cfset p.name = p.name & "2">
				</cfif>
				<cfquery name="checkpage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT * FROM #Request.dbprefix#_Pages 
					WHERE name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#p.name#">
				</cfquery>
				<cfif checkpage.recordcount gt 0>
					<cfset foundPage = true>
				<cfelse>
					<cfset foundPage = false>
				</cfif>
			</cfloop>
			<cfset insertPage = true>
		<cfelse>
			<cfif foundPage>
				<cfset insertPage = false>
			<cfelse>
				<cfset insertPage = true>
			</cfif>
		</cfif>

		<cfif insertPage>

			<!--- get order number for page --->
			<cfquery name="getOrder" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT max(orderNum) as o FROM #Request.dbprefix#_Pages 
				WHERE sectionID = <cfqueryparam cfsqltype="cf_sql_integer" value="0#p.sectionID#">
			</cfquery>
			<cfif Len(getOrder.o)>
				<cfset orderNum = getOrder.o + 1>
			<cfelse>
				<cfset orderNum = 1>
			</cfif>

			<!--- do insert --->
			<cfquery name="savepage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				INSERT INTO #Request.dbprefix#_Pages (
					parentpageid,
					subordernum,
					name,
					title,
					navtitle,
					sectionID,
					orderNum,
					statusID,
					membersOnly,
					linkPublic,
					ShowInNav,
					templateID,
					dateModified)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_integer" value="#p.parentpageID#" null="#IsEmpty(parentpageid)#">,
					<cfqueryparam cfsqltype="cf_sql_real" value="#p.subordernum#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#p.name#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#p.title#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#p.navtitle#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="0#p.sectionID#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#orderNum#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#p.statusID#">,
					<cfqueryparam cfsqltype="cf_sql_bit" value="#p.membersOnly#">,
					<cfqueryparam cfsqltype="cf_sql_bit" value="#p.linkPublic#">,
					<cfqueryparam cfsqltype="cf_sql_bit" value="#p.ShowInNav#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#p.templateID#" null="#IsEmpty(p.templateID)#">,
					#Now()#
				)
			</cfquery>
			<!--- get page id --->
			<cfset p.pageID = Application.Lighthouse.getInsertedId()>

			<!--- insert user groups --->
			<cfif p.userGroupID is not "">
				<cfquery name="insertUserGroups" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					INSERT INTO #Request.dbprefix#_PageUserGroups (pageID,userGroupID)
					SELECT #p.pageID#,userGroupID 
					FROM #Request.dbprefix#_UserGroups
					WHERE userGroupID IN (<cfqueryparam value="#p.userGroupID#" cfsqltype="CF_SQL_INTEGER" list="yes">)
				</cfquery>
			</cfif>

			<!--- look for page part values in form --->
			<cfif IsDefined("fieldNames")>
				<cfloop index="key" list="#fieldNames#">
					<cfif Find("PAGEPART_",key)>
						<cfset value = form[key]>
						<cfset label = Replace(key,"PAGEPART_","")>
						<cfif label is not "TITLE">
							<cfif len(value) gt 255>
								<cfset ind = 1>
								<cfset orderNum = 0>
								<!--- For long values, loop through text and break it into pieces --->
								<cfloop condition = "len(value) - ind gt 0">
									<cfset longValue = Mid(value,ind,longValueCharLimit)>
									<cfset ind = ind + longValueCharLimit>
									<cfset orderNum = orderNum + 1>
									<cfquery name="savePagePart" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
										INSERT INTO #Request.dbprefix#_PageParts (pageID,label,longValue,orderNum)
										VALUES (
											<cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">,
											<cfqueryparam cfsqltype="cf_sql_varchar" value="#label#">,
											<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#longValue#">,
											<cfqueryparam cfsqltype="cf_sql_integer" value="#orderNum#">
										)
									</cfquery>
								</cfloop>

							<cfelse>
								<cfquery name="savePagePart" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
									INSERT INTO #Request.dbprefix#_PageParts (pageID,label,shortValue)
									VALUES (
										<cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">,
										<cfqueryparam cfsqltype="cf_sql_varchar" value="#label#">,
										<cfqueryparam cfsqltype="cf_sql_varchar" value="#value#">
									)
								</cfquery>
							</cfif>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>

			<cfset Application.PageAudit.InsertRow(PageID="#p.pageID#",PageName="#p.name#",User="#session.User#",Insert="1")>
			<cfset reloadPage = true>
		<cfelse>

			<!--- If moving page, make sure we haven't created a paradox (pages that are each others parents) --->
			<cfif movePage and Len(parentPageID) gt 0>
				<cfquery name="checkparent" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT * FROM #Request.dbprefix#_Pages 
					WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.parentpageID#">
				</cfquery>
				<cfloop condition="checkparent.pagelevel gt 1 and Len(checkparent.parentPageID) gt 0">
					<cfif checkpage.pageid is checkparent.parentPageID>
						<cfquery name="UPDATEparent" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							UPDATE #Request.dbprefix#_Pages
							SET parentPageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#checkPage.parentPageID#">
							WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.parentpageID#">
						</cfquery>
						<cfbreak>
					</cfif>
					<cfquery name="checkparent" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						SELECT * FROM #Request.dbprefix#_Pages 
						WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#checkparent.parentPageID#">
					</cfquery>
				</cfloop>
			</cfif>

			<!--- update page --->
			<cfquery name="savepage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				UPDATE #Request.dbprefix#_Pages
				SET name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#p.name#">,
					title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#p.title#">,
					navtitle = <cfqueryparam cfsqltype="cf_sql_varchar" value="#p.navtitle#">,
					sectionID = <cfqueryparam cfsqltype="cf_sql_integer" value="0#p.sectionID#">,
					templateID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.templateID#" null="#IsEmpty(p.templateID)#">,
					parentPageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.parentpageID#" null="#IsEmpty(p.parentPageID)#">,
					subordernum = <cfqueryparam cfsqltype="cf_sql_real" value="0#p.subordernum#">,
					statusID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.statusID#">,
					membersOnly = <cfqueryparam cfsqltype="cf_sql_bit" value="#p.membersOnly#">,
					linkPublic = <cfqueryparam cfsqltype="cf_sql_bit" value="#p.linkPublic#">,
					showInNav = <cfqueryparam cfsqltype="cf_sql_bit" value="#p.showInNav#">,
					titleTag = <cfqueryparam cfsqltype="cf_sql_varchar" value="#p.titleTag#">,
					metaDescription = <cfqueryparam cfsqltype="cf_sql_varchar" value="#p.metaDescription#">,
					dateModified = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">
				WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
			</cfquery>

			<!--- look for page part values in form --->
			<cfloop index="key" list="#fieldNames#">
				<cfif Find("PAGEPART_",key)>
					<cfset value = form[key]>
					<cfset label = Replace(key,"PAGEPART_","")>
					<cfif label is not "TITLE">
						<cfif len(value) gt 255>
							<cfset ind = 1>
							<cfset orderNum = 0>
							<!--- For long values, loop through text and break it into pieces --->
							<cfloop condition = "len(value) - ind gt 0">
								<cfset longValue = Mid(value,ind,longValueCharLimit)>
								<cfset ind = ind + longValueCharLimit>
								<cfset orderNum = orderNum + 1>

								<!--- if page part already exists, UPDATE it.  otherwise, insert --->
								<cfquery name="checkPagePart" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
									SELECT pagePartID FROM #Request.dbprefix#_PageParts 
									WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#"> 
										and label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#label#"> 
										and orderNum = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#orderNum#">
								</cfquery>
								<cfif checkPagePart.recordcount gt 0>
									<cfquery name="savePagePart" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
										UPDATE #Request.dbprefix#_PageParts
										SET pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#"> ,
											label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#label#">,
											shortValue = null,
											longValue = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#longValue#">,
											orderNum = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#orderNum#">
										WHERE pagePartID = #checkpagepart.pagePartID#
									</cfquery>
								<cfelse>
									<cfquery name="savePagePart" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
										INSERT INTO #Request.dbprefix#_PageParts (pageID,label,longValue,orderNum)
										VALUES (
											<cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">,
											<cfqueryparam cfsqltype="cf_sql_varchar" value="#label#">,
											<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#longValue#">,
											<cfqueryparam cfsqltype="cf_sql_tinyint" value="#orderNum#">
										)
									</cfquery>
								</cfif>

							</cfloop>

							<!--- delete and records with higher order numbers --->
							<cfquery name="deletePagePart" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
								DELETE FROM #Request.dbprefix#_PageParts
								WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#"> 
									and label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#label#">
									and (
										orderNum > <cfqueryparam cfsqltype="cf_sql_integer" value="#orderNum#"> 
										or orderNum is null
									)
							</cfquery>

						<cfelse>

							<!--- if page part already exists, UPDATE it.  otherwise, insert --->
							<cfquery name="checkPagePart" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
								SELECT pagePartID FROM #Request.dbprefix#_PageParts 
								WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#"> 
									and label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#label#">
							</cfquery>
							<cfif checkPagePart.recordcount gt 0>
								<cfquery name="savePagePart" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
									UPDATE #Request.dbprefix#_PageParts
									SET pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">,
										label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#label#">,
										shortValue = <cfqueryparam cfsqltype="cf_sql_varchar" value="#value#">,
										longValue = null
									WHERE pagePartID = <cfqueryparam cfsqltype="cf_sql_integer" value="#checkpagepart.pagePartID#">
								</cfquery>
							<cfelse>
								<cfquery name="savePagePart" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
									INSERT INTO #Request.dbprefix#_PageParts (pageID,label,shortValue)
									VALUES (
										<cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">,
										<cfqueryparam cfsqltype="cf_sql_varchar" value="#label#">,
										<cfqueryparam cfsqltype="cf_sql_varchar" value="#value#">
									)
								</cfquery>
							</cfif>

							<!--- delete and records with higher order numbers --->
							<cfquery name="deletePagePart" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
								DELETE FROM #Request.dbprefix#_PageParts
								WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#"> 
									and label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#label#"> 
									and orderNum > 1
							</cfquery>
						</cfif>
					</cfif>
				</cfif>
			</cfloop>
			
			<!--- Page Topics --->
			<cfquery name="deleteTopics" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				DELETE FROM #Request.dbprefix#_PageTopics
				WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
			</cfquery>
			<cfif Len(p.topics) gt 0>
				<cfset topicsArray = Application.Json.decode(p.topics)>
				<!--- Insert new topics --->
				<cfloop index="i" from="1" to="#ArrayLen(topicsArray)#">
					<cfset topicArray = topicsArray[i]>
					<cfif Len(topicArray[1]) is 0>
						<cfquery name="checkTopic" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							SELECT topicID FROM #Request.dbprefix#_Topics
							WHERE topic = <cfqueryparam cfsqltype="cf_sql_varchar" value="#topicArray[2]#">
						</cfquery>
						<cfif checkTopic.recordCount is 0>
							<cfquery name="insertTopic" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
								INSERT INTO #Request.dbprefix#_Topics (topic)
								VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#topicArray[2]#">)
							</cfquery>
							<cfset topicArray[1] = Application.Lighthouse.getInsertedId()>
						<cfelse>
							<cfset topicArray[1] = checkTopic.topicID>
						</cfif>
					</cfif>
					<cfquery name="insertTopics" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						INSERT INTO #Request.dbprefix#_PageTopics (pageID,topicID)
						VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#topicArray[1]#">)
					</cfquery>
				</cfloop>
			</cfif>

			<!--- update user groups --->
			<cfif p.userGroupID is not "">
				<cfquery name="insertUserGroups" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					INSERT INTO #Request.dbprefix#_PageUserGroups (pageID,userGroupID)
					SELECT #p.pageID#,userGroupID 
					FROM #Request.dbprefix#_UserGroups
					WHERE userGroupID IN (<cfqueryparam value="#p.userGroupID#" cfsqltype="CF_SQL_INTEGER" list="yes">)
						AND userGroupID NOT IN (
							SELECT userGroupID FROM #Request.dbprefix#_PageUserGroups
							WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
						)
				</cfquery>
			</cfif>
			<cfquery name="insertUserGroups" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				DELETE FROM #Request.dbprefix#_PageUserGroups
				WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
				<cfif p.userGroupID is not "">
					AND userGroupID NOT IN (<cfqueryparam value="#p.userGroupID#" cfsqltype="CF_SQL_INTEGER" list="yes">)
				</cfif>
			</cfquery>

			<cfset Application.PageAudit.InsertRow(PageID="#p.pageID#",PageName="#p.name#",User="#session.User#",StatusID="#p.statusID#")>

			<!--- handle pushing live and deactivation --->
			<cfif deactivateLive or statusID is Application.Lighthouse.LiveStatus>
				<!--- get live record --->
				<cfquery name="checkLive" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT count(*) as c FROM #Request.dbprefix#_Pages_Live 
					WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
				</cfquery>

				<cfif checkLive.c gt 0>
					<!--- archive live record --->
					<cfquery name="saveArchivePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						INSERT INTO #Request.dbprefix#_Pages_Archive (pageID, parentPageID, name, sectionID, title, navTitle, titleTag, metaDescription, dateModified, pageLevel, orderNum, subOrderNum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID)
						SELECT pageID, parentPageID, name, sectionID, title, navTitle, titleTag, metaDescription, dateModified, pageLevel, orderNum, subOrderNum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID
						FROM #Request.dbprefix#_Pages_Live
						WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
					</cfquery>
					<cfquery name="getID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						SELECT @@Identity as pageArchiveID
					</cfquery>
					<cfset pageArchiveID = getID.pageArchiveID>
					<cfquery name="saveArchivePageParts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						INSERT INTO #Request.dbprefix#_PageParts_Archive (pagePartID, pageArchiveID, label, shortValue, longValue, orderNum)
						SELECT pagePartID,<cfqueryparam cfsqltype="cf_sql_integer" value="#pageArchiveID#">,label, shortValue, longValue, orderNum
						FROM #Request.dbprefix#_PageParts_Live
						WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
					</cfquery>
					<cfquery name="saveArchivePageTopics" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						INSERT INTO #Request.dbprefix#_PageTopics_Archive (pageArchiveID, topicID)
						SELECT <cfqueryparam cfsqltype="cf_sql_integer" value="#pageArchiveID#">,topicID
						FROM #Request.dbprefix#_PageTopics_Live
						WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
					</cfquery>

					<!--- delete live record --->
					<cfquery name="deleteLivePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						DELETE FROM #Request.dbprefix#_PageParts_Live 
						WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
					</cfquery>
					<cfquery name="deleteLivePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						DELETE FROM #Request.dbprefix#_PageTopics_Live 
						WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
					</cfquery>
					<cfquery name="deleteLivePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						DELETE FROM #Request.dbprefix#_PageUserGroups_Live 
						WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
					</cfquery>
					<cfquery name="deleteLivePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						DELETE FROM #Request.dbprefix#_Pages_Live 
						WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
					</cfquery>
				</cfif>

				<cfif statusID is Application.Lighthouse.LiveStatus>
					<!--- move working record live --->
					<cfquery name="saveLivePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						INSERT INTO #Request.dbprefix#_Pages_Live (pageID, parentPageID, name, sectionID, title, navTitle, titleTag, metaDescription, dateModified, pageLevel, orderNum, subOrderNum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID)
						SELECT pageID, parentPageID, name, sectionID, title, navTitle, titleTag, metaDescription, dateModified, pageLevel, orderNum, subOrderNum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID
						FROM #Request.dbprefix#_Pages
						WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
					</cfquery>
					<cfquery name="saveLivePageParts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						INSERT INTO #Request.dbprefix#_PageParts_Live (pagePartID, pageID, label, shortValue, longValue, orderNum)
						SELECT pagePartID, pageID,label, shortValue, longValue, orderNum
						FROM #Request.dbprefix#_PageParts
						WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
					</cfquery>
					<cfquery name="saveLivePageTopics" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						INSERT INTO #Request.dbprefix#_PageTopics_Live (pageID, topicID)
						SELECT pageID, topicID
						FROM #Request.dbprefix#_PageTopics
						WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
					</cfquery>
					<cfquery name="saveLiveUserGroups" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						INSERT INTO #Request.dbprefix#_PageUserGroups_Live (pageID, userGroupID)
						SELECT pageID, userGroupID
						FROM #Request.dbprefix#_PageUserGroups
						WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
					</cfquery>
				</cfif>
			</cfif>
		</cfif>

		<cfset runInit = true>

		<cfif checkpage.sectionid is not p.sectionid
			or checkpage.templateid is not p.templateid
			or checkpage.statusID is not p.statusID
			or checkpage.membersOnly is not p.membersOnly
			or checkpage.parentPageID is not p.parentPageID
			or checkpage.subordernum is not p.subordernum>
			<cfset reloadPage = true>
		</cfif>

		<cfif checkpage.sectionid is not p.sectionid
			or checkpage.parentPageID is not p.parentPageID
			or checkpage.subordernum is not p.subordernum>
			<cfset Application.Lighthouse.RepairPageHierarchy()>
		</cfif>
	</cfif>

	<!--- This does not seem to current work with mysql 4.1, even with InnoDB tables.  Probably will work at some point --->
	<cfif Request.dbtype is not "mysql">
		<cftransaction action="commit"/>
	</cfif>

	<cfcatch>
		<cftransaction action="rollback"/>
		<cfrethrow>
	</cfcatch>

</cftry>
</cftransaction>
</cflock>
</cfif>

<!--- Get page from database --->
<cfquery name="getPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT p.*,
		t.name as templateName, 
		s.descr as statusName,
		CASE WHEN l.pageID is null THEN 'No' ELSE 'Yes' END as LiveExists
	FROM #Request.dbprefix#_Pages p 
		LEFT JOIN #Request.dbprefix#_Templates t on p.templateID = t.templateID
		LEFT JOIN #Request.dbprefix#_Statuses s on p.statusID = s.statusID
		LEFT JOIN #Request.dbprefix#_Pages_Live l on p.pageID = l.pageID
	WHERE 
		<cfif Len(p.pageID) gt 0>
			p.pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
		<cfelse>
			p.name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#p.name#">
		</cfif>
</cfquery>

<!--- set page properties --->
<cfif getPage.recordcount gt 0>
	<cfset p.pageid = getPage.pageid>
	<cfset p.name = getPage.name>
	<cfset p.sectionID = getPage.sectionID>
	<cfset p.parentPageID = getPage.parentPageID>
	<cfset p.subordernum = getPage.subordernum>
	<cfset p.statusID = getPage.statusID>
	<cfset p.membersOnly = getPage.membersOnly>
	<cfset p.linkPublic = getPage.linkPublic>
	<cfset p.titleTag = getPage.titleTag>
	<cfset p.metaDescription = getPage.metaDescription>
	<cfset p.templateID = getPage.templateID>
	<cfset p.newPage = false>
	<cfset p.masterPageID = getPage.masterPageID>
	<cfset p.CanDelete = getPage.CanDelete>
	<cfset p.title = getPage.title>
	<cfset p.navTitle = getPage.navTitle>
	<cfset p.templateName = getPage.templateName>
	<cfset p.statusName = getPage.statusName>
	<cfset p.LiveExists = getPage.LiveExists>
	<cfset p.showInNav = getPage.showInNav>
	<cfset p.cookieCrumb = getPage.cookiecrumb>

	<!--- If status is live, status will be work-in-progress if the page is edited --->
	<cfif p.statusID is Application.Lighthouse.LiveStatus>
		<cfset p.statusID = Application.Lighthouse.WorkInProgressStatus>
	</cfif>
	
	<!--- Get topics for page --->
	<cfquery name="getTopics" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT pt.topicID,t.topic 
		FROM #Request.dbprefix#_PageTopics pt INNER JOIN #Request.dbprefix#_Topics t ON pt.topicID = t.topicID
		WHERE pt.pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
		ORDER BY t.topic
	</cfquery>
	<cfsavecontent variable="p.topics">[<cfoutput query="getTopics"><cfif currentRow gt 1>,</cfif>["#JSStringFormat(topicid)#","#JSStringFormat(topic)#"]</cfoutput>]</cfsavecontent>
	
	<!--- Get UserGroups for page --->
	<cfquery name="getUserGroups" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT UserGroupID FROM #Request.dbprefix#_PageUserGroups
		WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
	</cfquery>
	<cfset p.userGroupID = ValueList(getUserGroups.userGroupID)>

<cfelse>

	<!--- If archived pages exist, go to versions --->
	<cfif Len(pageID) gt 0>
		<cfquery name="getLiveForDeleted" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT pageID
			FROM #Request.dbprefix#_Pages_Live
			WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
		</cfquery>
		<cfif getLiveForDeleted.recordCount is 0>
			<cfquery name="getArchivedForDeleted" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT top 1 pageID,pageArchiveID
				FROM #Request.dbprefix#_Pages_Archive
				WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#p.pageID#">
				ORDER BY dateModified desc
			</cfquery>
		</cfif>
	</cfif>

	<cfset p.pageid = "">
	<cfset p.title = "">
	<cfset p.navTitle = "">
	<cfset p.statusID = "">
	<cfset p.membersOnly = 0>
	<cfset p.titleTag = "">
	<cfset p.templateID = "">
	<cfset p.newPage = true>
	<cfset p.CanDelete = 1>
	<cfset p.templateName = "">
	<cfset p.statusName = "">
	<cfset p.LiveExists = "">
	<cfset p.topics = "">
	<cfset p.cookiecrumb = "">
</cfif>
</cfsilent>
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<cfinclude template="headerIncludes.cfm">
<script type="text/javascript">
var p = new lh.Page(#Application.json.encode(p)#);
var reloadPage = #reloadPage#;
var reloadTop = #reloadTop#;
var runInit = #runInit#;

<!--- If archived pages exist, go to versions --->
<cfif IsDefined("getLiveForDeleted")>
	<cfif getLiveForDeleted.recordCount gt 0>
		if (confirm("The working version of the requested page no longer exists.\n\nWould you like to view and/or restore the live version of the page?")) {
			window.open(AppVirtualPath + "/Admin/index.cfm?adminFunction=versionsView&pageID=#getLiveForDeleted.pageID#");
		}
	<cfelseif getArchivedForDeleted.recordCount gt 0>
		if (confirm("The working version of the requested page no longer exists.\n\nWould you like to view and/or restore archived versions of the page?")) {
			window.open(AppVirtualPath + "/Admin/index.cfm?adminFunction=versionsView&pageID=#getArchivedForDeleted.pageID#&pageArchiveID=#getArchivedForDeleted.pageArchiveID#");
		}
	<cfelse>
		alert("The requested page no longer exists.");
	</cfif>
</cfif>

//If not in editor (can happen at login), refresh top location
if (!top.setPageStatus){
	top.location = AppVirtualPath + "/Admin/index.cfm?adminFunction=editPage&pageID=" + p.PAGEID;
}

xAddEvent(window,"load",function(){
	top.setPageStatus("Loading page.");

	top.setPageProperties(p);
	if (reloadPage||reloadTop){
		top.refreshPageTree();
	}
	if (reloadTop) {
		top.editPage(#p.pageID#);
	}
	try {
		top.selectPage();
	} catch(e){}
	//Load page, if necessary
	var pageSearch = "?pageID=#p.pageID#&edit=true&pageVersion=working";
	if (reloadPage || (top.getEl("page") && top.getEl("page").contentWindow.location.search != pageSearch)){
		top.getEl("page").contentWindow.location.replace("#Request.AppVirtualPath#/page.cfm" + pageSearch);
	} else {
		top.finalizePage("");
	}

	if (p.PAGEID.length > 0) {
		top.getEl("propertiesButton").style.display = "";
		top.getEl("propertiesSeperator").style.display = "";
	} else {
		top.getEl("propertiesButton").style.display = "none";
		top.getEl("propertiesSeperator").style.display = "none";
	}
	if (p.CANDELETE == "1") {
		top.getEl("deleteButton").style.display = "";
		top.getEl("deleteSeperator").style.display = "";
	} else {
		top.getEl("deleteButton").style.display = "none";
		top.getEl("deleteSeperator").style.display = "none";
	}
});
</script>
<style>
body {background-color:##EFEFEF;}
</style>
</head>
<body>
<form action="#Request.AppVirtualPath#/Lighthouse/Admin/pageHiddenForm.cfm" method="post" name="toolbarForm" id="toolbarForm">
<input type="hidden" id="pageid" name="pageid" value="#p.pageID#">
<input type="hidden" id="navtitle" name="navtitle" value="#p.navtitle#">
<input type="hidden" id="statusID" name="statusID" value="#p.statusID#">
<input type="hidden" id="membersOnly" name="membersOnly" value="#p.membersOnly#">
<input type="hidden" id="linkPublic" name="linkPublic" value="#p.linkPublic#">
<input type="hidden" id="sectionid" name="sectionid" value="#p.sectionID#">
<input type="hidden" id="parentpageid" name="parentpageid" value="#p.parentpageID#">
<input type="hidden" id="subordernum" name="subordernum" value="#p.subordernum#">
<input type="hidden" id="templateID" name="templateID" value="#p.templateID#">
<input type="hidden" id="showInNav" name="showInNav" value="#p.showInNav#">
<input type="hidden" id="titleTag" name="titleTag" value="#p.titleTag#">
<input type="hidden" id="metaDescription" name="metaDescription" value="#HtmlEditFormat(p.metaDescription)#">
<input type="hidden" id="topics" name="topics" value="#HtmlEditFormat(p.topics)#">
<input type="hidden" id="userGroupID" name="userGroupID" value="#p.userGroupID#">

<input type="hidden" name="savePage" value="true">
<input type="hidden" name="deletePage" value="false">
<input type="hidden" name="deleteVersion" value="false">
<input type="hidden" name="movePage" value="false">
<input type="hidden" name="deactivateLive" value="false">
</form>
</cfoutput>
</body>
</html>