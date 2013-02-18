<!---
Generates XML output Of Section/Subsection/Categories for use in kiosk.
--->
<cfif not IsDefined('KioskID') or not ListFind("kjhdsf$@887",KioskID)>
	<cfabort>	
</cfif>

<cfinclude template="../includes/CleanHighAscii.cfm">

<cfquery name="getListingTree" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum,
		S.SectionID, S.Title as STitle, S.OrderNum as SOrderNum,
		C.CategoryID, C.Title as CTitle, C.OrderNum as COrderNum
		FROM Categories C
		Inner Join Sections S on C.SectionID=S.SectionID
		Inner Join ParentSectionsView PS on S.ParentSectionID=PS.ParentSectionID
	Where exists (Select CategoryID from ListingCategories LC Inner Join ListingsView L on LC.ListingID=L.ListingID Where LC.CategoryID=C.CategoryID and L.Active=1 and L.Reviewed=1 and L.ExpirationDate >= #application.CurrentDateInTZ# and (L.Deadline is null or L.Deadline >= DATEADD(Day, 0, DATEDIFF(Day, 0, GetDate()))) and L.DeletedAfterSubmitted=0)
	and C.CategoryID not in (370)
	and PS.ParentSectionID not in (8)
	UNION
		SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum,
		0 as SectionID, null as STitle, 0 as SOrderNum,
		C.CategoryID, C.Title as CTitle, C.OrderNum as COrderNum
		FROM Categories C
		Inner Join ParentSectionsView PS on C.ParentSectionID=PS.ParentSectionID and C.SectionID is null
	Where exists (Select CategoryID from ListingCategories LC Inner Join ListingsView L on LC.ListingID=L.ListingID Where LC.CategoryID=C.CategoryID and L.Active=1 and L.Reviewed=1 and L.ExpirationDate >= #application.CurrentDateInTZ# and (L.Deadline is null or L.Deadline >= DATEADD(Day, 0, DATEDIFF(Day, 0, GetDate()))) and L.DeletedAfterSubmitted=0)
	and C.CategoryID not in (370)
	and PS.ParentSectionID not in (8)
	UNION
	SELECT PS.ParentSectionID, 'Professional Job Opportunities' as PSTitle, PS.OrderNum as PSOrderNum,
		S.SectionID, null as STitle, S.OrderNum as SOrderNum,
		C.CategoryID, C.Title as CTitle, C.OrderNum as COrderNum
		FROM Categories C
		Inner Join Sections S on C.SectionID=S.SectionID
		Inner Join ParentSectionsView PS on S.ParentSectionID=PS.ParentSectionID
	Where exists (Select CategoryID from ListingCategories LC Inner Join ListingsView L on LC.ListingID=L.ListingID Where L.ListingTypeID in (10) and LC.CategoryID=C.CategoryID and L.Active=1 and L.Reviewed=1 and L.ExpirationDate >= #application.CurrentDateInTZ# and (L.Deadline is null or L.Deadline >= DATEADD(Day, 0, DATEDIFF(Day, 0, GetDate()))) and L.DeletedAfterSubmitted=0)
	and C.CategoryID not in (370)
	and PS.ParentSectionID in (8)
	and S.SectionID=19
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
