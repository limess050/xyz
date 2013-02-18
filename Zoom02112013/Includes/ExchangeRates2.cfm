<div class="promo-tideandlunar">
	<cfif isDefined("application.exchangeRateStruct")>
		<cfset currencyList = "USD,EUR,GBP,ZAR">
		<cftry>
			<cfoutput>
				<ul>
				<cfset counter = 1>	
				<cfloop list="#currencyList#" index="i">
					<li <cfif Counter is ListLen(currencyList)>class="last"</cfif>><strong>1 #i#</strong> = #StructFind(application.exchangeRateStruct, i)# TZS</li>
					<cfset counter = counter + 1>
				</cfloop>
				</ul>
			</cfoutput>
		<cfcatch type="any">
			<p>Exchange Rates are not available at this time</p>
		</cfcatch>	
		</cftry>
	<cfelse>
		<p>Exchange Rates are not available at this time</p>	
	</cfif>
</div>