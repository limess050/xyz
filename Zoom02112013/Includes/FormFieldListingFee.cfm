<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td class="rightAtd">
				<!--- <div id="ListingFeeDiv">Listing Fee: <span id="ListingFeeSpan"></span></div> --->
				<cfif ListFind("5",caller.ParentSectionID) and ListFind("6,7,8",caller.ListingTypeID)>
					<div id="ApplyHAndRPackageDiv" class="ApplyPackagesDiv"></div>
				</cfif>					
				<cfif ListFind("55",caller.ParentSectionID) and ListFind("84,85,86",caller.CategoryID) and ListFind("4,5",caller.ListingTypeID)>
					<div id="ApplyVPackageDiv" class="ApplyPackagesDiv"></div>
				</cfif>			
				<cfif ListFind("8",caller.ParentSectionID) and ListFind("10,12",caller.ListingTypeID)>
					<div id="ApplyJRPackageDiv" class="ApplyPackagesDiv"></div>
				</cfif>
				<input type="hidden" name="ListingFee" id="ListingFee" value="#caller.ListingFee#">
			</td>
			<td valign="top">
				<strong>Please complete the form below. Required fields are marked with an “*”.</strong>
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set ListingFee=<cfif Len(caller.ListingFee)><cfqueryparam value="#caller.ListingFee#" cfsqltype="CF_SQL_MONEY"><cfelse>0</cfif>	
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
		and InProgress=1<!--- Don't change fees for listings already submitted. --->
	</cfquery>	
<cfelseif Action is "Validate">	

</cfif>
