<?php
if (!defined('BASEPATH'))
    exit('No direct script access allowed');

class Listings extends CI_Controller {

    public function __construct() {
        parent::__construct();
        $this->load->model('listingsmodel');
    }

    function testmenu() {
        $this->common->menu();
    }

    public function index($pageURL = '') {

        if ($pageURL != '') {
            if ($pageURL == 'testsearch')
                $this->search(4);

            $res = $this->listingsmodel->determiner($pageURL);


            if (isset($res->row()->ListingID)) {
                $this->listingdetail($res->row()->ListingID);
            } else if (isset($res->row()->ParentPageID)) {

                $function = explode('.', $res->row()->FileName);

                //print_r($function);
                if (method_exists($this, $function[0]))
                    $this->$function[0]($res);
                else
                    $this->page($res);
            }

            else if (isset($res->row()->CategoryID) and !isset($res->row()->ListingID)) {

                switch ($res->row()->ParentSectionID) {
                    case '1':
                        $this->tanzania_business_directory($res->row()->secURL, $res->row()->catURL);
                        break;

                    case '21':
                        $this->travel_and_tourism_directory($res->row()->catURL);
                        break;

                    case '32':
                        $this->restaurants_and_nightlife($res->row()->catURL);
                        break;

                    case '66':
                        $this->arts_and_entertainment($res->row()->catURL);
                        break;




                    case '59':
                        $this->tanzania_events_calendar($res->row()->catURL);
                        break;

                    default:
                        echo "Ha" . $res->row()->ParentSectionID;
                        break;
                }
            } else if (isset($res->row()->SectionID) and !isset($res->row()->CategoryID) and !isset($res->row()->ListingID) and $res->row()->ParentSectionID != 0) {
                switch ($res->row()->ParentSectionID) {
                    case '1':
                        $this->tanzania_business_directory($res->row()->URLSafeTitleDashed);
                        break;


                    default:
                        echo "ha";
                        break;
                }
            } else if (isset($res->row()->SectionID) and !isset($res->row()->CategoryID) and !isset($res->row()->ListingID) and $res->row()->ParentSectionID == 0) {


                switch ($res->row()->SectionID) {
                    case '1':
                        $this->tanzania_business_directory();
                        break;

                    case '21':
                        $this->travel_and_tourism_directory();
                        break;

                    case '32':
                        $this->restaurants_and_nightlife();
                        break;

                    case '5':
                        $details = array();

                        // if($res->row()->ParentSectionID)
                        // 	$details['ParentSectionID']=$res->row()->ParentSectionID;
                        if ($res->row()->SectionID) {
                            $details['ParentSectionID'] = $res->row()->SectionID;
                            $details['SectionID'] = $res->row()->SectionID;
                        }
                        $this->tanzania_real_estate($details);
                        break;

                    case '4':
                        $details = array();
                        if ($res->row()->SectionID) {

                            $details['SectionID'] = $res->row()->SectionID;
                        }
                        $this->steals_deals_and_classifieds($details);
                        break;

                    case '8':
                        $details = array();


                        if ($res->row()->SectionID) {
                            $details['ParentSectionID'] = $res->row()->SectionID;
                            $details['SectionID'] = $res->row()->SectionID;
                        }

                        $this->tanzania_jobs_and_employment($details);
                        break;

                    case '55':

                        $details = array();

                        // if($res->row()->ParentSectionID)
                        // 	$details['ParentSectionID']=$res->row()->ParentSectionID;
                        if ($res->row()->SectionID) {
                            $details['ParentSectionID'] = $res->row()->SectionID;
                            $details['SectionID'] = $res->row()->SectionID;
                        }
                        $this->used_cars_trucks_and_boats($details);
                        break;

                    case '59':
                        $details = array();

                        // if($res->row()->ParentSectionID)
                        // 	$details['ParentSectionID']=$res->row()->ParentSectionID;
                        if ($res->row()->SectionID) {
                            $details['ParentSectionID'] = $res->row()->SectionID;
                            $details['SectionID'] = $res->row()->SectionID;
                        }
                        $this->tanzania_events_calendar($details);
                        break;

                    default:
                        echo "ha";
                        break;
                }
            }

            // else $this->section_listings($this->uri->segment(2));
        } else {

            $header['Meta']->BrowserTitle = 'Tanzania Directory for Business, Entertainment & Travel Info';
            $header['Meta']->MetaDescr = 'Welcome to ZoomTanzania, where locals go to find  accurate and up-to-date business, entertainment, jobs, real estate, cars, travel and classified information.';

            $movieSchedulesQuery = "
				SELECT L.Title as TheatreName, LOC.Title as Location, L.URLSafeTitle, (Select MovieImage from listingmovies as LM where L.ListingID = LM.ListingID order by OrderNum limit 1) as Flier FROM listingsview as L inner join listinglocations as LL on L.ListingID = LL.ListingID inner join locations as LOC on LL.LocationID = LOC.LocationID where L.ListingTypeID = 20 and L.Active=1 and L.Reviewed=1 and L.DeletedAfterSubmitted=0 and L.Blacklist_fl = 0";

            $data['movieSchedulesObj'] = $this->db->query($movieSchedulesQuery);

            $specialEventsQuery = "
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
		From listingsview L 
		Where (
				EXISTS (SELECT ListingID FROM listingeventdays  WHERE ListingID=L.ListingID AND ListingEventDate >= '" . CURRENT_DATE_IN_TZ . "')
				
					)
			
		and (RecurrenceID  in (3,4) or RecurrenceID is null)
		and L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= '" . CURRENT_DATE_IN_TZ . "'
		and L.Active=1 and L.Reviewed=1 and L.DeletedAfterSubmitted=0 and L.Blacklist_fl = 0 
		Order By EventSortDate, EventRank,  L.ListingTitle";

            $data['specialEventsObj'] = $this->db->query($specialEventsQuery);


            $featuredBusinessQuery = "Select L.ListingID, L.ListingTitle, L.ShortDescr, L.Deadline,
			L.ELPTypeThumbnailImage, L.LogoImage, L.ELPThumbnailFromDoc
			From listingsview L
			Where L.ListingTypeID  in (1,2,14)
			and L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= '" . CURRENT_DATE_IN_TZ . "'
			and L.Active=1 and L.Reviewed=1 and L.DeletedAfterSubmitted=0 and L.Blacklist_fl = 0
			Order by L.FeaturedListing desc, L.DateSort desc Limit 1";

            $data['featuredBusinessObj'] = $this->db->query($featuredBusinessQuery);

            $travelSpecialQuery = "Select L.ListingID, L.ListingTitle, L.ShortDescr, L.Deadline,
			L.ELPTypeThumbnailImage, L.LogoImage, L.ELPThumbnailFromDoc
			From listingsview L
			Where L.ListingTypeID  in (9)
			and L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= '" . CURRENT_DATE_IN_TZ . "' and L.Deadline >= '" . CURRENT_DATE_IN_TZ . "' 
			and L.Active=1 and L.Reviewed=1 and L.DeletedAfterSubmitted=0 and L.Blacklist_fl = 0
			Order by L.FeaturedTravelListing desc, L.DateSort desc Limit 1";

            $data['travelSpecialObj'] = $this->db->query($travelSpecialQuery);


            $data['rates'] = $this->exchange_rates();

            $tidesQuery = "select t.tideDate, t.High, t.Measurement,l.LunarDate,l.MoonTypeID,mt.descr 
		from tides t left join lunar l 
	ON CONVERT(t.TideDate,  date)=CONVERT(l.LunarDate ,  date)
	left join moontype mt  ON l.moonTypeID = mt.moonTypeID

	where TideDate >= '" . date("Y-m-d") . ' 00:00:00' . "'
	AND TideDate <= '" . date("Y-m-d") . ' 23:59:00' . "'";

            $data['tidesObj'] = $this->db->query($tidesQuery);




            $this->load->view('header', $header);
            $this->load->view('menu');
            $this->load->view('home-new', $data);
            $this->load->view('footer');
        }
    }

