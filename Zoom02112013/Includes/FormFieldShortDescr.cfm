<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>

<cfif Action is "Form">	
	<cfoutput>		
		<tr>
			<td class="rightAtd">
				<cfswitch expression="#caller.ListingTypeID#">					
					<cfcase value="1,2,9,14,20">
						<cfif not caller.PhoneOnlyEntry>*&nbsp;</cfif>Short Promo Copy:
					</cfcase>
					<cfcase value="3,4,5,6,7,8,10,11,12,13">
						*&nbsp;Listing Copy:
					</cfcase>
					<cfcase value="15">
						*&nbsp;Event Description:
					</cfcase>
				</cfswitch>	
			</td>
			<td>
				<textarea name="ShortDescr" id="ShortDescr" cols="50" rows="4">#caller.ShortDescr#</textarea>
			</td>
		</tr>
		<script type="text/javascript">
			function CKShortDecr() {
				CKEDITOR.replace( 'ShortDescr',
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
		Set ShortDescr=<cfqueryparam value="#Trim(caller.ShortDescr)#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.ShortDescr)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
	CKEDITOR.instances.ShortDescr.updateElement();
	<cfswitch expression="#caller.ListingTypeID#">
		<cfcase value="1,2,9,14,20">
			<cfif not caller.PhoneOnlyEntry>if (!checkText(formObj.elements["ShortDescr"],"Short Promo Copy")) return false;</cfif>
			if (!checkLength(formObj.elements["ShortDescr"],2000,"Short Promo Copy")) return false;
		</cfcase>
		<cfcase value="3,4,5,6,7,8,10,11,12,13">
			if (!checkText(formObj.elements["ShortDescr"],"Listing Copy")) return false;
			if (!checkLength(formObj.elements["ShortDescr"],8000,"Listing Copy")) return false;
		</cfcase>
		<cfcase value="15">
			if (!checkText(formObj.elements["ShortDescr"],"Event Description")) return false;
			if (!checkLength(formObj.elements["ShortDescr"],2000,"Event Description")) return false;
		</cfcase>
	</cfswitch>						
</cfif>
