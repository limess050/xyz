<cfparam name="RequiredCodeOfConductID" default="4">

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
<div id="registration">
	<cfoutput>
	<form name="fCOC" action="page.cfm?PageID=#PageID#" method="post" ONSUBMIT="return validateCOCForm(this)">			
		<input type="hidden" name="LinkID" value="#LinkID#">
		<input type="hidden" name="ParentSectionID" value="#ParentSectionID#">
		<input type="hidden" name="ListingSectionID" value="#ListingSectionID#">
		<input type="hidden" name="ListingTypeID" value="#ListingTypeID#">
		<input type="hidden" name="CategoryID" value="#CategoryID#">
		<input type="hidden" name="Step" value="2">
		<input type="hidden" name="AgreedCodeOfConductID" value="#RequiredCodeOfConductID#">
		<table border="0" cellspacing="" cellpadding="" class="datatable">
		<cfswitch expression="#RequiredCodeOfConductID#">
			<cfcase value="1"><!--- Events --->
				<tr>
					<td colspan=2>
						<strong>Thank you for posting an Event Listing.  Please read the following Code of Conduct and indicate your agreement with each of the statements below by checking the boxes in the left column before posting your listing.
						<br><br>Code of Conduct: </strong>
					</td>
				</tr>
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC1" class="COCInput" value = "1" >
					</td>
					<td>
						I will only post Event Listings for companies/organizations for which I am an employee or an authorized representative.		
					</td>
				</tr>		
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC2" class="COCInput" value = "1">
					</td>
					<td>
						I understand that only events with a flier, brochure or other artwork will show on the home page events scroll.
					</td>
				</tr>		
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC3" class="COCInput" value = "1">
					</td>
					<td>
						I understand that only events with a flier, brochure or other artwork are eligible for free promotion in the <a title = "This Week in Tanzania" target = "_blank" href = "http://www.zoomtanzania.com/this-week-in-tanzania-newsletter-archive">"This Week in Tanzania"</a> weekly newsletter.
					</td>
				</tr>		
				<tr>
					<td class="rightAtd">
						<input type="checkbox"  name="COC4" class="COCInput" value = "1">
					</td>
					<td>
						I understand I can add, edit and delete Event Listings from my "My Account" page.
					</td>
				</tr>		
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC5" class="COCInput" value = "1">
					</td>
					<td>
						I will delete or update my Event Listings if they are cancelled, or if there is date/venue change.
					</td>
				</tr>		
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC6" class="COCInput" value = "1">
					</td>
					<td>
						I understand that failure to comply with the rules above can result in my being blocked from using ZoomTanzania.com.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC7" class="COCInput" value = "1">
					</td>
					<td>
						I understand that new listings will not show live on the website until they are reviewed and approved by ZoomTanzania.com.  New listings will be reviewed within 1 business day of the date of posting.
					</td>
				</tr>
			</cfcase>
			<cfcase value="2"><!--- Job Opps --->
				<tr>
					<td colspan=2>
						<strong>Thank you for posting a Job Vacancy listing.  Please read the following Code of Conduct and indicate your agreement with each of the statements below by checking the boxes in the left column before posting your listing.
						<br><br>Code of Conduct: </strong>
					</td>		
				</tr>		
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC1" class="COCInput" value = "1">
					</td>
					<td>
						I will only post job vacancies for companies for which I am an employee or the legally authorized recruitment representative.		
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC2" class="COCInput" value = "1">
					</td>
					<td>
						I understand that providing detailed information for Job Description, Duties & Responsibilities, and Minimum Requirements will greatly improve the quality of applications I receive.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC2" class="COCInput" value = "1">
					</td>
					<td>
						I will only post Job Vacancies for positions located in Tanzania.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC4" class="COCInput" value = "1">
					</td>
					<td>
						I understand I can add, edit and delete job vacancies from my ZoomTanzania.com "My Account" page.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC5" class="COCInput" value = "1">
					</td>
					<td>
						I understand that job vacancies will automatically be deleted on midnight of the "Application Deadline" date that I provide.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC6" class="COCInput" value = "1">
					</td>
					<td>
						I agree to delete any Job Vacancy listing if the position is filled prior to the application deadline.
					</td>
				</tr>						
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC7" class="COCInput" value = "1">
					</td>
					<td>
						I understand that business opportunities, franchise sales and pyramid schemes are not Job Vacancies and will not be permitted.
					</td>
				</tr>						
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC8" class="COCInput" value = "1">
					</td>
					<td>
						I understand that failure to comply with the rules above can result in my being blocked from using ZoomTanzania.com.
					</td>
				</tr>						
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC9" class="COCInput" value = "1">
					</td>
					<td>
						I understand that new listings will not show live on the website until they are reviewed and approved by ZoomTanzania.com.  New listings will be reviewed within 1 business day of the date of posting.
					</td>
				</tr>			
			</cfcase>			
			<cfcase value="4"><!--- Classifieds and Real Estate --->
				<tr>
					<td colspan=2>
						<strong>Thank you for posting a Used Car, Truck or Boat | Real Estate | or For Sale by Owner classified.  Please read the following Code of Conduct and indicate your agreement with each of the statements below by checking the boxes in the left column before posting your listing.
						<br><br>Code of Conduct: </strong>
					</td>		
				</tr>		
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC1" class="COCInput" value = "1">
					</td>
					<td>
						I am the legal owner, or their authorized representative, of the item(s) I will post for sale or rent.		
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC2" class="COCInput" value = "1">
					</td>
					<td>
						The information I will provide will be truthful and accurate to the best of my knowledge.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC3" class="COCInput" value = "1">
					</td>
					<td>
						I will honor the price or rental fee that I will post.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC4" class="COCInput" value = "1">
					</td>
					<td>
						I understand that I will be able to add, edit or delete any listings I create from my ZoomTanzania.com "My Account" page.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC5" class="COCInput" value = "1">
					</td>
					<td>
						I agree to delete my classified listings when they are no longer available for sale or rent.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC6" class="COCInput" value = "1">
					</td>
					<td>
						I understand that failure to comply with the rules above can result in my being blocked from posting future listings on ZoomTanzania.com.
					</td>
				</tr>						
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC7" class="COCInput" value = "1">
					</td>
					<td>
						I understand that new listings will not show live on the website until they are reviewed and approved by ZoomTanzania.com.  New listings will be reviewed within 1 business day of the date of posting.
					</td>
				</tr>			
			</cfcase>
			<cfcase value="5"><!--- CV Posting --->
				<tr>
					<td colspan=2>
						<strong>Thank you for posting a CV / Job Seeker listing on ZoomTanzania.com. Please read the following Code of Conduct and indicate your agreement with each of the statements below by checking the boxes in the left column before posting your listing. 
						<br><br>Code of Conduct: </strong>
					</td>		
				</tr>		
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC1" class="COCInput" value = "1">
					</td>
					<td>
						I certify that the details, work history, certifications and other information in my CV are valid and accurate.	
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC2" class="COCInput" value = "1">
					</td>
					<td>
						I understand that by posting my CV on ZoomTanzania.com I am allowing employers to find my Job Seeker listing and open my CV.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC3" class="COCInput" value = "1">
					</td>
					<td>
						I understand that ZoomTanzania.com does not provide job placement services of any kind. 
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC4" class="COCInput" value = "1">
					</td>
					<td>
						I understand that ZoomTanzania.com is a tool for employers to promote job vacancies, and that I must apply for each job on my own.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC5" class="COCInput" value = "1">
					</td>
					<td>
						I will thoroughly read job descriptions and application instructions for each job before submitting an application.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC6" class="COCInput" value = "1">
					</td>
					<td>
						I will only apply for jobs for which I meet the minimum requirements and for which I am truly qualified for.
					</td>
				</tr>						
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC7" class="COCInput" value = "1">
					</td>
					<td>
						I understand that failure to comply with the rules above can result in my being blocked from applying to job vacancy listings on ZoomTanzania.com.
					</td>
				</tr>					
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC8" class="COCInput" value = "1">
					</td>
					<td>
						I understand that I should never be asked to make a payment to apply for any job.  I will report to ZoomTanzania.com any employer that requests a payment.
					</td>
				</tr>					
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC9" class="COCInput" value = "1">
					</td>
					<td>
						I have read and understand the ZoomTanzania.com "<a title = 'Job Seekers Guide' href = 'http://www.zoomtanzania.com/job-seekers-guide'>Job Seekers Guide</a>"
					</td>
				</tr>			
			</cfcase>			
			<cfcase value="6"><!--- Travel Specials --->
				<tr>
					<td colspan=2>
						<strong>Thank you for posting a Travel Special listing on ZoomTanzania.com. Please read the following Code of Conduct and indicate your agreement with each of the statements below by checking the boxes in the left column before posting your listing. 
						<br><br>Code of Conduct: </strong>
					</td>		
				</tr>		
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC1" class="COCInput" value = "1">
					</td>
					<td>
						I understand that it is my responsibility to maintain my Travel Special Listing with up-to-date contact information and description.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC2" class="COCInput" value = "1">
					</td>
					<td>
						I understand that I can edit or delete my listing at any time by logging into "My Account" from the very top left of any page on ZoomTanzania.com. 
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC3" class="COCInput" value = "1">
					</td>
					<td>
							I will delete this listing if for any reason the offer is no longer available.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC4" class="COCInput" value = "1">
					</td>
					<td>
						I agree to honor any prices quoted in Travel Special my listing.
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC5" class="COCInput" value = "1">
					</td>
					<td>
							I understand that failure to follow the code of conduct above may result in my being blocked from posting listings on ZoomTanzania.com.
					</td>
				</tr>	
			</cfcase>
			<cfcase value="7"><!--- Business Listings --->
				<tr>
					<td colspan=2>
						<strong>Thank you for posting a Business Listing on ZoomTanzania.com. Each month over 500,000 business listing pages are viewed by site users, and over 3,500 inquiry emails are sent to business listed on the site. Please read the following Code of Conduct and indicate your agreement with each of the statements below by checking the boxes in the left column before posting your listing.
						<br><br>Code of Conduct: </strong>
					</td>		
				</tr>		
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC1" class="COCInput" value = "1">
					</td>
					<td>
						I understand that it is my responsibility to maintain my business listings with up-to-date contact information and business description. 
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC2" class="COCInput" value = "1">
					</td>
					<td>
						I understand that I can edit or delete my listing at any time by logging into "My Account" from the very top left of any page on ZoomTanzania.com. 
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC3" class="COCInput" value = "1">
					</td>
					<td>
						I understand that I should maintain a single account, and post all listings of any kind only after logging into my account so I will have access to edit or delete them from a single page. 
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC4" class="COCInput" value = "1">
					</td>
					<td>
						I understand that failure to follow the code of conduct above may result in my being blocked from posting listings on ZoomTanzania.com. 
					</td>
				</tr>				
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC5" class="COCInput" value = "1">
					</td>
					<td>
						I understand that my basic <strong>text only</strong> listing is free.
					</td>
				</tr>
				<tr>
					<td class="rightAtd">
						<input type="checkbox" name="COC6" class="COCInput" value = "1">
					</td>
					<td>
						I understand I can upgrade my listing to a Featured Business Listing that will show at the top of its category page with my logo and a full size flier, advert or PDF for only $75 +VAT per year.  Learn more about <a  title = 'Featured Business Listings' href = 'http://www.zoomtanzania.com/featured-business-listing' >Featured Business Listings by clicking here</a>.
					</td>
				</tr>
			</cfcase>
		</cfswitch>
		<tr>
			<td>&nbsp;</td>
			<td>
				&nbsp;<br>
				<input type="submit" name="submit" value="Submit" class="btn">
			</td>
		</tr>
	</table>
	</form>
		</cfoutput>
</div>