    function exchange_rates() {
        $this->db->order_by('orderNum');
        return $this->db->get('exchange_rates');
    }

//and EXISTS (SELECT ListingID FROM listingeventdays  WHERE ListingID=L.ListingID and ListingEventDate <=DATE_ADD(2013-01-01, INTERVAL 28 DAY)
    //events 406/342/347
    function tanzania_business_directory($URLSafeTitleDashed = '', $categoryURLSafeTitleDashed = '') {
        $leftSide['featuredBusinessObj'] = $this->getFeaturedListings(1);

        $leftSide['relatedEventsObj'] = $this->getRelatedEvents(406, 342, 347);


        if ($categoryURLSafeTitleDashed != '') {
            $this->category($categoryURLSafeTitleDashed, $leftSide);
        } else if ($URLSafeTitleDashed != '' and $categoryURLSafeTitleDashed == '') {

            $this->subsection($URLSafeTitleDashed, $leftSide);
        } else {

            $this->section_subsections(1, $leftSide);
        }
    }

    function travel_and_tourism_directory($URLSafeTitleDashed = '') {

        $leftSide['featuredBusinessObj'] = $this->getFeaturedListings(21);

        if ($URLSafeTitleDashed != '') {
            $this->category($URLSafeTitleDashed, $leftSide);
        } else {
            $this->section_categories(21, $leftSide);
        }
    }

    function restaurants_and_nightlife($URLSafeTitleDashed = '') {

        $leftSide['featuredBusinessObj'] = $this->getFeaturedListings(32);
        $leftSide['relatedEventsObj'] = $this->getRelatedEvents(357, 338, 408, 360, 413);

        if ($URLSafeTitleDashed != '') {
            $this->category($URLSafeTitleDashed, $leftSide);
        } else {
            $this->section_categories(32, $leftSide);
        }
    }

    function arts_and_entertainment($URLSafeTitleDashed = '') {
        $leftSide['featuredBusinessObj'] = $this->getFeaturedListings(66);
        $leftSide['relatedEventsObj'] = $this->getRelatedEvents(413, 339, 344, 356);

        if ($URLSafeTitleDashed != '') {

            $this->category($URLSafeTitleDashed, $leftSide);
        } else {
            $this->section_categories(66, $leftSide);
        }
    }

    function tanzania_jobs_and_employment($details, $categoryURLSafeTitleDashed = '') {
        if ($categoryURLSafeTitleDashed != '') {
            $this->category($categoryURLSafeTitleDashed);
        } elseif ($details['ParentSectionID'] != '' and $categoryURLSafeTitleDashed == '') {

            $this->section_listings($details);
        }
    }

    function steals_deals_and_classifieds($details, $categoryURLSafeTitleDashed = '') {
        if ($categoryURLSafeTitleDashed != '') {
            $this->category($categoryURLSafeTitleDashed);
        } elseif ($details['SectionID'] != '' and $categoryURLSafeTitleDashed == '') {

            $this->section_listings($details);
        }
    }

    function used_cars_trucks_and_boats($details, $categoryURLSafeTitleDashed = '') {
        //print_r($details);

        if ($categoryURLSafeTitleDashed != '') {
            $this->category($categoryURLSafeTitleDashed);
        } elseif ($details['SectionID'] != '' and $categoryURLSafeTitleDashed == '') {

            $this->section_listings($details);
        }
    }

    function tanzania_real_estate($details, $categoryURLSafeTitleDashed = '') {
        //print_r($details);

        if ($categoryURLSafeTitleDashed != '') {
            $this->category($categoryURLSafeTitleDashed);
        } elseif ($details['ParentSectionID'] != '' and $categoryURLSafeTitleDashed == '') {

            $this->section_listings($details);
        }
    }

    function testpage($view) {
        $this->load->view('header');
        $this->load->view($view);
        $this->load->view('footer');
    }

    function tanzania_events_calendar($details) {

        if ($categoryURLSafeTitleDashed != '') {
            $this->category($categoryURLSafeTitleDashed);
        } elseif ($details['ParentSectionID'] != '' and $categoryURLSafeTitleDashed == '') {

            $this->section_listings($details);
        }
    }

    function getFeaturedListings($ParentSectionID) {
        return $this->listingsmodel->getFeaturedListings($ParentSectionID);
    }

    function getRelatedEvents($eventcategories) {
        return $this->listingsmodel->getRelatedEvents($eventcategories);
    }

    function section_subsections($SectionID, $leftSide = '') {
        $this->db->where('SectionID', $SectionID);
        $header['Meta'] = $data['sectionMeta'] = $this->db->get('sections')->row();



        $data['subsections'] = $this->listingsmodel->getSection($SectionID);

        ///print_r($header);
        $hints = $this->listingsmodel->getHints($SectionID);
        $data['pageTextObj'] = $hints['pageTextObj'];
        $leftSide['youMayAlsoLikeObj'] = $hints['youMayAlsoLikeObj'];

        $this->load->view('header', $header);
        $this->load->view('menu');
        $this->load->view('left-sidetower', $leftSide);
        $this->load->view('section-landing', $data);
        //die();
        $this->load->view('right-sidetower');
        $this->load->view('footer');
    }

    function section_categories($SectionID, $leftSide = '') {

        $data['categories'] = $this->listingsmodel->getSection($SectionID);
        $this->db->where('SectionID', $SectionID);
        $header['Meta'] = $data['sectionMeta'] = $this->db->get('sections')->row();
        $hints = $this->listingsmodel->getHints($SectionID);
        $data['pageTextObj'] = $hints['pageTextObj'];
        $leftSide['youMayAlsoLikeObj'] = $hints['youMayAlsoLikeObj'];

        $this->load->view('header', $header);
        $this->load->view('menu');
        if (isset($leftSide))
            $this->load->view('left-sidetower', $leftSide);
        else
            $this->load->view('left-sidetower');
        $this->load->view('sub-section-landing', $data);
        $this->load->view('right-sidetower');
        $this->load->view('footer');
    }

    function subsection($URLSafeTitleDashed, $leftSide = '') {
        $this->db->where('URLSafeTitleDashed', strtolower($URLSafeTitleDashed));
        $header['Meta'] = $data['sectionMeta'] = $this->db->get('sections')->row();

        $hints = $this->listingsmodel->getHints($data['sectionMeta']->ParentSectionID, $data['sectionMeta']->SectionID);
        $data['pageTextObj'] = $hints['pageTextObj'];
        $leftSide['youMayAlsoLikeObj'] = $hints['youMayAlsoLikeObj'];

        $data['subsection'] = true;
        $data['categories'] = $this->listingsmodel->getSection($data['sectionMeta']->SectionID);

        $this->load->view('header', $header);
        $this->load->view('menu-new');
        $this->load->view('left-sidetower', $leftSide);
        $this->load->view('sub-section-landing', $data);
        $this->load->view('right-sidetower');
        $this->load->view('footer');
    }

