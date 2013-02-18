<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>

<cfif Action is "Form">	
	<cfoutput>			
		<tr>
			<td class="rightAtd">
				<cfif not caller.PhoneOnlyEntry>*&nbsp;</cfif>Location/Directions:<br>
				<span class="instructions">Assume the customer is not familiar with your location or street.  Provide clear, concise and descriptive driving directions.</span>
				<!--- <cfswitch expression="#caller.ListingTypeID#">
					<cfcase value="1,2,14,15">
						*&nbsp;Location/Directions:<br>
						<span class="instructions">Assume the customer is not familiar with your location or street.  Provide clear, concise and descriptive driving directions.</span>		
					</cfcase>
					<cfdefaultCase>
						*&nbsp;Location:
					</cfdefaultcase>
				</cfswitch> --->
			</td>
			<td>
				<textarea name="LocationText" id="LocationText" cols="35" rows="3">#caller.LocationText#</textarea>
			</td>
		</tr>
		<script type="text/javascript">
			function CKLocationText() {
				CKEDITOR.replace( 'LocationText',
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
			
			CKLocationText();
		</script>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set LocationText=<cfqueryparam value="#caller.LocationText#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.LocationText)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">			
	CKEDITOR.instances.LocationText.updateElement();
	<cfswitch expression="#caller.ListingTypeID#">
		<cfcase value="1,2">
			<cfif not caller.PhoneOnlyEntry>if (!checkText(formObj.elements["LocationText"],"Directions")) return false;</cfif>
		</cfcase>
		<cfdefaultCase>
			<cfif not caller.PhoneOnlyEntry>if (!checkText(formObj.elements["LocationText"],"Location")) return false;</cfif>
		</cfdefaultcase>
	</cfswitch>	
</cfif>

