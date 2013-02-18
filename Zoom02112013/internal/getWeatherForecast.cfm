<cfscript>
	weather = CreateObject("component","CFC.weatherCFC");
	weather.getWeather(locationCode = "TZXX0001", tempUnits = "c");
</cfscript>