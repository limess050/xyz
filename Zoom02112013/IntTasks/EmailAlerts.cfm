<!--- Scheduled process to send out Email Alerts --->
<!--- Schedule to run every 15 minutes --->

<cfsetting RequestTimeout="1900">
<cfset startTime = now()>

<cfparam name="ShowDebug" default="1">

<cfinclude template="../includes/PlainTextForEmail.cfm">

<!--- Flag Listings that have been live for over two days, so the getAlertMatches query only has to look a the handful of recent Listings --->
<cfif Request.environment is "live">
	<cfquery name="updateListings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set AlertsComplete_fl = 1
		Where ListingID in (Select ListingID 
							From Listings
							Where DateSort < DATEADD(d,-2,<cfqueryparam value="#DateFormat(application.CurrentDateInTZ,'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE">)
							and AlertsComplete_fl=0)
	</cfquery>
</cfif>

<cfif not IsDefined('application.AlertImpressions')>
	<cfset application.AlertImpressions= structNew()>
</cfif>

<cfquery name="getAlerts" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
 	Select A.AlertID, A.ConfirmationID,
	U.ContactFirstName as FirstName, U.Username as Email
	From Alerts A with (NOLOCK)
	Inner join LH_Users U with (NOLOCK) on A.UserID=U.UserID
	Where (A.LastRan is null or A.LastRan < <cfqueryparam value="#DateFormat(application.CurrentDateInTZ,'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE">)
	and A.ConfirmationReceived is not null
	and Len(U.Username)>0
	and A.Expired=0
	and exists (Select AlertID From AlertSections with (NOLOCK) Where AlertID=A.AlertID)
	Order By A.LastRan
</cfquery>

<cfquery name="AlertSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select SectionID as SelectValue,
	CASE WHEN SectionID in (39,40,50) THEN (Select Title From Sections Where SectionID = 5) + ' - ' + Title ELSE Title END as SelectText
	From Sections with (NOLOCK)
	Where SectionID in (4,8,37,55,59,39,40,50)
	Order by SelectText, Title
</cfquery>
<cfset AlertSectionsOrdered = ValueList(AlertSections.SelectValue)>
<cfset AlertSectionStruct = StructNew()>
<cfoutput query="AlertSections">
	<cfset AlertSectionStruct[SelectValue] = SelectText>
</cfoutput>
<cfif ShowDebug and not getAlerts.RecordCount>
	All Alerts have already been processed today.
