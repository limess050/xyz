<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed'); 
/**
* 
*/
class Users extends CI_Controller
{
	
	function __construct()
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
		if($this->ion_auth->logout())
			$this->login();
	}

	function update()
	{

	}

	function update_details($UserID)
	{
		
		$this->load->library('form_validation');

		// $this->form_validation->set_rules('password', 'Password', 'required|matches[passconf]');
		// $this->form_validation->set_rules('passconf', 'Password Confirmation', 'required');
		// $this->form_validation->set_rules('email', 'Email', 'required|valid_email|is_unique[lh_users.email]');
		$this->form_validation->set_rules('BirthYearID', 'Birth Year', 'required');
		$this->form_validation->set_rules('BirthMonthID', 'Birth Month', 'required');
		$this->form_validation->set_rules('SelfIdentifiedTypeID', 'How you describe yourself', 'required');
		$this->form_validation->set_rules('EducationLevelID', 'Education Level', 'required');
		$this->form_validation->set_rules('FirstName', 'First Name', 'required');
		$this->form_validation->set_rules('LastName', 'Last Name', 'required');

		if ($this->form_validation->run() == TRUE)
		{
			$date = new DateTime($this->input->post('BirthYearID') . '/' . $this->input->post('BirthMonthID') . '/01'  );
			$AgeGroupID = $this->calculate_agegroup($date);

			$additional = array(
				'FirstName'=> $this->input->post('FirstName'),
				'LastName'=> $this->input->post('LastName'),
				'AreaID' => $this->input->post('AreaID'),
				'BirthYearID' => $this->input->post('BirthYearID'),
				'BirthMonthID' => $this->input->post('BirthMonthID'),
				'SelfIdentifiedTypeID' => $this->input->post('SelfIdentifiedTypeID'),
				'EducationLevelID' => $this->input->post('EducationLevelID'),
				'GenderID'=>$this->input->post('GenderID'),
				'AgeGroupID' => $AgeGroupID
				);

			$this->ion_auth->update($UserID, $additional);
		}
		else
		{
			$this->update();
		}
	}

	function createaccount()
	{

	}


	function calculate_agegroup($date)
	{

		$now = new DateTime();
		$interval = $now->diff($date);
		$age = $interval->y;

		switch ($age) {
			case ($age <= 21) :
				$AgeGroupID = 1;
				break;			
			case ($age >= 21 and $age <=30) :
				$AgeGroupID = 2;
				break;

			case ($age >= 31 and $age <=44) :
				$AgeGroupID = 3;
				break;

			case ($age >= 45 and $age <=60) :
				$AgeGroupID = 4;
				break;

			case ($age > 60) :
				$AgeGroupID = 5;
				break;
			
			default:
				$AgeGroupID = 0;
				break;
		}

		return $AgeGroupID;
	}

	function registeruser()
	{

		$this->load->library('form_validation');

		$this->form_validation->set_rules('password', 'Password', 'required|matches[passconf]');
		$this->form_validation->set_rules('passconf', 'Password Confirmation', 'required');
		$this->form_validation->set_rules('email', 'Email', 'required|valid_email|is_unique[lh_users.email]');
		$this->form_validation->set_rules('BirthYearID', 'Birth Year', 'required');
		$this->form_validation->set_rules('BirthMonthID', 'Birth Month', 'required');
		$this->form_validation->set_rules('SelfIdentifiedTypeID', 'How you describe yourself', 'required');
		$this->form_validation->set_rules('EducationLevelID', 'Education Level', 'required');
		$this->form_validation->set_rules('FirstName', 'First Name', 'required');
		$this->form_validation->set_rules('LastName', 'Last Name', 'required');

		if ($this->form_validation->run() == TRUE)
		{

			$date = new DateTime($this->input->post('BirthYearID') . '/' . $this->input->post('BirthMonthID') . '/01'  );
			$AgeGroupID = $this->calculate_agegroup($date);
			

			$username = $this->input->post('email');
			$password = $this->input->post('password');
			$email = $this->input->post('email');
			$additional = array(
				'FirstName'=> $this->input->post('FirstName'),
				'LastName'=> $this->input->post('LastName'),
				'AreaID' => $this->input->post('AreaID'),
				'BirthYearID' => $this->input->post('BirthYearID'),
				'BirthMonthID' => $this->input->post('BirthMonthID'),
				'SelfIdentifiedTypeID' => $this->input->post('SelfIdentifiedTypeID'),
				'EducationLevelID' => $this->input->post('EducationLevelID'),
				'GenderID'=>$this->input->post('GenderID'),
				'AgeGroupID' => $AgeGroupID
				);

			if($this->ion_auth->register($username,$password,$email,$additional))
				echo $this->ion_auth->messages();
			else
				echo $this->ion_auth->errors();
		}
		
		else
		{
			$this->createaccount();
		}	
	}

	function confirmaccount()
	{

	}

	function forgotpassword()
	{

	}

	function send_password()
	{

		$this->load->library('form_validation');
		$this->form_validation->set_rules('email', 'Email', 'required|valid_email');

		if ($this->form_validation->run() == TRUE)
		{
//			$this->db->where('UPPER(username)', strtoupper($this->input->post('email')),true);

			$this->db->where('UPPER(username)', strtoupper('terences@ZoomTanzania.com'),true);
			$user=$this->db->get('lh_users');

			if($user->num_rows() > 0)
			{

				$password = $user->row()->Password;

				$this->load->library('email');
				
				$this->email->from('inquiry@zoomtanzania.com', 'ZoomTanzania.com');
				$this->email->to($this->input->post('email'));
		
				$this->db->where('AutoEmailID', 18);
				$emailObj = $this->db->get('AutoEmails');

				$subject = $emailObj->row()->SubjectLine;
				$message = $emailObj->row()->Body;

				$search = array(
				     '%password%'
				);
				$replace = array(
				     $password
				);
				$message = str_replace($search, $replace, $message);

				//echo $message;

				$this->email->subject('subject');
				$this->email->message('message');
				
				//$this->email->send();
				
				//echo $this->email->print_debugger();
			}

			else
			{
				echo "That email address is not registered";
			}
		}

		else
		{
			$this->forgotpassword();
		}

	}


	function getaccountlistings()
	{

		//$loggedInUser = $this->ion_auth->user();

		//print_r($this->session->all_userdata());
		$UserID = $this->session->userdata('user_id');

		$accountListingsQuery = "Select L.ListingID, L.LinkID, L.Inprogress,
		IFNull(L.ListingFee,0) as ListingFee, IFNull(L.ExpandedListingFee,0) as ExpandedFee, 
		L.ListingTitle, L.ExpirationDate, L.ListingTypeID, L.Reviewed,
		L.Make as MakeOther, L.Model as ModelOther, L.VehicleYear, L.ExpandedListingPDF, L.ExpandedListingHTML,
		CASE WHEN L.PaymentStatusID in (2,3) and L.HasExpandedListing=1 and L.ExpirationDateELP >= '2012-01-01 00:00:00' Then 1 Else 0 END as HasExpandedListing,
		O.PaymentStatusID, O.OrderID,
		PSt.Title as PaymentStatus,
		PS.Title as ParentSection, PS.ParentSectionID, S.SectionID, S.Title as Section,  
		(Select C.CategoryID From ListingCategories LC Inner Join Categories C on LC.CategoryID=C.CategoryID Where LC.ListingID=L.ListingID Order By C.OrderNum Limit 1) as CategoryID, (Select C.Title From ListingCategories LC Inner Join Categories C on LC.CategoryID=C.CategoryID Where LC.ListingID=L.ListingID Order By C.OrderNum Limit 1) as  Category,
		LT.TermExpiration,
		M.Title as Make, 
		IFNull(L.ListingFee,0) + IFNull(L.ExpandedListingFee,0) as TotalFee
		From ListingsView L
		Left Outer Join Orders O on L.OrderID=O.OrderID
		Left Outer Join PaymentStatuses PSt on O.PaymentStatusID=PSt.PaymentStatusID
		Inner Join ListingParentSections LPS on L.ListingID=LPS.ListingID
		Inner Join ParentSectionsView PS On LPS.ParentSectionID=PS.ParentSectionID
		Inner Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
		Left Outer Join ListingSections LS on L.ListingID=LS.ListingID
		Left Outer Join SectionsView S on LS.SectionID=S.SectionID
		Left Outer Join Makes M on L.MakeID=M.MakeID
		Where L.DeletedAfterSubmitted=0 
		and  O.UserID= " . $UserID . "
		Order By PS.OrderNum, O.OrderDate desc, L.ListingID";

		$accountListingsObj = $this->db->query($accountListingsQuery);

		return $accountListingsObj;

		//echo $accountListingsObj->num_rows();

	}

	function myaccount()
	{

		$ListingStatuses = array('Pending Review','Live');
		$accountListingsObj=$this->getaccountlistings();

		if($accountListingsObj->num_rows() > 0)
		{
			echo "<table border='1'>";
			echo "<tr><td>Listing Title</td><td>Site Location</td><td>Status</td><td>Expires On</td><td>Payment History</td><td>Renew</td></tr>";
			foreach($accountListingsObj->result() as $Listing)
			{
				echo "<tr>";
					echo "<td>" . $Listing->ListingTitle . "</td>";
					echo "<td></td>";
					echo "<td>" . $ListingStatuses[$Listing->Reviewed] . "</td>";
					echo "<td>" . date('d/m/Y',strtotime($Listing->ExpirationDate)) . "</td>";
					echo "<td></td>";
					echo "<td><input type='checkbox' id='ListingID" . $Listing->ListingID . "' class='ListingID' name='ListingIDs' value=" . $Listing->ListingID . "></td>";
				echo "</tr>";

			}
			echo "</table>";
		}
		
	}
}