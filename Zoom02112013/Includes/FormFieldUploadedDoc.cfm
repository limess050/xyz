<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>

<cfif Action is "Form">	
	<cfoutput>
		<tr>
			<td class="rightAtd">
				<cfswitch expression="#caller.ListingTypeID#">
					<cfcase value="11">
						Uploaded&nbsp;Resume/CV:
					</cfcase>
					<cfdefaultCase>
						<cfif caller.CategoryID is "289">Tender<cfelse>Position</cfif>&nbsp;Description&nbsp;Document:
					</cfdefaultcase>
				</cfswitch>
			</td>
			<td style="vertical-align: top;">
				<span style="float:left;">
				<input name="UploadedDoc" id="UploadedDoc" type="file">
				<input value="#caller.UploadedDoc#" id="ExistingUploadedDoc" name="ExistingUploadedDoc" type="hidden">
				</span>
				<span id="ExistingUploadedDocTN" style="float: right;"><cfif Len(caller.UploadedDoc)>&nbsp;(#caller.UploadedDoc#)</cfif></span>
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<cfif Len(caller.ExistingUploadedDoc) and (Len(caller.UploadedDoc) or (ListFind("10,11",caller.ListingTypeID) and Len(caller.LongDescr)))>
	<!--- Delete Doc if new doc is being uploaded, or if Position Description textarea has value when ListingTYpe is JE1 --->		
		<cfif FileExists("#Request.ListingUploadedDocsDir#\#caller.ExistingUploadedDoc#")>
			<cffile action="Delete" file="#Request.ListingUploadedDocsDir#\#caller.ExistingUploadedDoc#">
		</cfif>
		
		<cfquery name="deleteDoc" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update Listings
			Set UploadedDoc=null				
			Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cfif>
	<cfif Len(caller.UploadedDoc)>
		<cffile action="upload" filefield="UploadedDoc" destination="#Request.ListingUploadedDocsDir#" nameconflict="MakeUnique">

		<!--- Check file extension --->
		<cfif Not ListFindNoCase("doc,docx,pdf,txt",cffile.ClientFileExt)>
			<cfif FileExists("#cffile.ServerDirectory#\#cffile.ServerFile#")>
				<cffile action="Delete" file="#cffile.ServerDirectory#\#cffile.ServerFile#">
			</cfif>
			<cflocation url="page.cfm?pageID=5&Step=2&LinkID=#caller.LinkID#&DT=#cffile.ClientFileExt#" addToken="No">
		</cfif>
		
		<cfset fileName = file.serverFile>
		<cfset newFileName = DateFormat(Now(),"DDMMYY") & TimeFormat(Now(),"HHmmss") & REReplaceNoCase(fileName,"[## ?&]","_","ALL")>
		<cfif fileName is not newFileName>
			<cffile action="rename" source="#Request.ListingUploadedDocsDir#\#fileName#" destination="#Request.ListingUploadedDocsDir#\#newFileName#">
		</cfif>
		<cfquery name="addDoc" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Update Listings
			Set UploadedDoc=<cfqueryparam value="#newFileName#" cfsqltype="CF_SQL_VARCHAR">
			Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cfif>
<cfelseif Action is "Validate">	

</cfif>
