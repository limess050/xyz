
<cfquery name="getTides"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#" cachedwithin="#createtimespan(0,0,15,0)#">
	select datePart(dy,t.TideDate) AS dayofYear, t.tideDate, t.High, t.Measurement,l.LunarDate,l.MoonTypeID,mt.descr,
	DATEADD(dd, 0, DATEDIFF(dd, 0, t.TideDate)) as tideDateOnly
	from Tides t With (NoLock) left join Lunar l With (NoLock)
	ON CONVERT(varchar(10), t.TideDate, 101)=CONVERT(varchar(10), l.LunarDate, 101)
	left join MoonType mt With (NoLock) ON l.moonTypeID = mt.moonTypeID
	where TideDate >= <cfqueryparam value="#DateFormat(NowInDar,'mm/dd/yyyy')# 12:00 AM" cfsqltype="CF_SQL_DATETIME" >
	AND TideDate <= <cfqueryparam value="#DateFormat(DateAdd('d',2,NowInDAR),'mm/dd/yyyy')# 11:59 PM" cfsqltype="CF_SQL_DATETIME" >
</cfquery>	

<cfquery name="getDays" dbtype="query">
	Select Distinct tideDateOnly, dayOfYear
	From getTides	
</cfquery>

			
<cfoutput query="getDays">
<div class="promo-tideandlunartitle tideTable" id="TidesHeader#dayOfYear#" <cfif CurrentRow neq "1">style="display:none;"</cfif>>
	<div class="float-left"><img src="images/sitewide/icon.tideandlunar.gif" alt="Tide and Lunar" width="28" height="39" align="left" /></div>
	<div class="float-left promo-tideandlunartitletext"><strong>TIDE AND LUNAR:</strong><br />
		<em>#DateFormat(TideDateOnly,'ddd., mmmm dd, yyyy')#</em></div>
	<div class="clear"></div>
</div>
</cfoutput>
<cfoutput query="getTides" group="dayOfYear">
	<cfset CurrentTideDate=TideDateOnly>
	<div class="promo-tideandlunar tideDiv" id="Tides#dayOfYear#" <cfif CurrentRow neq "1">style="display:none;"</cfif>>
		<ul>
			<cfoutput>
				<li><strong><cfif high>High<cfelse>Low</cfif></strong>&nbsp;&nbsp;&nbsp;#TimeFormat(tideDate,"h:mm tt")# | #measurement# m</li>
			</cfoutput>
			<cfif LunarDate NEQ "">
				<li><strong>#descr#</strong></li>
			</cfif>
			<li class="last"><cfloop query="getDays"><cfif CurrentTideDate neq TideDateOnly><a href="javascript:void(0);" class="ShowTides#DayOfYear#">#DateFormat(TideDateOnly,'mmm dd')#</a> | </cfif></cfloop><!--- <a href="">Mar. 28</a> | <a href="">Mar. 29</a> | ---><a href="#lh_getPageLink(6,'tides')#">View full schedule</a></li>
		</ul>
	</div>	 	
</cfoutput>
<script>
	 $(document).ready(function(){
		<cfoutput query="getTides" group="dayOfYear">
			$(".ShowTides#DayOfYear#").click(function() {
				$(".tideTable").hide();
				$(".tideDiv").hide();
				$("##TidesHeader#dayOfYear#").show();		
				$("##Tides#DayOfYear#").show();				
			});
		</cfoutput>
	 });	
</script>
<!--- 
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
</table>	 --->

