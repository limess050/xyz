<!--- ParentSectionID passed in and SubSctionID select lit passed out.
If SectionID passed in and SectionID exists in resulting select list, marked it 'selected' --->

<cfsetting showdebugoutput="no">

<cffunction name="get" access="remote" returntype="string" displayname="Returns a table with form fields of Parent Section, Sefction, Category, and Listing Type.">
	<cfargument name="ParentSectionID" required="yes">
	<cfargument name="SectionID" required="yes">
	<cfargument name="CategoryID" required="yes">
	<cfargument name="ListingTypeID" required="yes">
	
	<cfset ParentSectionID=Replace(arguments.ParentSectionID,"|",",","ALL")>
	<cfset SectionID=Replace(arguments.SectionID,"|",",","ALL")>
	<cfset CategoryID=Replace(arguments.CategoryID,"|",",","ALL")>
	<cfset ListingTypeID=Replace(arguments.ListingTypeID,"|",",","ALL")>
	
	<cfquery name="ParentSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select PS.ParentSectionID as SelectValue, PS.Title as SelectText
		From ParentSectionsView PS
		Where PS.Active=1
		Order by PS.OrderNum
	</cfquery>
	
	<cfif ParentSectionID neq "0">
		<cfquery name="getSections"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select S.SectionID as SelectValue, S.Title as SelectText, IsNull(PS.Title,'') + ' - ' + IsNull(S.Title,'') as FullSelectText
			From Sections S
			Inner Join ParentSectionsView PS on S.ParentSectionID=PS.ParentSectionID
			Where S.ParentSectionID in (<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
			and S.ParentSectionID is not null
			and S.Active=1
			Order by S.OrderNum
		</cfquery>
	</cfif>
	
	<!--- <cfquery name="getListingTypes"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
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
	</cfquery> --->

	<cfset rString = "">       
	
	<cfsavecontent variable="rString">
		<table border="0" cellspacing="0" cellpadding="0" class="datatable">
			<tr>
				<td>
					Section:
				</td>
				<td>
					<select name="ParentSectionID" id="ParentSectionID">
						<option value="">-- Select a Section --
						<cfoutput query="ParentSections">
							<option value="#SelectValue#" <cfif SelectValue is ParentSectionID>selected</cfif>>#SelectText#
						</cfoutput>
					</select>
				</td>
			</tr>
			<script>
				$("#ParentSectionID").change(function(e)
			    {	
					parentSectionID=$("#ParentSectionID").val();
					if (parentSectionID=='') {
						parentSectionID=0;
					}
					sectionID=0;
					categoryID=0;
					listingTypeID=0;
					checkAllowTravel();
					$("#NextButtonDiv").hide();
					getSelections();
			    });
			</script>
			<cfif ParentSectionID neq "0" and getSections.RecordCount>		
				<tr>
					<td class="ADDLABELCELL">
						<label for="SectionID">Sub-Section:</label>
					</td>
					<td class="ADDFIELDCELL">
						<select name="SectionID" id="SectionID">
							<option value=""><cfif getSections.RecordCount>--- Select Sub-section Name ---<cfelse>No Sub-sections exist for this Parent Section</cfif></option>
							<cfoutput query="getSections">
								<option value="#SelectValue#" <cfif ListFind(SectionID,SelectValue)>selected</cfif>>#SelectText#
							</cfoutput>						
						</select>
					</td>	
				</tr>
				<script>
					$("#SectionID").change(function(e)
				    {	
						sectionID=$("#SectionID").val();
						categoryID=0;
						listingTypeID=0;
						checkAllowTravel();
						$("#NextButtonDiv").hide();
						getSelections();
				    });
				</script>
				<cfif ListFind("19,20",SectionID)><!--- Jobs and Employment Professional or Domestic. So show Listing Types now --->			
					<cfquery name="getListingTypes"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
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
					<tr>
						<td class="ADDLABELCELL">
							<label for="ListingTypeID">Listing Type:</label>
						</td>
						<td class="ADDFIELDCELL">
							<select name="ListingTypeID" id="ListingTypeID">					
								<option value="">--- Select Listing Type ---</option>									
								<cfoutput query="getListingTypes">
									<option value="#SelectValue#" <cfif ListFind(ListingTypeID,SelectValue)>selected</cfif>>#SelectText#
								</cfoutput>						
							</select>
							<input type="hidden" name="CheckListingType" value="1">
						</td>	
					</tr>						
					<script>							
						$("#ListingTypeID").change(function(e)
					    {	
							listingTypeID=$("#ListingTypeID").val();
							categoryID=0;
							$("#NextButtonDiv").hide();
							getSelections();
					    });
					</script>
					<cfif ListingTypeID neq "0">
						<cfquery name="getCategories"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							Select C.CategoryID as SelectValue, C.Title as SelectText, IsNull(S.Title,'') + ' - ' + IsNull(C.Title,'') as FullSelectText
							From Categories C
							Inner Join Sections S on C.SectionID=S.SectionID or (C.ParentSectionID=S.SectionID and C.SectionID is null)
							Where C.Active=1 and (
							<cfif SectionID neq "0">C.SectionID in (<cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER" list="Yes">) or </cfif>
							(C.ParentSectionID in (<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER" list="Yes">) and C.SectionID is null)
							)
							Order by S.OrderNum, C.OrderNum
						</cfquery>
						<tr>
							<td class="ADDLABELCELL">
								<label for="SectionID">Category:</label>
								<cfif ListFind("10,12",ListingTypeID)><br /><span class="instructions">(Choose all that apply)<br />To multi-select, hold<br />the “Ctrl” key and click<br />each option desired.</span></cfif>

							</td>
							<td class="ADDFIELDCELL">
								<select name="CategoryID" id="CategoryID" <cfif ListFind("10,12",ListingTypeID)><cfif getCategories.RecordCount gt "10">size="10"</cfif> multiple</cfif>>
									<option value=""><cfif getCategories.RecordCount>--- Select Category Name ---<cfelse>No Categories exist for this Section</cfif></option>										
									<cfoutput query="getCategories">
										<option value="#SelectValue#" <cfif ListFind(CategoryID,SelectValue)>selected</cfif>>#SelectText#
									</cfoutput>						
								</select>
							</td>		
						</tr>				
						<script>							
							$("#CategoryID").change(function(e)
						    {	
								categoryID=$("#CategoryID").val();
								$("#NextButtonDiv").hide();
								getSelections();
						    });
						</script>
						<cfif CategoryID neq "0">
							<script>
								$("#NextButtonDiv").show();
							</script>
						</cfif>
					</cfif>
				<cfelseif SectionID neq "0"><!--- Show Categories --->
					<cfquery name="getCategories"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						Select C.CategoryID as SelectValue, C.Title as SelectText, IsNull(S.Title,'') + ' - ' + IsNull(C.Title,'') as FullSelectText
						From Categories C
						Inner Join Sections S on C.SectionID=S.SectionID or (C.ParentSectionID=S.SectionID and C.SectionID is null)
						Where C.Active=1 and (
						<cfif SectionID neq "0">C.SectionID in (<cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER" list="Yes">) or </cfif>
						(C.ParentSectionID in (<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER" list="Yes">) and C.SectionID is null)
						)
						Order by S.OrderNum, C.OrderNum
					</cfquery>
					<tr>
						<td class="ADDLABELCELL">
							<label for="SectionID">Category:</label>
						</td>
						<td class="ADDFIELDCELL">
							<select name="CategoryID" id="CategoryID">
							<option value=""><cfif getCategories.RecordCount>--- Select Category Name ---<cfelseif SectionID is "0">--- Select Section First ---<cfelse>No Categories exist for this Section</cfif></option>
								
								<cfoutput query="getCategories">
									<option value="#SelectValue#" <cfif ListFind(CategoryID,SelectValue)>selected</cfif>>#SelectText#
								</cfoutput>						
							</select>
						</td>		
					</tr>			
					<script>							
						$("#CategoryID").change(function(e)
					    {	
							categoryID=$("#CategoryID").val();
							listingTypeID=0;
							$("#NextButtonDiv").hide();
							getSelections();
					    });
					</script>
					<cfif CategoryID neq "0">
						<cfquery name="getListingTypes"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							Select LT.ListingTypeID as SelectValue, LT.Descr as SelectText
							From ListingTypes LT
							Inner Join CategoryListingTypes CLT on LT.ListingTypeID=CLT.ListingTypeID
							Where CLT.CategoryID in (<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER" list="Yes">) 
							Order by LT.OrderNum
						</cfquery>
						<cfif getListingTypes.RecordCount is "1">
							<cfoutput><input type="hidden" name="ListingTypeID" ID="ListingTypeID" value="#getListingTypes.SelectValue#"><input type="hidden" name="CheckListingType" value="0"></cfoutput>
							<script>
								$("#NextButtonDiv").show();
							</script>
						<cfelse>
							<tr>
								<td class="ADDLABELCELL">
									<label for="ListingTypeID">Listing Type:</label>
								</td>
								<td class="ADDFIELDCELL">
									<select name="ListingTypeID" id="ListingTypeID">					
										<option value="">--- Select Listing Type ---</option>									
										<cfoutput query="getListingTypes">
											<option value="#SelectValue#" <cfif ListFind(ListingTypeID,SelectValue)>selected</cfif>>#SelectText#
										</cfoutput>						
									</select>
									<input type="hidden" name="CheckListingType" value="1">
								</td>	
							</tr>						
							<script>							
								$("#ListingTypeID").change(function(e)
							    {	
									listingTypeID=$("#ListingTypeID").val();
									$("#NextButtonDiv").hide();
									getSelections();
							    });
							</script>
							<cfif ListingTypeID neq "0">
								<script>
									$("#NextButtonDiv").show();
								</script>
							</cfif>
						</cfif>
					</cfif>
				</cfif>
			<cfelseif ParentSectionID neq "0">	<!--- Parent Section has no SubSections (originally just For Sale By Owner) --->
				<cfquery name="getCategories"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					Select C.CategoryID as SelectValue, C.Title as SelectText, IsNull(S.Title,'') + ' - ' + IsNull(C.Title,'') as FullSelectText
					From Categories C
					Inner Join Sections S on C.SectionID=S.SectionID or (C.ParentSectionID=S.SectionID and C.SectionID is null)
					Where C.Active=1 and (
					<cfif SectionID neq "0">C.SectionID in (<cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER" list="Yes">) or </cfif>
					(C.ParentSectionID in (<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER" list="Yes">) and C.SectionID is null)
					)
					Order by S.OrderNum, C.OrderNum
				</cfquery>
				<tr>
					<td class="ADDLABELCELL">
						<label for="SectionID">Category:</label>
					</td>
					<td class="ADDFIELDCELL">
						<select name="CategoryID" id="CategoryID">
						<option value=""><cfif getCategories.RecordCount>--- Select Category Name ---<cfelse>No Categories exist for this Section</cfif></option>
							
							<cfoutput query="getCategories">
								<option value="#SelectValue#" <cfif ListFind(CategoryID,SelectValue)>selected</cfif>>#SelectText#
							</cfoutput>						
						</select>
					</td>		
				</tr>			
				<script>							
					$("#CategoryID").change(function(e)
				    {	
						categoryID=$("#CategoryID").val();
						listingTypeID=0;
						$("#NextButtonDiv").hide();
						getSelections();
				    });
				</script>
				<cfif CategoryID neq "0">
					<cfquery name="getListingTypes"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						Select LT.ListingTypeID as SelectValue, LT.Descr as SelectText
						From ListingTypes LT
						Inner Join CategoryListingTypes CLT on LT.ListingTypeID=CLT.ListingTypeID
						Where CLT.CategoryID in (<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER" list="Yes">) 
						Order by LT.OrderNum
					</cfquery>
					<cfif getListingTypes.RecordCount is "1">
						<cfoutput><input type="hidden" name="ListingTypeID" ID="ListingTypeID" value="#getListingTypes.SelectValue#"><input type="hidden" name="CheckListingType" value="0"></cfoutput>
						<script>
							$("#NextButtonDiv").show();
						</script>
					<cfelse>
						<tr>
							<td class="ADDLABELCELL">
								<label for="ListingTypeID">Listing Type:</label>
							</td>
							<td class="ADDFIELDCELL">
								<select name="ListingTypeID" id="ListingTypeID">					
									<option value="">--- Select Listing Type ---</option>									
									<cfoutput query="getListingTypes">
										<option value="#SelectValue#" <cfif ListFind(ListingTypeID,SelectValue)>selected</cfif>>#SelectText#
									</cfoutput>						
								</select>
								<input type="hidden" name="CheckListingType" value="1">
							</td>	
						</tr>						
						<script>							
							$("#ListingTypeID").change(function(e)
						    {	
								listingTypeID=$("#ListingTypeID").val();
								$("#NextButtonDiv").hide();
								getSelections();
						    });
						</script>
						<cfif ListingTypeID neq "0">
							<script>
								$("#NextButtonDiv").show();
							</script>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</table>
	</cfsavecontent>	

 	<cfreturn rString>
</cffunction>

