<?php
/*
 * @Author :VincenT David 
 * @Email  :vincentdaudi@gmail.com
 * @Skype id :vincentdaudi
 */


$this->load->view('formgenerator/header');
$this->load->view('formgenerator/content');
$results = $this->datafetcher->formsCreatedSections($table="search_forms");


if ($results->num_rows() > 0) {
    ?>
    <table width="100%" border="0" class="mytable">

        <thead>

            <tr>

                <th>
                    S/N
                </th>
                <th>
                    Section name
                </th>
                <th>
                    Categories & Subsection(s)
                </th>

            </tr>
        <tbody>


            <?php
            $table_output = '';
            $sn = 0;
            foreach ($results->result_array() as $value) {
                $sn++;
                //check if subsections detected 
                $result_categories = $this->datafetcher->sectionCategory($value['SecID'],$table="search_forms");
                
                $forms_output = '';
                
                foreach ($result_categories->result_array() as $forms) {

                    ///load subsection if present
                    $formid = '';
                    if (!empty($forms['sections_without_subsections'])) {
                        
                        //get the subsection name 
                        $results_subsections = $this->datafetcher->getSectionSubsections($value['SecID'], $forms['CategoryID']);
                      // echo $this->db->last_query() . '<Br>';

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

                        $name = $subs_name ;
                    } else {


                        $sectionswithsubsectionsresults = $this->datafetcher->loadSubsection($forms['CategoryID'],$table="search_forms");
                        foreach ($sectionswithsubsectionsresults->result_array() as $rowsvalue) {

                            $formid = 'sec/';
                        }

                        $name = '-------';
                    }


                    $forms_output.='<tr><td>' . $name . '</td><td>' . $forms['Title'] . '</td>
                       
                    <td>' . anchor('mastersearch/editform/' . $formid . $forms['CategoryID'], $title =img(array('src'=>'icons/edit.png')), $attrib = array('title' => 'edit', 'class' => ''), $attrib = array('title' => 'edit', 'class' => '')) . nbs(3) . anchor_popup('mastersearch/generateform/' . $formid . $forms['CategoryID'], $title =img(array('src'=>'icons/accept.png')), $attrib = array('title' => 'view', 'class' => '')) . nbs(3) . anchor('mastersearch/deletesearchform/' . $formid . $forms['CategoryID'],$title =img(array('src'=>'icons/cancel.png')), $attrib = array('title' => 'delete', 'class' => ''), $attrib = array('title' => 'delete', 'class' => '')) . '</td>
                       
</tr>';
                }
                $table_output.='<tr><td>' . $sn . '</td><td>' . $value['sectionTitle'] . '</td><td><table width="100%" border="0" class="myinnertable">' . $forms_output . '</table></td></tr>';
            }
            echo $table_output;
            ?>





        </tbody>

    </thead>




    </table>    
    <?php
}
else{
    
    echo 'no data found';
}
?>





<?php
$this->load->view('formgenerator/footer');
