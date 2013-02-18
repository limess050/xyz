<!---
File Name: 	/leads/leads.cfm
Author: 	David Hammond
Description:
	Screen to view prospects
Inputs:
	startRow (opt)
	orderBy (opt)
--->

<div id=bodyOfPageDiv>
<h1 style="margin:0px"><cfoutput>
	#Request.Table.Title#:
	<cfif StructKeyExists(Request.Table.RowActions,Request.Table.action)>#Request.Table.RowActions[Request.Table.action].Label#
	<cfelseif StructKeyExists(Request.Table.Actions,Request.Table.action)>#Request.Table.Actions[Request.Table.action].Label#
	<cfelse>#Request.Table.action#</cfif>
</cfoutput></h1>

<cfif StructKeyExists(Request,"Lighthouse_Errors")>
	<div id="lighthouse_errors">
		<p>Warning! Lighthouse syntax errors have been detected:</p>
		<ul><cfloop index="i" from="1" to="#ArrayLen(Request.Lighthouse_Errors)#">
		<li><cfoutput>#Request.Lighthouse_Errors[i]#</cfoutput></li></cfloop></ul>
	</div>
</cfif>

<cfinclude template="MS_TableDisplay_StatusMessage.cfm">

<P>
<cfif ArrayLen(Request.Table.ActionOrder) gt 1>
	<TABLE CELLPADDING=1 CELLSPACING=1 BORDER=0 CLASS=ACTIONBUTTONTABLE>
	<TR><CF_MS_TableDisplay_ActionButtons start="<TD CLASS=ACTIONCELL>" end="</TD>"></TR>
	</TABLE>
</cfif>
<cfif Request.Table.action is "Edit">
	<TABLE CELLPADDING=1 CELLSPACING=1 BORDER=0 CLASS=ACTIONBUTTONTABLE>
	<TR>
		<cfloop index="i" from="1" to="#ArrayLen(Request.Table.RowActionOrder)#">
			<cfset CurrAction = Request.Table.RowActions[Request.Table.RowActionOrder[i]]>
			<cfif IIf(Len(CurrAction.ConditionalParam),"IsDefined(""url.#CurrAction.ConditionalParam#"")","true")>
				<cfswitch expression="#CurrAction.Type#">
					<cfcase value="Edit"></cfcase>
					<cfcase value="Select">
						<cfoutput>
						<!---<TD CLASS=ACTIONCELL><a href="javascript:#CurrAction.jsfunction#('#pk#','#JSStringFormat(Evaluate("#CurrAction.DescrColName#"))#')">#CurrAction.Label#</a></TD>--->
						<TD CLASS=ACTIONCELL ID="selButton" ROWID="#pk#" ROWDESCR="#JSStringFormat(Evaluate(CurrAction.DescrColName))#"></TD>
						</cfoutput>
					</cfcase>
					<cfcase value="Custom">
						<cfset showButton = true>
						<cfif Len(CurrAction.Condition)>
							<cfset CurrAction.Condition = REReplace(CurrAction.Condition,"([^ ]+)_SpecialColumn","\1_SpecialColumn","ALL")>
							<cfif Not Evaluate(CurrAction.Condition)><cfset showButton = false></cfif>
						</cfif>
						<cfif showButton>
							<cfif Find("javascript:",CurrAction.href)>
								<cfset theCurrActionHref = REReplace(CurrAction.Href,"##([^##]+)##","##JSStringFormat(HTMLEditFormat(\1))##","ALL")>
							<cfelse>
								<cfset theCurrActionHref = REReplace(CurrAction.Href,"##([^##]+)##","##URLEncodedFormat(\1)##","ALL")>
							</cfif>
							<cfset theCurrActionOnClick = REReplace(CurrAction.OnClick,"##([^##]+)##","##JSStringFormat(HTMLEditFormat(\1))##","ALL")>
							<cfoutput><TD CLASS=ACTIONCELL><a href="#Evaluate("""" & theCurrActionHref & """")#" onclick="#Evaluate("""" & theCurrActionOnClick & """")#" <cfif Len(CurrAction.Target) gt 0>TARGET="#CurrAction.Target#"</cfif>>#CurrAction.Label#</a></TD></cfoutput>
						</cfif>
					</cfcase>
					<cfdefaultcase>
						<cfoutput><TD CLASS=ACTIONCELL><a href="#cgi.script_name#?action=#Request.Table.RowActionOrder[i]#&#Request.Table.persistentParams#&pk=#pk#<cfif Len(queryParams) gt 0>&queryParams=#URLEncodedFormat(queryParams)#</cfif>" <cfif Len(CurrAction.Target) gt 0>TARGET="#CurrAction.Target#"</cfif>>#CurrAction.Label#</a></TD></cfoutput>
					</cfdefaultcase>
				</cfswitch>
			</cfif>
		</cfloop>
	</TR>
	</TABLE>
</cfif>
</P>

<cfinclude template="MS_TableDisplay_Body.cfm">
<cfif Not IsDefined("Request.EndResponse")>
</div>
</cfif>