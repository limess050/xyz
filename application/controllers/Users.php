<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed'); 
/**
* 
*/
class Users extends CI_Controllers
{
	
	function __construct(argument)
	{
		parent::__construct();
	}

	function login()
	{

		
	}

	function login_user()
	{
		if(!$this->ion_auth->login($identity, $password, $remember))
			$this->login();
		else
		{
			
		}
	}

	function logout()
	{
		$this->ion_auth->logout();
	}

	function update_details()
	{

	}

	function register()
	{

	}

	function confirm_account()
	{

	}

	function forgot_password()
	{

	}

	function reset_password()
	{

	}
}