<cfprocessingdirective suppressWhiteSpace="Yes"> <cfsetting enablecfoutputonly="true">
<cfloop index="field" list="#allFields#">
	<cfif isDefined(field)>
		<cfset temp = SetVariable(field, stripCR(trim(evaluate(field))))>
	<cfelse>
		<cfset temp = SetVariable(field, "")>
	</cfif>
</cfloop>

<cfsetting enablecfoutputonly="false"> </cfprocessingdirective>