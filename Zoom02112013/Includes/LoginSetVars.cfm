<cfset session.userID = getUser.userID>
<cfset session.username = getUser.UserName>
<cfcookie name="LoggedIn" value="1">
<cfset StructDelete(session,"User")>

<cfset AreaID=getUser.AreaID>
<cfset GenderID=getUser.GenderID>
<cfset BirthMonthID=getUser.BirthMonthID>
<cfset BirthYearID=getUser.BirthYearID>
<cfset EducationLevelID=getUser.EducationLevelID>
<cfset SelfIdentifiedTypeID=getUser.SelfIdentifiedTypeID>

<cfinclude template="SetDemogrCookies.cfm">