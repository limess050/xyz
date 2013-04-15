<!DOCTYPE html>
<html lang="en">
<head>
<base href = "<?php echo base_url(); ?>" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<META NAME="country" CONTENT="Tanzania">
<?php
		if(isset($Meta->BrowserTitle) and ($Meta->BrowserTitle != '' ))
			$BrowserTitle = $Meta->BrowserTitle;
		else if(isset($Meta->H1Text) and $Meta->H1Text !='')
			$BrowserTitle = $Meta->H1Text;
		else if(isset($Meta->TitleTag) and $Meta->TitleTag != '')
			$BrowserTitle = $Meta->TitleTag;
		else if(isset($Meta->Title) and $Meta->Title != '')
			$BrowserTitle = $Meta->Title;

		if(isset($Meta->MetaDescr) and $Meta->MetaDescr != '')
			$MetaDescr = $Meta->MetaDescr;
		else
			$MetaDescr = '';


	?>
	<title><?php echo $BrowserTitle; ?></title>

	<META NAME="description" CONTENT="<?php echo $MetaDescr; ?>">

	<script>

</script>
<link href="styles/common.css" rel="stylesheet" type="text/css" />

<link rel="shortcut icon" href="../favicon.ico">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
        
        <script type="text/javascript" src="js/legacy/jquery-ui-1.8.12.custom.min.js"></script>
		<link rel="stylesheet" type="text/css" href="styles/megamenudefault.css" />
		<link rel="stylesheet" type="text/css" href="styles/megamenucomponent.css" />
<!-- 		<link href="styles/legacy/menu.css" rel="stylesheet" type="text/css" /> -->
		<link href="styles/tabcontent.css" rel="stylesheet" type="text/css" />
		<link href="styles/home.css" rel="stylesheet" type="text/css" />
		<link href="styles/style_categories.css" rel="stylesheet" type="text/css" />
		<link rel="stylesheet" type="text/css" href="styles/legacy/skin.css" />
				<link href="styles/footer.css?323343" rel="stylesheet" type="text/css" />
		<link href="styles/exchange.css" rel="stylesheet" type="text/css" />
		 <script src="js/tabcontent.js" type="text/javascript"></script>
		 <script src="js/modernizr.custom.js"></script>
      <script src="js/modernizr.custom.63321.js"></script>
        <script src="js/cbpHorizontalMenu.js"></script>
		<script>
			// $(function() {
			// 	cbpHorizontalMenu.init();
			// });

			$(document).ready(function(){
				$('#cbp-hrmenu > ul > li').hover(
					function(){
						$(this).addClass('cbp-hropen');
					},
					function(){
						$(this).removeClass('cbp-hropen');
					}
				);

			});
		</script>
        <script type="text/javascript" src="js/jquery.jcarousel.js"></script>
        <!--<script type="text/javascript" src="js/jquery.jcarousel.min.js"></script>-->
         <script type="text/javascript" src="js/carousel.js" language="javascript"></script>
</head>

<body>
	<div id="loginbar"><div id="loginbutton"><a  href="#">log in</a>  |   <a  href="#">register</a> </div><div id="searchbutton"><input name="zoomsearch" type="text" id="zoomsearch" value="search in zoomtanzania" size="30" maxlength="70" />
	  <a  href="#">  <input name="zoom search" type="button" value="zoom search" /> 
		  
	</a>        
	<input name="zoomidsearch" type="text" id="zoomidsearch" value="# zoom ID" size="10" maxlength="70" />
	  <a  href="#">  
	  <input name="idsearch" type="button" value="#search by ID" />
		  
	</a></div></div>
	<div id="page">
	<div id="bannerextrapage" align="center"><a href="#"></a></div>
	<div id="header">
	<div id="logo">
		<span><img src="images/sitewide/logoZoom.png"  style=""/></span>
		<span id="banner"><a href="#"><img style = "margin-top:12px;" src="images/Airtel-Bure.jpg" alt="banner" width="675" height="83" /></a></span>
	</div>