</cfif>
 <cfoutput query="getAlerts" maxrows=200>	
	<cftry>
		<cfquery name="getAlertSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select ASe.AlertSectionID,  ASe.SectionID, ASe.PriceMinUs, ASe.PriceMaxUS, ASe.PriceMinTZS, ASe.PriceMaxTZS,
			ASCa.CategoryID, ASL.LocationID
			From AlertSections ASe with (NOLOCK)
			Inner Join AlertSectionCategories ASCa with (NOLOCK) on ASe.AlertSectionID=ASCa.AlertSectionID
			Left Outer Join AlertSectionLocations ASL with (NOLOCK) on ASe.AlertSectionID=ASL.AlertSectionID
			Where ASe.AlertID = <cfqueryparam value="#AlertID#" cfsqltype="CF_SQL_INTEGER">
			Order By ASe.AlertSectionID, ASCa.CategoryID, ASL.LocationID
		</cfquery>
		<cfinclude template="../includes/AlertsSearchSyntax.cfm">		
		
	 	<cfquery name="getAlertMatches"	datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select Distinct L.ListingID, L.ListingTitle, L.ShortDescr, L.ListingTypeID, 
			L.SquareFeet, L.SquareMeters, L.Make, L.Model, L.VehicleYear,
			LPS.ParentSectionID, LS.SectionID
			From ListingsView L with (NOLOCK)
			Inner Join ListingParentSections LPS with (NOLOCK) on L.ListingID=LPS.ListingID
			Left Outer Join ListingSections LS with (NOLOCK) on L.ListingID=LS.ListingID
			Where L.AlertsComplete_fl = 0
			<cfinclude template="../includes/LiveListingFilter.cfm">
			and not exists 
				(Select ListingID 
				From AlertListings AL with (NOLOCK)
				Where ListingID = L.ListingID
				and AlertID=<cfqueryparam value="#AlertID#" cfsqltype="CF_SQL_INTEGER">)
			and (#AlertSectionsClauses#)
			Order by SectionID
		</cfquery>
		<cftransaction>
			<cfif getAlertMatches.RecordCount>
				<cfset AlertID = AlertID>
				<cfset ListingLinks = "">
				<cfloop list="#AlertSectionsOrdered#" index="s">
					<cfif ListFind(ValueList(getAlertSections.SectionID),s)>
						<cfset ListingLinks = ListingLinks & "<p><strong>#AlertSectionStruct[s]#</strong><br>">
						<cfquery name="getAlertMatchesForSection" dbtype="query">
							Select ListingID, ListingTitle, ListingTypeID, 
							ShortDescr, SquareMeters, SquareFeet, Make, Model, VehicleYear,
							SectionID,ParentSectionID
							From getAlertMatches
							Where SectionID = <cfqueryparam value="#s#" cfsqltype="CF_SQL_INTEGER"> or ParentSectionID = <cfqueryparam value="#s#" cfsqltype="CF_SQL_INTEGER">
						</cfquery>
						<cfif GetAlertMatchesForSection.RecordCount>
							<cfif StructKeyExists(application.AlertImpressions,s)>
								<cfset application.AlertImpressions[s] = application.AlertImpressions[s] + 1>
							<cfelse>
								<cfset application.AlertImpressions[s] = 1>
							</cfif>						
							<cfloop query="GetAlertMatchesForSection">
								<cfif SectionID is s or ParentSectionID is s>
									<cfquery name="logAlertListing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
										Insert into AlertListings
										(AlertID, ListingID)
										VALUES
										(<cfqueryparam value="#AlertID#" cfsqltype="CF_SQL_INTEGER">,<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">)
									</cfquery>
									<cfswitch expression="#ListingTypeID#">
										<cfcase value="5"><!--- FSBO Motorcycles, Mopeds, ATVs, & Vibajaji & FSBO Commercial Trucks --->
										<cfsavecontent variable="VehicleTitle">
											#VehicleYear#<cfif Len(Make)>  #Make#</cfif><cfif Len(Model)> #Model#</cfif>
										</cfsavecontent>
											<cfset ListingTitleDisplay = VehicleTitle>
										</cfcase>
										<cfcase value="7"><!--- Housing & Real Estate Commercial Rental --->
											<cfif Len(SquareFeet) or Len(SquareMeters)>
												<cfif Len(SquareFeet)>
													<cfset LocalSquareFeet=SquareFeet>
													<cfset LocalSquareMeters=0.092903*SquareFeet>
												<cfelse>
													<cfset LocalSquareMeters=SquareMeters>
													<cfset LocalSquareFeet=10.7639*SquareMeters>
												</cfif>												
												<cfset ListingTitleDisplay = ListingTitle & ' #Round(LocalSquareFeet)# ft<sup>2</sup>/#NumberFormat(LocalSquareMeters,",.9")# m<sup>2</sup>'>
											<cfelse>
												<cfset ListingTitleDisplay = ListingTitle>
											</cfif>
										</cfcase>
										<cfcase value="10,12"><!--- Jobs --->
											<cfset ListingTitleDisplay = ShortDescr>
										</cfcase>
										<cfdefaultcase>
											<cfset ListingTitleDisplay = ListingTitle>
										</cfdefaultcase>
									</cfswitch>
									<cfsavecontent variable="ListingLink"><p>#ListingTitleDisplay# <a href="#request.httpURL#/ListingDetail?ListingID=#ListingID#&utm_source=ZoomTanzania&utm_medium=Email&utm_campaign=Alerts">#request.httpURL#/ListingDetail?ListingID=#ListingID#&utm_source=ZoomTanzania&utm_medium=Email&utm_campaign=Alerts</a></p></cfsavecontent>
									<cfset ListingLinks = ListingLinks & ListingLink>
								</cfif>
							</cfloop>
						<cfelse>
							<cfset ListingLinks = ListingLinks & 'There are no new listings that match your #AlertSectionStruct[s]# alert criteria.  You can edit your alert criteria to be less specific by clicking the "Edit Alert Criteria" link.<br>'>
						</cfif>						
					</cfif>
				</cfloop>
				<!--- #AlertID#: #ListingLinks# --->
				<cfset edit="0">
				<cfsavecontent variable="EmailTextPlain">
Hi #FirstName#,
The following new listings match your alert criteria.  From your friends at ZoomTanzania.com

#textMessage(ListingLinks)#
					
Edit Alert Criteria: #Request.httpsURL#/#lh_getPageLink(Request.ManageAlertPageID,'manageAlerts')#?ConfirmationID=#ConfirmationID#
					
Cancel All Alert Criteria: #Request.httpsURL#/#lh_getPageLink(Request.ManageAlertPageID,'manageAlerts')#?ConfirmationID=#ConfirmationID#&DeleteAll=Y
					
				</cfsavecontent>
				<cfsavecontent variable="EmailTextHTML">
					Hi #FirstName#,<br>The following new listings match your alert criteria.  From your friends at ZoomTanzania.com
					<p><a href="#Request.httpsURL#/#lh_getPageLink(Request.ManageAlertPageID,'manageAlerts')#?ConfirmationID=#ConfirmationID#" style="font-size: 18px;font-weight: bold;">Edit Alert Criteria</a><br>
					<a href="#Request.httpsURL#/#lh_getPageLink(Request.ManageAlertPageID,'manageAlerts')#?ConfirmationID=#ConfirmationID#&DeleteAll=Y" style="font-size: 18px;font-weight: bold;">Cancel All Alert Criteria</a></p>
					#ListingLinks#
					<p><a href="#Request.httpsURL#/#lh_getPageLink(Request.ManageAlertPageID,'manageAlerts')#?ConfirmationID=#ConfirmationID#" style="font-size: 18px;font-weight: bold;">Edit Alert Criteria</a><br>
					<a href="#Request.httpsURL#/#lh_getPageLink(Request.ManageAlertPageID,'manageAlerts')#?ConfirmationID=#ConfirmationID#&DeleteAll=Y" style="font-size: 18px;font-weight: bold;">Cancel All Alert Criteria</a></p>
				</cfsavecontent>

				<cfmail to="#Email#" from="#Request.AlertsFrom#" subject="New Listing Alerts from ZoomTanzania.com #DateFormat(application.CurrentDateInTZ,'dd/mm/yy')#" type="HTML">					
					<cfmailpart type="text/plain" charset="utf-8">#EmailTextPlain#</cfmailpart>
					<cfmailpart type="text/html" charset="utf-8">#EmailTextHTML#</cfmailpart>
				</cfmail>
				<cfif ShowDebug>
				Alerts for #Email#: <strong>Sent</strong><br>
				</cfif>
			<cfelseif ShowDebug>
				Alerts for #Email#: <strong>No Matches</strong><br>
			</cfif>
			<cfquery name="logRan" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Update Alerts
				Set LastRan=<cfqueryparam value="#DateFormat(application.CurrentDateInTZ,'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE">
				<cfif getAlertMatches.RecordCount>, LastSent=<cfqueryparam value="#DateFormat(application.CurrentDateInTZ,'mm/dd/yyyy')#" cfsqltype="CF_SQL_DATE"></cfif>
				Where AlertID=<cfqueryparam value="#AlertID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cftransaction>
		<cfcatch type = "Database">
			Database error. <cfoutput>#AlertID#<br></cfoutput>
		</cfcatch>
	</cftry>
	<!--- Run program for close to, but less than 10 minutes. Abort if time passed --->
    <cfif Abs(DateDiff("s", now(), startTime)) gt 540>
		Quitting after 9 minutes.
		<cfabort>
    </cfif>
 </cfoutput>
 