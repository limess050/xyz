<cfimport prefix="lh" taglib="../Tags">

<cfif Not IsDefined("pageID")><cfset pageID = ""></cfif>
<cfif Not IsDefined("pageArchiveID")><cfset pageArchiveID = ""></cfif>
<cfif Not IsDefined("action")><cfset action = ""></cfif>

<cfsavecontent variable="tdstyle">CLASS=TOOLBARBUTTONUP NOWRAP ONMOUSEOVER="this.className='TOOLBARBUTTONMOUSEOVER'" ONMOUSEOUT="this.className='TOOLBARBUTTONUP'" ONMOUSEDOWN="this.className='TOOLBARBUTTONDOWN'" ONMOUSEUP="this.className='TOOLBARBUTTONUP'"</cfsavecontent>
<cfset reloadPage = true>
<cfset closeWindow = false>

<cfif Len(action) gt 0>
<cflock name="savePage" type="exclusive" timeout="30">
<cftransaction>
	<cfswitch expression="#action#">
		<cfcase value="deleteVersion">
			<cfquery name="deleteArchivePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				DELETE FROM #Request.dbprefix#_Pages_Archive 
				WHERE pageArchiveID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageArchiveID#">
			</cfquery>
			<cfset pageArchiveID = "">
			<cfset reloadPage = true>
		</cfcase>

		<cfcase value="deactivateLive">
			<cfquery name="checkPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT name FROM #Request.dbprefix#_Pages_Live 
				WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
			</cfquery>

			<cfif checkpage.recordcount gt 0>
				<!--- archive live record --->
				<cfquery name="saveArchivePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					INSERT INTO #Request.dbprefix#_Pages_Archive (pageID, parentPageID, name, sectionID, title, navTitle, titleTag, metaDescription, dateModified, pageLevel, orderNum, subOrderNum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID)
					SELECT pageID, parentPageID, name, sectionID, title, navTitle, titleTag, metaDescription, dateModified, pageLevel, orderNum, subOrderNum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID
					FROM #Request.dbprefix#_Pages_Live
					WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
				</cfquery>
				<cfquery name="getID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT @@Identity as pageArchiveID
				</cfquery>
				<cfset newPageArchiveID = getID.pageArchiveID>
				<cfquery name="saveArchivePageParts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					INSERT INTO #Request.dbprefix#_PageParts_Archive (pagePartID, pageArchiveID, label, shortValue, longValue, orderNum)
					SELECT pagePartID,#newPageArchiveID#,label, shortValue, longValue, orderNum
					FROM #Request.dbprefix#_PageParts_Live
					WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
				</cfquery>

				<!--- delete live record --->
				<cfquery name="deleteLivePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					DELETE FROM #Request.dbprefix#_Pages_Live 
					WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
				</cfquery>

				<cfset Application.PageAudit.InsertRow(PageID="#pageID#",PageName="#checkpage.name#",User="#session.User#",Deactivate="1")>
				<cfset reloadPage = true>
			</cfif>
		</cfcase>

		<cfcase value="restoreAsWorking">
			<cfif Len(pageArchiveID) gt 0>
				<cfquery name="checkPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT name,title,navTitle,titleTag, metaDescription,membersOnly,linkPublic,ShowInNav,templateID,masterPageID
					FROM #Request.dbprefix#_Pages_Archive 
					WHERE pageArchiveID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageArchiveID#">
				</cfquery>

				<cfif checkpage.recordcount gt 0>

					<!--- check working record --->
					<cfquery name="checkWorking" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						SELECT count(*) as c FROM #Request.dbprefix#_Pages 
						WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
					</cfquery>

					<cfif checkWorking.c gt 0>
						<!--- insert archive record into working table --->
						<cfquery name="updateWorkingPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							UPDATE #Request.dbprefix#_Pages
							SET name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkPage.name#">,
								title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkPage.title#">,
								navTitle = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkPage.navTitle#">,
								titleTag = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkPage.titleTag#">,
								metaDescription = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkPage.metaDescription#">,
								dateModified = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
								membersOnly = <cfqueryparam cfsqltype="cf_sql_bit" value="#checkPage.membersOnly#">,
								linkPublic = <cfqueryparam cfsqltype="cf_sql_bit" value="#checkPage.linkPublic#">,
								ShowInNav = <cfqueryparam cfsqltype="cf_sql_bit" value="#checkPage.ShowInNav#">,
								templateID = <cfqueryparam cfsqltype="cf_sql_integer" value="#checkPage.templateID#" null="#IsEmpty(checkPage.templateID)#">,
								masterPageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#checkPage.masterPageID#" null="#IsEmpty(checkPage.masterPageID)#">
							WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
						</cfquery>
						<cfquery name="deleteWorkingPageParts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							DELETE FROM #Request.dbprefix#_PageParts 
							WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
						</cfquery>
					<cfelse>
						<cfquery name="insertWorkingPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							SET IDENTITY_INSERT #Request.dbprefix#_Pages ON
							INSERT INTO #Request.dbprefix#_Pages (pageID, parentPageID, name, sectionID, title, navTitle, titleTag, metaDescription, dateModified, pageLevel, orderNum, subOrderNum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID, statusID)
							SELECT pageID, parentPageID, name, sectionID, title, navTitle, titleTag, metaDescription, dateModified, pageLevel, orderNum, subOrderNum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID, #Application.Lighthouse.WorkInProgressStatus#
							FROM #Request.dbprefix#_Pages_Archive
							WHERE pageArchiveID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageArchiveID#">
							SET IDENTITY_INSERT #Request.dbprefix#_Pages OFF
						</cfquery>
					</cfif>

					<cfquery name="insertWorkingPageParts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						INSERT INTO #Request.dbprefix#_PageParts (pageID, label, shortValue, longValue, orderNum)
						SELECT #pageID#, label, shortValue, longValue, orderNum
						FROM #Request.dbprefix#_PageParts_Archive
						WHERE pageArchiveID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageArchiveID#">
					</cfquery>

					<cfset Application.PageAudit.InsertRow(PageID="#pageID#",PageName="#checkpage.name#",User="#session.User#",restoreAsWorking="1",pageArchiveID="#pageArchiveID#")>
				</cfif>
			<cfelse>
				<cfquery name="checkPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT name,title,navTitle,titleTag, metaDescription,membersOnly,linkPublic,ShowInNav,templateID,masterPageID
					FROM #Request.dbprefix#_Pages_Live 
					WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
				</cfquery>

				<cfif checkpage.recordcount gt 0>
					<!--- check working record --->
					<cfquery name="checkWorking" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						SELECT count(*) as c FROM #Request.dbprefix#_Pages 
						WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
					</cfquery>

					<!--- insert live record into working table --->
					<cfif checkWorking.c gt 0>
						<cfquery name="updateWorkingPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							UPDATE #Request.dbprefix#_Pages
							SET name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkPage.name#">,
								title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkPage.title#">,
								navTitle = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkPage.navTitle#">,
								titleTag = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkPage.titleTag#">,
								metaDescription = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkPage.metaDescription#">,
								dateModified = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
								membersOnly = <cfqueryparam cfsqltype="cf_sql_bit" value="#checkPage.membersOnly#">,
								linkPublic = <cfqueryparam cfsqltype="cf_sql_bit" value="#checkPage.linkPublic#">,
								ShowInNav = <cfqueryparam cfsqltype="cf_sql_bit" value="#checkPage.ShowInNav#">,
								templateID = <cfqueryparam cfsqltype="cf_sql_integer" value="#checkPage.templateID#" null="#IsEmpty(checkPage.templateID)#">,
								masterPageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#checkPage.masterPageID#" null="#IsEmpty(checkPage.masterPageID)#">
							WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
						</cfquery>
						<cfquery name="deleteWorkingPageParts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							DELETE FROM #Request.dbprefix#_PageParts 
							WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
						</cfquery>
					<cfelse>
						<cfquery name="insertWorkingPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							SET IDENTITY_INSERT #Request.dbprefix#_Pages ON
							INSERT INTO #Request.dbprefix#_Pages (pageID, parentPageID, name, sectionID, title, navTitle, titleTag, metaDescription, dateModified, pageLevel, orderNum, subOrderNum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID, statusID)
							SELECT pageID, parentPageID, name, sectionID, title, navTitle, titleTag, metaDescription, dateModified, pageLevel, orderNum, subOrderNum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID, #Application.Lighthouse.LiveStatus#
							FROM #Request.dbprefix#_Pages_Live
							WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
							SET IDENTITY_INSERT #Request.dbprefix#_Pages OFF
						</cfquery>
					</cfif>
					
					<cfquery name="insertWorkingPageParts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						INSERT INTO #Request.dbprefix#_PageParts (pageID, label, shortValue, longValue, orderNum)
						SELECT #pageID#, label, shortValue, longValue, orderNum
						FROM #Request.dbprefix#_PageParts_Live
						WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
					</cfquery>

					<cfset Application.PageAudit.InsertRow(PageID="#pageID#",PageName="#checkpage.name#",User="#session.User#",restoreAsWorking="1")>
				</cfif>
			</cfif>

			<cfset closeWindow = true>
		</cfcase>

		<cfcase value="restoreAsLive">
			<cfif Len(pageArchiveID) gt 0>

				<cfquery name="checkPage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					SELECT name,title,navTitle,titleTag, metaDescription,membersOnly,linkPublic,ShowInNav,templateID,masterPageID
					FROM #Request.dbprefix#_Pages_Archive 
					WHERE pageArchiveID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageArchiveID#">
				</cfquery>

				<cfif checkpage.recordcount gt 0>

					<!--- get live record --->
					<cfquery name="checkLive" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						SELECT count(*) as c FROM #Request.dbprefix#_Pages_Live 
						WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
					</cfquery>

					<cfif checkLive.c gt 0>
						<!--- archive live record --->
						<cfquery name="saveArchivePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							INSERT INTO #Request.dbprefix#_Pages_Archive (pageID, parentPageID, name, sectionID, title, navTitle, titleTag, metaDescription, dateModified, pageLevel, orderNum, subOrderNum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID)
							SELECT pageID, parentPageID, name, sectionID, title, navTitle, titleTag, metaDescription, dateModified, pageLevel, orderNum, subOrderNum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID
							FROM #Request.dbprefix#_Pages_Live
							WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
						</cfquery>
						<cfquery name="getID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							SELECT @@Identity as pageArchiveID
						</cfquery>
						<cfset newPageArchiveID = getID.pageArchiveID>
						<cfquery name="saveArchivePageParts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							INSERT INTO #Request.dbprefix#_PageParts_Archive (pagePartID, pageArchiveID, label, shortValue, longValue, orderNum)
							SELECT pagePartID,#newPageArchiveID#,label, shortValue, longValue, orderNum
							FROM #Request.dbprefix#_PageParts_Live
							WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
						</cfquery>

						<!--- insert archive record into live table --->
						<cfquery name="updateLivePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							UPDATE #Request.dbprefix#_Pages_Live
							SET name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkPage.name#">,
								title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkPage.title#">,
								navTitle = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkPage.navTitle#">,
								titleTag = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkPage.titleTag#">,
								metaDescription = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkPage.metaDescription#">,
								dateModified = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
								membersOnly = <cfqueryparam cfsqltype="cf_sql_bit" value="#checkPage.membersOnly#">,
								linkPublic = <cfqueryparam cfsqltype="cf_sql_bit" value="#checkPage.linkPublic#">,
								ShowInNav = <cfqueryparam cfsqltype="cf_sql_bit" value="#checkPage.ShowInNav#">,
								templateID = <cfqueryparam cfsqltype="cf_sql_integer" value="#checkPage.templateID#" null="#IsEmpty(checkPage.templateID)#">,
								masterPageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#checkPage.masterPageID#" null="#IsEmpty(checkPage.masterPageID)#">
							WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
						</cfquery>
						<cfquery name="deleteLivePageParts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							DELETE FROM #Request.dbprefix#_PageParts_Live 
							WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
						</cfquery>
						<cfquery name="insertLivePageParts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							INSERT INTO #Request.dbprefix#_PageParts_Live (pagePartID, pageID, label, shortValue, longValue, orderNum)
							SELECT pagePartID, #pageID#, label, shortValue, longValue, orderNum
							FROM #Request.dbprefix#_PageParts_Archive
							WHERE pageArchiveID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageArchiveID#">
						</cfquery>

					<cfelse>

						<!--- insert archive record into live table --->
						<cfquery name="insertLivePage" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							INSERT INTO #Request.dbprefix#_Pages_Live (pageID, parentPageID, name, sectionID, title, navTitle, titleTag, metaDescription, dateModified, pageLevel, orderNum, subOrderNum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID)
							SELECT pageID, parentPageID, name, sectionID, title, navTitle, titleTag, metaDescription, dateModified, pageLevel, orderNum, subOrderNum, cookieCrumb, membersOnly, linkPublic, ShowInNav, templateID, masterPageID
							FROM #Request.dbprefix#_Pages_Archive
							WHERE pageArchiveID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageArchiveID#">
						</cfquery>
						<cfquery name="insertLivePageParts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							INSERT INTO #Request.dbprefix#_PageParts_Live (pagePartID, pageID, label, shortValue, longValue, orderNum)
							SELECT pagePartID, #pageID#, label, shortValue, longValue, orderNum
							FROM #Request.dbprefix#_PageParts_Archive
							WHERE pageArchiveID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageArchiveID#">
						</cfquery>

					</cfif>

					<cfset Application.PageAudit.InsertRow(PageID="#pageID#",PageName="#checkpage.name#",User="#session.User#",restoreAsLive="1",pageArchiveID="#pageArchiveID#")>

				</cfif>

				<cfset pageArchiveID = "">
			</cfif>
			<cfset reloadPage = true>
		</cfcase>
	</cfswitch>
