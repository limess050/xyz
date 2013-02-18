<!---
Site Map Template
--->



<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfquery name="getImpressionSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SectionID
	From PageSections
	Where PageID = <cfqueryparam value="#PageID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfset ImpressionSectionID=getImpressionSection.SectionID>
<cfif not Len(ImpressionSectionID)>
	<cfset ImpressionSectionID = 0>
</cfif>

<cfif not IsDefined('application.SectionImpressions')>
	<cfset application.SectionImpressions= structNew()>
</cfif>
<cfif StructKeyExists(application.SectionImpressions,ImpressionSectionID)>
	<cfset application.SectionImpressions[ImpressionSectionID] = application.SectionImpressions[ImpressionSectionID] + 1>
<cfelse>
	<cfset application.SectionImpressions[ImpressionSectionID] = 1>
</cfif>

<cfinclude template="header.cfm">

<!--- <cfoutput>#Request.Page.GetCookieCrumb()#</cfoutput><br>
<cfoutput>#Request.Page.GetSectionName()#</cfoutput> --->

<!--- <lh:MS_SitePagePart id="title" class="title">
<lh:MS_SitePagePart id="body" class="body">
 --->
<cfquery name="getListingTree" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum,
	S.SectionID, S.Title as STitle, S.OrderNum as SOrderNum,
	C.CategoryID, C.Title as CTitle, C.OrderNum as COrderNum,
	L.ListingID, L.ListingTitle, L.ListingTypeID, L.URLSafeTitle
	FROM Categories C
	Inner Join Sections S on C.SectionID=S.SectionID
	Inner Join ParentSectionsView PS on S.ParentSectionID=PS.ParentSectionID
	Left Outer Join ListingCategories LC on C.CategoryID=LC.CategoryID
	Left Outer Join ListingsView L on LC.ListingID=L.ListingID and L.Active=1 and L.Reviewed=1 and L.ExpirationDate >= #application.CurrentDateInTZ# and (L.Deadline is null or L.Deadline >= #application.CurrentDateInTZ#) and L.DeletedAfterSubmitted=0
	UNION
	SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum,
	PS.ParentSectionID*1000000 as SectionID, null as STitle, 0 as SOrderNum,
	C.CategoryID, C.Title as CTitle, C.OrderNum as COrderNum,
	L.ListingID, L.ListingTitle, L.ListingTypeID, L.URLSafeTitle
	FROM Categories C
	Inner Join ParentSectionsView PS on C.ParentSectionID=PS.ParentSectionID and C.SectionID is null
	Left Outer Join ListingCategories LC on C.CategoryID=LC.CategoryID
	Left Outer Join ListingsView L on LC.ListingID=L.ListingID and L.Active=1 and L.Reviewed=1 and L.ExpirationDate >= #application.CurrentDateInTZ# and (L.Deadline is null or L.Deadline >= #application.CurrentDateInTZ#) and L.DeletedAfterSubmitted=0
	Order By PSOrderNum, SOrderNum, COrderNum, ListingTitle
</cfquery>
<cfoutput>
<div class="centercol-inner legacy"> <h1><lh:MS_SitePagePart id="title" class="title"></h1>
<p>&nbsp;</p>

 <div class="breadcrumb""><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/">Home</a> &gt; </div>

</cfoutput>

<lh:MS_SitePagePart id="body" class="body">
<p>&nbsp;</p>
<table>
	<cfoutput query="getListingTree" group="PSTitle">		
		<tr>
			<td colspan="4">#PSTitle#</td>
		</tr>
		<cfoutput group="STitle">
			<cfif Len(STitle)>
				<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td colspan="3">#STitle#</td>
				</tr>
			</cfif>
			<cfoutput group="CTitle">
				<cfif not ListFind("370",CategoryID)>
					<tr>
						<td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
						<td colspan="2"><a href="Category?CategoryID=#CategoryID#">#CTitle#</a></td>
					</tr>
					<cfoutput>
						<cfif Len(ListingTitle) and not ListFind("3,4,5,6,7,8",ListingTypeID)>
							<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<cfif ListFind("1,2,14",ListingTypeID) and Len(URLSafeTitle)>
									<td><a href="#URLSafeTitle#">#ListingTitle#</a></td>
								<cfelse>
									<td><a href="ListingDetail?ListingID=#ListingID#">#ListingTitle#</a></td>
								</cfif>
							</tr>
						</cfif>
					</cfoutput>
				</cfif>
			</cfoutput>
		</cfoutput>	
	</cfoutput>
</table>



</div>

<!-- END CENTER COL -->

<cfinclude template="footer.cfm">
