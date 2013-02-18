
<cfsetting showdebugoutput="no">

<cffunction name="GetEvents" access="remote" returntype="string" displayname="Returns the total Listing Fees of all the  passed ListingIDs">
	<cfargument name="start" required="yes">
	<cfargument name="end" required="yes">
	<cfargument name="CategoryID" required="yes">
	
	<cfparam name="MonthView" default="1">
	<cfparam name="DayView" default="0">
	<cfparam name="WeekView" default="0">
	<cfparam name="EventsLimit" default="4">
	
	<cfset rString=''>
		
	<cfset FromDate=DateFormat(dateAdd("s", start, "01/01/1970"),'mm/dd/yyyy')>
	<cfset ToDate=DateFormat(dateAdd("s", end, "01/01/1970"),'mm/dd/yyyy')>
	
	<cfif end-start is "86400">
		<cfset DayView="1">
		<cfset MonthView="0">
		<cfset EventsLimit="100"><!--- Show 'all' events when looking at a single day --->
	<cfelseif end-start is "604800">
		<cfset WeekView="1">
		<cfset MonthView="0">
		<cfset EventsLimit="100"><!--- Show 'all' events when looking at week view --->
	</cfif>	
	
	<cfif not MonthView><!--- "See All" item is first on week and day, but last on month --->
		<cfloop from="#FromDate#" to="#ToDate#" index="D">
			<cfif Len(rString)>
				<cfset rString=rString & ",">
			</cfif>
			<cfset rString=rString & '{"title":"See All Events This Day","start":"#DateFormat(D,"yyyy-mm-dd")# 12:00","url":"#Request.HTTPURL#/SearchEvents?SearchStartDate=#DateFormat(D,'dd/mm/yyyy')#&SearchEndDate=#DateFormat(D,'dd/mm/yyyy')#","allDay":false,"className":"seeAll"}'>
		</cfloop>
	</cfif>
	
	<!--- Get all events on adjacent dates as well so as to insure all events get called even if browser is in a different timezone.  --->
	<cfset ToDate=dateAdd("d", 1, ToDate)>
	<cfset FromDate=dateAdd("d", -1, FromDate)>
	
	<cfloop from="#FromDate#" to="#ToDate#" index="D">
		<cfset "EventCount#DateFormat(d,'mmddyyyy')#" = 0>
	</cfloop>
	
	<cfloop from="1" to="4" index="i">
		<cfquery name="getEvents" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select Distinct L.ListingID, L.ListingTitle, L.EventStartDate,
			CASE 
			WHEN L.EventEndDate is null or DateAdd(day, datediff(day,0, L.EventStartDate), 0) = DateAdd(day, datediff(day,0, L.EventEndDate), 0)
			THEN LD.ListingEventDate + CONVERT(VARCHAR,L.EventStartDate,108) 
			ELSE L.EventStartDate END as StartDate, 
			CASE 
			WHEN L.EventEndDate is null 
			THEN NULL
			WHEN DateAdd(day, datediff(day,0, L.EventStartDate), 0) = DateAdd(day, datediff(day,0, L.EventEndDate), 0)
			THEN LD.ListingEventDate + CONVERT(VARCHAR,L.EventEndDate,108)
			ELSE L.EventEndDate END as EndDate, 
			L.EventEndDate,
			'' as Randomizer
			From ListingsView L
			Inner Join ListingEventDays LD on L.ListingID=LD.ListingID
			Where ListingEventDate < <cfqueryparam value="#ToDate#" cfsqltype="CF_SQL_DATE">
			and LD.ListingEventDate >= <cfqueryparam value="#FromDate#" cfsqltype="CF_SQL_DATE">
			<cfinclude template="LiveListingFilter.cfm">
			<cfif Len(CategoryID)>
				and exists (Select ListingID from ListingCategories LC Where L.ListingID=LC.ListingID and CategoryID=<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">)
			</cfif>
			<cfswitch expression="#i#">
				<cfcase value="1"><!--- Multi-Day events --->
					and L.EventEndDate is not null
					and DateAdd(day, datediff(day,0, L.EventStartDate), 0) <> DateAdd(day, datediff(day,0, L.EventEndDate), 0)
				</cfcase>
				<cfcase value="2"><!--- Not recurring or Yearly recurring --->
					and (L.RecurrenceID is null or L.RecurrenceID = '4')
					and (EventEndDate is null or DateAdd(day, datediff(day,0, L.EventStartDate), 0) = DateAdd(day, datediff(day,0, L.EventEndDate), 0))
				</cfcase>
				<cfcase value="3"><!--- Monthly --->
					and L.RecurrenceID = 3
					and (EventEndDate is null or DateAdd(day, datediff(day,0, L.EventStartDate), 0) = DateAdd(day, datediff(day,0, L.EventEndDate), 0))
				</cfcase>
				<cfcase value="4"><!--- Weekly and Bi-Weekly --->
					and L.RecurrenceID in (1,2)
					and (EventEndDate is null or DateAdd(day, datediff(day,0, L.EventStartDate), 0) = DateAdd(day, datediff(day,0, L.EventEndDate), 0))
				</cfcase>
			</cfswitch>			
			Order By StartDate, EndDate
		</cfquery>
		
		<cfif i is "4"><!--- Randomize Weekly and BiWeekly results set --->
			<cfloop query="getEvents">
			   <cfset querySetCell(getEvents,"Randomizer",rand(),currentRow)>
			</cfloop>			
			<cfquery dbType="query" name="getEvents">
				Select ListingID, ListingTitle, EventStartDate,
				StartDate, EndDate, EventEndDate, Randomizer
				From getEvents
				Order By Randomizer
			</cfquery>
		</cfif>
		
		<cfoutput query="getEvents">
			<cfif i is "1"><!--- Multi-Day events (not included in limit of 7 per day) --->
				<cfif Len(rString)>
					<cfset rString=rString & ",">
				</cfif>
				<cfset rString=rString & '{"id":#ListingID#,"title":"#JSStringFormat(ListingTitle)#","start":"#DateFormat(StartDate,"yyyy-mm-dd")# 00:00","end":"#DateFormat(EndDate,"yyyy-mm-dd")# #TimeFormat(EndDate,"HH:mm")#","url":"#Request.HTTPURL#/ListingDetail?ListingID=#ListingID#","allDay":true}'>
			<cfelse>
				<cfif Evaluate('EventCount' & DateFormat(StartDate,'mmddyyyy')) lt EventsLimit><!--- Only show first 7 events for a given day  --->
					<cfif Len(rString)>
						<cfset rString=rString & ",">
					</cfif>
					<cfif MonthView>
						<cfset rString=rString & '{"id":#ListingID#,"title":"#JSStringFormat(ListingTitle)#","start":"#DateFormat(StartDate,"yyyy-mm-dd")# 00:00","url":"#Request.HTTPURL#/ListingDetail?ListingID=#ListingID#","allDay":false}'>
					<cfelse>
						<cfset rString=rString & '{"id":#ListingID#,"title":"#JSStringFormat(ListingTitle)#","start":"#DateFormat(StartDate,"yyyy-mm-dd")# #TimeFormat(StartDate,"HH:mm")#","url":"#Request.HTTPURL#/ListingDetail?ListingID=#ListingID#","allDay":false}'>
					</cfif>
				</cfif>
				<cfset "EventCount#DateFormat(StartDate,'mmddyyyy')#"= Evaluate('EventCount' & DateFormat(StartDate,'mmddyyyy')) + 1>
			</cfif>
		</cfoutput>
	</cfloop>
	
	<cfif MonthView><!--- "See All" item is first on week and day, but last on month --->
		<cfloop from="#FromDate#" to="#ToDate#" index="D">
			<cfif Len(rString)>
				<cfset rString=rString & ",">
			</cfif>
			<cfset rString=rString & '{"title":"See All Events This Day","start":"#DateFormat(D,"yyyy-mm-dd")# 00:00","url":"#Request.HTTPURL#/SearchEvents?SearchStartDate=#DateFormat(D,'dd/mm/yyyy')#&SearchEndDate=#DateFormat(D,'dd/mm/yyyy')#","allDay":false,"className":"seeAll"}'>
		</cfloop>
	</cfif>
	
	<cfset rString="[" & rString & "]">
	
 	<cfreturn rString>
</cffunction>