</cftransaction>
</cflock>
</cfif>

<!--- Get versions from database --->
<cfquery name="getVersions" maxRows="20" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT null as vPageArchiveID, dateModified FROM #Request.dbprefix#_Pages_Live 
	WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
	UNION ALL
	SELECT PageArchiveID, dateModified FROM #Request.dbprefix#_Pages_Archive 
	WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
	ORDER BY dateModified desc
</cfquery>

<cfoutput>
<html>
<head>
<cfinclude template="headerIncludes.cfm">

<script type="text/javascript">
function deleteThisPage() {
	<cfif Len(pageArchiveID)>
		if (confirm("This archived version of this page will be deleted.  Continue?")) {
			document.toolbarForm.action.value = "deleteVersion";
			document.toolbarForm.submit();
		}
	<cfelse>
		if (confirm("The live version of this page will be deactivated.  Continue?")) {
			document.toolbarForm.action.value = "deactivateLive";
			document.toolbarForm.submit();
		}
	</cfif>
}

function restoreAsWorking() {
	if (confirm("The working version of this page will be over-written.  Continue?")) {
		document.toolbarForm.action.value = "restoreAsWorking";
		document.toolbarForm.submit();
	}
}
function restoreAsLive() {
	if (confirm("The live version of this page will be moved to the archive and replace with this version.  Continue?")) {
		document.toolbarForm.action.value = "restoreAsLive";
		document.toolbarForm.submit();
	}
}

