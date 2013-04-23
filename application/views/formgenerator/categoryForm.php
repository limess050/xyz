<?php
/*
 * @Author :VincenT David 
 * @Email  :vincentdaudi@gmail.com
 * @Skype id :vincentdaudi
 */
?>
<?php
/*
 * @Author :VincenT David
 * @Email :vincentdaudi@gmail.com
 * @Skype id :vincentdaudi
 */
$this->load->view('formgenerator/header');
$this->load->view('formgenerator/content');

if ($results->num_rows() > 0) {

    $input_output = '';
    $validation_arr = array();

    foreach ($results->result_array() as $value) {

        //check if input is more than one
        $val = array();


        $inputfield = '';

        if ($value['no_input'] > 0) {



            /**
             *  check if it is textarea, select dropdown etc
             *  this is the place where all input types configured on a db and you want to appear in a generated form are configured
             * form validation has done according to rickharrison library(for javascript Ci form validation)
             * 
             */
            $fieldTobegenerated = '';

            switch (strtolower($value['input_type'])) {

                case"textarea";
                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    //fetch the validation rules as set by the user
                    $rulesin = '';
                    $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                    foreach ($rules_results->result_array() as $rules) {
                        $rulesin.=$rules['rule_name'] . '|';
                    }
                    $val['name'] = $value['fieldtypename'];
                    $val['display'] = $label;
                    $val['rules'] = $rulesin;

                    $fieldTobegenerated = form_label($label) . form_textarea(array('name' => $value['fieldtypename'], 'cols' => '25', 'rows' => '3')) . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                    break;
                case"textinput":
                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    //fetch the validation rules as set by the user
                    $rulesin = '';
                    $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                    foreach ($rules_results->result_array() as $rules) {
                        $rulesin.=$rules['rule_name'] . '|';
                    }
                    $val['name'] = $value['fieldtypename'];
                    $val['display'] = $label;
                    $val['rules'] = $rulesin;
                 
                    $fieldTobegenerated = form_label($label) . form_input(array('name' => $value['fieldtypename'], 'value' => '')) . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                    break;
                    
                    
                         case"dateinput":
                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    //fetch the validation rules as set by the user
                    $rulesin = '';
                    $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                    foreach ($rules_results->result_array() as $rules) {
                        $rulesin.=$rules['rule_name'] . '|';
                    }
                    $val['name'] = $value['fieldtypename'];
                    $val['display'] = $label;
                    $val['rules'] = $rulesin;

                    $fieldTobegenerated = form_label($label) . form_input(array('name' => $value['fieldtypename'], 'value' => '','class'=>'datepicker')) . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                    break;
                    
                      
                         case"date":
                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    //fetch the validation rules as set by the user
                    $rulesin = '';
                    $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                    foreach ($rules_results->result_array() as $rules) {
                        $rulesin.=$rules['rule_name'] . '|';
                    }
                    $val['name'] = $value['fieldtypename'];
                    $val['display'] = $label;
                    $val['rules'] = $rulesin;

                    $fieldTobegenerated = form_label($label) . form_input(array('name' => $value['fieldtypename'], 'value' => '','class'=>'datepicker')) . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                    break;
                    
                    
                    case "daterange":
                        
                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    //fetch the validation rules as set by the user
                    $rulesin = '';
                    $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                    foreach ($rules_results->result_array() as $rules) {
                        $rulesin.=$rules['rule_name'] . '|';
                    }
                    $val['name'] = $value['fieldtypename'];
                    $val['display'] = $label;
                    $val['rules'] = $rulesin;

                    $fieldTobegenerated = form_label($label) .form_input(array('name' => 'startdate', 'value' => '','class'=>'datepicker')) .'-'.form_input(array('name' => 'enddate', 'value' => '','class'=>'datepicker')). '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                    break;
                    
                     case "yearrange":
                        
                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    //fetch the validation rules as set by the user
                    $rulesin = '';
                    $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                    foreach ($rules_results->result_array() as $rules) {
                        $rulesin.=$rules['rule_name'] . '|';
                    }
                    $val['name'] = $value['fieldtypename'];
                    $val['display'] = $label;
                    $val['rules'] = $rulesin;

                     $fieldTobegenerated = form_label($label) .form_input(array('name' => 'startdate', 'value' => '','class'=>'datepickeryear')) .'-'.form_input(array('name' => 'enddate', 'value' => '','class'=>'datepickeryear')). '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                    break;
                    
                      case "pricerange":
                        
                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    //fetch the validation rules as set by the user
                    $rulesin = '';
                    $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                    foreach ($rules_results->result_array() as $rules) {
                        $rulesin.=$rules['rule_name'] . '|';
                    }
                    $val['name'] = $value['fieldtypename'];
                    $val['display'] = $label;
                    $val['rules'] = $rulesin;

                    $fieldTobegenerated = form_label($label) .form_input(array('name' => 'minprice', 'value' => '','class'=>'')).'-'.form_input(array('name' => 'maxprice', 'value' => '','class'=>'')). '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                    break;
                    
                    
                    
                    

                case"checkbox":
                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    //fetch the validation rules as set by the user
                    $rulesin = '';
                    $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                    foreach ($rules_results->result_array() as $rules) {
                        $rulesin.=$rules['rule_name'] . '|';
                    }
                    $val['name'] = $value['fieldtypename'];
                    $val['display'] = $label;
                    $val['rules'] = $rulesin;

                    $fieldTobegenerated = form_label($label) . form_checkbox(array('name' => $value['fieldtypename'], 'value' => '')) . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                    break;

                case"file":
                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    //fetch the validation rules as set by the user
                    $rulesin = '';
                    $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                    foreach ($rules_results->result_array() as $rules) {
                        $rulesin.=$rules['rule_name'] . '|';
                    }
                    $val['name'] = $value['fieldtypename'];
                    $val['display'] = $label;
                    $val['rules'] = $rulesin;

                    $fieldTobegenerated = form_label($label) . '<input type="file" name="' . $value['fieldtypename'] . '[]" class="images"/>' . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                    break;
                    
                    case"password":
                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    //fetch the validation rules as set by the user
                    $rulesin = '';
                    $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                    foreach ($rules_results->result_array() as $rules) {
                        $rulesin.=$rules['rule_name'] . '|';
                    }
                    $val['name'] = $value['fieldtypename'];
                    $val['display'] = $label;
                    $val['rules'] = $rulesin;

                    $fieldTobegenerated = form_label($label) . form_password(array('name' => $value['fieldtypename'], 'value' => '')) . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                    break;
                    
                    
                    
                    
                      
                     case"multiselect":
                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    //fetch the validation rules as set by the user
                    $rulesin = '';
                    $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                    foreach ($rules_results->result_array() as $rules) {
                        $rulesin.=$rules['rule_name'] . '|';
                    }
                    $val['name'] = $value['fieldtypename'];
                    $val['display'] = $label;
                    $val['rules'] = $rulesin;
                    
                    $out = '';
                    $tabletesults = $this->datafetcher->selecTfromTable($value['draws_from']);

                    foreach ($tabletesults->result_array()as $rows) {

                        $out.='<option value="' . $rows[$value['column_id']] . '">' . $rows[$value['display_id']] . '</option>';
                    }
                    
                    

                    $fieldTobegenerated = form_label($label) . '<select  name="'.$value['fieldtypename'].'[]" class="" multiple="multiple" size="4"><option value="" selected>--Select an option--</option>' . $out . '</select>' . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                    break;

                   //selecTfromTable($table)
                    
                     case"select":
                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    //fetch the validation rules as set by the user
                    $rulesin = '';
                    $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                    foreach ($rules_results->result_array() as $rules) {
                        $rulesin.=$rules['rule_name'] . '|';
                    }
                    $val['name'] = $value['fieldtypename'];
                    $val['display'] = $label;
                    $val['rules'] = $rulesin;
                    
                    $out = '';
                    $tabletesults = $this->datafetcher->selecTfromTable($value['draws_from']);

                    foreach ($tabletesults->result_array()as $rows) {

                        $out.='<option value="' . $rows[$value['column_id']] . '">' . $rows[$value['display_id']] . '</option>';
                    }
                    
                    

                    $fieldTobegenerated = form_label($label) . '<select name="'.$value['fieldtypename'].'" class=""><option value="" selected>--Select an option--</option>' . $out . '</select>'.'<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                    break;
                    
                     case "repeat":

                    if (empty($value['input_tip'])) {
                        $tipsOnlabel = '';
                    } else {
                        $tipsOnlabel = $value['input_tip'];
                    }
                    $out = '';
                    $repeatselectrtesults = $this->datafetcher->getAllrepeats();

                    foreach ($repeatselectrtesults->result_array()as $rows) {

                        $out.='<option value="' . $rows['repeat_id'] . '">' . $rows['events'] . '</option>';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . '<select name="" class="events"><option value="">Select</option>' . $out . '</select><div class="events_display"></div>';
                    break;
                   case "price":
                        //$fieldTobegenerated='<table border="0"><tr><td></td><td></td></tr></table>';
                        if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    //fetch the validation rules as set by the user
                    $rulesin = '';
                    $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                    foreach ($rules_results->result_array() as $rules) {
                        $rulesin.=$rules['rule_name'] . '|';
                    }
                    $val['name'] = $value['fieldtypename'];
                    $val['display'] = $label;
                    $val['rules'] = $rulesin;

                    $fieldTobegenerated = form_label($label) .'<table border="0" class="price"><tr>
                        <td>'.form_input(array('name' => $value['fieldtypename'], 'value' => '','class'=>'priceVal')) .'</td>
                        <td>'.'<select name="price" class="pricetd"><option value="usd">$USD</option><option value="tzs">TZS</option></select>' .'</td>
                        </tr></table>'. '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                       break;
                       
                       case"time";
                                     if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    //fetch the validation rules as set by the user
                    $rulesin = '';
                    $rules_results = $this->datafetcher->loadsValidationrules($value['input_id']);
                    foreach ($rules_results->result_array() as $rules) {
                        $rulesin.=$rules['rule_name'] . '|';
                    }
                    $val['name'] = $value['fieldtypename'];
                    $val['display'] = $label;
                    $val['rules'] = $rulesin;
           
                                     
                    $out='<option value="12.00 AM">'.'12.00 AM'.'</option>
                          <option value="12.30 AM"> 12.30 AM </option>
                          <option value="1.00 AM"> 1.00 AM </option>
                          <option value="1.30 AM"> 1.30 AM </option>
                          <option value="2.00 AM"> 2.00 AM </option>
                          <option value="2.30 AM"> 2.30 AM </option>
                          <option value="3.00 AM"> 3.00 AM </option>
                          <option value="3.30 AM"> 3.30 AM </option>
                          <option value="4.00 AM"> 4.00 AM </option>
                          <option value="4.30 AM"> 4.30 AM </option>
                          <option value="5.00 AM"> 5.00 AM </option>
                          <option value="5.30 AM"> 5.30 AM </option>
                          <option value="6.00 AM"> 6.00 AM </option>
                          <option value="6.30 AM"> 6.30 AM </option>
                          <option value="7.00 AM"> 7.00 AM </option>
                          <option value="7.30 AM"> 7.30 AM </option>
                          <option value="8.00 AM"> 8.00 AM </option>
                          <option value="8.30 AM"> 8.30 AM </option>
                          <option value="9.00 AM"> 9.00 AM </option>
                          <option value="9.30 AM"> 9.30 AM </option>
                          <option value="10.00 AM"> 10.00 AM </option>
                          <option value="10.30 AM"> 10.30 AM </option>
                          <option value="11.00 AM"> 11.00 AM </option>
                          <option value="11.30 AM"> 11.30 AM </option>
                          
                          <option value="12.00 PM"> 12.00 PM </option>
                          <option value="12.30 PM"> 12.30 PM </option>
                          <option value="1.00 PM"> 1.00 PM </option>
                          <option value="1.30 PM"> 1.30 PM </option>
                          <option value="2.00 PM"> 2.00 PM </option>
                          <option value="2.30 PM"> 2.30 PM </option>
                          <option value="3.00 PM"> 3.00 PM </option>
                          <option value="3.30 PM"> 3.30 PM </option>
                          <option value="4.00 PM"> 4.00 PM </option>
                          <option value="4.30 PM"> 4.30 PM </option>
                          <option value="5.00 PM"> 5.00 PM </option>
                          <option value="5.30 PM"> 5.30 PM </option>
                          <option value="6.00 PM"> 6.00 PM </option>
                          <option value="6.30 PM"> 6.30 PM </option>
                          <option value="7.00 PM"> 7.00 PM </option>
                          <option value="7.30 PM"> 7.30 PM </option>
                          <option value="8.00 PM"> 8.00 PM </option>
                          <option value="8.30 PM"> 8.30 PM </option>
                          <option value="9.00 PM"> 9.00 PM </option>
                          <option value="9.30 PM"> 9.30 PM </option>
                          <option value="10.00 PM"> 10.00 PM </option>
                          <option value="11.00 PM"> 11.00 PM </option>
                          <option value="11.30 PM"> 11.30 PM </option>
                          
                           ';
                    
                   
//                    $time = strtotime('12:00');
//                    
//                    
//                    $dayChanger='';
//                    
//                    for($x=0; $x<2; $x++){
//                          
//                       
//                        
//                         $timeout='';
//                        for($k=0; $k<24;$k++){
//                             //changing the AM to PM
//                        if(strcasecmp($x, "1")==0){
//                          $dayChanger='AM';  
//                            
//                        }else{
//                          $dayChanger='PM';   
//                        }
//                        echo $k;
//                            $min=30 *($k);
//                            $startTime=date("h:i", strtotime('+'.$min.' minutes', $time));
//                            
//                            $timeout.='<option value="11.30 PM"> '.$startTime.''.$dayChanger.' </option>';
//                        }
//                        //for the first 24hours /a day session
//                                               
//                    } echo $timeout.'</br></br></br>';
                  
                   $fieldTobegenerated = form_label($label) . '<select name="'.$value['fieldtypename'].'" class=""><option value="" selected>--Select an option--</option>' . $out . '</select>' . '<i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                           break;
                    
                    
                default:
                    break;
            }

///loop to get the exactly number of inputs required

            for ($a = 0; $a < $value['no_input']; $a++) {

                $inputfield.='<li>' . $fieldTobegenerated . '</li>';
            }
        } else {

            $inputfield = '';
        }


        $input_output.=$inputfield;


        $validation_arr[] = $val;
    }
     if(isset($heading)&& isset($category)){
      $heading=$heading;  
      $category=$category;
    }else{
        $heading='';
        $category='';
    }
    echo form_open_multipart('formInsertion/formsdataprocessor/', $data = array('name' => 'myForm', 'id' => 'myform', 'class' => 'myform', 'onsubmit' => "")) . '<h1>' .$heading. $category . '</h1>' . '<!--.javascript form validation.-->
<div class="error_box" id ="error_box"></div><div id="success_box"></div>' . form_fieldset() . '<ul>' . form_hidden($name = "cat", $id ='') . $input_output . '<li>' . form_label() . form_submit(array('name' => 'submit', 'value' => 'submit', 'class' => 'submit')) . '</li></ul>' . form_fieldset_close() . form_close();
} else {
    
}
?>
<?php
//json encoding for the form validations attributes;

$array_final = json_encode($validation_arr);
$array_final = preg_replace('/"([a-zA-Z]+[a-zA-Z0-9]*)":/', '$1:', $array_final);
?>
<!--.form validation script goes here.-->
<script type="text/javascript">

 
    var validator = new FormValidator('myForm',<?php print_r($array_final); ?>, function(errors, event) {
        
        if (errors.length > 0) {
                       
            // Show the errors
            var errorString = '';
        
            for (var i = 0, errorLength = errors.length; i < errorLength; i++) {
                errorString += errors[i].message + '<br />';
            }
        
            error_box.innerHTML = errorString;
     
        }
        
          
    });
    
 
</script>
<?php
$this->load->view('footer');
?>
