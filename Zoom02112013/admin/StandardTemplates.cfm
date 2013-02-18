<!--- This template expects a ListingID. --->

<cfset allFields="ListingID,HeaderID,BodyID,FooterID,BackgroundColorID,DoIt">
<cfinclude template="../includes/setVariables.cfm">
<cfmodule template="../includes/_checkNumbers.cfm" fields="ListingID,HeaderID,BodyID,FooterID,BackgroundColorID,DoIt">

<cfset Edit="0">
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Everything DAR - Find What you Need &mdash; Fast!  | Email Lister</title>
<meta http-equiv="X-UA-Compatible" content="IE=7" />
<link href="style.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../Lighthouse/Resources/js/lighthouse_all.js"></script>
<script type="text/javascript" src="../js/jquery-1.3.2.min.js"></script>

  <script type="text/javascript" src="../js/ui.core.js"></script>
  <script src="../js/coda.js" type="text/javascript"> </script>
  <script type="text/javascript" src="../js/thickbox.js"></script>

  <script type="text/javascript" src="../js/jquery-ui-1.7.2.custom.min.js"></script>
  <script type="text/javascript" src="../js/pause.js"></script>	
<script>
	function validateForm(formObj) {	
		if (!checkChecked(formObj.elements["HeaderID"],"Header Option")) return false;	
		if (!checkChecked(formObj.elements["BodyID"],"Body Option")) return false;	
		if (!checkChecked(formObj.elements["FooterID"],"Footer Option")) return false;	
		if (!checkChecked(formObj.elements["BackgroundColorID"],"Background Color Option")) return false;	
		return true;
	}
</script>
</head>
<body>

<cfquery name="getHeaders"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select HeaderID, Descr
	From Headers
	Order by OrderNum
</cfquery>
<cfquery name="getBodies"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select BodyID, Descr
	From Bodies
	Order by OrderNum
</cfquery>
<cfquery name="getFooters"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select FooterID, Descr
	From Footers
	Order by OrderNum
</cfquery>
<cfquery name="getBackgroundColors"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select BackgroundColorID, Descr
	From BackgroundColors
	Order by OrderNum
</cfquery>
<cfoutput>
<div id="popoutWide">
	<!-- popout button --><!--<div id="popout-close"><a href="##"><img src="images/inner/btn.close.gif" width="61" height="17" alt="CLOSE" onclick="tb_remove()"/></a></div>-->
	<!-- popout content -->
	<div id="popout-content">
		<cfif not IsDefined('ListingID') or not Len(ListingID)>
			No Listing found.
		<cfelse>
			<cfset ExpandedListingFullToolbar="1">
			
			<div id="SpacerToForceToolbarDown">
				<p><br /></p>
				<p><br /></p>
			</div>
			<form name="TemplateForm" action="EditExpandedListingHTML.cfm" method="post" onSubmit="return validateForm(this)">
				<input type="hidden" name="ListingID" ID="ListingID" value="#ListingID#">
				<table cellpadding="5" cellspacing="5">
					<tr>
						<td>
							<p class="greenlarge">Please select the features you would like for the standard template:</p>
						</td>
					</tr>
					<tr>
						<td>
							<p><strong>Header Options:</strong></p>
						</td>
					</tr>
					<tr>
						<td>
							<cfloop query="getHeaders">
								<input type="radio" name="HeaderID" value="#HeaderID#"> #Descr#&nbsp;&nbsp;&nbsp;
							</cfloop>
						</td>
					</tr>
					<tr>
						<td>
							<p><strong>Body Options:</strong></p>
						</td>
					</tr>
					<tr>
						<td>
							<cfloop query="getBodies">
								<input type="radio" name="BodyID" value="#BodyID#"> #Descr#&nbsp;&nbsp;&nbsp;
							</cfloop>						
						</td>
					</tr>
					<tr>
						<td>
							<p><strong>Footer Options:</strong></p>
						</td>
					</tr>
					<tr>
						<td>
							<cfloop query="getFooters">
								<input type="radio" name="FooterID" value="#FooterID#"> #Descr#&nbsp;&nbsp;&nbsp;
							</cfloop>	
						</td>
					</tr>
					<tr>
						<td>
							<p><strong>Background Color Options:</strong></p>
						</td>
					</tr>
					<tr>
						<td>
							<cfloop query="getBackgroundColors">
								<input type="radio" name="BackgroundColorID" value="#BackgroundColorID#"> #Descr#&nbsp;&nbsp;&nbsp;
							</cfloop>	
						</td>
					</tr>
					<tr>
						<td>
							&nbsp;
						</td>
					</tr>
					<tr>
						<td>
							<input type="submit" name="submit" id="submit" value="Next"> <input type="button" name="Cancel" id="Cancel" value="Cancel" onClick="javascript:history.back(1);">
						</td>
					</tr>
				</table>
			</form>
		</cfif>
	</div> 
</div>
<div id="SpacerToForceScrollBar">
	<p><br /></p>
	<p><br /></p>
	<p><br /></p>
	<p><br /></p>
</div>
</cfoutput>
</body>
</html>