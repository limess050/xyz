  case "secondcontactaltenatephone":

                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'secondcontactaltenatephone';
                    $val['display'] = 'second contact altenate phone';
                    $val['rules'] = 'required';

                    $fieldTobegenerated = $error . form_label($label) . form_input(array('name' => 'secondcontactaltenatephone', 'value' => '' . set_value(''), 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    
                    
                    break;
                
                
                
                
                case "contactaltenatephone":

                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'contactaltenatephone';
                    $val['display'] = 'contact altenate phone';
                    $val['rules'] = 'required';

                    $fieldTobegenerated = $error . form_label($label) . form_input(array('name' => 'contactaltenatephone', 'value' => '' . set_value(''), 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;
                
                
                
                
                case "contactphone":

                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'contactphone';
                    $val['display'] = 'contact phone';
                    $val['rules'] = 'required';

                    $fieldTobegenerated = $error . form_label($label) . form_input(array('name' => 'contactphone', 'value' => '' . set_value('contactphone'), 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;
                case "secondcontactlastname":

                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'secondcontactlastname';
                    $val['display'] = 'second contact lastname';
                    $val['rules'] = 'required';

                    $fieldTobegenerated = $error . form_label($label) . form_input(array('name' => 'secondcontactlastname', 'value' => '' . set_value('secondcontactlastname'), 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;
                
                case "secondcontactfirstname":

                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'secondcontactfirstname';
                    $val['display'] = 'second contact first name';
                    $val['rules'] = 'required';

                    $fieldTobegenerated = $error . form_label($label) . form_input(array('name' => 'secondcontactfirstname', 'value' => '' . set_value('name'), 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;

                case "fullname_input":

                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }


                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'name';
                    $val['display'] = 'name';
                    $val['rules'] = 'required';

                    $fieldTobegenerated = $error . form_label($label) . form_input(array('name' => 'name', 'value' => '' . set_value('name'), 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;

                case "lastname":

                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }

                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'lastname';
                    $val['display'] = 'last name';
                    $val['rules'] = 'required';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . form_input(array('name' => 'lastname', 'value' => '', 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;


                case "confirmemail":

                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }

                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'confirmemail';
                    $val['display'] = 'confirm an email';
                    $val['rules'] = 'required|matches[confirmemail]';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . form_input(array('name' => 'confirmemail', 'value' => '', 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;


                case "listingtitle":

                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }

                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'listingtitle';
                    $val['display'] = 'Listing Title';
                    $val['rules'] = 'required';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . form_input(array('name' => 'listingtitle', 'value' => '', 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;

                case "listingtitle":

                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }

                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'listingcopy';
                    $val['display'] = 'Listing Copy';
                    $val['rules'] = 'required';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . form_input(array('name' => 'listingcopy', 'value' => '', 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;

                case "listingtitle":

                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }

                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'eventname';
                    $val['display'] = 'Event name';
                    $val['rules'] = 'required';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . form_input(array('name' => 'eventname', 'value' => '', 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;


                case "eventsenddate":

                    if (!empty($value['input_tip'])) {
                        $tipsOnlabel = $value['input_tip'];
                    } else {
                        $tipsOnlabel = '';
                    }

                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'eventsenddate';
                    $val['display'] = 'Event end date';
                    $val['rules'] = 'required';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . form_input(array('name' => 'eventsenddate', 'value' => '', 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;

                case "primaryphone":

                    if (empty($value['input_tip'])) {
                        $tipsOnlabel = '';
                    } else {
                        $tipsOnlabel = $value['input_tip'];
                    }

                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'primaryphone';
                    $val['display'] = 'primary public phone #';
                    $val['rules'] = 'required|is_natural';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . form_input(array('name' => 'primaryphone', 'value' => '', 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;

                case "public_phone":

                    if (empty($value['input_tip'])) {
                        $tipsOnlabel = '';
                    } else {
                        $tipsOnlabel = $value['input_tip'];
                    }

                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'public_phone';
                    $val['display'] = 'public phone #';
                    $val['rules'] = 'required|is_natural';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . form_input(array('name' => 'public_phone', 'value' => '', 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;


                case "otherphone":

                    if (empty($value['input_tip'])) {
                        $tipsOnlabel = '';
                    } else {
                        $tipsOnlabel = $value['input_tip'];
                    }
                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'otherphone';
                    $val['display'] = 'Other public phone #';
                    $val['rules'] = 'required|is_natural';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . form_input(array('name' => 'otherphone', 'value' => '', 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;


                case "fax":

                    if (empty($value['input_tip'])) {
                        $tipsOnlabel = '';
                    } else {
                        $tipsOnlabel = $value['input_tip'];
                    }
                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'fax';
                    $val['display'] = 'Fax # ';
                    $val['rules'] = 'required|is_natural';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . form_input(array('name' => 'fax', 'value' => '', 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;

                case "contact_email":

                    if (empty($value['input_tip'])) {
                        $tipsOnlabel = '';
                    } else {
                        $tipsOnlabel = $value['input_tip'];
                    }

                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'contact_email';
                    $val['display'] = 'public email';
                    $val['rules'] = 'required|valid_email';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . form_input(array('name' => 'contact_email', 'value' => '', 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;
                    
                     case "contactemail":

                    if (empty($value['input_tip'])) {
                        $tipsOnlabel = '';
                    } else {
                        $tipsOnlabel = $value['input_tip'];
                    }

                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'contactemail';
                    $val['display'] = 'contact email';
                    $val['rules'] = 'required|valid_email';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . form_input(array('name' => 'contactemail', 'value' => '', 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;
                case "website":

                    if (empty($value['input_tip'])) {
                        $tipsOnlabel = '';
                    } else {
                        $tipsOnlabel = $value['input_tip'];
                    }

                    /*                     * **an array to feed the validation rules for this input* */
//                    $val['name']='website';
//                    $val['display']='a link to the webiste';
//                    $val['rules']='required';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . form_input(array('name' => 'website', 'value' => '', 'size' => '30')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;

                case "textarea":

                    if (empty($value['input_tip'])) {
                        $tipsOnlabel = '';
                    } else {
                        $tipsOnlabel = $value['input_tip'];
                    }
                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'txtarea';
                    $val['display'] = 'Description(s)';
                    $val['rules'] = 'required';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . form_textarea(array('name' => 'txtarea', 'cols' => '25', 'rows' => '3')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;


                case "location":

                    if (empty($value['input_tip'])) {
                        $tipsOnlabel = '';
                    } else {
                        $tipsOnlabel = $value['input_tip'];
                    }
                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'location';
                    $val['display'] = 'location';
                    $val['rules'] = 'required';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . form_textarea(array('name' => 'location', 'cols' => '25', 'rows' => '3')) . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
                    break;

                case "images":

                    if (empty($value['input_tip'])) {
                        $tipsOnlabel = '';
                    } else {
                        $tipsOnlabel = $value['input_tip'];
                    }

                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'images[]';
                    $val['display'] = 'picture ';
                    $val['rules'] = 'is_file_type[jpg,jpeg,png,gif]';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . '<input type="file" name="images[]" class="images"/>';
                    break;

                case "file":

                    if (empty($value['input_tip'])) {
                        $tipsOnlabel = '';
                    } else {
                        $tipsOnlabel = $value['input_tip'];
                    }

                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'file[]';
                    $val['display'] = 'file ';
                    $val['rules'] = 'required|is_file_type[doc,docx,pdf]';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . '<input type="file" name="file[]" class="images"/>';
                    break;

                case "select":

                    if (empty($value['input_tip'])) {
                        $tipsOnlabel = '';
                    } else {
                        $tipsOnlabel = $value['input_tip'];
                    }
                    $out = '';
                    $repeatselectrtesults = $this->dataFetcher->getAllrepeats();

                    foreach ($repeatselectrtesults->result_array()as $rows) {

                        $out.='<option value="' . $rows['repeat_id'] . '">' . $rows['events'] . '</option>';
                    }
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label) . '<select name="" class="events">' . $out . '</select><div class="events_display"></div>';

                    break;
                case "area":

                    if (empty($value['input_tip'])) {
                        $tipsOnlabel = '';
                    } else {
                        $tipsOnlabel = $value['input_tip'];
                    }
                    $out = '';
                    $area = $this->dataFetcher->loadareas();

                    foreach ($area->result_array()as $rows) {

                        $out.='<option value="' . $rows['area_id'] . '">' . $rows['area_name'] . '</option>';
                    }

                    /*                     * **an array to feed the validation rules for this input* */
                    $val['name'] = 'area[]';
                    $val['display'] = 'area';
                    $val['rules'] = 'required';
                    /*                     * check if label has been modified */
                    if (empty($value['form_label'])) {
                        $label = $value['input_name'];
                    } else {
                        $label = $value['form_label'];
                    }

                    $fieldTobegenerated = form_label($label, $name = "area", $attributes = array('class' => 'area')) . '<select name="area[]" class="events" multiple>' . $out . '</select>' . '</br><i><font color="#1A9B50">' . form_label($tipsOnlabel, $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';

                    break;
                    
                    
                    
                    
                    
                              <li>
              <?php
              echo form_label();
              echo form_checkbox(array('name'=>'validation_chck[]','checked'=>'checked','value'=>'required')).'required';
          
              ?>  
            </li>  
             <li>
              <?php
              echo form_label();
              echo form_checkbox(array('name'=>'validation_chck[]','checked'=>'','value'=>'')).'None';
          
              ?>  
            </li>  
           
            <li>
              <?php
              echo form_label();
              echo form_checkbox(array('name'=>'validation_chck[]','value'=>'valid_email')).'valid email';
              ?>  
            </li> 
            <li>
              <?php
              echo form_label();
              echo form_checkbox(array('name'=>'validation_chck[]','value'=>'is_natural')).'is natural integer';
              ?>  
            </li> 
            <li>
              <?php
              echo form_label();
              echo form_checkbox(array('name'=>'validation_chck[]','value'=>'decimal')).'is decimal';
              ?>  
            </li> 
            <li>
              <?php
              echo form_label();
              echo form_checkbox(array('name'=>'validation_chck[]','value'=>'integer')).'is an integer';
              ?>  
            </li> 
           
            <li>
              <?php
              echo form_label();
              echo form_checkbox(array('name'=>'validation_chck[]','value'=>'numeric')).'is numeric';
              ?>  
            </li> 
             <li>
              <?php
              echo form_label('Matches');
              echo form_input(array('name'=>'matches','value'=>''))
              ?>  
            </li>
             <li>
              <?php
              echo form_label('Is file type');
              echo form_input(array('name'=>'','value'=>'')).'</br><i><font color="#1A9B50">' .
                   form_label("Type the file type extension eg jpg|pdf|docx", $name = "tips", $attributes = array('class' => 'tips')) . '</font></i>';
              ?>  
            </li>
