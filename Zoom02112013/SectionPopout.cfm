<!--- This template expects a ParentSectionID and possible a SectionID. --->

<cfset Edit="0">
<cfimport prefix="lh" taglib="Lighthouse/Tags">

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Everything DAR - Find What you Need &mdash; Fast!  |  Home</title>
<meta http-equiv="X-UA-Compatible" content="IE=7" />
<link href="style.css" rel="stylesheet" type="text/css" />
</head>
<body>

<div id="popout">
	<!-- popout button --><!--<div id="popout-close"><a href="#"><img src="images/inner/btn.close.gif" width="61" height="17" alt="CLOSE" onclick="tb_remove()"/></a></div>-->
	<!-- popout content -->
	<div id="popout-content">
		<cfset PopoutFormat="1">
		<cfinclude template="includes/GetSectionLinksTable.cfm">	
	</div> 
</div>

</body>
</html>