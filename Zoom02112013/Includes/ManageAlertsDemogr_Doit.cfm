<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfset allFields="FirstName,Email,AreaID,GenderID,BirthMonthID,BirthYearID,SelfIdentifiedTypeID,EducationLevelID">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="AreaID,GenderID,BirthMonthID,BirthYearID,EducationLevelID,SelfIdentifiedTypeID">

<cfif Len(ConfirmationID)>
	<cfquery name="ConfirmAlert" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select AlertID from Alerts Where ConfirmationID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ConfirmationID#">
	</cfquery>
	<cfset DuplicateEmail = "0">
	<cfif ConfirmAlert.RecordCount>
		<cfquery name="ConfirmEmailUnique" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select UserName 
			From LH_Users
			Where UserName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Email#">
			and UserID <> <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Session.UserID#">
		</cfquery>
		<cfif ConfirmEmailUnique.RecordCount>
			<cfset DuplicateEmail = "1">
		</cfif>
		<cfquery name="UpdateAlertSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update LH_Users
			Set ContactFirstName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FirstName#">,
			<cfif not DuplicateEmail>
					UserName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Email#">,
					ContactEmail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Email#">,
			</cfif>
			AreaID = <cfif Len(AreaID)><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#AreaID#"><cfelse>null</cfif>,
			GenderID = <cfif Len(GenderID)><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#GenderID#"><cfelse>null</cfif>,
			BirthMonthID = <cfif Len(BirthMonthID)><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#BirthMonthID#"><cfelse>null</cfif>,
			BirthYearID = <cfif Len(BirthYearID)><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#BirthYearID#"><cfelse>null</cfif>,
			EducationLevelID = <cfif Len(EducationLevelID)><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#EducationLevelID#"><cfelse>null</cfif>,
			SelfIdentifiedTypeID = <cfif Len(SelfIdentifiedTypeID)><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#SelfIdentifiedTypeID#"><cfelse>null</cfif>
			Where UserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.UserID#">	
		</cfquery>
		<cfinclude template="../includes/SetDemogrCookies.cfm">
	</cfif>
	<cfif DuplicateEmail>
		<cflocation url="page.cfm?PageID=#Request.ManageAlertPageID#&ConfirmationID=#ConfirmationID#&Em=0" addToken="No">
	<cfelse>
		<cflocation url="page.cfm?PageID=#Request.ManageAlertPageID#&ConfirmationID=#ConfirmationID#" addToken="No">
	</cfif>
	
	<cfabort>
<cfelse>
	<cflocation url="page.cfm?PageID=#Request.ManageAlertPageID#" addToken="No">
	<cfabort>
</cfif>