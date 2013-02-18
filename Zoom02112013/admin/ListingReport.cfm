
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Listing Report">
<cfinclude template="../Lighthouse/Admin/Header.cfm">
<cfif IsDefined('url.reportType') and url.reportType is "excel">
	<cfcontent type="application/x-msexcel" reset="Yes">
	<cfheader name="Content-Disposition" value="filename=ListingReport#DateFormat(now(),'ddmmyyyy')#.xls">
</cfif>
<cfoutput><script language="JavaScript" src="#Request.HTTPSURL#/scripts/jquery-1.3.2.min.js" type="text/javascript"></script></cfoutput>

<cfquery name="getCategoryTree" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum,
	S.SectionID, S.Title as STitle, S.OrderNum as SOrderNum,
	C.CategoryID, C.Title as CTitle, C.OrderNum as COrderNum,
	(Select Count(L.ListingID)
		From ListingsView L 
		Inner Join ListingCategories LC on L.ListingID=LC.ListingID
		Inner Join Categories C on LC.CategoryID=C.CategoryID
		Where L.DeletedAfterSubmitted=0 and L.InProgress=0
		and C.ParentSectionID=PS.ParentSectionID) as SectionListingCount,
	(Select Count(L.ListingID) as ListingCount
		From ListingsView L
		Inner Join ListingCategories LC on L.ListingID=LC.ListingID
		Inner Join Categories C on LC.CategoryID=C.CategoryID
		Where L.DeletedAfterSubmitted=0 and L.InProgress=0
		and (L.Deadline is null or L.Deadline >= #application.CurrentDateInTZ#)
		and C.ParentSectionID=PS.ParentSectionID) as SectionLiveListingCount,
	(Select Count(L.ListingID) as ListingCount
		From ListingsView L 
		Inner Join ListingCategories LC on L.ListingID=LC.ListingID
		Inner Join Categories C on LC.CategoryID=C.CategoryID
		Where L.DeletedAfterSubmitted=0 and L.InProgress=0
		and C.ParentSectionID=PS.ParentSectionID
		and C.SectionID=S.SectionID) as SubSectionListingCount,
	(Select Count(L.ListingID) as ListingCount
		From ListingsView L
		Inner Join ListingCategories LC on L.ListingID=LC.ListingID
		Inner Join Categories C on LC.CategoryID=C.CategoryID
		Where L.DeletedAfterSubmitted=0 and L.InProgress=0
		and (L.Deadline is null or L.Deadline >= #application.CurrentDateInTZ#)
		and C.ParentSectionID=PS.ParentSectionID
		and C.SectionID=S.SectionID) as SubSectionLiveListingCount,
	(Select Count(L.ListingID) as ListingCount
		From ListingsView L 
		Inner Join ListingCategories LC on L.ListingID=LC.ListingID
		Where L.DeletedAfterSubmitted=0 and L.InProgress=0
		and LC.CategoryID=C.CategoryID) as CategoryListingCount,
	(Select Count(L.ListingID) as ListingCount
		From ListingsView L
		Inner Join ListingCategories LC on L.ListingID=LC.ListingID
		Where L.DeletedAfterSubmitted=0 and L.InProgress=0
		and (L.Deadline is null or L.Deadline >= #application.CurrentDateInTZ#)
		and LC.CategoryID=C.CategoryID) as CategoryLiveListingCount
	FROM Categories C
	Inner Join Sections S on C.SectionID=S.SectionID
	Inner Join ParentSectionsView PS on S.ParentSectionID=PS.ParentSectionID
	UNION
	SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum,
	PS.ParentSectionID*1000000 as SectionID, null as STitle, 0 as SOrderNum,
	C.CategoryID, C.Title as CTitle, C.OrderNum as COrderNum,
	(Select Count(L.ListingID)
		From ListingsView L 
		Inner Join ListingCategories LC on L.ListingID=LC.ListingID
		Inner Join Categories C on LC.CategoryID=C.CategoryID
		Where L.DeletedAfterSubmitted=0 and L.InProgress=0
		and C.ParentSectionID=PS.ParentSectionID) as SectionListingCount,
	(Select Count(L.ListingID) as ListingCount
		From ListingsView L
		Inner Join ListingCategories LC on L.ListingID=LC.ListingID
		Inner Join Categories C on LC.CategoryID=C.CategoryID
		Where L.DeletedAfterSubmitted=0 and L.InProgress=0
		and (L.Deadline is null or L.Deadline >= #application.CurrentDateInTZ#)
		and C.ParentSectionID=PS.ParentSectionID) as SectionLiveListingCount,
	null as SubSectionListingCount, null as SubSectionLiveListingCount,
	(Select Count(L.ListingID) as ListingCount
		From ListingsView L 
		Inner Join ListingCategories LC on L.ListingID=LC.ListingID
		Where L.DeletedAfterSubmitted=0 and L.InProgress=0
		and LC.CategoryID=C.CategoryID) as CategoryListingCount,
	(Select Count(L.ListingID) as ListingCount
		From ListingsView L
		Inner Join ListingCategories LC on L.ListingID=LC.ListingID
		Where L.DeletedAfterSubmitted=0 and L.InProgress=0
		and (L.Deadline is null or L.Deadline >= #application.CurrentDateInTZ#)
		and LC.CategoryID=C.CategoryID) as CategoryLiveListingCount
	FROM Categories C
	Inner Join ParentSectionsView PS on C.ParentSectionID=PS.ParentSectionID and C.SectionID is null
	Order By PSOrderNum, SOrderNum, COrderNum
</cfquery>

<cfset TotalListingCount=0>
<cfset TotalLiveListingCount=0>
<cfoutput query="getCategoryTree" group="PSOrderNum">
	<cfset TotalListingCount=TotalListingCount + SectionListingCount>
	<cfset TotalLiveListingCount=TotalLiveListingCount + SectionLiveListingCount>
</cfoutput>
<div id=bodyOfPageDiv>
	<cfif not IsDefined('url.reportType')>
		<h1 style="margin:0px"> Listing Report:<cfoutput> #Dateformat(Now(),'dd/mm/yyyy')#</cfoutput> </h1>
		<P>
		<A HREF="ListingReport.cfm?reportType=excel" class=normaltext>Export as Excel</A>
		<p>
	</cfif>
	<TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0 CLASS=VIEWTABLE>
	<thead>
		<tr id="viewgroupheaderrow">
			<td CLASS=VIEWHEADERCELL>Section</td>
			<td CLASS=VIEWHEADERCELL>SubSection</td>
			<td CLASS=VIEWHEADERCELL>Category</td>
			<td CLASS=VIEWHEADERCELL>Total Listings</td>
			<td CLASS=VIEWHEADERCELL>Live Listings</td>
		</tr>
	</thead>
	<tbody>
	<cfoutput>
		<tr class="VIEWROW">
			<td>
				<strong>Entire Site</strong>
			</td>
			<td>
				&nbsp;
			</td>
			<td>
				&nbsp;
			</td>	
			<td align="center"><strong>#TotalListingCount#</strong></td>
			<td align="center"><strong>#TotalLiveListingCount#</strong></td>
		</tr>
	</cfoutput>	
	<cfoutput query="getCategoryTree" group="PSOrderNum">
		<tr class="VIEWROW">
			<td>
				#PSTitle#
			</td>
			<td>
				&nbsp;
			</td>
			<td>
				&nbsp;
			</td>
			<td align="center">#SectionListingCount#</td>
			<td align="center">#SectionLiveListingCount#</td>
		</tr>
			<cfoutput group="SOrderNum">
				<cfif SectionID lt 1000000>
					<tr class="VIEWROW">
						<td>
							&nbsp;
						</td>
						<td>
							#STitle#
						</td>
						<td>
							&nbsp;
						</td>
						<td align="center">#SubSectionListingCount#</td>
						<td align="center">#SubSectionLiveListingCount#</td>
					</tr>
				</cfif>			
					<cfoutput>
						<tr class="VIEWROW">
							<td>
								&nbsp;
							</td>
							<td>
								&nbsp;
							</td>
							<td>
								#CTitle#
							</td>	
							<td align="center">#CategoryListingCount#</td>
							<td align="center">#CategoryLiveListingCount#</td>
						</tr>					
					</cfoutput>
			</cfoutput>
	</cfoutput>	
	</tbody>
	</table>

</div>
<cfinclude template="../Lighthouse/Admin/Footer.cfm">