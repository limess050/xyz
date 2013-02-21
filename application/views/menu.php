<ul id="menu">
    <li><a href="#" >Home</a></li>
    <li><a href="#" class="drop">Business Directory</a><!-- Begin Home Item -->
        <div class="dropdown_5columns"><!-- Begin 5 columns container  -->
        
            <div class="col_5">
                <h2>Tanzania Business Directory</h2>
            </div>

            <?php $first = 0; foreach ($biz->result() as $section): ?>
            
            <?php if($first == 0): ?>
                <div class="col_1">
                <ul class="greybox">
            <?php endif; ?>

                    <li><a href="#"><?php echo $section->Title; ?></a></li>

             <?php $first++; ?>

             <?php if($first == 8): ?>

             <?php $first = 0; ?>

                </ul>  
            </div>
            <?php endif; ?>
            <?php endforeach; ?> 
            
            
          <div class="col_2">
            
                <p class="black_box">
                    <img src = "images/home/abstract-2.jpg" height=90 width=250 class = "center_image" />

                    Procurement made easy! Learn how to request a quote from up to 6 business at one time > <a href = "">Click Here</a>
                    </p>
                <p class="black_box">
                    <img src = "images/home/abstract-2.jpg" height=90 width=250  class = "center_image"/>

                    Is your business listed? Top ten reasons to list your business > <a href = "">Click Here</a>
                </p>
            </div>
        
            
        
        </div>

    
    </li><!-- End Home Item -->
    <li><a href="#" class="drop">Tourism Directory</a>
<div class="dropdown_5columns"><!-- Begin 5 columns container  -->
        
            <div class="col_5">
                <h2>Tanzania Tourism Directory</h2>
            </div>

            <?php $first = 0; foreach ($tours->result() as $section): ?>
            
            <?php if($first == 0): ?>
                <div class="col_1">
                <ul class="greybox">
            <?php endif; ?>

                    <li><a href="<?php echo $section->URLSafeTitleDashed ?>"><?php echo $section->Title; ?></a></li>

             <?php $first++; ?>

             <?php if($first == 8): ?>

             <?php $first = 0; ?>

                </ul>  
            </div>
            <?php endif; ?>
            <?php endforeach; ?> 
            <?php if($first != 8): ?>
                </ul>  
            </div>
            <?php endif; ?>
            
          <div class="col_2">
            
                <p class="black_box">
                    <img src = "images/home/abstract-2.jpg" height=90 width=250 class = "center_image" />

                    Procurement made easy! Learn how to request a quote from up to 6 business at one time > <a href = "">Click Here</a>
                    </p>
                <p class="black_box">
                    <img src = "images/home/abstract-2.jpg" height=90 width=250  class = "center_image"/>

                    Is your business listed? Top ten reasons to list your business > <a href = "">Click Here</a>
                </p>
            </div>
        
            
        
        </div>

    </li>
    <li><a href="#" >Restaurants & Nightlife</a></li>
    <li><a href="#" class="drop">Arts & Entertainment</a><!-- Begin 4 columns Item -->
    
        <div class="dropdown_4columns"><!-- Begin 4 columns container -->
        
            <div class="col_4">
                <h2>This is a heading title</h2>
            </div>
            
            <div class="col_1">
            
                <h3>Some Links</h3>
                <ul>
                    <li><a href="#">ThemeForest</a></li>
                    <li><a href="#">GraphicRiver</a></li>
                    <li><a href="#">ActiveDen</a></li>
                    <li><a href="#">VideoHive</a></li>
                    <li><a href="#">3DOcean</a></li>
                </ul>   
                 
            </div>
    
            <div class="col_1">
            
                <h3>Useful Links</h3>
                <ul>
                    <li><a href="#">NetTuts</a></li>
                    <li><a href="#">VectorTuts</a></li>
                    <li><a href="#">PsdTuts</a></li>
                    <li><a href="#">PhotoTuts</a></li>
                    <li><a href="#">ActiveTuts</a></li>
                </ul>   
                 
            </div>
    
            <div class="col_1">
            
                <h3>Other Stuff</h3>
                <ul>
                    <li><a href="#">FreelanceSwitch</a></li>
                    <li><a href="#">Creattica</a></li>
                    <li><a href="#">WorkAwesome</a></li>
                    <li><a href="#">Mac Apps</a></li>
                    <li><a href="#">Web Apps</a></li>
                </ul>   
                 
            </div>
    
            <div class="col_1">
            
                <h3>Misc</h3>
                <ul>
                    <li><a href="#">Design</a></li>
                    <li><a href="#">Logo</a></li>
                    <li><a href="#">Flash</a></li>
                    <li><a href="#">Illustration</a></li>
                    <li><a href="#">More...</a></li>
                </ul>   
                 
            </div>
            
        </div><!-- End 4 columns container -->
    
    </li><!-- End 4 columns Item -->

 <!--    <li class="menu_right"><a href="#" class="drop">Events</a> -->
	<li><a href="#" class="drop">Events</a>
    
		<div class="dropdown_1column align_right">
        
                <div class="col_1">
                
                    <ul class="simple">
                        <li><a href="#">FreelanceSwitch</a></li>
                        <li><a href="#">Creattica</a></li>
                        <li><a href="#">WorkAwesome</a></li>
                        <li><a href="#">Mac Apps</a></li>
                        <li><a href="#">Web Apps</a></li>
                        <li><a href="#">NetTuts</a></li>
                        <li><a href="#">VectorTuts</a></li>
                        <li><a href="#">PsdTuts</a></li>
                        <li><a href="#">PhotoTuts</a></li>
                        <li><a href="#">ActiveTuts</a></li>
                        <li><a href="#">Design</a></li>
                        <li><a href="#">Logo</a></li>
                        <li><a href="#">Flash</a></li>
                        <li><a href="#">Illustration</a></li>
                        <li><a href="#">More...</a></li>
                    </ul>   
                     
                </div>
                
        </div>
        
    </li>
    <li ><a href="#" class="drop">Classifieds</a><!-- Begin 3 columns Item -->
    
        <div class="dropdown_3columns align_right"><!-- Begin 3 columns container -->
            
            <div class="col_3">
                <h2>Lists in Boxes</h2>
            </div>
            
            <div class="col_1">
    
                <ul class="greybox">
                    <li><a href="#">FreelanceSwitch</a></li>
                    <li><a href="#">Creattica</a></li>
                    <li><a href="#">WorkAwesome</a></li>
                    <li><a href="#">Mac Apps</a></li>
                    <li><a href="#">Web Apps</a></li>
                </ul>   
    
            </div>
            
            <div class="col_1">
    
                <ul class="greybox">
                    <li><a href="#">ThemeForest</a></li>
                    <li><a href="#">GraphicRiver</a></li>
                    <li><a href="#">ActiveDen</a></li>
                    <li><a href="#">VideoHive</a></li>
                    <li><a href="#">3DOcean</a></li>
                </ul>   
    
            </div>
            
            <div class="col_1">
    
                <ul class="greybox">
                    <li><a href="#">Design</a></li>
                    <li><a href="#">Logo</a></li>
                    <li><a href="#">Flash</a></li>
                    <li><a href="#">Illustration</a></li>
                    <li><a href="#">More...</a></li>
                </ul>   
    
            </div>
            
            <div class="col_3">
                <h2>Here are some image examples</h2>
            </div>
            
            <div class="col_3">
                <img src="img/02.jpg" width="70" height="70" class="img_left imgshadow" alt="" />
                <p>Maecenas eget eros lorem, nec pellentesque lacus. Aenean dui orci, rhoncus sit amet tristique eu, tristique sed odio. Praesent ut interdum elit. Maecenas imperdiet, nibh vitae rutrum vulputate, lorem sem condimentum.<a href="#">Read more...</a></p>
    
                <img src="img/01.jpg" width="70" height="70" class="img_left imgshadow" alt="" />
                <p>Aliquam elementum felis quis felis consequat scelerisque. Fusce sed lectus at arcu mollis accumsan at nec nisi. Aliquam pretium mollis fringilla. Vestibulum tempor facilisis malesuada. <a href="#">Read more...</a></p>
            </div>
        
        </div><!-- End 3 columns container -->
        
    </li><!-- End 3 columns Item -->
    <!-- <li><a href="#" >Zoom Pons</a></li> -->
    <li><a href="#" >How to Zoom</a></li>
    <li><a href="#" >About TZ</a></li>

