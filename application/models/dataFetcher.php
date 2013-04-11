<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

class DataFetcher extends CI_Model {

    /**
     * @method :method to load all existed sections
     * @param :none
     * @return results
     * 
     */
    public function sectionsLoader() {

        $sql = "select* from sections where ParentSectionID is null order by Title";
        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * @method :select specific subsection if existing
     * @param: section id
     * @return subsection
     *  
     */
    public function subsectionLoader($id) {

        $sql = "select * from sections where 
           ParentSectionID ='$id' order by Title";
        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * 
     * @Method : load all the categories
     * @param section Id
     * @return results
     */
    public function categoriesLoaderwithoutsubsections($id) {

        $sql = "select * , categories.Title as Title
        from categories
        inner join sections 
        on categories.SectionID=sections.SectionID
        where sections.SectionID='$id' UNION select * , categories.Title as Title
        from categories
        inner join sections 
        on categories.ParentSectionID=sections.SectionID
        where sections.ParentSectionID='$id' ";

        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * 
     * @Method : Load all the categories
     * @param section Id
     * @return results
     */
    public function categoriesLoader($id, $subcatid) {

        $sql = "select categories.Title as categoryTitle,categories.CategoryID,sections.SectionID 
        from categories
        inner join sections 
        on categories.ParentSectionID=sections.ParentSectionID
        where sections.ParentSectionID='$id' and
              categories.SectionID='$subcatid'";

        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * 
     * @Method : Load all the categories
     * @param section Id
     * @return results
     */
////////////////////////////////////////////////////////////////////////////////////////
    public function categoriesautoLoader($subsectionid) {

        $sql = "select *, categories.Title as Title
        from categories
        inner join sections 
        on categories.SectionID=sections.SectionID
        where  categories.SectionID='$subsectionid'";

        $results = $this->db->query($sql);
        return $results;
    }

////////////////////////////////////////////////////////////////////////////////////////
    /**
     * @method load the input types
     * @param none
     * @return results 
     */
    public function inputTypesLoader() {

        $sql = "select* from input_type_tbl";
        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * @method :select form title
     *  @param section id
     * @return results (form title)
     * 
     */
    public function getformTitle($id) {

        $sql = "select section_name from section_tbl where section_id='$id'";
        $results = $this->db->query($sql);

        if ($results) {

            $name = '';
            foreach ($results->result_array() as $value) {

                $name = $value['section_name'];
            }
            return $name;
        } else {
            return FALSE;
        }
    }

    /**
     * @method :Insert forms name
     * @param section id
     * @return return form id
     * 
     */
    public function insertFormsTitle($section) {

        $title = $this->getformTitle($section);
        $sql = "insert into forms_titles(title) values('$title')";
        $results = $this->db->query($sql);
        $id = $this->db->insert_id();
        return $id;
    }

    ////////////////////////////////////////the discarded algorithm//////////////////////////////////////////////////////////////
    /**
     * @method :Insertion of pre-generated form settings
     * @param: variables
     * @return boolean
     * 
     */
    public function insertFormSettings($selections, $section, $categories_selected) {

        $count = 0;

        $last_inserted_ids = array();
        $data = array();


        foreach ($categories_selected as $key => $value) {
            $sectionId = $section;
            $categoryId = $value;
            $form_id = $this->insertFormsTitle($sectionId);
            //getting selected check box and their corresponding values

            array_push($last_inserted_ids, $form_id);

            foreach ($selections as $key => $value) {
                if (!empty($value)) {
                    $checkBoxIndex = $key;
                    $checkBoxSelectedValue = $value;


                    $sql = "INSERT INTO form_tbl(form_id,category_id,section_id,no_input,input_type_id)
              VALUES('$form_id',$categoryId,'$sectionId',$checkBoxSelectedValue,$checkBoxIndex)";

                    $results = $this->db->query($sql);

                    if ($results) {
                        $count++;
                    }
                }
            }
        }


        $data['last_inserted_ids'] = $last_inserted_ids;
        $data['results'] = $count;

        return $data;
    }

    /////////////////////////////////////////end////////////////////////////////////////////// 
    /**
     * @method :get last inserted form
     * @param : Variables
     * @return results
     * 
     * 
     * */
    public function getFormDetails($formids) {



        $sql = "select label_name,input_tip,forms_titles.form_id,input_name,input_type,max_no_inputs,no_input,title from section_tbl,input_type_tbl,form_label_name_tbl,categories,forms_titles,form_tbl 
          where forms_titles.form_id=form_tbl.form_id and
          section_tbl.section_id=categories.section_id and
          form_tbl.section_id=section_tbl.section_id and
          form_label_name_tbl.input_id=form_tbl.input_type_id and
          
          form_tbl.category_id =categories.cat_id and
          input_type_tbl.input_id=form_tbl.input_type_id and
          forms_titles.form_id='$formids'
          ";
        $results = $this->db->query($sql);

        return $results;
    }

    /**
     * 
     * @method: get section name
     * @param: form id
     * @return section name
     */
    public function getSectionName($formId) {
        $sql = "select distinct(section_name) from form_tbl,section_tbl,forms_titles
         where form_tbl.form_id=forms_titles.form_id and
         section_tbl.section_id=form_tbl.section_id and
         form_tbl.form_id='$formId'";
        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * @method : fetch form details
     * @param : 
     * @return results
     * 
     * */
    public function getfomdetails() {

        $sql = "select distinct cat_name,category_id from categories,form_tbl,input_type_tbl where 
        categories.cat_id=form_tbl.category_id and
        input_type_tbl.input_id=form_tbl.input_type_id
        ";
        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * @method :load subsections
     * @param: none
     * @return results
     * 
     */
    public function loadSubsection($id) {

        $sql_new = "select distinct categories.Title as categoryTitle,CategoryID,category_id from form_tbl,categories
        where categories.CategoryID=form_tbl.category_id and
        categories.CategoryID='$id'";
        $results = $this->db->query($sql_new);
        return $results;
    }

    /*     * load section name and id for sections with no subsections */

    public function loadsection($id) {

        $sql = "select distinct categories.Title as categoryTitle,CategoryID from form_tbl,categories where
          form_tbl.sections_without_subsections=categories.SectionID and
          form_tbl.category_id=categories.CategoryID and
          form_tbl.sections_without_subsections='$id'
           ";

        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * @method: get specific form category information
     * @param:  category id
     * @return results
     * 
     */
    public function categoryDetails($id) {
        $data = array();

//        $sql =" select * from categories,form_tbl,input_type_tbl where 
//         form_tbl.category_id=categories.cat_id and
//        input_type_tbl.input_id=form_tbl.input_type_id and
//        form_tbl.category_id='$id' order by displayOrder asc";

        $sql = "SELECT *
         FROM categories, form_tbl, input_type_tbl
          WHERE form_tbl.category_id = categories.CategoryID
          AND input_type_tbl.input_id = form_tbl.input_type_id
          AND form_tbl.category_id ='$id'
          ORDER BY displayOrder ASC";
        $results = $this->db->query($sql);

        //echo $this->db->last_query();

        foreach ($results->result_array() as $value) {

            $category_name = $value['Title'];
            $category_id = $value['CategoryID'];
        }
        $data['results'] = $results;
        $data['catid'] = $category_id;
        $data['category'] = $category_name;
        return $data;
    }

    /**
     * @method: get specific form category information
     * @param:  category id
     * @return results
     * 
     */
    public function subcategoryDetails($id) {
        $data = array();
        $category_name = '';
        $sql = "select*,categories.Title as CategoryName from sections,form_tbl,categories,input_type_tbl where 
        sections.SectionID=categories.ParentSectionID and
        categories.SectionID=form_tbl.sections_without_subsections and
        input_type_tbl.input_id=form_tbl.input_type_id and
        form_tbl.category_id=categories.CategoryID and
        form_tbl.category_id='$id' order by displayOrder Asc
        ";
        $results = $this->db->query($sql);

        foreach ($results->result_array() as $value) {

            $category_name = $value['CategoryName'];
            $category_id = $value['CategoryID'];
        }
        $data['results'] = $results;
        $data['category'] = $category_name;
        $data['catid'] = $category_id;
        return $data;
    }

    /**
     * @method :load  repeat events
     * @param :none
     * @return results
     * 
     */
    public function getrepeats($id) {
        $sql = "select * from repeatevents where repeatevents.repeat_id='$id'";
        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * @method :load all options for repeat events
     * @param :none
     * @return results
     * 
     */
    public function getAllrepeats() {
        $results = $this->db->get('repeatevents');
        return $results;
    }

    public function generatedformsInformations() {

        $sql_new = "select distinct sections_without_subsections,cat_name,category_id,cat_id from categories,form_tbl 
              where 
              categories.cat_id=form_tbl.category_id
              ";
        $results = $this->db->query($sql_new);
        return $results;
    }

    /**
     * @method :
     * @param :
     * @return results
     * 
     * 
     */
    public function sectionCategory($sectionid) {

        $sql_new = "select distinct sections_without_subsections,Title,category_id,CategoryID from categories,form_tbl 
              where 
              categories.CategoryID=form_tbl.category_id and
              categories.ParentSectionID='$sectionid'
              ";
        $results = $this->db->query($sql_new);
        return $results;
    }

    /*     * * editig functions */

    /**
     * @method :select section name and id
     * @param category id
     * @return results
     * 
     */
    public function loadsectionFromcategory($cat_id) {

        $sql = "select distinct sections.SectionID as SecID,sections.Title as sectionTitle from form_tbl,sections,categories
          where 
          sections.SectionID=categories.ParentSectionID and
          form_tbl.category_id=categories.CategoryID and
          form_tbl.category_id='$cat_id' 
          ";
        $results = $this->db->query($sql);

       // echo $this->db->last_query();
        return $results;
    }

    /**
     *
     * @method :get form informations from category id
     * @param :category id
     * @return results
     *  
     * */
    public function getSectionSubsections($sectionid, $catid) {
        $sql = "select distinct categories.ParentSectionID,sections.Title as subSectionTitle,categories.Title as categoryTitle,categories.CategoryID,sections.SectionID from sections,categories where
                categories.ParentSectionID='$sectionid' and
                sections.SectionID=categories.SectionID and    
                categories.CategoryID='$catid'
          ";
        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * @method :delete the category
     * @param :category id
     * @return boolen
     * 
     */
    public function deletecateggory($id) {

        $sql = "delete from form_tbl where category_id='$id'";
        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * @method : load section from for forms created
     * @param none
     * @return results
     * 
     */
    public function formsCreatedSections() {
        $sql = "select distinct sections.Title as sectionTitle,sections.SectionID as SecID, sections.ParentSectionID from sections,form_tbl,categories
        where 
        categories.CategoryID=form_tbl.category_id and
        categories.ParentSectionID=sections.SectionID";
        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * @method: load areas
     * @param :none
     * @return results
     * 
     */
    public function loadareas() {

        $sql = "select*from area_tbl";
        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * 
     * @method :add form inputs types
     * @param :none
     * @return  boolean
     * 
     * 
     */
    public function addFormInputsTypes($inputname, $formfieldtype, $max_no_inputs, $fieldtypename, $validation_chkboxes, $tablename, $tablecolumnid, $tabledisplaycolumn) {
        ///insert validation rules in a db
        //check if form field type is select
        if (strcasecmp($formfieldtype, "select") == 0) {
            $columnid = $tablecolumnid;
            $displayid = $tabledisplaycolumn;
            $table = $tablename;
        } else {
            $columnid = '';
            $displayid = '';
            $table = '';
        }

        $sql = "insert into input_type_tbl(input_name,input_type,max_no_inputs,fieldtypename,draws_from,column_id,display_id)
        values('$inputname','$formfieldtype','$max_no_inputs','$fieldtypename','$table','$columnid','$displayid')";
        $results = $this->db->query($sql);
        $lastid = $this->db->insert_id($results);
        if ($results) {
            foreach ($validation_chkboxes as $value) {
                $sql = "insert into validation_rules_handler_tbl(input_type_id,rule_name)values('$lastid','$value')";
                $results = $this->db->query($sql);
            }
        }
        return $results;
    }

    /**
     * @method :list all input ty;pes present
     * @param :none
     * @return results
     * 
     */
    public function listAllInputstypes() {
        $sql = "select * from input_type_tbl order by  input_id desc";
        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * @method : load input types details
     * @param  : id
     * @return results
     */
    public function loadInputTypesDetails($id) {
        $sql = "select * from input_type_tbl where input_id='$id'";
        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * @method: Update input types details
     * @param :variable
     * @return boolean
     * 
     */
    public function updateInputsTypesDetails($inputname, $formfieldtype, $max_no_inputs, $fieldtypename, $validation_chkboxes, $tablename, $tablecolumnid, $tabledisplaycolumn, $id) {

        if (strcasecmp($formfieldtype, "select") == 0) {
            $columnid = $tablecolumnid;
            $displayid = $tabledisplaycolumn;
            $table = $tablename;
        } else {
            $columnid = '';
            $displayid = '';
            $table = '';
        }

        $sql = "update input_type_tbl set input_name='$fieldtypename',input_type='$formfieldtype',draws_from='$tablename',max_no_inputs='$max_no_inputs',fieldtypename='$fieldtypename',column_id='$tablecolumnid',display_id='$tabledisplaycolumn' where input_id='$id'";
        $results = $this->db->query($sql);

        if ($results) {
            //update the validation rules
            ///delete then insert
            $sql_delete = "delete from validation_rules_handler_tbl where input_type_id='$id'";
            $results_delete = $this->db->query($sql_delete);

            if ($results_delete) {
                foreach ($validation_chkboxes as $value) {
                    $sql = "insert into validation_rules_handler_tbl(input_type_id,rule_name)values('$id','$value')";
                    $results = $this->db->query($sql);
                }
            }
        }
        return $results;
    }

    /**
     * @method : remove input type
     * @param :id
     * @return Id
     */
    public function deleteInput($id) {

        if (!empty($id)) {
            $sql_validationremove = "delete from validation_rules_handler_tbl where input_type_id='$id'";
            $remover_results = $this->db->query($sql_validationremove);
            if ($remover_results) {

                $sql = "delete from input_type_tbl where input_type_tbl.input_id='$id'";
                $results = $this->db->query($sql);

                return $results;
            } else {
                return FALSE;
            }
        }
    }

    /**
     * @method :load validation rules per input
     * @param :input id
     * @return results
     */
    public function loadsValidationrules($inputid) {
        $sql = "select rule_name from validation_rules_handler_tbl where input_type_id='$inputid'";
        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * @method :load validation rules per input
     * @param :input id
     * @return results
     */
    public function loadsValidationrulesByName($inputname, $inputid) {
        $sql = "select rule_name from validation_rules_handler_tbl where input_type_id='$inputid'and
                validation_rules_handler_tbl.rule_name='$inputname'
           ";
        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * 
     * @method : select from table
     * @param :table name
     * @return results
     * 
     * 
     */
    public function selecTfromTable($table) {
        $sql = "select * from $table";
        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * @method :load validations rules
     * @param : none
     * @return results
     * 
     */
    public function loadInputValidations() {
        $sql = "select* from forminputvalidationrules";
        $results = $this->db->query($sql);
        return $results;
    }

    /**
     * @method :load the results for draw from column
     * @param : input_type id
     * @return results
     * 
     */
    public function drawsFromColumn($id) {
        $sql = "select draws_from,column_id,display_id from input_type_tbl where input_type_tbl.input_id='$id'";
        $results = $this->db->query($sql);
        return $results;
    }
    
    /***
     * @method :load input to be displayed on select dropdowns
     * @param :none
     * @return results
     * 
     */
    public function loadSelectInputTypes() {
        $sql="select* from selectinputtypes";
        $results=$this->db->query($sql);
        return $results;
        
    }
     /***
     * @method :load input to be displayed on select dropdowns
     * @param :none
     * @return results
     * 
     */
    public function loadSelectInputTypesByid($id) {
        $sql="select* from input_type_tbl where input_id='$id'";
        $results=$this->db->query($sql);
        return $results;
        
    }

}

?>
