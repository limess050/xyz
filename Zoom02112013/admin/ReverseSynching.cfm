<cfset allFields="StatusMessage">
<cfinclude template="../includes/setVariables.cfm">

<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Synch From Laptop">
<cfinclude template="../Lighthouse/Admin/Header.cfm">

<cfif ListFind("Devel,Live",Request.environment)>
	<p class="STATUSMESSAGE">This template is not designed to run on the server. It runs on the laptops to synch sections, cateogries and pricing from the server.</p>
	<cfinclude template="../Lighthouse/Admin/Footer.cfm">
	<cfabort>
</cfif>

<cfinclude template="../includes/getLaptopKey.cfm">
<cfinclude template="../includes/SynchURL.cfm">
<cfhttp url="http://#SynchURL#/intTasks/ReverseSynchXML.cfm" method="GET" timeout="600">
<cfset synchData = XmlParse(CFHTTP.FileContent)>

<cfset Sections = synchData.theContainer.sections.XmlChildren>
<cfset SectionCount=ArrayLen(Sections)>

<cfset Categories = synchData.theContainer.categories.XmlChildren>
<cfset CategoryCount=ArrayLen(Categories)>

<cfset CategoryListingTypes = synchData.theContainer.categoryListingTypes.XmlChildren>
<cfset CategoryListingTypesCount=ArrayLen(CategoryListingTypes)>

<cfset ListingTypes = synchData.theContainer.listingTypes.XmlChildren>
<cfset ListingTypesCount=ArrayLen(ListingTypes)>

<cfset ListingTypesPricings = synchData.theContainer.listingTypesPricings.XmlChildren>
<cfset ListingTypesPricingsCount=ArrayLen(ListingTypesPricings)>

