<!--- Included in ImpressionsTracker.cfm --->
<cfif IsDefined('application.AlertImpressions')>
	<cfloop collection = "#application.AlertImpressions#" item = "SectionID">
		<cfif application.AlertImpressions[SectionID] gt 0>
			<cfset TheCount = application.AlertImpressions[SectionID]>
			<cfset StructDelete(application.AlertImpressions, "#SectionID#")>
			<cfquery name="checkExistence" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Select SectionID
				From AlertImpressions with (NOLOCK)
				Where SectionID = <cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">
				and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
			</cfquery>
			<cfif checkExistence.RecordCount>
				<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Update AlertImpressions
					Set Count = Count + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
					Where SectionID = <cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">
					and ImpressionDate = DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
				</cfquery>
			<cfelse>
				<cfquery name="createCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
					Insert into AlertImpressions
					(SectionID, ImpressionDate, Count)
					VALUES
					(<cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">, DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate())), <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">)
				</cfquery>
			</cfif>
			<cfquery name="incrementCount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
				Update Sections 
				Set AlertImpressions = AlertImpressions + <cfqueryparam value="#TheCount#" cfsqltype="CF_SQL_INTEGER">
				Where SectionID = <cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfif>
	</cfloop>
</cfif>
