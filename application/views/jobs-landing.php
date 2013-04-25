<div id="columncontent">
  <div id="container">
  <!--title-->
    <h1 align="center"><?php echo $sectionMeta->H1Text ?><img src="images/sitewide/blubar.gif" alt="" width="540" height="5" /></h1>
    <div id="welcometext" align="left">
    
     <!--breadcrumbs TO SET-->
      <p class="smallbreadcrumbs">Home &gt; Classifieds &gt; Jobs&gt; Job Vacancies in Tanzania</p>
      
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
  <!--facebook page -->
  
 
  <div  class="fb-like" data-href="http://www.facebook.com/pages/ZoomTanzaniacom/196820157025531" data-send="true" data-width="400" data-show-faces="true"></div>

    </div>
    
   <!--Jobs All list in 2 row for all the categories in the section or subsection-->
    <div class="list">
      <br/>
        <h2 style = "width:300px;"> Job vacancies in Tanzania <?php echo $listings->num_rows(); ?></h2>
        <p align="right"><img src="images/sitewide/button_job.png" width="127" height="36" alt="classified" /></p>
        <br />
     <div><ul>
      <li > <?php foreach($listings->result() as $listing): ?>
        <a href = "listingdetail?ListingID=<?php echo $listing->ListingID; ?>" title = "<?php echo $listing->ShortDescr; ?>"><?php echo $listing->ShortDescr; ?></a><br />
        <?php echo $listing->Location; ?><br />
        Deadline: <?php echo date('d-m-Y',strtotime($listing->Deadline)); ?>
        <br />
        <br />
      <?php endforeach;?></li></ul>
     
  
		</div></div>
    <div id="welcometext" align="left"> 
          <?php if(isset($pageTextObj) and $pageTextObj->num_rows() > 0): ?>
          <?php echo $pageTextObj->row()->Descr; ?><br>
        <?php endif; ?>   
      </div>



</div>