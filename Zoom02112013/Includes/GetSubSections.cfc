<!--- ParentSectionID passed in and SubSctionID select lit passed out.
If SectionID passed in and SectionID exists in resulting select list, marked it 'selected' --->

<cfsetting showdebugoutput="no">

<cffunction name="SelectList" access="remote" returntype="string" displayname="Returns Sub Section ID Select list for passed Parent SectionID">
	<cfargument name="ParentSectionID" required="yes">
	<cfargument name="SectionID" required="yes">
	<cfargument name="Action" type="string" required="yes">
	
	<cfset ParentSectionID=Replace(arguments.ParentSectionID,"|",",","ALL")>
	<cfset SectionID=Replace(arguments.SectionID,"|",",","ALL")>
	
	<cfquery name="getSections"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select S.SectionID as SelectValue, S.Title as SelectText, IsNull(PS.Title,'') + ' - ' + IsNull(S.Title,'') as FullSelectText
		From Sections S
		Inner Join ParentSectionsView PS on S.ParentSectionID=PS.ParentSectionID
		Where S.ParentSectionID in (<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
		and S.ParentSectionID is not null
		Order by S.OrderNum
	</cfquery>

	<cfset rString = ""> 
	
	<cfif getSections.RecordCount>	
		<cfsavecontent variable="rString">
			<td class="ADDLABELCELL">
				<label for="SectionID">Sub-Section:</label>
			</td>
			<td class="ADDFIELDCELL">
				<input name="SectionID_isEditable" value="true" type="hidden"> 
				<select name="SectionID" id="SectionID" <cfif arguments.Action is "Search" and getSections.RecordCount>multiple="Multiple" size="<cfif getSections.RecordCount lt "10">#getSections.RecordCount#<cfelse>10</cfif>"</cfif>>
					<cfif Arguments.Action is "Search">
						<cfif arguments.ParentSectionID is "0"><option value="">--- Select Parent Section First ---</option><cfelseif not getSections.RecordCount><option value="">No Sub-sections exist for the selected Parent Sections</option></cfif>
					<cfelse>
						<option value=""><cfif getSections.RecordCount>--- Select Sub-section Name ---<cfelseif arguments.ParentSectionID is "0">--- Select Parent Section First ---<cfelse>No Sub-sections exist for this Parent Section</cfif></option>
					</cfif>					
					<cfoutput query="getSections">
						<option value="#SelectValue#" <cfif ListFind(SectionID,SelectValue)>selected</cfif>><cfif Arguments.Action is "Search">#FullSelectText#<cfelse>#SelectText#</cfif>
					</cfoutput>						
				</select>
			</td>		
		</cfsavecontent>	
	</cfif>       
	
	

 	<cfreturn rString>
</cffunction>

