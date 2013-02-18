
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Alert Emails Activity Report by Sections">
<cfinclude template="../Lighthouse/Admin/Header.cfm">
<cfparam name="ImpressionDate" default="">
<cfparam name="ImpressionDate_end" default="">
<cfparam name="ImpressionDateWhereClause" default="">
<cfparam name="ImpressionDateCriteriaLabel" default="Email Alert Activity">

<!--- Convert to US Date Format for use in query --->
<cfset InDate = ImpressionDate>
<cfinclude template="../includes/DateFormatter.cfm">
<cfset ImpressionDate_ForSearch = OutDate>

<cfset InDate = ImpressionDate_end>
<cfinclude template="../includes/DateFormatter.cfm">
<cfset ImpressionDate_end_ForSearch = OutDate>


<cfif Len(ImpressionDate_ForSearch) and IsDate(ImpressionDate_ForSearch) and Len(ImpressionDate_end_ForSearch) and IsDate(ImpressionDate_end_ForSearch)>
	<cfset ImpressionDateWhereClause=" and ImpressionDate >= '#DateFormat(ImpressionDate_ForSearch,'mm/dd/yyyy')#' and ImpressionDate <= '#DateFormat(ImpressionDate_end_ForSearch,'mm/dd/yyyy')#'">
<cfelseif Len(ImpressionDate_ForSearch) and IsDate(ImpressionDate_ForSearch)>
	<cfset ImpressionDateWhereClause=" and ImpressionDate = '#DateFormat(ImpressionDate_ForSearch,'mm/dd/yyyy')#'">
<cfelseif Len(ImpressionDate_end_ForSearch) and IsDate(ImpressionDate_end_ForSearch)>
	<cfset ImpressionDateWhereClause=" and ImpressionDate = '#DateFormat(ImpressionDate_end_ForSearch,'mm/dd/yyyy')#'">
</cfif>
<cfset AlertDateCountWhereClause=ReplaceNoCase(ImpressionDateWhereClause,"ImpressionDate","DateCreated","ALL")>

<cfquery name="getSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select S.SectionID as SelectValue,
	CASE WHEN S.SectionID in (39,40,50) THEN (Select Title From Sections Where SectionID = 5) + ' - ' + Title ELSE S.Title END as SelectText,
	(Select IsNull(SUM(Count),0) 
		From AlertImpressions with (NOLOCK)
		Where SectionID=S.SectionID 
		#PreserveSingleQuotes(ImpressionDateWhereClause)#) as TotalImpressions,
	(Select Count(Distinct UserID)
		From Alerts A with (NOLOCK)
		Inner Join AlertSections ASe with (NOLOCK) on A.AlertID=ASe.AlertID
		Where Expired=0
		and ASe.SectionID=S.SectionID
		#PreserveSingleQuotes(AlertDateCountWhereClause)#) as TotalAlertSubscribers
	From Sections S with (NOLOCK)
	Where S.SectionID in (4,8,37,55,59,39,40,50)
	Order by SelectText, S.Title
</cfquery>

<cfoutput>
	<script language="JavaScript" src="#Request.AppVirtualPath#/public.js" type="text/javascript"></script>
</cfoutput>
	
<script type="text/javascript">
dojo.addOnLoad(function(){
	dojo.require("dojo.widget.*");
	dojo.require("dojo.widget.DatePicker");
});
	
function validateForm(formObj) {
	return (1 == 1					
			&& checkDateDDMMYYYY(formObj.elements["ImpressionDate"],"From Date")
			&& checkDateDDMMYYYY(formObj.elements["ImpressionDate_end"],"To Date")					
	)
}
</script>

<cfoutput>
	<h1 style="margin:0px">#pg_title#</h1>
	<p></p>
	
	<form name="f1" method="post" action="AlertImpressionsReport.cfm" ONSUBMIT="return validateForm(this)">
		<TABLE CLASS=ADDTABLE CELLPADDING=5 CELLSPACING=0>
			<TR id="ImpressionDate_TR">
				<TD CLASS=SEARCHLABELCELL SCOPE=row><LABEL FOR="ImpressionDate">Email Sent Date</LABEL></TD>
				<TD CLASS=SEARCHFIELDCELL> 
			<label for="ImpressionDate">from</label>
			<input type="TEXT" id="ImpressionDate" name="ImpressionDate" size="15" value="#ImpressionDate#" >
			<img style="vertical-align:middle;cursor:pointer;" alt="Select a date" 
				onclick="lh.ShowPopupCalendar(getEl('ImpressionDate'),'DD/MM/YYYY')"
				src="../Lighthouse/dojo/src/widget/templates/images/dateIcon.gif"/>
			<label for="ImpressionDate_end">to</label>

			<input type="TEXT" name="ImpressionDate_end" id="ImpressionDate_end" size="15" value="#ImpressionDate_end#" >
			<img style="vertical-align:middle;cursor:pointer;" alt="Select a date" 
				onclick="lh.ShowPopupCalendar(getEl('ImpressionDate_end'),'DD/MM/YYYY')"
				src="../Lighthouse/dojo/src/widget/templates/images/dateIcon.gif"/>
			</TD>
			</TR>
			<TR>
			<TD COLSPAN=2 ALIGN=RIGHT>
				<INPUT TYPE="SUBMIT" VALUE="Submit" class=button>
			</TD>
		</TR>
		</table>
	</form>
	<cfif Len(ImpressionDate) and IsDate(ImpressionDate) and Len(ImpressionDate_end) and IsDate(ImpressionDate_end)>
		<cfset ImpressionDateCriteriaLabel = ImpressionDateCriteriaLabel & " for: #DateFormat(ImpressionDate,'dd/mm/yyyy')# through #DateFormat(ImpressionDate_end,'dd/mm/yyyy')#">
	<cfelseif Len(ImpressionDate) and IsDate(ImpressionDate)>
		<cfset ImpressionDateCriteriaLabel = ImpressionDateCriteriaLabel & " for: #DateFormat(ImpressionDate,'dd/mm/yyyy')#">
	<cfelseif Len(ImpressionDate_end) and IsDate(ImpressionDate_end)>
		<cfset ImpressionDateCriteriaLabel = ImpressionDateCriteriaLabel & " for: #DateFormat(ImpressionDate_end,'dd/mm/yyyy')#">
	</cfif>
	<p>
		<strong>#ImpressionDateCriteriaLabel#</strong>
	</p>
</cfoutput>

<table class="VIEWTABLE" cellspacing="0" cellpadding="0" border="0">
	<tr>
		<td class="VIEWHEADERCELL">
			Section
		</td>
		<td class="VIEWHEADERCELL">
			Emails Sent
		</td>
		<td class="VIEWHEADERCELL">
			Subscribers
		</td>
	</tr>
	<cfoutput query="getSections">
		<tr class="VIEWROW<cfif CurrentRow MOD 2 is "0"> alternate</cfif>">
			<td>
				#SelectText#
			</td>
			<td>
				#TotalImpressions#
			</td>
			<td>
				#TotalAlertSubscribers#
			</td>
		</tr>
	</cfoutput>
</table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">