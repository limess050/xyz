<style>
	.exchange {font-size: 11px; font-family: Verdana, Geneva, sans-serif;}
</style>
<cfset currencyList = "USD,EUR,GBP,ZAR">
<p class="exchange">Current Value of the Tanzanian Shilling:</p>
<cfloop list="#currencyList#" index="i">
	<cfinvoke
	webservice="http://www.webservicex.com/CurrencyConvertor.asmx?wsdl"
	method="ConversionRate"
	returnvariable="aRate">
	<cfinvokeargument name="FromCurrency" value="TZS"/>
	<cfinvokeargument name="ToCurrency" value="#i#"/>
	</cfinvoke>

<cfoutput><p class="exchange">#aRate# #i#</p></cfoutput>
</cfloop> 