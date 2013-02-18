<cfsetting requesttimeout="300">

<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfset allFields="FirstName,Email,Password,AlertSectionIDs,AreaID,GenderID,BirthMonthID,BirthYearID,SelfIdentifiedTypeID,EducationLevelID,AlertSectionID,CategoryIDs,LocationIDs,PriceMinUS,PriceMaxUS,PriceMinTZS,PriceMaxTZS,AddAlertSectionID">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="AlertSectionID,AreaID,GenderID,BirthMonthID,BirthYearID,EducationLevelID,SelfIdentifiedTypeID,AddAlertSectionID">

<cfif Len(FirstName)><!--- Submission from previous form --->
	<!--- Check for existing Alert with matching Email Address --->
	<cfset DuplicateEmail = "0">
	<cfquery name="ConfirmEmailUnique" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select Email 
		From Alerts 
		Where Email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Email#">
	</cfquery>
	<cfif ConfirmEmailUnique.RecordCount>
		<cfset DuplicateEmail = "1">
	</cfif>
	<cfset session.NewAlert["FirstName"] = FirstName>
	<cfset session.NewAlert["Email"] = Email>
	<cfset session.NewAlert["Password"] = Password>
	<cfset session.NewAlert["AlertSectionIDs"] = AlertSectionIDs>
	<cfset session.NewAlert["AreaID"] = AreaID>
	<cfset session.NewAlert["GenderID"] = GenderID>
	<cfset session.NewAlert["BirthMonthID"] = BirthMonthID>
	<cfset session.NewAlert["BirthYearID"] = BirthYearID>
	<cfset session.NewAlert["SelfIdentifiedTypeID"] = SelfIdentifiedTypeID>
	<cfset session.NewAlert["EducationLevelID"] = EducationLevelID>
	<cfif DuplicateEmail>
		<cflocation url="page.cfm?PageID=#Request.AddAlertPageID#&Step=1&Em=#Email#" addToken="No">
		<cfabort>
	</cfif>
<cfelseif Len(AddAlertSectionID)>
	<cfset session.NewAlert["AlertSectionIDs"] = ListAppend(session.NewAlert["AlertSectionIDs"],AddAlertSectionID)>
<cfelseif Len(AlertSectionID)>
	<cfset AlertSectionIDCounter = ListValueCount(session.NewAlert["AlertSectionIDs"],AlertSectionID)>
	
	<cfset session.NewAlert["AlertSectionID"][AlertSectionID][AlertSectionIDCounter]["CategoryIDs"] = CategoryIDs>
	<cfset session.NewAlert["AlertSectionID"][AlertSectionID][AlertSectionIDCounter]["LocationIDs"] = LocationIDs>
	<cfset session.NewAlert["AlertSectionID"][AlertSectionID][AlertSectionIDCounter]["PriceMinUS"] = PriceMinUS>
	<cfset session.NewAlert["AlertSectionID"][AlertSectionID][AlertSectionIDCounter]["PriceMaxUS"] = PriceMaxUS>
	<cfset session.NewAlert["AlertSectionID"][AlertSectionID][AlertSectionIDCounter]["PriceMinTZS"] = PriceMinTZS>
	<cfset session.NewAlert["AlertSectionID"][AlertSectionID][AlertSectionIDCounter]["PriceMaxTZS"] = PriceMaxTZS>
</cfif>

<cfparam name="ShowLocations" default="1">
<cfparam name="ShowPriceRanges" default="0">
<cfparam name="LimitSelectionCount" default="0">
<cfparam name="ShowConfirmationStep" default="1">
<cfloop list="#session.NewAlert["AlertSectionIDs"]#" index="i">
	<cfset AlertSectionIDCounter = ListValueCount(session.NewAlert["AlertSectionIDs"],i)>
	<cfif not StructKeyExists(session.NewAlert["AlertSectionID"],i)>
		<cfset ShowConfirmationStep = "0">
		<cfinclude template="AlertSectionForm.cfm">
		<cfbreak>
	<cfelseif not StructKeyExists(session.NewAlert["AlertSectionID"][i],AlertSectionIDCounter)>
		<cfset ShowConfirmationStep = "0">
		<cfinclude template="AlertSectionForm.cfm">
		<cfbreak>
	</cfif>
</cfloop>

<cfif ShowConfirmationStep>
	<lh:MS_SitePagePart id="bodyConfirmationRequest" class="body">	
	<cfoutput>
	<form name="f1" action="page.cfm?PageID=#Request.AddAlertPageID#" method="post">
	</cfoutput>
		<input type="hidden" name="Step" value="3">
		<table border="0" cellspacing="0" cellpadding="0" class="datatable">
			<cfset SortedAlertSectionIDs = "">
			<cfoutput query="AlertSections">
				<cfloop list="#session.NewAlert["AlertSectionIDs"]#" index="i">
					<cfif SelectValue is i>
						<cfset SortedAlertSectionIDs = ListAppend(SortedAlertSectionIDs,i)>
					</cfif>
				</cfloop>
			</cfoutput>
			<cfset session.NewAlert["AlertSectionIDs"] = SortedAlertSectionIDs>
			<cfset ProcessedAlertSectionIDs = "">
			<cfoutput>
				<cfloop list="#session.NewAlert["AlertSectionIDs"]#" index="i">
					<cfset AlertSectionIDCounter = ListValueCount(ProcessedAlertSectionIDs,i) + 1>
					<cfset ProcessedAlertSectionIDs = ListAppend(ProcessedAlertSectionIDs, i)>
					<tr>
						<td>
							#AlertSectionStruct[i]#
						</td>
						<td>
							<cfloop list="#session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["CategoryIDs"]#" index="c">
								#AlertCategoryStruct[c]#<br>
							</cfloop>
						</td>
						<td>
							<cfif Len(session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["LocationIDs"])>
								<cfloop list="#session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["LocationIDs"]#" index="loc">
									#AlertLocationStruct[loc]#<br>
								</cfloop>
							<cfelse>
								&nbsp;
							</cfif>
						</td>							
					</tr>
					<cfif Len(session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["PriceMinUS"])>
						<tr>
							<td style="padding: 0px 5px 7px 0;">&nbsp;</td>
							<td colspan="2" style="padding: 0px 5px 7px 0;">
								Min ($US): #NumberFormat(session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["PriceMinUS"],0)# - Max ($US): #NumberFormat(session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["PriceMaxUS"],0)#<br>
								Min (TSH): #NumberFormat(session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["PriceMinTZS"],0)# - Max (TSH): #NumberFormat(session.NewAlert["AlertSectionID"][i][AlertSectionIDCounter]["PriceMaxTZS"],0)#
							</td>
							<td style="padding: 0px 5px 7px 0;">&nbsp;</td>
						</tr>
					</cfif>
				</cfloop>
			</cfoutput>
			<tr>
				<td colspan="3">
					<cfoutput query="AlertSections">
						<a href="page.cfm?PageID=#Request.AddAlertPageID#&AddAlertSectionID=#SelectValue#&Step=2">Add <cfif ListFind(Session.NewAlert["AlertSectionIDs"],SelectValue)>another<cfelse>a</cfif> #SelectText# Alert</a><br>
					</cfoutput>	
				</td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td colspan="2">
					&nbsp;<br>
					<input type="submit" name="Next" value="Next >>" class="btn">
				</td>
			</tr>	
		</table>
	</form>	
</cfif>
	
	
	
	