    function section_listings($details, $categoryURLSafeTitleDashed = '') {

        //print_r($details);
        $data['locations'] = $this->listingsmodel->getTables('locations');
        //echo $SectionID;
        $params = array();

        if (isset($details['ParentSectionID']))
            $this->db->where('SectionID', $details['ParentSectionID']);
        else
            $this->db->where('SectionID', $details['SectionID']);

        $header['Meta'] = $data['sectionMeta'] = $this->db->get('sections')->row();


        $params['SectionID'] = $details['SectionID'];
        if (isset($details['ParentSectionID']))
            $params['ParentSectionID'] = $details['ParentSectionID'];

        if ($header['Meta']->ParentSectionID)
            $hints = $this->listingsmodel->getHints($header['Meta']->ParentSectionID, $header['Meta']->SectionID);
        else
            $hints = $this->listingsmodel->getHints(0, $header['Meta']->SectionID);





        //print_r($categoryDetails);

        if ($this->input->get('LocationID') > 0)
            $categoryDetails['LocationID'] = $this->input->get('LocationID');

        $data['pageTextObj'] = $hints['pageTextObj'];

        // print_r(($data['pageTextObj']));

        $leftSide['youMayAlsoLikeObj'] = $hints['youMayAlsoLikeObj'];

        if (isset($leftSide['featuredBusinessObj']))
            unset($leftSide['featuredBusinessObj']);


        $this->db->where('active', 1);
        $this->db->where('SectionID', $details['SectionID']);
        $categories = $this->db->get('categories');


        if ($categories->num_rows() == 0) {
            $this->db->where('active', 1);
            $this->db->where('ParentSectionID', $details['SectionID']);
            $categories = $this->db->get('categories');
        }

        $params['categoryID'] = '';

        foreach ($categories->result() as $category) {
            $params['categoryID'] .= $category->CategoryID . ',';
        }

        $string = $params['CategoryID'] = substr($params['categoryID'], 0, -1);




        $catID = explode(",", $params['CategoryID']);




        $params = $this->listingsmodel->getCategory($catID[0]);
        $params['CategoryIDs'] = $string;

        if ($details['SectionID'] == 8) {
            $params['JETID'] = 1;
            $params['InJobSectionOverview'] = 1;
            $params['ParentSectionID'] = $details['SectionID'];
            //unset($params['CategoryIDs']);
        }

        $data['SectionID'] = $details['SectionID'];
        if ($this->input->get('LocationID') > 0)
            $params['LocationID'] = $this->input->get('LocationID');


        $params['limit'] = true;
        $params['SortBy'] = 'MostRecent';
        $data['listings'] = $this->listingsmodel->getListings($params);


        //echo $this->db->last_query();

        $this->load->view('header', $header);
        $this->load->view('menu');

        if (isset($leftSide))
            $this->load->view('left-sidetower', $leftSide);
        else
            $this->load->view('left-sidetower');

        switch ($details['SectionID']) {
            // case '59':
            // 	$this->load->view('events-landing',$data);
            // 	break;

            case '8':
                $this->load->view('jobs-landing', $data);
                break;

            case '5':
            case '4':
            case '55':
            case '59':
                $this->load->view('classifieds-landing-page', $data);
                break;

            default:
                # code...
                break;
        }

        $this->load->view('right-sidetower');
        $this->load->view('footer');
    }

    function category($categoryURLSafeTitleDashed, $leftSide = '') {
        $data['locations'] = $this->listingsmodel->getTables('locations');
       

		$this->db->select('categories.Title as catTitle, categories.H1Text as catH1Text, CategoryID, categories.ParentSectionID, categories.SectionID, sections.Title secTitle');
		$this->db->from('categories');
		$this->db->join('sections', 'categories.ParentSectionID = sections.SectionID');
		$category=$this->db->get()->row();


        $header['Meta'] = $data['catMeta'] = $category;

        $categoryDetails = $this->listingsmodel->getCategory($category->CategoryID);

        $hints = $this->listingsmodel->getHints($category->ParentSectionID, $category->SectionID, $category->CategoryID);



        //print_r($categoryDetails);

        if ($this->input->get('LocationID') > 0)
            $categoryDetails['LocationID'] = $this->input->get('LocationID');

        $data['pageTextObj'] = $hints['pageTextObj'];

        $leftSide['youMayAlsoLikeObj'] = $hints['youMayAlsoLikeObj'];

        if (isset($leftSide['featuredBusinessObj']))
            unset($leftSide['featuredBusinessObj']);



        $data['Featured_listings_result_obj'] = $this->listingsmodel->getListings($categoryDetails, 1);


        $listings = $data['Listings_result_obj'] = $this->listingsmodel->getListings($categoryDetails);

        $data['quoteRequestString'] = '';
        $forlocation = array();
        foreach ($listings->result() as $listing) {
            $data['quoteRequestString'] .= $listing->ListingID . ',';
        }

        $data['quoteRequestString'] = substr($data['quoteRequestString'], 0, -1);

        $this->load->view('header', $header);
        $this->load->view('menu');
        if (isset($leftSide))
            $this->load->view('left-sidetower', $leftSide);
        else
            $this->load->view('left-sidetower');

        $this->load->view('category-landing', $data);

        $this->load->view('right-sidetower');
        $this->load->view('footer');
    }

    function subsection_old($URLSafeTitleDashed) {


        $this->db->where('URLSafeTitleDashed', $URLSafeTitleDashed);
        $current_sub_section = $this->db->get('sections');

        $header['current'] = $data['current_sub_section'] = $current_sub_section->row();

        $this->db->where('Active', 1);
        $this->db->where('SectionID', $current_sub_section->row()->SectionID);
        $this->db->order_by('Title');
        $categories = $this->db->get('categories');


        $hints = $this->listingsmodel->getHints('hintsections', 'SectionID', $data['current_sub_section']->SectionID);

        if (isset($hints['pageText']))
            $data['pageText'] = $hints['pageText'];

        if (isset($hints['youMayAlsoLike']))
            $leftSide['youMayAlsoLike'] = $hints['youMayAlsoLike'];

        $categories_array = array();
        $category_titles = array();

        foreach ($categories->result() as $category) {
            $category_titles[$category->CategoryID] = $category->Title;
            $category_images[$category->CategoryID] = $category->ImageFile;
            $category_links[$category->CategoryID] = $category->URLSafeTitleDashed;
            $categories_array[] = $category->CategoryID;
        }

        $data['category_titles'] = $category_titles;
        $data['category_images'] = $category_images;
        $data['category_links'] = $category_links;

        $this->load->view('header', $header);
        $this->load->view('menu');
        if (isset($left_side))
            $this->load->view('left-sidetower', $left_side);
        else
            $this->load->view('left-sidetower');

        $this->load->view('sub-section-landing', $data);
        $this->load->view('right-sidetower');
        $this->load->view('footer');
    }

