
<script type="text/javascript" src="js/carousel-other.js" language="javascript"></script>
<script>
	$(document).ready(function() {
		$('.CategorySelect').change(function() {
			if ($(this).val() != '') {
				$(this).closest("form").attr('action', $(this).val());
				$(this).closest("form").submit();
			}
		});
	});
</script>
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
    <h1 align="center"><?php echo $sectionMeta->H1Text ?><img src="images/sitewide/blubar.gif" alt="" width="540" height="5" /></h1>
    <div id="welcometext" align="left">
    			<?php if(isset($pageTextObj)): ?>
					<?php echo $pageTextObj->row()->Descr; ?><br>
				<?php endif; ?>				

				<div class="fb-like" data-href="http://www.facebook.com/pages/ZoomTanzaniacom/196820157025531" data-send="true" data-width="572" data-show-faces="true"></div>
				</div>
			
</div>
    <div class="business" align="center">
     <ul>
<?php  $subSection = $subsections->row(); ?>

<?php for($i=1; $i<$subsections->num_rows();$i++): ?>
<?php

$SectionID = $subSection->SectionID;  
$SectionImage = $subSection->SectionImage;
$SectionTitle = $subSection->SubSection;
$SectionURL = $subSection->SectionURL;
?>
<li><a name="S<?php echo $subSection->SectionID; ?>"></a>
<h2><?php echo $subSection->SubSection; ?><br /><br /></h2>
<form action="" method="post">
	<select name="CategorySelect" id="CategorySelect" class="CategorySelect">
		<option value="">Choose a Category</option>
			
		<?php while($subSection->SectionID == $SectionID): ?>
			<option value="<?php echo $subSection->CategoryURLSafeTitle  ?>"><?php echo $subSection->Category ?> (<?php echo $subSection->ListingCount; ?>)</option>
			<?php $subSection = $subsections->next_row(); $i++;?>
		<?php endwhile; ?>

   	</select>
</form> 
<img src="images/sections/<?php echo $SectionImage   ?>" alt="<?php echo $SectionTitle ?>" width = "150" height = "120" />
</li>
<?php endfor; ?>
</ul>
</div>
</div>