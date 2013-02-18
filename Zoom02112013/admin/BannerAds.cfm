
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Banner Ads">
<cfinclude template="../Lighthouse/Admin/Header.cfm">

<cfoutput><script language="JavaScript" src="#Request.HTTPSURL#/scripts/jquery-1.3.2.min.js" type="text/javascript"></script></cfoutput>
<cfset positionID = 0>
<cfif isDefined("action") AND Action EQ "edit">
	<cfquery name="getEditInfo" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT PositionID
		FROM BannerAds
		WHERE BannerAdID = <cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfset positionID = getEditInfo.positionID>
</cfif>

<lh:MS_Table table="BannerAdsView" title="#pg_title#" disallowedActions="Add" >
	
	<lh:MS_TableColumn
		ColName="BannerAdID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Search="no"	
		Identity="true" />	
	
	<lh:MS_TableColumn
		ColName="UserID3"
		DispName="Business Account"
		type="pseudo"
		Expression="'<a href=""Accounts.cfm?Action=Edit&PK=' + Cast(UserID as varchar(20)) +'"">' + Cast(UserID as varchar(20)) + '</a>'"
		Editable="No"
		Search="No"
		View="no"
		ShowOnEdit="true" />
		
		<lh:MS_TableColumn
		ColName="PositionID"
		DispName="Position"
		type="select"
		FKTable="BannerAdPosition"
		FKColName="PositionID"
		FKDescr="Position"
		View="Yes"	
		SelectQuery="Select PositionID as SelectValue, Position as SelectText From BannerAdPosition Order By PositionID"	
		Required="Yes" />
			
		
		<lh:MS_TableColumn
		ColName="PaymentStatusID"
		DispName="Order Status"
		type="select"
		FKTable="PaymentStatuses"
		FKColName="PaymentStatusID"
		FKDescr="Title"	
		View="no"
		Edit="no"	
		Editable="no"		 />		
		
	<lh:MS_TableColumn
		ColName="ParentSectionID"
		DispName="&nbsp;&nbsp;&nbsp;Parent Section"
		type="checkboxgroup"
		FKTable="PageSectionsView"
		FKColName="ParentSectionID"
		FKDescr="Title"
		FKOrderBy="OrderNum"
		FKJoinTable="BannerAdParentSections"
		SelectQuery="Select ParentSectionID as SelectValue, Title as SelectText From PageSectionsView Where SectionID < 1000 Order By OrderNum"
		Required="No"
		ShowCheckAll="false"
		checkboxcols="1"
			 />			
	
	<lh:MS_TableColumn
		ColName="BannerAdTypeID"
		DispName="&nbsp;Banner Ad Type"
		type="select"
		FKTable="BannerAdTypes"
		FKColName="BannerAdTypeID"
		FKDescr="BannerAdType"
		FKORderBy="BannerAdTypeID"
		Required="Yes"
		View="No"	
		 />
	
	<lh:MS_TableColumn
		ColName="ClickThroughs"
		DispName="Click Throughs"
		type="pseudo"
		Expression="ImpressionsExpanded + ImpressionsExternal"
		Editable="No"
		Search="No"
		View="no"
		ShowOnEdit="true" />
		
	<lh:MS_TableColumn
		ColName="BannerAdUrl"
		DispName="Banner Ad Url"	
		type="text" 
		MaxLength="200"
		Required="No" 			
		 />
		
	<lh:MS_TableColumn
		ColName="OrderDate"
		Dispname="Order Date"	
		type="date" 
		Edit="No"		
		View="No"
		Editable="No"	
		Required="Yes"
		Format="DD/MM/YYYY"	 />		
		
	<lh:MS_TableColumn
		ColName="StartDate"
		Dispname="Start Date"	
		type="date" 
		MaxLength="20"
		Edit="No"		
		Required="Yes" 
		View="No"
		Format="DD/MM/YYYY"	/>	
		
	<lh:MS_TableColumn
		ColName="EndDate"
		Dispname="End Date"	
		type="date" 
		MaxLength="20"
		Edit="No"		
		Required="Yes"
		View="No"	 
		Format="DD/MM/YYYY"/>
			
	<cfif isDefined("action") AND ListFind("View",action)>	
		<lh:MS_TableColumn 
		colname="Status" 
		dispname="Status"	
		type="text" 
		View="Yes"
		Edit="No"	
		Search="No"		 />	
	</cfif>	
		
	<lh:MS_TableColumn
			ColName="BannerAdImage"
			DispName="Image"
			type="File"
			Directory="#Request.MCFUploadsDir#/BannerAds"
			NameConflict="makeunique"
			DeleteWithRecord="Yes"
			Search="No"
		/>

	<lh:MS_TableColumn
			ColName="BannerAdLinkFile"
			DispName="File"
			type="File"
			Directory="#Request.MCFUploadsDir#/BannerAds"
			NameConflict="makeunique"
			DeleteWithRecord="Yes"
			Search="No"
		/>	
		
	
	
		
		<cfif isDefined("action") AND ListFind("Edit",action)>
		<lh:MS_TableColumn
			ColName="BannerAdID2"
			DispName="Related Orders"
			type="select-multiple"
			FKTable="RelatedBannerAdOrdersView"
			FKJoinTable="BannerAdRelatedOrdersView"	
			FKColName="BannerADID"	
			FKJoinColName="BannerADID"	
			FKDescr="distinct('<br>' + OrderLink)"
			Editable="no" />
			
	</cfif>			
	
		<lh:MS_TableColumn 
		colname="active" 
		dispname="Banner Active?"	
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="1"
		View="No"
		Search="Yes" />		
		
		<lh:MS_TableColumn 
		colname="reviewed" 
		dispname="Banner Reviewed?"	
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="0"
		View="No"
		Search="Yes" />		

	<lh:MS_TableRowAction
		ActionName="Custom"
		Label="Activity Report"
		HREF="BannerAdActivity.cfm?BannerAdID=##pk##" />	
	
		<lh:MS_TableEvent
		EventName="OnBeforeUpdate"
		Include="../../admin/BannerAd_onBeforeUpdate.cfm" />
</lh:MS_Table>


<cfif isDefined("action") AND Action is "Edit">
	<cfquery name="UpdateHistory" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select U.UpdateDate, U.Descr,
		IsNull(Us.FirstName,'') + ' ' + IsNull(Us.LastName,'') as UpdatedBy
		From Updates U 
		Left Outer Join LH_Users Us on U.UpdatedByID=Us.UserID
		Where U.BannerAdID=<cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">
		Order By U.UpdateDate Desc
	</cfquery>
	<p>
	<cfif UpdateHistory.RecordCount>
		<p><strong>Banner Ad Update History</strong><br>
		<cfoutput query="UpdateHistory">
			#DateFormat(UpdateDate,'dd/mm/yyyy')#: by #UpdatedBy#: <br>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#Replace(Descr,"|","<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;","ALL")#<br>
		</cfoutput>		
	</cfif>
</cfif>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">