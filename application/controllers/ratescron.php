<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Ratescron extends CI_Controller {

	public function __construct()
	{
		parent::__construct();

	}

	function updateexchangerates()
	{
		echo "heheh";
		$rate = array();
		$rates = array();

		$from = array('USD','EUR','GBP','ZAR','KES');
		$to = 'TZS';
		$ch = curl_init();
		$orderNum=0;
		foreach($from as $currency)
		{
			// $url = 'http://finance.yahoo.com/d/quotes.csv?f=l1ab&s='.$currency.$to.'=X';
			// $handle = fopen($url, 'r');
			 
			// if ($handle) {
			//     $result = fgetcsv($handle);
			//     fclose($handle);
			// }

			$url = "http://download.finance.yahoo.com/d/quotes.csv?f=l1ab&e=.csv&s=" . $currency.$to . "=X";

		    curl_setopt($ch, CURLOPT_URL,$url);
		    curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
		    $csv = curl_exec($ch);

			$result = explode(',', $csv) ;

			$rate['currency'] = $currency;
			$rate['buy'] = $result[2];
			$rate['sell'] = $result[1];
			$rate['orderNum'] = $orderNum;

			$orderNum++;

			$rates[] = $rate;




			// $rates .= "<li> <h2> 1 $currency <br />";
   //   		$rates .= " Buy: $result[2]<br />";
   //   		$rates .= " Sell: $result[1]<br /></h2></li>";

		}

		$tabled_rates = $this->db->get('exchange_rates');

		if($tabled_rates->num_rows() > 0)
		{
			$this->db->update_batch('exchange_rates',$rates,'currency');
		}

		else
		{
			$this->db->insert_batch('exchange_rates',$rates);
		}

	    curl_close ($ch);
		
	}

}