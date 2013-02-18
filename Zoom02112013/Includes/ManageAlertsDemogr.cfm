<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfquery name="getAlertDemogr" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select U.ContactFirstName as FirstName, U.UserName as Email, U.AreaID, U.GenderID, U.BirthMonthID, U.BirthYearID, U.SelfIdentifiedTypeID, U.EducationLevelID
	From Alerts A
	Inner Join LH_Users U on A.UserID=U.UserID
	Where A.ConfirmationID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ConfirmationID#">
</cfquery>
<cfif getAlertDemogr.RecordCount>
	<cfset FirstName = getAlertDemogr.FirstName>
	<cfset Email = getAlertDemogr.Email>
	<cfset AreaID = getAlertDemogr.AreaID>
	<cfset GenderID = getAlertDemogr.GenderID>
	<cfset BirthMonthID = getAlertDemogr.BirthMonthID>
	<cfset BirthYearID = getAlertDemogr.BirthYearID>
	<cfset SelfIdentifiedTypeID = getAlertDemogr.SelfIdentifiedTypeID>
	<cfset EducationLevelID = getAlertDemogr.EducationLevelID>
</cfif>

<cfset allFields="FirstName,Email,AreaID,GenderID,BirthMonthID,BirthYearID,SelfIdentifiedTypeID,EducationLevelID">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="GenderID,BirthMonthID,BirthYearID,EducationLevelID,SelfIdentifiedTypeID">

<lh:MS_SitePagePart id="bodyDemogIntro" class="body">
<p>&nbsp;</p>

<cfinclude template="CreateEditAccountForm.cfm">
