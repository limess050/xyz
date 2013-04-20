<?php
  $this->load->view('formgenerator/header');      
  $this->load->view('formgenerator/content');      

$results=$this->datafetcher->loadparentsectioninsearchforms();
$results2=$this->datafetcher->loadparentsectionandsubection();
$results3 =$this->datafetcher->formsCreatedSections($table = "search_forms");

 if ($results3->num_rows()>0 ||$results->num_rows()>0||$results2->num_rows()>0) {
     ?>
           <table width="100%" border="0" class="mytable">

        <thead>

            <tr>

                <th>
                    Section name
                </th>
                <th>
                    Categories & Subsection(s)
                </th>

            </tr>
        <tbody> 
     <?php
     
        
            $output3='';
                   $table_output = '';
            $sn = 0;
            foreach ($results3->result_array() as $val) {

                $result_categories = $this->datafetcher->sectionCategory($val['SecID'], $table = "search_forms");
                ///load search forms by category
                $forms_output = '';
                $no = 0;

                foreach ($result_categories->result_array() as $forms) {
                    $formid = '';
                    ///load subsection if present
                     
                      
                    if (!empty($forms['sections_without_subsections'])) {

                        //get the subsection name 
 
                        $results_subsections = $this->datafetcher->getSectionSubsections($val['SecID'], $forms['CategoryID']);

                        $subs_name = '';
                        ///
                        //if category is  not empty means  section with subsections

                        $sectionwithoutsubsectionsresults = $this->datafetcher->loadsection($forms['sections_without_subsections'],$table="search_forms");
                        foreach ($sectionwithoutsubsectionsresults->result_array() as $rows) {
                            $formid = 'subsec/';
                        }


                        /////
                        foreach ($results_subsections->result_array() as $subsectionsname) {

                            $subs_name.=$subsectionsname['subSectionTitle'];
                        }

                        $name = $subs_name;
                    } else {


                        $sectionswithsubsectionsresults = $this->datafetcher->loadSubsection($forms['CategoryID'],$table="search_forms");
                        foreach ($sectionswithsubsectionsresults->result_array() as $rowsvalue) {

                            $formid = 'sec/';
                        }

                        $name = '-------';
                    }


                    $forms_output.='<tr><td>' . $name . '</td><td>' . $forms['Title'] . '</td>
                       
                    <td>' . anchor('mastersearch/editform/' . $formid . $forms['CategoryID'], $title = img(array('src' => 'icons/edit.png')), $attrib = array('title' => 'edit', 'class' => ''), $attrib = array('title' => 'edit', 'class' => '')) . nbs(3) . anchor_popup('mastersearch/generateform/' . $formid . $forms['CategoryID'], $title = img(array('src' => 'icons/accept.png')), $attrib = array('title' => 'view', 'class' => '')) . nbs(3) . anchor('mastersearch/deletesearchform/' . $formid . $forms['CategoryID'], $title = img(array('src' => 'icons/cancel.png')), $attrib = array('title' => 'delete', 'class' => ''), $attrib = array('title' => 'delete', 'class' => '')) . '</td>
                       
</tr>';
                }


                $sn++;
                $table_output .= '<tr><td>' . $val['sectionTitle'] . '</td><td><table width="100%" border="0" class="myinnertable">' . $forms_output . '</table></td></tr>';
            }
            echo $table_output; 
     
            $output = '';
            $sn=0;
            foreach ($results->result_array() as $value) {
              $sn++; 
              $checker= '<td>'.anchor('mastersearch/editform/' .'sectiononly/' . $value['parentsectionid'], $title = img(array('src' => 'icons/edit.png')), $attrib = array('title' => 'edit', 'class' => ''), $attrib = array('title' => 'edit', 'class' => '')) . nbs(3) . anchor_popup('mastersearch/generateform/'.'sectiononly/' . $value['parentsectionid'], $title = img(array('src' => 'icons/accept.png')), $attrib = array('title' => 'view', 'class' => '')) . nbs(3) . anchor('mastersearch/deletesearchform/'.'sectiononly/' . $value['parentsectionid'], $title = img(array('src' => 'icons/cancel.png')), $attrib = array('title' => 'delete', 'class' => ''), $attrib = array('title' => 'delete', 'class' => '')).'</td>';
              $output.='<tr><td>'.$value['SectionTitle'].'</td><td><table width="100%" border="0" class="myinnertable"><tr><td>'.'--All--'.'</td><td>'.'--All--'.'</td><td>'.$checker.'</td></tr></table></td>';
        
                
            } echo $output;
            ///////////////////////////////////////////
            $output2='';
            ////  the one with subsection and section
            
            foreach ($results2->result_array() as $value2) {
              
              $checker2= '<td>'.anchor('mastersearch/editform/' .'sectionsubsection/' . $value2['parentsectionid'].'/'.$value2['subsectionid'], $title = img(array('src' => 'icons/edit.png')), $attrib = array('title' => 'edit', 'class' => ''), $attrib = array('title' => 'edit', 'class' => '')) . nbs(3) . anchor_popup('mastersearch/generateform/'.'sectionsubsection/' . $value2['parentsectionid'].'/'.$value2['subsectionid'], $title = img(array('src' => 'icons/accept.png')), $attrib = array('title' => 'view', 'class' => '')) . nbs(3) . anchor('mastersearch/deletesearchform/'.'sectionsubsection/' . $value2['parentsectionid'].'/'.$value2['subsectionid'], $title = img(array('src' => 'icons/cancel.png')), $attrib = array('title' => 'delete', 'class' => ''), $attrib = array('title' => 'delete', 'class' => '')).'</td>';
              $output2.='<tr><td>'.$value2['section_name'].'</td><td><table width="100%" border="0" class="myinnertable"><td>'.$value2['subsections'].'</td><td>'.'--all--'.'</td><td>'.$checker2.'</td></tr></table></td>';
        
                
            } echo $output2;
         
            
           ///////////////////////////////////////////////  
       ?>
            </tbody>
    </table>   
           
      <?php }else{
            echo 'no data ';
        }
  $this->load->view('formgenerator/footer');      
?>
