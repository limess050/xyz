<div id="columncontent">
<div id="container">
    <h1 align="center"><?php echo $listing->ListingTitle; ?> > <?php echo $listing->Category; ?><img src="images/sitewide/blubar.gif" alt="" width="540" height="5" /></h1>
    <div id="welcometext" align="left"> 
<p class="smallbreadcrumbs"><a href="#">Home</a> &gt;<a href="#"> <?php echo $listing->ParentSection; ?></a> &gt; <a href="#"><?php echo $listing->Category; ?></a> &gt; <?php echo $listing->ListingTitle; ?></p><p>
        <br />
       
    </p>
    </div>
 <img src="images/categories/detailpage_shareit.jpg" /> <!-- AddThis Button BEGIN -->
<div class="addthis_toolbox addthis_default_style addthis_32x32_style" align="right">
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
 <!--BUSINESS DETAIL COMPLETE--><div class="listlogo"><h2>
    <br />
    <br />
    <?php if($listing->HasExpandedListing): ?>
     <a href = "http://www.zoomtanzania.com/ListingUploadedDocs/<?php echo $listing->ExpandedListingPDF  ?>" <?php echo $target; ?>><?php echo $listing->ListingTitle; ?></a><br />
    <?php else: ?>
<?php echo $listing->ListingTitle; ?><br />
    <?php endif; ?>
<br />
          </h2><div class="list">
      
     <ul>
      <?php if($listing->HasExpandedListing): ?>
      <li>
      <a href = "<?php echo $featuredURL; ?>" <?php echo $target; ?>><img src="http://www.zoomtanzania.com/ListingUploadedDocs/<?php echo $listing->LogoImage  ?>"  align="left" /></a>
      </li>
      <?php endif; ?>

      <li>
        <h5>Contacts:</h5><br />
          <b><br />
          Location:</b> Dar Es Salaam <br />
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


            <?php if(isset($listing->FacebookPage)): ?>
             <b><a href="#">Facebook Page </a></b><br />
            <?php endif; ?>

            <?php if($listing->WebsiteURL): ?>
              <strong>Website: </strong><a <?php echo $target; ?> href="<?php echo prep_url($listing->WebsiteURL); ?>"><?php echo ($listing->WebsiteURL); ?></a><br />
            <?php endif; ?>

</li><li><img src="images/sitewide/button_send.png" width="127" height="36" /></li>  
</ul></div>
<?php if($listing->HasExpandedListing): ?>
 
<div class="list">
<img src="http://placehold.it/120x120" width="120" height="120" />
<img src="http://placehold.it/120x120" width="120" height="120" />
<img src="http://placehold.it/120x120" width="120" height="120" />
<img src="http://placehold.it/120x120" width="120" height="120" />

</div>
 
<?php endif; ?>
<div class="list" align="left">
  <?php if($listing->HasExpandedListing): ?>

<a href = "<?php echo $featuredURL; ?>" <?php echo $target; ?>><img src="images/sitewide/icon_lens.png" alt="" width="20" height="19" />zoom our flyer</a><br />
       <br />
       <a href = "<?php echo $featuredURL; ?>" <?php echo $target; ?>><img src="http://www.zoomtanzania.com/ListingUploadedDocs/<?php echo $listing->ELPTypeThumbnailImage  ?>" alt="<?php echo $listing->ListingTitle; ?> type" title = "<?php echo $listing->ListingTitle; ?> type" /></a>
<?php endif; ?>
          <h5>          About <?php echo $listing->ListingTitle; ?>: </h5>
          <?php echo $listing->ShortDescr; ?>
        <br />
          <br />
        <h5>Location/Directions:</h5><br />
        <?php echo $listing->LocationText; ?><br />
        <br />
        <br />
        <br />
</div>
        
        
      

       

     
  </div>
  <div align="right">
        <h6><a href="#"><img src="images/sitewide/button_report.gif" width="21" height="18" /> report abuse or incorrect content</a></h6></div><!-- AddThis Button START --><div class="addthis_toolbox addthis_default_style addthis_16x16_style" align="left">
<a class="addthis_button_email"></a>
<a class="addthis_button_print"></a>
<a class="addthis_button_facebook"></a>
<a class="addthis_button_twitter"></a>
<a class="addthis_button_compact"></a><!--<a class="addthis_counter addthis_bubble_style"></a>-->
</div>
<script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=undefined"></script>
<!-- AddThis Button END --></div>
</div>



</div>