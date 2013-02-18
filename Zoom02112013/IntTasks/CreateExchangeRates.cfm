
<cfset application.exchangeRateStruct = StructNew()>
<cfset currencyList = "USD,EUR,GBP,ZAR">

<cfoutput>
	<cfloop list="#currencyList#" index="i">
		<cftry>
			<cfhttp url="http://finance.yahoo.com/d/quotes.csv?e=.csv&f=sl1d1t1&s=#i#TZS=X" method="get" result="q" timeout="30">
		 	<cfset rate = listGetAt(q.filecontent,2)/>	
		 	<cfset structInsert(application.exchangeRateStruct, i , rate)>	 	
		<cfcatch>
			<!---if any of the cfhttp calls fail we want this structure to remain undefined --->
			<cfset structDelete(application,"exchangeRateStruct")>
			<cfbreak>
		</cfcatch>
		</cftry>
	</cfloop>	
</cfoutput>