    function category_old($URLSafeTitleDashed) {
        $data['locations'] = $this->listingsmodel->getTables('locations');
        foreach ($data['locations']->result() as $location) {
            $locations_array[$location->LocationID] = $location->Title;
        }


        $this->db->where('URLSafeTitleDashed', $URLSafeTitleDashed);

        $category_result_obj = $this->db->get('categories');

        $header['current'] = $data['catMeta'] = $category_result_obj->row();

        $category = $category_result_obj->row();


        $this->db->where('CategoryID', $category->CategoryID);
        $listingcategories_result_obj = $this->db->get('listingcategories');

        foreach ($listingcategories_result_obj->result() as $listingcategories) {
            $listings_array[] = $listingcategories->ListingID;
        }

        $this->db->order_by('Title');
        $this->db->where_in('ListingID', $listings_array);
        $data['Listings_result_obj'] = $this->db->get('Listings');


        $this->db->where_in('ListingID', $listings_array);
        $listinglocationsObj = $this->db->get('listinglocations');


        foreach ($listinglocationsObj->result() as $listinglocations) {
            if (isset($ListingLocationNames[$listinglocations->ListingID]))
                $ListingLocationNames[$listinglocations->ListingID] .= ', ' . $locations_array[$listinglocations->LocationID];
            else
                $ListingLocationNames[$listinglocations->ListingID] = $locations_array[$listinglocations->LocationID];
        }

        $data['ListingLocationNames'] = $ListingLocationNames;

        $hints = $this->listingsmodel->getHints($data['current_category']->ParentSectionID, $data['current_category']->SectionID, $data['current_category']->CategoryID);

        if (isset($hints['pageText']))
            $data['pageText'] = $hints['pageText'];

        if (isset($hints['youMayAlsoLike']))
            $leftSide['youMayAlsoLike'] = $hints['youMayAlsoLike'];


        $this->load->view('header', $header);
        $this->load->view('menu');
        if (isset($left_side))
            $this->load->view('left-sidetower', $left_side);
        else
            $this->load->view('left-sidetower');

        $this->load->view('category-landing-bu', $data);
        $this->load->view('right-sidetower');
        $this->load->view('footer');
    }

    public function listingdetail($ListingID = '') {
        if ($this->input->get('ListingID'))
            $ListingID = $this->input->get('ListingID');
        $listingObj = $this->listingsmodel->getsinglelisting($ListingID);

        $data['target'] = '';

        $data['listing'] = $listingObj->row();

        
        if(!$data['listing']->ParentSectionID)
            $data['listing']->ParentSectionID = 4;



        switch ($data['listing']->ParentSectionID) {

            case '1':
                $header['Meta']->BrowserTitle = $data['listing']->ListingTitle . ' in ' . $data['listing']->Location . ', Tanzania';
                $header['Meta']->MetaDescr = $header['Meta']->BrowserTitle . $data['listing']->ShortDescr;
                $leftSide['featuredBusinessObj'] = $this->getFeaturedListings(1);
                $leftSide['relatedEventsObj'] = $this->getRelatedEvents(406, 342, 347);

                if ($data['listing']->HasExpandedListing) {
                    $file_parts = pathinfo(LISTINGUPLOADEDDOCS . $data['listing']->ExpandedListingPDF);

                    switch ($file_parts['extension']) {
                        case 'jpeg':
                        case 'jpg':
                        case 'png':
                        case 'gif':
                            $data['featuredURL'] = 'zoomedlisting?ListingID=' . $data['listing']->ListingID;

                            break;



                        case 'pdf':
                            $data['target'] .= "target = '_blank'";
                            $data['featuredURL'] = LISTINGUPLOADEDDOCS . $data['listing']->ExpandedListingPDF;
                            break;

                        default:
                            # code...
                            break;
                    }
                }

                break;

            case '8':
                $header['Meta']->BrowserTitle = $data['listing']->ShortDescr . ' Job in ' . $data['listing']->Location . ', Tanzania';
                $header['Meta']->MetaDescr = $header['Meta']->BrowserTitle;

                break;




			case '5':

    			$header['Meta']->BrowserTitle = $data['listing']->ListingTitle;  
        			switch ($data['listing']->ListingTypeID) {
        				case '7':
        				case '6':
        					$header['Meta']->BrowserTitle .= ' For Rent in ';
        					break;	

        				case '8':
        					$header['Meta']->BrowserTitle .= ' For Sale in ';
        					break;

                    $header['Meta']->BrowserTitle .= $data['listing']->Location . ', Tanzania' ;
                    $header['Meta']->MetaDescr .=  $header['Meta']->BrowserTitle;

    				
           		 }

             case '55':
                
                if ($data['listing']->ListingTypeID == 3) {
                    $header['Meta']->BrowserTitle = $data['listing']->ListingTitle . ' For Sale in ' . $data['listing']->Location . ', Tanzania | Classified';
                    $header['Meta']->MetaDescr = $header['Meta']->BrowserTitle . $data['listing']->ShortDescr;
                } else {
                    $header['Meta']->BrowserTitle = $data['listing']->VehicleYear . ' ' . $data['listing']->Make . ' ' . $data['listing']->ModelOther . ' For Sale in ' . $data['listing']->Location . ', Tanzania | Classified';
                    $header['Meta']->MetaDescr = $header['Meta']->BrowserTitle . $data['listing']->ShortDescr;
                }

                break;

            case '4':

                $header['Meta']->BrowserTitle = $data['listing']->ListingTitle . ' For Sale in ' . $data['listing']->Location . ', Tanzania';
                $header['Meta']->MetaDescr = $header['Meta']->BrowserTitle . $data['listing']->ShortDescr;

                break;
				
				default:
					echo $data['listing']->ParentSectionID;
					break;
			}



     	$this->load->view('header', $header);
        $this->load->view('menu');
        if (isset($left_side))
            $this->load->view('left-sidetower', $left_side);
        else
            $this->load->view('left-sidetower');

        switch ($data['listing']->ParentSectionID) {

            case '1':
                $this->load->view('businesses-detail-page', $data);
                break;

            case '8':
                $this->load->view('job-detail-page', $data);
                break;

            case '55':
                $this->load->view('cars-detail-page', $data);
                break;

            case '5':
                $this->load->view('realestate-detail-page', $data);
                break; 

            case '4':
                $this->load->view('fsbo-detail-page', $data);
                break;

            case '59':
                $this->load->view('classifieds-landing-page', $data);
                break;

            default:
                # code...
                break;
        }
        $this->load->view('right-sidetower');
        $this->load->view('footer');
    }


    public function ELP($res) {
        $listingObj = $this->listingsmodel->getsinglelisting($this->input->get('ListingID'));

        $listing = $listingObj->row();

        $data['flier'] = LISTINGUPLOADEDDOCS . $listing->ExpandedListingPDF;

        $header['Meta']->BrowserTitle = $listing->ListingTitle . ' in ' . $listing->Location . ', Tanzania';
        $header['Meta']->MetaDescr = $header['Meta']->BrowserTitle . $listing->ShortDescr;


        $this->load->view('header', $header);
        $this->load->view('menu');
        $this->load->view('plain', $data);
        $this->load->view('footer');
    }

