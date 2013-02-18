<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfswitch expression="#caller.ListingTypeID#">
	<cfcase value="6,7,8">	
		<cfset ListingImagesCount=12>	
	</cfcase>
	<cfcase value="4,5">	
		<cfset ListingImagesCount=8>	
	</cfcase>
	<cfdefaultcase>
		<cfset ListingImagesCount=2>
	</cfdefaultcase>
</cfswitch>

<cfif Action is "Form">	
	<cfoutput>	
		<script>function deleteListingImage(x,y,z){
					if (confirm('Are you sure you want to delete this image?')) {
						var datastring = "LinkID=" + x + "&FileName=" + encodeURIComponent(y);
				           
						$.ajax(
				           {
							type:"POST",
				               url:"#Request.HTTPURL#/includes/ListingImages.cfc?method=Delete&returnformat=plain",
				               data:datastring,
				               success: function(response)
				               {
									 $("##ListingImage" + z + "PreviewSpan").html('Image Deleted');			
				               }
				           });
					}
				}
		</script>
		<tr>
			<td class="rightAtd">
				&nbsp;
			</td>
			<td style="vertical-align: top;">
				<a href="imageoptimization" target="_blank">Save Time Uploading Pictures - Learn How Here</a>
			</td>
		</tr>
		<cfloop from="1" to="#ListingImagesCount#" index="i">
			
			<tr>
				<td class="rightAtd">
					Image:
				</td>
				<td style="vertical-align: top;">
					<span style="float:left;">
					<input name="ListingImage#i#" id="ListingImage#i#" type="file">
					<input value="#Evaluate("caller.ListingImageID" & i)#" id="ListingImageID#i#" name="ListingImageID#i#" type="hidden">
					</span>
					<span id="ListingImage#i#TN" style="float: right;"><cfif Len(Evaluate("caller.ListingImageFileName" & i))><span id="ListingImage#i#PreviewSpan"><img src="#Request.httpURL#/ListingImages/#Evaluate("caller.ListingImageFileName" & i)#" width="90"><br /><a href="javascript:void(0);" onClick="deleteListingImage('#LinkID#','#Evaluate("caller.ListingImageFileName" & i)#',#i#)">Delete image</a></span></cfif></span>
				</td>
			</tr>
		</cfloop>
		
		<!--- <cfif ListFind("4,5,6,7,8",caller.ListingTypeID)>
			<tr>
				<td class="rightAtd">
					Image: 
				</td>
				<td style="vertical-align: top;">
					<span style="float:left;">
					<input name="ListingImageThree" id="ListingImageThree" type="file">
					<input value="#caller.ListingImageIDThree#" id="ListingImageIDThree" name="ListingImageIDThree" type="hidden">
					</span>
					<span id="ListingImageThreeTN" style="float: right;"><cfif Len(caller.ListingImageFileNameThree)><span id="ListingImage3PreviewSpan"><img src="#Request.httpURL#/ListingImages/#caller.ListingImageFileNameThree#" width="90"><br /><a href="javascript:void(0);" onClick="deleteListingImage('#LinkID#','#caller.ListingImageFileNameThree#',3)">Delete image</a></span></cfif></span>
				</td>
			</tr>
			<tr>
				<td class="rightAtd">
					Image:
				</td>
				<td style="vertical-align: top;">
					<span style="float:left;">
					<input name="ListingImageFour" id="ListingImageFour" type="file">
					<input value="#caller.ListingImageIDFour#" id="ListingImageIDFour" name="ListingImageIDFour" type="hidden">
					</span>
					<span id="ListingImageFourTN" style="float: right;"><cfif Len(caller.ListingImageFileNameFour)><span id="ListingImage4PreviewSpan"><img src="#Request.httpURL#/ListingImages/#caller.ListingImageFileNameFour#" width="90"><br /><a href="javascript:void(0);" onClick="deleteListingImage('#LinkID#','#caller.ListingImageFileNameFour#',4)">Delete image</a></span></cfif></span>
				</td>
			</tr>
		</cfif> --->
	</cfoutput>
<cfelseif Action is "Process">	
	<cfloop from="1" to="#ListingImagesCount#" index="i">
		<cfif Len(Evaluate("caller.ListingImage" & i))>
			<cfif Len(Evaluate("caller.ListingImageID" & i))>
				<cfset DeleteImageID=Evaluate("caller.ListingImageID" & i)>
				<cfinclude template="deleteImage.cfm">
			</cfif>
			<cfset FieldName="ListingImage#i#">
			<cfset ImageOrderNum=i>
			<cfinclude template="uploadImage.cfm">
		</cfif>
	</cfloop>
	<!--- <cfif Len(caller.ListingImageTwo)>
		<cfif Len(caller.ListingImageIDTwo)>
			<cfset DeleteImageID=caller.ListingImageIDTwo>
			<cfinclude template="deleteImage.cfm">
		</cfif>
		<cfset FieldName="ListingImageTwo">
		<cfset ImageOrderNum="2">
		<cfinclude template="uploadImage.cfm">
	</cfif>
	<cfif ListFind("4,5,6,7,8",caller.ListingTypeID)>
		<cfif Len(caller.ListingImageThree)>
			<cfif Len(caller.ListingImageIDThree)>
				<cfset DeleteImageID=caller.ListingImageIDThree>
				<cfinclude template="deleteImage.cfm">
			</cfif>
			<cfset FieldName="ListingImageThree">
			<cfset ImageOrderNum="3">
			<cfinclude template="uploadImage.cfm">
		</cfif>
		<cfif Len(caller.ListingImageFour)>
			<cfif Len(caller.ListingImageIDFour)>
				<cfset DeleteImageID=caller.ListingImageIDFour>
				<cfinclude template="deleteImage.cfm">
			</cfif>
			<cfset FieldName="ListingImageFour">
			<cfset ImageOrderNum="4">
			<cfinclude template="uploadImage.cfm">
		</cfif>
	</cfif> --->
<cfelseif Action is "Validate">	

</cfif>
