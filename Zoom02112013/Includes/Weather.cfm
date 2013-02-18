<style>
	.weather {font-size: 11px; font-family: Verdana, Geneva, sans-serif;}
</style>

<cfset YahooLocationID = "TZXX0001">
<cfset baseUrl = "http://xml.weather.yahoo.com/forecastrss?p=">

<cfhttp url="#baseUrl##YahooLocationID#" result="response">


<cfset xmlResult = xmlParse(response.fileContent)>

<cfset lastUpdated = xmlResult.rss.channel.lastBuildDate.xmlText>

<cfset description = xmlResult.rss.channel.description.xmlText>


<!--- units --->
<cfset speed = xmlResult.rss.channel["yweather:units"].xmlAttributes.speed>
<cfset temp = xmlResult.rss.channel["yweather:units"].xmlAttributes.temperature>
<cfset distance = xmlResult.rss.channel["yweather:units"].xmlAttributes.distance>
<cfset pressure = xmlResult.rss.channel["yweather:units"].xmlAttributes.pressure>



<cfset temperature = xmlResult.rss.channel.item["yweather:condition"].xmlAttributes.temp>
<cfset condition = xmlResult.rss.channel.item["yweather:condition"].xmlAttributes.text>


<cfset numForecast = arrayLen(xmlResult.rss.channel.item["yweather:forecast"])>
<cfset forecast = arrayNew(1)>
<cfloop index="x" from="1" to="#numForecast#">
    <cfset day = structNew()>
    <cfset day.date = xmlResult.rss.channel.item["yweather:forecast"][x].xmlAttributes.date>
    <cfset day.dow = xmlResult.rss.channel.item["yweather:forecast"][x].xmlAttributes.day>
    <cfset day.high = xmlResult.rss.channel.item["yweather:forecast"][x].xmlAttributes.high>
    <cfset day.low = xmlResult.rss.channel.item["yweather:forecast"][x].xmlAttributes.low>
    <cfset day.condition = xmlResult.rss.channel.item["yweather:forecast"][x].xmlAttributes.text>
    <cfset arrayAppend(forecast, day)>
</cfloop>

<cfoutput>

<p class="weather">
	<b>Currently: #condition# / #temperature# #temp#</b><br>
</p>
<br>
<cfloop index="x" from="1" to="#arrayLen(forecast)#">
	<p class="weather">
		<b>Forecast for #forecast[x].dow# #forecast[x].date#</b><br />
		Temperature: #forecast[x].low#/#forecast[x].high# #temp#<br />
		Conditions: #forecast[x].condition#<br/>
	</p>
	<br>
</cfloop>

</cfoutput>
