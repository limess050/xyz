	
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

<?php  $subSection = $subSections->row(); ?>

<?php for($i=1; $i<$subSections->num_rows();$i++): ?>
<?php

$SectionID = $subSection->SectionID;  
$SectionImage = $subSection->SectionImage;
?>

<li class="MH255"><a name="S44"></a>
				<h2><span class="ss"><?php echo $subSection->SubSection; ?></span></h2>
                   <form action="" method="post">
					<select name="CategorySelect" id="CategorySelect" class="CategorySelect">

                    		<option value="">Choose a Category</option>
								
							<?php while($subSection->SectionID == $SectionID): ?>
								<option value="<?php echo $subSection->CategoryURLSafeTitle  ?>"><?php echo $subSection->Category ?> (<?php echo $subSection->ListingCount; ?>)</option>
								<?php $subSection = $subSections->next_row(); $i++;?>
							<?php endwhile; ?>
                   	</select>
				</form> 
				
					<img src="images/sections/<?php echo $SectionImage   ?>" alt="<?php echo $subSection->SubSection; ?>" width = "150" height = "120" />
									                 
		   </li>

<?php endfor; ?>

	</ul>

	</div>


