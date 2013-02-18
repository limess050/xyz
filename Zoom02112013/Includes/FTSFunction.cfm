<cffunction name="NormalizeFullTextSearchTerm" hint="Takes ad-hoc search text and makes valid search term for sql server full-text search" returntype="String">
	<cfargument name="s" type="string" required="true">
	<cfset var s2 = "">
	<cfset var word = "">
	<cfset var quoteOpened = false>
	<cfset var openQuote = false>
	<cfset var closeQuote = false>
	<cfset var operatorNeeded = false>
	<cfset var condition = "">
	<cfloop index="i" from="1" to="#listLen(arguments.s," ")#">
		<cfset word = listGetAt(arguments.s,i," ")>
		<cfif listFindNoCase("AND,OR,NEAR,&,&!,|,~",word)>
			<!--- word is an operator --->
			<cfif i gt 1 and i lt listLen(arguments.s," ")>
				<!--- Not first or last word --->
				<cfset s2 = listAppend(s2,UCase(word)," ")>
				<cfset operatorNeeded = false>
			</cfif>
		<cfelseif word is "NOT" and (operatorNeeded or (i gt 2 and listGetAt(arguments.s,i-1," ") is "AND"))>
			<!--- word is an operator --->
			<cfif i gt 1 and i lt listLen(arguments.s," ")>
				<!--- Not first or last word --->
				<cfif operatorNeeded>
					<cfset s2 = listAppend(s2,"AND NOT"," ")>
					<cfset operatorNeeded = false>
				<cfelse>
					<cfset s2 = listAppend(s2,"NOT"," ")>
				</cfif>
			</cfif>
		<cfelse>
			<cfif operatorNeeded>
				<cfset condition = "AND ">
			<cfelse>
				<cfset condition = "">
			</cfif>
			<cfset openQuote = false>
			<cfset closeQuote = false>
			<cfif quoteOpened>
				<cfif right(word,1) is """">
					<!--- Closing quote --->
					<cfset closeQuote = true>
				</cfif>
			<cfelseif left(word,1) is """">
				<!--- Opening quote --->
				<cfset openQuote = true>
				<cfif right(word,1) is """">
					<!--- Also closing quote --->
					<cfset closeQuote = true>
				<cfelse>
					<cfset quoteOpened = true>
				</cfif>
			<cfelse>
				<!--- Quote single word --->
				<cfset openQuote = true>
				<cfset closeQuote = true>
			</cfif>
			<cfset word = replace(word,"""","","all")>
			<cfif quoteOpened or not listFindNoCase("1|2|3|4|5|6|7|8|9|0|$|!|@|##|$|%|^|&|*||)|-|_|+|=|[|]|{|}|about|after|all|also|an|and|another|any|are|as|at|be|because|been|before|being|between|both|but|by|came|can|come|could|did|do|does|each|else|for|from|get|got|has|had|he|have|her|here|him|himself|his|how|if|in|into|is|it|its|just|like|make|many|me|might|more|most|much|must|my|never|now|of|on|only|or|other|our|out|over|re|said|same|see|should|since|so|some|still|such|take|than|that|the|their|them|then|there|these|they|this|those|through|to|too|under|up|use|very|want|was|way|we|well|were|what|when|where|which|while|who|will|with|would|you|your|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z",word,"|")>
				<cfif openQuote>
					<cfset condition = condition & """">
				</cfif>
				<cfset condition = condition & word>
				<cfif closeQuote>
					<cfset condition = condition & """">
					<cfset quoteOpened = false>
				</cfif>
				<cfset operatorNeeded = (Not quoteOpened)>
				<cfset s2 = listAppend(s2,condition," ")>
			</cfif>
		</cfif>
	</cfloop>
	<cfif quoteOpened>
		<cfset s2 = s2 & """">
	</cfif>
	<cfreturn s2>
</cffunction>