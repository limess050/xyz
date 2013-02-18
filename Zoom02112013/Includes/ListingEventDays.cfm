
<cfquery name="delEventDays"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	delete from ListingEventDays
	where ListingID = <cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfif Len(getListing.EventEndDate)>
	<cfset eventDuration = DateDiff("d",getListing.EventStartDate,getListing.EventEndDate) + 1>
<cfelse>
	<cfset eventDuration = 1>
</cfif>
				
<cfloop from="1" to="#EventDuration#" index="i">
	<cfset eventDate = DateAdd("d",Evaluate(i-1),getListing.EventStartDate)>	
	<cfquery name="insListingDates"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		insert into ListingEventDays(ListingID,ListingEventDate)
		values(<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">,
		<cfqueryparam value="#DateFormat(eventDate,'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE">)
	</cfquery>
</cfloop>
				
<cfif Len(getListing.RecurrenceID)>
				
				<cfquery name="getTermExpiration"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					select TermExpiration
					from ListingTypes
					where ListingTypeID = 15
				</cfquery>
				<cfset listingEndDate = DateAdd("d",getTermExpiration.TermExpiration,Now())>		
				<cfswitch expression="#getListing.RecurrenceID#">
					<cfcase value="1">
						
						
						<cfset dayDiff = DateDiff("d",getListing.EventStartDate,listingEndDate)>
						<cfloop from="1" to="#dayDiff#" index="i">
							<cfset thisDate = DateAdd("d",i,getListing.EventStartDate)>
							
							<cfif ListFind(ValueList(getRecurrenceDays.descr),DayOfWeekAsString(DayOfWeek(thisDate)))>
								<cfloop from="1" to="#EventDuration#" index="i">
									<cfset eventDate = DateAdd("d",Evaluate(i-1),thisDate)>	
									<cfquery name="insListingDates"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
										insert into ListingEventDays(ListingID,ListingEventDate)
										values(<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">,
										<cfqueryparam value="#DateFormat(eventDate,'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE">)
									</cfquery>
								</cfloop>
								
							</cfif>	
						</cfloop>
						
					</cfcase>
					<cfcase value="2">
						
						<cfset dayDiff = DateDiff("d",getListing.EventStartDate,listingEndDate)>
						<cfset counter = 1>
						<cfset counter2 = ListLen(ValueList(getRecurrenceDays.descr))>
						<cfloop from="1" to="#dayDiff#" index="i">
							<cfset thisDate = DateAdd("d",i,getListing.EventStartDate)>
							
							<cfif ListFind(ValueList(getRecurrenceDays.descr),DayOfWeekAsString(DayOfWeek(thisDate)))>
								
								<cfif counter EQ ListLen(ValueList(getRecurrenceDays.descr)) AND counter2 NEQ 0>
									<cfset counter2 = counter2 - 1>
								<cfelse>	
									<cfloop from="1" to="#EventDuration#" index="i">
									<cfset eventDate = DateAdd("d",Evaluate(i-1),thisDate)>	
									<cfquery name="insListingDates"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
										insert into ListingEventDays(ListingID,ListingEventDate)
										values(<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">,
										<cfqueryparam value="#DateFormat(eventDate,'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE">)
									</cfquery>
									</cfloop>
									<cfset counter = counter + 1>
									<cfset counter2 = ListLen(ValueList(getRecurrenceDays.descr))>
									
								</cfif>
							</cfif>	
							<cfif counter2 EQ 0>
								<cfset counter = 0>
							</cfif>	
						</cfloop>
						
					</cfcase>
					<cfcase value="3">
						<cfquery name="getRecurrenceMonth"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							select descr, daily
							from RecurrenceMonths 
							where recurrenceMonthID = <cfqueryparam value="#getListing.RecurrenceMonthID#" cfsqltype="CF_SQL_INTEGER">			
						</cfquery>				
						<cfset monthDiff = DateDiff("m",getListing.EventStartDate,listingEndDate)>
						
						<cfloop from="1" to="#monthDiff#" index="i">
							<cfif getRecurrenceMonth.daily>
								<cfset thisDate = CreateDate(Year(DateAdd("m",i,getListing.EventStartDate)),Month(DateAdd("m",i,getListing.EventStartDate)),getListing.RecurrenceMonthID)>
							<cfelse>
								<cfset occurenceArray = StructNew()>
								<cfset occurenceArray["Sunday"] = 1>
								<cfset occurenceArray["Monday"] = 2>
								<cfset occurenceArray["Tuesday"] = 3>
								<cfset occurenceArray["Wednesday"] = 4>
								<cfset occurenceArray["Thursday"] = 5>
								<cfset occurenceArray["Friday"] = 6>
								<cfset occurenceArray["Saturday"] = 7>
								<cfset occurence = ListFirst(getRecurrenceMonth.descr," ")>
								<cfset occurenceDay = ListLast(getRecurrenceMonth.descr," ")>
								<cfset occurenceDayNumeric = occurenceArray["#occurenceDay#"]>
								<cfset occurenceNumeric = REReplace(occurence,"st|nd|rd|th","","ALL")>
								
								<cfset dayOfMonth = GetNthOccOfDayInMonth(occurenceNumeric,occurenceDayNumeric,Month(DateAdd("m",i,getListing.EventStartDate)),Year(DateAdd("m",i,getListing.EventStartDate)))>
								<cfif dayOfMonth EQ -1>
									<cfset dayOfMonth = GetNthOccOfDayInMonth(4,occurenceDayNumeric,Month(DateAdd("m",i,getListing.EventStartDate)),Year(DateAdd("m",i,getListing.EventStartDate)))>
								</cfif>
								
								<cfset thisDate = CreateDate(Year(DateAdd("m",i,getListing.EventStartDate)),Month(DateAdd("m",i,getListing.EventStartDate)),dayOfMonth)>
							</cfif>
							
							<cfloop from="1" to="#EventDuration#" index="i">
								<cfset eventDate = DateAdd("d",Evaluate(i-1),thisDate)>	
								<cfquery name="insListingDates"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
									insert into ListingEventDays(ListingID,ListingEventDate)
									values(<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">,
									<cfqueryparam value="#DateFormat(eventDate,'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE">)
								</cfquery>
							</cfloop>
								
							
						</cfloop>
						
					</cfcase>
					<cfcase value="4">
									
						<cfset yearDiff = DateDiff("yyyy",getListing.EventStartDate,listingEndDate)>
						
						<cfloop from="1" to="#yearDiff#" index="i">
							
								<cfset thisDate = DateAdd("yyyy",i,getListing.EventStartDate)>
						
							<cfloop from="1" to="#EventDuration#" index="i">
								<cfset eventDate = DateAdd("d",Evaluate(i-1),thisDate)>	
								<cfquery name="insListingDates"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
									insert into ListingEventDays(ListingID,ListingEventDate)
									values(<cfqueryparam value="#getListing.ListingID#" cfsqltype="CF_SQL_INTEGER">,
									<cfqueryparam value="#DateFormat(eventDate,'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE">)
								</cfquery>
							</cfloop>
								
						</cfloop>
						
					</cfcase>
				</cfswitch>
			</cfif>	