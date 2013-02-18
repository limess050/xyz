<cfquery name="GetCurrent" datasource="#request.dsn#">
	SELECT IsSpam,DefensioPass,DefensioSignature
	FROM Messages
	WHERE MessageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>
<cfif Len(GetCurrent.DefensioSignature) gt 0>
	<cfset defensio = CreateObject("component","cfc.defensio.defensio").Init(Request.DefensioApi.Key, Request.DefensioApi.OwnerUrl)>
	<cfif not structKeyExists(form,"IsSpam")>
		<cfset form.IsSpam = 0>
	</cfif>
	<!--- Report false positives and negatives to Defensio --->
	<cfif GetCurrent.DefensioPass is 1 and IsSpam is 1>
		<cfset defensio.reportFalseNegatives(GetCurrent.DefensioSignature)>
	<cfelseif GetCurrent.DefensioPass is 0 and IsSpam is 0>
		<cfset defensio.reportFalsePositives(GetCurrent.DefensioSignature)>
	</cfif>
</cfif>
