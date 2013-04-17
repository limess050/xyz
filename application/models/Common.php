<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed'); 
/**
* 
*/
class Common extends CI_Model
{


	function __construct()
	{
		parent::__construct();
	}

	function is_logged_in()
	{

		$array = array(
		 	'login_redirect_url'=>current_url()
		 );
		 
	 	$this->session->set_userdata( $array ); 
	 	//echo $this->session->userdata('login_redirect_url');
		if (!$this->ion_auth->logged_in())
		 	redirect('alerts');
	}



	function menu()
	{
		

		$this->db->group_by('CategoryID');
		$this->db->select('CategoryID, count(ListingID) as catCount',FALSE);
		$categoryListingsCount=$this->db->get('ListingCategories');

		foreach($categoryListingsCount->result() as $categoryListingCount)
		{
			$categoryListingsCountArray[$categoryListingCount->CategoryID] = $categoryListingCount->catCount;
		}


		$this->db->where('active', 1);
		$this->db->order_by('Title');
		$sections = $this->db->get('sections');

		foreach ($sections->result() as $section) {
			if(!$section->ParentSectionID)
				$mainMenu[$section->SectionID] = $section->URLSafeTitleDashed;

			$sections_array[$section->ParentSectionID][$section->URLSafeTitleDashed] = $section->Title;
		}


		$this->db->order_by('Title');
		$this->db->where('active', 1);
		$categories = $this->db->get('categories');

		foreach ($categories->result() as $category) {

			if(isset($categoryListingsCountArray[$category->CategoryID]))
				$count =  $categoryListingsCountArray[$category->CategoryID];
			else $count = 0;

			if(!$category->ParentSectionID)

				$category_array[$category->SectionID][$category->URLSafeTitleDashed] = $category->Title . ' (' . $count . ')';
			else
				$category_array[$category->ParentSectionID][$category->URLSafeTitleDashed] = $category->Title . ' (' . $count . ')';

		}
		// echo "<pre>";
		// print_r($mainMenu);
		// echo "</pre>";

		$this->db->order_by('OrderNum');
		$main=$this->db->get('main_menu_items');

		//print_r($category_array);


		$menu = '<div class="menubox" align="center"><div><nav id="cbp-hrmenu" class="cbp-hrmenu"><ul>';
		$menu .= '<li><a href="' . base_url() . '">HOME</a></li>';

		$item_num = 0;
		foreach ($main->result() as $item) {

			if($item->DrawsFrom != '')
			{
				$menu .= '<li><a href="' . $mainMenu[$item->SectionID] . '" class="drop">' . $item->MenuTitle . '</a>';


    			
				if($item->DrawsFrom == 'sections')
					$sub_menu_array = $sections_array;
				else if($item->DrawsFrom == 'categories')
					$sub_menu_array = $category_array;


				$countChecker=$flag =1;
				$count = count($sub_menu_array[$item->SectionID]); //total sub menu number of rows
				

				$col_complete = ceil($count/2); //We'll have 3 columns

				//echo $col_complete . '<br>';

				$menu .= '<div class="cbp-hrsub"><div class="cbp-hrsub-inner">';
				foreach($sub_menu_array[$item->SectionID] as $url => $sub_menu)
				{


    				if($flag==1)
						$menu .= '<div><ul>';//Start Col of Menu Items


					$menu .= '<li><a href="' . $url . ' ">' . $sub_menu . '</a></li>';

					if($flag == $col_complete)
					{
						$menu .= '</ul></div>'; // If col is full, close col 
						$flag = 1;
					}

					else if($countChecker == $count)
    					$menu .= '</ul></div>';
    				else
    				{
						$flag++;
						$countChecker++;
					}
				}

				$menu .= '</div></li>';

			}
			else
				$menu .= '<li><a href="' . $item->URLSafeTitleDashed . '">' . $item->MenuTitle . '</a></li>';

			$item_num++;
		}

		$menu .= '</ul></nav></div></div>';

		echo $menu;
	}

	
}