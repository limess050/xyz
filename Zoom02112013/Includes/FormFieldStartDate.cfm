<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td class="rightAtd">
				Start&nbsp;Date:
			</td>
			<td>
				<input name="EventStartDate" id="EventStartDate" value="#DateFormat(caller.EventStartDate,'dd/mm/yyyy')#" maxLength="20">
			</td>
		</tr>
		<script type="text/javascript">
			$(function() {
				$("##EventStartDate").datepicker({showOn: 'button', buttonImage: 'images/calendar.gif', buttonImageOnly: true, dateFormat: 'dd/mm/yy', changeMonth: true, changeYear: true, minDate: 0 
});
			});
		</script>

	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set EventStartDate=<cfqueryparam value="#DateFormat(caller.EventStartDate,'dd/mm/yyyy')#" cfsqltype="CF_SQL_DATE" null="#NOT LEN(caller.EventStartDate)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">		
	//if (!checkText(formObj.elements["EventStartDate"],"Start Date")) return false;	
	if (!checkDateDDMMYYYY(formObj.elements["EventStartDate"],"Start Date")) return false;	
	var startDateInFuture=1;
	var monthfield=document.f1.EventStartDate.value.split("/")[1]
	var dayfield=document.f1.EventStartDate.value.split("/")[0]
	var yearfield=document.f1.EventStartDate.value.split("/")[2]
	var startDate = new Date(monthfield+"/"+dayfield+"/"+yearfield);
	
	var nowmonthfield=document.f1.NowDate.value.split("/")[1]
	var nowdayfield=document.f1.NowDate.value.split("/")[0]
	var nowyearfield=document.f1.NowDate.value.split("/")[2]
	var today = new Date(nowmonthfield+"/"+nowdayfield+"/"+nowyearfield);
	if (startDate<today) {
	  	startDateInFuture=0;
	}	
	if (startDateInFuture==0) {
		alert('The Start Date cannot be in the past.');
		formObj.elements["EventStartDate"].focus();
		return false;
	}
</cfif>
