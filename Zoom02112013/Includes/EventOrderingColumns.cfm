<cfoutput>
CASE WHEN (Select Min(ListingEventDate) From ListingEventDays With (NoLock) Where ListingID=L.ListingID) <= #application.CurrentDateInTZ#
		THEN (Select Max(ListingEventDate) From ListingEventDays With (NoLock) Where ListingID=L.ListingID) <!--- Multipday event already in progress, so set event sort date to event's end date --->
		ELSE (Select Min(ListingEventDate) From ListingEventDays With (NoLock) Where ListingID=L.ListingID) <!--- All others use Event's Start Date --->
		END as EventSortDate,	
	CASE WHEN RecurrenceID is NULL and (EventEndDate is null or convert(varchar,EventStartDate,101) = convert(varchar,EventEndDate,101)) THEN 1 <!--- Non Repeating Single day --->
		WHEN RecurrenceID is NULL and (Select Min(ListingEventDate) From ListingEventDays With (NoLock) Where ListingID=L.ListingID) <= #application.CurrentDateInTZ# THEN 6 <!--- Multiday events that have already started --->
		WHEN RecurrenceID is null THEN 5 <!--- Multiday events that have not started --->
		WHEN RecurrenceID=3 THEN 2 <!--- Monthly Repeating --->
		WHEN RecurrenceID=2 THEN 3 <!--- Bi weekly Repeating --->
		WHEN RecurrenceID=1 THEN 4 <!--- Weekly Repeating --->
		ELSE 10 END as EventRank,<!--- Yearly Repeating --->
		
</cfoutput>