<!--     <li><a href="#" class="drop">Jobs</a><!-- Begin 5 columns Item -
    
        <div class="dropdown_5columns"><!-- Begin 5 columns container 
        
            <div class="col_5">
                <h2>This is an example of a large container with 5 columns</h2>
            </div>
            
            <div class="col_1">
                <p class="black_box">This is a dark grey box text. Fusce in metus at enim porta lacinia vitae a arcu. Sed sed lacus nulla mollis porta quis.</p>
            </div>
            
            <div class="col_1">
                <p>Phasellus vitae sapien ac leo mollis porta quis sit amet nisi. Mauris hendrerit, metus cursus accumsan tincidunt.</p>
            </div>
            
            <div class="col_1">
                <p class="italic">This is a sample of an italic text. Consequat scelerisque. Fusce sed lectus at arcu mollis accumsan at nec nisi porta quis sit amet.</p>
            </div>
            
            <div class="col_1">
                <p>Curabitur euismod gravida ante nec commodo. Nunc dolor nulla, semper in ultricies vitae, vulputate porttitor neque.</p>
            </div>
            
            <div class="col_1">
                <p class="strong">This is a sample of a bold text. Aliquam sodales nisi nec felis hendrerit ac eleifend lectus feugiat scelerisque.</p>
            </div>
        
            <div class="col_5">
                <h2>Here is some content with side images</h2>
            </div>
           
            <div class="col_3">
            
                <img src="img/01.jpg" width="70" height="70" class="img_left imgshadow" alt="" />
                <p>Maecenas eget eros lorem, nec pellentesque lacus. Aenean dui orci, rhoncus sit amet tristique eu, tristique sed odio. Praesent ut interdum elit. Sed in sem mauris. Aenean a commodo mi. Praesent augue lacus.<a href="#">Read more...</a></p>
        
                <img src="img/02.jpg" width="70" height="70" class="img_left imgshadow" alt="" />
                <p>Aliquam elementum felis quis felis consequat scelerisque. Fusce sed lectus at arcu mollis accumsan at nec nisi. Aliquam pretium mollis fringilla. Nunc in leo urna, eget varius metus. Aliquam sodales nisi.<a href="#">Read more...</a></p>
            
            </div>
            
            <div class="col_2">
            
                <p class="black_box">This is a black box, you can use it to highligh some content. Sed sed lacus nulla, et lacinia risus. Phasellus vitae sapien ac leo mollis porta quis sit amet nisi. Mauris hendrerit, metus cursus accumsan tincidunt.Quisque vestibulum nisi non nunc blandit placerat. Mauris facilisis, risus ut lobortis posuere, diam lacus congue lorem, ut condimentum ligula est vel orci. Donec interdum lacus at velit varius gravida. Nulla ipsum risus.</p>
            
            </div>
        
        </div><End 5 columns container 
    
    </li>< End 5 columns Item --> 


    <!-- <li class="menu_right"><a href="#" class="drop">Classifieds</a><!-- Begin 3 columns Item --> 


</ul>