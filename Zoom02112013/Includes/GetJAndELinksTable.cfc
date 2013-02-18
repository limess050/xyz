<!--- This creates the html ofr the Links tables in the Jobs & Employment Sections, which has a custom hierarchy, to sort Opportunites from Seekings in displaying them.--->
<cfinclude template="../application.cfm">
<cfset Edit="0">
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfsetting showdebugoutput="no">

<cffunction name="Get" access="remote" returntype="string" displayname="Returns Listing Type ID Select list for passed SectionID">
	<cfargument name="TID" required="yes"><!--- Homepage or Pop-up --->
	<cfargument name="ID" required="yes"><!--- Seeking or Opps --->
	
	
	
	<cfparam name="SubSectionID" default="">
	<cfparam name="ShowEmptyCategories" default="1">
	
	<cfquery name="SectionLinks" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select C.SectionID, S.Title as SubSection, S.OrderNum as SectionOrderNum,
		C.CategoryID, C.Title as Category, C.OrderNum as CategoryOrderNum, C.SectionID, C.ParentSectionID,
		L.ListingID
		From Sections S
		<cfif ShowEmptyCategories>
			Left Outer Join Categories C on S.SectionID=C.SectionID or (C.ParentSectionID=S.SectionID and C.SectionID is null) 
			Left Outer Join ListingCategories LC on C.CategoryID=LC.CategoryID
			Left Outer Join ListingsView L on LC.ListingID=L.ListingID and L.Active=1 and L.Reviewed=1 and L.ExpirationDate >= #application.CurrentDateInTZ# and L.DeletedAfterSubmitted=0 and (L.Deadline is null or L.Deadline >= DATEADD(Day, 0, DATEDIFF(Day, 0, DATEADD(HOUR,3,GETUTCDATE()))))
		<cfelse>
			Inner Join Categories C on S.SectionID=C.SectionID or (C.ParentSectionID=S.SectionID and C.SectionID is null)
			Inner Join ListingCategories LC on C.CategoryID=LC.CategoryID
			Inner Join ListingsView L on LC.ListingID=L.ListingID and L.Active=1 and L.Reviewed=1 and L.ExpirationDate >= #application.CurrentDateInTZ# and L.DeletedAfterSubmitted=0 and (L.Deadline is null or L.Deadline >= #application.CurrentDateInTZ#)
		</cfif>
		Where S.Active=1
		and C.Active=1
		and C.ParentSectionID=8
		<cfif Len(SubSectionID)>
			and C.SectionID=<cfqueryparam value="#SubSectionID#" cfsqltype="CF_SQL_INTEGER">
		</cfif>
		<cfswitch expression="#ID#">
			<cfcase value="1">				
				and (L.ListingTypeID is null or L.ListingTypeID in (10,12))
				and S.SectionID <> 29
			</cfcase>
			<cfcase value="2">				
				and (L.ListingTypeID is null or L.ListingTypeID in (11,13))
				and S.SectionID <> 29
			</cfcase>
			<cfcase value="3">				
				and (L.ListingTypeID is null or L.ListingTypeID in (10,12))
				and S.SectionID = 29
			</cfcase>
			<cfcase value="4">				
				and (L.ListingTypeID is null or L.ListingTypeID in (11,13))
				and S.SectionID = 29
			</cfcase>
		</cfswitch>
		Order By SectionOrderNum, CategoryOrderNum, L.ListingID
	</cfquery>
	<cfquery name="SectionLinks" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select C.SectionID, S.Title as SubSection, S.OrderNum as SectionOrderNum,
	C.CategoryID, C.Title as Category, C.OrderNum as CategoryOrderNum, C.SectionID, C.ParentSectionID, 
	(Select Count(L.ListingID) 
	From ListingsView L Inner Join ListingCategories LC on L.ListingID=LC.ListingID
	Where LC.CategoryID=C.CategoryID
	<cfinclude template="../includes/LiveListingFilter.cfm"> 	
	<cfswitch expression="#ID#">
		<cfcase value="1">				
			and (L.ListingTypeID is null or L.ListingTypeID in (10,12))
			and S.SectionID <> 29
		</cfcase>
		<cfcase value="2">				
			and (L.ListingTypeID is null or L.ListingTypeID in (11,13))
			and S.SectionID <> 29
		</cfcase>
		<cfcase value="3">				
			and (L.ListingTypeID is null or L.ListingTypeID in (10,12))
			and S.SectionID = 29
		</cfcase>
		<cfcase value="4">				
			and (L.ListingTypeID is null or L.ListingTypeID in (11,13))
			and S.SectionID = 29
		</cfcase>
	</cfswitch>)
	as ListingCount
	From Sections S
	Left Outer Join Categories C on S.SectionID=C.SectionID or (C.ParentSectionID=S.SectionID and C.SectionID is null) 
	Where S.Active=1
	and C.Active=1
	and C.ParentSectionID=8
	<cfif Len(SubSectionID)>
		and C.SectionID=<cfqueryparam value="#SubSectionID#" cfsqltype="CF_SQL_INTEGER">
	</cfif>
	Order By SectionOrderNum, CategoryOrderNum
</cfquery>

	<cfset rString = "">   
	
	<cfsavecontent variable="rString">
		<cfoutput query="SectionLinks" group="SectionOrderNum">
			<div class="hpitem-expand"><span class="hpcategory-expand"><cfif Len(SectionID)>#SubSection#<cfelse>&nbsp;</cfif></span><br />
			<cfset ShowComma="0">
				<cfset LinkCount=1>
	  		<cfoutput group="CategoryOrderNum"><cfif Len(Category)><cfif ShowComma>, </cfif><a href="#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#CategoryID#&JETID=#ID#" <cfif LinkCount MOD 2 is "0">class="alternatelink"</cfif>>#Category#<!--- <cfif request.environment neq "live"> ---> (#ListingCount#)<!--- </cfif> ---></a></cfif><cfset ShowComma="1"><cfset LinkCount=LinkCount+1></cfoutput>
			</div>
		</cfoutput>
	</cfsavecontent>	
	

 	<cfreturn rString>
</cffunction>

