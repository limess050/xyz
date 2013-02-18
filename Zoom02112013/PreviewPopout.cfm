<!--- This template expects a HeaderID, BodyID or FooterID. --->

<cfset Edit="0">
<cfimport prefix="lh" taglib="Lighthouse/Tags">
<cfparam name="TemplateHTML" default="">

<cfset allFields="HeaderID,BodyID,FooterID,BackgroundColorID">
<cfinclude template="includes/setVariables.cfm">
<cfmodule template="includes/_checkNumbers.cfm" fields="HeaderID,BodyID,FooterID,BackgroundColorID">

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Everything DAR - Find What you Need &mdash; Fast!  |  Home</title>
<meta http-equiv="X-UA-Compatible" content="IE=7" />
<link href="expandedlisting.css" rel="stylesheet" type="text/css" />
</head>
<body>
<cfif Len(HeaderID)>
	<cfquery name="getPreview"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select HTML
		From Headers
		Where HeaderID =  <cfqueryparam value="#HeaderID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfset TemplateHTML=getPreview.HTML>
</cfif>
<cfif Len(BodyID)>
	<cfquery name="getPreview"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select HTML
		From Bodies
		Where BodyID =  <cfqueryparam value="#BodyID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfset TemplateHTML=getPreview.HTML>
</cfif>
<cfif Len(FooterID)>
	<cfquery name="getPreview"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select HTML
		From Footers
		Where FooterID =  <cfqueryparam value="#FooterID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfset TemplateHTML=getPreview.HTML>
</cfif>
<cfif Len(BackgroundColorID)>
	<cfquery name="getPreview"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select HTML
		From Headers
		Where HeaderID = 1
	</cfquery>
	<cfset TemplateHTML=getPreview.HTML>
	<cfswitch expression="#BackgroundColorID#">
		<cfcase value="2">
			<cfset TemplateHTML=ReplaceNoCase(TemplateHTML,'class="white"','class="blue"','ALL')>
		</cfcase>
		<cfcase value="3">
			<cfset TemplateHTML=ReplaceNoCase(TemplateHTML,'class="white"','class="mint"','ALL')>
		</cfcase>
		<cfcase value="4">
			<cfset TemplateHTML=ReplaceNoCase(TemplateHTML,'class="white"','class="wheat"','ALL')>
		</cfcase>
		<cfcase value="5">
			<cfset TemplateHTML=ReplaceNoCase(TemplateHTML,'class="white"','class="lilac"','ALL')>
		</cfcase>
	</cfswitch>
</cfif>


	
	
	
	

<div id="popout-wide">
	<!-- popout button --><!--<div id="popout-close"><a href="#"><img src="images/inner/btn.close.gif" width="61" height="17" alt="CLOSE" onclick="tb_remove()"/></a></div>-->
	<!-- popout content -->
	<div id="popout-content">
		<cfoutput>#TemplateHTML#</cfoutput>
	</div> 
</div>

</body>
</html>