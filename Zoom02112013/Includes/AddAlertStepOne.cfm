<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfparam name="Em" default="">

<cfset FirstName = session.NewAlert["FirstName"]>
<cfset Email = session.NewAlert["Email"]>
<cfset Password = session.NewAlert["Password"]>
<cfset AlertSectionIDs = session.NewAlert["AlertSectionIDs"]>
<cfset GenderID = session.NewAlert["GenderID"]>
<cfset BirthMonthID = session.NewAlert["BirthMonthID"]>
<cfset BirthYearID = session.NewAlert["BirthYearID"]>
<cfset SelfIdentifiedTypeID = session.NewAlert["SelfIdentifiedTypeID"]>
<cfset EducationLevelID = session.NewAlert["EducationLevelID"]>

<cfset allFields="FirstName,Email,Password,AlertSectionIDs,AreaID,GenderID,BirthMonthID,BirthYearID,SelfIdentifiedTypeID,EducationLevelID">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="GenderID,BirthMonthID,BirthYearID,EducationLevelID,SelfIdentifiedTypeID">


<cfif Len(Em)>
	<p>&nbsp;</p>
	<cfoutput><div class="notice">'#Em#' already has Alerts. <a href="page.cfm?PageID=#Request.AddAlertPageID#&Step=4&Em=#Email#"><strong>Click here</strong></a> to have a link to this Alert sent to you.</div></cfoutput>
</cfif>

<lh:MS_SitePagePart id="bodyStart" class="body">
<p>&nbsp;</p>

<cfinclude template="CreateEditAccountForm.cfm">
