
<cfsetting showdebugoutput="no">

<cffunction name="GetExchangeRate" access="remote" returntype="string" displayname="Returns Current Exchange Rates">
	<cfset rString="">
	<cfset currencyList = "USD,EUR,GBP,ZAR,CNY">
	<cfsavecontent variable="rString">
		<cftry>
		
		<cfoutput>
			<table  border="0" cellspacing="0" cellpadding="0" class="exchange" width="200">
			<tr><td colspan="2" style="font-size:10px"><b>Exchange Rates for #DateFormat(Now(),"dd mmm yyyy")#</b></td></tr>	
			<cfset counter = 1>	
			<cfloop list="#currencyList#" index="i">
				<cfhttp url="http://finance.yahoo.com/d/quotes.csv?e=.csv&f=sl1d1t1&s=#i#TZS=X" method="get" result="q1">	
				<cfhttp url="http://finance.yahoo.com/d/quotes.csv?e=.csv&f=sl1d1t1&s=TZS#i#=X" method="get" result="q2">
 				<cfset rate1 = listGetAt(q1.filecontent,2)/>
				<cfset rate2 = listGetAt(q2.filecontent,2)/>	
				<tr  <cfif counter MOD 2 EQ 1>class="alt"</cfif>>
					<td>#i#</td>
					<td>1 #i# = #rate1# TZS<br>1 TZS = #rate2# #i#</td>
				</tr>
				<cfset counter = counter + 1>
			</cfloop>
			</table>
		</cfoutput>
		<cfcatch type="any">
			Exchange Rates are not available at this time
		</cfcatch>
		
		</cftry>
	</cfsavecontent> 	

 	<cfreturn rString>
</cffunction>
