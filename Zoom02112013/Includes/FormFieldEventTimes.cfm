<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>



<cfif Action is "Form">	
	
	<cfoutput>		
		<tr>
			<td class="rightAtd">
				*&nbsp;Event&nbsp;Start&nbsp;Time:
			</td>
			<td>
				<select name="EventStartTime" ID="EventStartTime">
					<option value="">-- Select --
					<option value="12:00 AM" <cfif "12:00 AM" is caller.EventStartTime>Selected</cfif>>12:00 AM
					<option value="12:30 AM" <cfif "12:30 AM" is caller.EventStartTime>Selected</cfif>>12:30 AM
					<cfloop from="1" to="11" index="i">
						<option value="#i#:00 AM" <cfif "#i#:00 AM" is caller.EventStartTime>Selected</cfif>>#i#:00 AM
						<option value="#i#:30 AM" <cfif "#i#:30 AM" is caller.EventStartTime>Selected</cfif>>#i#:30 AM
					</cfloop>
					<option value="12:00 PM" <cfif "12:00 PM" is caller.EventStartTime>Selected</cfif>>12:00 PM
					<option value="12:30 PM" <cfif "12:30 PM" is caller.EventStartTime>Selected</cfif>>12:30 PM
					<cfloop from="1" to="11" index="i">
						<option value="#i#:00 PM" <cfif "#i#:00 PM" is caller.EventStartTime>Selected</cfif>>#i#:00 PM
						<option value="#i#:30 PM" <cfif "#i#:30 PM" is caller.EventStartTime>Selected</cfif>>#i#:30 PM
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td class="rightAtd">
				&nbsp;Event&nbsp;End&nbsp;Time:
			</td>
			<td>
				<select name="EventEndTime" ID="EventEndTime">
					<option value="">-- Select --
					<option value="12:00 AM" <cfif "12:00 AM" is caller.EventEndTime>Selected</cfif>>12:00 AM
					<option value="12:30 AM" <cfif "12:30 AM" is caller.EventEndTime>Selected</cfif>>12:30 AM
					<cfloop from="1" to="11" index="i">
						<option value="#i#:00 AM" <cfif "#i#:00 AM" is caller.EventEndTime>Selected</cfif>>#i#:00 AM
						<option value="#i#:30 AM" <cfif "#i#:30 AM" is caller.EventEndTime>Selected</cfif>>#i#:30 AM
					</cfloop>
					<option value="12:00 PM" <cfif "12:00 PM" is caller.EventEndTime>Selected</cfif>>12:00 PM
					<option value="12:30 PM" <cfif "12:30 PM" is caller.EventEndTime>Selected</cfif>>12:30 PM
					<cfloop from="1" to="11" index="i">
						<option value="#i#:00 PM" <cfif "#i#:00 PM" is caller.EventEndTime>Selected</cfif>>#i#:00 PM
						<option value="#i#:30 PM" <cfif "#i#:30 PM" is caller.EventEndTime>Selected</cfif>>#i#:30 PM
					</cfloop>
				</select>
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">
	<cfset InDate=caller.EventStartDate>
	<cfinclude template="DateFormatter.cfm">
	<cfset LocalEventStartDate=OutDate>
	
	<cfset InDate=caller.EventEndDate>
	<cfinclude template="DateFormatter.cfm">
	<cfset LocalEventEndDate=OutDate>
	
	<cfquery name="updateListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set EventStartDate=<cfqueryparam value="#LocalEventStartDate# #caller.EventStartTime#" cfsqltype="CF_SQL_DATETIME" null="#NOT LEN(LocalEventStartDate)#">
		<cfif Len(caller.EventEndTime)>,EventEndDate=<cfif not Len(LocalEventEndDate)><cfqueryparam value="#LocalEventStartDate# #caller.EventEndTime#" cfsqltype="CF_SQL_DATETIME" null="#YesNoFormat(NOT LEN(LocalEventStartDate))#"><cfelse><cfqueryparam value="#LocalEventEndDate# #caller.EventEndTime#" cfsqltype="CF_SQL_DATETIME" null="#YesNoFormat(NOT LEN(LocalEventEndDate))#"></cfif></cfif>
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
<cfelseif Action is "Validate">			
		if (!checkText(formObj.elements["EventStartTime"],"Event Start Time")) return false;					
</cfif>