<!--- create query objects with the data --->
<cfset getSections = QueryNew("SectionID, ParentSectionID, Title, Descr, Active, OrderNum") >
<cfset temp = QueryAddRow(getSections, #SectionCount#)>
<cfloop index="i" from = "1" to = "#SectionCount#">
   <cfset temp = QuerySetCell(getSections, "SectionID", #synchData.theContainer.sections.section[i].sectionID.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getSections, "ParentSectionID", #synchData.theContainer.sections.section[i].parentSectionID.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getSections, "Title", #synchData.theContainer.sections.section[i].title.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getSections, "Descr", #synchData.theContainer.sections.section[i].descr.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getSections, "Active", #synchData.theContainer.sections.section[i].active.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getSections, "OrderNum", #synchData.theContainer.sections.section[i].orderNum.XmlText#, #i#)>
</cfloop>

<cfset getCategories = QueryNew("CategoryID, ParentSectionID, SectionID, Title, Descr, Active, OrderNum, ClickThroughs") >
<cfset temp = QueryAddRow(getCategories, #CategoryCount#)>
<cfloop index="i" from = "1" to = "#CategoryCount#">
   <cfset temp = QuerySetCell(getCategories, "CategoryID", #synchData.theContainer.categories.category[i].categoryID.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getCategories, "ParentSectionID", #synchData.theContainer.categories.category[i].parentSectionID.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getCategories, "SectionID", #synchData.theContainer.categories.category[i].sectionID.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getCategories, "Title", #synchData.theContainer.categories.category[i].title.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getCategories, "Descr", #synchData.theContainer.categories.category[i].descr.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getCategories, "Active", #synchData.theContainer.categories.category[i].active.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getCategories, "OrderNum", #synchData.theContainer.categories.category[i].orderNum.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getCategories, "ClickThroughs", #synchData.theContainer.categories.category[i].clickThroughs.XmlText#, #i#)>
</cfloop>

<cfset getCategoryListingTypes = QueryNew("CategoryID, ListingTypeID") >
<cfset temp = QueryAddRow(getCategoryListingTypes, #CategoryListingTypesCount#)>
<cfloop index="i" from = "1" to = "#CategoryListingTypesCount#">
   <cfset temp = QuerySetCell(getCategoryListingTypes, "CategoryID", #synchData.theContainer.categoryListingTypes.categoryListingType[i].categoryID.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getCategoryListingTypes, "ListingTypeID", #synchData.theContainer.categoryListingTypes.categoryListingType[i].listingTypeID.XmlText#, #i#)>
</cfloop>

<cfset getListingTypes = QueryNew("ListingTypeID, Title, Descr, Active, OrderNum, BasicFee, ExpandedFee, TermExpiration, AdditionalBasicFee, AdditionalExpandedFee, DiscountedFee, FivePerYearFee, TenPerYearFee, TwentyPerYearFee, UnlimitedPerYearFee") >
<cfset temp = QueryAddRow(getListingTypes, #ListingTypesCount#)>
<cfloop index="i" from = "1" to = "#ListingTypesCount#">
   <cfset temp = QuerySetCell(getListingTypes, "ListingTypeID", #synchData.theContainer.listingTypes.listingType[i].ListingTypeID.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypes, "Title", #synchData.theContainer.listingTypes.listingType[i].Title.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypes, "Descr", #synchData.theContainer.listingTypes.listingType[i].Descr.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypes, "Active", #synchData.theContainer.listingTypes.listingType[i].Active.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypes, "OrderNum", #synchData.theContainer.listingTypes.listingType[i].OrderNum.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypes, "BasicFee", #synchData.theContainer.listingTypes.listingType[i].BasicFee.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypes, "ExpandedFee", #synchData.theContainer.listingTypes.listingType[i].ExpandedFee.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypes, "TermExpiration", #synchData.theContainer.listingTypes.listingType[i].TermExpiration.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypes, "AdditionalBasicFee", #synchData.theContainer.listingTypes.listingType[i].AdditionalBasicFee.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypes, "AdditionalExpandedFee", #synchData.theContainer.listingTypes.listingType[i].AdditionalExpandedFee.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypes, "DiscountedFee", #synchData.theContainer.listingTypes.listingType[i].DiscountedFee.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypes, "FivePerYearFee", #synchData.theContainer.listingTypes.listingType[i].FivePerYearFee.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypes, "TenPerYearFee", #synchData.theContainer.listingTypes.listingType[i].TenPerYearFee.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypes, "TwentyPerYearFee", #synchData.theContainer.listingTypes.listingType[i].TwentyPerYearFee.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypes, "UnlimitedPerYearFee", #synchData.theContainer.listingTypes.listingType[i].UnlimitedPerYearFee.XmlText#, #i#)>
</cfloop>

<cfset getListingTypesPricing = QueryNew("ListingTypePricingID, ListingTypeID, USPriceStart, USPriceEnd, TZSPriceStart, TZSPriceEnd, ListingFee, DiscountedFee") >
<cfset temp = QueryAddRow(getListingTypesPricing, #ListingTypesPricingsCount#)>
<cfloop index="i" from = "1" to = "#ListingTypesPricingsCount#">
   <cfset temp = QuerySetCell(getListingTypesPricing, "ListingTypePricingID", #synchData.theContainer.listingTypesPricings.listingTypesPricing[i].ListingTypePricingID.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypesPricing, "ListingTypeID", #synchData.theContainer.listingTypesPricings.listingTypesPricing[i].ListingTypeID.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypesPricing, "USPriceStart", #synchData.theContainer.listingTypesPricings.listingTypesPricing[i].USPriceStart.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypesPricing, "USPriceEnd", #synchData.theContainer.listingTypesPricings.listingTypesPricing[i].USPriceEnd.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypesPricing, "TZSPriceStart", #synchData.theContainer.listingTypesPricings.listingTypesPricing[i].TZSPriceStart.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypesPricing, "TZSPriceEnd", #synchData.theContainer.listingTypesPricings.listingTypesPricing[i].TZSPriceEnd.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypesPricing, "ListingFee", #synchData.theContainer.listingTypesPricings.listingTypesPricing[i].ListingFee.XmlText#, #i#)>
   <cfset temp = QuerySetCell(getListingTypesPricing, "DiscountedFee", #synchData.theContainer.listingTypesPricings.listingTypesPricing[i].DiscountedFee.XmlText#, #i#)>
</cfloop>

<cfoutput query="getSections">
	<cfquery name="checkSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select SectionID
		From Sections
		Where SectionID=<cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif checkSection.RecordCount>
		<cfquery name="updateSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update Sections
			Set ParentSectionID= <cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(ParentSectionID)#">, 
			Title=<cfqueryparam value="#Title#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(Title)#">, 
			Descr=<cfqueryparam value="#Descr#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(Descr)#">, 
			Active=<cfqueryparam value="#Active#" cfsqltype="CF_SQL_INTEGER">, 
			OrderNum=<cfqueryparam value="#OrderNum#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(OrderNum)#">
			Where SectionID=<cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	<cfelse>
		<cfquery name="insertSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SET IDENTITY_INSERT Sections ON

			Insert into Sections
			(SectionID, ParentSectionID, Title, Descr, Active, OrderNum)
			VALUES
			(<cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">, 
			<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(ParentSectionID)#">, 
			<cfqueryparam value="#Title#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(Title)#">, 
			<cfqueryparam value="#Descr#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(Descr)#">, 
			<cfqueryparam value="#Active#" cfsqltype="CF_SQL_INTEGER">,
			<cfqueryparam value="#OrderNum#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(OrderNum)#">)
			
			SET IDENTITY_INSERT Sections OFF
		</cfquery>
	</cfif>
</cfoutput>

<cfoutput>
	#SectionCount# Sections synched.<br>
</cfoutput>

<cfoutput query="getCategories">
	<cfquery name="checkCategory" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select CategoryID
		From Categories
		Where CategoryID=<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif checkCategory.RecordCount>
		<cfquery name="updateCategory" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update Categories
			Set SectionID= <cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(SectionID)#">,
			ParentSectionID= <cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(ParentSectionID)#">, 
			Title=<cfqueryparam value="#Title#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(Title)#">, 
			Descr=<cfqueryparam value="#Descr#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(Descr)#">, 
			Active=<cfqueryparam value="#Active#" cfsqltype="CF_SQL_INTEGER">, 
			OrderNum=<cfqueryparam value="#OrderNum#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(OrderNum)#">, 
			ClickThroughs=<cfqueryparam value="#ClickThroughs#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(ClickThroughs)#">
			Where CategoryID=<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	<cfelse>
		<cfquery name="insertCategory" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SET IDENTITY_INSERT Categories ON

			Insert into Categories
			(CategoryID, ParentSectionID, SectionID, Title, Descr, Active, OrderNum, ClickThroughs)
			VALUES
			(<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">, 
			<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(ParentSectionID)#">, 
			<cfqueryparam value="#SectionID#" cfsqltype="CF_SQL_INTEGER">, 
			<cfqueryparam value="#Title#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(Title)#">, 
			<cfqueryparam value="#Descr#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(Descr)#">, 
			<cfqueryparam value="#Active#" cfsqltype="CF_SQL_INTEGER">,
			<cfqueryparam value="#OrderNum#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(OrderNum)#">,
			<cfqueryparam value="#ClickThroughs#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(ClickThroughs)#">)
			
			SET IDENTITY_INSERT Categories OFF
		</cfquery>
	</cfif>
</cfoutput>

<cfoutput>
	#CategoryCount# Categories synched.<br>
</cfoutput>

<cfquery name="deleteCategoryListingTypes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Delete From CategoryListingTypes
</cfquery>
<cfoutput query="getCategoryListingTypes">
	<cfquery name="insertCategoryListingType" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Insert into CategoryListingTypes
		(CategoryID, ListingTypeID)
		VALUES
		(<cfqueryparam value="#CategoryID#" cfsqltype="CF_SQL_INTEGER">, 
		<cfqueryparam value="#ListingTypeID#" cfsqltype="CF_SQL_INTEGER">)
	</cfquery>
</cfoutput>

<cfoutput query="getListingTypes">
	<cfquery name="updateCategory" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update ListingTypes
		Set Title=<cfqueryparam value="#Title#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(Title)#">, 
		Descr=<cfqueryparam value="#Descr#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(Descr)#">, 
		Active=<cfqueryparam value="#Active#" cfsqltype="CF_SQL_INTEGER">, 
		OrderNum=<cfqueryparam value="#OrderNum#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(OrderNum)#">, 
		BasicFee=<cfqueryparam value="#BasicFee#" cfsqltype="CF_SQL_MONEY" null="#NOT LEN(BasicFee)#">, 
		ExpandedFee=<cfqueryparam value="#ExpandedFee#" cfsqltype="CF_SQL_MONEY" null="#NOT LEN(ExpandedFee)#">, 
		TermExpiration=<cfqueryparam value="#TermExpiration#" cfsqltype="CF_SQL_INTEGER" null="#NOT LEN(TermExpiration)#">, 
		AdditionalBasicFee=<cfqueryparam value="#AdditionalBasicFee#" cfsqltype="CF_SQL_MONEY" null="#NOT LEN(AdditionalBasicFee)#">, 
		AdditionalExpandedFee=<cfqueryparam value="#AdditionalExpandedFee#" cfsqltype="CF_SQL_MONEY" null="#NOT LEN(AdditionalExpandedFee)#">, 
		DiscountedFee=<cfqueryparam value="#DiscountedFee#" cfsqltype="CF_SQL_MONEY" null="#NOT LEN(DiscountedFee)#">, 
		FivePerYearFee=<cfqueryparam value="#FivePerYearFee#" cfsqltype="CF_SQL_MONEY" null="#NOT LEN(FivePerYearFee)#">, 
		TenPerYearFee=<cfqueryparam value="#TenPerYearFee#" cfsqltype="CF_SQL_MONEY" null="#NOT LEN(TenPerYearFee)#">, 
		TwentyPerYearFee=<cfqueryparam value="#TwentyPerYearFee#" cfsqltype="CF_SQL_MONEY" null="#NOT LEN(TwentyPerYearFee)#">, 
		UnlimitedPerYearFee=<cfqueryparam value="#UnlimitedPerYearFee#" cfsqltype="CF_SQL_MONEY" null="#NOT LEN(UnlimitedPerYearFee)#">
		Where ListingTypeID=<cfqueryparam value="#ListingTypeID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
</cfoutput>

<cfquery name="deleteListingTypesPricings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Delete From ListingTypesPricing
</cfquery>
<cfoutput query="getListingTypesPricing">
	<cfquery name="insertCategoryListingType" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SET IDENTITY_INSERT ListingTypesPricing ON
		
		Insert into ListingTypesPricing
		(ListingTypePricingID, ListingTypeID, USPriceStart, USPriceEnd, TZSPriceStart, TZSPriceEnd, ListingFee, DiscountedFee)
		VALUES
		(<cfqueryparam value="#ListingTypePricingID#" cfsqltype="CF_SQL_INTEGER">, 
		<cfqueryparam value="#ListingTypeID#" cfsqltype="CF_SQL_INTEGER">, 
		<cfqueryparam value="#USPriceStart#" cfsqltype="CF_SQL_MONEY">, 
		<cfqueryparam value="#USPriceEnd#" cfsqltype="CF_SQL_MONEY">, 
		<cfqueryparam value="#TZSPriceStart#" cfsqltype="CF_SQL_MONEY">, 
		<cfqueryparam value="#TZSPriceEnd#" cfsqltype="CF_SQL_MONEY">, 
		<cfqueryparam value="#ListingFee#" cfsqltype="CF_SQL_MONEY">, 
		<cfqueryparam value="#DiscountedFee#" cfsqltype="CF_SQL_MONEY">)
			
		SET IDENTITY_INSERT ListingTypesPricing OFF
	</cfquery>
</cfoutput>

<cfoutput>
	Listing Types synched.<br>
</cfoutput>

<!--- Delete any records that no longer exist on server --->
<cfquery name="deleteSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Delete From Sections
	Where SectionID not in (<cfqueryparam value="#ValueList(getSections.SectionID)#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
</cfquery>

<cfquery name="deleteCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Delete From Categories
	Where CategoryID not in (<cfqueryparam value="#ValueList(getCategories.CategoryID)#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
</cfquery>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">
