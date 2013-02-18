
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfif not edit and  IsDefined('session.UserID') and Len(session.UserID) and isDefined('cookie.LoggedIn') and cookie.LoggedIn is "1"><!--- Already logged in --->
	<cflocation url="#lh_getPageLink(Request.ManageAlertPageID,'manageAlerts')#" AddToken="No">
	<cfabort>
</cfif>

<cfparam name="Step" default="1">

<cfif Step gt 1 and not IsDefined('session.Newalert')>
	<cfset Step = "1">
</cfif>
<cfif not IsDefined('session.NewAlert') or IsDefined('url.ResetAlert')>
	<cfset session.NewAlert = StructNew()>
	<cfset session.NewAlert["FirstName"] = "">
	<cfset session.NewAlert["Email"] = "">
	<cfset session.NewAlert["Password"] = "">
	<cfset session.NewAlert["AlertSectionIDs"] = "">
	<cfset session.NewAlert["GenderID"] = "">
	<cfset session.NewAlert["BirthMonthID"] = "">
	<cfset session.NewAlert["BirthYearID"] = "">
	<cfset session.NewAlert["SelfIdentifiedTypeID"] = "">
	<cfset session.NewAlert["EducationLevelID"] = "">
	<cfset session.NewAlert["AlertSectionID"] = StructNew()>
</cfif>

<cfquery name="getImpressionSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SectionID
	From PageSections
	Where PageID = <cfqueryparam value="#PageID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfset ImpressionSectionID=getImpressionSection.SectionID>
<cfif not Len(ImpressionSectionID)>
	<cfset ImpressionSectionID = 0>
</cfif>

<cfif not IsDefined('application.SectionImpressions')>
	<cfset application.SectionImpressions= structNew()>
</cfif>
<cfif StructKeyExists(application.SectionImpressions,ImpressionSectionID)>
	<cfset application.SectionImpressions[ImpressionSectionID] = application.SectionImpressions[ImpressionSectionID] + 1>
<cfelse>
	<cfset application.SectionImpressions[ImpressionSectionID] = 1>
</cfif>

<cfquery name="AlertSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select SectionID as SelectValue,
	CASE WHEN SectionID in (39,40,50) THEN (Select Title From Sections Where SectionID = 5) + ' - ' + Title ELSE Title END as SelectText
	From Sections
	Where SectionID in (4,8,37,55,59,39,40,50)
	Order by SelectText, Title
</cfquery>
<cfquery name="AllSectionCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select CategoryID as SelectValue, Title as SelectText
	From Categories
	Where  Active = 1
	and (ParentSectionID in (<cfqueryparam value="#ValueList(AlertSections.SelectValue)#" cfsqltype="CF_SQL_INTEGER" list="yes">)
		or SectionID in (<cfqueryparam value="#ValueList(AlertSections.SelectValue)#" cfsqltype="CF_SQL_INTEGER" list="yes">))
	Order by OrderNum
</cfquery>
<cfquery name="Locations" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select LocationID as SelectValue, Title as SelectText
	From Locations
	Where Active=1
	Order by Title
</cfquery>

<cfset AlertSectionStruct = StructNew()>
<cfoutput query="AlertSections">
	<cfset AlertSectionStruct[SelectValue] = SelectText>
</cfoutput>

<cfset AlertCategoryStruct = StructNew()>
<cfoutput query="AllSectionCategories">
	<cfset AlertCategoryStruct[SelectValue] = SelectText>
</cfoutput>

<cfset AlertLocationStruct = StructNew()>
<cfoutput query="Locations">
	<cfset AlertLocationStruct[SelectValue] = SelectText>
</cfoutput>

<cfinclude template="header.cfm">

<cfoutput>
<div class="centercol-inner legacy">
 	<h1><lh:MS_SitePagePart id="title" class="title"></h1>
	<p>&nbsp;</p>

 	<div class="breadcrumb"><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/">Home</a> &gt; </div>

</cfoutput>

<cfif edit>
	<p>Text to display on initial page.</p>
	<lh:MS_SitePagePart id="bodyStart" class="body">
	<p>Text to display on For Sale Classifieds form.</p>
	<lh:MS_SitePagePart id="bodySectionData4" class="body">	
	<p>Text to display on Special Travel Offers form.</p>
	<lh:MS_SitePagePart id="bodySectionData37" class="body">		
	<p>Text to display on Tanzania Events Calendar form.</p>
	<lh:MS_SitePagePart id="bodySectionData59" class="body">
	<p>Text to display on Tanzania Jobs &amp; Employment form.</p>
	<lh:MS_SitePagePart id="bodySectionData8" class="body">		
	<p>Text to display on Commercial Rentals form.</p>
	<lh:MS_SitePagePart id="bodySectionData50" class="body">	
	<p>Text to display on Homes &amp; Property For Sales form.</p>
	<lh:MS_SitePagePart id="bodySectionData40" class="body">	
	<p>Text to display on Housing Rentals form.</p>
	<lh:MS_SitePagePart id="bodySectionData39" class="body">
	<p>Text to display on third page when user has not yet submitted the alert.</p>
	<lh:MS_SitePagePart id="bodyConfirmationRequest" class="body">
	<p>Text to display in email before Confirmation link</p>
	<lh:MS_SitePagePart id="bodyEmail" class="body">	
	<p>Text to display on fourth page. (Thank you and confirmation email sent.)</p>
	<lh:MS_SitePagePart id="bodyThankYou" class="body">
	<p>Text to display on Confirmation Link Resent page.</p>
	<lh:MS_SitePagePart id="bodyLinkResent" class="body">
	<p>Text to display in Confirmation Link Resent email.</p>
	<lh:MS_SitePagePart id="bodyResendEmail" class="body">
<cfelse>
 	<cfswitch expression="#Step#">
	 	<cfcase value="1">
			<cfinclude template="../includes/AddAlertStepOne.cfm">
		</cfcase>
	 	<cfcase value="2">
			<!--- Details --->
			<p>&nbsp;</p>
			<cfinclude template="../includes/AddAlertStepTwo.cfm">
		</cfcase>
	 	<cfcase value="3">
			<!--- Process Alert --->
			<cfinclude template="../includes/AddAlertStepThree.cfm">
		</cfcase>
	 	<cfcase value="4">
			<!--- Send Confirmation Email for entered email address --->
			<cfinclude template="../includes/AddAlertResendConfirmation.cfm">
		</cfcase>
	 </cfswitch>	
</cfif>

<!--- <cfdump var="#session.NewAlert#"> --->

</div>

<!-- END CENTER COL -->

<cfinclude template="footer.cfm">
