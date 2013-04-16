
<script type="text/javascript" src="js/carousel-other.js" language="javascript"></script>
<div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=231785620286787";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>


<script>
function search(SearchTerm,ID)
{

	var curURL = document.URL;
	var URL = new Array();
	URL[0]=curURL;

	if (curURL.indexOf("LocationID")) {URL =curURL.split("?LocationID");}

	 if ($.browser.msie)
		window.location = URL[0] + "?" + SearchTerm + "=" + ID;
	
	else
		window.location.replace(URL[0] + "?" + SearchTerm + "=" + ID);
		
}
</script>
<div id="columncontent">
  <div id="container">
    <h1 align="center"><?php echo $catMeta->H1Text ?><img src="images/sitewide/blubar.gif" alt="" width="540" height="5" /></h1>
    <div id="welcometext" align="left"> 
	
		<!--Breadcrumbs-->
      <p class="smallbreadcrumbs">Home &gt; Tanzania Business Directory &gt; Business Services &gt; Tanzania Recruitment Agencies</p>

      <!--Page Text-->
      <p>
        <br />
		<?php if(isset($pageText)): ?>
			<?php echo $pageText; ?><br>
		<?php endif; ?>
       <br />
      </p>

      <!--Facebook-->
  	<div  class="fb-like" data-href="http://www.facebook.com/pages/ZoomTanzaniacom/196820157025531" data-send="true" data-width="572" data-show-faces="true"></div>

  	<div style = "float: left; clear: none;">
      <div class="titlecategory" style = "width:250px;"><br />Featured <?php echo $catMeta->H1Text ?></div>

       <div align="right" style = "width:300px;">
	       	<img src="images/sitewide/button_post.png" alt="post a listing" />
			<form name = "se" id = "se" method="post" action = "request-quote" style = "display: inline;">
				<input type="hidden" name="ListingResults" value="<?php echo $quoteRequestString; ?>">
				<input type="hidden" name="CategoryID" value="93">	
				<input type="hidden" name="CategoryURL" value="AirlinesinTanzania">	
	       		<input type = "image" name = "SGI" id = "SGI" src="images/sitewide/button_quote.png"  title = "TIP:  Use the 'Filter Listings' fields above to narrow your options before opening the group inquiry form." />
			</form>
		</div>
	</div> 
	</div><!--Close Welcome Text-->
   	<div class="list">
  	<div><span class="uppercap">Choose a location</span><br />
    <span class="smallcategory"><a href="<?php echo current_url(); ?>?LocationID=1">Dar Es Salaam </a>       |         <a href="<?php echo current_url(); ?>?LocationID=13">Zanzibar </a>          |      <a href="<?php echo current_url(); ?>?LocationID=9-16">  Arusha/Moshi </a>           </span>
    <form style = "width:100px; display:inline;" action = "" method = "post">
	    <!-- <select name="jumpMenu" id="jumpMenu" onchange="MM_jumpMenu('parent',this,0)"  style ="display:inline;"> -->
	    <select name="CategorySelect" id="CategorySelect" class = "CategorySelect" style ="display:inline;" onChange=search('LocationID',this.value) >
			<option value="">Select Area</option>
			<?php foreach($locations->result() as $location): ?>
				<option value="<?php echo $location->LocationID ?>" ><?php echo $location->Title; ?></option>
			<?php endforeach; ?>
		</select>
	<form>
	</div>
	</div>
    </div>
    <div class="categories">
    	
    <?php $i=0; ?>
	<?php foreach($Featured_listings_result_obj->result() as $Listing): ?>
		<?php if($Listing->HasExpandedListing): ?>
	  <div><a href="<?php echo $Listing->ListingURL; ?>">
	  	<img src="http://www.zoomtanzania.com/ListingUploadedDocs/<?php echo $Listing->LogoImage ?>" alt="<?php echo $Listing->ListingTitle ?>"  /></a><br /><a href="<?php echo url_title(str_replace("&", "And",$Listing->ListingTitle)); ?>"> <span class="smallcategory"><?php echo $Listing->ListingTitle ?></a><br />
	      </span><span class="smallcategorynormal"><?php echo trim($Listing->Location); ?><?php if($Listing->LocationOther != ''): ?><?php echo ', ' . $Listing->LocationOther; ?><?php endif; ?>
	  	</span>
	      </h2>
	    </div>
			<?php $i++; ?>
		<?php endif; ?>
	<?php endforeach; ?>

	
	<?php if($i%3 != 0): ?>
	
	<?php if(($i+1)%3 == 0): ?>
	<div><a href="#"><img src="images/sitewide/B_feauture.png" alt="Feature Your Business Here"  /></a>
	    </div>
	<?php elseif(($i+2)%3 == 0): ?>
		<div><a href="#"><img src="images/sitewide/B_feauture.png" alt="Feature Your Business Here"  /></a>
	    </div>
	    	<div><a href="#"><img src="images/sitewide/B_feauture.png" alt="Feature Your Business Here"  /></a>
	    </div>
	<?php endif; ?>
	<?php endif; ?>

	 </div><div class="list"><br />
      <div><p class="titlecategory">All <?php echo $catMeta->H1Text; ?></p><br />
      <br />
      <?php foreach($Listings_result_obj->result() as $Listing): ?>
    	<a href="<?php echo url_title($Listing->ListingTitle); ?>"><span class="smallcategory"><?php echo $Listing->ListingTitle; ?></span></a><br />
     		<?php echo trim($Listing->Location); ?><?php if($Listing->LocationOther != ''): ?><?php echo ', ' . $Listing->LocationOther; ?>
			<?php endif; ?>

     		<br />
      <br />
      <?php endforeach; ?>
      </div>
  
		</div>



</div>