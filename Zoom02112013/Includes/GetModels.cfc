<!--- ParentSectionID passed in and SubSctionID select lit passed out.
If SectionID passed in and SectionID exists in resulting select list, marked it 'selected' --->

<cfsetting showdebugoutput="no">

<cffunction name="SelectList" access="remote" returntype="string" displayname="Returns Sub Section ID Select list for passed Parent SectionID">
	<cfargument name="MakeID" required="yes">
	<cfargument name="ModelID" required="yes">
	<cfargument name="Action" type="string" required="yes">
	
	<cfset MakeID=Replace(arguments.MakeID,"|",",","ALL")>
	<cfset ModelID=Replace(arguments.ModelID,"|",",","ALL")>
	
	<cfquery name="getModels"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select M.ModelID as SelectValue, M.Title as SelectText
		From Models M
		Where M.MakeID in (<cfqueryparam value="#MakeID#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
		and M.MakeID is not null
		Order by M.OrderNum
	</cfquery>

	<cfset rString = ""> 
	
		
		<cfsavecontent variable="rString">
			<cfoutput>
			
			
			<td class="rightAtd">
				*&nbsp;Model:
			</td>
			<td>
				<select name="ModelID" ID="ModelID">
					<option value="">-- Select --
					<cfloop query="getModels">
						<option value="#SelectValue#" <cfif ListFind(ModelID,SelectValue)>Selected</cfif>>#SelectText#
					</cfloop>
					<option value="0">Other</option>
				</select>
			</td>
			</cfoutput>	
		</cfsavecontent>	
	       
	
	

 	<cfreturn rString>
</cffunction>

