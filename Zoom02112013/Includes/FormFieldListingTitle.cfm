<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>


<cfif Action is "Form">	
	<cfoutput>	
		<tr>
			<td class="rightAtd">
				<cfswitch expression="#caller.ListingTypeID#">
					<cfcase value="1,10,20">
						*&nbsp;Business/Organization Name:
					</cfcase>
					<cfcase value="2">
						*&nbsp;Restaurant&nbsp;Name:
					</cfcase>
					<cfcase value="9">
						*&nbsp;Trip&nbsp;Name:
					</cfcase>
					<cfcase value="11,13">
						*&nbsp;Headline:
					</cfcase>
					<cfcase value="14">
						*&nbsp;Organization&nbsp;Name:
					</cfcase>
					<cfcase value="15">
						*&nbsp;Event&nbsp;Name:
					</cfcase>
					<cfcase value="6,7,8">
						*&nbsp;Listing&nbsp;Title:
					</cfcase>
					<cfdefaultCase>
						*&nbsp;Descriptive&nbsp;Title:
					</cfdefaultcase>
				</cfswitch>
				<cfif not IsDefined('session.UserID') or not Len(session.UserID) and ListFind("1,2,14",caller.ListingTypeID)>
					<br /><span class="instructions">As you want it to appear as the title of your listing.  You will provide your Registered Company Name later in the form.</span>
				</cfif>
			</td>
			<td>
				<input name="ListingTitle" id="ListingTitle" value="#caller.ListingTitle#" size="45" maxLength="200" <cfif ListFind("11,15",caller.ListingTypeID)>style="width:250px"</cfif>>
				<div ID="ListingTitleWarningDiv" style="color:red;display:none;"></div>
				<input type="hidden" name="AllowListingTitleSubmit" ID="AllowListingTitleSubmit" value="1">
			</td>
		</tr>
	</cfoutput>
<cfelseif Action is "Process">	
	<!--- If HR or FSBO ot TTT and Listing is live and title is being changed, send email to admin --->
	<cfif ListFind("3,4,5,6,7,8,9",caller.ListingTypeID) and Len(caller.ExpirationDate)>
		<cfquery name="getOrigTitle"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select Title
			From Listings
			Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfif caller.ListingTitle neq getOrigTitle.Title>
			<cfmail to="#Request.MailToFormsTo#" from="#Request.MailToFormsFrom#" subject="Listing #caller.ListingID#'s Title Changed" type="HTML">
				<p>
					New Title: <a href="#Request.HTTPURL#/ListingDetail?ListingID=#caller.ListingID#">#caller.ListingTitle#</a><br />
					Previous Title: #getOrigTitle.Title#
				</p>
			</cfmail>
		</cfif>
	</cfif>
	<cfquery name="updateListing"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Update Listings
		Set Title=<cfqueryparam value="#caller.ListingTitle#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.ListingTitle)#">,
		URLSafeTitle=<cfqueryparam value="#REreplace(caller.ListingTitle, "[^a-zA-Z0-9]","","all")#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(caller.ListingTitle)#">
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
<cfelseif Action is "Validate">	
	<cfswitch expression="#caller.ListingTypeID#">
		<cfcase value="1,2,10">
			if (!checkText(formObj.elements["ListingTitle"],"Business Name")) return false;	
		</cfcase>
		<cfcase value="9">
			if (!checkText(formObj.elements["ListingTitle"],"Trip Name")) return false;	
		</cfcase>
		<cfcase value="11,13">
			if (!checkText(formObj.elements["ListingTitle"],"Headline")) return false;	
		</cfcase>
		<cfcase value="14">
			if (!checkText(formObj.elements["ListingTitle"],"Organization Name")) return false;	
		</cfcase>
		<cfcase value="15">
			if (!checkText(formObj.elements["ListingTitle"],"Event Name")) return false;	
		</cfcase>
		<cfdefaultCase>
			if (!checkText(formObj.elements["ListingTitle"],"Descriptive Title")) return false;	
		</cfdefaultcase>
	</cfswitch>		
	<cfif ListFind("1,2,14",caller.ListingTypeID)>
		checkListingTitleIsUniqueSync();
		if (formObj.elements["AllowListingTitleSubmit"].value==0) {
			alert('A business listing already exists with the name "' + formObj.elements["ListingTitle"].value + '". The business name must be unique.');
			formObj.elements["ListingTitle"].focus();
			return false;
		}
	</cfif>
</cfif>
