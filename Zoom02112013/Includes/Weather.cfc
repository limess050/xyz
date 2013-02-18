

<cfsetting showdebugoutput="no">

<cffunction name="GetWeather" access="remote" returntype="string" displayname="Returns Current Weather">
	<cfset rString="">
	<cfset YahooLocationID = "TZXX0001">
	<cfset baseUrl = "http://xml.weather.yahoo.com/forecastrss?p=">
	<cfset imageBaseUrl = "http://l.yimg.com/a/i/us/we/52/">
	
	<cfhttp url="#baseUrl##YahooLocationID#&u=c" result="response">
	
	
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
	<cfset code = xmlResult.rss.channel.item["yweather:condition"].xmlAttributes.code>
	
	
	<cfset numForecast = arrayLen(xmlResult.rss.channel.item["yweather:forecast"])>
	<cfset forecast = arrayNew(1)>
	<cfloop index="x" from="1" to="#numForecast#">
	    <cfset day = structNew()>
	    <cfset day.date = xmlResult.rss.channel.item["yweather:forecast"][x].xmlAttributes.date>
	    <cfset day.dow = xmlResult.rss.channel.item["yweather:forecast"][x].xmlAttributes.day>
	    <cfset day.high = xmlResult.rss.channel.item["yweather:forecast"][x].xmlAttributes.high>
	    <cfset day.low = xmlResult.rss.channel.item["yweather:forecast"][x].xmlAttributes.low>
	    <cfset day.condition = xmlResult.rss.channel.item["yweather:forecast"][x].xmlAttributes.text>
	    <cfset day.code = xmlResult.rss.channel.item["yweather:forecast"][x].xmlAttributes.code>
	    <cfset arrayAppend(forecast, day)>
	</cfloop>
	<cfoutput>
	<cfsavecontent variable="rString">
	<table  border="0" cellspacing="0" cellpadding="0" class="exchange" width="200">
	<tr class="alt">
	<td style="width:40px">Currently</td>
	<td style="vertical-align:top">#temperature# #temp# <img src="#imageBaseUrl##code#.gif" width="30" style="vertical-align:middle"></td>
	</tr>
	
	<cfloop index="x" from="1" to="#arrayLen(forecast)#">
		
		<tr>
			<td>#forecast[x].dow# #forecast[x].date#</td>
			<td>#forecast[x].low#/#forecast[x].high# #temp#
			<img src="#imageBaseUrl##forecast[x].code#.gif" width="30" style="vertical-align:middle"></td>
		</tr>
		
	</cfloop>
	</table>
	</cfsavecontent> 	
	</cfoutput>
 	<cfreturn rString>
</cffunction>
