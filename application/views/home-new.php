	<!--MAIN CONTENT!--><div id="main"><!--FIRST ROW TOP-->
	<div id="homerow1">
<div id="box_left">
    <h4> Movie schedules     <img src="images/sitewide/blubar.gif" alt="" width="170" height="5" /></h4>
    <ul id="my-movies-carousel" class="jcarousel-skin-tango-movies-carousel">
    <?php foreach($movieSchedulesObj->result() as $movieTheatre): ?>
      <li> <a href="#" ><?php echo $movieTheatre->TheatreName ?><br />
        <?php echo $movieTheatre->Location ?><br /></a>
        <a href="#" ><img class="left" src="http://www.zoomtanzania.com/ListingImages/<?php echo $movieTheatre->Flier  ?>" width="130" height="200" alt="<?php echo $movieTheatre->TheatreName; ?>" /></a>
        </li>

  <?php endforeach; ?>
    </ul>
  </div>

  <div class="container">

        <div><h4> Upcoming Special Events<img src="images/sitewide/blubar.gif" alt="" width="540" height="5" /></h4></div>
    <ul id="mycarousel" class="jcarousel-skin-tango">
    <?php foreach($specialEventsObj->result() as $specialEvent):  ?>
      
    <li>
      <a href="#"><img src="http://www.zoomtanzania.com/ListingImages/HomepageThumbnails/<?php echo $specialEvent->ELPTypeThumbnailImage ?>" alt="<?php echo $specialEvent->ListingTitle; ?>" width="100"  /></a><br />
      <a href = "#"><?php echo $specialEvent->ListingTitle ?> <strong><?php echo date('M d', strtotime($specialEvent->EventStartDate)) ?></strong></a>
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
  </div>
</div><!--SECONND CONTENT ROW + CLASSIFIED TABS-->
<div id="homerow2"><div id="box_left">
    <h4>Latest Featured Business<br />
      <img src="images/sitewide/blueline.gif" alt="" width="170" height="5" /></h4>
    <ul class="imageList">
      <?php $featuredListing= $featuredBusinessObj->row(); ?>
        <li><a href="#" ><?php echo $featuredListing->ListingTitle; ?></a>
        <a href="#" ><img class="left" src="http://www.zoomtanzania.com/ListingUploadedDocs/<?php echo $featuredListing->LogoImage ?>" width="141"  alt="" /><br />
         </a></li>
    </ul>

</div><div class="precontainer_tab"><div class="container_tab">
<ul class="tabs" persist="true"  style = "color:#fff">
            <li><a href="#" rel="view1">LATEST</a></li>
            <li><a href="#" rel="view2">MOST VIEW</a></li>
            <li><a href="#" rel="view3">POST FREE</a></li>
            <li><a href="#" rel="view4">TIPS</a></li>
        </ul>
        <div class="tabcontents">
           
            <div id="view1" class="classified"> <div class="secondlevelmenu"  style = "color:#fff">show only &gt;<a href="#"> JOBS</a> |<a href="#"> VEHICLES </a>| <a href="#">REAL ESTATE</a>|<a href="#">CLASSIFIEDS</a></div>
              
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
            <div id="view2" class="classified"><div class="secondlevelmenu" style = "color:#fff">show only &gt;<a href="#"> JOBS</a> |<a href="#"> VEHICLES </a>| <a href="#">REAL ESTATE</a>|<a href="#">CLASSIFIEDS</a></div>
              
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
    </div></div>
    <div id="box_banner">
    
        <img  src="images/home/hp_socialnetwork.jpg" height="229" alt="" />

</div></div><!-- BANNER 728--><div class="clear10"></div><div id="homerow3"><img src="images/Airtel-Bure.jpg" width="728" height="90" /></div><!-- Exchange + rates-->

<div id="homerow4">

  <?php if(isset($rates)): ?>
  <?php if(strlen($rates) > 0): ?>
  <div class="exchange">
    <ul>
      <li>
        <h2>exchange rates</h2><img src="images/sitewide/blueline.gif" width="130" height="3" /><i><br />
        <img src="images/home/icon_exchangerates.png" width="26" height="16" align="texttop" /> <?php echo date("D, d M Y",strtotime(TODAY_CURRENT_DATE_IN_TZ)); ?></i>
      </li>
     <?php echo $rates ?>
    </ul>
  </div>
  <?php endif; ?>
  <?php endif; ?>


  <?php if(isset($tidesObj)): ?>
  <?php if($tidesObj->num_rows() > 0): ?>

  <div class="exchange">
  <ul><li><h2>tide and lunar</h2>
    <img src="images/sitewide/blueline.gif" width="130" height="3" /><br />
    <i><img src="images/home/icon_tidelunar.png" width="50" height="16" align="texttop" /> <?php echo date("D, d M Y",strtotime(TODAY_CURRENT_DATE_IN_TZ)); ?></i>
  </li>

  <?php foreach($tidesObj->result() as $tide): ?>
  <li>

  <?php if($tide->High == 1): ?>
   <h2>High <?php echo date('h:i A', strtotime($tide->tideDate)); ?><br />
  <?php else: ?>
   <h2>Low <?php echo date('h:i A', strtotime($tide->tideDate)); ?><br />
  <?php endif; ?>
  <?php echo $tide->Measurement ?> m</h2><br />
  </li>

  <?php endforeach; ?>

  <li><a href = ""> Tomorrow</a> <br /> <a href = "">Next Seven Days</a> <br /> <a href = "">Full Schedule</a></li>

  </ul>
  </div>
  <?php endif; ?>
  <?php endif; ?>
</div>
  
  </div><!--MAIN FINISH-->