<cfparam name="ELPShowListingTypes" default="1,2,9,14,15">
<cfparam name="ELPOnStepTwo" default="0">

$(document).ready(function()
	{		    
		<cfoutput>
			<cfif Len(LinkID) and ListFind("#ELPShowListingTypes#",ListingTypeID) and (not IsDefined('session.UserID') or session.UserID neq Request.PhoneOnlyUserID)>
				getExpandedListing()
			</cfif>	
		</cfoutput>
		<cfif ELPOnStepTwo>			
			openELPForm(1);
		</cfif>
	});
	
	function addELPChange(){ 
	   $("#ELPTypeID").bind('change', function(){ 
			if ($("#ELPTypeID").val()==$("#ELPTypeOtherID").val()) {
				$("#ELPTypeOtherDiv").show();			
			}
			else {
				$("#ELPTypeOtherDiv").hide();
			}
			$("#ELPTypeID option:selected").each(function () {
                SelVal = $(this).text() + " ";
          	});
			$("#selectedDocType").html(SelVal);
	   });
	} 
	<cfoutput>
	function getExpandedListing() {
		var datastring = "LinkID=#LinkID#";
		$.ajax(
           {
			type:"POST",
			dataType: 'json',
               url:"#Request.HTTPSURL#/includes/ExpandedListing.cfc?method=Get&returnformat=plain",
               data:datastring,
               success: function(responseVars)
               {
				$("##ExpandedListingDiv").html(responseVars.ExpListingDisplayHTML);
				$("##SubtotalAmountSpan").html('$' + parseFloat(responseVars.SubtotalAmount).toFixed(2));
				$("##SubtotalAmount").val(responseVars.SubtotalAmount);
				$("##VATAmountSpan").html('$' + parseFloat(responseVars.VAT).toFixed(2));
				$("##VAT").val(responseVars.VAT);
				$("##PaymentAmountSpan").html('$' + parseFloat(responseVars.PaymentAmount).toFixed(2));
				$("##PaymentAmount").val(responseVars.PaymentAmount);
               }
           });
	}
	function openELPForm(s) {
		var datastring = "LinkID=#LinkID#";
		if (s==1) {
			var datastring = "LinkID=#LinkID#&ELPOnStepTwo=1&ListingTypeID=#ListingTypeID#";
		}
		$.ajax(
           {
			type:"POST",
			dataType: 'json',
               url:"#Request.HTTPSURL#/includes/ExpandedListing.cfc?method=OpenForm&returnformat=plain",
               data:datastring,
               success: function(responseVars)
               {
				$("##ExpandedListingDiv").html(responseVars.ExpListingDisplayHTML);
				$("##SubtotalAmountSpan").html('$' + parseFloat(responseVars.SubtotalAmount).toFixed(2));
				$("##SubtotalAmount").val(responseVars.SubtotalAmount);
				$("##VATAmountSpan").html('$' + parseFloat(responseVars.VAT).toFixed(2));
				$("##VAT").val(responseVars.VAT);
				$("##PaymentAmountSpan").html('$' + parseFloat(responseVars.PaymentAmount).toFixed(2));
				$("##PaymentAmount").val(responseVars.PaymentAmount);
				addELPChange();
               }
           });
	}
	function deleteExpandedListing() {
		var datastring = "LinkID=#LinkID#";
		$.ajax(
           {
			type:"POST",
               url:"#Request.HTTPSURL#/includes/ExpandedListing.cfc?method=DelExL&returnformat=plain",
               data:datastring,
               success: function(response)
               {				
				location.href='#lh_getPageLink(5,'postalisting')##AmpOrQuestion#Step=3&LinkID=#LinkID#&StatusMessage=#URLEncodedFormat('Featured Listing deleted.')#';
               }
           });
	}
	
	</cfoutput>