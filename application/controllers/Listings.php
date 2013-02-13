<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Listings extends CI_Controller {

	public function __construct()
	{
		parent::__construct();

	}

	public function index()
	{
		//echo $this->session->userdata('current_url');
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