<?php
$this->load->view('formgenerator/header');
$this->load->view('formgenerator/content');

$data = array('id' => '', 'class' => 'myformcreator');
echo form_open_multipart('mastersearch/loadsearchbox/', $data);
echo form_fieldset('');
?>
<ul>
    <li>

        <?php
//error checking
        if (form_error('section')) {
            echo '<div class="error">';
            echo form_error("section") . form_error();
            echo '</div>';
        }

        echo form_label('section');
        ?>
        <select name="section" class="searchsection">

            <option  value="" selected="">--Select section--</option>
            <?php
            
            $out = '';
            $results = $this->datafetcher->sectionsLoader();
            foreach ($results->result_array() as $section) {

                $out.='<option value="' . $section['SectionID'] . set_value('section') . '">' . $section['Title'] . '</option>';
            } echo $out;
            ?>
        </select> 


    </li>
    <li>
           <?php
           
           if (form_error('cat')) {
            echo '<div class="error">';
            echo form_error("cat") . form_error();
            echo '</div>';
        }
                 
           ?>
        <table class="mytable" width="" border="0">
            <tr>

            <div class="searchcategory">
                <!--.here the goes the ajax triggered selection.--> 


            </div>

            </tr>
            <tr>
            <li>

                <div class="subcategories">

                </div>

            </li>

            </tr>

        </table>

    </li>


</ul>

<?php
echo form_submit($name="submit", $value='search');
echo form_fieldset_close();
echo form_close();
$this->load->view('formgenerator/footer');
?>
