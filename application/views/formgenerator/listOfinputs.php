<?php

/*
 * @Author :VincenT David 
 * @Email  :vincentdaudi@gmail.com
 * @Skype id :vincentdaudi
 */
$this->load->view('formgenerator/header');
$this->load->view('formgenerator/content');

$this->load->view('formgenerator/addFormInputsTypes');
if($results->num_rows()>0){
 ?>


<table class="myinnertable" width="100%" border="0">
    
    <thead>
        <tr>
            <th>
                SN
            </th>
            <th>
                Input type name
            </th>
            <th>
                Input type (programming purpose)
            </th>
            <th>
                Maximum number of Inputs
            </th>
            <th>
                Option(s)
            </th>
            
            
        </tr>
        
    </thead>
    <tbody>
    <?php
    $output='';
    $no=0;
    
 foreach ($results->result_array() as $value) {
     $no++;
     $edit_anchor=anchor('formgenerator/editinputs/'. $value['input_id'], $title =img(array('src'=>'icons/edit.png')), $attrib = array('title' => 'edit', 'class' => ''));
     $cancel_anchor=anchor('formgenerator/deleteInput/'. $value['input_id'], $title =img(array('src'=>'icons/cancel.png')), $attrib = array('title' => 'cancel', 'class' => ''));
     $output.='<tr><td>'.$no.'</td><td>'.$value['input_name'].'</td><td>'.$value['input_type'].'</td><td>'.$value['max_no_inputs'].'</td><td>'.$edit_anchor.''.$cancel_anchor.'</td></tr>';
   
 }echo $output;
    
    
    ?>
    
    
    </tbody>  
</table> 
 <?php
    
}else{
    echo 'no input found'; 
}
$this->load->view('formgenerator/footer');
?>
