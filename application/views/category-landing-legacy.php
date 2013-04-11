<div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=231785620286787";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>
<div class="centercol-inner">

		<div class="promo-eventscalendar">
		 	<div class="promo-homepagetitle"><h1><?php echo $catMeta->H1Text ?></h1> </div>
			<div class="promo-eventscalendartext">
				<div class="PTwrapper">
				<?php if(isset($pageText)): ?>
					<?php echo $pageText; ?><br>
				<?php endif; ?>
				</div>
				<div class="clear5"></div>
				<div class="fb-like" data-href="http://www.facebook.com/pages/ZoomTanzaniacom/196820157025531" data-send="true" data-width="572" data-show-faces="true"></div>
				<div class="clear5"></div>
				<div class="filterForm">
				<hr>
		
				<form name="f1" action="Tanzania-Jobs-And-Employment" method="get"  ONSUBMIT="return validateForm1(this)">
					<div class="notice">&nbsp;&nbsp;Filter listings by any combination of the fields below.</div><div class="clear5"></div>
																
					<div class="filterField">&nbsp;&nbsp;
						<span class="filterLabel">Location: </span>
						<select class="dining-locationsearch" name="LocationID" id="LocationID">
							<option value="">-- Select an Area --
							<?php foreach($locations->result() as $location): ?>
								<option value="<?php $location->LocationID ?>" ><?php echo $location->Title; ?>
							<?php endforeach; ?>
								
						</select>		
					</div>	
					<div class="filterField">&nbsp;&nbsp;
							<input name="btn-searchdining" id="btn-searchdining" type="image" value="Go" src="images/sitewide/btn.go_off.gif" alt="Go" align="absmiddle" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-searchdining','','images/sitewide/btn.go_on.gif',1)"  />
					</div>
				</form>
			
	</div>
	</div>
	</div>
	<div id="RequestBid">
					<table>
						<tr>
							<td style="vertical-align: middle;padding-top: 10px;">
								
									<form name="fT" ID="fT" action="page.cfm?PageID=184" method="post">
										
											<input type="hidden" name="ListingResults" value="18610,14860,18026,22197,43358,14638,35192,9979,5082,2001,1319,1926,9522,9441,9437,9563,9443,9445,9488,9438,9455,9440">
										
										<input type="hidden" name="CategoryID" value="93">	
										<input type="hidden" name="CategoryURL" value="AirlinesinTanzania">	
										<input type="image" name="SGI" ID="SGI" value="Send Group Inquiry" title="TIP:  Use the 'Filter Listings' fields above to narrow your options before opening the group inquiry form." src="images/sitewide/btn.groupinquiry_off.gif" align="absmiddle" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('SGI','','images/sitewide/btn.groupinquiry_on.gif',1)">	
										<input type="hidden" name="FilterListingTypeID" value="1">	
										
											<input type="hidden" name="LocationID" ID="LocationIDC" value="">
										
											<input type="hidden" name="CuisineID" ID="CuisineIDC" value="">
										
											<input type="hidden" name="NGOTypeID" ID="NGOTypeIDC" value="">
										
									</form>
								
							</td>
							<td class="promo-eventscalendartext" style="padding-bottom: 0px;">
								<strong>Send an email inquiry to up to 6 businesses below at one time.</strong>
							</td>
						</tr>
					</table>
				</div>


<div class="float-left"> <h3 class="h3Featured">Featured <?php echo $catMeta->H1Text ?></h3></div>			
<div class="clear"></div>

<div class="promo-upcomingspecialevents-inner">

	<ul class="dining-skin-tango">

	<?php foreach($Featured_listings_result_obj->result() as $Listing): ?>
		<?php if($Listing->HasExpandedListing): ?>
			<li>
				<a href="<?php echo $Listing->ListingID ?>"><img src="http://www.zoomtanzania.com/ListingUploadedDocs/<?php echo $Listing->LogoImage ?>" alt="<?php echo $Listing->ListingTitle ?>"></a>
				<h2><a href = "<?php echo $Listing->ListingID ?>"><?php echo $Listing->ListingTitle ?></a></h2>
				<span class = "smalltext"><?php echo $Listing->Location; ?></span>
			</li>

		<?php endif; ?>

	<?php endforeach; ?>

	</ul>

</div>



<ul class="dining-nonfeatured">
			<div class="float-left"><h4 class="h4Category">All <?php echo $catMeta->H1Text ?></h4></div>
			
			<div class="clear"></div>

			<?php foreach($Listings_result_obj->result() as $Listing): ?>
					
			<li> 
            	<h2><a href="<?php echo $Listing->ListingID; ?>"><?php echo $Listing->ListingTitle; ?></a></h2>
				<span class="smalltext"><?php echo $Listing->Location; ?></span>
			</li>				
					
			<?php endforeach; ?>
	

</div>


