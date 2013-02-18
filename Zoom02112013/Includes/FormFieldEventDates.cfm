<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td class="rightAtd">
				*&nbsp;Event&nbsp;Start&nbsp;Date:
			</td>
			<td>
				<input name="EventStartDate" id="EventStartDate" value="#DateFormat(caller.EventStartDate,'dd/mm/yyyy')#" maxLength="20">
			</td>
		</tr>
		<tr>
			<td class="rightAtd">
				Event&nbsp;End&nbsp;Date:
			</td>
			<td>
				<input name="EventEndDate" id="EventEndDate" value="<cfif DateFormat(caller.EventEndDate,'dd/mm/yyyy') neq DateFormat(caller.EventStartDate,'dd/mm/yyyy')>#DateFormat(caller.EventEndDate,'dd/mm/yyyy')#</cfif>" maxLength="20">
			</td>
		</tr><script type="text/javascript">
			$(function() {
				$("##EventStartDate").datepicker({showOn: 'button', buttonImage: 'images/calendar.gif', buttonImageOnly: true, dateFormat: 'dd/mm/yy', changeMonth: true, changeYear: true
});
				$("##EventEndDate").datepicker({showOn: 'button', buttonImage: 'images/calendar.gif', buttonImageOnly: true, dateFormat: 'dd/mm/yy', changeMonth: true, changeYear: true
});
			});
		</script>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfset InDate=caller.EventStartDate>
	<cfinclude template="DateFormatter.cfm">
	<cfset LocalEventStartDate=OutDate>
	
	<cfset InDate=caller.EventEndDate>
	<cfinclude template="DateFormatter.cfm">
	<cfset LocalEventEndDate=OutDate>
	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set EventStartDate=<cfqueryparam value="#LocalEventStartDate#" cfsqltype="CF_SQL_DATE" null="#YesNoFormat(NOT LEN(LocalEventStartDate))#">,
		EventEndDate=<cfqueryparam value="#LocalEventEndDate#" cfsqltype="CF_SQL_DATE" null="#YesNoFormat(NOT LEN(LocalEventEndDate))#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
<cfelseif Action is "Validate">	
	if (!checkText(formObj.elements["EventStartDate"],"Event Start Date")) return false;
	if (!checkDateDDMMYYYY(formObj.elements["EventStartDate"],"Event Start Date")) return false;		
	if (!checkDateDDMMYYYY(formObj.elements["EventEndDate"],"Event End Date")) return false;			
		
</cfif>