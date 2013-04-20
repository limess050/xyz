	<div id="main">
  <div id="sidebar">
  <?php if(isset($featuredBusinessObj)):?>
    <?php if($featuredBusinessObj->num_rows() > 0):?>
    <div id="box_left">
      <h4> Latest Featured Businesses  <img src="images/sitewide/blubar.gif" alt="" width="200" height="5" /></h4>
       <ul id="my-movies-carousel" class="jcarousel-skin-tango-sidebar1">
      <?php foreach($featuredBusinessObj->result() as $featuredBusiness): ?>
        <li> <a href="<?php echo url_title($featuredBusiness->ListingTitle); ?>" ><?php echo $featuredBusiness->ListingTitle ?>
          </a><br />
          <a href="<?php echo url_title($featuredBusiness->ListingTitle); ?>" ><img class="left" src="http://www.zoomtanzania.com/ListingUploadedDocs/<?php echo $featuredBusiness->LogoImage  ?>" width = "165" alt="<?php echo $featuredBusiness->ListingTitle; ?>" /></a>
          </li>

    <?php endforeach; ?>
      </ul>
    </div>
    <?php endif; ?>
  <?php endif; ?>

  <?php if(isset($relatedEventsObj)): ?> 
    <?php if($relatedEventsObj->num_rows() > 0): ?> 
    <div id="box_left">
      <h4>Related Events<br />
        <img src="images/sitewide/blueline.gif" alt="" width="180" height="5" /></h4>
      <ul id="sidebar1" class="jcarousel-skin-tango-sidebar1">
        <?php foreach($relatedEventsObj->result() as $relatedEvent): ?>
        <li> <a href="listingdetail?ListingID=<?php echo $relatedEvent->ListingID; ?>" ><?php echo $relatedEvent->ListingTitle; ?></a><br />
         <a href="listingdetail?ListingID=<?php echo $relatedEvent->ListingID; ?>" > <img class="left" src="http://www.zoomtanzania.com/ListingImages/HomepageThumbnails/<?php echo $relatedEvent->ELPTypeThumbnailImage  ?>" width="100"  alt="<?php echo $relatedEvent->ListingTitle; ?>" />
          </a></li>
        <?php endforeach; ?>
      </ul>
    </div>
    <?php endif; ?>
  <?php endif; ?>


  <?php if(isset($youMayAlsoLikeObj)): ?> 
    <?php if($youMayAlsoLikeObj->num_rows() > 0): ?> 

    <div id="box_left">
      <h4>You May Also Like<br />
        <img src="images/sitewide/blueline.gif" alt="" width="180" height="5" /></h4>
      <ul class="imageList">
        <li>
          <div class="zoomreccomend">
                <?php foreach($youMayAlsoLikeObj->result() as $youMayAlsoLike): ?>
             <p><?php echo $youMayAlsoLike->Descr; ?></p><br />
                <?php endforeach; ?>
          </div>
        </li>
      </ul>
    </div>
    <?php endif; ?>
  <?php endif; ?>
</div>