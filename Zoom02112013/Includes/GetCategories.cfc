<!--- ParentSectionID passed in and SubSctionID select lit passed out.
If SectionID passed in and SectionID exists in resulting select list, marked it 'selected' --->

<cfsetting showdebugoutput="no">

<cffunction name="SelectList" access="remote" returntype="string" displayname="Returns Category ID Select list for passed SectionID">
	<cfargument name="SectionID" required="yes">
	<cfargument name="ParentSectionID" required="yes">
	<cfargument name="CategoryID" required="yes">
	<cfargument name="Action" type="string" required="yes">
	<cfargument name="CatsMultiple" type="string" required="yes">
	
	<cfset SectionID=Replace(arguments.SectionID,"|",",","ALL")>
	<cfset ParentSectionID=Replace(arguments.ParentSectionID,"|",",","ALL")>
	<cfset CategoryID=Replace(arguments.CategoryID,"|",",","ALL")>
	
	<cfquery name="getCategories"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select C.CategoryID as SelectValue, C.Title as SelectText, IsNull(S.Title,'') + ' - ' + IsNull(C.Title,'') as FullSelectText
		From Categories C
		Inner Join Sections S on C.SectionID=S.SectionID or (C.ParentSectionID=S.SectionID and C.SectionID is null)
		Where 
		<cfif SectionID neq "0">C.SectionID in (<cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER" list="Yes">) or </cfif>
		(C.ParentSectionID in (<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER" list="Yes">) and C.SectionID is null)
		Order by S.OrderNum, C.OrderNum
	</cfquery>

	<cfset rString = "">        
	
	<cfsavecontent variable="rString">
		<td class="ADDLABELCELL">
			<label for="SectionID">Category:</label>
		</td>
		<td class="ADDFIELDCELL">
			<input name="CategoryID_isEditable" value="true" type="hidden"> 
			<select name="CategoryID" id="CategoryID" <cfif (arguments.Action is "Search" or arguments.CatsMultiple is "1") and getCategories.RecordCount>multiple="Multiple" size="<cfif getCategories.RecordCount lt "10">#getCategories.RecordCount#<cfelse>10</cfif>"</cfif>>
				<cfif Arguments.Action is "Search">
					<cfif arguments.SectionID is "0" and arguments.ParentSectionID is "0"><option value="">--- Select Section First ---</option><cfelseif not getCategories.RecordCount><option value="">No Categories exist for the selected Sections</option></cfif>
				<cfelse>
					<option value=""><cfif getCategories.RecordCount>--- Select Category Name ---<cfelseif arguments.SectionID is "0">--- Select Section First ---<cfelse>No Categories exist for this Section</cfif></option>
				</cfif>
				
				<cfoutput query="getCategories">
					<option value="#SelectValue#" <cfif ListFind(CategoryID,SelectValue)>selected</cfif>><cfif Arguments.Action is "Search">#FullSelectText#<cfelse>#SelectText#</cfif>
				</cfoutput>						
			</select>
		</td>		
	</cfsavecontent>	

 	<cfreturn rString>
</cffunction>

