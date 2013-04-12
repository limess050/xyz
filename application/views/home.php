<div id="main"><!--SIDEBAR LEFT--><div id="sidebar">
  <div id="box_left">
    <h4> Movie schedules     <img src="images/sitewide/blubar.gif" alt="" width="170" height="5" /></h4>
    <ul id="my-movies-carousel" class="jcarousel-skin-tango-movies-carousel">
    <?php foreach($movieSchedulesObj->result() as $movieTheatre):	?>
      <li> <a href="#" ><?php echo $movieTheatre->TheatreName ?><br />
        <?php echo $movieTheatre->Location ?><br /></a>
        <a href="#" ><img class="left" src="http://www.zoomtanzania.com/ListingImages/<?php echo $movieTheatre->Flier  ?>" width="130" height="200" alt="<?php echo $movieTheatre->TheatreName; ?>" /></a>
        </li>

	<?php endforeach; ?>
    </ul>
  </div>
  <div id="box_left">
    <h4>Latest Travel Special<br />
      <img src="images/sitewide/blueline.gif" alt="" width="170" height="5" /></h4>
    <ul class="imageList">
    	<?php $travelSpecial = $travelSpecialObj->row(); ?>
      <li> <a href="#" ><?php echo $travelSpecial->ListingTitle; ?></a>
      	<a href = "#">
        <img class="left" src="http://www.zoomtanzania.com/ListingUploadedDocs/<?php echo $travelSpecial->ELPTypeThumbnailImage; ?>"   alt="<?php echo $travelSpecial->ListingTitle; ?>" />
        </a></li>
    </ul>
  </div><div id="box_left">
    <h4>&nbsp;</h4>
    <ul class="imageList">
      <li></li>
    </ul>
  </div>
</div><!--CONTENT SLIDING EVENTS + CLASSIFIED TABS--><div id="upcomingeventslide">
  <div class="container">
  	<div><h4> Upcoming Special Events<img src="images/sitewide/blubar.gif" alt="" width="540" height="5" /></h4></div>
  	<ul id="mycarousel" class="jcarousel-skin-tango">
    <?php foreach($specialEventsObj->result() as $specialEvent):	?>
  		
    <li>
    	<a href="#"><img src="http://www.zoomtanzania.com/ListingImages/HomepageThumbnails/<?php echo $specialEvent->ELPTypeThumbnailImage ?>" alt="<?php echo $specialEvent->ListingTitle; ?>" width="100"  /></a><br />
    	<a href = "#"><?php echo $specialEvent->ListingTitle ?> <strong><?php echo date('M d', strtotime($specialEvent->EventStartDate)) ?></strong></a>
    </li>
    <?php endforeach; ?>
  </ul>

</div><div class="container_tab">
<ul class="tabs" persist="true">
    <li>CLASSIFIEDS</li>
    <li><a href="#" rel="view1">LATEST</a></li>
    <li><a href="#" rel="view2">MOST VIEW</a></li>
    <li><a href="#" rel="view3">POST FREE</a></li>
    <li><a href="#" rel="view4">TIPS</a></li>
</ul>
        <div class="tabcontents">
           
            <div id="view1" class="classified"> <div class="secondlevelmenu">show only &gt;<a href="#"> JOBS</a> |<a href="#"> VEHICLES </a>| <a href="#">REAL ESTATE</a>|<a href="#">FSBO</a></div>
              
  <ul>
    <li>
      <img src="images/image2.jpg" alt="jobs" width="100" height="60" />
      Headline
      Lorem ipsum dolor sit amet...
    Headline
      Lorem ipsum dolor sit amet...
    Headline
      Lorem ipsum dolor sit amet...
    Headline
      Lorem ipsum dolor sit amet... <span class="viewall"><a href="#">more &gt;</strong></a></span><div class="viewall"><a href="#">view all jobs &gt;</a></div>
    </li>
 
    <li>
      <img src="images/image2.jpg" alt="cars" width="100" height="60" /> Headline
      Lorem ipsum dolor sit amet... Headline
      Lorem ipsum dolor sit amet... Headline
      Lorem ipsum dolor sit amet... <span class="viewall"><a href="#">more &gt;</strong></a></span>
      <div class="viewall"><a href="#">view all vehicles &gt;</a></div></li>
 
    <li>
      <img src="images/image2.jpg" alt="real estate" width="100" height="60" /> Headline Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... <span class="viewall"><a href="#">more &gt;</strong></a></span>
      <div class="viewall"><a href="#">view all real estate&gt;</a></div></li>
 
    <li>
      <img src="images/image2.jpg" alt="fsbo" width="100" height="60" /> Headline
      Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet...  <span class="viewall"><a href="#">more &gt;</strong></a></span>
      <div class="viewall"><a href="#">view all fsbo &gt;</a></div></li>
  </ul>
