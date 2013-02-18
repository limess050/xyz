
<cfquery name="getTides" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#" cachedwithin="#createtimespan(0,1,0,0)#">
	select datePart(dy,t.TideDate) AS dayofYear, t.tideDate, t.High, t.Measurement,l.LunarDate,l.MoonTypeID,mt.descr
	from Tides t left join Lunar l
	ON CONVERT(varchar(10), t.TideDate, 101)=CONVERT(varchar(10), l.LunarDate, 101)
	left join MoonType mt ON l.moonTypeID = mt.moonTypeID
	where TideDate >= <cfqueryparam value="#DateFormat(Now(),'mm/dd/yyyy')# 12:00 AM" cfsqltype="CF_SQL_DATETIME" >
	AND TideDate <= <cfqueryparam value="#DateFormat(DateAdd('d',2,Now()),'mm/dd/yyyy')# 11:59 PM" cfsqltype="CF_SQL_DATETIME" >
</cfquery>	



<table  border="0" cellspacing="0" cellpadding="0" width="200" class="tides">
<cfoutput query="getTides" group="dayOfYear">
	<cfset counter = 0>
	<cfoutput>
		<cfset counter = counter + 1>
	</cfoutput>
<tr>
	<td style="width:40px" rowspan="<cfif lunarDate NEQ "">#counter + 2#<cfelse>#counter + 1#</cfif>">
		<cfif DateFormat(Now(),"mm/dd/yy") EQ DateFormat(tideDate,"mm/dd/yy")>
			Today
		<cfelse>
			#DateFormat(tideDate,"ddd mmm d, yyyy")#
		</cfif>
	</td>
</tr>
<cfoutput>	
<tr>	
	<td <cfif high>class="alt"</cfif> nowrap="nowrap">
		<cfif high>High<cfelse>Low</cfif> #TimeFormat(tideDate,"h:mm tt")# / #measurement# m
	</td>
</tr>
</cfoutput>
<cfif LunarDate NEQ "">
	<tr>
		<td id="lunar">#descr#</td>
	</tr>	
</cfif>

</cfoutput>
</table>
<table style="border:none">
<tr><td colspan="2"><a href="page.cfm?pageID=6" style="font-size:10px">Click here to view full Tide/Moon Schedule</tr>
</table>	

