<?php
/*
 * The contents of this file are subject to beyond Meetings Manager Public license you may not use or change this file except in
  compliance with the License. You may obtain a copy of the License by emailing this address udsmmeetingmanager@googlegroups.com
 * @author vincent daud
  @email vincentdaudi@gmail.com
 */
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en-US" xml:lang="en">
    <head>
        <base href ="<?php echo base_url(); ?>" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <link></link>
         <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
        <script type='text/javascript' src="js/jquery-ui-1.8.18.custom.min.js"></script>
        <script type="text/javascript" src="js/validate.js"></script>
        <link href="styles/default.css" rel="stylesheet"/>
        <link href="styles/ui-lightness/jquery-ui-1.8.18.custom.css" rel="stylesheet"/>
        <!--...date picker trigger.-->

        <script type="text/javascript">
            
            $(function(){
                // Datepicker
                $('.datepicker').datepicker({
                    inline: true
                });
                //date picker for the year ranges
                $('.datepickeryear').datepicker({
                    inline: true,
                    changeYear:true
                });
                $('.datepickeryear').datepicker("option","dateFormat","yy");
                //hover states on the static widgets
                $('#dialog_link, ul#icons li').hover(
                function() { $(this).addClass('ui-state-hover'); },
                function() { $(this).removeClass('ui-state-hover'); }
            );
            }); 
            
            
            
            
            
            $(document).ready(function()
            {
                $(".section").change(function()
                {
                    var id=$(this).val();
                    var dataString = 'id='+ id;

                    $.ajax
                    ({
                        type: "POST",
                        url: "<?php echo base_url(); ?>index.php/formgenerator/setSectionId/",
                        data: dataString,
                        cache: false,
                        success: function(html)
                        {
                            $(".categories").html(html);
                            
                            ///function to autoload the categories from subsection
                            $(".autoloadcat").change(function()
                            {
                                var id=$(this).val();
                                var dataString = 'catid='+ id;

                                ///if the subsection categories present load the categories
                                $.ajax
                                ({
                                    type: "POST",
                                    url: "<?php echo base_url(); ?>index.php/formgenerator/selectCategory/",
                                    data: dataString,
                                    cache: false,
                                    success: function(html)
                                    {
                                        $(".subcat").html(html);
                                        dataType:html;
                                    }
                                });

                            });
                            
                            
                            
                        }
                    });

                });
                //////////////////////////////////////////////////
                
                //searching algorithm goes here
                $(".searchsection").change(function()
                {
                    var id=$(this).val();
                    var dataString = 'id='+ id;

                    $.ajax
                    ({
                        type: "POST",
                        url: "<?php echo base_url();?>index.php/mastersearch/searchfilter/",
                        data: dataString,
                        cache: false,
                        success: function(html)
                        {
                            $(".searchcategory").html(html);
                            
                            ///function to autoload the categories from subsection
                            $(".autoloadcat").change(function()
                            {
                                var id=$(this).val();
                                var dataString = 'catid='+ id;

                                ///if the subsection categories present load the categories
                                $.ajax
                                ({
                                    type: "POST",
                                    url: "<?php echo base_url();?>index.php/mastersearch/selectCategory/",
                                    data: dataString,
                                    cache: false,
                                    success: function(html)
                                    {
                                        $(".subcategories").html(html);
                                        ///function to autoload the categories from subsection
                                     
                                        dataType:html;
                                    }
                                });

                            });
                            
                            
                            
                        }
                    });

                });
                
                //
                   
                
                $(".events").change(function()
                {
                    var id=$(this).val();
                    var dataString = 'e_id='+ id;

                    $.ajax
                    ({
                        type: "POST",
                        url: "<?php echo base_url(); ?>index.php/formgenerator/selectEventsRepeat/",
                        data: dataString,
                        cache: false,
                        success: function(html)
                        {
                            $(".events_display").html(html);
                        }
                    });

                });
              
            });

        </script>


    </head>
    <body>
  <!--..navigation menu .-->
    <div id="menu">
        <?php
        $this->load->view('formgenerator/menu');
        ?>
    </div>