</div>
            <div id="view2" class="classified"><div class="secondlevelmenu">show only &gt;<a href="#"> JOBS</a> |<a href="#"> VEHICLES </a>| <a href="#">REAL ESTATE</a>|<a href="#">FSBO</a></div>
              
  <ul>
    <li>
      <img src="images/image2.jpg" alt="jobs" width="100" height="60" />
      Headline
      Lorem ipsum dolor sit amet...
    Headline
      Lorem ipsum dolor sit amet...
    Headline
      Lorem ipsum dolor sit amet...
    Headline
      Lorem ipsum dolor sit amet... <span class="viewall"><a href="#">more &gt;</strong></a></span><div class="viewall"><a href="#">view all jobs &gt;</a></div>
    </li>
 
    <li>
      <img src="images/image2.jpg" alt="cars" width="100" height="60" /> Headline
      Lorem ipsum dolor sit amet... Headline
      Lorem ipsum dolor sit amet... Headline
      Lorem ipsum dolor sit amet... <span class="viewall"><a href="#">more &gt;</strong></a></span>
      <div class="viewall"><a href="#">view all vehicles &gt;</a></div></li>
 
    <li>
      <img src="images/image2.jpg" alt="real estate" width="100" height="60" /> Headline Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... <span class="viewall"><a href="#">more &gt;</strong></a></span>
      <div class="viewall"><a href="#">view all real estate&gt;</a></div></li>
 
    <li>
      <img src="images/image2.jpg" alt="fsbo" width="100" height="60" /> Headline
      Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet...  <span class="viewall"><a href="#">more &gt;</strong></a></span>
      <div class="viewall"><a href="#">view all fsbo &gt;</a></div></li>
  </ul>
</div>
           <div id="view3" class="classified">
             <div class="secondlevelmenu"><a href="#">POST FREE CLASSIFIED</a><a href="#"></a></div>
  <ul>
    <li>
      <img src="images/logo_zoomtanzania.gif" width="100" height="70" />
      Headline
      Lorem ipsum dolor sit amet...
    Headline
      Lorem ipsum dolor sit amet...
    Headline
      Lorem ipsum dolor sit amet...
    Headline
      Lorem ipsum dolor sit amet...<span><a href="#">more &gt;</a></span>
    </li>
 
    <li><img src="images/logo_zoomtanzania.gif" alt="" width="100" height="70" /> Headline
      Lorem ipsum dolor sit amet... Headline
      Lorem ipsum dolor sit amet... Headline
      Lorem ipsum dolor sit amet... <span><a href="#">more &gt;</a></span></li>
 
    <li>
      <img src="images/logo_zoomtanzania.gif" alt="" width="100" height="70" /> Headline Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... <span><a href="#">more &gt;</a></span></li>
 
    <li>
      <img src="images/logo_zoomtanzania.gif" alt="" width="100" height="70" /> Headline
      Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... <span><a href="#">more &gt;</a></span></li>
  </ul>
</div>
            <div id="view4" class="classified">
              <div class="secondlevelmenu"><a href="#">TIPS</a><a href="#"></a></div>
  <ul>
    <li>
      <img src="images/event3.jpg" width="100" height="70" />
      Headline
      Lorem ipsum dolor sit amet...
    Headline
      Lorem ipsum dolor sit amet...
    Headline
      Lorem ipsum dolor sit amet...
    Headline
      Lorem ipsum dolor sit amet...<span><a href="#">more &gt;</a></span>
    </li>
 
    <li>
      <img src="images/event3.jpg" alt="" width="100" height="70" /> Headline
      Lorem ipsum dolor sit amet... Headline
      Lorem ipsum dolor sit amet... Headline
      Lorem ipsum dolor sit amet... <span><a href="#">more &gt;</a></span></li>
 
    <li>
      <img src="images/event3.jpg" alt="" width="100" height="70" /> Headline Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... <span><a href="#">more &gt;</a></span></li>
 
    <li>
      <img src="images/event3.jpg" alt="" width="100" height="70" /> Headline
      Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... Headline Lorem ipsum dolor sit amet... <span><a href="#">more &gt;</a></span></li>
  </ul>
</div>
        </div>
    </div>
		



</div><!-- SIDEBAR RIGHT--><div id="sidebar2"><div id="box_banner">
    

        <img  src="images/home/hp_socialnetwork_new.jpg" height="200" alt="" />  <!-- AddThis Button BEGIN -->
<div class="addthis_toolbox addthis_default_style addthis_32x32_style" align="right">
<a class="addthis_button_facebook"></a>
<a class="addthis_button_twitter"></a>
<a class="addthis_button_google_plusone_share"></a>
<a class="addthis_button_stumbleupon"></a>
<a class="addthis_button_reddit"></a>
<a class="addthis_button_linkedin"></a>
</div>
<script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=undefined"></script>
<!-- AddThis Button END -->
  </div><div id="box_left">
    <h4>Latest Featured Business<br />
      <img src="images/sitewide/blueline.gif" alt="" width="170" height="5" /></h4>
    <ul class="imageList">
    	<?php $featuredListing= $featuredBusinessObj->row(); ?>
      	<li><a href="#" ><?php echo $featuredListing->ListingTitle; ?></a>
        <a href="#" ><img class="left" src="http://www.zoomtanzania.com/ListingUploadedDocs/<?php echo $featuredListing->LogoImage ?>" width="141"  alt="" /><br />
         </a></li>
    </ul>

</div></div>
  
  </div>