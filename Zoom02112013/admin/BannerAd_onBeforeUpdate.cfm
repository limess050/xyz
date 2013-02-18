

<cfset CheckboxList="Active,Reviewed">
<cfset DateList="StartDate,EndDate">
<cfset TitleLabel="Listing Title">
<cfset ShortDescrLabel="Short Description">
<cfset DeadlineLabel="Deadline">
<cfset LongDescrLabel="Long Description">
<cfset LocationTextLabel="Location">
<cfset UploadedDocLabel="Uploaded Document">
		
<cfset TrackedColumns="PlacementID,PositionID,Impressions,BannerAdURL,StartDate,EndDate,BannerAdImage,Active,Reviewed">

	


<cfset ChangedString="">

<cfquery name="getOrig" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select #Replace(TrackedColumns,"_","","ALL")#
	From BannerAds B
	Left Outer Join BannerAdParentSections BPS on B.BannerADID = BPS.BannerAdID
	Left Outer join BannerAdSections BS on B.BannerADID = BS.BannerAdID
	Left Outer Join BannerAdCategories BC on B.BannerADID = BC.BannerAdID
	Where B.BannerADID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>
<cfquery name="ParentSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select ParentSectionID as SelectValue, Title as SelectText
	From ParentSectionsView
	Order By ParentSectionID
</cfquery>
<cfquery name="Sections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SectionID as SelectValue, Title as SelectText
	From SectionsView
	Order By SectionID
</cfquery>
<cfquery name="Categories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select CategoryID as SelectValue, Title as SelectText
	From Categories
	Order By CategoryID
</cfquery>

<cfif ListFind(TrackedColumns,"PositionID")>
	
	<cfquery name="Positions" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select PositionID as SelectValue, Position as SelectText
		From BannerAdPosition
		Order By PositionID
	</cfquery>
</cfif>
<cfif ListFind(TrackedColumns,"PlacementID")>
	<cfquery name="Placements" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select PlacementID as SelectValue, Placement as SelectText
		From BannerAdPlacement
		Order By PlacementID
	</cfquery>
</cfif>


<cfloop list="#TrackedColumns#" index="i">
	<cfset LabelName=Replace(Replace(i,"ID",":"),"_"," ","ALL")>
	
	<cfset ColumnName=Replace(i,"_","","ALL")>
	<cfset OldValue=Evaluate('getOrig.' & ColumnName)>
	
	
	<cfif ListFind(DateList,i)>
		<cfset OldValue=DateFormat(OldValue,"dd/mm/yyyy")>
	</cfif>
	
	<cfif ListFind(CheckboxList,i)>
		<cfif IsDefined('#ColumnName#')>
			<cfif not Len(OldValue) OR OldValue EQ 0>
				<cfset ChangedString=ListAppend(ChangedString,"#LabelName# checked.","|")>
			</cfif>
		<cfelseif OldValue EQ 1>
			<cfset ChangedString=ListAppend(ChangedString,"#LabelName# unchecked.","|")>
		</cfif>
	<cfelse>
		
		<cfif IsDefined("#columnName#")>
			<cfset NewValue=Evaluate(ColumnName)>	
		<cfelse>
			<cfset NewValue="">	
		</cfif>
		
		
		
		<cfif OldValue neq NewValue>
			<cfif ListFind("ParentSectionID,SectionID,CategoryID,PositionID,PlacementID",ColumnName)>
				<cfswitch expression="#ColumnName#">
					<cfcase value="ParentSectionID">
						<cfloop query="ParentSections">
							<cfif Len(NewValue) and SelectValue is NewValue>
								<cfset NewValue=SelectText>
							</cfif>
							<cfif Len(OldValue) and SelectValue is OldValue>
								<cfset OldValue=SelectText>
							</cfif>
						</cfloop>
					</cfcase>
					<cfcase value="SectionID">
						<cfloop query="Sections">
							<cfif Len(NewValue) and SelectValue is NewValue>
								<cfset NewValue=SelectText>
							</cfif>
							<cfif Len(OldValue) and SelectValue is OldValue>
								<cfset OldValue=SelectText>
							</cfif>
						</cfloop>
					</cfcase>
					<cfcase value="CategoryID">
						<cfloop query="Categories">
							<cfif Len(NewValue) and SelectValue is NewValue>
								<cfset NewValue=SelectText>
							</cfif>
							<cfif Len(OldValue) and SelectValue is OldValue>
								<cfset OldValue=SelectText>
							</cfif>
						</cfloop>
					</cfcase>
					<cfcase value="PositionID">
						<cfloop query="Positions">
							<cfif Len(NewValue) and SelectValue is NewValue>
								<cfset NewValue=SelectText>
							</cfif>
							<cfif Len(OldValue) and SelectValue is OldValue>
								<cfset OldValue=SelectText>
							</cfif>
						</cfloop>
					</cfcase>
					<cfcase value="PlacementID">
						<cfloop query="Placements">
							<cfif Len(NewValue) and SelectValue is NewValue>
								<cfset NewValue=SelectText>
							</cfif>
							<cfif Len(OldValue) and SelectValue is OldValue>
								<cfset OldValue=SelectText>
							</cfif>
						</cfloop>
					</cfcase>
				</cfswitch>
			</cfif>
			
			
		<cfif Len(NewValue) gt 200 or Len(OldValue) gt 200><!--- Long strings just cause a huge confusing output on the Update History --->				
			<cfif not Len(NewValue)>
				<cfif ColumnName NEQ "BannerAdImage">
					<cfset ChangedString=ListAppend(ChangedString,"#LabelName# deleted.","|")>
				<cfelse>
					<cfif isDefined("BannerAdImage_Delete")> 
						<cfset ChangedString=ListAppend(ChangedString,"#LabelName# deleted.","|")>
					</cfif>	
				</cfif>	
			<cfelseif Not Len(OldValue)>
				<cfset ChangedString=ListAppend(ChangedString,"#LabelName# text entered.","|")>
			<cfelse>
				<cfset ChangedString=ListAppend(ChangedString,"#LabelName# text changed.","|")>
			</cfif>
		<cfelse>
			<cfif not Len(NewValue)>
				<cfif ColumnName NEQ "BannerAdImage">
					<cfset ChangedString=ListAppend(ChangedString,"#LabelName# deleted.","|")>
				<cfelse>
					<cfif isDefined("BannerAdImage_Delete")> 
						<cfset ChangedString=ListAppend(ChangedString,"#LabelName# deleted.","|")>
					</cfif>	
				</cfif>	
			<cfelseif Not Len(OldValue)>
				<cfset ChangedString=ListAppend(ChangedString,"#LabelName# '#NewValue#' entered.","|")>
			<cfelse>
				<cfset ChangedString=ListAppend(ChangedString,"#LabelName# '#OldValue#' changed to '#NewValue#'.","|")>
			</cfif>
		</cfif>	
	</cfif>
	
		
				
	</cfif>
	
	
	
</cfloop>





<cfif Len(ChangedString)>
	<cfquery name="updatedBy" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Insert into Updates
		(BannerAdID, UpdateDate, UpdatedByID, Descr)
		VALUES
		(<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">,
		GetDate(),
		<cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">,
		<cfqueryparam value="#ChangedString#" cfsqltype="CF_SQL_VARCHAR" maxlength="2000">)
	</cfquery>
</cfif>

