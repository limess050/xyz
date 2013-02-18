<!--- 
Take ParentSectionID and find Pos1 BannerAdIDs
Delete Existing Weight Records for BannerAdID/ParentSectionID combo
Loop through the IDs, adding the Weight records
Redirect to Form
 --->
<cfparam name="ParentSectionID" default="">

<cfinclude template="includes/BannerAdSectionWeightQueries.cfm">

<cfoutput query="getPos1Ads">
	<cfif IsDefined('Weight#BannerAdID#')>
		<cfif Len(Weight)>
			<cfquery name="updateWeight" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Update BannerAdSectionWeights
				Set Weight = <cfqueryparam value="#NumberFormat(Evaluate('Weight' & BannerAdID),'_.__')#" cfsqltype="CF_SQL_FLOAT">
				Where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
				and ParentSectionID = <cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		<cfelse>
			<cfquery name="InsertWeight" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Insert into BannerAdSectionWeights
				(BannerAdID, ParentSectionID, Weight)
				VALUES
				(<cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#NumberFormat(Evaluate('Weight' & BannerAdID),'_.__')#" cfsqltype="CF_SQL_FLOAT">)
			</cfquery>
		</cfif>
	</cfif>
</cfoutput>
<cfoutput query="getPos3Ads">
	<cfif IsDefined('Weight#BannerAdID#')>
		<cfif Len(Weight)>
			<cfquery name="updateWeight" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Update BannerAdSectionWeights
				Set Weight = <cfqueryparam value="#NumberFormat(Evaluate('Weight' & BannerAdID),'_.__')#" cfsqltype="CF_SQL_FLOAT">
				Where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
				and ParentSectionID = <cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		<cfelse>
			<cfquery name="InsertWeight" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Insert into BannerAdSectionWeights
				(BannerAdID, ParentSectionID, Weight)
				VALUES
				(<cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#NumberFormat(Evaluate('Weight' & BannerAdID),'_.__')#" cfsqltype="CF_SQL_FLOAT">)
			</cfquery>
		</cfif>
	</cfif>
</cfoutput>

<!--- See if Weights for a position total more than 100. If so, move decimal place on Weights over until the total is less than 100. --->
<cfif GetPos1Ads.RecordCount>
	<cfquery name="getWeightTotalPos1" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select Sum(Weight) as TotalWeight
		From BannerAdSectionWeights
		Where BannerAdID in (<cfqueryparam value="#ValueList(getPos1Ads.BanneradID)#" cfsqltype="CF_SQL_INTEGER" List="Yes">)
		and ParentSectionID = <cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif getWeightTotalPos1.TotalWeight gt 100>
		<cfset ReductionFactor = 10>
		<cfloop condition = "getWeightTotalPos1.TotalWeight/ReductionFactor gt 100">
		    <cfset ReductionFactor = ReductionFactor* 10>
		</cfloop> 
		<cfquery name="UpdatePos1Weights" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update BannerAdSectionWeights
			Set Weight=Weight/<cfqueryparam value="#ReductionFactor#" cfsqltype="CF_SQL_INTEGER">
			Where BannerAdID in (<cfqueryparam value="#ValueList(getPos1Ads.BanneradID)#" cfsqltype="CF_SQL_INTEGER" List="Yes">)
			and ParentSectionID = <cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cfif>
</cfif>
<cfif GetPos3Ads.RecordCount>
	<cfquery name="getWeightTotalPos3" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select Sum(Weight) as TotalWeight
		From BannerAdSectionWeights
		Where BannerAdID in (<cfqueryparam value="#ValueList(getPos3Ads.BanneradID)#" cfsqltype="CF_SQL_INTEGER" List="Yes">)
		and ParentSectionID = <cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif getWeightTotalPos3.TotalWeight gt 100>
		<cfset ReductionFactor = 10>
		<cfloop condition = "getWeightTotalPos3.TotalWeight/ReductionFactor gt 100">
		    <cfset ReductionFactor = ReductionFactor* 10>
		</cfloop> 
		<cfquery name="UpdatePos3Weights" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update BannerAdSectionWeights
			Set Weight=Weight/<cfqueryparam value="#ReductionFactor#" cfsqltype="CF_SQL_INTEGER">
			Where BannerAdID in (<cfqueryparam value="#ValueList(getPos3Ads.BanneradID)#" cfsqltype="CF_SQL_INTEGER" List="Yes">)
			and ParentSectionID = <cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cfif>
</cfif>

<cflocation url="BannerAdSectionWeight.cfm?ParentSectionID=#ParentSectionID#&StatusMsg=#URLEncodedFormat('Weights updated.')#" AddToken="No">
<cfabort>
