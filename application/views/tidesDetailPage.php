  <script>
  $(function() {
  	//{ minDate: 0}
    $( "#StartDate" ).datepicker();
    $( "#EndDate" ).datepicker();
  });
  </script>
<div id="columncontent">
  	<div id="container">
    	<h1 align="center"><?php echo $pageMeta->Title ?><img src="images/sitewide/blubar.gif" alt="" width="540" height="5" /></h1>
    	<div id="welcometext" align="left">
			<!--Breadcrumbs-->
		</div>
	      <p>
	        <br />

			<form method="post" action="tides">
				From: <input type="text" name="StartDate" id = "StartDate">
				To: <input type="text" name="EndDate" id = "EndDate"> <input type = "submit" value = "Submit">
			</form><br><br>

	        <?php 

  $week = new DateTime(TODAY_CURRENT_DATE_IN_TZ);
  $month = new DateTime(TODAY_CURRENT_DATE_IN_TZ);
  $ninetyDays = new DateTime(TODAY_CURRENT_DATE_IN_TZ);
  $week = $week->add(new DateInterval('P7D'));
  $month = $month->add(new DateInterval('P30D'));
  $ninetyDays = $ninetyDays->add(new DateInterval('P90D'));

  ?>
  <a href = "tides?EndDate=<?php echo $week->format("Y-m-d"); ?>">Next 7 Days</a> | <a href = "tides?EndDate=<?php echo $month->format("Y-m-d"); ?>">Next 30 Days</a> | <a href = "tides?EndDate=<?php echo $ninetyDays->format("Y-m-d"); ?>">Next 90 Days</a><br><br>
	        <table cellpadding="5">
	        	<thead>
	        		<tr>
		        		<th>Day</th>
		        		<th>High</th>
		        		<th>Low</th>
		        		<th>High</th>
		        		<th>Low</th>
		        		<th>High</th>
		        		<th>Sunrise</th>
		        		<th>Sunset</th>
		        	</tr>
	        	</thead>
	        	<tbody>
				
				<?php $rowCounter=0;?>

				<?php foreach($highChecker->result() as $high): ?>
				<?php $counter=0; ?>
						<?php $rowCounter++ ;?>	
				<tr style = "background:<?php if($rowCounter%2): ?>#CCC;<?php else: ?>#FFF<?php endif; ?>">
					<td><?php echo date("D, d M Y",strtotime($high->day)); ?></td>
					<?php if($high->High): ?>
						<td> <?php echo date('h:i A', strtotime($high->tideDate)); ?> / <?php echo $high->Measurement ?></td>
					<?php else: ?>
						<td></td>
						<td> <?php echo date('h:i A', strtotime($high->tideDate)); ?> / <?php echo $high->Measurement ?></td>
					<?php endif; ?>

					<?php foreach($tidesObj->result() as $day): ?>
					<?php if($day->day == $high->day): ?>
						<?php if($counter == 0): ?>
							<?php  $counter++; ?>
						<?php else: ?>
							<?php if($high->valuescount==3 and $counter==3): ?>
								<?php if($high->High): ?>
								<td> <?php echo date('h:i A', strtotime($day->tideDate)); ?> / <?php echo $day->Measurement ?> m</td>
								<td></td>
								<td></td>
								<?php else: ?>
								<td> <?php echo date('h:i A', strtotime($day->tideDate)); ?> / <?php echo $day->Measurement ?> m</td>
								<td></td>
								<?php endif; ?>
							<?php elseif($high->High and $counter==4): ?>
								<td> <?php echo date('h:i A', strtotime($day->tideDate)); ?> / <?php echo $day->Measurement ?> m</td>
								<td></td>
							<?php else: ?>
								<td> <?php echo date('h:i A', strtotime($day->tideDate)); ?> / <?php echo $day->Measurement ?> m</td>
							<?php endif ?>
						<?php endif; ?>

					<?php $counter++; ?>
					
					<?php else: ?>
						<?php $counter =0; ?>
					<?php endif; ?>
					<?php endforeach;?>
						
					<td><?php echo date('h:i A', strtotime($high->SunriseDate)); ?></td>
					<td><?php echo date('h:i A', strtotime($high->SunsetDate)); ?></td>
						

				</tr>

				<?php endforeach; ?>






				


	        	
	        	</tbody>
	        </table>
	       <br />
	      </p>
	</div>
</div>