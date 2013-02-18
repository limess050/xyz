<!---
  MS_PageNav.cfm

  Inputs:
	 totalItems (required) Total number of items to page through
	 numPerPage (required) Number of items per page.
	 startRow (required) The number of the first item on the current page.
	 url (required) The url
	 numTabs (optional) The number of tabs to show at a time (not including current).
		Default is 15.
	 showInfo (optional) Default false. Shows start, end, and total rows info.

  Include to show navigation to page through a number of items
--->
<cfinclude template="../Functions/LighthouseLib.cfm">
<cfparam name="attributes.numTabs" default="15">
<cfscript>
if (Not IsDefined("attributes.showInfo")) attributes.showInfo = false;

endRow = Min(attributes.startRow + attributes.numPerPage - 1,attributes.totalItems);
prevPage = attributes.startRow - attributes.numPerPage;
nextPage = attributes.startRow + attributes.numPerPage;

// Make some calculations
currPage = (attributes.startRow - 1 + attributes.numPerPage) / attributes.numPerPage;
endPage = Int(attributes.totalItems / attributes.numPerPage) + 1;

// tab is number of the first tab to be displayed.
tab = Int(Max(Min(currPage - Int((attributes.numTabs-1)/2),endPage - (attributes.numTabs-1)),1));
from = tab * attributes.numPerPage - attributes.numPerPage + 1;
to = Min(attributes.totalItems,from + (attributes.numPerPage * (attributes.numTabs-1)));

// strip startrow parameter from url
baseurl = REReplaceNoCase(attributes.url,"(&amp;startrow=[0-9]+|startrow=[0-9]+&amp;|startrow=[0-9]+)","","ALL");
</cfscript>

<cfoutput>
<p class="pagenav">
<cfif attributes.showInfo>
	<div class=SMALLTEXT>
		Showing #attributes.startRow# - #endRow# of #attributes.totalItems# records.
		<cfif attributes.totalItems gt 10>
			<select id="pagenavNum" onchange="window.location='#removeQueryParam(baseurl,"lh_MaxRows")#&amp;lh_MaxRows='+this.options[this.selectedIndex].value;">
				<option value="0">View All</option>
				<cfset numberList = "10,25,100">
				<cfif attributes.numPerPage is not attributes.totalItems and ListFind(numberList,attributes.numPerPage) is 0>
					<option selected value="#attributes.numPerPage#">View #attributes.numPerPage# per page</option>
				</cfif>
				<cfloop index="num" list="#numberList#">
					<option<cfif attributes.numPerPage is num> selected</cfif> value="#num#">View #num# per page</option>
				</cfloop>
			</select>
		</cfif>
	</div>
</cfif>
<table class="pagenav">
	<tr align="CENTER" valign="MIDDLE">
		<cfif attributes.totalItems gt attributes.numPerPage>
			<cfif attributes.startrow gt 1>
				<td><a href="#baseurl#&amp;startRow=#prevPage#">&lt;&lt;Previous</a></td>
			</cfif>
			<cfif from gt 1>
				<td><a href="#baseurl#&amp;startRow=#Evaluate(from - attributes.numPerPage)#">...More</a></td>
			</cfif>
			<cfset row = 0>
			<cfloop index="i" from="#from#" to="#to#" step="#attributes.numPerPage#">
				<cfif i eq attributes.startrow>
					<td class="pagenavcurrent">#tab#</td>
				<cfelse>
					<td><a href="#baseurl#&amp;startRow=#i#">#tab#</a></td>
				</cfif>
				<cfset tab = tab + 1>
				<cfset row = row + 1>
				<cfif row is 20><cfset row = 0></TR><TR></cfif>
			</cfloop>
			<cfif to lt attributes.totalItems - attributes.numPerPage>
				<td><a href="#baseurl#&amp;startRow=#i#">More...</a></td>
			</cfif>
			<cfif attributes.totalItems ge nextPage>
				<td><a href="#baseurl#&amp;startRow=#nextPage#">Next&gt;&gt;</a></td>
			</cfif>
		</cfif>
	</TR>
</table>
</cfoutput>
</p>
