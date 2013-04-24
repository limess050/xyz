<div id="columncontent">
  <div id="container">
    <h4 align="center"><?php echo $listing->Category; ?><br><img src="images/sitewide/blubar.gif" alt="" width="540" height="5" /></h4>
    <div id="welcometext" align="left"> 
      <p class="smallbreadcrumbs"><a href="#">Home</a> &gt;<a href="#"> <?php echo $listing->ParentSection; ?></a> &gt; <a href="#"><?php echo $listing->Category; ?></a> &gt; <?php echo $listing->ShortDescr; ?></p><p>
        <br />
       
    </p>
    </div>
<!-- AddThis Button BEGIN -->
<div class="addthis_toolbox addthis_default_style addthis_32x32_style">
<img src="images/categories/detailpage_shareit.jpg" class="pullleft"/><a class="addthis_button_email"></a>
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
<!-- AddThis Button END -->
 <!--BUSINESS DETAIL COMPLETE-->
 <div class="list"><h3>
    <br />
    <br />
    <h3><?php echo $listing->ShortDescr; ?><br />
<br />
          </h3>
          
      
     <div><ul><li><b>job Category:</b> <?php echo $listing->Category; ?><br />
<!--<b>position type:</b> NOT YET FUNCTIONAL <b><br />
organization type: </b>NOT YET FUNCTIONAL <b><br />-->
location:</b> <?php echo $listing->Location; ?><br />
           <br /> 
          <h5> COMPANY:
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

        <div  align="left"><br />
        <h5>POSITION DESCRIPTION:</h5><br />
        <?php if($listing->UploadedDoc): ?>
         <a href="ListingUploadedDocs/<?php echo $listing->UploadedDoc;?>">Position Description Document (download)</a>
       <?php else: ?>
         <?php echo strip_tags($listing->LongDescr,'<p><br>'); ?>
       <?php endif; ?>
          <br />
            <br />
            <h5>APPLICATION INSTRUCTIONS:</h5><br />
            <?php echo $listing->Instructions; ?>

         
         
          
</div>

<div><h5>if you are qualified for this position<br />
  <img src="images/sitewide/button_apply.png" alt="apply now" width="127" height="36" align="texttop" /></h5>
   <h6 class="pullright padit"><a href="#"> report abuse or incorrect content<img src="images/sitewide/button_report.gif" width="21" height="18" /></a></h6></div>
 </div> 

       
        <div class="addthis_toolbox addthis_default_style addthis_16x16_style padit">
<a class="addthis_button_email"></a>
<a class="addthis_button_print"></a>
<a class="addthis_button_facebook"></a>
<a class="addthis_button_twitter"></a>
<a class="addthis_button_compact"></a><!--<a class="addthis_counter addthis_bubble_style"></a>-->
</div>
<script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=undefined"></script>
<!-- AddThis Button END --></div>

</div>