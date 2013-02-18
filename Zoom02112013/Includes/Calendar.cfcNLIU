<cfsetting showdebugoutput="false">
<cffunction name="createCalendar" output="false" returntype="string" access="remote">
    	

    <cfargument name="curMonth" required="yes" type="numeric">
    <cfargument name="curYear" required="yes" type="numeric">
    
    <cfset var filename = "#cgi.script_name#">
    <cfset var outString = "">
    <cfset var firstDay = CreateDate(curYear, curMonth, 1)>
    <cfset var firstDayDigit = DayOfWeek(FirstDay)>
    <cfset var thisDay = 1>
    <cfset var h = 1>
	
	<cfquery name="getEvents" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		select l.title,le.ListingID,datepart(d,le.ListingEventDate) AS EventDay from listingEventDays le
		inner join listingsview l ON l.listingID = le.listingID
		where datepart(m,ListingEventDate) = #Month(firstDay)#
		AND datepart (yyyy,ListingEventDate) = #Year(firstDay)#
		and l.DeletedAfterSubmitted=0 and L.Active=1 and L.Reviewed=1 and L.ExpirationDate >= getDate()
		Order by ListingEventDate
	</cfquery>
	<cfset events = StructNew()>
	<cfoutput query="getEvents" group="EventDay">
		
		<cfset "events.event_#EventDay#" = ArrayNew(1)>
		<cfoutput>
			<cfset eventData = StructNew()>
			<cfset eventData.ListingID = ListingID>
			<cfset eventData.Title = Title>
			<cfset ArrayAppend(Evaluate("events.event_"&EventDay),eventData)>
		</cfoutput>
	
	</cfoutput>
    
    <cfsavecontent variable="outString">
		
    <cfoutput>
	<div id="eventscalendar">
	<div class="title"><a href="javascript:void(0)" onclick="getCalendar(#month(dateadd("M",-1,firstDay))#,#year(dateadd("M",-1,firstDay))#)" class="black">&lt;</a>&nbsp;#Ucase(DateFormat(firstDay, "mmmm"))#&nbsp;#DateFormat(firstDay, "yyyy")#&nbsp;<a href="javascript:void(0)" onclick="getCalendar(#month(dateadd("M",1,firstDay))#,#year(dateadd("M",1,firstDay))#)" class="black">&gt;</a></div>	
    <table cellspacing="0">
  

    <tr>
        <th>Su</th>
        <th>M</th>
        <th>Tu</th>
        <th>W</th>
        <th>Th</th>
        <th>F</th>
        <th>S</th>
    </tr>    
    </cfoutput>
    </cfsavecontent>
    
    <!--- if it isn't sunday, then we need to if space over to start on the corrent day of week --->
    <cfif firstDayDigit neq 1>
        <cfloop from="1" to="#DayOfWeek(FirstDay)-1#" index="h">
            <cfset outString &= "<td>&nbsp;</td>">
        </cfloop>
    </cfif>
    
    <!--- loop thru all the dates in this month --->
    <cfloop from="1" to="#DaysInMonth(firstDay)#" index="thisDay">
    
        <!--- is it Sunday? if so start new row. --->
        <cfif DayOfWeek(CreateDate(curYear, curMonth, thisDay)) eq 1><cfset outString &= "<tr>"></cfif>
        
        <!--- insert a day --->
        
        
        <!--- is it today? append correct classes to above td --->
        <cfif (CreateDate(curYear, curMonth, thisDay) eq CreateDate(year(now()),month(now()),day(now()))) AND not isDefined("events.event_"&thisDay)>
            <cfset outString &= "<td class='today'>"&thisDay>
			
		<cfelseif isDefined("events.event_"&thisDay)>
			<cfsavecontent variable="newString">
				<cfoutput>
					<td class='date_has_event'>#thisDay#
					<div class="events">
							<ul>
					<cfloop array="#evaluate('events.event_'&thisDay)#" index="thisEvent">
						
								<li>
									<span class="headline"><a href="#request.httpurl#/listingDetail?ListingID=#thisEvent.listingID#">#thisEvent.title#</a></span>
								</li>
								    
					</cfloop>
					    <li><hr /></li>
                                <li>
									<span class="headline"><a href="#request.httpurl#/showallEvents?StartDate=#CreateDate(curYear, curMonth, thisDay)#&EndDate=#CreateDate(curYear, curMonth, thisDay)#">Click here to see all events</a></span>
								</li>
								 <li>
									<span class="headline"><a href="#request.httpurl#/postalisting?ParentSectionID=46&ListingSectionID=59">Post your event</a></span>
								</li>
							</ul>
						</div>
				</cfoutput>
			</cfsavecontent>
			<cfset outString &= newString>
		<cfelse>
			<cfset outString &= "<td>"&thisDay>
        
        </cfif>
        
        
        <!--- begin insert data for this day --->
       <!--- <cfset outString &= "calendar data here">--->
        <!--- end insert data for this day --->
        
        <!--- close out this day --->
        <cfset outString &= "</td>">
        
        <!--- is it the last day of the month? if so, fill row with blanks. --->
        <cfif (thisDay eq DaysInMonth(firstDay))>
            <cfloop from="1" to="#(7-DayOfWeek(CreateDate(curYear, curMonth, thisDay)))#" index="h">
                <cfset outString &= "<td class='blank'>&nbsp;</td>">
            </cfloop>
        </cfif>

        <cfif DayOfWeek(CreateDate(curYear, curMonth, thisDay)) eq 7>
            <cfset outString &= "</tr>">
        </cfif>
    </cfloop>
    
    <cfset outString &= "</table><div class='next'>Next <a href='"&request.httpurl&"/ShowAllEvents?StartDate="&DateFormat(Now(),'mm-dd-yy')&"&EndDate="&DateFormat(DateAdd('d',7,Now()),'mm-dd-yy')&"'>7 Days</a>&nbsp;|&nbsp;<a href='"&request.httpurl&"/ShowAllEvents?StartDate="&DateFormat(Now(),'mm-dd-yy')&"&EndDate="&DateFormat(DateAdd('d',30,Now()),'mm-dd-yy')&"'>30 Days</a></div><div class='next'><a href='postalisting?ParentSectionID=59'>Post an Event</a></div>">
	
    <cfreturn outString />
</cffunction>
