<?php

 if($results->num_rows()>0){
 
     foreach ($results->result_array() as $value) {
         
         $inputname=$value['selectinputtypes'];
         $id=$value['selectinputtypes_id'];
     }
     $this->session->set_userdata('select_id',$id);
     $this->session->set_userdata('selectname',$inputname);
     //check if an error occured during validation
     if(form_error()){
       $name=$this->session->userdata('selectname');
     }else{
       $name=$inputname;  
     }
   
     ///forms goes here
     $data = array('name' => '', 'class' => 'myform');
echo form_open('formgenerator/editinputforselectfieldprocessor/', $data);
echo form_fieldset();
?>
<ul>

    <li>
        <?php
        if (form_error('inputname')) {
          echo '<div class="error">'.form_error('inputname').'</div>';
        }
        echo form_label('input name');
        echo form_input(array('name' => 'inputname', 'value' => '' .$name. set_value('inputname')));
        ?>

    </li>

   

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

?>
<?php     
     
     
     
     
 }else{
     echo 'no data found';
 }

?>
