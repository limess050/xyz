<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td class="rightAtd">
				<cfswitch expression="#caller.CategoryID#">
					<cfcase value="289">
						*&nbsp;Tender&nbsp;Title:
					</cfcase>
					<cfdefaultcase>
						*&nbsp;Position&nbsp;Title:
					</cfdefaultcase>
				</cfswitch>				
			</td>
			<td>
				<input name="ShortDescr" id="ShortDescr" value="#caller.ShortDescr#" maxLength="200">
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set ShortDescr=<cfqueryparam value="#caller.ShortDescr#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.ShortDescr)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
	if (!checkText(formObj.elements["ShortDescr"],"<cfif caller.CategoryID is "289">Tender<cfelse>Position</cfif> Title")) return false;	
</cfif>
