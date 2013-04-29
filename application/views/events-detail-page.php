<?php 
  if($listing->RecurrenceID)
    $eventDates = '' ;
  else
  {
    $eventDates = date("M d", strtotime($listing->EventStartDate));
    $eventTimes = 'From ' . date("H:m A", strtotime($listing->EventStartDate));

    if($listing->EventEndDate)
    {
      $eventDates .= ' - ' . date("M d", strtotime($listing->EventEndDate));
      $eventTimes .= ' To ' . date("H:m A", strtotime($listing->EventEndDate));
    }
  }
?>

<div id="columncontent">
<div id="container">
    <h1 align="center"><?php echo $listing->ListingTitle; ?><br><img src="images/sitewide/blubar.gif" alt="" width="540" height="5" /></h1>
    <div id="welcometext" align="left"> 
      <p class="smallbreadcrumbs"><a href="#">Home</a> &gt;<a href="#"> <?php echo $listing->ParentSection; ?></a> &gt; <a href="#"><?php echo $listing->Category; ?></a> &gt; <?php echo $listing->ListingTitle; ?></p><p>
        <br />
       
    </p>
    </div>
<div class="addthis_toolbox addthis_default_style addthis_32x32_style" align="right">
 <img src="images/categories/detailpage_shareit.jpg" align="top" class = "pullleft"/> <!-- AddThis Button BEGIN -->
<a class="addthis_button_email"></a>
<a class="addthis_button_print"></a>
<a class="addthis_button_facebook"></a>
<a class="addthis_button_twitter"></a>
<a class="addthis_button_google_plusone_share"></a>
<a class="addthis_button_stumbleupon"></a>
<a class="addthis_button_reddit"></a>
<a class="addthis_button_linkedin"></a>
<a class="addthis_button_blogger"></a>
<a class="addthis_button_compact"></a><!--<a class="addthis_counter addthis_bubble_style"></a>-->
</div>
<script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=undefined"></script>
<!-- AddThis Button END --></div>
 <!--BUSINESS DETAIL COMPLETE--><div class="listlogo"><div class="list">
      



     <ul>

       <?php if($listing->ELPTypeThumbnailImage): ?>
      <li><a href = "<?php echo $featuredURL; ?>" <?php echo $target; ?> ><img src="images/siticon_lens.png" alt="" width="20" height="19" />zoom our flyer</a><br />
       <br />
      
        <a href = "<?php echo $featuredURL; ?>" <?php echo $target; ?>><img src="http://www.zoomtanzania.com/ListingUploadedDocs/<?php echo $listing->ELPTypeThumbnailImage; ?>" alt="<?php echo $listing->ListingTitle; ?>" width = "141"  /></a>
     <?php endif; ?>
       <!-- <img src="" alt="<?php echo $listing->ListingTitle; ?>" width="141" height="200" /><br /> -->
     </li>
       <li><h3>
           <?php echo $eventDates ?></h3>
           <p>
            <?php echo $eventTimes ?></p><br>
         
         <h5>Location:</h5><?php echo $listing->Location; ?><br />
        <br />
             <h5>Contact &amp; info:</h5>
             <p>
            <?php if($listing->PublicPhone): ?>
              <b>Tel:</b> <?php echo $listing->PublicPhone; ?><br />
            <?php endif; ?>            

            <?php if($listing->PublicPhone3): ?>
              <b>Tel:</b> <?php echo $listing->PublicPhone3; ?><br />
            <?php endif; ?>

            <?php if($listing->PublicPhone4): ?>
              <b>Tel:</b> <?php echo $listing->PublicPhone4; ?><br />
            <?php endif; ?>
            
            <?php if($listing->PublicPhone2): ?>
             <b>Fax:</b> <?php echo $listing->PublicPhone2; ?><br />
            <?php endif; ?>

            <?php if($listing->WebsiteURL): ?>
              <strong>Website: </strong><a <?php echo $target; ?> href="<?php echo prep_url($listing->WebsiteURL); ?>"><?php echo ($listing->WebsiteURL); ?></a><br />
            <?php endif; ?>
          </p>

</li><li></li>  
</ul></div>
        <div class="list" align="left"><h5>About <?php echo $listing->ListingTitle; ?>: </h5>
        <p><?php echo strip_tags($listing->ShortDescr,'<p><br>'); ?>
           </p>
          <h5>
        Location/Directions:</h5>
        <p><?php echo $listing->LocationText; ?></p></div></div>
    
<div align="right">
        <h6><a href="#"><img src="images/sitewide/button_report.gif" width="21" height="18" /> report abuse or incorrect content</a></h6></div><div class="addthis_toolbox addthis_default_style addthis_16x16_style" align="left">
<a class="addthis_button_email"></a>
<a class="addthis_button_print"></a>
<a class="addthis_button_facebook"></a>
<a class="addthis_button_twitter"></a>
<a class="addthis_button_compact"></a><!--<a class="addthis_counter addthis_bubble_style"></a>-->
</div>
<script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=undefined"></script>
<!-- AddThis Button END -->
</div>



</div>