    public function TideDetail($pageObj) {

        if ($this->input->post('StartDate'))
            $startDate = date("Y-m-d", strtotime($this->input->post('StartDate'))) . ' 00:00:00';
        elseif ($this->input->get('StartDate'))
            $startDate = date("Y-m-d", strtotime($this->input->get('StartDate'))) . ' 00:00:00';
        else
            $startDate = date("Y-m-d") . ' 00:00:00';

        if ($this->input->post('EndDate'))
            $endDate = date("Y-m-d", strtotime($this->input->post('EndDate'))) . ' 23:59:00';
        elseif ($this->input->get('EndDate'))
            $endDate = date("Y-m-d", strtotime($this->input->get('EndDate'))) . ' 23:59:00';
        else
            $endDate = date("Y-m-d") . ' 23:59:00';

        $tidesQuery = "select CONVERT(t.tideDate,date) day, t.tideDate, t.High, t.Measurement,l.LunarDate,l.MoonTypeID,mt.descr, SunriseDate, SunsetDate
		from Tides t left join lunar l 
	ON CONVERT(t.TideDate,  date)=CONVERT(l.LunarDate ,  date)
	left join moontype mt  ON l.moonTypeID = mt.moonTypeID
	inner join sunrise s ON CONVERT(t.TideDate,date) = CONVERT(s.SunriseDate,date)
	inner join sunset st ON CONVERT(t.TideDate,date) = CONVERT(st.SunsetDate,date)
	where TideDate >= '" . $startDate . "'
	AND TideDate <= '" . $endDate . "'";

        $data['tidesObj'] = $this->db->query($tidesQuery);

        $highCheckerQuery = "select CONVERT(t.tideDate,date) day, COUNT( CONVERT( t.tideDate, DATE ) ) valuescount, t.tideDate, t.High, t.Measurement,l.LunarDate,l.MoonTypeID,mt.descr, SunriseDate, SunsetDate
		from Tides t left join lunar l 
	ON CONVERT(t.TideDate,  date)=CONVERT(l.LunarDate ,  date)
	left join moontype mt  ON l.moonTypeID = mt.moonTypeID
	inner join sunrise s ON CONVERT(t.TideDate,date) = CONVERT(s.SunriseDate,date)
	inner join sunset st ON CONVERT(t.TideDate,date) = CONVERT(st.SunsetDate,date)
	where TideDate >= '" . $startDate . "'
	AND TideDate <= '" . $endDate . "' group by day";

        $data['highChecker'] = $this->db->query($highCheckerQuery);


        $this->db->where('PageID', $pageObj->row()->PageID);
        $data['pageContent'] = $this->db->get('lh_pageparts')->row();
        $data['pageMeta'] = $pageObj->row();

        $header['Meta'] = $data['pageMeta'];
        $this->load->view('header', $header);
        $this->load->view('menu');
        if (isset($left_side))
            $this->load->view('left-sidetower', $left_side);
        else
            $this->load->view('left-sidetower');
        $this->load->view('tidesDetailPage', $data);
        $this->load->view('right-sidetower');
        $this->load->view('footer');
    }

    public function page($pageObj) {


        $this->db->where('PageID', $pageObj->row()->PageID);
        $data['pageContent'] = $this->db->get('lh_pageparts')->row();
        $data['pageMeta'] = $pageObj->row();

        $header['Meta'] = $data['pageMeta'];


        $this->load->view('header', $header);
        $this->load->view('menu');
        if (isset($left_side))
            $this->load->view('left-sidetower', $left_side);
        else
            $this->load->view('left-sidetower');
        //$this->load->view('page',$data);
        $this->load->view('category_detail');
        $this->load->view('right-sidetower');
        $this->load->view('footer');
    }

