<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>



<cfif Action is "Form">	
	<!--- See if account has an active Featured Listing before allowing Recurrence. --->
	<cfquery name="checkForFeaturedListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ListingID
		From ListingsView L
		Left Outer Join Orders O on L.OrderID=O.OrderID
		Where O.UserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
		and L.ListingTypeID in (1,2,14) 
		and (L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= #application.CurrentDateInTZ#)<!--- Has Featured Listing --->
		<cfinclude template="LiveListingFilter.cfm">
	</cfquery>
	<cfif not checkForFeaturedListings.RecordCount and (not Len(LinkID) or (Len(LinkID) and not Len(caller.getListing.RecurrenceID)))>
		<script type="text/javascript">
			var recurrenceAlertShown = 0;
			$(function() {
				$("#RecurrenceID").focus(function() {
					if (recurrenceAlertShown==0){
						alert('We\'re sorry, but only businesses with a featured business listing may post repeating events.');
						$("#RecurrenceID option:first").attr('hidden','hidden');
				  		$("#RecurrenceID").val('');
				  	recurrenceAlertShown = 1;
					}				  
				});				
			});
		</script>
	</cfif>
	<cfquery name="Recurrences" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select RecurrenceID as SelectValue, Descr as SelectText 
		From Recurrences
		Order By RecurrenceID
	</cfquery>
	<cfquery name="RecurrenceDays" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select RecurrenceDayID as SelectValue, Descr as SelectText 
		From RecurrenceDays
		Order By RecurrenceDayID
	</cfquery>
	<cfquery name="RecurrenceMonths" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select RecurrenceMonthID as SelectValue, Descr as SelectText, Daily
		From RecurrenceMonths
		Order By RecurrenceMonthID
	</cfquery>
	<cfquery name="RecurrenceMonthsDay" dbtype="query">
		select * from RecurrenceMonths
		where Daily = 1
	</cfquery>
	<cfquery name="RecurrenceMonthsWeekday" dbtype="query">
		select * from RecurrenceMonths
		where Daily = 0
	</cfquery>
	<cfif caller.RecurrenceMonthID NEQ "" AND caller.RecurrenceMonthID GT 30>
		<cfquery name="getDescr" dbtype="query">
			select selectText from RecurrenceMonths
			where SelectValue = <cfqueryparam value="#caller.RecurrenceMonthID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset descr = getDescr.selectText>
	<cfelse>
		<cfset descr = "">	
	</cfif>
	<cfoutput>		
		<tr>
			<td class="rightAtd">
				&nbsp;Repeats?:
			</td>
			<td>
				<select name="RecurrenceID" ID="RecurrenceID">
					<option value="">-- Select --</option>
					<cfif checkForFeaturedListings.RecordCount or (Len(LinkID) and Len(caller.getListing.RecurrenceID))>
						<cfloop query="Recurrences">
							<cfif selectValue NEQ 4>
								<option value="#SelectValue#" <cfif SelectValue is caller.RecurrenceID>selected</cfif>>#SelectText#</option>
							</cfif>
						</cfloop>
					<cfelse>
						<option value="">-- Not Available --</option>
					</cfif>
				</select>
			</td>
		</tr>
		<tr id="RecurrenceDayID_TR">
			<td class="rightAtd">
				&nbsp;Repeats Weekly or Bi-Weekly On:
			</td>
			<td>
			<table><tr>
			<cfloop query="RecurrenceDays">
				<td>				
					<input type="checkbox" name="RecurrenceDayID" value="#SelectValue#" <cfif ListFind(caller.RecurrenceDayID,selectValue)>checked</cfif>> #SelectText#
				</td>
				<cfif currentRow EQ 4>
					</tr><tr>
				</cfif>	
			</cfloop>
			</tr></table>	
			</td>	
		</tr>
		<tr id="RecurrenceMonthID_TR">
			<td class="rightAtd">
				&nbsp;Repeats Monthly:<br>
				(choose one)
			</td>
			<td>
			<table>
				<tr>
					<td>				
						<input type="radio" name="RepeatsMonthly" value="1" <cfif caller.RecurrenceMonthID NEQ "" AND caller.RecurrenceMonthID LTE 30>checked</cfif>> Repeats the 
						<select name="RecurrenceMonthID">
							<cfloop query="RecurrenceMonthsDay">
								<option value="#SelectValue#" <cfif SelectValue EQ caller.RecurrenceMonthID>selected</cfif>>#Replace(SelectText," Day","")#</option>
							</cfloop>
						</select> day of each month
					</td>
				</tr>
				<tr>	
					<td>				
						<input type="radio" name="RepeatsMonthly" value="2" <cfif caller.RecurrenceMonthID NEQ "" AND caller.RecurrenceMonthID GT 30>checked</cfif>> Repeats the 
						<select name="RepeatsMonthWeekDayNumber">
							<option value="1st" <cfif Find("1st",descr)>selected</cfif>>First</option>
							<option value="2nd" <cfif Find("2nd",descr)>selected</cfif>>Second</option>
							<option value="3rd" <cfif Find("3rd",descr)>selected</cfif>>Third</option>
							<option value="4th" <cfif Find("4th",descr)>selected</cfif>>Fourth</option>
							<option value="5th" <cfif Find("5th",descr)>selected</cfif>>Last</option>
						</select>
						<select name="RepeatsMonthWeekDay">
							<option value="Monday" <cfif Find("Monday",descr)>selected</cfif>>Monday</option>
							<option value="Tuesday" <cfif Find("Tuesday",descr)>selected</cfif>>Tuesday</option>
							<option value="Wednesday" <cfif Find("Wednesday",descr)>selected</cfif>>Wednesday</option>
							<option value="Thursday" <cfif Find("Thursday",descr)>selected</cfif>>Thursday</option>
							<option value="Friday" <cfif Find("Friday",descr)>selected</cfif>>Friday</option>
							<option value="Saturday" <cfif Find("Saturday",descr)>selected</cfif>>Saturday</option>
							<option value="Sunday" <cfif Find("Sunday",descr)>selected</cfif>>Sunday</option>
						</select> of each month
					</td>
				</tr>
				
			
			</table>	
			</td>	
		</tr>
		
	</cfoutput>
<cfelseif Action is "Process">

	

	<cfif caller.RepeatsMonthly NEQ "">
		<cfif RepeatsMonthly EQ 1>
			<cfset repeatsMonthID = caller.RecurrenceMonthID>
		</cfif>
		<cfif RepeatsMonthly EQ 2>
			<cfquery name="getRecurrenceMonthID"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				select recurrenceMonthID
				from RecurrenceMonths
				where Descr = <cfqueryparam value="#RepeatsMonthWeekDayNumber# #RepeatsMonthWeekDay#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<cfset repeatsMonthID = getRecurrenceMonthID.RecurrenceMonthID>
		</cfif>
	<cfelse>
		<cfset repeatsMonthID = "">	
	</cfif>
	<cfif caller.RecurrenceID NEQ 3>
		<cfset repeatsMonthID = "">
	</cfif>
	
	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set RecurrenceID=<cfqueryparam value="#caller.RecurrenceID#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.RecurrenceID)#">,
		RecurrenceMonthID=<cfqueryparam value="#RepeatsMonthID#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(RepeatsMonthID)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
		
		delete from ListingRecurrences
		where listingID = <cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif caller.RecurrenceDayID NEQ "">
		<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			insert into ListingRecurrences(ListingID,RecurrenceDayID)
			select <cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">,
			RecurrenceDayID from RecurrenceDays where RecurrenceDayID IN (<cfqueryparam value="#caller.RecurrenceDayID#" cfsqltype="CF_SQL_INTEGER" list="true">)
		</cfquery>
	</cfif>	
<cfelseif Action is "Validate">			
	if(document.f1.RecurrenceID.value == 1 || document.f1.RecurrenceID.value == 2)
		if (!checkChecked(formObj.elements["RecurrenceDayID"],"Repeats Weekly or Bi-Weekly On")) return false;
		
	if(document.f1.RecurrenceID.value == 3)
		if (!checkChecked(formObj.elements["RepeatsMonthly"],"Repeats Monthly")) return false;
		
		if(document.f1.RecurrenceID.value != ''){
			if(document.f1.EventStartDate.value != document.f1.EventEndDate.value && document.f1.EventEndDate.value != ''){
			alert('Events that span multiple days may not repeat.')
			return false;
			}}
			
						
</cfif>
