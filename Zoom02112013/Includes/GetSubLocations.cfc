NO LONGER IN USE getSubLocations.cfc<cfabort>

<!--- ParentLocationID passed in and SubSctionID select lit passed out.
If LocationID passed in and LocationID exists in resulting select list, marked it 'selected' --->

<cfsetting showdebugoutput="no">

<cffunction name="SelectList" access="remote" returntype="string" displayname="Returns Sub Location ID Select list for passed Parent LocationID">
	<cfargument name="ParentLocationID" required="yes">
	<cfargument name="LocationID" required="yes">
	<cfargument name="LocationOther" required="yes">
	<cfargument name="Action" type="string" required="yes">
	
	<cfset ParentLocationID=Replace(arguments.ParentLocationID,"|",",","ALL")>
	<cfset LocationID=Replace(arguments.LocationID,"|",",","ALL")>
	<cfset LocationOther=arguments.LocationOther>
	
	<cfset rString = ""> 
	
	<cfif ParentLocationID neq "0">
		<cfquery name="getLocations"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select S.LocationID as SelectValue, S.Title as SelectText, IsNull(PS.Title,'') + ' - ' + IsNull(S.Title,'') as FullSelectText
			From Locations S
			Inner Join ParentLocationsView PS on S.ParentLocationID=PS.ParentLocationID
			Where S.ParentLocationID in (<cfqueryparam value="#ParentLocationID#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
			and S.ParentLocationID is not null
			Order by S.OrderNum
		</cfquery>
		
		<cfif getLocations.RecordCount>	
			<cfsavecontent variable="rString">
				<td class="rightAtd">
					<label for="LocationID">Sub-Area:</label>
				</td>
				<td>
					<select name="LocationID" id="LocationID" <cfif arguments.Action is "Search" and getLocations.RecordCount>multiple="Multiple" size="<cfif getLocations.RecordCount lt "10">#getLocations.RecordCount#<cfelse>10</cfif>"</cfif>>
						<cfif Arguments.Action is "Search">
							<cfif arguments.ParentLocationID is "0"><option value="">--- Select Area First ---</option><cfelseif not getLocations.RecordCount><option value="">No Sub-locations exist for the selected Parent Locations</option></cfif>
						<cfelse>
							<option value=""><cfif getLocations.RecordCount>--- Select Sub-area Name ---<cfelseif arguments.ParentLocationID is "0">--- Select Area First ---<cfelse>No Sub-areas exist for this Parent Location</cfif></option>
						</cfif>					
						<cfoutput query="getLocations">
							<option value="#SelectValue#" <cfif ListFind(LocationID,SelectValue)>selected</cfif>><cfif Arguments.Action is "Search">#FullSelectText#<cfelse>#SelectText#</cfif>
						</cfoutput>						
					</select>
					<input type="hidden" name="LocationOther" value="">	
				</td>		
			</cfsavecontent>	
		<cfelse>
			<cfsavecontent variable="rString">
				<td class="rightAtd">
					<label for="LocationID">Sub-Area:</label>
				</td>
				<td>
					<input type="hidden" name="LocationID" value="">
					<cfoutput><input type="text" name="LocationOther" value="#LocationOther#" maxLength="200"></cfoutput>	
				</td>		
			</cfsavecontent>
		</cfif>  
	</cfif>
	
 	<cfreturn rString>
</cffunction>

