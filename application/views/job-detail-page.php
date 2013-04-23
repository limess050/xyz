<div id="columncontent">
  <div id="container">
    <h4 align="center"><?php echo $listing->Category; ?><br><img src="images/sitewide/blubar.gif" alt="" width="540" height="5" /></h4>
    <div id="welcometext" align="left"> 
      <p class="smallbreadcrumbs"><a href="#">Home</a> &gt;<a href="#"> <?php echo $listing->ParentSection; ?></a> &gt; <a href="#"><?php echo $listing->Category; ?></a> &gt; <?php echo $listing->ShortDescr; ?></p><p>
        <br />
       
    </p>
    </div>
<img src="images/categories/detailpage_shareit.jpg" /> <!-- AddThis Button BEGIN -->
<div class="addthis_toolbox addthis_default_style addthis_32x32_style" align="right">
<a class="addthis_button_email"></a>
<a class="addthis_button_print"></a>
<a class="addthis_button_facebook"></a>
<a class="addthis_button_twitter"></a>
<a class="addthis_button_google_plusone_share"></a>
<a class="addthis_button_stumbleupon"></a>
<a class="addthis_button_reddit"></a>
<a class="addthis_button_linkedin"></a>
<a class="addthis_button_blogger"></a>
<a class="addthis_button_compact"></a><!--<a class="addthis_counter addthis_bubble_style"></a>-->
</div>
<script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=undefined"></script>
<!-- AddThis Button END --></div>
 <!--BUSINESS DETAIL COMPLETE--><div class="listlogo"><h3>
    <br />
    <br />
      <?php echo $listing->ShortDescr; ?><br />
<br />
          </h3><div class="list">
      
     <ul><li><span class="smallcategorynormal"><b>job Category:</b> <?php echo $listing->Category; ?><br />
<b>position type:</b> NOT YET FUNCTIONAL <b><br />
organization type: </b>NOT YET FUNCTIONAL <b><br />
location:</b> <?php echo $listing->Location; ?></span><h5><br />
           <br /> 
           COMPANY:
           </h5><?php echo $listing->ListingTitle; ?><br />

     </li>
       <li><span id="EmailLister"><strong>Phone: </strong><?php if($listing->PublicPhone) echo $listing->PublicPhone; else "No Calls Please"; ?><br />
           <!-- <strong>Location:</strong> Dar Es Salaam<br /> -->
           <strong>Application Deadline: </strong><?php echo date('d-m-Y',strtotime($listing->Deadline)); ?></span> <br />
            <?php if($listing->WebsiteURL): ?>
            <strong>Website: </strong><a target = "_blank" href="<?php echo prep_url($listing->WebsiteURL); ?>"><?php echo ($listing->WebsiteURL); ?></a><br />
            <?php endif; ?>

</li><li></li>  
</ul></div>
        <div class="list" align="left"><br />
        <h5>POSITION DESCRIPTION:</h5><br />
        <?php if($listing->UploadedDoc): ?>
         <a href="ListingUploadedDocs/<?php echo $listing->UploadedDoc;?>">Position Description Document</a>
       <?php else: ?>
         <?php echo strip_tags($listing->LongDescr,'<p><br>'); ?>
       <?php endif; ?>
          <br />
            <br />
            <h5>APPLICATION INSTRUCTIONS:</h5><br />
            <?php echo $listing->Instructions; ?>

         
         
          
</div><div><h5>if you are qualified for this position</h5><br />
  <img src="images/sitewide/button_apply.png" alt="apply now" width="127" height="36" align="texttop" /></div></div>
 <div align="right">
        <h6><a href="#"><img src="images/sitewide/button_report.gif" width="21" height="18" /> report abuse or incorrect content</a></h6></div><div class="addthis_toolbox addthis_default_style addthis_16x16_style" align="left">
<a class="addthis_button_email"></a>
<a class="addthis_button_print"></a>
<a class="addthis_button_facebook"></a>
<a class="addthis_button_twitter"></a>
<a class="addthis_button_compact"></a><!--<a class="addthis_counter addthis_bubble_style"></a>-->
</div>
<script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=undefined"></script>
<!-- AddThis Button END --></div>
</div>