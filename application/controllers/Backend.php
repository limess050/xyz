<?php

/**
* 
*/
class Backend extends CI_Controller
{
	
	function index()
	{
		//if ($this->ion_auth->logged_in())
			$this->_crud((object)array('output' => '' , 'js_files' => array() , 'css_files' => array()));
		//else
		//	redirect('login');
	}

	function making_urls()
	{
		$sections = $this->db->get('sections');
		foreach($sections->result() as $section)
		{
			$data['SectionID'] = $section->SectionID;
			$data['URLSafeTitleDashed'] = $this->make_url_from_title(str_replace('&', 'And', $section->Title),'sections','SectionID',$section->SectionID);
			$datas[]=$data;
		}

		$this->db->update_batch('sections',$datas,'SectionID');
	}

	function _crud($output = null)
	{
		//if ($this->ion_auth->logged_in())
			$this->load->view('backend/crud.php',$output);
		//else
			//redirect('login');
	}

	function __construct()
	{
		parent::__construct();
		$this->load->library('grocery_CRUD');	
		$this->load->model('backendmodel');
				
		//$this->load->library('image_CRUD');
	}



	function make_url_from_title($title,$table,$pk,$id)
	{
		
		$url = strtolower(url_title($title));
		

		$this->db->where('URLSafeTitleDashed',$url);
		$obj=$this->db->get($table);

		if($obj->num_rows() > 0)
		{
			$this->db->where($pk,$id);
			$this->db->where('URLSafeTitleDashed',$url);
			$obj=$this->db->get($table);
			
			if( $obj->num_rows() == 0 )
				$url = $this->make_url_from_title($url . '-' . $url,$table,$pk,$id);
		
		}
	
		return $url;
		
	}
	


	function sections()
	{

		$this->grocery_crud->set_relation('ParentSectionID','sections','Title');
		$this->backendmodel->crud('sections');

	}

	function categories()
	{
		$this->grocery_crud->set_field_upload('ImageFile','images/categories');
		$this->grocery_crud->set_relation('ParentSectionID','sections','Title');

		$this->grocery_crud->set_relation('SectionID','sections','Title');

		$this->backendmodel->crud('categories');

	}

	function ngotypes()
	{
		$this->backendmodel->crud('ngotypes');
	}


	function autoemails()
	{
		$this->grocery_crud->set_relation('AutoEmailTypeID','AutoEmailTypes','Title');
		$this->backendmodel->crud('autoemails');
		
	}


	function badlistingreasons()
	{
		$this->backendmodel->crud('badlistingreasons');	
	}


	function parks()
	{
		$this->backendmodel->crud('parks');	
	}

	function areas()
	{
		$this->backendmodel->crud('areas');	
	}

	function listingtypes()
	{
		$this->backendmodel->crud('listingtypes');	
	}

	function cuisines()
	{
		$this->backendmodel->crud('cuisines');	
	}

	function locations()
	{
		$this->backendmodel->crud('locations');	
	}


	function amenities()
	{
		$this->backendmodel->crud('amenities');	
	}

	function relevantlinks()
	{
		$this->backendmodel->crud('relevantlinks');	
	}


	function listings($status)
	{
		$this->grocery_crud->where('Reviewed',$status);
		$this->backendmodel->crud('listings');	
	}

	function main_menu_items()
	{

			$this->grocery_crud->set_relation('SectionID','sections','Title');
			//$this->grocery_crud->set_relation('ParentSectionID','sections','Title');
			$this->backendmodel->crud('main_menu_items');	

	}
}