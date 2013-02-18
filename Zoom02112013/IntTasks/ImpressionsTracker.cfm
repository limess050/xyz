<!--- Scheduled process to insert impressions from application variables.
 --->
 <cfif IsDefined('application.SectionImpressions')>
	<cfloop collection = "#application.SectionImpressions#" item = "SectionID">
		<cfif application.SectionImpressions[SectionID] gt 0>			
			<cfset TheCount = application.SectionImpressions[SectionID]>
			<cfset StructDelete(application.SectionImpressions, "#SectionID#")>
			<cfquery name="checkExistence" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select SectionID
				From SectionImpressions with (NOLOCK)
				Where SectionID = <cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">
				and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
			</cfquery>
			<cfif checkExistence.RecordCount>
				<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Update SectionImpressions
					Set Count = Count + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
					Where SectionID = <cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">
					and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
				</cfquery>
			<cfelse>
				<cfquery name="createCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Insert into SectionImpressions
					(SectionID, ImpressionDate, Count)
					VALUES
					(<cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">, DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate())), <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">)
				</cfquery>
			</cfif>
			<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Update Sections 
				Set Impressions = Impressions + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
				Where SectionID = <cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfif>
	</cfloop>
</cfif>

<cfif IsDefined('application.CategoryImpressions')>
	<cfloop collection = "#application.CategoryImpressions#" item = "CategoryID">
		<cfif application.CategoryImpressions[CategoryID] gt 0>			
			<cfset TheCount = application.CategoryImpressions[CategoryID]>
			<cfset StructDelete(application.CategoryImpressions, "#CategoryID#")>
			<cfquery name="checkExistence" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select CategoryID
				From CategoryImpressions with (NOLOCK)
				Where CategoryID = <cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">
				and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
			</cfquery>
			<cfif checkExistence.RecordCount>
				<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Update CategoryImpressions
					Set Count = Count + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
					Where CategoryID = <cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">
					and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
				</cfquery>
			<cfelse>
				<cfquery name="createCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Insert into CategoryImpressions
					(CategoryID, ImpressionDate, Count)
					VALUES
					(<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">, DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate())), <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">)
				</cfquery>
			</cfif>
			<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Update Categories 
				Set Impressions = Impressions + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
				Where CategoryID = <cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfif>
	</cfloop>
</cfif>

<cfif IsDefined('application.BannerAdImpressions')>
	<cfloop collection = "#application.BannerAdImpressions#" item = "BannerAdID">
		<cfset InnerStruct=application.BannerAdImpressions[BannerAdID]>
		<cfloop collection = "#InnerStruct#" item = "SectionID">
			<cfif InnerStruct[SectionID] gt 0>
				<cfset TheCount = application.BannerAdImpressions[BannerAdID][SectionID]>
				<cfset StructDelete(application.BannerAdImpressions[BannerAdID], "#SectionID#")>
				<cfif StructIsEmpty(application.BannerAdImpressions[BannerAdID])>
					<cfset StructDelete(application.BannerAdImpressions,"#BannerAdID#")>
				</cfif>
				<cfquery name="checkExistence" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Select BannerAdID
					From BannerAdImpressions with (NOLOCK)
					Where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
					and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
					and SectionID = <cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				<cfif checkExistence.RecordCount>
					<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						Update BannerAdImpressions
						Set Count = Count + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
						Where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
						and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
						and SectionID = <cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">
					</cfquery>
				<cfelse>
					<cfquery name="createCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						Insert into BannerAdImpressions
						(BannerAdID, ImpressionDate, SectionID, Count)
						VALUES
						(<cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">, DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate())),<cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">, <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">)
					</cfquery>
				</cfif>
				<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Update BannerAds 
					Set Impressions = Impressions + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
					Where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
			</cfif>		
		</cfloop>
	</cfloop>
</cfif>

<cfif IsDefined('application.BannerAdExpandedImpressions')>
	<cfloop collection = "#application.BannerAdExpandedImpressions#" item = "BannerAdID">
		<cfset InnerStruct=application.BannerAdExpandedImpressions[BannerAdID]>
		<cfloop collection = "#InnerStruct#" item = "SectionID">
			<cfif InnerStruct[SectionID] gt 0>
				<cfset TheCount = application.BannerAdExpandedImpressions[BannerAdID][SectionID]>
				<cfset StructDelete(application.BannerAdExpandedImpressions[BannerAdID], "#SectionID#")>
				<cfif StructIsEmpty(application.BannerAdExpandedImpressions[BannerAdID])>
					<cfset StructDelete(application.BannerAdExpandedImpressions,"#BannerAdID#")>
				</cfif>
				<cfquery name="checkExistence" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Select BannerAdID
					From BannerAdExpandedImpressions with (NOLOCK)
					Where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
					and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
					and SectionID = <cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				<cfif checkExistence.RecordCount>
					<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						Update BannerAdExpandedImpressions
						Set Count = Count + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
						Where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
						and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))						
						and SectionID = <cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">
					</cfquery>
				<cfelse>
					<cfquery name="createCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						Insert into BannerAdExpandedImpressions
						(BannerAdID, ImpressionDate, SectionID,  Count)
						VALUES
						(<cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">, DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate())), <cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">, <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">)
					</cfquery>
				</cfif>
				<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Update BannerAds 
					Set ImpressionsExpanded = ImpressionsExpanded + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
					Where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
			</cfif>
		</cfloop>
	</cfloop>
</cfif>
 
<cfif IsDefined('application.BannerAdExternalImpressions')>
	<cfloop collection = "#application.BannerAdExternalImpressions#" item = "BannerAdID">
		<cfset InnerStruct=application.BannerAdExternalImpressions[BannerAdID]>
		<cfloop collection = "#InnerStruct#" item = "SectionID">
			<cfif InnerStruct[SectionID] gt 0>
				<cfset TheCount = application.BannerAdExternalImpressions[BannerAdID][SectionID]>
				<cfset StructDelete(application.BannerAdExternalImpressions[BannerAdID], "#SectionID#")>
				<cfif StructIsEmpty(application.BannerAdExternalImpressions[BannerAdID])>
					<cfset StructDelete(application.BannerAdExternalImpressions,"#BannerAdID#")>
				</cfif>
				<cfquery name="checkExistence" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Select BannerAdID
					From BannerAdExternalImpressions with (NOLOCK)
					Where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
					and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
					and SectionID = <cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				<cfif checkExistence.RecordCount>
					<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						Update BannerAdExternalImpressions
						Set Count = Count + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
						Where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
						and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
						and SectionID = <cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">
					</cfquery>
				<cfelse>
					<cfquery name="createCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
						Insert into BannerAdExternalImpressions
						(BannerAdID, ImpressionDate, SectionID, Count)
						VALUES
						(<cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">, DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate())), <cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">, <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">)
					</cfquery>
				</cfif>
				<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Update BannerAds 
					Set ImpressionsExternal = ImpressionsExternal + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
					Where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
			</cfif>
		</cfloop>
	</cfloop>
</cfif>

<cfinclude template="AlertsImpressionsTracker.cfm">
 
<cfinclude template="ListingsImpressionsTracker.cfm">

 