<!--- Loop through application.{StructureName}
		Increment impressions count in appropriate Impressions table
		Increment Impressions Count in appropriate Table
		Reset Application.{SturctureName} count to zero
 --->
<cfif IsDefined('application.ListingImpressions')>
	<cfloop collection = "#application.ListingImpressions#" item = "ListingID">
		<cfif application.ListingImpressions[ListingID] gt 0>
			<cfset TheCount = application.ListingImpressions[ListingID]>
			<cfset StructDelete(application.ListingImpressions, "#ListingID#")>
			<cfquery name="checkExistence" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select ListingID
				From ListingImpressions with (NOLOCK)
				Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
				and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
			</cfquery>
			<cfif checkExistence.RecordCount>
				<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Update ListingImpressions
					Set Count = Count + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
					Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
					and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
				</cfquery>
			<cfelse>
				<cfquery name="createCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Insert into ListingImpressions
					(ListingID, ImpressionDate, Count)
					VALUES
					(<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">, DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate())), <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">)
				</cfquery>
			</cfif>
			<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Update Listings 
				Set Impressions = Impressions + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
				Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfif>
	</cfloop>
</cfif>

<cfif IsDefined('application.ListingResultsPageImpressions')>
	<cfloop collection = "#application.ListingResultsPageImpressions#" item = "ListingID">
		<cfif application.ListingResultsPageImpressions[ListingID] gt 0>
			<cfset TheCount = application.ListingResultsPageImpressions[ListingID]>
			<cfset StructDelete(application.ListingResultsPageImpressions, "#ListingID#")>
			<cfquery name="checkExistence" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select ListingID
				From ListingResultsPageImpressions with (NOLOCK)
				Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
				and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
			</cfquery>
			<cfif checkExistence.RecordCount>
				<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Update ListingResultsPageImpressions
					Set Count = Count + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
					Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
					and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
				</cfquery>
			<cfelse>
				<cfquery name="createCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Insert into ListingResultsPageImpressions
					(ListingID, ImpressionDate, Count)
					VALUES
					(<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">, DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate())), <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">)
				</cfquery>
			</cfif>
			<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Update Listings 
				Set ImpressionsResultsPage = ImpressionsResultsPage + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
				Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfif>
	</cfloop>
</cfif>

<cfif IsDefined('application.ListingEmailInquiryImpressions')>
	<cfloop collection = "#application.ListingEmailInquiryImpressions#" item = "ListingID">
		<cfif application.ListingEmailInquiryImpressions[ListingID] gt 0>
			<cfset TheCount = application.ListingEmailInquiryImpressions[ListingID]>
			<cfset StructDelete(application.ListingEmailInquiryImpressions, "#ListingID#")>
			<cfquery name="checkExistence" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select ListingID
				From ListingEmailInquiryImpressions with (NOLOCK)
				Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
				and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
			</cfquery>
			<cfif checkExistence.RecordCount>
				<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Update ListingEmailInquiryImpressions
					Set Count = Count + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
					Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
					and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
				</cfquery>
			<cfelse>
				<cfquery name="createCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Insert into ListingEmailInquiryImpressions
					(ListingID, ImpressionDate, Count)
					VALUES
					(<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">, DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate())), <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">)
				</cfquery>
			</cfif>
			<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Update Listings 
				Set ImpressionsEmailInquiries = ImpressionsEmailInquiries + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
				Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfif>
	</cfloop>
</cfif>

<cfif IsDefined('application.ListingExpandedImpressions')>
	<cfloop collection = "#application.ListingExpandedImpressions#" item = "ListingID">
		<cfif application.ListingExpandedImpressions[ListingID] gt 0>
			<cfset TheCount = application.ListingExpandedImpressions[ListingID]>
			<cfset StructDelete(application.ListingExpandedImpressions, "#ListingID#")>
			<cfquery name="checkExistence" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select ListingID
				From ListingExpandedImpressions with (NOLOCK)
				Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
				and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
			</cfquery>
			<cfif checkExistence.RecordCount>
				<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Update ListingExpandedImpressions
					Set Count = Count + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
					Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
					and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
				</cfquery>
			<cfelse>
				<cfquery name="createCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Insert into ListingExpandedImpressions
					(ListingID, ImpressionDate, Count)
					VALUES
					(<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">, DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate())), <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">)
				</cfquery>
			</cfif>
			<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Update Listings 
				Set ImpressionsExpanded = ImpressionsExpanded + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
				Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfif>
	</cfloop>
</cfif>

<cfif IsDefined('application.ListingExternalImpressions')>
	<cfloop collection = "#application.ListingExternalImpressions#" item = "ListingID">
		<cfif application.ListingExternalImpressions[ListingID] gt 0>
			<cfset TheCount = application.ListingExternalImpressions[ListingID]>
			<cfset StructDelete(application.ListingExternalImpressions, "#ListingID#")>
			<cfquery name="checkExistence" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select ListingID
				From ListingExternalImpressions with (NOLOCK)
				Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
				and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
			</cfquery>
			<cfif checkExistence.RecordCount>
				<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Update ListingExternalImpressions
					Set Count = Count + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
					Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
					and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
				</cfquery>
			<cfelse>
				<cfquery name="createCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Insert into ListingExternalImpressions
					(ListingID, ImpressionDate, Count)
					VALUES
					(<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">, DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate())), <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">)
				</cfquery>
			</cfif>
			<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Update Listings 
				Set ImpressionsExternal = ImpressionsExternal + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
				Where ListingID = <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfif>
	</cfloop>
</cfif>
