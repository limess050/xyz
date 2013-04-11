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
		 	<div class="promo-homepagetitle"><h1><?php echo $sectionMeta->H1Text ?></h1> </div>
			<div class="promo-eventscalendartext">
				<div class="PTwrapper">
				<?php if(isset($pageTextObj)): ?>
					<?php echo $pageTextObj->row()->Descr; ?><br>
				<?php endif; ?>
				</div>
				<div class="clear5"></div>
				<div class="fb-like" data-href="http://www.facebook.com/pages/ZoomTanzaniacom/196820157025531" data-send="true" data-width="572" data-show-faces="true"></div>
			
	</div>
	</div>



<ul class="businessguide-skin-tango">



<?php foreach($categories->result() as $category):?>


<li class="MH255"><a name="S44"></a>
				<h2><a href = "<?php echo $this->uri->segment(1) ?>/<?php echo $category->CategoryURLSafeTitle ?>"><?php echo $category->Category; ?></a> (<?php echo $category->ListingCount; ?>)</h2>
                   			
					<a href = "<?php echo $this->uri->segment(1) ?>/<?php echo $category->CategoryURLSafeTitle ?>"><img src="images/categories/<?php echo $category->CategoryImage; ?>" alt="<?php echo $category->Category; ?>" width = "150" height = "120" /></a>
									                 
		   </li>
		
<?php endforeach; ?>

	</ul>

	</div>


