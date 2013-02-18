<cfparam name="currentpageid" default="">
<cfset currlevel = 1>

<cfquery name="getPages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	select p.pageid,
		p.masterPageID,
		pl.pageID as livePageID,
		coalesce(mp.name,p.name) as name,
		coalesce(p.pagelevel,1) as pageLevel
		<cfif dialogType is "Move">
			,p.parentpageid
			,p.subordernum
		</cfif>
	from #Request.dbprefix#_Pages p left join #Request.dbprefix#_Pages mp on p.masterPageID = mp.pageID
		left join #Request.dbprefix#_Pages_Live pl on p.pageID = pl.pageID
	order by p.ordernum
</cfquery>

<style>
div.a {
	margin-left:20px;
	display:none;
}
div.b {
	float:left;
}
span {
	display:block;
	padding-top:5px;
	cursor:pointer;
	overflow:visible;
}
a {
	text-decoration:none;
}
a:hover {
	color:black;
}
</style>

<script type="text/javascript">
<cfoutput>
var plus = "#Request.AppVirtualPath#/Lighthouse/Resources/images/plus.gif";
var minus = "#Request.AppVirtualPath#/Lighthouse/Resources/images/minus.gif";
var spacer = "#Request.AppVirtualPath#/Lighthouse/Resources/images/bullet.gif";
var os = document.getElementsByTagName("SPAN");
</cfoutput>

function stat1() {
	window.status = "Select a Page";
	return true;
}
function stat2(pageID) {
	window.status = "/page.cfm?pageID=" + pageID;
	return true;
}

// toggle visibility of children
function tog(o,disp) {
	var ns = o.nextSibling;
	while (ns && ns.nodeName == "#text") ns = ns.nextSibling;

	if (ns && ns.nodeName == "DIV") {
		if (disp == null) {
			if (ns.style.display == "block") {
				disp = "none";
			} else {
				disp = "block";
			}
		}
		ns.style.display = disp;

		// set plus/minus graphic
		if (disp == "block") {
			o.getElementsByTagName("IMG")[0].src = minus;
		} else {
			o.getElementsByTagName("IMG")[0].src = plus;
		}

	}
}


// display parents to top of tree
function showTree(o) {
	if (o.parentNode) {
		if (o.parentNode.className == "a" && o.parentNode.style.display != "block") {

			var ps = o.parentNode.previousSibling;
			while (ps && ps.nodeName == "#text") ps = ps.previousSibling;

			if (ps) {
				tog(ps,"block");
				showTree(ps);
			}
		}
	}
}
</script>

<div>
<cfoutput query="getpages">

	<!--- Up or down level --->
	<cfif pagelevel gt currlevel>#RepeatString("<div class=a>",pagelevel - currlevel)#
	<cfelseif pagelevel lt currlevel>#RepeatString("</div>",currlevel - pagelevel)#</cfif>
	<cfset currlevel = pagelevel>

	<!--- page link --->
	<span id=p#pageID# onclick=tog(this)>
		<div class=b><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/bullet.gif" height=12 width=12 hspace=3 vspace=2></div>
		<div class=b>
		<cfif pageid is currentpageid>
			#name# <i>[Current Page]</i>
		<cfelse>
			<a href="##" <cfif dialogType is "Go">onclick="go(#pageID#)"<cfelse>onclick="go(#pageID#,'#parentPageID#',#subordernum#)"</cfif> onmouseover="return stat2(#pageID#);" onmouseout="return stat1()">#name#</a>
		</cfif>
		<cfif len(livePageID) is 0><i>[Inactive]</i></cfif>
		<cfif len(masterPageID) gt 0><i>[Shadow Page]</i></cfif>
		</div>
	<br clear="all"/></span>
</cfoutput>
<cfoutput>#RepeatString("</div>",currlevel)#</cfoutput>
</div>

<script type="text/javascript">
// set plus/minus graphics
for (var i = 0; i < os.length; i++) {
	var o = os[i];


	var ns = o.nextSibling;
	while (ns && ns.nodeName == "#text") ns = ns.nextSibling;

	if (ns && ns.nodeName == "DIV") {
		if (ns.style.display == "block") {
			o.getElementsByTagName("IMG")[0].src = minus;
		} else {
			o.getElementsByTagName("IMG")[0].src = plus;
		}
	} else {
		o.getElementsByTagName("IMG")[0].src = spacer;
	}
}

<cfoutput>
<cfif len(currentpageid) gt 0>
	// Show current page in the hierarchy
	showTree(document.getElementById("p#currentpageid#"));
</cfif>
</cfoutput>
</script>
