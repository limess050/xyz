<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>



<cfif Action is "Form">	
	<cfquery name="PriceRanges" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select PriceRangeID as SelectValue, Title as SelectText 
		From PriceRanges
		Where Active=1
		Order By OrderNum
	</cfquery>
	
	<cfoutput>		
		<tr>
			<td class="rightAtd">
				<cfif not caller.PhoneOnlyEntry>*&nbsp;</cfif>Price&nbsp;Ranges:<br />
				<span class="instructions">(Choose all that apply)<br />To multi-select, hold the “Ctrl” key and click each option desired.</span>
			</td>
			<td>
				<select name="PriceRangeID" id="PriceRangeID" size="3" multiple>
					<cfloop query="PriceRanges">
						<option value="#SelectValue#" <cfif ListFind(caller.PriceRangeID,SelectValue)>Selected</cfif>>#SelectText#
					</cfloop>
				</select>
			</td>
		</tr>	
	</cfoutput>
<cfelseif Action is "Process">	
	<!--- Delete existing records --->
	<cfquery name="insertListingPriceRanges"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Delete From ListingPriceRanges
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<!--- Add new records --->
	<cfloop list="#caller.PriceRangeID#" index="i">		
		<cfquery name="insertListingPriceRanges"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Insert into ListingPriceRanges
			(ListingID, PriceRangeID)
			VALUES
			(<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">,
			<cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">)
		</cfquery>
	</cfloop>
<cfelseif Action is "Validate">			
		<cfif not caller.PhoneOnlyEntry>if (!checkSelected(formObj.elements["PriceRangeID"],"Price Range")) return false;</cfif>
</cfif>
