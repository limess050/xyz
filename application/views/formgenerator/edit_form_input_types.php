<?php

/*
 * @Author :VincenT David 
 * @Email  :vincentdaudi@gmail.com
 * @Skype id :vincentdaudi
 */

//get results of the fethed category

$checked_arr = array();
$checked_select_value = array();
$checked_select_maxval = array();
$checked_input_tips = array();
$checked_input_label = array();
$checked_input_orderby = array();

foreach ($results->result_array() as $editvalue) {

    array_push($checked_arr, $editvalue['input_id']);
    array_push($checked_select_value, $editvalue['no_input']);
    array_push($checked_input_tips, $editvalue['input_tip']);
    array_push($checked_input_label, $editvalue['form_label']);
    array_push($checked_select_maxval, $editvalue['max_no_inputs']);
    array_push($checked_input_orderby, $editvalue['displayOrder']);
}

$allresults = $this->dataFetcher->inputTypesLoader();

if ($allresults && $allresults->num_rows() > 0) {

    $checkboxoutput = '';

    foreach ($allresults->result_array() as $value) {

        $dropdown_values = array();
        $dropdowns = '';
        $checked = '';
        $editno_input = '';
        $select = '';
        $chkd = '';
        $label = '';
        $order='';
        $tip = '';

////////////the values user set last time in db
        for ($i = 0; $i < count($checked_arr); $i++) {

            if ($value['input_id'] == $checked_arr[$i]) {

                $checked.= 'TRUE';
                $label.=$checked_input_label[$i];
                $order.=$checked_input_orderby[$i];
                $tip.=$checked_input_tips[$i];

                $editno_input.=$checked_select_value[$i];
                //check if the select input value matches if then set select selected
                if ($value['max_no_inputs'] == $checked_select_maxval[$i]) {

                    $chkd.=$checked_select_value[$i];
                } else {

                    $chkd.='';
                }
            } else {
                $checked.= '';
                $label.='';
                $order.='';
                $tip.='';
                $editno_input.='';
            }
        }
////////////////////////////////////////////////////
        //the  loop for initiating the max number of input fixed number of selection as they are in db
        for ($a = 0; $a < $value['max_no_inputs']; $a++) {


            //check if the set number in the db matches is not empty
            $dropdownVal = ($a + 1);

            if ($dropdownVal == $chkd) {

                $select = "selected";
            } else {
                $select = "";
            }
            $dropdowns.='<option  ' . $select . ' value="' . $dropdownVal . set_value() . '">' . $dropdownVal . '</option>';
        }
        //end of the loop 

        $start_select = '<select name="count_' . $value['input_id'] . '"><option value="" >--no of input--</option>';
        $end_select = '</select>';
        //

        $data = array('name' => 'field_' . $value['input_id'], 'value' => 'field_' . set_value('inputs') . $value['input_id'], 'checked' => $checked);
        $checkboxoutput.='<tr><td><li>'. form_checkbox($data) .'</td><td>'.
                $value['input_name'] .'</td><td>'. $start_select . $dropdowns . $end_select .'</td><td>'.
                form_input(array('name' => 'label_' . $value['input_id'], 'value' => $label, 'size' => '30')).'</td><td>'.
                form_textarea(array('name' => 'tip_' . $value['input_id'], 'cols' => '25', 'rows' => '3', 'value' => $tip)) .'</td><td>'.
                form_input(array('name'=>'order_'.$value['input_id'],'value'=>$order)).
                '</li></td></tr>';
               
        
        
    }
    
  ?>
  <table width="100%" class="myinputtable" cellpadding="2">
    <tbody>
    <thead>
        <tr>
            <th>select input</th><th>Type</th><th>No of inputs</th><th>Label name</th><th>Tip(s)</th><th>Order By(#)</th>
            
        </tr>
    </thead>
        <?php echo $checkboxoutput; ?>
        
    </tbody>

</table> 
 <?php  
    //echo $checkboxoutput;
} else {

    ///no checkboxes to generate
}
?>

