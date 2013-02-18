<!---
File Name: 	/Lighthouse/Tags/MS_TableDefaultTemplateSimple.cfm
Author: 	David Hammond
Description:

Inputs:

--->

<div id=bodyOfPageDiv>

<cfinclude template="MS_TableDisplay_StatusMessage.cfm">

<P>
<cfif ArrayLen(ActionOrder) gt 1>
	<TABLE CELLPADDING=1 CELLSPACING=1 BORDER=0 BORDERCOLOR=FFFFFF CLASS=ACTIONBUTTONTABLE>
	<TR><CF_MS_TableDisplay_ActionButtons start="<TD CLASS=ACTIONCELL>" end="</TD>"></TR>
	</TABLE>
</cfif>
<cfif Request.Table.action is "Edit">
	<TABLE CELLPADDING=1 CELLSPACING=1 BORDER=0 BORDERCOLOR=FFFFFF CLASS=ACTIONBUTTONTABLE>
	<TR>
		<cfloop index="i" from="1" to="#ArrayLen(RowActionOrder)#">
			<cfset CurrAction = RowActions[RowActionOrder[i]]>
			<cfif IIf(Len(CurrAction.ConditionalParam),"IsDefined(""url.#CurrAction.ConditionalParam#"")","true")>
				<cfswitch expression="#CurrAction.Type#">
					<cfcase value="Edit"></cfcase>
					<cfcase value="Select">
						<cfoutput><TD CLASS=ACTIONCELL><a href="javascript:#CurrAction.jsfunction#('#pk#','#JSStringFormat(Evaluate("#CurrAction.DescrColName#"))#')">#CurrAction.Label#</a></TD></cfoutput>
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
						<cfoutput><TD CLASS=ACTIONCELL><a href="#cgi.script_name#?action=#RowActionOrder[i]#&#Request.Table.persistentParams#&pk=#pk#<cfif Len(queryParams) gt 0>&queryParams=#URLEncodedFormat(queryParams)#</cfif>" <cfif Len(CurrAction.Target) gt 0>TARGET="#CurrAction.Target#"</cfif>>#CurrAction.Label#</a></TD></cfoutput>
					</cfdefaultcase>
				</cfswitch>
			</cfif>
		</cfloop>
	</TR>
	</TABLE>
</cfif>
</P>

<cfinclude template="MS_TableDisplay_Body.cfm">
</div>
