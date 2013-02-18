<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>

<cfif Len(caller.ListingID)><!--- Skip entirely if new lisitng being added. Form field only to display on edit, not add. --->

	<cfif Action is "Form">	
		<cfquery name="Categories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select CategoryID as SelectValue, Title as SelectText 
			From Categories
			Where Active=1
			<cfswitch expression="#caller.ListingTypeID#">
				<cfcase value="10">
					and SectionID=19
				</cfcase>
				<cfcase value="12">
					and SectionID=20
				</cfcase>
			</cfswitch>		
			Order By OrderNum
		</cfquery>
		
		<cfoutput>		
			<tr>
				<td class="rightAtd">
					*&nbsp;Categories:<br />
					<span class="instructions">(Choose all that apply)<br />To multi-select, hold the “Ctrl” key and click each option desired.</span>
				</td>
				<td>
					<select name="ListingCategoryID" id="ListingCategoryID" multiple <cfif Categories.RecordCount gt "10">size="10"</cfif>>
						<option value="">-- Select --
						<cfloop query="Categories">
							<option value="#SelectValue#" <cfif ListFind(caller.CategoryID,SelectValue)>Selected</cfif>>#SelectText#
						</cfloop>
					</select>
				</td>
			</tr>
		</cfoutput>
	<cfelseif Action is "Process">	
		<cfquery name="deleteExistingCategories"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Delete From ListingCategories
			Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfloop list="#caller.ListingCategoryID#" index="i">		
			<cfquery name="insertCategories"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Insert into ListingCategories
				(ListingID, CategoryID)
				VALUES
				(<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#i#" cfsqltype="CF_SQL_INTEGER">)
			</cfquery>
		</cfloop>
	<cfelseif Action is "Validate">			
			if (!checkSelected(formObj.elements["ListingCategoryID"],"Categories")) return false;						
	</cfif>
<cfelseif Action is "Form">
	<!--- Use hidden variable to pass through Categories selected on first form. --->
	<cfoutput>
		<input type="hidden" name="ListingCategoryID" ID="ListingCategoryID" value="#caller.CategoryID#">
	</cfoutput>
</cfif>