<cfif closeWindow>
	if (top.opener) {
		top.opener.top.editPage(#pageID#,true);
		top.opener.focus();
	}
	//top.close();
<cfelse>
	<cfif reloadPage>
		<cfif StructKeyExists(form,"pageArchiveID")>
			top.page.location = "../page.cfm?pageID=#pageID#&pageArchiveID=#pageArchiveID#";
		<cfelseif Len(getVersions.vPageArchiveID) gt 0>
			top.page.location = "../page.cfm?pageID=#pageID#&pageArchiveID=#getVersions.vPageArchiveID#";
		</cfif>
	<cfelseif getVersions.recordCount is 0>
		top.page.location = "../page.cfm?pageID=#pageID#&pageVersion=working";
	</cfif>
</cfif>


</script>
</head>
<body bgcolor="efefef" class=NORMALTEXT>

<form action="index.cfm?adminFunction=versionsToolbar" method="post" name="toolbarForm" id="toolbarForm" style="margin:0px;">
<input type="hidden" name="pageID" value="#pageID#">
<input type="hidden" name="action" value="">

<table cellpadding=0 cellspacing=0 border=0>
<tr valign=top>
	<td>
		<table border="1" cellspacing="0" cellpadding="0" width="100%" CLASS=TOOLBARTABLE>
		<tr align=center>
			<cfif getVersions.recordCount gt 0>
				<td #tdstyle#>
					<select name="pageArchiveID" onchange="this.form.submit()">
						<cfloop query="getVersions">
							<option value="#toString(vPageArchiveID)#"
							<cfif pageArchiveID is toString(vPageArchiveID)>selected</cfif>>
							<cfif len(vPageArchiveID) gt 0>Archived Version<cfelse>Live Version</cfif>
							(#DateFormat(dateModified,"mmmm d, yyyy")# #TimeFormat(dateModified,"h:mmtt")#)</option>
						</cfloop>
					</select>
				</td>
				<td class=TOOLBARDIVIDER><img src=#Request.AppVirtualPath#/Lighthouse/Resources/images/spacer.gif width=1 height=1></TD>
				<td #tdstyle#><a href="index.cfm?adminFunction=pages&action=Edit&pk=<cfif len(pageArchiveID) gt 0>#pageArchiveID#&version=archive<cfelse>#pageID#&version=live</cfif>" unselectable="on" class="TOOLBARLINK" target="_blank"><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/toolbar/pageproperties.gif" width=19 height=19 border=0 alt="Page Properties"></a></td>
				<td class=TOOLBARDIVIDER><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/spacer.gif" alt="" width=1 height=1></TD>
				<cfif pageArchiveID is "">
					<td #tdstyle# onclick="deleteThisPage()">Deactivate</td>
				<cfelse>
					<td #tdstyle# onclick="deleteThisPage()">Delete Version</td>
				</cfif>
				<td class=TOOLBARDIVIDER><img src=#Request.AppVirtualPath#/Lighthouse/Resources/images/spacer.gif width=1 height=1></TD>
				<td #tdstyle# onclick="restoreAsWorking()">Restore as Working</td>
				<cfif pageArchiveID is not "">
					<td class=TOOLBARDIVIDER><img src=#Request.AppVirtualPath#/Lighthouse/Resources/images/spacer.gif width=1 height=1></TD>
					<td #tdstyle# onclick="restoreAsLive()">Restore as Live</td>
				</cfif>
			<cfelse>
				<td #tdstyle# height=30>No Live or Archived versions exist&nbsp;</td>
			</cfif>

			<td class=TOOLBARDIVIDER><img src=#Request.AppVirtualPath#/Lighthouse/Resources/images/spacer.gif width=1 height=1></TD>
			<td #tdstyle# height=30 onclick="top.close()">Close Window</td>
		</tr>
		</table>
	</td>
</tr>
</table>
</form>
</cfoutput>
</body>
</html>