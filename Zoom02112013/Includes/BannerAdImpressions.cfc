
<cfinclude template="../application.cfm">


<cfsetting showdebugoutput="no">

<cffunction name="CheckImpressionsSection" access="remote" returntype="numeric">
	<cfargument name="impressions" required="yes">
	<cfargument name="sectionIDs" required="yes">
	<cfargument name="startDate" required="yes">
	<cfargument name="endDate" required="yes">
	
	<cfset InDate=arguments.startDate>
	<cfinclude template="DateFormatter.cfm">
	<cfset LocalStartDate=OutDate>
	
	<cfset InDate=arguments.endDate>
	<cfinclude template="DateFormatter.cfm">
	<cfset LocalEndDate=OutDate>
	
	 
	<cfquery name="getImpressions" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select i.impressionID
		from impressions i
		where (i.bannerADID in (select BannerAdID from BannerAdSections where SectionID in (<cfqueryparam value="#arguments.sectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">) )
		OR i.bannerAdID in (select BannerADID from BannerAdParentSections where ParentSectionID in (select ParentSectionID from Sections where sectionID IN (<cfqueryparam value="#arguments.sectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)))
		<!--- do not roll down
		OR i.bannerADID in (select BannerADID from BannerADCategories where CategoryID in (select CategoryID from Categories where sectionID in (<cfqueryparam value="#arguments.sectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)))
		--->
		)
		and i.impressionDate > getDate()-30
	</cfquery>
	
	<cfquery name="getImpressionsSold" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select coalesce(sum(i.impressions),0) as sumimpressions
		from BannerAds i
		where (i.bannerADID in (select BannerAdID from BannerAdSections where SectionID in (<cfqueryparam value="#arguments.sectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">) )
		OR i.bannerAdID in (select BannerADID from BannerAdParentSections where ParentSectionID in (select ParentSectionID from Sections where sectionID IN (<cfqueryparam value="#arguments.sectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)))
		<!--- do not roll down
		OR i.bannerADID in (select BannerADID from BannerADCategories where CategoryID in (select CategoryID from Categories where sectionID in (<cfqueryparam value="#arguments.sectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)))
		--->
		)
		AND i.startDate >= <cfqueryparam value="#localstartDate#" cfsqltype="CF_SQL_DATE">
		AND i.endDate <= <cfqueryparam value="#localendDate#" cfsqltype="CF_SQL_DATE">
		
	</cfquery>
	
	<cfset dailyAvg = getImpressions.recordCount/30>
	<cfset daysInRange = DateDiff("d",localstartDate,localendDate)>
	<cfset dailyAvgSold = getImpressionsSold.sumimpressions/daysInRange>
	<cfset impressionAvg = (dailyAvg-dailyAvgSold) * daysInRange>
	
	
	<cfif arguments.impressions GTE impressionAvg AND impressionAvg GTE 0>
		<cfreturn impressionAvg>
	<cfelse>
		<cfreturn 0>	
	</cfif>
</cffunction>

<cffunction name="CheckImpressionsParentSection" access="remote" returntype="numeric">
	<cfargument name="impressions" required="yes">
	<cfargument name="parentSectionIDs" required="yes">
	<cfargument name="startDate" required="yes">
	<cfargument name="endDate" required="yes">
	
	<cfset InDate=arguments.startDate>
	<cfinclude template="DateFormatter.cfm">
	<cfset LocalStartDate=OutDate>
	
	<cfset InDate=arguments.endDate>
	<cfinclude template="DateFormatter.cfm">
	<cfset LocalEndDate=OutDate>
	
	 
	<cfquery name="getImpressions" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select i.impressionID
		from impressions i
		where (i.bannerADID in (select BannerAdID from BannerAdParentSections where ParentSectionID in (<cfqueryparam value="#arguments.ParentsectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">) )
		<!--- do not roll down
		or i.bannerAdID in (select BannerADID from BannerAdSections where SectionID in (select sectionID from Sections where ParentSectionID in (<cfqueryparam value="#arguments.ParentsectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)))
		or i.bannerAdID in (select BannerADID from BannerAdCategories where CategoryID in (select categoryID from Categories where sectionID in (select sectionID from Sections where parentSectionID in (<cfqueryparam value="#arguments.ParentsectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">))))
		--->
		)
		and i.impressionDate > getDate()-30
		
	</cfquery>
	
	<cfquery name="getImpressionsSold" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select coalesce(sum(i.impressions),0) as sumimpressions
		from BannerAds i
		where (i.bannerADID in (select BannerAdID from BannerAdParentSections where ParentSectionID in (<cfqueryparam value="#arguments.ParentsectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">) ))
		AND i.startDate >= <cfqueryparam value="#localstartDate#" cfsqltype="CF_SQL_DATE">
		AND i.endDate <= <cfqueryparam value="#localendDate#" cfsqltype="CF_SQL_DATE">
	</cfquery>
	
	<cfset dailyAvg = getImpressions.recordCount/30>
	<cfset daysInRange = DateDiff("d",localstartDate,localendDate)>
	<cfset dailyAvgSold = getImpressionsSold.sumImpressions/daysInRange>
	<cfset impressionAvg = (dailyAvg-dailyAvgSold) * daysInRange>
	
	
	<cfif arguments.impressions GTE impressionAvg AND impressionAvg GTE 0>
		<cfreturn impressionAvg>
	<cfelse>
		<cfreturn 0>	
	</cfif>
</cffunction>

<cffunction name="CheckImpressionsCategory" access="remote" returntype="numeric">
	<cfargument name="impressions" required="yes">
	<cfargument name="CategoryIDs" required="yes">
	<cfargument name="startDate" required="yes">
	<cfargument name="endDate" required="yes">
	
	<cfset InDate=arguments.startDate>
	<cfinclude template="DateFormatter.cfm">
	<cfset LocalStartDate=OutDate>
	
	<cfset InDate=arguments.endDate>
	<cfinclude template="DateFormatter.cfm">
	<cfset LocalEndDate=OutDate>
	
	 
	<cfquery name="getImpressions" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select i.impressionID
		from impressions i
		where (i.bannerADID in (select BannerAdID from BannerAdCategories where CategoryID in (<cfqueryparam value="#arguments.CategoryIDs#" cfsqltype="CF_SQL_INTEGER" list="true">) )
		or i.bannerADID in (select BannerADID from BannerAdSections where sectionID in (select sectionID from Categories where categoryID in (<cfqueryparam value="#arguments.CategoryIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)))
		or i.bannerADID in (select BannerADID from BannerAdParentSections where ParentSectionID in (select parentsectionID from Categories where categoryID in (<cfqueryparam value="#arguments.CategoryIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)))
		
		)
		and i.impressionDate > getDate()-30
	</cfquery>
	
	<cfquery name="getImpressionsSold" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select coalesce(sum(i.impressions),0) as sumimpressions
		from BannerAds i
		where (i.bannerADID in (select BannerAdID from BannerAdCategories where CategoryID in (<cfqueryparam value="#arguments.CategoryIDs#" cfsqltype="CF_SQL_INTEGER" list="true">) )
		or i.bannerADID in (select BannerADID from BannerAdSections where sectionID in (select sectionID from Categories where categoryID in (<cfqueryparam value="#arguments.CategoryIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)))
		or i.bannerADID in (select BannerADID from BannerAdParentSections where ParentSectionID in (select parentsectionID from Categories where categoryID in (<cfqueryparam value="#arguments.CategoryIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)))
		)
		AND i.startDate >= <cfqueryparam value="#localstartDate#" cfsqltype="CF_SQL_DATE">
		AND i.endDate <= <cfqueryparam value="#localendDate#" cfsqltype="CF_SQL_DATE">
	</cfquery>
	
	<cfset dailyAvg = getImpressions.recordCount/30>
	<cfset daysInRange = DateDiff("d",localstartDate,localendDate)>
	<cfset dailyAvgSold = getImpressionsSold.sumImpressions/daysInRange>
	<cfset impressionAvg = (dailyAvg-dailyAvgSold) * daysInRange>
	
	
	<cfif arguments.impressions GTE impressionAvg AND impressionAvg GTE 0>
		<cfreturn impressionAvg>
	<cfelse>
		<cfreturn 0>	
	</cfif>
</cffunction>



