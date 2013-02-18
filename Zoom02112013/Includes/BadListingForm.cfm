<!--- This template expects a ListingID. --->

<cfquery name="BadListingReasons" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select BadListingReasonID as SelectValue, Title as SelectText 
	From BadListingReasons
	Where Active=1
	Order By OrderNum
</cfquery>

<script src="js/jquery-1.3.min.js"></script>
<script type="text/javascript" src="Lighthouse/Resources/js/lighthouse_all.js"></script>
<script>
	function checkBLForm(f) {
		if (!checkSelected(document.BLForm.elements["BadListingReasonID"],"Type")) return false;	
		if (!checkEmail(document.BLForm.elements["ReporterEmail"],"Your Email")) return false;
		if (!checkText(f.CaptchaEntryBL,"Match Text")) return false;
		if (!captchaValidateBL()) return false;
				
		return true;
	}	
</script>

<cfoutput>		
	<cfif Request.environment is "db" or (not IsDefined('ListingID') or not IsNumeric(ListingID) or not Len(ListingID))>
		No Listing found.
	<cfelse>		
		<form name="BLForm" id="BLForm" action="ReportBadListing.cfm" method="post" onsubmit="return checkBLForm(this)">
			<cfset captcha = CreateObject("component","cfc.Captcha").init("BL",false)>
			#captcha.renderScripts()#
			<table>				
				<tr>
					<td>
						* Type:
					</td>
					<td>
						<select name="BadListingReasonID" id="BadListingReasonID">
							<option value="">-- Select Type --
							<cfloop query="BadListingReasons">
								<option value="#SelectText#">#SelectText#
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td>
						Comment/Details:
					</td>
					<td>
						<textarea cols="25" rows="4" name="BadListingComments" id="BadListingComments"></textarea>
					</td>
				</tr>
				<tr>
					<td>
						Your Name:
					</td>
					<td>
						<input name="ReporterName" id="ReporterName" maxlength="100">
					</td>
				</tr>
				<tr>
					<td>
						Your Email:
					</td>
					<td>
						<input name="ReporterEmail" id="ReporterEmail" maxlength="100">
					</td>
				</tr>
				<tr>
					<td>
						Your Phone:
					</td>
					<td>
						<input name="ReporterPhone" id="ReporterPhone" maxlength="100">
					</td>
				</tr>
					<tr>
						<td valign="top" style="font:12px Arial,Helvetica,sans-serif; padding: 5px;">
							*&nbsp;Match Text<br>
							To protect against spam, please prove you are a real person by typing what you 
							see to the right.  If you can't read it clearly, please click 
							#captcha.renderRefreshButton("refresh")#.
						</td>
						<td>
							#captcha.renderImage()#
							<p>#captcha.renderEntry()#</p>
						</td>
					</tr>
				<tr>
					<td colspan="2">
						<span style="float:right;"><input type="Submit" name="Submit" value="Submit" class="button" id="submit_btn"></span>
					</td>
				</tr>
			</table>
			<input type="hidden" name="ListingID" id="ListingID" value="#ListingID#">
		</form>
	</cfif>
</cfoutput>
