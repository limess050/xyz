<!---
Default Template
This template expects a CategoryID
--->



<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfinclude template="header.cfm">

<cfif not AcRunActiveContentIncluded>
	<cfset AcRunActiveContentIncluded="1">
	<cfhtmlhead text='<script src="#request.HTTPSURL#/Scripts/AC_RunActiveContent.js" type="text/javascript"></script>'>
</cfif>
<style type="text/css">
h2.in-house-sub-titles {color: #000; font-size: 18px;}

h3.in-house-sub-sub-titles {color: #000; font-size: 16px; text-align: center; font-weight: bold;}
ul.in-house-lists, ol.in-house-lists { margin:0 0 0 30px;}
ul.in-house-lists li, ol.in-house-lists li{ margin:0 0 10px 0;}
#contact-info{ text-align: center; clear: both; padding-top:30px;  }
</style>


<cfoutput>
<div class="centercol-inner legacy">
 	<h1><lh:MS_SitePagePart id="title" class="title"></h1>
	<p>&nbsp;</p>

 	<div class="breadcrumb""><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/">Home</a> &gt; </div>

</cfoutput>

	<lh:MS_SitePagePart id="body" class="body">
	<div class="centertext top15">
	<script language="javascript">
		if (AC_FL_RunContent == 0) {
			alert("This page requires AC_RunActiveContent.js.");
		} else {
			AC_FL_RunContent(
				'codebase', 'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0',
				'width', '567',
				'height', '76',
				'src', 'uploads/BannerAds/car_dealer1',
				'quality', 'high',
				'pluginspage', 'http://www.macromedia.com/go/getflashplayer',
				'align', 'middle',
				'play', 'true',
				'loop', 'true',
				'scale', 'showall',
				'wmode', 'transparent',
				'devicefont', 'false',
				'id', 'bannerAdPos1',
				'bgcolor', '#ffffff',
				'name', 'car_dealer1',
				'menu', 'true',
				'allowFullScreen', 'false',
				'allowScriptAccess','sameDomain',
				'movie', 'uploads/BannerAds/car_dealer1',
				'salign', ''
				); //end AC code
		}
	</script>
	<noscript>
		<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,24,0" width="675" height="90" id="BannerAdPos1" align="middle">
		<param name="allowScriptAccess" value="sameDomain" />
		<param name="allowFullScreen" value="false" />
		<param name="movie" value="uploads/BannerAds/car_dealer1.swf" /><param name="quality" value="high" /><param name="bgcolor" value="#ffffff" />	<embed src="uploads/BannerAds/car_dealer1.swf" quality="high" bgcolor="#ffffff" width="567" height="76" name="car_dealer1.swf" align="middle" allowScriptAccess="sameDomain" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
		</object>
	</noscript>
	</div>
	<div class="centertext top5">
	<script language="javascript">
		if (AC_FL_RunContent == 0) {
			alert("This page requires AC_RunActiveContent.js.");
		} else {
			AC_FL_RunContent(
				'codebase', 'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0',
				'width', '168',
				'height', '630',
				'src', 'uploads/BannerAds/bank_adv_cs31',
				'quality', 'high',
				'pluginspage', 'http://www.macromedia.com/go/getflashplayer',
				'align', 'middle',
				'play', 'true',
				'loop', 'true',
				'scale', 'showall',
				'wmode', 'transparent',
				'devicefont', 'false',
				'id', 'bannerAdPos3',
				'bgcolor', '#ffffff',
				'name', 'bank_adv_cs31',
				'menu', 'true',
				'allowFullScreen', 'false',
				'allowScriptAccess','sameDomain',
				'movie', 'uploads/BannerAds/bank_adv_cs31308128431109',
				'salign', ''
				); //end AC code
		}
	</script>
	<noscript>
		<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,24,0" width="200" height="750" id="BannerAdPos3" align="middle">
		<param name="allowScriptAccess" value="sameDomain" />
		<param name="allowFullScreen" value="false" />
		<param name="movie" value="uploads/BannerAds/bank_adv_cs31308128431109.swf" /><param name="quality" value="high" /><param name="bgcolor" value="#ffffff" />		<embed src="uploads/BannerAds/bank_adv_cs31.swf" quality="high" bgcolor="#ffffff" width="168" height="630" name="bank_adv_cs31.swf" align="middle" allowScriptAccess="sameDomain" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
		</object>
	</noscript>
	</div>					
					
					
					
					
	<lh:MS_SitePagePart id="body2" class="body">
</div>

<!-- END CENTER COL -->

<cfinclude template="footer.cfm">
