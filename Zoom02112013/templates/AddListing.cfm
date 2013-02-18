
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfparam name="Step" default="1">

<cfset ContentStyle="content">
<cfset ShowRightColumn="0">
<cfinclude template="../includes/eventFunctions.cfm">

<cfquery name="getImpressionSection" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SectionID
	From PageSections
	Where PageID = <cfqueryparam value="#PageID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfset ImpressionSectionID=getImpressionSection.SectionID>
<cfif not Len(ImpressionSectionID)>
	<cfset ImpressionSectionID = 0>
</cfif>

<cfif not IsDefined('application.SectionImpressions')>
	<cfset application.SectionImpressions= structNew()>
</cfif>
<cfif StructKeyExists(application.SectionImpressions,ImpressionSectionID)>
	<cfset application.SectionImpressions[ImpressionSectionID] = application.SectionImpressions[ImpressionSectionID] + 1>
<cfelse>
	<cfset application.SectionImpressions[ImpressionSectionID] = 1>
</cfif>

<cfinclude template="header.cfm">
<script type="text/javascript" src="Lighthouse/Resources/js/lighthouse_all.js"></script>

<!--- <cfoutput>#Request.Page.GetCookieCrumb()#</cfoutput><br>
<cfoutput>#Request.Page.GetSectionName()#</cfoutput> --->

<!--- <lh:MS_SitePagePart id="title" class="title">
<lh:MS_SitePagePart id="body" class="body">

 --->
 
 <!--- If linkID is present (they clicked on a link in the email) and the lsitings is an accountholder's listing, and they are not logged in (or logged in as someone else), log them in. --->
<cfif IsDefined('LinkID')>
	<cfquery name="checkAccount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.InProgressUserID, O.UserID
		From Listings L
		Left outer join Orders O on L.OrderID=O.OrderID
		Where L.LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfif Len(checkAccount.InProgressUserID) or Len(checkAccount.UserID)>
		<cfif Len(checkAccount.UserID)>
			<cfset UserID=checkAccount.UserID>
		<cfelseif Len(checkAccount.InProgressUserID)>
			<cfset UserID=checkAccount.InProgressUserID>
		</cfif>
		<cfif not IsDefined('session.UserID') or session.UserID neq UserID>
			<cfset session.userID = UserID>
			<cfcookie name="LoggedIn" value="1">
		</cfif>
	</cfif>
	
</cfif>

<cfoutput>
<div class="centercol-inner-wide legacy legacy-wide">
	<h1 id="PostAListingTitle">Post A<span id="PostAListingTypeSpan"></span> Listing</h1>

<br />
 <div class="breadcrumb"><a href="<cfif cgi.https is "on">#Request.HttpsURL#<cfelse>#Request.HttpURL#</cfif>/">Home</a> &gt; <span id="crumb">Post A Listing</span></div>
	<div>&nbsp;</div>
</cfoutput>
<cfif edit>
	<p>Text to display on initial page when user is not logged in.</p>
	<lh:MS_SitePagePart id="bodyPleaseLogIn" class="body">
	<p>Text to display on initial page (once user is logged in).</p>
	<lh:MS_SitePagePart id="body" class="body">
	<p>Text to display when attempting to add a Travel and Tourism listing without being a T&T business.</p>
	<lh:MS_SitePagePart id="bodyTravel" class="body">	
	<p>Text to display on second page. (Listing details)</p>
	<lh:MS_SitePagePart id="bodyTwo" class="body">	
	<p>Text to display on third page when user has not yet submitted the listing.</p>
	<lh:MS_SitePagePart id="bodyThree" class="body">	
	<p>Text to display on third page when user has already submitted the listing.</p>
	<lh:MS_SitePagePart id="bodyThreeSubmitted" class="body">	
	<p>Text to display on third page when listing can contain an ELP and user has not yet submitted a listing.</p>
	<lh:MS_SitePagePart id="bodyThreeELP" class="body">	
	<p>Text to display on third page when listing can contain an ELP and user has already submitted a listing.</p>
	<lh:MS_SitePagePart id="bodyThreeSubmittedELP" class="body">	
	<p>Text to display on fourth page. (Thank you and confirmation)</p>
	<lh:MS_SitePagePart id="bodyFour" class="body">	
	<p>Text to display on Save for Later page. </p>
	<lh:MS_SitePagePart id="bodyFive" class="body">
<cfelseif not IsDefined('session.UserID') or not Len(session.UserID)>
	<cfset allFields="FirstName,Email,AreaID,GenderID,BirthMonthID,BirthYearID,SelfIdentifiedTypeID,EducationLevelID">
	<cfinclude template="../includes/setVariables.cfm">
	<cfmodule template="../includes/_checkNumbers.cfm" fields="AreaID,GenderID,BirthMonthID,BirthYearID,EducationLevelID,SelfIdentifiedTypeID">
	<lh:MS_SitePagePart id="bodyPleaseLogIn" class="body">
	<cfset IncludeAlertSectionSelect = "0">
	<cfinclude template="../includes/CreateEditAccountForm.cfm">
<cfelse>
 	<cfswitch expression="#Step#">
	 	<cfcase value="1">
			<lh:MS_SitePagePart id="body" class="body">
			<!--- Section and Category --->
			<p>&nbsp;</p>
			<cfinclude template="../includes/AddListingStepOne.cfm">
		</cfcase>
	 	<cfcase value="2">
			<!--- Details --->
			<cfinclude template="../includes/AddListingStepTwo.cfm">
		</cfcase>
	 	<cfcase value="3">
			<!--- Process CC --->
			<cfinclude template="../includes/AddListingStepThree.cfm">
		</cfcase>
	 	<cfcase value="4">
			<!--- Confirmation page and Email --->
			<lh:MS_SitePagePart id="bodyFour" class="body">
			<p>&nbsp;</p>
			<cfinclude template="../includes/AddListingStepFour.cfm">
		</cfcase>
	 	<cfcase value="5">
			<!--- Save for later and Email --->
			<lh:MS_SitePagePart id="bodyFive" class="body">
			<p>&nbsp;</p>
			<cfinclude template="../includes/AddListingStepFive.cfm">
		</cfcase>
	 </cfswitch>	
</cfif>

</div>

<!-- END CENTER COL -->
<cfinclude template="footer.cfm">
