<cfimport prefix="lh" taglib="Lighthouse/Tags">

<cfset allFields="ListingID">
<cfinclude template="includes/setVariables.cfm">
<cfmodule template="includes/_checkNumbers.cfm" fields="ListingID">

<cfif ListingID is "17219">
	<cflocation url="ExpandedListing.cfm?ListingID=29482" addToken="No">
	<cfabort>
<cfelseif ListFind("1589,1590,3139,29482",ListingID)>
	<cfquery name="getListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ListingTitle
		From ListingsView L
		Where ListingID =  <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfset ListingLink=REReplace(Replace(Replace(getListing.ListingTitle," - ","-","All")," ","-","All"), "[^a-zA-Z0-9\-]","","all")>
	<cflocation url="#ListingLink#" addToken="No">
	<cfabort>
</cfif>

<cfparam name="ListingHeaderTitle" default="">
<cfparam name="ListingMetaDescr" default="">
<cfinclude template="includes/ListingQueries.cfm">

<cfparam name="Preview" default="0">

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<cfoutput>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title><cfif Len(ListingHeaderTitle)>Advert for #ListingHeaderTitle#<cfelse>Zoom Tanzania - Find What you Need - Fast!</cfif></title>
	<cfif Len(ListingMetaDescr)>
		<META NAME="description" CONTENT="#ListingMetaDescr#">
	</cfif>
	<link href="expandedlisting.css" rel="stylesheet" type="text/css" />

	<script type="text/javascript" src="#Request.HTTPURL#/Lighthouse/Resources/js/lighthouse_all.js"></script>
	<script type="text/javascript" src="#Request.HTTPURL#/js/jquery-1.3.2.min.js"></script>

  	<script type="text/javascript" src="#Request.HTTPURL#/js/ui.core.js"></script>
	<script type="text/javascript" src="#Request.HTTPURL#/js/ui.accordionCustom.js"></script>
	<script type="text/javascript" src="#Request.HTTPURL#/js/coda.js"> </script>
	<script type="text/javascript" src="#Request.HTTPURL#/js/thickbox.js"></script>
	<script type="text/javascript" src="#Request.HTTPURL#/js/jquery-ui-1.7.2.custom.min.js"></script>
 </cfoutput>
</head>

<body class="expanded"><div id="expandedlisting-wrapper">
<cfoutput><div id="expandedlisting-masthead"><div id="expandedlisting-logo"><a href="#Request.HTTPURL#"><img src="images/sitewide/logo.gif" width="349" height="124" alt="<cfif Len(ListingHeaderTitle)>Advert for #ListingHeaderTitle#<cfelse>ZoomTanzania.com</cfif>" /></a></div></cfoutput>

<cfif not Preview>
	<div id="backbutton"><a href="javascript:history.go(-1)">&lt;&lt; Back</a></div></div>
</cfif>

<div class="clear"></div>
<cfif Len(ListingID)>
	<cfquery name="getListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ExpandedListingHTML
		From Listings L
		Where ListingID =  <cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<p>&nbsp;</p>
	<cfoutput>#ReplaceNoCase(getListing.ExpandedListingHTML,"http://ListingUploadedDocs","ListingUploadedDocs","ALL")#</cfoutput>
<cfelse>
	<p>No listing found.</p>
</cfif>
<cfoutput>
	<p>&nbsp;</p>
	<div class="addthis_toolbox addthis_default_style">
		<a class="addthis_button_email"></a>
	    <a class="addthis_button_print"></a>
		<a class="addthis_button" href="http://www.addthis.com/bookmark.php?v=250&amp;username=kirkdar"></a>
	</div>
	<script type="text/javascript">
		var addthis_config = {
		data_track_clickback: true,
	    username: "kirkdar",
	    services_compact: 'fark, bizsugar, facebook, delicious, google, live, aim, adifni, digg, myspace, more'        
	    }
		function jsAppend(js_file)
		{
		    js_script = document.createElement('script');
		    js_script.type = "text/javascript";
		    js_script.src = js_file;
		    document.getElementsByTagName('head')[0].appendChild(js_script);
		}
		jsAppend(window.location.protocol + "//s7.addthis.com/js/250/addthis_widget.js");
	</script>
	<span class="pagination" style="float:right">
		<a href="ReportBadListing.cfm?ListingID=#ListingID#&height=500&width=500" class="thickbox">Report Bad Listings</a>
	</span>

	<script>
		function clickThroughExternal() {			
			var datastring = "ListingID=#ListingID#";    
			$.ajax(
	           {
				type:"POST",
	               url:"#Request.HTTPSURL#/includes/ClickThroughExternal.cfc?method=Increment&returnformat=plain",
	               data:datastring,
	               success: function(response)
	               {			
	               }
	           });		
		}
		
		$( "##expandedlisting-wrapper a:not(.addthis_button,.thickbox)" ).each(
			function( intIndex ){			
				$( this ).bind (
					"click",
					function(){
						clickThroughExternal();
					}
				);			 
			}		
		);
	</script>
</cfoutput>
</div>
</html>
