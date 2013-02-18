<cfcomponent output="false">
	<cffunction name="getWeather" access="public" output="false" returntype="void">
		<cfargument name="locationCode" type="String" required="true" />
		<cfargument name="tempUnits" type="String" required="true" />

		<cfhttp url="http://weather.yahooapis.com/forecastrss?p=#arguments.locationCode#&u=#arguments.tempUnits#">
		<cfset weatherXml = XmlParse(Replace(cfhttp.fileContent,"yweather:","yweather_","ALL"))>
		<cfset weatherLink = weatherXml.rss.channel.link.XmlText>
		<!---
		<cfdump var="#weatherXml#">
		<cfdump var="#weatherXml.rss.channel.item.yweather_forecast#">
		--->
		<cfset currentDate = DateFormat(weatherXml.rss.channel.item.yweather_condition.XmlAttributes.date,"mm/dd/yyyy")>
		<cfset locationCity = weatherXml.rss.channel.yweather_location.XmlAttributes.city>
		<cfset locationCountry = weatherXml.rss.channel.yweather_location.XmlAttributes.country>
		
		
		<cfset currentCode = weatherXml.rss.channel.item.yweather_condition.XmlAttributes.code>
		<cfset currentTemp = weatherXml.rss.channel.item.yweather_condition.XmlAttributes.temp>
		<cfset currentText = weatherXml.rss.channel.item.yweather_condition.XmlAttributes.text>
		<!--- <cfoutput>#currentDate#</cfoutput> --->
		<cfquery name="updateCurrentWeather" datasource="#request.dsn#">
			if not exists(select * from WeatherForecast
				where ForecastDate=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#currentDate#">
				and ForecastCountry=<cfqueryparam cfsqltype="cf_sql_varchar" value="#locationCountry#"> and ForecastCity=<cfqueryparam cfsqltype="cf_sql_varchar" value="#locationCity#">
			) 
				INSERT INTO [WeatherForecast]
				           ([FeeddownloadDate]
				           ,[ForecastDate]
				           ,[ForecastCountry]
				           ,[ForecastCity]
				           ,[ConditionCode]
				           ,[ConditionText]
				           ,[High]
				           ,[Low]
				           ,[Link]
				           ,[CurrentTemp],FeedupdateDate,CurrentCode,CurrentText)
				     VALUES
				           (GetDate()
				           ,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#currentDate#">
				           ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#locationCountry#">
				           ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#locationCity#">
				           ,NULL
				           ,NULL
				           ,NULL
				           ,NULL
				           ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#weatherLink#">
				           ,<cfqueryparam cfsqltype="cf_sql_integer" value="#currentTemp#">,GetDate(),<cfqueryparam cfsqltype="cf_sql_integer" value="#currentCode#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#currentText#">)
			ELSE
				UPDATE [WeatherForecast]
				   SET [Link] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#weatherLink#">
				      ,[CurrentTemp] = <cfqueryparam cfsqltype="cf_sql_integer" value="#currentTemp#">
				      ,[FeedupdateDate] = GetDate()
				      ,[CurrentCode] = <cfqueryparam cfsqltype="cf_sql_integer" value="#currentCode#">
				      ,[CurrentText] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#currentText#">
				where ForecastDate=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#currentDate#">
				and ForecastCountry=<cfqueryparam cfsqltype="cf_sql_varchar" value="#locationCountry#"> and ForecastCity=<cfqueryparam cfsqltype="cf_sql_varchar" value="#locationCity#">		
		</cfquery>
		<cfset forecastCount = ArrayLen(weatherXml.rss.channel.item.yweather_forecast)>
		
		<cfloop from="1" to="#forecastCount#" index="i">
			<cfset forecast = StructNew()>
			<cfset forecast.Date = weatherXml.rss.channel.item.yweather_forecast[i].XmlAttributes.date>
			<cfset forecast.Code = weatherXml.rss.channel.item.yweather_forecast[i].XmlAttributes.code>
			<cfset forecast.High = weatherXml.rss.channel.item.yweather_forecast[i].XmlAttributes.high>
			<cfset forecast.Low = weatherXml.rss.channel.item.yweather_forecast[i].XmlAttributes.low>
			<cfset forecast.Text = weatherXml.rss.channel.item.yweather_forecast[i].XmlAttributes.text>
			<cfdump var="#forecast#">
			<cfquery name="updateCurrentWeather" datasource="#request.dsn#">
				if not exists(select * from WeatherForecast
					where ForecastDate=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#forecast.Date#">
					and ForecastCountry=<cfqueryparam cfsqltype="cf_sql_varchar" value="#locationCountry#"> and ForecastCity=<cfqueryparam cfsqltype="cf_sql_varchar" value="#locationCity#">
				) 
					INSERT INTO [WeatherForecast]
					           ([FeeddownloadDate]
					           ,[ForecastDate]
					           ,[ForecastCountry]
					           ,[ForecastCity]
					           ,[ConditionCode]
					           ,[ConditionText]
					           ,[High]
					           ,[Low]
					           ,[Link]
					           ,[CurrentTemp],FeedupdateDate,CurrentCode,CurrentText)
					     VALUES
					           (GetDate()
					           ,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#forecast.Date#">
					           ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#locationCountry#">
					           ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#locationCity#">
					           ,<cfqueryparam cfsqltype="cf_sql_integer" value="#forecast.Code#">
					           ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#forecast.Text#">
					           ,<cfqueryparam cfsqltype="cf_sql_numeric" value="#forecast.High#">
					           ,<cfqueryparam cfsqltype="cf_sql_numeric" value="#forecast.Low#">
					           ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#weatherLink#">
					           ,NULL,GetDate(),NULL,NULL)
				ELSE
					UPDATE [WeatherForecast]
					   SET [Link] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#weatherLink#">
					      ,[ConditionCode] = <cfqueryparam cfsqltype="cf_sql_integer" value="#forecast.Code#">
					      ,[FeedupdateDate] = GetDate()
					      ,[ConditionText] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#forecast.Text#">
					      ,[High] = <cfqueryparam cfsqltype="cf_sql_numeric" value="#forecast.High#">
					      ,[Low] = <cfqueryparam cfsqltype="cf_sql_numeric" value="#forecast.Low#">			      
					where ForecastDate=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#forecast.Date#">
					and ForecastCountry=<cfqueryparam cfsqltype="cf_sql_varchar" value="#locationCountry#"> and ForecastCity=<cfqueryparam cfsqltype="cf_sql_varchar" value="#locationCity#">		
			</cfquery>	
			
		</cfloop>







		<cfreturn />
	</cffunction>
</cfcomponent>