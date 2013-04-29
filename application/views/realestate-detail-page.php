<?php
    if($listing->ListingTypeID == 6 or $listing->ListingTypeID==7)
    {
        $price = '<strong>Rent: </strong>';

        if(isset($listing->RentUS))
          $price .= '$US ' . number_format($listing->RentUS);
        else
          $price .= 'TZS ' . number_format($listing->RentTZS);

        $price .= '/' . $listing->Term;
    }
    else
    {
        $price = '<strong>Price: </strong>';
        if(isset($listing->PriceUS))
          $price .= '$US ' . number_format($listing->PriceUS);
        else
          $price .= 'TZS ' . number_format($listing->PriceTZS);    

    }  


   $ListingTitle = $listing->ListingTitle;
   

?>

<div id="columncontent">
<div id="container">
    <h1 align="center"><?php echo $ListingTitle; ?><br><img src="images/sitewide/blubar.gif" alt="" width="540" height="5" /></h1>
    <div id="welcometext" align="left"> 
<p class="smallbreadcrumbs"><a href="#">Home</a> &gt;<a href="#"> <?php echo $listing->ParentSection; ?></a> &gt; <a href="#"><?php echo $listing->Category; ?></a> &gt; <?php echo $ListingTitle; ?></p><p>
        <br />
       
    </p>
    </div>
<div class="addthis_toolbox addthis_default_style addthis_32x32_style" align="right">
 <img  src="images/categories/detailpage_shareit.jpg" align='top' class ="pullleft" /> <!-- AddThis Button BEGIN -->
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
 <!--BUSINESS DETAIL COMPLETE--><div class="listlogo">

 
<div class="list" align="left">
  
          <h5>About <?php echo $ListingTitle; ?>: </h5>
          <br>

         <b>Area:</b> <?php echo $listing->Location; ?><br />

         <?php if($listing->LocationText): ?>
            <b>Directions:</b> <?php echo strip_tags($listing->LocationText); ?><br />
         <?php endif; ?>


          <?php echo $price; ?><br />

          <?php if($listing->Bedrooms): ?>
            <strong>Bedrooms:</strong> <?php echo number_format($listing->Bedrooms); ?><br />
          <?php endif ?>

          <?php if($listing->Bathrooms): ?>
             <strong>Bathrooms:</strong> <?php echo $listing->Bathrooms; ?><br />
          <?php endif ?>
          
          <?php if($listing->Amenities): ?>
             <strong>Amenities:</strong> <?php echo $listing->Amenities; ?>
            <?php if($listing->AmenityOther): ?>
              <?php echo ', ' . $listing->AmenityOther;  ?>
            <?php endif; ?>
             <br />
          <?php endif; ?>
          
          <strong>Date Listed:</strong> <?php echo date('d-m-Y',strtotime($listing->DateListed)); ?><br /><Br />
          <?php echo strip_tags($listing->ShortDescr,'<p><b><strong>'); ?>

          <ul>
  

      <li>
        <h5>Contacts:</h5><br />
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

</li>
<?php if($listing->PublicEmail): ?>
<li><img src="images/sitewide/button_send.png" width="127" height="36" /></li> 
<?php endif; ?> 
</ul>

</div>

<?php if($listing->ListingImages): ?>
  <?php 
    $photos = explode(',', $listing->ListingImages);
  ?>

  <div class="list">
    <?php foreach($photos as $photo): ?>
      <img src= "<?php echo LISTINGIMAGES . $photo ?>" width="120"  />
    <?php endforeach; ?>
<!--   <img src="http://placehold.it/120x120" width="120" height="120" />
  <img src="http://placehold.it/120x120" width="120" height="120" />
  <img src="http://placehold.it/120x120" width="120" height="120" /> -->
  </div>
<?php endif; ?>
 



       

     
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