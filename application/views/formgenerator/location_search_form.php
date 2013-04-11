<?php
$this->load->view('header');
$this->load->view('content');

$data = array('id' => '', 'class' => 'myformcreator');
echo form_open_multipart('mastersearch/loadsearchbox/', $data);
echo form_fieldset('');
?>
<ul>
    <li>

        <?php
//error checking
        if (form_error('location')) {
            echo '<div class="error">';
            echo form_error("location") . form_error();
            echo '</div>';
        }

        echo form_label('location');
        ?>
        <select name="location" class="searchsection">

            <option  value="" selected="">--Select location--</option>
            <?php
            $results = $this->datafetcher->sectionsLoader();
            $results=$this->db->get('area_tbl');
            $out = '';
            foreach ($results->result_array() as $section) {

                $out.='<option value="' . $section['area_id'] . set_value('location') . '">' . $section['area_name'] . '</option>';
            } echo $out;
            ?>
        </select> 


    </li>
  


</ul>

<?php
echo form_submit($name="submit", $value='search');
echo form_fieldset_close();
echo form_close();
$this->load->view('footer');
?>

