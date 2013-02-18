<!---
Site Map Template generates root/SiteMap.xml file. To be scheduled to update the XML file hourly.
--->
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

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

<cfsavecontent variable="SiteMapXML"><?xml version="1.0" encoding="UTF-8"?>
	<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
	<cfoutput query="getListingTree" group="PSTitle">	
		<cfoutput group="STitle">
			<cfoutput group="CTitle">
				<cfif not ListFind("370",CategoryID)>
					<url>
						<loc>http://www.ZoomTanzania.com/Category?CategoryID=#CategoryID#</loc>
						<lastmod>#DateFormat(Now(),"yyyy-mm-dd")#</lastmod>
    					<changefreq>hourly</changefreq>
    					<priority>0.8</priority>
					</url>
					<cfoutput>
						<cfif Len(ListingTitle) and not ListFind("3,4,5,6,7,8",ListingTypeID)>							
							<url>
								<loc>http://www.ZoomTanzania.com/<cfif ListFind("1,2,14",ListingTypeID) and Len(URLSafeTitle)>#URLSafeTitle#<cfelse>ListingDetail?ListingID=#ListingID#</cfif></loc>
								<lastmod>#DateFormat(Now(),"yyyy-mm-dd")#</lastmod>
		    					<changefreq>hourly</changefreq>
		    					<priority>0.5</priority>
							</url>
						</cfif>
					</cfoutput>
				</cfif>
			</cfoutput>
		</cfoutput>	
	</cfoutput>
	</urlset>
</cfsavecontent>
<cffile action = "write" file = "c:/sites/dar/web/Sitemap.xml"   output = "#SitemapXML#">
Sitemap.xml regenerated.

