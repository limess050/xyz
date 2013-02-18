<cfparam name="ListingEditTemplate" default="0">
<cfoutput>
	function blacklistListingsAccount(t,x){
		if (confirm('Are you sure you want to Blacklist this Listing\'s Account?')) {
			var datastring = "PK=" + x;
			$.ajax(
	           {
				type:"POST",
	               url:"#Request.HTTPSURL#/Admin/BlacklistAccount.cfc?method=AddByListing&returnformat=plain",
	               data:datastring,
	               success: function(response)
	               {
				<cfif ListingEditTemplate>
					$("td.ACTIONCELL:last").show();
					$("td.ACTIONCELL:last").prev().hide();
				<cfelse>
					$(t).parent().hide();
					$(".UBLBut").show();
				</cfif>
				//alert('Account Blacklisted');
	               }
	           });	
		}		
	}
	
	function unblacklistListingsAccount(t,x){
		if (confirm('Are you sure you want to Un-Blacklist this Listing\'s Account?')) {
			var datastring = "PK=" + x;
			$.ajax(
	           {
				type:"POST",
	               url:"#Request.HTTPSURL#/Admin/BlacklistAccount.cfc?method=RemoveByListing&returnformat=plain",
	               data:datastring,
	               success: function(response)
	               {
	               		<cfif ListingEditTemplate>
					$("td.ACTIONCELL:last").hide();
					$("td.ACTIONCELL:last").prev().show();
				<cfelse>
					$(t).parent().hide();
					$(".BLBut").show();
				</cfif>					
				//alert('Account Blacklisted');
	               }
	           });	
		}		
	}
</cfoutput>