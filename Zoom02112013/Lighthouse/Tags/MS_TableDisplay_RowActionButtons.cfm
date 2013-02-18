<!---
File Name: 	MS_TableDisplay_*.cfm
Author: 	David Hammond
Description:
	Display tag
Inputs:
--->

<cfif Request.Table.action is "Edit">
	<cfloop index="i" from="1" to="#ArrayLen(Request.Table.RowActionOrder)#">
		<cfset CurrAction = Request.Table.RowActions[Request.Table.RowActionOrder[i]]>
		<cfif IIf(Len(CurrAction.ConditionalParam),"IsDefined(""url.#CurrAction.ConditionalParam#"")","true")>
			<cfswitch expression="#CurrAction.Type#">
				<cfcase value="Edit"></cfcase>
				<cfcase value="Select">
					<cfoutput>#attributes.start#<a NAME="selButton" ID="selButton" ROWID="#caller.pk#" ROWDESCR="#JSStringFormat(Evaluate("caller.#CurrAction.DescrColName#"))#>#attributes.end#</cfoutput>
				</cfcase>
				<cfcase value="Custom">
					<cfset showButton = true>
					<cfif Len(CurrAction.Condition)>
						<cfset CurrAction.Condition = REReplace(CurrAction.Condition,"([^ ]+)_SpecialColumn","caller.\1_SpecialColumn","ALL")>
						<cfif Not Evaluate(CurrAction.Condition)><cfset showButton = false></cfif>
					</cfif>
					<cfif showButton>
						<cfif Find("javascript:",CurrAction.href)>
							<cfset theCurrActionHref = REReplace(CurrAction.Href,"##([^##]+)##","##JSStringFormat(HTMLEditFormat(caller.\1))##","ALL")>
						<cfelse>
							<cfset theCurrActionHref = REReplace(CurrAction.Href,"##([^##]+)##","##URLEncodedFormat(caller.\1)##","ALL")>
						</cfif>
						<cfset theCurrActionOnClick = REReplace(CurrAction.OnClick,"##([^##]+)##","##JSStringFormat(HTMLEditFormat(caller.\1))##","ALL")>
						<cfoutput>#attributes.start#<a href="#Evaluate("""" & theCurrActionHref & """")#" onclick="#Evaluate("""" & theCurrActionOnClick & """")#" <cfif Len(CurrAction.Target) gt 0>TARGET="#CurrAction.Target#"</cfif>>#CurrAction.Label#</a>#attributes.end#</cfoutput>
					</cfif>
				</cfcase>
				<cfdefaultcase>
					<cfoutput>#attributes.start#<a href="#cgi.script_name#?action=#Request.Table.RowActionOrder[i]#&#Request.Table.persistentParams#&pk=#caller.pk#<cfif Len(caller.queryParams) gt 0>&queryParams=#URLEncodedFormat(caller.queryParams)#</cfif>" <cfif Len(CurrAction.Target) gt 0>TARGET="#CurrAction.Target#"</cfif>>#CurrAction.Label#</a>#attributes.end#</cfoutput>
				</cfdefaultcase>
			</cfswitch>
		</cfif>
	</cfloop>
</cfif>