    public function search($SectionID) {
        $this->load->model('datafetcher');
        $data = $this->datafetcher->selectsearchforms($table = "search_forms", $SectionID);
        /** title for the search form if none set it empty */
        $data['heading'] = "Search  for ";

         if ($data['results']->num_rows() > 0) {

            $input_output = '';
            $validation_arr = array();

            foreach ($data['results']->result_array() as $value) {

                //check if input is more than one
                $val = array();


                $inputfield = '';

                if ($value['no_input'] > 0) {



                    /**
                     *  check if it is textarea, select dropdown etc
                     *  this is the place where all input types configured on a db and you want to appear in a generated form are configured
                     * form validation has done according to rickharrison library(for javascript Ci form validation)
                     * 
                     */
                    $fieldTobegenerated = '';

                    switch (strtolower($value['input_type'])) {

                        case"textarea";
                            if (!empty($value['input_tip'])) {
                                $tipsOnlabel = $value['input_tip'];
                            } else {
                                $tipsOnlabel = '';
                            }
                            /*                             * check if label has been modified */
                            if (empty($value['form_label'])) {
                                $label = $value['input_name'];
                            } else {
                                $label = $value['form_label'];
                            }


                            /*                             * **an array to feed the validation rules for this input* */
                            //fetch the validation rules as set by the user
                            $rulesin = '';
                            $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                            foreach ($rules_results->result_array() as $rules) {
                                $rulesin.=$rules['rule_name'] . '|';
                            }
                            $val['name'] = $value['fieldtypename'];
                            $val['display'] = $label;
                            $val['rules'] = $rulesin;

                            $fieldTobegenerated = form_label($label) . form_textarea(array('name' => $value['fieldtypename'], 'cols' => '25', 'rows' => '3')) . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                            break;
                        case"textinput":
                            if (!empty($value['input_tip'])) {
                                $tipsOnlabel = $value['input_tip'];
                            } else {
                                $tipsOnlabel = '';
                            }
                            /*                             * check if label has been modified */
                            if (empty($value['form_label'])) {
                                $label = $value['input_name'];
                            } else {
                                $label = $value['form_label'];
                            }


                            /*                             * **an array to feed the validation rules for this input* */
                            //fetch the validation rules as set by the user
                            $rulesin = '';
                            $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                            foreach ($rules_results->result_array() as $rules) {
                                $rulesin.=$rules['rule_name'] . '|';
                            }
                            $val['name'] = $value['fieldtypename'];
                            $val['display'] = $label;
                            $val['rules'] = $rulesin;

                            $fieldTobegenerated = form_label($label) . form_input(array('name' => $value['fieldtypename'], 'value' => '')) . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                            break;


                        case"dateinput":
                            if (!empty($value['input_tip'])) {
                                $tipsOnlabel = $value['input_tip'];
                            } else {
                                $tipsOnlabel = '';
                            }
                            /*                             * check if label has been modified */
                            if (empty($value['form_label'])) {
                                $label = $value['input_name'];
                            } else {
                                $label = $value['form_label'];
                            }


                            /*                             * **an array to feed the validation rules for this input* */
                            //fetch the validation rules as set by the user
                            $rulesin = '';
                            $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                            foreach ($rules_results->result_array() as $rules) {
                                $rulesin.=$rules['rule_name'] . '|';
                            }
                            $val['name'] = $value['fieldtypename'];
                            $val['display'] = $label;
                            $val['rules'] = $rulesin;

                            $fieldTobegenerated = form_label($label) . form_input(array('name' => $value['fieldtypename'], 'value' => '', 'class' => 'datepicker')) . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                            break;


                        case"date":
                            if (!empty($value['input_tip'])) {
                                $tipsOnlabel = $value['input_tip'];
                            } else {
                                $tipsOnlabel = '';
                            }
                            /*                             * check if label has been modified */
                            if (empty($value['form_label'])) {
                                $label = $value['input_name'];
                            } else {
                                $label = $value['form_label'];
                            }


                            /*                             * **an array to feed the validation rules for this input* */
                            //fetch the validation rules as set by the user
                            $rulesin = '';
                            $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                            foreach ($rules_results->result_array() as $rules) {
                                $rulesin.=$rules['rule_name'] . '|';
                            }
                            $val['name'] = $value['fieldtypename'];
                            $val['display'] = $label;
                            $val['rules'] = $rulesin;

                            $fieldTobegenerated = form_label($label) . form_input(array('name' => $value['fieldtypename'], 'value' => '', 'class' => 'datepicker')) . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                            break;


                        case "daterange":

                            if (!empty($value['input_tip'])) {
                                $tipsOnlabel = $value['input_tip'];
                            } else {
                                $tipsOnlabel = '';
                            }
                            /*                             * check if label has been modified */
                            if (empty($value['form_label'])) {
                                $label = $value['input_name'];
                            } else {
                                $label = $value['form_label'];
                            }


                            /*                             * **an array to feed the validation rules for this input* */
                            //fetch the validation rules as set by the user
                            $rulesin = '';
                            $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                            foreach ($rules_results->result_array() as $rules) {
                                $rulesin.=$rules['rule_name'] . '|';
                            }
                            $val['name'] = $value['fieldtypename'];
                            $val['display'] = $label;
                            $val['rules'] = $rulesin;

                            $fieldTobegenerated = form_label($label) . form_input(array('name' => 'startdate', 'value' => '', 'class' => 'datepicker')) . '-' . form_input(array('name' => 'enddate', 'value' => '', 'class' => 'datepicker')) . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                            break;

                        case "yearrange":

                            if (!empty($value['input_tip'])) {
                                $tipsOnlabel = $value['input_tip'];
                            } else {
                                $tipsOnlabel = '';
                            }
                            /*                             * check if label has been modified */
                            if (empty($value['form_label'])) {
                                $label = $value['input_name'];
                            } else {
                                $label = $value['form_label'];
                            }


                            /*                             * **an array to feed the validation rules for this input* */
                            //fetch the validation rules as set by the user
                            $rulesin = '';
                            $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                            foreach ($rules_results->result_array() as $rules) {
                                $rulesin.=$rules['rule_name'] . '|';
                            }
                            $val['name'] = $value['fieldtypename'];
                            $val['display'] = $label;
                            $val['rules'] = $rulesin;

                            $fieldTobegenerated = form_label($label) . form_input(array('name' => 'startdate', 'value' => '', 'class' => 'datepickeryear')) . '-' . form_input(array('name' => 'enddate', 'value' => '', 'class' => 'datepickeryear')) . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                            break;

                        case "pricerange":

                            if (!empty($value['input_tip'])) {
                                $tipsOnlabel = $value['input_tip'];
                            } else {
                                $tipsOnlabel = '';
                            }
                            /*                             * check if label has been modified */
                            if (empty($value['form_label'])) {
                                $label = $value['input_name'];
                            } else {
                                $label = $value['form_label'];
                            }


                            /*                             * **an array to feed the validation rules for this input* */
                            //fetch the validation rules as set by the user
                            $rulesin = '';
                            $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                            foreach ($rules_results->result_array() as $rules) {
                                $rulesin.=$rules['rule_name'] . '|';
                            }
                            $val['name'] = $value['fieldtypename'];
                            $val['display'] = $label;
                            $val['rules'] = $rulesin;

                            $fieldTobegenerated = form_label($label) . form_input(array('name' => 'minprice', 'value' => '', 'class' => '')) . '-' . form_input(array('name' => 'maxprice', 'value' => '', 'class' => '')) . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                            break;





                        case"checkbox":
                            if (!empty($value['input_tip'])) {
                                $tipsOnlabel = $value['input_tip'];
                            } else {
                                $tipsOnlabel = '';
                            }
                            /*                             * check if label has been modified */
                            if (empty($value['form_label'])) {
                                $label = $value['input_name'];
                            } else {
                                $label = $value['form_label'];
                            }


                            /*                             * **an array to feed the validation rules for this input* */
                            //fetch the validation rules as set by the user
                            $rulesin = '';
                            $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                            foreach ($rules_results->result_array() as $rules) {
                                $rulesin.=$rules['rule_name'] . '|';
                            }
                            $val['name'] = $value['fieldtypename'];
                            $val['display'] = $label;
                            $val['rules'] = $rulesin;

                            $fieldTobegenerated = form_label($label) . form_checkbox(array('name' => $value['fieldtypename'], 'value' => '')) . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                            break;

                        case"file":
                            if (!empty($value['input_tip'])) {
                                $tipsOnlabel = $value['input_tip'];
                            } else {
                                $tipsOnlabel = '';
                            }
                            /*                             * check if label has been modified */
                            if (empty($value['form_label'])) {
                                $label = $value['input_name'];
                            } else {
                                $label = $value['form_label'];
                            }


                            /*                             * **an array to feed the validation rules for this input* */
                            //fetch the validation rules as set by the user
                            $rulesin = '';
                            $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                            foreach ($rules_results->result_array() as $rules) {
                                $rulesin.=$rules['rule_name'] . '|';
                            }
                            $val['name'] = $value['fieldtypename'];
                            $val['display'] = $label;
                            $val['rules'] = $rulesin;

                            $fieldTobegenerated = form_label($label) . '<input type="file" name="' . $value['fieldtypename'] . '[]" class="images"/>' . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                            break;

                        case"password":
                            if (!empty($value['input_tip'])) {
                                $tipsOnlabel = $value['input_tip'];
                            } else {
                                $tipsOnlabel = '';
                            }
                            /*                             * check if label has been modified */
                            if (empty($value['form_label'])) {
                                $label = $value['input_name'];
                            } else {
                                $label = $value['form_label'];
                            }


                            /*                             * **an array to feed the validation rules for this input* */
                            //fetch the validation rules as set by the user
                            $rulesin = '';
                            $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                            foreach ($rules_results->result_array() as $rules) {
                                $rulesin.=$rules['rule_name'] . '|';
                            }
                            $val['name'] = $value['fieldtypename'];
                            $val['display'] = $label;
                            $val['rules'] = $rulesin;

                            $fieldTobegenerated = form_label($label) . form_password(array('name' => $value['fieldtypename'], 'value' => '')) . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                            break;





                        case"multiselect":
                            if (!empty($value['input_tip'])) {
                                $tipsOnlabel = $value['input_tip'];
                            } else {
                                $tipsOnlabel = '';
                            }
                            /*                             * check if label has been modified */
                            if (empty($value['form_label'])) {
                                $label = $value['input_name'];
                            } else {
                                $label = $value['form_label'];
                            }


                            /*                             * **an array to feed the validation rules for this input* */
                            //fetch the validation rules as set by the user
                            $rulesin = '';
                            $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                            foreach ($rules_results->result_array() as $rules) {
                                $rulesin.=$rules['rule_name'] . '|';
                            }
                            $val['name'] = $value['fieldtypename'];
                            $val['display'] = $label;
                            $val['rules'] = $rulesin;

                            $out = '';
                            $tabletesults = $this->datafetcher->selecTfromTable($value['draws_from']);

                            foreach ($tabletesults->result_array()as $rows) {

                                $out.='<option value="' . $rows[$value['column_id']] . '">' . $rows[$value['display_id']] . '</option>';
                            }



                            $fieldTobegenerated = form_label($label) . '<select  name="' . $value['fieldtypename'] . '[]" class="" multiple="multiple" size="4"><option value="" selected>--Select an option--</option>' . $out . '</select>' . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                            break;

                        //selecTfromTable($table)

                        case"select":
                            if (!empty($value['input_tip'])) {
                                $tipsOnlabel = $value['input_tip'];
                            } else {
                                $tipsOnlabel = '';
                            }
                            /*                             * check if label has been modified */
                            if (empty($value['form_label'])) {
                                $label = $value['input_name'];
                            } else {
                                $label = $value['form_label'];
                            }


                            /*                             * **an array to feed the validation rules for this input* */
                            //fetch the validation rules as set by the user
                            $rulesin = '';
                            $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                            foreach ($rules_results->result_array() as $rules) {
                                $rulesin.=$rules['rule_name'] . '|';
                            }
                            $val['name'] = $value['fieldtypename'];
                            $val['display'] = $label;
                            $val['rules'] = $rulesin;

                            $out = '';
                            $tabletesults = $this->datafetcher->selecTfromTable($table = $value['draws_from'], $table_two = $value['draws_from_table_two'], $column_id_one = $value['column_id'], $column_id_two = $value['column_id_two'], $sec = $value['section'], $reference = $value['referenceid'], $title = $value['display_id']);

                            foreach ($tabletesults->result_array()as $rows) {

                                $out.='<option value="' . $rows[$value['column_id']] . '">' . $rows[$value['display_id']] . '</option>';
                            }



                            $fieldTobegenerated = form_label($label) . '<select name="' . $value['fieldtypename'] . '" class=""><option value="" selected>--Select an option--</option>' . $out . '</select>' . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                            break;

                        case "repeat":

                            if (empty($value['input_tip'])) {
                                $tipsOnlabel = '';
                            } else {
                                $tipsOnlabel = $value['input_tip'];
                            }
                            $out = '';
                            $repeatselectrtesults = $this->datafetcher->getAllrepeats();

                            foreach ($repeatselectrtesults->result_array()as $rows) {

                                $out.='<option value="' . $rows['repeat_id'] . '">' . $rows['events'] . '</option>';
                            }
                            /*                             * check if label has been modified */
                            if (empty($value['form_label'])) {
                                $label = $value['input_name'];
                            } else {
                                $label = $value['form_label'];
                            }

                            $fieldTobegenerated = form_label($label) . '<select name="" class="events"><option value="">Select</option>' . $out . '</select><div class="events_display"></div>';
                            break;
                        case "price":
                            //$fieldTobegenerated='<table border="0"><tr><td></td><td></td></tr></table>';
                            if (!empty($value['input_tip'])) {
                                $tipsOnlabel = $value['input_tip'];
                            } else {
                                $tipsOnlabel = '';
                            }
                            /*                             * check if label has been modified */
                            if (empty($value['form_label'])) {
                                $label = $value['input_name'];
                            } else {
                                $label = $value['form_label'];
                            }


                            /*                             * **an array to feed the validation rules for this input* */
                            //fetch the validation rules as set by the user
                            $rulesin = '';
                            $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                            foreach ($rules_results->result_array() as $rules) {
                                $rulesin.=$rules['rule_name'] . '|';
                            }
                            $val['name'] = $value['fieldtypename'];
                            $val['display'] = $label;
                            $val['rules'] = $rulesin;

                            $fieldTobegenerated = form_label($label) . '<table border="0" class="price"><tr>
                        <td>' . form_input(array('name' => $value['fieldtypename'], 'value' => '', 'class' => 'priceVal')) . '</td>
                        <td>' . '<select name="price" class="pricetd"><option value="usd">$USD</option><option value="tzs">TZS</option></select>' . '</td>
                        </tr></table>' . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                            break;

                        case"time";
                            if (!empty($value['input_tip'])) {
                                $tipsOnlabel = $value['input_tip'];
                            } else {
                                $tipsOnlabel = '';
                            }
                            /*                             * check if label has been modified */
                            if (empty($value['form_label'])) {
                                $label = $value['input_name'];
                            } else {
                                $label = $value['form_label'];
                            }


                            /*                             * **an array to feed the validation rules for this input* */
                            //fetch the validation rules as set by the user
                            $rulesin = '';
                            $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                            foreach ($rules_results->result_array() as $rules) {
                                $rulesin.=$rules['rule_name'] . '|';
                            }
                            $val['name'] = $value['fieldtypename'];
                            $val['display'] = $label;
                            $val['rules'] = $rulesin;


                            $out = '<option value="12.00 AM">' . '12.00 AM' . '</option>
                          <option value="12.30 AM"> 12.30 AM </option>
                          <option value="1.00 AM"> 1.00 AM </option>
                          <option value="1.30 AM"> 1.30 AM </option>
                          <option value="2.00 AM"> 2.00 AM </option>
                          <option value="2.30 AM"> 2.30 AM </option>
                          <option value="3.00 AM"> 3.00 AM </option>
                          <option value="3.30 AM"> 3.30 AM </option>
                          <option value="4.00 AM"> 4.00 AM </option>
                          <option value="4.30 AM"> 4.30 AM </option>
                          <option value="5.00 AM"> 5.00 AM </option>
                          <option value="5.30 AM"> 5.30 AM </option>
                          <option value="6.00 AM"> 6.00 AM </option>
                          <option value="6.30 AM"> 6.30 AM </option>
                          <option value="7.00 AM"> 7.00 AM </option>
                          <option value="7.30 AM"> 7.30 AM </option>
                          <option value="8.00 AM"> 8.00 AM </option>
                          <option value="8.30 AM"> 8.30 AM </option>
                          <option value="9.00 AM"> 9.00 AM </option>
                          <option value="9.30 AM"> 9.30 AM </option>
                          <option value="10.00 AM"> 10.00 AM </option>
                          <option value="10.30 AM"> 10.30 AM </option>
                          <option value="11.00 AM"> 11.00 AM </option>
                          <option value="11.30 AM"> 11.30 AM </option>
                          
                          <option value="12.00 PM"> 12.00 PM </option>
                          <option value="12.30 PM"> 12.30 PM </option>
                          <option value="1.00 PM"> 1.00 PM </option>
                          <option value="1.30 PM"> 1.30 PM </option>
                          <option value="2.00 PM"> 2.00 PM </option>
                          <option value="2.30 PM"> 2.30 PM </option>
                          <option value="3.00 PM"> 3.00 PM </option>
                          <option value="3.30 PM"> 3.30 PM </option>
                          <option value="4.00 PM"> 4.00 PM </option>
                          <option value="4.30 PM"> 4.30 PM </option>
                          <option value="5.00 PM"> 5.00 PM </option>
                          <option value="5.30 PM"> 5.30 PM </option>
                          <option value="6.00 PM"> 6.00 PM </option>
                          <option value="6.30 PM"> 6.30 PM </option>
                          <option value="7.00 PM"> 7.00 PM </option>
                          <option value="7.30 PM"> 7.30 PM </option>
                          <option value="8.00 PM"> 8.00 PM </option>
                          <option value="8.30 PM"> 8.30 PM </option>
                          <option value="9.00 PM"> 9.00 PM </option>
                          <option value="9.30 PM"> 9.30 PM </option>
                          <option value="10.00 PM"> 10.00 PM </option>
                          <option value="11.00 PM"> 11.00 PM </option>
                          <option value="11.30 PM"> 11.30 PM </option>
                          
                           ';


                            $fieldTobegenerated = form_label($label) . '<select name="' . $value['fieldtypename'] . '" class=""><option value="" selected>--Select an option--</option>' . $out . '</select>' . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                            break;


                        default:
                            break;
                    }

///loop to get the exactly number of inputs required

                    for ($a = 0; $a < $value['no_input']; $a++) {

                        $inputfield.='<li>' . $fieldTobegenerated . '</li>';
                    }
                } else {

                    $inputfield = '';
                }


                $input_output.=$inputfield;


                $validation_arr[] = $val;
            }
            if (isset($heading) && isset($category)) {
                $heading = $heading;
                $category = $category;
            } else {
                $heading = '';
                $category = '';
            }
            echo form_open_multipart('formInsertion/formsdataprocessor/', $data = array('name' => 'myForm', 'id' => 'myform', 'class' => 'myform', 'onsubmit' => "")) . '<h1>' . $heading . $category . '</h1>' . '<!--.javascript form validation.-->
                    <div class="error_box" id ="error_box"></div><div id="success_box"></div>' 
                    . form_fieldset() . '<ul>' 
                    . form_hidden($name = "cat", $id = '') .
                    $input_output . '<li>' . form_label() . 
                    form_submit(array('name' => 'submit', 'value' => 'submit', 'class' => 'submit')) .
                    '</li></ul>' .
                    form_fieldset_close() . 
                    form_close();
        } else {
            echo 'no form data';
        }
        
        
    }

