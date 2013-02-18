<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>

<cfif Action is "Form">		
	<cfoutput>					
		<cfif ListFind("10,11",caller.ListingTypeID)>
			<tr>
				<td colspan="2">
					<cfif caller.ListingTypeID is "11">
						Please either use the following open Resume/CV field to type in or copy and paste your resume OR upload your Resume/CV document in the Upload field.
					<cfelse>
						Please either use the following open <cfif caller.CategoryID is "289">Tender<cfelse>Position</cfif> Description field to type in or copy and paste your resume OR upload your Position Description in the Upload field.
					</cfif>
				</td>
			</tr>
		</cfif>	
		<tr>
			<td class="rightAtd">
				<cfswitch expression="#caller.ListingTypeID#">
					<cfcase value="11">
						Resume/CV:
						<cfset caller.IncludeCKEditor="1">
					</cfcase>
					<cfcase value="13">
						*&nbsp;Experience&nbsp;&&nbsp;Qualifications&nbsp;Summary:
					</cfcase>
					<cfdefaultCase>
						<cfif caller.CategoryID is "289">Tender<cfelse>Position</cfif>&nbsp;Description:
					</cfdefaultcase>
				</cfswitch>				
			</td>
			<td>
				<textarea name="LongDescr" id="LongDescr" cols="35">#caller.LongDescr#</textarea>
			</td>
		</tr>
		<script type="text/javascript">
			function CKLongDecr() {
				CKEDITOR.replace( 'LongDescr',
					{
				        filebrowserImageUploadUrl : 'fileUpload.cfm',
						height:"225", width:"550",
						toolbar :
						[
							['Cut','Copy','Paste','Bold','Italic','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
							['SpellChecker','Scayt']
						]
					});
				CKEDITOR.instances["LongDescr"].on("instanceReady", function()
					{
						//set keyup event
						this.document.on("keyup", checkPositionDescrDoc);
						
						 //and paste event
						this.document.on("paste", checkPositionDescrDoc);
					});
			}
			
			CKLongDecr();
		</script>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set LongDescr=<cfqueryparam value="#caller.LongDescr#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.LongDescr)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
	CKEDITOR.instances.LongDescr.updateElement();
	<cfswitch expression="#caller.ListingTypeID#">
		<cfcase value="12">
			if (!checkText(formObj.elements["LongDescr"],"Position Description")) return false;	
		</cfcase>
		<cfcase value="13">
			if (!checkText(formObj.elements["LongDescr"],"Experience & Qualiifications Summary")) return false;	
		</cfcase>
	</cfswitch>						
</cfif>
