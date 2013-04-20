<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class listingsModel extends CI_Model {

	function __construct()
	{
		parent::__construct();
	}

	
	function getListingCategoryCount($SectionID)
	{
		$categoriesInSectionArray = array();
		$listingsInCategoryArray = array();
		$livelistingsArray = array();
		$categorylistingsCountArray = array();



		$this->db->where('ParentSectionID', $SectionID);
		$categoriesInSectionResultObj = $this->db->get('categories');

		if($categoriesInSectionResultObj->num_rows() == 0)
		{
			$this->db->where('SectionID', $SectionID);
			$categoriesInSectionResultObj = $this->db->get('categories');
		}

		foreach($categoriesInSectionResultObj->result() as $categoryInSection)
			$categoriesArray[]=$categoryInSection->CategoryID;

		$this->db->where_in('CategoryID',$categoriesArray);
		$listingsInCategoryObj=$this->db->get('listingcategories');

		foreach ($listingsInCategoryObj->result() as $ListingInCategory) {
			$listingsInCategoryArray[] = $ListingInCategory->ListingID;
		}

		$this->db->where('Reviewed', 1);
		$this->db->where('Active', 1);
		$this->db->where('DeletedAfterSubmitted', 0);
		$this->db->where_in('ListingID',$listingsInCategoryArray);
		$livelistings=$this->db->get('listings');

		foreach($livelistings->result() as $liveListing)
		{
			$livelistingsArray[]=$liveListing->ListingID;
		}


		$this->db->where_in('ListingID',$livelistingsArray);
		$this->db->group_by('CategoryID');
		$this->db->select('CategoryID, count(ListingID) as catCount',FALSE);
		$categorylistingsCount=$this->db->get('listingcategories');

		foreach($categorylistingsCount->result() as $categoryListingCount)
		{
			$categorylistingsCountArray[$categoryListingCount->CategoryID] = $categoryListingCount->catCount;
		}

		return $categorylistingsCountArray;

	}

	function getTables($tableName)
	{
		return $this->db->get($tableName);
	}


	function Filters()
	{
		$locations = "Select LocationID as SelectValue, Title as SelectText 
		From locations With 		Where Active=1
		Order By OrderNum";


		$seekingEmploymentcategories="Select C.SectionID, S.Title as SubSection, S.OrderNum as SectionOrderNum, S.ImageFile as SectionImage,
			C.CategoryID, C.Title as Category, C.OrderNum as CategoryOrderNum, C.SectionID, C.ParentSectionID, C.URLSafeTitleDashed as CategoryURLSafeTitle,
			C.ImageFile as CategoryImage,
			(Select Count(L.ListingID) 
			From listings L Inner Join listingcategories LC With on L.ListingID=LC.ListingID
			Where LC.CategoryID=C.CategoryID 
			and L.Active=1

			and L.Reviewed=1 

			and L.DeletedAfterSubmitted=0 

			and (L.Deadline is null or L.Deadline >= " . CURRENT_DATE_IN_TZ . ")

			AND (L.ListingTypeID <> 15
				OR EXISTS (SELECT ListingID FROM listingeventdays with WHERE ListingID=L.ListingID 
						AND ListingEventDate >= " . CURRENT_DATE_IN_TZ . "))		
						
			and (L.ListingTypeID IN (1,2,14,15) or (L.ExpirationDate >= " . CURRENT_DATE_IN_TZ . " and L.PaymentStatusID in (2,3)))
			and L.Blacklist_fl = 0
			and (L.ListingTypeID is null or L.ListingTypeID in (10,12))) as ListingCount
			From sections S With 			Left Outer Join categories C With on S.SectionID=C.SectionID or (C.ParentSectionID=S.SectionID and C.SectionID is null) 		
			Where S.Active=1
			and C.Active=1
			and C.ParentSectionID=8
			and S.SectionID <> 29
			Order By SectionOrderNum, CategoryOrderNum";
	}

	function getSection($ParentSectionID)
	{

		//and L.PaymentStatusID in (2,3) and L.Blacklist_fl = 0
				$section="Select C.SectionID, S.Title as SubSection, CASE WHEN C.SectionID IS null THEN null ELSE S.OrderNum END as SectionOrderNum, S.ImageFile as SectionImage, S.URLSafeTitleDashed as SectionURL, 
		C.CategoryID, C.Title as Category, C.OrderNum as CategoryOrderNum, C.ParentSectionID, C.URLSafeTitleDashed as CategoryURLSafeTitle,
		C.ImageFile as CategoryImage,
		(Select Count(L.ListingID) 
		From listings L Inner Join listingcategories LC on L.ListingID=LC.ListingID
		Where LC.CategoryID=C.CategoryID
		and L.Active=1

		and L.Reviewed=1 

		and L.DeletedAfterSubmitted=0 

		and (L.Deadline is null or L.Deadline >= '" . CURRENT_DATE_IN_TZ . "' )

		AND (L.ListingTypeID <> 15
			OR EXISTS (SELECT ListingID FROM listingeventdays WHERE ListingID=L.ListingID 
					AND ListingEventDate >= '" . CURRENT_DATE_IN_TZ . "'))		
					
		and (L.ListingTypeID IN (1,2,14,15) or (L.ExpirationDate >= '" . CURRENT_DATE_IN_TZ . "' ))
		) 
		as ListingCount
		From sections S Left Outer Join categories C on S.SectionID=C.SectionID or (C.ParentSectionID=S.SectionID and C.SectionID is null) 
		Where S.Active=1
		and C.ParentSectionID=" . $ParentSectionID . "
		and C.Active=1
		Order By SectionOrderNum, CategoryOrderNum";

		if($this->db->query($section)->num_rows() >0 )
			return $this->db->query($section);
		else
		{
			$section="Select C.SectionID, S.Title as SubSection, CASE WHEN C.SectionID IS null THEN null ELSE S.OrderNum END as SectionOrderNum, S.ImageFile as SectionImage,
			C.CategoryID, C.Title as Category, C.OrderNum as CategoryOrderNum, C.ParentSectionID, C.URLSafeTitleDashed as CategoryURLSafeTitle,
			C.ImageFile as CategoryImage,
			(Select Count(L.ListingID) 
			From listings L Inner Join listingcategories LC on L.ListingID=LC.ListingID
			Where LC.CategoryID=C.CategoryID
			and L.Active=1

			and L.Reviewed=1 

			and L.DeletedAfterSubmitted=0 

			and (L.Deadline is null or L.Deadline >= '" . CURRENT_DATE_IN_TZ . "' )

			AND (L.ListingTypeID <> 15
				OR EXISTS (SELECT ListingID FROM listingeventdays WHERE ListingID=L.ListingID 
						AND ListingEventDate >= '" . CURRENT_DATE_IN_TZ . "'))		
						
			and (L.ListingTypeID IN (1,2,14,15) or (L.ExpirationDate >= '" . CURRENT_DATE_IN_TZ . "' ))
			) 
			as ListingCount
			From sections S Left Outer Join categories C on S.SectionID=C.SectionID or (C.ParentSectionID=S.SectionID and C.SectionID is null) 
			Where S.Active=1
			and C.SectionID=" . $ParentSectionID . "
			and C.Active=1
			Order By SectionOrderNum, CategoryOrderNum";			
			return $this->db->query($section);
		}

	}


	function getCategory($CategoryID)
	{

		//echo $CategoryID;
		$categoryQuery = "Select C.Title, C.ParentSectionID, C.SectionID, C.Descr as CallOut, C.H1Text, C.MetaKeywords, C.URLSafeTitle, PS.Title as ParentSection, S.Title as SubSection From categories C Left Outer Join parentsectionsview PS on C.ParentSectionID=PS.ParentSectionID Left Outer Join sections S on C.SectionID=S.SectionID Where C.CategoryID = ";

		$categoryQuery = $categoryQuery . $CategoryID;
		//echo $CategoryID;
		//echo $CategoryID;


		// echo $categoryQuery; die();
		$category['categoryMeta'] = $this->db->query($categoryQuery)->row(); 



		$ListingTypeQuery = "Select ListingTypeID From categorylistingtypes Where CategoryID = ";


		$ListingTypeQuery = $ListingTypeQuery . $CategoryID . " And ListingTypeID in (3,4,5,6,7,8)";
		//echo $ListingTypeQuery;

		$ListingTypeObj = $this->db->query($ListingTypeQuery);

		if($ListingTypeObj->num_rows() > 0)
			$category['showThumbNail'] = 1;

		else
			$category['showThumbNail'] = 0;


		if(strpos("4,5,8,55",$category['categoryMeta']->SectionID))
			$category['SortBy'] = 'MostRecent';
		else if($category['categoryMeta']->ParentSectionID == 59)
			$category['SortBy'] = 'EventSort';
		else
			$category['SortBy'] = '';


		$category['ParentSectionID'] = $category['categoryMeta']->ParentSectionID;
		$category['SectionID'] = $category['categoryMeta']->SectionID;

		if(isset($category['categoryMeta']->SectionID))
			$category['hassections'] = 1;
		else
			$category['hassections'] = 0;

		$category['CategoryIDs'] = $CategoryID;

	//	print_r($category);

		return $category;

	}

	function getlistings($category,$featured=0)
	{

		//print_r($category);STRAIGHT_JOIN
		$listingsQuery = "Select  L.Deadline, L.ExpirationDate, L.ListingID, L.ListingTypeID, L.ListingTitle, L.ShortDescr, L.DateListed, L.PriceUS, L.PriceTZS,
		L.RentUS, L.RentTZS, L.Bedrooms, L.Bathrooms, L.AmenityOther, L.LocationOther, L.LocationText,
		L.LongDescr, L.MakeID, L.DateSort,
		L.Make as MakeOther, L.Model as ModelOther, L.VehicleYear, L.Kilometers, L.FourWheelDrive,
		L.Deadline, L.WebsiteURL, L.PublicPhone,  L.PublicPhone2,  L.PublicPhone3,  L.PublicPhone4, L.PublicEmail, L.URLSafeTitle as ListingURL, 
		L.EventStartDate, L.EventEndDate, L.RecurrenceID, L.RecurrenceMonthID,
		L.ExpandedListingHTML, L.ExpandedListingPDF,
		L.CuisineOther, L.AccountName,
		GROUP_CONCAT(LOC.Title SEPARATOR ', ') Location,
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= '" . CURRENT_DATE_IN_TZ . "' Then 1 Else 0 END as HasExpandedListing,
		L.SquareFeet, L.SquareMeters,
		L.LogoImage, L.ELPTypeThumbnailImage, L.ELPThumbnailFromDoc,
		PS.ParentSectionID, PS.Title as ParentSection, PS.URLSafeTitleDashed as ParentSectionURLSafeTitle,
		S.SectionID, S.Title as SubSection,
		C.CategoryID, C.Title as Category, 
		M.Title as Make, T.Title as Transmission,
		Te.Title as Term, RAND() as RandOrderID, ";

		if($category['showThumbNail'])
			$listingsQuery .= "(Select FileName
			From listingimages 
			Where ListingID=L.ListingID
			Order By OrderNum, ListingImageID Limit 1) as FileNameForTN, ";

		if (isset($category['QID']))
			$listingsQuery .=	" CQL.LineID as QLineID, ";
		// else
		// 	$listingsQuery .= " 1 as QLineID, ";
		
//
		$listingsQuery .= "CASE WHEN L.UserID = " . PHONE_ONLY_USER . " THEN 1 ELSE 0 END as PhoneOnlyListing_fl
		From parentsectionsview PS";

		if($category['SectionID']==4)
		$listingsQuery .= " Inner Join sections S  on PS.ParentSectionID=S.SectionID ";

		else
		$listingsQuery .= " Inner Join sections S  on PS.ParentSectionID=S.ParentSectionID ";
			
		$listingsQuery .="	
		Inner Join categories C  on S.SectionID=C.SectionID
		Inner Join listingcategories LC  on C.CategoryID=LC.CategoryID
		Inner Join listingsview L  on LC.ListingID=L.ListingID ";
		if (isset($category['QID']))
			$listingsQuery .= " Inner Join CategoryQueries CQ  on C.CategoryID=CQ.CategoryID and CQ.	CategoryQueryID= " . $category['QID'] . " Inner Join CategoryQueryLines CQL  on CQ.CategoryQueryID=CQL.CategoryQueryID and CQL.ListingID=L.ListingID";
	
		$listingsQuery .= "Left Outer Join makes M  on L.MakeID=M.MakeID
		Left Outer Join listinglocations LL on L.ListingID = LL.ListingID and LL.LocationID <> 4
		Inner Join locations LOC on LL.LocationID = LOC.LocationID
		Left Outer Join transmissions T  on L.TransmissionID=T.TransmissionID
		Left outer Join terms Te  on L.TermID=Te.TermID
		 Where S.Active=1";
		if (isset($category['ParentSectionID']) and $category['ParentSectionID'] == '8' and isset($category['JETID']))
		{

			$listingsQuery .= " and L.ListingTypeID in (10,12)";	
		}	
		
		else

		{
			 $listingsQuery .= " and (L.ListingTypeID IN (1,2,14,15) or (L.ExpirationDate >= '" . CURRENT_DATE_IN_TZ . "' ))";
		}

		if(isset($category['ParentSectionID']) and !in_array($category['ParentSectionID'], array(1,21,32))  )
			$listingsQuery .= " and S.ParentSectionID = " . $category['ParentSectionID'] ;

		elseif (isset($category['SectionID']) and !in_array($category['ParentSectionID'], array(1,21,32))) {
			
			$listingsQuery .= " and S.SectionID = " . $category['SectionID'] ;
		}
			
		
		elseif(isset($category['CategoryIDs']))
			$listingsQuery .= " and C.CategoryID in ('" . $category['CategoryIDs'] . "')";

		if ( isset($category['InJobSectionOverview']))
			$listingsQuery .= " and LC.CategoryID = (Select CategoryID From listingcategories  where ListingID=L.ListingID Limit 1)";

		$listingsQuery .= "
		and L.Active=1

		and L.Reviewed=1 

		and L.DeletedAfterSubmitted=0 

		and (L.Deadline is null or L.Deadline >= '" . CURRENT_DATE_IN_TZ . "')

		AND (L.ListingTypeID <> 15
			OR EXISTS (SELECT ListingID FROM listingeventdays  WHERE ListingID=L.ListingID 
					AND ListingEventDate >= '" . CURRENT_DATE_IN_TZ . "'))";


		if(isset($category['LocationID']))
			$listingsQuery .= " and LL.LocationID IN (" . str_replace('-', ',', $category['LocationID'])  .")";
		//Job listings can have multiple categories, so limit to one category so the listing does not appear mulitple times on the Section Overview page.


		//echo $category['ParentSectionID'];

			
		$listingsQuery .= ' Group By L.ListingID';
	

		switch ($category['SortBy']) {
			case 'Year':
				$listingsQuery .= " Order By C.OrderNum, L.VehicleYear desc, L.Title, L.DateSort desc";
				break;			

			case 'MakeModel':
				if($CategoryID == 84)
					$listingsQuery .= " Order By C.OrderNum, M.Title, L.Model, L.VehicleYear, L.Title, L.DateSort desc";
				else
					$listingsQuery .= " Order By C.OrderNum, L.Make, L.Model, L.VehicleYear, L.Title, L.DateSort desc";
				break;

			case 'MostRecent':
					$listingsQuery .= " Order By L.DateSort desc, C.OrderNum, M.Title, L.Model, L.VehicleYear, L.Title";
				break;
			
			default:
				if($featured==1)
					$listingsQuery .= " Order By HasExpandedListing desc, RandOrderID";
				else
					$listingsQuery .= " Order By ListingTitle";

				break;
		}

		if($category['limit'])
			$listingsQuery .= " Limit " . LISTINGS_PER_PAGE;


		// echo $category['ParentSectionID'];
		// echo $category['SectionID'];
		 //echo $listingsQuery; 
		$listings= $this->db->query($listingsQuery);

		//echo $this->db->last_query();


		return $listings;
	}

	function getsinglelisting($ListingID)
	{

		//print_r($category);STRAIGHT_JOIN
		$listingsQuery = "Select  L.Deadline, L.ExpirationDate, L.ListingID, L.ListingTypeID, L.ListingTitle, L.ShortDescr, L.DateListed, L.PriceUS, L.PriceTZS,
		L.RentUS, L.RentTZS, L.Bedrooms, L.Bathrooms, L.AmenityOther, L.LocationOther, L.LocationText,
		L.LongDescr, L.MakeID, L.DateSort,
		L.Make as MakeOther, L.Model as ModelOther, L.VehicleYear, L.Kilometers, L.FourWheelDrive,
		L.Deadline, L.WebsiteURL, L.PublicPhone,  L.PublicPhone2,  L.PublicPhone3,  L.PublicPhone4, L.PublicEmail, L.URLSafeTitle as ListingURL, 
		L.EventStartDate, L.EventEndDate, L.RecurrenceID, L.RecurrenceMonthID,
		L.ExpandedListingHTML, L.ExpandedListingPDF,
		L.CuisineOther, L.AccountName,
		GROUP_CONCAT(LOC.Title SEPARATOR ', ') Location,
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= '" . CURRENT_DATE_IN_TZ . "' Then 1 Else 0 END as HasExpandedListing,
		L.SquareFeet, L.SquareMeters,
		L.LogoImage, L.ELPTypeThumbnailImage, L.ELPThumbnailFromDoc,
		PS.ParentSectionID, PS.Title as ParentSection, PS.URLSafeTitleDashed as ParentSectionURLSafeTitle,
		S.SectionID, S.Title as SubSection,
		C.CategoryID, C.Title as Category, 
		M.Title as Make, T.Title as Transmission,
		Te.Title as Term, RAND() as RandOrderID, ";

		
		$listingsQuery .= "CASE WHEN L.UserID = " . PHONE_ONLY_USER . " THEN 1 ELSE 0 END as PhoneOnlyListing_fl
		From parentsectionsview PS 
		Inner Join sections S  on PS.ParentSectionID=S.ParentSectionID	
		Inner Join categories C  on S.SectionID=C.SectionID
		Inner Join listingcategories LC  on C.CategoryID=LC.CategoryID
		Inner Join listingsview L  on LC.ListingID=L.ListingID ";

	
		$listingsQuery .= "Left Outer Join makes M  on L.MakeID=M.MakeID
		Left Outer Join listinglocations LL on L.ListingID = LL.ListingID and LL.LocationID <> 4
		Inner Join locations LOC on LL.LocationID = LOC.LocationID
		Left Outer Join transmissions T  on L.TransmissionID=T.TransmissionID
		Left outer Join terms Te  on L.TermID=Te.TermID
		 Where S.Active=1";

		$listingsQuery .= " and (L.ListingTypeID IN (1,2,14,15) or (L.ExpirationDate >= '" . CURRENT_DATE_IN_TZ . "' ))";


		$listingsQuery .= "
		and L.Active=1

		and L.Reviewed=1 

		and L.DeletedAfterSubmitted=0 

		and (L.Deadline is null or L.Deadline >= '" . CURRENT_DATE_IN_TZ . "')

		AND (L.ListingTypeID <> 15
			OR EXISTS (SELECT ListingID FROM listingeventdays  WHERE ListingID=L.ListingID 
					AND ListingEventDate >= '" . CURRENT_DATE_IN_TZ . "'))


		AND L.ListingID = $ListingID";

		$listing= $this->db->query($listingsQuery);


		return $listing;
	}


	function gethints($ParentSectionID=0, $SectionID=0,$CategoryID=0)
	{
		//Getting Page Text




		if($CategoryID != 0)
		{

			$pageText = "Select H.HintID, H.Descr
			From hints H
			Where H.Active=1
			and H.HintTypeID=1
			and exists (Select HintID From hintcategories Where CategoryID = $CategoryID and HintID=H.HintID)
			Order by Rand() Limit 1";

			$hints['pageTextObj'] = $this->db->query($pageText);

		}

		if((isset($SectionID) and $SectionID !=0 and $CategoryID == 0) or (isset($hints['pageTextObj']) and $hints['pageTextObj']->num_rows() == 0) and isset($SectionID) )
		{

			$pageText = "Select H.HintID, H.Descr
			From hints H
			Where H.Active=1
			and H.HintTypeID=1
			and exists (Select HintID From hintsections Where SectionID = $SectionID and HintID=H.HintID)
			Order by Rand() Limit 1";

			$hints['pageTextObj'] = $this->db->query($pageText);
		}

		if(($ParentSectionID != 0 and $SectionID ==0 and $CategoryID == 0) or (isset($hints['pageTextObj']) and $hints['pageTextObj']->num_rows() == 0))
		{

			$pageText = "Select H.HintID, H.Descr
			From hints H
			Where H.Active=1
			and H.HintTypeID=1
			and exists (Select HintID From hintparentsections Where ParentSectionID = $ParentSectionID and HintID=H.HintID)
			Order by Rand() Limit 1";

			$hints['pageTextObj'] = $this->db->query($pageText);
		}

		if($CategoryID != 0)
		{

			$youMayAlsoLike = "Select H.HintID, H.Descr
			From hints H
			Where H.Active=1
			and H.HintTypeID=2
			and exists (Select HintID From hintcategories Where CategoryID = $CategoryID and HintID=H.HintID)
			Order by Rand() Limit 3";

			$hints['youMayAlsoLikeObj'] = $this->db->query($youMayAlsoLike);

		}

		if((isset($SectionID) and $SectionID !=0 and $CategoryID == 0) or (isset($hints['youMayAlsoLikeObj']) and $hints['youMayAlsoLikeObj']->num_rows() == 0 ) and isset($SectionID))
		{

			$youMayAlsoLike = "Select H.HintID, H.Descr
			From hints H
			Where H.Active=1
			and H.HintTypeID=2
			and exists (Select HintID From hintsections Where SectionID = $SectionID and HintID=H.HintID)
			Order by Rand() Limit 3";

			$hints['youMayAlsoLikeObj'] = $this->db->query($youMayAlsoLike);
		}

		if(($ParentSectionID != 0 and $SectionID ==0 and $CategoryID == 0) or (isset($hints['youMayAlsoLikeObj']) and $hints['youMayAlsoLikeObj']->num_rows() == 0))
		{

			$youMayAlsoLike = "Select H.HintID, H.Descr
			From hints H
			Where H.Active=1
			and H.HintTypeID=2
			and exists (Select HintID From hintparentsections Where ParentSectionID = $ParentSectionID and HintID=H.HintID)
			Order by Rand() Limit 3";

			$hints['youMayAlsoLikeObj'] = $this->db->query($youMayAlsoLike);
		}
		



		return $hints;

	}

	function determiner($pageURL)
	{
		$this->db->where_in('ListingTypeID', array(1,2,20));
		$this->db->where('upper(URLSafeTitle)', strtoupper(str_replace("-", "", $pageURL)), true);
		$listing=$this->db->get('listingsview');


		if ($listing->num_rows() > 0)
		{

			$ListingQuery = "
			Select STRAIGHT_JOIN L.ListingID, L.ListingTypeID, L.ListingTitle, L.ShortDescr, L.DateListed, L.LocationOther, L.LocationText,
			L.LongDescr,  
			
			L.Deadline, L.WebsiteURL, L.PublicPhone,  L.PublicPhone2,  L.PublicPhone3,  L.PublicPhone4, L.PublicEmail, L.URLSafeTitle as ListingURL, 
			
			L.ExpandedListingHTML, L.ExpandedListingPDF,
			 L.AccountName,
			GROUP_CONCAT(LOC.Title SEPARATOR ', ') Location,
			CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= '" . CURRENT_DATE_IN_TZ . "' Then 1 Else 0 END as HasExpandedListing,
			CASE WHEN L.UserID = " . PHONE_ONLY_USER . " THEN 1 ELSE 0 END as PhoneOnlyListing_fl,
			L.LogoImage, L.ELPTypeThumbnailImage, L.ELPThumbnailFromDoc,
			PS.ParentSectionID, PS.Title as ParentSection, PS.URLSafeTitleDashed as ParentSectionURLSafeTitle,
			S.SectionID, S.Title as SubSection,
			C.CategoryID, C.Title as Category, 
			(Select FileName
		 	From listingimages 
			Where ListingID=L.ListingID
		 	Order By OrderNum, ListingImageID Limit 1) as FileNameForTN
			From parentsectionsview PS 
			Inner Join sections S  on PS.ParentSectionID=S.ParentSectionID	
			Inner Join categories C  on S.SectionID=C.SectionID
			Inner Join listingcategories LC  on C.CategoryID=LC.CategoryID
			Inner Join listingsview L  on LC.ListingID=L.ListingID

			Left Outer Join listinglocations LL on L.ListingID = LL.ListingID and LL.LocationID <> 4
			Inner Join locations LOC on LL.LocationID = LOC.LocationID

			Where S.Active=1

			and L.Active=1

			and L.Reviewed=1 

			and L.DeletedAfterSubmitted=0 

			and (L.ListingTypeID IN (1) or (L.ExpirationDate >= '" . CURRENT_DATE_IN_TZ . "' ))

			and (L.Deadline is null or L.Deadline >= '" . CURRENT_DATE_IN_TZ . "')

			and L.ListingID = " . $listing->row()->ListingID;

			$row=$this->db->query($ListingQuery);

			return $row;

		}

		else
		{
			$this->db->where('upper(URLSafeTitleDashed)', strtoupper($pageURL), true);
			$section=$this->db->get('sections');


			if($section->num_rows() == 0)
			{
				$this->db->select('*, categories.URLSafeTitleDashed as catURL, sections.URLSafeTitleDashed as secURL');
				$this->db->where('upper(categories.URLSafeTitle)', strtoupper(str_replace("-", "", $pageURL)), true);
				$this->db->from('categories');
				$this->db->join('sections','categories.SectionID = sections.SectionID');
				$category=$this->db->get();



				if($category->num_rows() == 0)
				{

					$this->db->select('*, categories.ParentSectionID as ParentSectionID, categories.URLSafeTitleDashed as catURL, sections.URLSafeTitleDashed as secURL');
					$this->db->where('upper(categories.URLSafeTitle)', strtoupper(str_replace("-", "", $pageURL)), true);
					$this->db->from('categories');
					$this->db->join('sections','categories.ParentSectionID = sections.SectionID');
					$category=$this->db->get();

					if($category->num_rows() == 0)
					{					

						$this->db->select('*');
						$this->db->from('lh_pages_live');
						$this->db->where('MembersOnly', 0);
						$this->db->where('upper(lh_pages_live.Name)', strtoupper($pageURL), true);
						$this->db->join('lh_templates', 'lh_templates.TemplateID = lh_pages_live.TemplateID');

						$page = $this->db->get();

						return $page;
					}	

					else return $category;			
				}

				else return $category;
			}

			else return $section;
		}
	}

	function getFeaturedlistings($ParentSectionID)
	{
				$featuredBusinessQuery = "Select L.ListingID, L.ListingTitle, L.ShortDescr, L.Deadline,
		L.ELPTypeThumbnailImage, L.LogoImage, L.ELPThumbnailFromDoc
		From listingsview L inner join listingcategories LC on L.ListingID = LC.ListingID
		Where L.ListingTypeID  in (1,2,14)
		and L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= '" . CURRENT_DATE_IN_TZ . "'
		and L.Active=1 and L.Reviewed=1 and L.DeletedAfterSubmitted=0 and L.Blacklist_fl = 0 and LC.CategoryID IN (SELECT CategoryID FROM categories WHERE ParentSectionID = " . $ParentSectionID . ") 
		Order by L.FeaturedListing desc, L.DateSort desc Limit 5";

		return $this->db->query($featuredBusinessQuery);
	}

	function getRelatedEvents($eventcategories)
	{
		$relatedEventsQuery = "
			Select L.ListingID, L.ListingTitle, L.EventStartDate, L.RecurrenceID, L.RecurrenceMonthID,
		(Select Min(ListingEventDate) From listingeventdays  Where ListingID=L.ListingID) as StartDate, (Select Max(ListingEventDate) From listingeventdays  Where ListingID=L.ListingID) as EndDate,
		
		CASE WHEN (Select Min(ListingEventDate) From listingeventdays  Where ListingID=L.ListingID) <= '" . CURRENT_DATE_IN_TZ . "'
			THEN (Select Max(ListingEventDate) From listingeventdays  Where ListingID=L.ListingID) 
			ELSE (Select Min(ListingEventDate) From listingeventdays  Where ListingID=L.ListingID) 
			END as EventSortDate,	
		CASE WHEN RecurrenceID is NULL and (EventEndDate is null or cast(EventStartDate as char) = cast(EventEndDate as char)) THEN 1
			WHEN RecurrenceID is NULL and (Select Min(ListingEventDate) From listingeventdays  Where ListingID=L.ListingID) <= '" . CURRENT_DATE_IN_TZ . "' THEN 6 
			WHEN RecurrenceID is null THEN 5 
			WHEN RecurrenceID=3 THEN 2 
			WHEN RecurrenceID=2 THEN 3 
			WHEN RecurrenceID=1 THEN 4 
			ELSE 10 END as EventRank,
		
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= '" . CURRENT_DATE_IN_TZ . "' Then 1 Else 0 END as HasExpandedListing,
		L.ELPTypeThumbnailImage, L.ExpandedListingPDF		
		From listingsview L inner join listingcategories LC on L.ListingID = LC.ListingID
		Where (
				EXISTS (SELECT ListingID FROM listingeventdays  WHERE ListingID=L.ListingID AND ListingEventDate >= '" . CURRENT_DATE_IN_TZ . "')
				
					)
			
		and (RecurrenceID  in (3,4) or RecurrenceID is null)
		and L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= '" . CURRENT_DATE_IN_TZ . "'
		and L.Active=1 and L.Reviewed=1 and L.DeletedAfterSubmitted=0 and L.Blacklist_fl = 0 and LC.CategoryID IN (". $eventcategories .")
		Order By EventSortDate, EventRank,  L.ListingTitle";

		return $this->db->query($relatedEventsQuery);
	}



}

/* End of file listingsModel.php */
/* Location: ./application/models/listingsModel.php */