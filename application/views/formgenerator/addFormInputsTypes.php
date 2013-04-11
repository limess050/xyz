<?php
/*
 * @Author :VincenT David 
 * @Email  :vincentdaudi@gmail.com
 * @Skype id :vincentdaudi
 */


$data = array('name' => '', 'class' => 'myform');
echo form_open('formgenerator/addInputsTypes/', $data);
echo form_fieldset();
?>
<ul>

    <li>
        <?php
        if (form_error('inputname')) {
          echo '<div class="error">'.form_error('inputname').'</div>';
        }
        echo form_label('input name');
        echo form_input(array('name' => 'inputname', 'value' => '' . set_value('inputname')));
        ?>

    </li>

    <li>
        <?php
        if (form_error('max_no_inputs')) {
            
             echo '<div class="error">'.form_error('max_no_inputs').'</div>';
        }
        echo form_label('Maximum number of inputs');
        echo form_input(array('name' => 'max_no_inputs', 'value' => ''.  set_value('max_no_inputs')));
        ?>

    </li>
    
    <li>
        <?php
        
        if (form_error('formfieldtype')) {
            
            echo '<div class="error">'.form_error('formfieldtype').'</div>';
        }
        echo form_label('form field type');
        
        $results_to_selectField=$this->datafetcher->loadSelectInputTypes();
        if($results_to_selectField->num_rows()>0){
         ?>
         <select name="formfieldtype" class="">
              <option value="">choose a field type</option>
         <?php   
            $select_out='';
           foreach ($results_to_selectField->result_array()as $rowsTobedisplayed) {
               
             $select_out.='<option value="'.$rowsTobedisplayed['selectinputtypes'].'">'.$rowsTobedisplayed['selectinputtypes'].'</option>';   
            } echo $select_out;
       ?>
         </select>
      <?php }
        
        ?>
        
    </li>
    
     <li>
        <?php
        if (form_error('tablename')) {
            echo form_error('tablename');
        }
        echo form_label('Draws form table name');
        echo form_input(array('name' => 'tablename', 'value' => '' . set_value('tablename')));
        ?>

    </li>
    <li>
        <?php
        if (form_error('displaycolumnid')) {
            echo form_error('displaycolumnid');
        }
        echo form_label('hidden display column id');
        
        echo form_input(array('name' => 'displaycolumnid', 'value' => '' . set_value('displaycolumnid'))).'</br><i><font color="#1A9B50">'.
             form_label("Write the column ID as it is from the database", $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
        ?>

    </li>
    <li>
        <?php
        if (form_error('displaycolumn')) {
            echo form_error('displaycolumn');
        }
        echo form_label('Display column name');
        
        echo form_input(array('name' => 'displaycolumn', 'value' => '' . set_value('displaycolumn'))).'</br><i><font color="#1A9B50">'.
             form_label("Write the column name which will go to output the description as it is from the database", $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
        ?>

    </li>
         
    
            <?php
            if (form_error('validation_chck')) {
            
            echo '<div class="error">'.form_error('validation_chck').'</div>';
        }
            $db_results=$this->datafetcher->loadInputValidations();
            if($db_results->num_rows()>0){
                $outputValidation='';
                foreach ($db_results->result_array() as $inputValidations) {
                
                if(strcasecmp($inputValidations['input_rules'],"required")==0){
                   $checked="checked"; 
                }else{
                    $checked="";
                }    
                    
                $outputValidation.='<li>'.  form_label().form_checkbox(array('name'=>'validation_chck[]','value'=>$inputValidations['input_rules'],'checked'=>$checked)).$inputValidations['input_rules'].'</li>';
                } echo $outputValidation;
                
            }
          ?>
  

    <li>
        <?php
        echo form_label('');
        echo form_submit(array('name' => 'submit', 'value' => 'add'));
        ?>

    </li>



</ul>
<?php
echo form_fieldset_close();
echo form_close();

$this->load->view('footer');
?>
