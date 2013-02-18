<cfparam name="currentpageid" default="">

<cfquery name="getPages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	select p.pageid,
		p.masterPageID,
		pl.pageID as livePageID,
		coalesce(mp.name,p.name) as name,
		case 
			when mp.title is not null and Len(mp.title) > 0 and p.title <> '<br>' then mp.title
			when mp.navtitle is not null and Len(mp.navtitle) > 0 then mp.navtitle
			when p.title is not null and Len(p.title) > 0 then p.title
			when p.navtitle is not null and Len(p.navtitle) > 0 then p.navtitle
			else p.name
		end as title,
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
span#infotab {display:inline}
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
var currlevel = 1
var currentpageid = "#currentpageid#";
var p = new Array();
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


<cfoutput query="getpages">
p[#Evaluate("currentrow-1")#]=["#pageID#","#masterPageID#","#livePageID#","#JsStringFormat(name)#","#JsStringFormat(StripHtml(title))#","#pageLevel#"<cfif dialogType is "Move">,"#parentPageID#","#subordernum#"</cfif>];</cfoutput>

document.write("<div>\n");
for (var i = 0; i < p.length; i ++) {
	pageID = p[i][0];
	masterPageID = p[i][1];
	livePageID = p[i][2];
	name = p[i][3];
	title = p[i][4];
	if (title == "") title = "(No Title)";
	pagelevel = p[i][5];
	if (i == p.length - 1) {
		nextPageLevel = 0;
	} else {
		nextPageLevel = p[i+1][5];
	}
	<cfif dialogType is "Move">
		parentPageID = p[i][6];
		subOrderNum = p[i][7];
	</cfif>


	// Up or down level
	if (pagelevel > currlevel) {
		for (j = 0; j < pagelevel - currlevel; j ++) {
			document.writeln("<div class=a>");
		}
	} else if (pagelevel < currlevel) {
		for (j = 0; j < currlevel - pagelevel; j ++) {
			document.writeln("</div>");
		}
	}
	currlevel = pagelevel;

	// page link
	document.writeln("<span id=p" + pageID + " onclick=tog(this)>");

	// plus/minus/bullet graphic
	document.writeln("<div class=b>");
	if (nextPageLevel > pagelevel) {
		document.write("<img src=\"" + plus + "\" height=12 width=12 hspace=3 vspace=2>");
	} else {
		document.write("<img src=\"" + spacer + "\" height=12 width=12 hspace=3 vspace=2>");
	}
	document.write("</div>");

	// page name
	document.writeln("<div class=b>");
	if (pageID == currentpageid) {
		document.writeln(title + " <i>[Current Page]</i>");
	} else {
		document.writeln("<a href=\"#\" <cfif dialogType is "Go">onclick=\"go(" + pageID + ",'" + name + "')\"<cfelse>onclick=\"go(" + pageID + ",'" + parentPageID + "'," + subOrderNum + ")\"</cfif> onmouseover=\"return stat2(" + pageID + ");\" onmouseout=\"return stat1()\">" + title + "</a>");
	}
	if (livePageID == "") {
		document.writeln("<i>[Inactive]</i>");
	}
	if (masterPageID != "") {
		document.writeln("<i>[Shadow Page]</i>");
	}
	document.writeln("</div>");

	document.writeln("<br clear=\"all\"/></span>");
}
for (j = 0; j < currlevel; j ++) {
	document.writeln("</div>");
}
document.writeln("</div>");
<cfoutput>
<cfif len(currentpageid) gt 0>
	// Show current page in the hierarchy
	showTree(document.getElementById("p#currentpageid#"));
</cfif>
</cfoutput>
</script>
