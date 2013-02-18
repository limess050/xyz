<!--- Display list of links (for admin home page)
	assumes query getLinks (in header) has already been run --->

<cfset numcats = 0>
<cfoutput query="getLinks" group="category">
	<cfset numcats = numcats + 1>
</cfoutput>

<cfset col2 = false>
<table cellspacing=10>
	<tr valign=top>
		<td>
			<cfoutput query="getLinks" group="category">
				<cfif not col2 and currentRow gt (recordCount / 2) - recordcount/(numcats*2)>
					</td><td>
					<cfset col2 = true>
				</cfif>
			
				<b>#category#</b>
				<ul>
				<cfoutput>
					<li><a href="#Evaluate(DE(href))#" <cfif len(onclick)>onclick="#onclick#"</cfif> <cfif len(target)>target="#target#"</cfif>>#linktext#</a>
				</cfoutput>
				</ul>
			</cfoutput>
		</td>
		<cfif lh_isModuleInstalled("siteEditor")>
			<cfset wip = Session.User.GetWorkInProgress()>
			<cfset workflow = Session.User.GetWorkflowItems()>
			<cfset recent = Session.User.GetRecent()>
			<td>
				<cfif wip.recordcount gt 0>
					<b>My Work In Progress:</b>
					<ul>
					<cfoutput query="wip">
						<li><a href="index.cfm?adminFunction=editPage&pageID=#pageID#">#Application.Lighthouse.StripHtml(title)#</a></li>
					</cfoutput>
					</ul>
				</cfif>
				<cfif workflow.recordcount gt 0>
					<cfoutput query="workflow" group="status">
						<h4>#status#</h4>
						<ul>
						<cfoutput>
							<li><a href="index.cfm?adminFunction=editPage&pageID=#pageID#">#Application.Lighthouse.StripHtml(title)#</a></li>
						</cfoutput>
						</ul>
					</cfoutput>
				</cfif>
				<cfif recent.recordcount gt 0>
					<b>My Recent Live Pages:</b>
					<ul>
					<cfoutput query="recent" group="pageID">
						<li><a href="index.cfm?adminFunction=editPage&pageID=#pageID#">#Application.Lighthouse.StripHtml(title)#</a></li>
					</cfoutput>
					</ul>
				</cfif>
			</td>
		</cfif>
	</tr>
</table>