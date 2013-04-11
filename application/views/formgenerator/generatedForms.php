<?php
/*
 * @Author :VincenT David 
 * @Email  :vincentdaudi@gmail.com
 * @Skype id :vincentdaudi
 */
$this->load->view('header');
$this->load->view('content');

$results = $this->datafetcher->generatedformsInformations();


if ($results->num_rows() > 0) {
    ?>
    <table width="0" border="" class="mytable">    
    <?php
    
        $out_sub = '';
        
        $output = '';
    foreach ($results->result_array() as $value) {

            $formid = '';
            
        if (empty($value['sections_without_subsections'])) {
            //if it is empty means its section without subsections 
            $sectionswithsubsectionsresults = $this->datafetcher->loadSubsection($value['category_id']);
            foreach ($sectionswithsubsectionsresults->result_array() as $rowsvalue) {

                $out_sub.=$rowsvalue['cat_name'];
                $formid='sec/';
            }
        }
        else{
              //if category is  not empty means  section with subsections
            $sectionwithoutsubsectionsresults = $this->datafetcher->loadsection($value['sections_without_subsections']);
            foreach ($sectionwithoutsubsectionsresults->result_array() as $rows) {
                $out_sub.=$rows['cat_name'];
                $formid='subsec/';
            }
         
        }

        //the final row output printed 
        $output.='<tr><td>' . $value['cat_name'] . '</td><td>'. anchor('formgenerator/editform/' .$formid. $value['cat_id'], $title = 'click', $attrib = array('title' => 'click', 'class' => '')) .'</td><td>'.anchor_popup('formgenerator/generateform/' .$formid. $value['cat_id'], $title = 'click', $attrib = array('title' => 'click', 'class' => '')) . '</td><td>'. anchor('formgenerator/formdelete/' .$formid. $value['cat_id'], $title = 'click', $attrib = array('title' => 'click', 'class' => '')).'</td></tr>';
    } echo $output;
    ?>
    </table> 
        <?php
    } else {

        ///handle exception

        echo 'no data for any form';
    }
    ?>



<?php
$this->load->view('footer');