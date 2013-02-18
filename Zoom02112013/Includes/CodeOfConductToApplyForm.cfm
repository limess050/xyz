<!--- This template expects a ListingID. --->

<cfparam name="DoIt" default="0">

<cfif DoIt><!--- Process --->
	<cfquery name="getUserInfo" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Insert into UserCodeOfConduct
		(UserID, CodeOfConductID,AgreedDate)
		VALUES
		(<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">,
		3,
		<cfqueryparam cfsqltype="cf_sql_date" value="#application.CurrentDateInTZ#">)
	</cfquery>
	<cflocation url="#Request.httpsUrl#/ListingDetail?ListingID=#ListingID#&ShowEmail=1" addToken="No">
	<cfabort>
<cfelse>
	<!--- Display Form --->
	<script>
		function validateCOCForm(formObj) {
			allChecked=0;
			$('.COCInput').each(function(i, element){
				if ($(element).attr('checked')==false && allChecked==0) {
					alert('You must select all checkboxes before proceeding');
					allChecked=1;
				}
			});
			if (allChecked==1){
				return false;
			}
			return true;
		}
	</script>
	<cfoutput>
		<cfif not IsDefined('ListingID') or not IsNumeric(ListingID) or not Len(ListingID)>
			No Listing found.
		<cfelse>
			<div class="body">
				
			</div>
			<form name="f100" action="#request.httpUrl#/includes/CodeOfConductToApplyForm.cfm" method="post" ONSUBMIT="return validateCOCForm(this)">
			<input type="hidden" name="redirecturl" value="#Request.httpsUrl#/ListingDetail?ListingID=#ListingID#&CE=1">
			<table border="0" cellspacing="" cellpadding="" class="datatable">
				<tr>
					<td colspan=2>
						<strong>Job applicants must register and agree to the following Code of Conduct before applying for jobs or posting a CV.  Please indicate your agreement with each of the statements below by checking the boxes in the left column.
						<br><br>Code of Conduct: </strong>
					</td>		
				</tr>		
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC1" class="COCInput" value = "1">
					</td>
					<td>
						I will thoroughly read job descriptions and application instructions for each job before submitting an application.		
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC2" class="COCInput" value = "1">
					</td>
					<td>
						I will only apply for jobs for which I meet the minimum requirements and for which I am truly qualified for.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC3" class="COCInput" value = "1">
					</td>
					<td>
						My CV / Resume is up-to-date and truthfully represents my work history, education, certifications and professional accomplishments.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC4" class="COCInput" value = "1">
					</td>
					<td>
						I understand that failure to comply with the rules above can result in my being blocked from applying to job vacancy listings on ZoomTanzania.com.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC5" class="COCInput" value = "1">
					</td>
					<td>
						I understand that I should never be asked to make a payment to apply for any job.  I will report to ZoomTanzania.com any employer that requests a payment.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC6" class="COCInput" value = "1">
					</td>
					<td>
						I have read and understand the ZoomTanzania.com "<a target = "_blank" href = 'http://www.zoomtanzania.com/job-seekers-guide' title = 'Job Seekers Guide'>Job Seekers Guide</a>"
					</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td>
						&nbsp;<br>
						<input type="submit" name="submit" value="Submit" class="btn">
					</td>
				</tr>
			</table>
			<input type="hidden" name="doit" value="1">
			<input type="hidden" name="ListingID" value="#ListingID#">
			</form>
		</cfif>
	</cfoutput>
</cfif>

