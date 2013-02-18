<cfprocessingdirective suppressWhiteSpace="Yes">

<cfset fields = attributes.fields>

<!--- <cfset hiddenContentDir = caller.hiddenContentDir> --->
<cfloop index="field" list="#fields#">
	<cfset f = evaluate("caller.#field#")>
	
	<!--- Strips commas and dollar signs out of any numbers entered. (So a user entering $100,000 as a price does not get a _checkNumbers.cfm validation error. --->
	<cfif Find(",",f)>
		<cfset f=Replace(f,",","","ALL")>
		<cfset "caller.#field#"=f>	
	</cfif>
	<cfif Find("$",f)>
		<cfset f=Replace(f,"$","","ALL")>
		<cfset "caller.#field#"=f>	
	</cfif>
	
	<cfif len(f) and not isNumeric(f)>
		<strong><cfif Request.environment neq "Live">
			<cfoutput>#f# in the #field# field is invalid.</cfoutput>		
		</cfif>
		<p><br />Please use your back button to make your edits.</strong>
		<cfabort>
	</cfif>
</cfloop>

</cfprocessingdirective>