    /*     * controller function for interpret any form */

    public function form() {


       

        //json encoding for the form validations attributes;

        $array_final = json_encode($validation_arr);
        $array_final = preg_replace('/"([a-zA-Z]+[a-zA-Z0-9]*)":/', '$1:', $array_final);
        ?>
        <!--.form validation script goes here.-->
        <script type="text/javascript">

                 
            var validator = new FormValidator('myForm',<?php print_r($array_final); ?>, function(errors, event) {
                
                if (errors.length > 0) {
                               
                    // Show the errors
                    var errorString = '';
                
                    for (var i = 0, errorLength = errors.length; i < errorLength; i++) {
                        errorString += errors[i].message + '<br />';
                    }
                
                    error_box.innerHTML = errorString;
             
                }
                
                  
            });
            
         
        </script>
        <?php
    }

    function missing() {
        $db1['hostname'] = 'zoom';
        $db1['username'] = 'sa';
        $db1['password'] = '5tokwerue';
        $db1['database'] = 'ZoomTanzania';
        $db1['dbdriver'] = 'odbc';
        $db1['dbprefix'] = '';
        $db1['pconnect'] = TRUE;
        $db1['db_debug'] = TRUE;
        $db1['cache_on'] = FALSE;
        $db1['cachedir'] = '';
        $db1['char_set'] = 'utf8';
        $db1['dbcollat'] = 'utf8_general_ci';
        $db1['swap_pre'] = '';
        $db1['autoinit'] = TRUE;
        $db1['stricton'] = FALSE;

        $DB1 = $this->load->database($db1, TRUE);


        $db2['hostname'] = 'localhost';
        $db2['username'] = 'root';
        $db2['password'] = '';
        $db2['database'] = 'zoomtanzania';
        $db2['dbdriver'] = 'mysql';
        $db2['dbprefix'] = '';
        $db2['pconnect'] = TRUE;
        $db2['db_debug'] = TRUE;
        $db2['cache_on'] = FALSE;
        $db2['cachedir'] = '';
        $db2['char_set'] = 'utf8';
        $db2['dbcollat'] = 'utf8_general_ci';
        $db2['swap_pre'] = '';
        $db2['autoinit'] = TRUE;
        $db2['stricton'] = FALSE;
        $DB2 = $this->load->database($db2, TRUE);

        $table = 'Listings';

        $max = 49000;
        $min = 46999;

        $DB2->where('ListingID <', $max);
        $DB2->where('ListingID >', $min);
        $DB2->select('ListingID');
        $listings = $DB2->get($table);

//echo $listings->num_rows();

        $data = array();
        foreach ($listings->result() as $listing) {
            $miss[] = $listing->ListingID;
        }

        $DB1->where('ListingID <', $max);
        $DB1->where('ListingID >', $min);
        $DB1->where_not_in('ListingID', $miss);
        $missing = $DB1->get($table);

        echo $missing->num_rows();

        $fields = $DB2->list_fields($table);

        foreach ($missing->result() as $listing) {

            foreach ($fields as $field) {

                if ($field == 'PaymentConfirmationEmailDateSent')
                    $field = 'PaymentConfirmationSent';
// //die();
                $data[$field] = $listing->$field;
            }


            $datas[] = $data;
        }

        print_r($datas);

// $DB2->insert_batch($table,$datas);
//print_r($miss);
//echo $listings->num_rows();
    }

