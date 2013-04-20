<?php
/*
 * @Author :VincenT David 
 * @Email  :vincentdaudi@gmail.com
 * @Skype id :vincentdaudi
 */

$this->load->view('formgenerator/header');
$this->load->view('formgenerator/content');


if (form_error()) {

    //set section id and name and subsection of any in session
} else {

}


if (!empty($catname)) {
    $category = $catname;
}

$data = array('id' => '','class'=>'myformcreator');
///the section name should be displayed of here

echo form_open_multipart($controller.'/', $data);
echo form_fieldset('');
echo 'section name :' . $sectionname . '</br>';
echo form_hidden('section_id', $section_id);
echo form_hidden('cat[]', $catid);

if (!empty($subsectionname)) {

    echo 'subsection name :' . $subsectionname . '</br>';
    echo form_hidden('subsection_id', $subsection_id);
}

echo 'Category :' . $category . '</br>';
?>
<ul>

    <li>

        <?php
        echo form_label('select the input types');
        ?>
        <ul>

            <?php
            echo form_fieldset();

            if (form_error('inputs')) {

                echo form_error('inputs');
            }

            $data['results'] = $result;
            $this->load->view('formgenerator/edit_form_input_types', $data);
            echo form_fieldset_close();
            ?>
        </ul>
   </li>
</ul> 

<?php
$data = array('name' => 'edit', 'value' => 'Edit');
echo form_submit($data);
echo form_fieldset_close();
echo form_close();
$this->load->view('formgenerator/footer');
?>