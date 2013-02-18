<cfinclude template="checkLogin.cfm">
<cfinclude template="checkPermission.cfm">
<cfimport prefix="lh" taglib="../Tags">
<cfobject component="#Application.ComponentPath#.Page" name="p">
<cfset top = p.GetTopLevelPages()>
<cfparam name="url.pageID" default="1">
<cfset tdstyle = "CLASS=TOOLBARBUTTONUP ONMOUSEOVER=""this.className='TOOLBARBUTTONMOUSEOVER'"" ONMOUSEOUT=""this.className='TOOLBARBUTTONUP'"" ONMOUSEDOWN=""this.className='TOOLBARBUTTONDOWN'"" ONMOUSEUP=""this.className='TOOLBARBUTTONUP'""">
<cfparam name="pageID" default="">
<cfset UserGroups = Application.UserGroup.GetAll()>
<cfset Statuses = Application.Status.GetForUser(session.User.UserID)>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Content Administration</title>
<cfoutput>
<script type="text/javascript">
var djConfig = {isDebug:false};
var defaultPageID = "#url.pageID#";
var httpUrl = "#Request.httpUrl#";
</script>
<cfinclude template="headerIncludes.cfm">
<script type="text/javascript" src="#Request.AppVirtualPath#/Lighthouse/Resources/js/editor.js"></script>
</cfoutput>
<style>
html,body{height:100%}
body {margin:0px;background-color:#EFEFEF;}
form {margin:0px;}
#loadIndicator {position:relative;background-color:#fff;width:100%;height:100%;}
#loadIndicator td {text-align:center;vertical-align:middle;}
#monitorStatus {text-align:center;}
#mainContainer {width:100%; height:500px; overflow:hidden;}
div.pane {overflow:auto;margin:5px;}
#treeTab {margin:5px 0px 0px 5px;}
span.helpLink {cursor:help;}
form.pageInfo * {font-size:10px;}
form.pageInfo div.field {padding:4px 0px;}
form.pageInfo div.field * {width:95%;}
form.pageInfo div.field * * {width:auto;}
#link {word-break:break-all;}
#newTopics {width:75%;color:gray;}
#addTopics {width:20%;}
#displayTopics div {margin:5px 0px;}
#displayTopics span.indicator {cursor:pointer;}
span.indicator {background-color:#666;color:white;margin:0px 2px;font-size:9px;padding:0px 1px;}
span.indicator.m {padding:0px 1px;}
span.indicator.i {padding:0px 3px;}
span.indicator.h {padding:0px 2px 0px 1px;}
.dojoDialog {background: #fff;border-radius: 20px;-moz-border-radius: 20px;padding: 20px;}
</style>
</head>
<body class=NORMALTEXT>
<cfoutput>
<table id="loadIndicator"><tr><td><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/ajax-loader-big.gif" alt="Loading"></td></tr></table>

<div id="topContainer" dojoType="SplitContainer" orientation="horizontal" sizerWidth="5" activeSizing="false" layoutAlign="client" persist="true"
	style="height:100%;">
	<div id="propertiesContainer" dojoType="ContentPane" sizeShare="25" style="float:left;width:25%;">
		<div id="mainContainer" dojoType="AccordionContainer">
			<div id="pageInfoTab" dojoType="ContentPane" label="Page Properties" class="pane">
				<form class=pageInfo>
					<div class="field">
						<b>Name:</b> 
						#Application.Lighthouse.ShowTooltip("name","The page name must be unique in the site.")#<br>
						<input type="text" id="txtName">
					</div>
					<cfif Request.lh_useFriendlyUrls>
						<div class="field">
							<b>Link:</b><br>
							<span id="link"></span>
						</div>
					</cfif>
					<div class="field">
						<b>Title:</b><br>
						<textarea id="txtTitle"></textarea>
					</div>
					<div class="field">
						<b>Navigation Title:</b>
						#Application.Lighthouse.ShowTooltip("navtitle","The navigation title is used in the subnavigation of the site.  Often this is the same as the title, but if the title is very long it is sometimes desirable to have a shorter navigation title. This is also used in various places in the admin.")#<br>
						<input type="text" id="txtNavTitle">
					</div>
					<div class="field">
						<b>Browser Title:</b>
						#Application.Lighthouse.ShowTooltip("titletag","The browser title contains the title for your web page that appears in the top bar of the web browser.  An accurate, descriptive title here helps improve search engine rankings.  If no browser title is specified, the title will be used.")#<br>
						<textarea id="txtBrowserTitle"></textarea>
					</div>
					<div class="field">
						<b>Meta Description:</b>
						#Application.Lighthouse.ShowTooltip("metadescription","The meta description is a short description of the page that will not appear on your site but may display in search engine results.  Note that your meta description will generally not affect your search engine rankings, but a good description can result in increased traffic by increasing the likelihood that a user will click on your search result.")#<br>
						<textarea id="txtMetaDescription"></textarea>
					</div>
					<div class="field">
						<b>Show in Navigation:</b>
						#Application.Lighthouse.ShowTooltip("showinnav","If checked, links to this page will appear in the navigation.")#<br>
						<span><input type="radio" id="rbShowInNavYes" name="showInNav" value="1"><label for="rbShowInNavYes">Yes</label>
						<input type="radio" id="rbShowInNavNo" name="showInNav" value="0"><label for="rbShowInNavNo">No</label></span>
					</div>
				</form>
				<form class=pageInfo onsubmit="addNewTopic();return false;">
					<div class="field">
						<b>Topics:</b><br>
						<div id="displayTopics"></div>
						<select id="selectTopics" style="display:none;"><option value="">--Choose an existing topic--</select>
						<span><input type="text" id="newTopics"><input id="addTopics" type=button value="Add"></span>
					</div>
				</form>
			</div>
			<div id="pagePermsTab" dojoType="ContentPane" label="Page Permissions" class="pane">
				<form class=pageInfo>
					<div class="field">
						<b>Members Only:</b>
						#Application.Lighthouse.ShowTooltip("membersonly","You can designate each page on the site as ""members-only"" or ""public."" Public pages are viewable to all website users. Members-only content will require users to log in to view this content.")#<br>
						<span><input type="radio" id="rbMembersOnlyYes" name="MembersOnly" value="1"><label for="rbMembersOnlyYes">Yes</label>
						<input type="radio" id="rbMembersOnlyNo" name="MembersOnly" value="0"><label for="rbMembersOnlyNo">No</label></span>
					</div>
					<div class="field" id="divLinkPublic">
						<b>Public Link:</b>
						#Application.Lighthouse.ShowTooltip("linkpublic","If checked, links to this page in the navigation will appear even for people who don't have access to view the page.  When the user clicks on the link, they will be presented with a login page.")#<br>
						<span><input type="radio" id="rbLinkPublicYes" name="LinkPublic" value="1"><label for="rbLinkPublicYes">Yes</label>
						<input type="radio" id="rbLinkPublicNo" name="LinkPublic" value="0"><label for="rbLinkPublicNo">No</label></span>
					</div>
					<div class="field" id="divUserGroups">
						<b>Member User Groups:</b>
						#Application.Lighthouse.ShowTooltip("usergroups","For members-only pages, select the user groups who have access to this page.  If no user groups are selected, the page will be available to all members.")#<br>
						<select id="userGroupIDs" multiple="true" size="5">
							<cfloop query="UserGroups">
								<option value="#userGroupID#">#name#</option>
							</cfloop>
						</select>
					</div>
				</form>
			</div>
			</cfoutput>
			<div id="myPagesTab" dojoType="ContentPane" label="My Pages" class="pane">
				<div id="wip">
					<b>Work In Progress:</b>
					<ul id="wipUl"></ul>
				</div>
				<div id="workflow"></div>
			</div>
			<cfoutput>
			<div id="treeTab" dojoType="ContentPane" label="Navigate Site" class="pane">
				<div dojoType="TreeLoadingControllerV3" widgetId="controller" RpcUrl="#Request.AppVirtualPath#/Lighthouse/Admin/rpc.cfm?object=Page&method=GetTreeNodes"></div>
				<div dojoType="TreeSelectorV3" widgetId="selector"></div>
				<div dojoType="TreeEmphasizeOnSelect" selector="selector"></div>
				<div dojoType="TreeV3" widgetId="tree" listeners="controller;selector">
					<cfloop query="top">
						<div dojoType="TreeNodeV3" title="#Application.Lighthouse.StripHtml(title)#" widgetId="#pageID#" isFolder="true"></div>
					</cfloop>
				</div>
				<p>
				<strong>Key:</strong><br>
				<span class="indicator m">M</span> Members-Only<br>
				<span class="indicator i">I</span> Inactive<br>
				<span class="indicator h">H</span> Hidden
				</p>
			</div>
		</div>
	</div>
	<div dojoType="ContentPane" sizeShare="75"  style="float:right;width:75%;height:100%;">
		<div id="toolbarContainer" style="background-color:##EFEFEF;border-bottom:1px solid black;">
			<table cellpadding=0 cellspacing=0 border=0 parseWidgets="false">
			<tr valign=top>
				<td>
					<table border="1" cellspacing="0" cellpadding="0" width="100%" CLASS=TOOLBARTABLE>
					<tr align=center>
						<td #tdstyle# onclick="try{window.location='index.cfm'}catch(e){}"><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/toolbar/home.gif" alt="Home" title="Admin Home" border=0 width=16 height=19></td>
						<td class=TOOLBARDIVIDER><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/spacer.gif" alt="" width=1 height=1></TD>
						<!--- <cfif ListFind("DB", Request.environment)> --->
						<td #tdstyle#><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/toolbar/new.gif" alt="New" title="Create a New Page" onclick="showDialog('newPage')"></td>
						<td class=TOOLBARDIVIDER><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/spacer.gif" alt="" width=1 height=1></TD>
						<!--- </cfif> --->
						
						<td id="propertiesButton" #tdstyle# onclick="showDialog('properties')"><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/toolbar/pageproperties.gif" width=19 height=19 border=0 alt="Properties" title="Page Properties"></td>
						<td id="propertiesSeperator" class=TOOLBARDIVIDER><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/spacer.gif" alt="" width=1 height=1></TD>
						<td #tdstyle# onclick="showDialog('template')"><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/toolbar/template.gif" border=0 width=26 height=19 alt="Template" title="Choose Template"></td>
						<td class=TOOLBARDIVIDER><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/spacer.gif" alt="" width=1 height=1></TD>
						<td #tdstyle#><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/toolbar/movepage.gif" alt="Move" title="Move This Page" onclick="showDialog('MovePage')" width=23 height=16></td>
						<td class=TOOLBARDIVIDER><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/spacer.gif" alt="" width=1 height=1></TD>
						<td id="deleteButton" #tdstyle#><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/toolbar/delete.gif" alt="Delete" title="Delete This Page" onclick="deleteThisPage()" width=14 height=21></td>
						<td id="deleteSeperator" class=TOOLBARDIVIDER><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/spacer.gif" alt="" width=1 height=1></TD>
						<td #tdstyle# onclick="showWindow('preview')"><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/toolbar/viewworking.gif" alt="Browse Page" border=0 width=17 height=20></td>
						<td class=TOOLBARDIVIDER><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/spacer.gif" alt="" width=1 height=1></TD>
						<td #tdstyle# onclick="showWindow('versions')"><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/toolbar/versions.gif" border=0 width=17 height=19 alt="Versions" title="Work with Live or Archived Version"></td>
						<td class=TOOLBARDIVIDER><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/spacer.gif" alt="" width=1 height=1></TD>
						<td #tdstyle# onclick="dojo.widget.byId('dlgSave').show()" id="saveChangesButton">
							<img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/toolbar/save.gif" alt="Save" title="Save Changes" width=14 height=14>
						</td>
						<td align=right width=52><a href="http://www.modernsignal.com/" target="_blank"><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/toolbar/modernsignal.gif" alt="Modern Signal" title="Modern Signal" width=52 height=25 border=0></a></td>
					</tr>
					</table>
					<lh:MS_HTMLEditToolbar
						FieldName="main"
						ResourcesDir="#Request.AppVirtualPath#/Lighthouse/Resources"
						ImageDir="#Request.MCFUploadsDir#"
						SpellCheck="#lh_isModuleInstalled("spellcheck")#"
						SiteEditor="true">
				</td>
				<td rowspan=2 class=SMALLTEXT style="padding:5px" valign=middle nowrap>
					<div style="background-color:##FFF;-moz-border-radius:10px;margin:3px;padding:5px;border:1px dotted ##374F89;">
						<div id="editorStatus" style="font-weight:bold;color:##374F89;"></div>
						<div id="divPageStatus">
							<div id="monitorStatus" class="button" style="display:none" onclick="dojo.widget.byId('dlgSave').show()">Save Changes</div>
							<b>Page Status:</b> <span id="pageStatusName"></span><br>
							<b>Page is Active:</b> <span id="pageIsActive"></span>
						</div>
					</div>
				</td>
				<td rowspan=2 class=SMALLTEXT style="padding:10px" valign=middle>
					<iframe id="postback" name="postback" src="#Request.AppVirtualPath#/Lighthouse/Admin/pageHiddenForm.cfm?pageID=#url.pageID#" style="width:100%;height:50px;border-width:0px" frameborder="false" scrolling="no"></iframe>
				</td>
			</tr>
			</table>
		</div>
		<iframe id="page" name="page" src="../page.cfm?pageID=#pageID#&amp;edit=yes&amp;pageVersion=working" onload="setDefaultArea()" style="width:100%;height:100%;border-width:0px;" frameborder="false"></iframe>
	</div>
</div>
<div dojoType="dialog" id="dlgSave" style="display:none;">
	<cfloop query="Statuses">
		<br><div class="button" onclick="changeStatus(#statusID#)">Save as #descr#</div>
	</cfloop>
	<br><p align="center"><input type="button" id="CancelSave" value="Cancel"></p>
</div>

</body>
</cfoutput>
</html>