    function test() {


        $db1['hostname'] = 'zoom';
        $db1['username'] = 'sa';
        $db1['password'] = '5tokwerue';
        $db1['database'] = 'ZoomTanzania';
        $db1['dbdriver'] = 'odbc';
        $db1['dbprefix'] = '';
        $db1['pconnect'] = TRUE;
        $db1['db_debug'] = TRUE;
        $db1['cache_on'] = FALSE;
        $db1['cachedir'] = '';
        $db1['char_set'] = 'utf8';
        $db1['dbcollat'] = 'utf8_general_ci';
        $db1['swap_pre'] = '';
        $db1['autoinit'] = TRUE;
        $db1['stricton'] = FALSE;

        $DB1 = $this->load->database($db1, TRUE);


        $db2['hostname'] = 'localhost';
        $db2['username'] = 'root';
        $db2['password'] = '';
        $db2['database'] = 'zoomtanzania';
        $db2['dbdriver'] = 'mysql';
        $db2['dbprefix'] = '';
        $db2['pconnect'] = TRUE;
        $db2['db_debug'] = TRUE;
        $db2['cache_on'] = FALSE;
        $db2['cachedir'] = '';
        $db2['char_set'] = 'utf8';
        $db2['dbcollat'] = 'utf8_general_ci';
        $db2['swap_pre'] = '';
        $db2['autoinit'] = TRUE;
        $db2['stricton'] = FALSE;
        $DB2 = $this->load->database($db2, TRUE);


        $max_min = $DB2->get('max_min');

        $max = $max_min->row()->max;
        $min = $max_min->row()->min;

        $update['min'] = $max - 1;
        $update['max'] = $max + 200;




//1899; 2000

        $table = 'ListingResultsPageImpressions';
        $DB1->where('ListingID <', $max);
        $DB1->where('ListingID >', $min);
//$DB1->select('DueDate');
// $DB1->where('OrderID', 904);

        $listings = $DB1->get($table);
        echo $listings->num_rows();

//echo gettype($listings->row()->DueDate);
//$filds=$listings->result_array();
//print_r($filds);
//	echo	$listings->row()->PaymentConfirmationEmailDateSent;

        $data = array();
        $datas = array();

        $fields = $DB2->list_fields($table);

        foreach ($listings->result() as $listing) {

            foreach ($fields as $field) {

                if ($field == 'PaymentConfirmationEmailDateSent')
                    $field = 'PaymentConfirmationSent';
// //die();
                $data[$field] = $listing->$field;
            }


            $datas[] = $data;
        }

//print_r($datas);

        if ($DB2->insert_batch($table, $datas))
            $DB2->update('max_min', $update);
    }

    function ttest($pageURL) {
        $this->db->where('ListingTypeID', 1);
        $this->db->where('upper(URLSafeTitle)', strtoupper(str_replace("-", "", $pageURL)), true);
        $listing = $this->db->get('listingsview');

        if ($listing->num_rows() == 0) {
            $this->db->where('upper(URLSafeTitleDashed)', strtoupper($pageURL), true);
            $section = $listing = $this->db->get('sections');


            if ($section->num_rows() == 0) {
                $this->db->where('upper(URLSafeTitle)', strtoupper(str_replace("-", "", $pageURL)), true);
                $category = $this->db->get('categories');

                if ($category->num_rows() == 0) {

                    $this->db->where('MembersOnly', 0);
                    $this->db->where('upper(Name)', strtoupper($pageURL), true);
                    $category = $this->db->get('lh_pages_live');
                }
            }
        }



        echo $this->db->last_query();
    }

    public function listings() {
        $this->Common->is_logged_in();
    }

    public function post_a_listing($type = 0) {
        $this->Common->is_logged_in();
    }

    public function save_listing($type = 0) {
        $this->Common->is_logged_in();
    }

    public function edit_listing($listing_id) {
        $this->Common->is_logged_in();
    }

    public function test_login() {
//$this->ion_auth->login();
        $identity = 'admin@swahilimusicnotes.com';
        $password = '12GrownUp;';
        $remember = false; // remember the user
        if ($this->ion_auth->login($identity, $password, $remember))
            echo "Hehehehe";
        else
            echo $this->ion_auth->errors();

//echo $this->db->last_query();
    }

}

/* End of file controllername.php */
/* Location: ./application/controllers/controllername.php */