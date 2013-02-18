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
		
	}

	
}