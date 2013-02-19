<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Listings extends CI_Controller {

	public function __construct()
	{
		parent::__construct();

	}

	public function index()
	{
		$this->db->where('ParentSectionID', 1);
		$this->db->order_by('title');
		$data['sections'] = $this->db->get('sections');

		//echo $this->session->userdata('current_url');
		$this->load->view('header');
		$this->load->view('menu',$data);
		$this->load->view('home');
		$this->load->view('footer');
	}

	public function listingdetail($listing_id)
	{

	}

	public function listings()
	{
		$this->Common->is_logged_in();
	}

	public function post_a_listing($type=0)
	{
		$this->Common->is_logged_in();
	}

	public function save_listing($type=0)
	{
		$this->Common->is_logged_in();
	}

	public function edit_listing($listing_id)
	{
		$this->Common->is_logged_in();
	}

}

/* End of file controllername.php */
/* Location: ./application/controllers/controllername.php */