<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class BackendModel extends CI_Model {

	function __construct()
	{
		parent::__construct();
		$this->load->library('grocery_CRUD');	
	}

	function index()
	{
		//if ($this->ion_auth->logged_in())
			$this->_crud((object)array('output' => '' , 'js_files' => array() , 'css_files' => array()));
		//else
		//	redirect('login');
	}

	function _crud($output = null)
	{
		//if ($this->ion_auth->logged_in())
			$this->load->view('backend/crud.php',$output);
		//else
			//redirect('login');
	}


	function crud($table_name)
	{
		try {
			$this->grocery_crud->set_table($table_name);
			
			$output = $this->grocery_crud->render();

			$this->_crud($output);
			}catch(Exception $e){
				show_error($e->getMessage().' --- '.$e->getTraceAsString());
		}
	}


}

/* End of file backend.php */
/* Location: ./application/models/backend.php */