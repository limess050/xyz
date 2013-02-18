
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfparam name="Step" default="2">

<cfset ContentStyle="content">
<cfset ShowRightColumn="0">

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

<cfif isDefined("form.newUser")>
	<cfquery name="createAccount" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Insert into LH_Users
		(UserName, Password, Active, Company, 
		ContactFirstName, ContactLastName, ContactPhoneLand, ContactPhoneMobile, ContactEmail,
		AltContactFirstName, AltContactLastName, AltContactPhoneLand, AltContactPhoneMobile, AltContactEmail)
		VALUES
		(<cfqueryparam value="#ContactEmail#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(ContactEmail)#">,
		<cfqueryparam value="#InProgressPassword#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(InProgressPassword)#">,
		1,
		<cfqueryparam value="#InProgressCompanyName#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(InProgressCompanyName)#">,
		<cfqueryparam value="#ContactFirstName#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(ContactFirstName)#">,
		<cfqueryparam value="#ContactLastName#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(ContactLastName)#">,
		<cfqueryparam value="#ContactPhone#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(ContactPhone)#">,
		<cfqueryparam value="#ContactSecondPhone#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(ContactSecondPhone)#">,
		<cfqueryparam value="#ContactEmail#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(ContactEmail)#">,
		<cfqueryparam value="#AltContactFirstName#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(AltContactFirstName)#">,
		<cfqueryparam value="#AltContactLastName#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(AltContactLastName)#">,
		<cfqueryparam value="#AltContactPhone#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(AltContactPhone)#">,
		<cfqueryparam value="#AltContactSecondPhone#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(AltContactSecondPhone)#">,
		<cfqueryparam value="#AltContactEmail#" cfsqltype="CF_SQL_VARCHAR" null="#NOT LEN(AltContactEmail)#">)	
				
		Select Max(UserID) as NewUserID
		From LH_Users	
	</cfquery>
	
	 <cfif Request.environment is "Live" or Request.environment is "Devel" or Request.environment is "DB">
          <cfset NewAccountID=createAccount.NewUserID>
          <cfset NewAccountName=InProgressCompanyName>
          <cfset NewUserName=ContactEmail>
		  <cfif Len(AltContactEmail)>
		  	<cfset NewUserName=ListAppend(NewUserName,AltContactEmail)>
		  </cfif>
          <cfset NewPassword=InProgressPassword>
          <cfinclude template="../includes/EmailNewAccount.cfm">
      </cfif>

	<cfset session.UserID=createAccount.NewUserID>
	<cfcookie name="LoggedIn" value="1">
</cfif>


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

<cfif not isDefined("session.userID") OR not Len(session.userID)>
	<cfinclude template="../includes/AddBannerAdContactForm.cfm">
	<cfinclude template="../templates/footer.cfm"></div></div></body></html>
<cfabort>
</cfif>
<cfoutput>
<div class="centercol-inner-wide legacy legacy-wide">
<cfif step EQ 1>
	<h1 id="PostABannerAdTitle">Post A<span id="PostABannerAdSpan"></span> Banner Ad</h1>
</cfif>
<cfif step EQ 4>
	<h1 id="PostABannerAdTitle">Post A<span id="PostABannerAdSpan"></span> Banner Ad - Confirm and Pay</h1>
</cfif>
<cfif step EQ 6>
	<h1 id="PostABannerAdTitle">Purchase Additional Impressions</h1>
</cfif>

<br />
 <div>&nbsp;</div>
</cfoutput>
<cfif edit>
	<p>Text to display on step one.</p>
	<lh:MS_SitePagePart id="bodyOne" class="body">	
	<p>Text to display on fourth page. (Thank you and confirmation)</p>
	<lh:MS_SitePagePart id="bodyFour" class="body">	
	
<cfelse>
 	<cfswitch expression="#Step#">
	 	<cfcase value="1">
			<lh:MS_SitePagePart id="bodyOne" class="body">
			<br>			
			<cfinclude template="../includes/AddBannerAdStepOne.cfm">
		</cfcase>
	 	<cfcase value="2">
			<p>&nbsp;</p>
			<cfinclude template="../includes/AddBannerAdStepTwo.cfm">
		</cfcase>
	 	<cfcase value="3">			
			<cfinclude template="../includes/AddBannerAdStepThree.cfm">
		</cfcase>
	 	<cfcase value="4">
			<!---  
			<lh:MS_SitePagePart id="bodyFour" class="body">
			--->
			<p>&nbsp;</p>
			<cfinclude template="../includes/AddBannerAdStepFour.cfm">
		</cfcase>
	 	<cfcase value="5">
			
			<p>&nbsp;</p>
			<cfinclude template="../includes/AddBannerAdStepFive.cfm">
		</cfcase>
		<cfcase value="6">
			
			<p>&nbsp;</p>
			<cfinclude template="../includes/AddBannerAdAdditionalImpressions.cfm">
		</cfcase>
		<cfcase value="7">
			
			<p>&nbsp;</p>
			<cfinclude template="../includes/AddBannerAdAdditionalImpressions2.cfm">
		</cfcase>
	 </cfswitch>	
</cfif>

</div>

<!-- END CENTER COL -->
<cfinclude template="footer.cfm">
