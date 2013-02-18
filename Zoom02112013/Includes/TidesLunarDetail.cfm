<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset Request.TidesPageID="6">


<cfparam name="StartDate" default="#Now()#">
<cfparam name="EndDate" default="#Now()#">
<cfset allFields="startDate,endDate">
<cfinclude template="setVariables.cfm">

<cfif not IsDate(StartDate) or not IsDate(EndDate)>
	<cfset StartDate = Now()>
	<cfset EndDate = Now()>
</cfif>

<cfquery name="ParentSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select PS.ParentSectionID as SelectValue, PS.Title as SelectText
	From ParentSectionsView PS
	Where PS.Active=1
	Order by PS.OrderNum
</cfquery>

<cfquery name="getTides"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	select datePart(dy,t.TideDate) AS dayofYear, t.tideDate, t.High, t.Measurement,l.LunarDate,l.MoonTypeID,mt.descr,su.sunriseDate,ss.sunsetDate
	from Tides t left join Lunar l
	ON CONVERT(varchar(10), t.TideDate, 101)=CONVERT(varchar(10), L.LunarDate, 101)
	left join MoonType mt ON l.moonTypeID = mt.moonTypeID
	left join Sunrise su
	ON CONVERT(varchar(10), t.TideDate, 101)=CONVERT(varchar(10), su.SunriseDate, 101)
	left join Sunset ss
	ON CONVERT(varchar(10), t.TideDate, 101)=CONVERT(varchar(10), ss.SunsetDate, 101)
	where TideDate >= <cfqueryparam value="#DateFormat(StartDate,'mm/dd/yyyy')# 12:01 AM" cfsqltype="CF_SQL_DATETIME" >
	AND TideDate <= <cfqueryparam value="#DateFormat(EndDate,'mm/dd/yyyy')# 11:59 PM" cfsqltype="CF_SQL_DATETIME" >
</cfquery>	



<script>
	function validateForm(formObj) {		
		
		return true;
	}
</script>

<cfoutput>
<form name="f1" action="page.cfm?PageID=#Request.TidesPageID#" method="post" ONSUBMIT="return validateForm(this)">
	<table style="width:100%">
		
		<tr>
			<td>
				Date Range: <input name="StartDate" id="StartDate" value="#DateFormat(StartDate,'mm/dd/yyyy')#" maxLength="20"> - 
							<input name="EndDate" id="EndDate" value="#DateFormat(EndDate,'mm/dd/yyyy')#" maxLength="20"> 
							<input type="submit" name="Submit" value="Submit">
			</td>
			
		</tr>
	
		
		<script type="text/javascript">
			$(function() {
				$("##StartDate").datepicker({showOn: 'button', buttonImage: 'images/calendar.gif', buttonImageOnly: true, dateFormat: 'mm/dd/yy', changeMonth: true, changeYear: true
});
				$("##EndDate").datepicker({showOn: 'button', buttonImage: 'images/calendar.gif', buttonImageOnly: true, dateFormat: 'mm/dd/yy', changeMonth: true, changeYear: true
});
			});
		</script>
	</table>
</form>

<br>
<p><a href="page.cfm?PageID=#Request.TidesPageID#&EndDate=#DateAdd('d',7,Now())#">Next 7 Days</a> | <a href="page.cfm?PageID=#Request.TidesPageID#&EndDate=#DateAdd('d',30,Now())#">Next 30 Days</a> | <a href="page.cfm?PageID=#Request.TidesPageID#&EndDate=#DateAdd('d',90,Now())#">Next 90 Days</a></p>
</cfoutput>
<br>
<cfset showLastHigh = false>
<cfset showLastLow = false>
<cfoutput query="getTides" group="dayOfYear">
	<cfset counter = 0>
	<cfoutput>
		<cfif counter EQ 0 AND not high>
			<cfset counter = counter + 1>
		</cfif>
		<cfset counter = counter + 1>
	</cfoutput>
	<cfif counter GTE 4>
		<cfset showLastLow = true>
	</cfif>	
	<cfif counter EQ 5>
		<cfset showLastHigh = true>
	</cfif>	
</cfoutput>
<table class="tides-full" cellspacing="0" style="width:800px;">
<tr class="headerrow">
	<td class="toprow">Day</td>
	<td class="toprow">High</td>
	<td class="toprow">Low</td>
	<td class="toprow">High</td>
	<cfif showLastLow>
		<td class="toprow">Low</td>
	</cfif>
	<cfif showLastHigh>
		<td class="toprow">High</td>
	</cfif>
	<td class="toprow">Moon</td>
	<td class="toprow">Sunrise</td>
	<td class="toprow">Sunset</td>
</tr>
<cfoutput query="getTides" group="dayOfYear">
	<tr <cfif dayofyear MOD 2 EQ 0>class="alt"</cfif>>
		<td>#DateFormat(tideDate,"ddd mmm d, yyyy")#</td>
		<cfset counter = 0>
		<cfoutput>
			<cfif counter EQ 0 AND not High><cfset counter = counter + 1><td style="width:100px">&nbsp;</td></cfif>
			<td>#TimeFormat(TideDate,"h:mm tt")# / #measurement# m</td>
			<cfset counter = counter + 1>
		</cfoutput>
		<cfif counter EQ 3 AND showLastLow>
			<td>&nbsp;</td>
			<cfif showLastHigh>
				<td>&nbsp;</td>
			</cfif>
		</cfif>
		<cfif counter EQ 4 AND showLastHigh>
			<td>&nbsp;</td>
		</cfif>
		<td>&nbsp;<cfif LunarDate NEQ "">#descr#</cfif></td>
		<td>#TimeFormat(SunriseDate,"h:mm tt")#</td>
		<td>#TimeFormat(SunsetDate,"h:mm tt")#</td>
	</tr>	
</cfoutput>

</table>

