<!---
File Name: 	MS_TableDisplay_*.cfm
Author: 	David Hammond
Description:
	Display tag
Inputs:
--->

<cfset Actions = Request.Table.Actions>
<cfset ActionOrder = Request.Table.ActionOrder>
<cfloop index="i" from="1" to="#ArrayLen(ActionOrder)#">
	<cfset CurrAction = Actions[ActionOrder[i]]>
	<cfif IIf(Len(CurrAction.ConditionalParam),"IsDefined(""url.#CurrAction.ConditionalParam#"")","true")>
		<cfswitch expression="#CurrAction.Type#">
			<cfcase value="View">
				<cfif url.Searching and Request.Table.action is not "View">
					<cfoutput>#attributes.start#<a href="#cgi.script_name#?action=#ActionOrder[i]#&#Request.Table.persistentParams#&#caller.queryParams#">View Search Results</a>#attributes.end#</cfoutput>
				</cfif>
				<cfif url.Searching or Request.Table.action is not "View">
					<cfoutput>#attributes.start#<a href="#cgi.script_name#?action=#ActionOrder[i]#&#Request.Table.persistentParams#">View All</a>#attributes.end#</cfoutput>
				</cfif>
			</cfcase>
			<cfcase value="Search">
				<cfif url.Searching and Request.Table.action is not "Search">
					<cfoutput>#attributes.start#<a href="#cgi.script_name#?action=#ActionOrder[i]#&#Request.Table.persistentParams#&#caller.queryParams#">Refine Search</a>#attributes.end#</cfoutput>
				</cfif>
				<cfif url.Searching or Request.Table.action is not "Search">
					<cfoutput>#attributes.start#<a href="#cgi.script_name#?action=#ActionOrder[i]#&#Request.Table.persistentParams#"><cfif url.Searching>New </cfif>Search</a>#attributes.end#</cfoutput>
				</cfif>
			</cfcase>
			<cfcase value="Add">
				<cfif Request.Table.action is not "Add">
					<cfoutput>#attributes.start#<a href="#cgi.script_name#?action=#ActionOrder[i]#&#Request.Table.persistentParams#<cfif Len(caller.queryParams) gt 0>&queryParams=#URLEncodedFormat(caller.queryParams)#</cfif>">#CurrAction.Label#</a>#attributes.end#</cfoutput>
				</cfif>
			</cfcase>
			<cfcase value="DeleteOnEdit">
				<cfif Request.Table.action is "Edit">
					<cfset showButton = true>
					<cfif Len(Request.Table.RelatedTables) gt 0>
						<cfloop index="tc" list="#Request.Table.RelatedTables#">
							<cfquery name="checkRelatedTable" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
								select count(*) as c from #ListFirst(tc,".")# where #ListLast(tc,".")# = #caller.pk#
							</cfquery>
							<cfif checkRelatedTable.c gt 0><cfset showButton = false><cfbreak></cfif>
						</cfloop>
					</cfif>
					<cfif showButton><cfoutput>#attributes.start#<a href="#cgi.script_name#?action=Delete&#Request.Table.persistentParams#&pk=#pk#<cfif Len(caller.queryParams) gt 0>&queryParams=#URLEncodedFormat(caller.queryParams)#</cfif>">Delete</a>#attributes.end#</cfoutput></cfif>
				</cfif>
			</cfcase>
			<cfcase value="ListOrder">
				<cfif Request.Table.action is not "ListOrder">
					<cfoutput>#attributes.start#<a href="#cgi.script_name#?action=#ActionOrder[i]#&#Request.Table.persistentParams#<cfif Len(caller.queryParams) gt 0>&queryParams=#URLEncodedFormat(caller.queryParams)#</cfif>">#CurrAction.Label#</a>#attributes.end#</cfoutput>
				</cfif>
			</cfcase>
			<cfcase value="Custom">
				<cfif Request.Table.action is not ActionOrder[i]>
					<cfset CurrAction.Href = REReplace(CurrAction.Href,"##([^##]+)##","##caller.\1##","ALL")>
					<cfoutput>#attributes.start#<a href="#Evaluate("""" & CurrAction.Href & """")#" <cfif Len(CurrAction.Target) gt 0>TARGET="#CurrAction.Target#"</cfif>>#CurrAction.Label#</a>#attributes.end#</cfoutput>
				</cfif>
			</cfcase>
		</cfswitch>
	</cfif>
</cfloop>