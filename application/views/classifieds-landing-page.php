<div id="columncontent">
<div id="container">
    <h1 align="center"> <?php echo $sectionMeta->H1Text ?><img src="images/sitewide/blubar.gif" alt="" width="540" height="5" /></h1>
    <div id="welcometext" align="left"> 
      <p class="smallbreadcrumbs">Home &gt; Classifieds &gt; Vehicles&gt; Used Cars, Trucks and Boats<span class="titlecategory"></span></p>
      <p align="right"><img src="images/sitewide/button_classified.png" width="127" height="36" alt="classified" />
        
      </p><div><div  class="fb-like" data-href="http://www.facebook.com/pages/ZoomTanzaniacom/196820157025531" data-send="true" data-width="400" data-show-faces="true"></div></div>
      <p class="titlecategory" align="center"> <?php echo $sectionMeta->H1Text ?> available - <?php echo $listings->num_rows(); ?> - </p>
      <br />
    </div>

    
<div class="list">
    <div><span class="uppercap">Choose a location</span><br />
    <span class="smallcategory"><a href="<?php echo current_url(); ?>?LocationID=1">Dar Es Salaam </a>       |         <a href="<?php echo current_url(); ?>?LocationID=13">Zanzibar </a>          |      <a href="<?php echo current_url(); ?>?LocationID=9-16">  Arusha/Moshi </a>           </span>
    <form style = "width:100px; display:inline;" action = "" method = "post">

      <select name="CategorySelect" id="CategorySelect" class = "CategorySelect" style ="display:inline;" onChange=search('LocationID',this.value) >
      <option value="">Select Area</option>
      <?php foreach($locations->result() as $location): ?>
        <option value="<?php echo $location->LocationID ?>" ><?php echo $location->Title; ?></option>
      <?php endforeach; ?>
    </select>
  <form>
  </div>
  </div>
    </div><div align="right">Pages 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 ...</div>

    <div class="categories">

<?php foreach($listings->result() as $listing): ?>
<?php if($listing->ListingTypeID == 1): ?>
    <?php continue; ?>
  <?php else: ?>
  <?php

    if($listing->ListingTypeID == 6 or $listing->ListingTypeID==7)
    {
        if(isset($listing->RentUS))
          $price = '$US ' . number_format($listing->RentUS);
        else
          $price = 'TZS ' . number_format($listing->RentTZS);

        $price .= '/' . $listing->Term;
    }
    else
    {
        if(isset($listing->PriceUS))
          $price = '$US ' . number_format($listing->PriceUS);
        else
          $price = 'TZS ' . number_format($listing->PriceTZS);    

    }
    if($SectionID == 55)
    {
      if($listing->ListingTypeID==3)
       $ListingTitle = $listing->ListingTitle;
     else
      $ListingTitle = $listing->VehicleYear . ' ' . $listing->Make . ' ' . $listing->ModelOther;
    }
    else
      $ListingTitle = $listing->ListingTitle;

  ?>
  <div>

    <?php if($listing->FileNameForTN): ?>
    <a href="listingdetail?ListingID=<?php echo $listing->ListingID; ?>">
    <img src="http://www.zoomtanzania.com/ListingImages/CategoryThumbnails/<?php echo $listing->FileNameForTN; ?>" alt="<?php echo $ListingTitle; ?>" width = "150"  /></a>
    <?php else: ?>
      <a href="listingdetail?ListingID=<?php echo $listing->ListingID; ?>">
    <img src="images/sitewide/no_image.jpg" alt="<?php echo $ListingTitle; ?>" width = "150"  /></a>
    <?php endif; ?>
    <br> <a href="listingdetail?ListingID=<?php echo $listing->ListingID; ?>"><?php echo $ListingTitle ?></a><br><?php echo $price; ?><br />
          <span class="smallcategorynormal"> <?php echo $listing->Location ?></span>
	      </h2>
	    </div>
    <?php endif; ?>
<?php endforeach; ?>

          <div><a href="#">
		  <h2><img src="images/sitewide/C_postfree.png" alt="Tourism and travels" width = "150" height = "150" /></h2>
		  </a>
		    <h2>&nbsp;</h2>
          </div>
	    </ul>
    </div>
    <div id="welcometext" align="left"> 
                  <?php if(isset($pageTextObj) and $pageTextObj->num_rows() > 0): ?>
          <?php echo $pageTextObj->row()->Descr; ?><br>
        <?php endif; ?> </div><div class="list"><br />
    </div>



</div>