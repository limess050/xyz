<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>

<cfif Action is "Form">	
	<cfoutput>		
		<tr>
			<td class="rightAtd">
				*&nbsp;Prices and Fees:
			</td>
			<td>
				<textarea name="MovieFees" id="MovieFees" cols="50" rows="4">#caller.MovieFees#</textarea>
			</td>
		</tr>
		<script type="text/javascript">
			function CKShortDecr() {
				CKEDITOR.replace( 'MovieFees',
					{
				        filebrowserImageUploadUrl : 'fileUpload.cfm',
						height:"225", width:"520",
						toolbar :
						[
							['Cut','Copy','Paste','Bold','Italic','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
							['SpellChecker','Scayt']
						]
					});				
			}
			
			CKShortDecr();
		</script>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set MovieFees=<cfqueryparam value="#Trim(caller.MovieFees)#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.MovieFees)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
	CKEDITOR.instances.MovieFees.updateElement();
			<cfif not caller.PhoneOnlyEntry>if (!checkText(formObj.elements["MovieFees"],"Prices and Fees")) return false;</cfif>
			if (!checkLength(formObj.elements["MovieFees"],8000,"Prices and Fees")) return false;							
</cfif>
