<?php
/*
 * @Author :VincenT David 
 * @Email  :vincentdaudi@gmail.com
 * @Skype id :vincentdaudi
 */


$this->load->view('formgenerator/header');
$this->load->view('formgenerator/content');
$results = $this->dataFetcher->formsCreatedSections();


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
                $result_categories = $this->dataFetcher->sectionCategory($value['SecID']);
                
                $forms_output = '';
                
                foreach ($result_categories->result_array() as $forms) {

                    ///load subsection if present
                    $formid = '';
                    if (!empty($forms['sections_without_subsections'])) {
                        
                        //get the subsection name 
                        $results_subsections = $this->dataFetcher->getSectionSubsections($value['SecID'], $forms['CategoryID']);
                      // echo $this->db->last_query() . '<Br>';

                        $subs_name = '';
                        ///
                        //if category is  not empty means  section with subsections
                        $sectionwithoutsubsectionsresults = $this->dataFetcher->loadsection($forms['sections_without_subsections']);
                        foreach ($sectionwithoutsubsectionsresults->result_array() as $rows) {
                            $formid = 'subsec/';
                        }


                        /////
                        foreach ($results_subsections->result_array() as $subsectionsname) {
                            $subs_name.=$subsectionsname['subSectionTitle'];
                        }

                        $name = $subs_name ;
                    } else {


                        $sectionswithsubsectionsresults = $this->dataFetcher->loadSubsection($forms['CategoryID']);
                        foreach ($sectionswithsubsectionsresults->result_array() as $rowsvalue) {

                            $formid = 'sec/';
                        }

                        $name = '-------';
                    }


                    $forms_output.='<tr><td>' . $name . '</td><td>' . $forms['Title'] . '</td>
                       
                    <td>' . anchor('formgenerator/editform/' . $formid . $forms['CategoryID'], $title =img(array('src'=>'icons/edit.png')), $attrib = array('title' => 'edit', 'class' => ''), $attrib = array('title' => 'edit', 'class' => '')) . nbs(3) . anchor_popup('formgenerator/generateform/' . $formid . $forms['CategoryID'], $title =img(array('src'=>'icons/accept.png')), $attrib = array('title' => 'view', 'class' => '')) . nbs(3) . anchor('formgenerator/formdelete/' . $formid . $forms['CategoryID'],$title =img(array('src'=>'icons/cancel.png')), $attrib = array('title' => 'delete', 'class' => ''), $attrib = array('title' => 'delete', 'class' => '')) . '</td>
                       
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