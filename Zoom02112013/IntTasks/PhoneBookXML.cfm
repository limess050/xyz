<!---
Generates XML output Of Section/Subsection/Categories for use in Phone Book.
--->
<cfif not IsDefined('PhoneBookID') or not ListFind("kj5dsf$@8u7",PhoneBookID)>
	<cfabort>	
</cfif>

<cfinclude template="../includes/CleanHighAscii.cfm">

<cfset XMLFeedFilterOuter = "and CategoryID not in (370)">
<cfset XMLFeedFilterInner = "and L.listingTypeID in (3,4,5,6,7,8,10,15)">

<cfquery name="getListingTree" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	<!--- Listings in Sections with SubSections (Business, Travel, Real Estate, ...)  --->
	SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum,
		S.SectionID, S.Title as STitle, S.OrderNum as SOrderNum,
		C.CategoryID, C.Title as CTitle, C.OrderNum as COrderNum
		FROM Categories C
		Inner Join Sections S on C.SectionID=S.SectionID
		Inner Join ParentSectionsView PS on S.ParentSectionID=PS.ParentSectionID
	Where 
		exists (Select CategoryID from ListingCategories LC Inner Join ListingsView L on LC.ListingID=L.ListingID Where LC.CategoryID=C.CategoryID <cfinclude template="../includes/LiveListingFilter.cfm"> #XMLFeedFilterInner#)<!--- check to make sure there are live listings in this section/category combo --->
		and PS.ParentSectionID not in (8)<!--- Any Section but Jobs --->
		#XMLFeedFilterOuter#
	UNION
		<!--- Listings in Sections with no SubSections (Events, FSBO, Entertainment, ...)  --->
		SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum,
		0 as SectionID, null as STitle, 0 as SOrderNum,
		C.CategoryID, C.Title as CTitle, C.OrderNum as COrderNum
		FROM Categories C
		Inner Join ParentSectionsView PS on C.ParentSectionID=PS.ParentSectionID and C.SectionID is null
	Where 
		exists (Select CategoryID from ListingCategories LC Inner Join ListingsView L on LC.ListingID=L.ListingID Where LC.CategoryID=C.CategoryID <cfinclude template="../includes/LiveListingFilter.cfm"> #XMLFeedFilterInner#)<!--- check to make sure there are live listings in this section/category combo --->
		and PS.ParentSectionID not in (8)<!--- Any Section but Jobs --->
		#XMLFeedFilterOuter#
	UNION
	<!--- Professional Employment Opps --->
	SELECT PS.ParentSectionID, 'Professional Job Opportunities' as PSTitle, PS.OrderNum as PSOrderNum,
		S.SectionID, null as STitle, S.OrderNum as SOrderNum,
		C.CategoryID, C.Title as CTitle, C.OrderNum as COrderNum
		FROM Categories C
		Inner Join Sections S on C.SectionID=S.SectionID
		Inner Join ParentSectionsView PS on S.ParentSectionID=PS.ParentSectionID
	Where 
		exists (Select CategoryID from ListingCategories LC Inner Join ListingsView L on LC.ListingID=L.ListingID Where L.ListingTypeID in (10) and LC.CategoryID=C.CategoryID <cfinclude template="../includes/LiveListingFilter.cfm"> #XMLFeedFilterInner#)<!--- check to make sure there are live listings in this section/category combo --->
		and PS.ParentSectionID in (8)<!--- Jobs --->
		and S.SectionID=19<!--- Professional --->
		#XMLFeedFilterOuter#	
	Order By PSOrderNum, SOrderNum, COrderNum
</cfquery>
<cfsavecontent variable="TreeXML"><?xml version="1.0" encoding="UTF-8"?>
<everythingdar><cfoutput query="getListingTree" group="PSTitle">	
	<section>
		<label>#XMLFormat(PSTitle)#</label><cfoutput group="STitle">
		<subsection>
			<label>#XMLFormat(STitle)#</label><cfoutput group="CTitle">
			<category>
				<label>#XMLFormat(CTitle)#</label>
				<ID>#XMLFormat(CategoryID)#</ID>
			</category></cfoutput>
		</subsection></cfoutput>	
	</section></cfoutput>
</everythingdar>
</cfsavecontent>

<!--- <cfdump var="#TreeXML#"> --->
<CFCONTENT
TYPE="text/plain"
RESET="Yes"><CFOUTPUT>#ToString(CleanHighAscii(TreeXML))#</CFOUTPUT>
