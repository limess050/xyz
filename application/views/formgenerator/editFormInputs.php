<?php
/*
 * @Author :VincenT David 
 * @Email  :vincentdaudi@gmail.com
 * @Skype id :vincentdaudi
 */
$this->load->view('formgenerator/header');
$this->load->view('formgenerator/content');

$validation_arr = array();

if ($results->num_rows() > 0) {

    foreach ($results->result_array() as $value) {
        $id = $value['input_id'];
        $input_type = $value['input_type'];
        $input_name = $value['input_name'];
        $max_no_inputs = $value['max_no_inputs'];
    }

///check if form errors occured during submission

    if (form_error()) {
        $inputname = '';
        $inputtype = '';
        $maxnoinputs = '';
    } else {
        $inputname = $input_name;
        $inputtype = $input_type;
        $maxnoinputs = $max_no_inputs;
    }

    echo'<div class="error_box" id ="error_box"></div>';

    $data = array('name' => 'editinputs', 'class' => 'myform');
    echo form_open('formgenerator/updateInputTypesDetails/', $data);
    echo form_fieldset();
    ?>
    <ul>

        <li>
            <?php
            if (form_error('inputname')) {
                echo form_error('inputname');
            }
            echo form_label('input name');
            echo form_input(array('name' => 'inputname', 'value' => '' . $inputname . set_value('inputname')));
            echo form_hidden($name = 'id', $id);
            $vl['name'] = 'inputname';
            $vl['display'] = 'input type name';
            $vl['rules'] = 'required';
            $validation_arr[] = $vl;
            ?>

        </li>

        <li>
            <?php
            if (form_error('max_no_inputs')) {
                echo form_error('max_no_inputs');
            }
            echo form_label('Maximum number of inputs');
            echo form_input(array('name' => 'max_no_inputs', 'value' => '' . $maxnoinputs . set_value('max_no_inputs')));
            $val['name'] = 'max_no_inputs';
            $val['display'] = 'Maximum # of inputs';
            $val['rules'] = 'required';
            $validation_arr[] = $val;
            ?>

        </li>


        <li>
        <?php
        
            $val['name'] = 'formfieldtype';
            $val['display'] = 'select type for the form field';
            $val['rules'] = 'required';
            $validation_arr[] = $val;
        echo form_label('form field type');
        
        $results_to_selectField=$this->datafetcher->loadSelectInputTypes();
        if($results_to_selectField->num_rows()>0){
         ?>
         <select name="formfieldtype" class="">
              <option value="">choose a field type</option>
         <?php   
            $select_out='';
           foreach ($results_to_selectField->result_array()as $rowsTobedisplayed) {
               $select='';
               $results_two=$this->datafetcher->loadSelectInputTypesByid($id);
               
               foreach ($results_two->result_array() as $rowTocompare) {
                   
               if(strcasecmp($rowsTobedisplayed['selectinputtypes'],$rowTocompare['input_type'])==0){
                 $select="selected";
                 }
               else{
                  $select=""; 
               }
                   
               }
             
             $select_out.='<option  '.$select.' value="'.$rowsTobedisplayed['selectinputtypes'].'">'.$rowsTobedisplayed['selectinputtypes'].'</option>';   
            } echo $select_out;
       ?>
         </select>
      <?php }
        
        ?>
        
    </li>
        
        <?php
        /*         * *****************************draws from column*************************************************************** */
//        $val['name'] = 'validation_chck[]';
//        $val['display'] = 'atleast one validation rule ';
//        $val['rules'] = 'required';
//        $validation_arr[] = $val;
        

        $results_drawsfrom = $this->datafetcher->drawsFromColumn($id);
        if ($results_drawsfrom->num_rows() > 0) {
            foreach ($results_drawsfrom->result_array() as $drawsfields) {

                //check  if the table exists and columns too
                if (is_null($drawsfields['draws_from']) || empty($drawsfields['draws_from'])) {

                    $tablename = '<li>' . form_label('Draws form table name') . form_input(array('name' => 'tablename', 'value' => '' . set_value('tablename'))) . '</li>';
                    echo $tablename;
                } else {
                    $tablename = '<li>' . form_label('Draws form table name') . form_input(array('name' => 'tablename', 'value' => $drawsfields['draws_from'] . set_value('tablename'))) . '</li>';
                    echo $tablename;
                }
                ///column  id
                if (is_null($drawsfields['column_id']) || empty($drawsfields['column_id'])) {


                    $tablename = '<li>' . form_label('hidden display column id') . form_input(array('name' => 'displaycolumnid', 'value' => '' . set_value('displaycolumnid'))) . '</li>';
                    echo $tablename;
                } else {
                    $tablename = '<li>' . form_label('hidden display column id') . form_input(array('name' => 'displaycolumnid', 'value' => $drawsfields['column_id'] . set_value('displaycolumnid'))) . '</br><i><font color="#1A9B50">' .
                            form_label("Write the column ID as it is from the database", $name = "tips", $attributes = array('class' => 'tips')) . '</font></i></li>';
                    echo $tablename;
                }

                ///column name 
                if (is_null($drawsfields['display_id']) || empty($drawsfields['display_id'])) {

                    $tablename = '<li>' . form_label('Display column name') . form_input(array('name' => 'displaycolumn', 'value' => '' . set_value('displaycolumn'))) . '</br><i><font color="#1A9B50">' .
                            form_label("Write the column name which will go to output the description as it is from the database", $name = "tips", $attributes = array('class' => 'tips')) . '</font></i></li>';
                    echo $tablename;
                } else {

                    $tablename = '<li>' . form_label('Display column name') . form_input(array('name' => 'displaycolumn', 'value' => $drawsfields['display_id'] . set_value('displaycolumn'))) . '</li>';
                    echo $tablename;
                }
            }
        }



        /*         * *****************************end*************************************************************** */
        ?>



        <?php
        /*         * ********************************************************************************* */
        $db_results = $this->datafetcher->loadInputValidations();
        if ($db_results->num_rows() > 0) {
            $outputValidation = '';

            foreach ($db_results->result_array() as $inputValidations) {
                $checked = '';

                foreach ($this->datafetcher->loadsValidationrulesByName($inputValidations['input_rules'], $id)->result_array() as $rules) {

                    if (strcasecmp($inputValidations['input_rules'], $rules['rule_name']) == 0) {
                        $checked = "checked";
                    } else {
                        $checked = "";
                    }
                }



                $outputValidation.='<li>' . form_label() . form_checkbox(array('name' => 'validation_chck[]', 'value' => $inputValidations['input_rules'], 'checked' => $checked)) . $inputValidations['input_rules'] . '</li>';
            } echo $outputValidation;
        }

        /*         * ********************************************************************************* */
        ?>



        <li>
        <?php
        echo form_label('');
        echo form_submit(array('name' => 'update', 'value' => 'Edit Input'));
        ?>

        </li>



    </ul>
        <?php
        echo form_fieldset_close();
        echo form_close();
        ?>  

    <?php
} else {
    //echo form error
    echo 'error';
}
?>
        <?php
//json encoding for the form validations attributes;

        $array_final = json_encode($validation_arr);
        $array_final = preg_replace('/"([a-zA-Z]+[a-zA-Z0-9]*)":/', '$1:', $array_final);
        ?>
<!--.form validation script goes here.-->
<script type="text/javascript">
    var validator = new FormValidator('editinputs',<?php print_r($array_final); ?>, function(errors, event) {        
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
$this->load->view('formgenerator/footer');
?>
