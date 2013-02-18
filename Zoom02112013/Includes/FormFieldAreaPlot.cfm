This template is no longer in use (includes/FormFieldAreaPlot.cfm) <cfabort>

<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td class="rightAtd">		
				<cfset 	AreaPlotLabel="Street/Area &&nbsp;Plot Number">
				<cfif IsDefined('session.UserID') and Len(session.UserID) and not caller.edit>
					<cfinclude template="../includes/MyListings.cfm">	
					<cfif AllowHAndR>
						<cfset 	AreaPlotLabel="Listing&nbsp;Title">
					</cfif>
				</cfif>
				*&nbsp;#AreaPlotLabel#:
			</td>
			<td>
				<input name="AreaPlot" id="AreaPlot" value="#caller.AreaPlot#" maxLength="200">
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set AreaPlot=<cfqueryparam value="#caller.AreaPlot#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.AreaPlot)#">	
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
	if (!checkText(formObj.elements["AreaPlot"],"Street/Area & Plot Number")) return false;
</cfif>
