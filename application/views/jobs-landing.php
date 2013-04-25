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
  <!--title-->
    <h1 align="center"><?php echo $sectionMeta->H1Text ?><img src="images/sitewide/blubar.gif" alt="" width="540" height="5" /></h1>
    <div class="welcometext" align="left">
    
     <!--breadcrumbs TO SET-->
      <div class="smallbreadcrumbs">Home &gt; Classifieds &gt; Jobs&gt; Job Vacancies in Tanzania</div>
      
   <div class="fb-like" data-href="http://www.facebook.com/pages/ZoomTanzaniacom/196820157025531" data-send="true" data-width="572" data-show-faces="true"></div>
				</div>
    <!--choose a location-->
    
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
  
    
<!--container close / open pagination / title h2 and buttons-->
  
      
    
    
<!--pagination MINI STYLE-->
<div class="pagination pagination-mini">
  <ul>
    <li><a href="#">Prev</a></li>
    <li><a href="#">1</a></li>
    <li><a href="#">2</a></li>
    <li><a href="#">3</a></li>
    <li><a href="#">4</a></li>
    <li><a href="#">5</a></li>
    <li><a href="#">Next</a></li>
  </ul>
</div>
<div class="welcometext">
       <div class="pullright" ><img src="images/sitewide/button_job.png" width="127" height="36" alt="classified" /></div>
     <div> 
<h2 style = "width:300px;"><?php echo $listings->num_rows(); ?> Job vacancies in Tanzania </h2></div>
        
       </div> 
    
        
         
         
        
       


<!-- CONTENT-->
        <div class="list">
      
     <div><ul>

       <?php $i = 0; ?>
       <?php foreach($listings->result() as $listing): ?>
       <?php $i++; ?>
       <li >
        <a href = "listingdetail?ListingID=<?php echo $listing->ListingID; ?>" title = "<?php echo $listing->ShortDescr; ?>"><?php echo $listing->ShortDescr; ?></a><br />
        <?php echo $listing->Location; ?><br />
        Deadline: <?php echo date('d-m-Y',strtotime($listing->Deadline)); ?>
      <?php if($i==2): ?>
      <?php $i=0; ?>
      <div style = "clear: both; border: none; padding:0; margin:0;"></div>
      <?php endif; ?>
      </li>   <?php endforeach;?>

    </ul>
     
  
		</div></div>
      
    <!--Welcome text and pagination MINI STYLE-->  
       <div class="welcometext">
    
   
          <?php if(isset($pageTextObj) and $pageTextObj->num_rows() > 0): ?>
          <?php echo $pageTextObj->row()->Descr; ?><br>
        <?php endif; ?> 
          
 <div class="pagination pagination-mini">
  <ul>
    <li><a href="#">Prev</a></li>
    <li><a href="#">1</a></li>
    <li><a href="#">2</a></li>
    <li><a href="#">3</a></li>
    <li><a href="#">4</a></li>
    <li><a href="#">5</a></li>
    <li><a href="#">Next</a></li>
  </ul>
</div>
</div>


</div>