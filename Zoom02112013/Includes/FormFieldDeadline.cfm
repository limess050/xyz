<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td class="rightAtd">
				<cfswitch expression="#caller.ListingTypeID#">
					<cfcase value="10,12">
						*&nbsp;Application&nbsp;Deadline:
					</cfcase>
					<cfdefaultCase>
						*&nbsp;Expiration&nbsp;Date:
					</cfdefaultcase>
				</cfswitch>				
			</td>
			<td>
				<input name="Deadline" id="Deadline" value="#DateFormat(caller.Deadline,'dd/mm/yyyy')#" maxLength="20">
				<input type="hidden" name="NowDate" id="NowDate" value="#DateFormat(Now(),'dd/mm/yyyy')#">
			</td>
		</tr>
		<script type="text/javascript">
			$(function() {
				$("##Deadline").datepicker({showOn: 'button', buttonImage: 'images/calendar.gif', buttonImageOnly: true, dateFormat: 'dd/mm/yy', changeMonth: true, changeYear: true, minDate: 0 
});
			});
		</script>

	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set Deadline=<cfqueryparam value="#DateFormat(caller.Deadline,'dd/mm/yyyy')#" cfsqltype="CF_SQL_DATE" null="#NOT LEN(caller.Deadline)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
	<!--- If this is a ListingTypeID=10 listing (Prof Job Opp) see if the expiration date needs to be updated.. --->
	<cfif caller.ListingTypeID is "10">		
		<cfset FromFrontEndListingForm=1>
		<cfinclude template="SetExpirationDate.cfm">
	</cfif>
<cfelseif Action is "Validate">
	<cfswitch expression="#caller.ListingTypeID#">
		<cfcase value="10,12">
			if (!checkText(formObj.elements["Deadline"],"Application Deadline")) return false;	
			if (!checkDateDDMMYYYY(formObj.elements["Deadline"],"Application Deadline")) return false;				
		</cfcase>
		<cfdefaultCase>
			if (!checkText(formObj.elements["Deadline"],"Expiration Date")) return false;	
			if (!checkDateDDMMYYYY(formObj.elements["Deadline"],"Expiration Date")) return false;	
		</cfdefaultcase>
	</cfswitch>			
	var dateInFuture=1;
	var monthfield=document.f1.Deadline.value.split("/")[1]
	var dayfield=document.f1.Deadline.value.split("/")[0]
	var yearfield=document.f1.Deadline.value.split("/")[2]
	var deadline = new Date(monthfield+"/"+dayfield+"/"+yearfield);
	
	var nowmonthfield=document.f1.NowDate.value.split("/")[1]
	var nowdayfield=document.f1.NowDate.value.split("/")[0]
	var nowyearfield=document.f1.NowDate.value.split("/")[2]
	var today = new Date(nowmonthfield+"/"+nowdayfield+"/"+nowyearfield);
	if (deadline<today) {
	  	dateInFuture=0;
	}	
	if (dateInFuture==0) {
		alert('The <cfif ListFind("10,11",caller.ListingTypeID)>Deadline<cfelse>Expiration Date</cfif> cannot be in the past.');
		formObj.elements["Deadline"].focus();
		return false;
	}
</cfif>
