<cfparam name="FirstRun" default="1">
<cfparam name="BannerAdPosition" default="1">
<cfif Request.environment is "Live">
	<cfset DefaultPlacementID = "3939598">
<cfelse>
	<cfset DefaultPlacementID = "3946407">
</cfif>


<cfparam name="KeyValuesStr" default = "">
<cfparam name="KeyWordsStr" default = "">

<cfif FirstRun>
	<cfif Request.environment is "Live">
		<cfset CachedWithinValue = CreateTimeSpan(0, 0, 10, 0)>
	<cfelse>
		<cfset CachedWithinValue = CreateTimeSpan(0, 0, 0, 10)>
	</cfif>
	
	<cfif ListFind("#Request.ListingDetailPageID#,#Request.CategoryPageID#",PageID) and IsDefined('CategoryID')>
		<cfset KeyWordsStr = ListAppend(KeyWordsStr,"C#CategoryID#","+")>
	</cfif>
	
	<cfif ListFind("#Request.ListingDetailPageID#,#Request.CategoryPageID#",PageID) and IsDefined('CategoryID')><!--- Get any Keywords assigned to this Category --->
		<cfquery name="getKeywordsC#CategoryID#" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#" cachedwithin="#CachedWithinValue#">
			Select KeywordID
			From CategoryKeywords
			Where CategoryID = <cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfoutput query="getKeywordsC#CategoryID#">
			<cfset KeyWordsStr = ListAppend(KeyWordsStr,"#KeywordID#","+")>
		</cfoutput>
	<cfelseif PageID is Request.SectionOverviewPageID and IsDefined('SectionID')><!--- Get Any Keywords Assigned to this Section --->
		<cfquery name="getKeywordsS#SectionID#" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#" cachedwithin="#CachedWithinValue#">
			Select KeywordID
			From SectionKeywords
			Where SectionID = <cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfoutput query="getKeywordsS#SectionID#">
			<cfset KeyWordsStr = ListAppend(KeyWordsStr,"#KeywordID#","+")>
		</cfoutput>
	<cfelse><!--- Get any KeyWords assigned to this CMS page --->
		<cfquery name="getKeywordsP#PageID#" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#" cachedwithin="#CachedWithinValue#">
			Select KeywordID
			From PageKeywords
			Where PageID = <cfqueryparam value="#PageID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfoutput query="getKeywordsP#PageID#">
			<cfset KeyWordsStr = ListAppend(KeyWordsStr,"#KeywordID#","+")>
		</cfoutput>
	</cfif>
	
	<cfif Len(KeyWordsStr)>
		<cfset KeyWordsStr = "key=" & KeyWordsStr & ";">
	</cfif>
	
	<cfif IsDefined('cookie.DemogrGenderID') and Len(cookie.DemogrGenderID)>
		<cfset KeyValuesStr = KeyValuesStr & "KVGN=#cookie.DemogrGenderID#;">
	</cfif>
	<cfif IsDefined('cookie.DemogrBirthMonthID') and Len(cookie.DemogrBirthMonthID) and IsDefined('cookie.DemogrBirthYearID') and Len(cookie.DemogrBirthYearID)>
		<cfset AgeInYears = DateDiff("yyyy",CreateDate(#cookie.DemogrBirthYearID#, #cookie.DemogrBirthMonthID#, 1),application.CurrentDateInTZ)>
		<cfif AgeInYears lte "21">
			<cfset AgeID = "1">
		<cfelseif AgeInYears gt "21" and AgeInYears lte "30">
			<cfset AgeID = "2">
		<cfelseif AgeInYears gt "30" and AgeInYears lte "44">
			<cfset AgeID = "3">
		<cfelseif AgeInYears gt "44" and AgeInYears lte "59">
			<cfset AgeID = "4">
		<cfelseif AgeInYears gte "60">
			<cfset AgeID = "5">
		</cfif>
		<cfset KeyValuesStr = KeyValuesStr & "KVAG=#AgeID#;">
	</cfif>
	<cfif IsDefined('cookie.DemogrAreaID') and Len(cookie.DemogrAreaID)>
		<cfset KeyValuesStr = KeyValuesStr & "KVCY=#cookie.DemogrAreaID#;">
	<cfelseif PageID is Request.ListingDetailPageID and IsDefined('ListingID') and getListing.RecordCount and getListingInfo2.RecordCount><!--- Get Location based on Listing locations --->
		<cfset AreaIDs = "">
		<cfloop list="#ValueList(getListingInfo2.LocationID)#" index="LocationID">
			<cfinclude template="AdTechLocationMappings.cfm">
		</cfloop>
		<cfif Len(AreaIDs)>
			<cfset KeyValuesStr = KeyValuesStr & "KVCY=#AreaIDs#;">
		</cfif>
	<cfelseif PageID is Request.CategoryPageID and IsDefined('LocationID') and Len(LocationID)><!--- If Catgory page has location selected in dropdown filter, use that location. --->
		<cfset AreaIDs = "">
		<cfinclude template="AdTechLocationMappings.cfm">
		<cfif Len(AreaIDs)>
			<cfset KeyValuesStr = KeyValuesStr & "KVCY=#AreaIDs#;">
		</cfif>
	</cfif>
	<cfif IsDefined('cookie.DemogrEducationLevelID') and Len(cookie.DemogrEducationLevelID)>
		<cfif ListFind("1,2",cookie.DemogrEducationLevelID)>
			<cfset KeyValuesStr = KeyValuesStr & "KVED=1;">
		<cfelse>
			<cfset KeyValuesStr = KeyValuesStr & "KVED=2;">
		</cfif>		
	</cfif>
	
	<cfif IsDefined('cookie.DemogrSelfIdentifiedTypeID') and Len(cookie.DemogrSelfIdentifiedTypeID)>
		<cfset KeyValuesStr = KeyValuesStr & "KVSI=#cookie.DemogrSelfIdentifiedTypeID#;">
	</cfif>
	
	
	<cfif IsDefined('ImpressionSectionID') and (ImpressionSectionID neq "0" or PageID is "1")><!--- Section already accurately determined. --->
		<cfset AdTechSectionID = ImpressionSectionID>
	<cfelse>
		<cfquery name="getAdTechSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
			Select P.PageID, P.CookieCrumb, PS.SectionID
			From LH_Pages_Live P
			Left Join PageSections PS on P.PageID=PS.PageID
			Where P.PageID = <cfqueryparam value="#PageID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset AdTechSectionID=getAdTechSection.SectionID>
		<cfif not Len(AdTechSectionID) and Len(getAdTechSection.CookieCrumb)><!--- Find first available SectionID by moving up parent tree --->
			<cfquery name="getParentAdTechSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select PageID as ATPageID, SectionID as ATSectionID
				From PageSections
				Where PageID in (<cfqueryparam value="#getAdTechSection.CookieCrumb#" cfsqltype="CF_SQL_INTEGER" list="yes">)
			</cfquery>
			<cfif getParentAdTechSection.RecordCount>
				<cfloop from="#ListLen(getAdTechSection.CookieCrumb)#" to="1" step="-1" index="p">
				<!--- Loop through cookiecrumb PageID values, from last to first and if the query contains a record with that PageID, set the AdTechSectionID and break out of loop. --->
					<cfoutput query="getParentAdTechSection">
						<cfif p is ATPageID>
							<cfset AdTechSectionID = ATSectionID>
						</cfif>
					</cfoutput>
					<cfif Len(AdTechSectionID)>
						<cfbreak>
					</cfif>
				</cfloop>
			</cfif>	
		</cfif>	
		<cfif not Len(AdTechSectionID)>
			<cfset AdTechSectionID = "0">
		</cfif>
	</cfif>
	<cfquery name="getPlacementIDs" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select PlacementID1, PlacementID2
		From Sections
		Where SectionID = <cfqueryparam value="#ADTechSectionID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
</cfif>

<cfif BannerAdPosition is "1">
	<cfset SizeID = "5206">
	<cfset BannerAdWidth = "675">
	<cfset BannerAdHeight = "90">
	<cfset PlacementID = getPlacementIDs.PlacementID1>
<cfelse><!--- Position 3 --->
	<cfset SizeID = "1054">
	<cfset BannerAdWidth = "200">
	<cfset BannerAdHeight = "550">
	<cfset PlacementID = getPlacementIDs.PlacementID2>
</cfif>

<cfif not Len(PlacementID)>
	<cfset PlacementID=DefaultPlacementID>
</cfif>

<cfoutput>
<script language="javascript">
<!--
if (window.adgroupid == undefined) {
	window.adgroupid = Math.round(Math.random() * 1000);
}
document.write('<scr'+'ipt language="javascript1.1" src="http://adserver.adtech.de/addyn/3.0/1332/#PlacementID#/0/#SizeID#/ADTECH;loc=100;target=_blank;#KeyValuesStr##KeyWordsStr#grp='+window.adgroupid+';misc='+new Date().getTime()+'"></scri'+'pt>');
//-->
</script><noscript><a href="http://adserver.adtech.de/adlink/3.0/1332/#PlacementID#/0/#SizeID#/ADTECH;loc=300" target="_blank"><img src="http://adserver.adtech.de/adserv/3.0/1332/#PlacementID#/0/#SizeID#/ADTECH;loc=300" border="0" width="#BannerAdWidth#" height="#BannerAdHeight#"></a></noscript>
</cfoutput>
<cfset FirstRun = "0">