

<cfif Len(AreaID)>
	<cfcookie name="DemogrAreaID" expires="never" value="#AreaID#">
<cfelse>
	<cfcookie name="DemogrAreaID" expires="Now">
</cfif>
<cfif Len(GenderID)>
	<cfcookie name="DemogrGenderID" expires="never" value="#GenderID#">
<cfelse>
	<cfcookie name="DemogrGenderID" expires="Now">
</cfif>
<cfif Len(BirthMonthID)>
	<cfcookie name="DemogrBirthMonthID" expires="never" value="#BirthMonthID#">
<cfelse>
	<cfcookie name="DemogrBirthMonthID" expires="Now">
</cfif>
<cfif Len(BirthYearID)>
	<cfcookie name="DemogrBirthYearID" expires="never" value="#BirthYearID#">
<cfelse>
	<cfcookie name="DemogrBirthYearID" expires="Now">
</cfif>
<cfif Len(EducationLevelID)>
	<cfcookie name="DemogrEducationLevelID" expires="never" value="#EducationLevelID#">
<cfelse>
	<cfcookie name="DemogrEducationLevelID" expires="Now">
</cfif>
<cfif Len(SelfIdentifiedTypeID)>
	<cfcookie name="DemogrSelfIdentifiedTypeID" expires="never" value="#SelfIdentifiedTypeID#">
<cfelse>
	<cfcookie name="DemogrSelfIdentifiedTypeID" expires="Now">
</cfif>
