<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

$results = $this->datafetcher->inputTypesLoader();

if ($results && $results->num_rows() > 0) {

    $checkboxoutput = '';

    foreach ($results->result_array() as $value) {

        $dropdown_values = array();
        $dropdowns = '';

        //the  loop for initiating the max number of input fixed number of selection as they are in db

        for ($a = 0; $a < $value['max_no_inputs']; $a++) {

            $dropdowns.='<option   value="' . ($a + 1) . set_value('') . '">' . ($a + 1) . '</option>';
        }
        //end of the loop 

        $start_select = '<select name="count_' . $value['input_id'] . '"><option value="" >--no of input--</option>';
        $end_select = '</select>';
        //

        $data = array('name' => 'field_' . $value['input_id'], 'value' => 'field_' . set_value('inputs') . $value['input_id'],'class'=>'checkbox');

        $checkboxoutput.='<tr><td><li>' . form_checkbox($data) . '</td><td>' .
                $value['input_name'] . '</td><td>' . $start_select . $dropdowns . $end_select . '</td><td>'.
                form_input(array('name' => 'label_' . $value['input_id'], 'value' => '', 'size' => '30')) .'</td><td>'.
                form_input(array('name' => 'order_' . $value['input_id'], 'value' => '', 'size' => '30')).'</td><td>'.
                form_textarea(array('name' => 'tip_' . $value['input_id'], 'cols' => '25', 'rows' => '3','value' =>'')).
                '</li></td></tr>';
    }
    
  ?>
<table width="100%" class="myinputtable" cellpadding="2">
    <tbody>
    <thead>
        <tr>
            <th>select input</th><th>Type</th><th>No of inputs</th><th>Label name</th><th>Order format</th><th>Tip(s)</th>
            
        </tr>
    </thead>
        <?php echo $checkboxoutput; ?>
        
    </tbody>

</table>    
  <?php  

}
?>
