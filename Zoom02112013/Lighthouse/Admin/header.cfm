<cfsilent>
<cfparam name="pg_title" default="">
<cfparam name="MCFShowAddCurrentPage" default="true">
<cfquery name="getLinks" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT alc.descr as category,alc.linkCatID,linkText,href,onclick,target
	FROM #Request.dbprefix#_links al inner join #Request.dbprefix#_linkCats alc on al.linkCatID = alc.linkCatID
	WHERE al.linkID in (
			SELECT linkID FROM #Request.dbprefix#_userLinks 
			WHERE userID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">
		)
		<cfif glb_User.Super is 1>or al.super = 1</cfif>
	ORDER BY alc.ordernum, al.ordernum
</cfquery>
</cfsilent>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<cfinclude template="headerIncludes.cfm">
<cfoutput>
<title>#Request.glb_title#<cfif len(pg_title)>: #pg_title#</cfif></title>
</cfoutput>
</head>
<body style="margin:0px" class=NORMALTEXT>

<!-- Tags for the menu bar. -->
<div id="menuBar">
	<div id="menuButtonGroupLeft">
		<cfoutput query="getLinks" group="category">
			<a class="menuButton" href="##" onclick="return buttonClick(this, '#Replace(category," ","_","ALL")#');" onmouseover="buttonMouseover(this, '#Replace(category," ","_","ALL")#');">#category#</a>
		</cfoutput>
	</div>
	<div id="menuButtonGroupRight">
		<cfoutput>
		<span id="loggedInAs">Logged&nbsp;in&nbsp;as&nbsp;#glb_user.firstName#&nbsp;#glb_user.lastName#</span>
		<a class="menuButton" href="##" onclick="return buttonClick(this, 'mcf_Options');" onmouseover="buttonMouseover(this, 'mcf_Options');">Options</a>
		<a class="menuButton" href="index.cfm"><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/home.gif" border=0 width=13 height=11 align=bottom alt="Home"></a>
		<a class="menuButton" href="index.cfm?adminFunction=login&amp;logout=Y" onclick="return confirm('Logout?');">Logout</a>
		</cfoutput>
	</div>
</div>

<!-- Tags for the drop down menus. -->
<div id="mcf_Options" class="menu">
	<cfoutput>
	<a class="menuItem" href="index.cfm?adminFunction=links&amp;action=Add&amp;linktext=#urlencodedformat(pg_title)#&amp;href=#urlencodedformat(getParameterizedUrl())#" title="Save a link to the current page in the menu.">Save Page</a>
	</cfoutput>
</div>
<cfoutput query="getLinks" group="category">
	<div id="#Replace(category," ","_","ALL")#" class="menu">
		<cfoutput>
			<a class="menuItem" href="#Replace(Evaluate(DE(href)),"&","&amp;","ALL")#" <cfif len(onclick)>onclick="#onclick#"</cfif> <cfif len(target)>target="#target#"</cfif>>#linktext#</a>
		</cfoutput>
	</div>
</cfoutput>
<div style="padding:10px;">
