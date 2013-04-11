<div class="rightcol-inner">
		
				<div class="promotitle" >

	 		<h2>Latest Featuered Business</h2>

	</div>	
					<div class="promo-latestfeaturebiz" style = " padding-top:10px;">
	
					<img src = "ListingImages/HomepageThumbnails/erolink.png" />
					<p><a href = "">EroLink - Recruitment Specialist</a></p>
	</div>
	<div class="clear5"></div>
	<div class="promotitle" >

	 		<h2>Upcoming Conferences & Seminars</h2>

	</div>	
					<div class="promo-latestfeaturebiz" style = " padding-top:10px;">
	
					<img src = "ListingImages/HomepageThumbnails/Training.jpg" />
					<p><a href = "">
Public Seminar of Grievance EroLink - Recruitment Specialist</a></p>
	</div>

	<div class="clear5"></div>
	<?php if(isset($youMayAlsoLikeObj)): ?>		
	<div class="promotitle" >

	 		<h2>You May Also be Interested In</h2>

	</div>	
	<div class="promo-latestfeaturebiz" style = " padding-top:10px;">
		<?php foreach($youMayAlsoLikeObj->result() as $youMayAlsoLike): ?>
			<p><?php echo $youMayAlsoLike->Descr; ?></p>
		<?php endforeach; ?>
	</div>
	<?php endif; ?>
		
</div>
