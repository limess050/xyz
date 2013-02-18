
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Impressions Activity Report by Sections">
<cfinclude template="../Lighthouse/Admin/Header.cfm">
<cfparam name="ImpressionDate" default="">
<cfparam name="ImpressionDate_end" default="">
<cfparam name="ImpressionDateWhereClause" default="">
<cfparam name="ImpressionDateCriteriaLabel" default="Impressions Activity">

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

<cfquery name="getSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select Title, SectionID, OrderNum,
	(Select IsNull(SUM(Count),0) 
		From SectionImpressions 
		Where SectionID=PS.SectionID 
		#PreserveSingleQuotes(ImpressionDateWhereClause)#) as TotalImpressions,
	(Select IsNull(SUM(Count),0) 
		From ListingEmailInquiryImpressions L 
		Inner Join ListingCategories LC on L.ListingID=LC.ListingID 
		Inner Join Categories C on LC.CategoryID=C.CategoryID 
		Where C.SectionID=PS.SectionID 
		or C.ParentSectionID=PS.SectionID
		#PreserveSingleQuotes(ImpressionDateWhereClause)#) as TotalEmailInquiries
	From PagesectionsView pS
	Order by OrderNum
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
	
	<form name="f1" method="post" action="SectionImpressionsReport.cfm" ONSUBMIT="return validateForm(this)">
		<TABLE CLASS=ADDTABLE CELLPADDING=5 CELLSPACING=0>
			<TR id="ImpressionDate_TR">
				<TD CLASS=SEARCHLABELCELL SCOPE=row><LABEL FOR="ImpressionDate">Impression Date</LABEL></TD>
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
			Impressions
		</td>
		<td class="VIEWHEADERCELL">
			Email Inquiries
		</td>
	</tr>
	<cfoutput query="getSections">
		<tr class="VIEWROW<cfif CurrentRow MOD 2 is "0"> alternate</cfif>">
			<td>
				#Title#
			</td>
			<td>
				#TotalImpressions#
			</td>
			<td>
				#TotalEmailInquiries#
			</td>
		</tr>
	</cfoutput>
</table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">