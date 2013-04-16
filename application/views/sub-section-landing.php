
<script type="text/javascript" src="js/carousel-other.js" language="javascript"></script>
<div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=231785620286787";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>
<div id="columncontent">
  <div id="container">
    <h1 align="center"> <?php echo $sectionMeta->H1Text ?><img src="images/sitewide/blubar.gif" alt="" width="540" height="5" /></h1>
    <div id="welcometext" align="left">
	<?php if(isset($pageTextObj)): ?>
		<?php if($pageTextObj->num_rows() > 0): ?>
			<?php echo $pageTextObj->row()->Descr; ?><br>
		<?php endif; ?>
	<?php endif; ?>

	<div class="fb-like" data-href="http://www.facebook.com/pages/ZoomTanzaniacom/196820157025531" data-send="true" data-width="572" data-show-faces="true"></div>
    </div>

    
 <div></div>
    </div><div class="directory">
     <ul>

		<?php 
			$urlPrefix = $this->uri->segment(1) .'/' ;
			if(isset($subsection)) 
				$urlPrefix .= $this->uri->segment(2) .'/';
		?>
     	<?php foreach($categories->result() as $category):?>


		<li class="MH255">
			<h2>
				
				<a href = "<?php echo $category->CategoryURLSafeTitle ?>"><?php echo $category->Category; ?></a>

				<br>-<?php echo $category->ListingCount; ?>-</h2><br />
		       			
				<a href = "<?php echo $category->CategoryURLSafeTitle ?>"><img src="images/categories/<?php echo $category->CategoryImage; ?>" alt="<?php echo $category->Category; ?>" width = "150" height = "120" /></a>
								                 
		</li>
		
		<?php endforeach; ?>

	</ul>
	</div>

</div>