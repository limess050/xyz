

<cfif ListFind("1,19",LocationID) and not ListFind(AreaIDs,1)>
	<cfset AreaIDs = ListAppend(AreaIDs, 1)>
</cfif>
<cfif ListFind("9,16,24",LocationID) and not ListFind(AreaIDs,2)>
	<cfset AreaIDs = ListAppend(AreaIDs, 2)>
</cfif>
<cfif ListFind("10,12,13",LocationID) and not ListFind(AreaIDs,3)>
	<cfset AreaIDs = ListAppend(AreaIDs, 3)>
</cfif>
<cfif ListFind("18",LocationID) and not ListFind(AreaIDs,4)>
	<cfset AreaIDs = ListAppend(AreaIDs, 4)>
</cfif>
<cfif ListFind("15,17",LocationID) and not ListFind(AreaIDs,5)>
	<cfset AreaIDs = ListAppend(AreaIDs, 5)>
</cfif>
<cfif ListFind("20",LocationID) and not ListFind(AreaIDs,6)>
	<cfset AreaIDs = ListAppend(AreaIDs, 6)>
</cfif>
<cfif ListFind("22",LocationID) and not ListFind(AreaIDs,7)>
	<cfset AreaIDs = ListAppend(AreaIDs, 7)>
</cfif>
<cfif ListFind("11,21,23",LocationID) and not ListFind(AreaIDs,8)>
	<cfset AreaIDs = ListAppend(AreaIDs, 8)>
</cfif>
<cfif ListFind("14",LocationID) and not ListFind(AreaIDs,9)>
	<cfset AreaIDs = ListAppend(AreaIDs, 9)>
</cfif>
<cfif ListFind("4",LocationID) and not ListFind(AreaIDs,10)>
	<cfset AreaIDs = ListAppend(AreaIDs, 10)>
</cfif>