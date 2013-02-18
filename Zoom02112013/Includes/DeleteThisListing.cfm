
	<p><br /></p>
	<span id="deleteListingDiv" style="float:right">
	<a href="javascript:<cfif not Len(LinkID) or  getListing.InProgress>deleteNewListing()<cfelse>deleteListing()</cfif>">Delete This Listing</a><!--- <input type="button" name="Delete" value="Delete This Listing" class="btn" <cfif not Len(LinkID) or  getListing.InProgress>onClick="deleteNewListing()"<cfelse>onClick="deleteListing()"</cfif> > --->
	</span>
	<br clear="all">

<cfoutput>
<script>
	function deleteListing(){
		if (confirm('Are you sure you want to delete this listing?')) {
			var datastring = "LinkID=#LinkID#";
	           
			$.ajax(
	           {
				type:"POST",
	               url:"#Request.HTTPURL#/includes/MyListings.cfc?method=Delete&returnformat=plain",
	               data:datastring,
	               success: function(response)
	               {
						<cfif IsDefined('session.UserID') and Len(session.UserID)>
							location.href="#lh_getPageLink(7,'myaccount')#";		
						<cfelse>
							location.href="#lh_getPageLink(5,'postalisting')#";		
						</cfif>								
	               }
	           });
		}
	}
	
	function deleteNewListing(){
		if (confirm('Are you sure you want to delete this listing?')) {
			var datastring = "LinkID=#LinkID#";
	           
			$.ajax(
	           {
				type:"POST",
	               url:"#Request.HTTPURL#/includes/MyListings.cfc?method=DeleteNew&returnformat=plain",
	               data:datastring,
	               success: function(response)
	               {
				   		var resp = jQuery.trim(response);
						if (resp=='Deleted' || resp=='No Listing') {
							<cfif IsDefined('session.UserID') and Len(session.UserID)>
								location.href="#lh_getPageLink(7,'myaccount')#";		
							<cfelse>
								location.href="#lh_getPageLink(5,'postalisting')#";		
							</cfif>
						}
	               }
	           });
		}
	}
</script>
</cfoutput>