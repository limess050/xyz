<!--- ParentSectionID passed in and SubSctionID select lit passed out.
If SectionID passed in and SectionID exists in resulting select list, marked it 'selected' --->

<cfsetting showdebugoutput="no">

<cffunction name="SelectList" access="remote" returntype="string" displayname="Returns Listing Type ID Select list for passed SectionID">
	<cfargument name="CategoryID" required="yes">
	<cfargument name="SectionID" required="yes">
	<cfargument name="ParentSectionID" required="yes">
	<cfargument name="ListingTypeID" required="yes">
	<cfargument name="Action" type="string" required="yes">
	
	<cfset CategoryID=Replace(arguments.CategoryID,"|",",","ALL")>
	<cfset SectionID=Replace(arguments.SectionID,"|",",","ALL")>
	<cfset ParentSectionID=Replace(arguments.ParentSectionID,"|",",","ALL")>
	<cfset ListingTypeID=Replace(arguments.ListingTypeID,"|",",","ALL")>
	
	<cfquery name="getListingTypes"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select LT.ListingTypeID as SelectValue, LT.Descr as SelectText
		From ListingTypes LT
		Inner Join CategoryListingTypes CLT on LT.ListingTypeID=CLT.ListingTypeID
		Where CLT.CategoryID in (<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER" list="Yes">) 
		Order by LT.OrderNum
	</cfquery>
	
	<cfquery name="getListingTypesForJandE"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select LT.ListingTypeID as SelectValue, LT.Descr as SelectText
		From ListingTypes LT
		Where LT.ListingTypeID in 
		<cfif ListFind("19",SectionID)>
			(10,11) 
		<cfelse>
			(12,13) 
		</cfif>
		Order by LT.OrderNum
	</cfquery>

	<cfset rString = "">       
	
	<cfif getListingTypes.RecordCount gt 1>	
		<cfsavecontent variable="rString">1|
			<td class="ADDLABELCELL">
				<label for="ListingTypeID">Listing Type:</label>
			</td>
			<td class="ADDFIELDCELL">
				<input name="ListingTypeID_isEditable" value="true" type="hidden"> 
				<select name="ListingTypeID" id="ListingTypeID">					
					<option value="">--- Select Listing Type ---</option>
					
					<cfoutput query="getListingTypes">
						<option value="#SelectValue#" <cfif ListFind(ListingTypeID,SelectValue)>selected</cfif>>#SelectText#
					</cfoutput>						
				</select>
				<input type="hidden" name="CheckListingType" value="1">
			</td>		
		</cfsavecontent>	
	<cfelseif ListFind("19,20",SectionID)>
		<cfsavecontent variable="rString">1|
			<td class="ADDLABELCELL">
				<label for="ListingTypeID">Listing Type:</label>
			</td>
			<td class="ADDFIELDCELL">
				<input name="ListingTypeID_isEditable" value="true" type="hidden"> 
				<select name="ListingTypeID" id="ListingTypeID">					
					<option value="">--- Select Listing Type ---</option>
					
					<cfoutput query="getListingTypesForJandE">
						<option value="#SelectValue#" <cfif ListFind(ListingTypeID,SelectValue)>selected</cfif>>#SelectText#
					</cfoutput>						
				</select>
				<input type="hidden" name="CheckListingType" value="1">
			</td>		
		</cfsavecontent>	
	<cfelseif getListingTypes.RecordCount>
		<cfsavecontent variable="rString">0|
			<td class="ADDLABELCELL">
				&nbsp;
			</td>
			<td class="ADDFIELDCELL">
				<input name="ListingTypeID_isEditable" value="true" type="hidden"> 
				<input name="ListingTypeID" id="ListingTypeID" value="<cfoutput>#getListingTypes.SelectValue#</cfoutput>" type="hidden"> 
				<input type="hidden" name="CheckListingType" value="0">
			</td>		
		</cfsavecontent>	
	</cfif> 	

 	<cfreturn rString>
</cffunction>

