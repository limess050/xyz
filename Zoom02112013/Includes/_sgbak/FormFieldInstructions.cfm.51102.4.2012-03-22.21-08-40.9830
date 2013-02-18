<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>

<cfif Action is "Form">	
	<cfoutput>			
		<tr>
			<td class="rightAtd">
				<cfswitch expression="#caller.ListingTypeID#">
					<cfdefaultCase>
						*&nbsp;Application&nbsp;Instructions:
					</cfdefaultcase>
				</cfswitch>				
			</td>
			<td>
				<textarea name="Instructions" id="Instructions" cols="35">#caller.Instructions#</textarea>
			</td>
		</tr>
		<script type="text/javascript">
			function CKInstructions() {
				CKEDITOR.replace( 'Instructions',
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
			
			CKInstructions();
		</script>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set Instructions=<cfqueryparam value="#caller.Instructions#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.Instructions)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
	CKEDITOR.instances.Instructions.updateElement();
	<cfswitch expression="#caller.ListingTypeID#">
		<cfdefaultCase>
			if (!checkText(formObj.elements["Instructions"],"Application Instructions")) return false;	
			if (!checkLength(formObj.elements["Instructions"],2000,"Application Instructions")) return false;
		</cfdefaultcase>
	</cfswitch>						
</cfif>
