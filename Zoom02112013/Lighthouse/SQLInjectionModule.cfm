<cfif not isDefined("application.MS_SQLInjectionPhrasesLastUpdated")>
	<cfset application.MS_SQLInjectionPhrasesLastUpdated = "">
</cfif>
<cfif not isDefined("application.MS_SQLInjectionPhrases")>
	<cfset application.MS_SQLInjectionPhrases = "CAST\s*\(|EXEC\s*\(|;\s*Declare">
</cfif>

<cfif isDefined("url.ReloadSQLInjectionPhrases") or not len(application.MS_SQLInjectionPhrasesLastUpdated) or application.MS_SQLInjectionPhrasesLastUpdated neq dateFormat(now(), 'mm/dd/yyyy')>
	<!-- SQL Injection Phrases being reloaded -->
	<cfset application.MS_SQLInjectionPhrasesLastUpdated = dateFormat(now(), 'mm/dd/yyyy')>

	<cfhttp url="http://www.modernsignal.com/SQLInjectionPhrases.cfm" method="get">
	<cfset s = cfhttp.fileContent>
	<cftry>
		<cfset xml = xmlParse(s)>
		<cfcatch>
			<!-- Unable to parse XML -->
		</cfcatch>
	</cftry>

	<cftry>
		<cfset application.MS_SQLInjectionPhrases = xml.phrases[1].xmlText>
		<cfcatch>
			<!-- Unable to load XML Phrases -->
		</cfcatch>
	</cftry>
</cfif>

<cfloop collection="#url#" item="var">
	<cfif right(var, 2) is "ID" and find(";", url[var])>
		We have discovered invalid data.  Quitting.<cfabort>
	</cfif>
	<cfif reFindNoCase(application.MS_SQLInjectionPhrases, url[var])>
		We have discovered invalid data.  Quitting.<cfabort>
	</cfif>
</cfloop>
<cfloop collection="#form#" item="var">
	<cfif right(var, 2) is "ID" and find(";", form[var])>
		We have discovered invalid data.  Quitting.<cfabort>
	</cfif>
	<cfif reFindNoCase(application.MS_SQLInjectionPhrases, form[var])>
		We have discovered invalid data.  Quitting.<cfabort>
	</cfif>
</cfloop>

<cfif isDefined("form.pageID") and len(trim(form.pageID)) and not isNumeric(form.pageID)>
	We have discovered invalid data. Quitting.<cfabort>
</cfif>
<cfif isDefined("url.pageID") and len(trim(url.pageID)) and not isNumeric(url.pageID)>
	We have discovered invalid data. Quitting.<cfabort>
</cfif>
