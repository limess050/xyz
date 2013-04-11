<!DOCTYPE html>
<html lang="en">
<head>
		<base href = "<?php echo base_url(); ?>" />
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<META NAME="country" CONTENT="Tanzania">
		
	
		<link rel=stylesheet href="styles/style.css?V=02152013" type="text/css">
		<link rel=stylesheet href="styles/menu.css?V=02152013" type="text/css">


		<script type="text/javascript" src="js/jquery-1.5.1.min.js"></script>
		<!--  jQuery UI script -->
		<script type="text/javascript" src="js/jquery-ui-1.8.12.custom.min.js"></script>

			<!--  jCarousel library -->
			<script type="text/javascript" src="js/jquery.jcarousel.min.js"></script>
			<!--  jCarousel skin stylesheet -->
			<link rel="stylesheet" type="text/css" href="styles/skin.css" />
			<!--  jCarousel carousel script -->
			<script type="text/javascript" src="js/carousel.js" language="javascript"></script>
			<script type="text/javascript" src="js/lighthouse_all.js" language="javascript"></script>

			    <script src="js/tabcontent.js" type="text/javascript"></script>
    <link href="styles/tabcontent.css" rel="stylesheet" type="text/css" />


		<?php
			if(isset($Meta->BrowserTitle) and ($Meta->BrowserTitle != '' ))
				$BrowserTitle = $Meta->BrowserTitle;
			else
				$BrowserTitle = $Meta->H1Text;

			if(isset($Meta->MetaDescr) and $Meta->MetaDescr != '')
				$MetaDescr = $Meta->MetaDescr;
			else
				$MetaDescr = '';


		?>
		<title><?php echo $BrowserTitle; ?></title>

		<META NAME="description" CONTENT="<?php echo $MetaDescr; ?>">

		<script>

  </script>
</head>
<body>
	<div class="wrapper">
		<div class="masthead">
		<div class="myaccount"><a href="myaccount" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-myaccount','','images/sitewide/btn.myaccount_on.gif',1)"><img src="images/sitewide/btn.myaccount_off.gif" alt="My Account" name="btn-myaccount" width="114" height="25" border="0" id="btn-myaccount" /></a></div>
		<div class="loggedIn">&nbsp;&nbsp;<noscript><div style="color:red">This site requires javaScript to function correctly. Please use your browser's options to enable javaScript.</div></noscript>
		<!-- <span id="UserWelcome"><cfif IsDefined('session.UserID') and Len(session.UserID) and IsDefined('session.UserName')>Welcome, #session.UserName#<br>&nbsp;&nbsp;&nbsp;&nbsp;<a href="Logout=Y">(log out)</a>&nbsp;&nbsp;&nbsp;</cfif></span> --></div>
		<div class="search searchByID">
			<form action="#lh_getPageLink(53,'sitesearch')#" method="get" onSubmit="return checkListingID(this);">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Search by Listing ID#&nbsp;&nbsp;<input name="searchString" type="text" value="Listing ID" class="searchByIDfield" maxlength="7"  onFocus="if (this.value=='Listing ID') {this.value=''};"/>
				<input type="hidden" name="SearchByID" value="1">
				<input name="go" id="btn-go" type="image" value="Go" src="images/sitewide/btn.go_off.gif" alt="Search" align="absmiddle" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-go','','images/sitewide/btn.go_on.gif',1)" />
			</form>
		</div>
		<div class="search searchByName">
			<form action="#lh_getPageLink(53,'sitesearch')#" method="get">
				<span id="SearchByNameField" style="float: right;">
				<input name="searchString" type="text" value="Search ZoomTanzania.com" class="searchfield" maxlength="50"  onFocus="if (this.value=='Search ZoomTanzania.com') {this.value=''};"/>
				<input name="go" id="btn-go" type="image" value="Go" src="images/sitewide/btn.go_off.gif" alt="Search" align="absmiddle" onmouseout="MM_swapImgRestore()" onmouseover="MM_swapImage('btn-go','','images/sitewide/btn.go_on.gif',1)" />
				</span>
				<span id="searchByNameText" style="float: right;">
				Search by Business Name or Type of Business&nbsp;&nbsp;<br>
				Ex: Auto Emporium OR Car Dealers
				</span>
			</form>
		</div>
		<div class="clear"></div>
	</div>
	
	<!-- LOGO AND AD ROW -->
	<div class="logoandad">
		<div id="logo" class="float-left"><a href=""><img src="images/sitewide/logoZoom.gif"  alt="ZoomTanzania. Find What You Need - Fast!" /></a></div>
		<div id="ad" class="float-right">
			<img src = "images/Airtel-Bure.jpg">	
		</div>
		<div class="clear"></div>
	</div>
