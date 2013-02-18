<!--- <cfif IsDefined('url.TestMe')>
	<cfset cookie.TestMe="1">
</cfif>
<cfif not findNoCase("monitor.cfm", cgi.CF_TEMPLATE_PATH)>
	<cfif not IsDefined('cookie.TestMe')>
		<cflocation url="SplashZoom.html" AddToken="no">
		<cfabort>
	</cfif>
</cfif> --->

<!--- Set application scope and turn on session management.
	Applications on the same server must have unique names. --->
<cfapplication name="DARSite" sessionManagement="Yes" scriptprotect="all">
<!--- Set error handling --->
<cferror type="exception" template="Lighthouse/Admin/error.cfm" mailto="douglas@modernsignal.com">
<cferror type="request" template="Lighthouse/Admin/error-request.cfm">

<cfinclude template="Lighthouse/SQLInjectionModule.cfm">

<!------------------------------------------------------------>
<!--- set standard Lighthouse variables ---------------------->
<!------------------------------------------------------------>

<!--- Table prefix for standard Lighthouse tables. --->
<cfset Request.dbprefix="LH">
<!--- ColdFusion datasource name --->
<cfset Request.dsn="ZoomTanzania_WRAPPED">
<!--- Type of database.  (mysql or mssql (SQL Server).  Default is mssql) --->
<cfset Request.dbtype="mssql">
<!--- Username and password for database. --->
<cfset Request.dbusername="">
<cfset Request.dbpassword="">
<!---
Auth Type used for accessing password protected RSS feeds.  Can be "basic" or "auto".
Use basic authentication if possible.  In IIS, basic and NT authentication must be turned off
so that ColdFusion can handle the authentication.
--->
<cfset Request.lh_authType = "basic">

<!--- Set whether friendly urls will be used.  If true, then the web server must be set up to
	use /404.cfm to handle all 404 errors. --->
<cfset Request.lh_useFriendlyUrls = true>

<!--- Override any standard tablenames, if necessary. --->
<!---<cfset MCFDBUsersTableName = "#Request.dbprefix#_AdminUsers">--->
<!--- Path from webserver root to application root. Include leading "/" (e.g. "/subdir"). Leave blank if application is at webserver root. --->
<cfset Request.AppVirtualPath = "">
<!--- Path from webserver root to directory where files will be uploaded.  Do NOT include leading "/" --->
<cfset Request.MCFUploadsDir = "uploads">
<cfset request.MCFTenderDocsDir = "TenderDocs">
<!--- Stylesheet to use for Lighthouse admin screens. Available stylesheets are in Lighthouse/Resources/css --->
<cfset Request.MCFStyle = "MSStandard">

<!--- Fully qualified paths to non-secure and secure applications. If secure does not exist, use same value as non-secure. --->

<cfset Request.httpURL = "http://www.ZoomTanzania.com">
<cfset Request.httpsURL = "http://www.ZoomTanzania.com">
<cfset Request.environment="Live">
<!--- Global title of application --->
<cfset Request.glb_title = "ZoomTanzania">
<!--- Include Libraries --->
<cfinclude template="Lighthouse/Functions/Init.cfm">
<cfinclude template="Lighthouse/Functions/LighthouseLib.cfm">

<cfset Request.MailToFormsTo = "accounts@ZoomTanzania.com">
<cfset Request.MailToFormsFrom = "inquiry@ZoomTanzania.com">
<cfset Request.AlertsFrom = "alerts@ZoomTanzania.com">
<cfset Request.BCCEmail = "">
<cfset Request.DevelCCEmail = "">
<cfset Request.AlertsBCCEmail = "douglas@modernsignal.com">

<cfset Request.ListingImagesDir = "c:/sites/ZoomTanzania/web/ListingImages">
<cfset Request.ListingUploadedDocsDir = "c:/sites/ZoomTanzania/web/ListingUploadedDocs">
<cfset Request.ListingEmailedDocsDir = "c:/sites/ZoomTanzania/web/ListingEmailedDocs">
<cfset Request.TenderDocsDir = "c:/sites/ZoomTanzania/web/TenderDocs">
<cfset Request.UploadedImages = "c:/sites/ZoomTanzania/web/Uploads">

<cfset Request.BannerAdsUploadedDocsDir = "c:/sites/ZoomTanzania/web/uploads/BannerAds">

<cfset Request.CategoryPageID="2">
<cfset Request.ListingDetailPageID="3">
<cfset Request.AddAListingPageID="5">
<cfset Request.ListingDetailPageID="3">
<cfset Request.MyAccountPageID="7">
<cfset Request.RenwalCartPageID="16">
<cfset Request.AddABannerAdPageID="21">
<cfset Request.SectionOverviewPageID="29">
<cfset Request.NonAcctRenewalPageID="30">
<cfset Request.SearchEventsPageID="33">
<cfset Request.JobSeekersGuidePageID="38">
<cfset Request.NationalParksPageID="76">
<cfset Request.NationalParkFeePageID="53">
<cfset Request.TenderPageID="184">
<cfset Request.AddAlertPageID="307">
<cfset Request.ManageAlertPageID="308">
<cfset Request.CreateAccountPageID="310">
<cfset Request.ImageViewerPageID="473">
<cfset Request.ImageBasedELPPageID="474">

<cfset Application.LoginTemplate="templates/login.cfm">

<cfset Request.PhoneOnlyUserID="1125">
<cfset Request.PriceRangeCategoryIDs="329,331,332,333,354,363,402,427,428">
<cfset Request.ParkCategoryIDs="332,333,362,363,428">

<cfset Request.ListingTitleTrunc="100">
<cfset request.RowsPerPage="50">
<cfset request.LinksPerPage="12">
<cfset request.MaxSearchResults="10">

<cfset Request.DefensioApi = {Key = "F2FE8BC3756A30F7D666BFEDE09046E9", OwnerUrl = "zoomtanzania.com"}>

<!--- Set parameters for devel, staging, etc, environments. --->
<cfswitch expression="#cgi.SERVER_NAME#">
	<!--- Douglas' Local Envi --->
	<cfcase value="zoom.dwb">
		<cfset Request.dsn="ZoomOnDev2">
		<cfset Request.dbusername="">
		<cfset Request.dbpassword="">
		<cfset Request.httpURL = "http://zoom.dwb">
		<cfset Request.httpsURL = "http://zoom.dwb">
		<cfset Request.environment="DB">
		<!--- Password protect entire site --->
		<cfinclude template="Lighthouse/Admin/checkQaLogin.cfm">
		<cfset request.MCFUploadsDir = "uploads">
		<cfset request.MCFTenderDocsDir = "TenderDocs">
		<!--- Set error handling for local environment -- show error but don't send email --->
		<cfset Request.lh_showErrorInfo = true>
		<cfset Request.lh_sendErrorEmail = false>
		<cfset Request.lh_useFriendlyUrls = true>
		<cfset Request.MailToFormsTo = "douglas@modernsignal.com">
		<cfset Request.MailToFormsFrom = "douglas@modernsignal.com">
		<cfset Request.AlertsFrom = "douglas@modernsignal.com">
		<cfset Request.BCCEmail = "douglas@modernsignal.com">
		<cfset Request.DevelCCEmail = "douglas@modernsignal.com">
		<cfset Request.ListingImagesDir = "c:/sites/zoom/web/ListingImages">
		<cfset Request.ListingUploadedDocsDir = "c:/sites/zoom/web/ListingUploadedDocs">
		<cfset Request.BannerAdsUploadedDocsDir = "c:/sites/zoom/web/uploads/BannerAds">
		<cfset Request.ListingEmailedDocsDir = "c:/sites/zoom/web/ListingEmailedDocs">
		<cfset Request.TenderDocsDir = "c:/sites/zoom/web/TenderDocs">
		<cfset Request.UploadedImages = "c:/sites/zoom/web/Uploads">
		<cfset Request.SectionOverviewPageID="30">
		<cfset Request.NonAcctRenewalPageID="31">
		<cfset Request.NationalParksPageID="51">
		<cfset Request.NationalParkFeePageID="52">
		<cfset Request.TenderPageID="54">
		<cfset Request.PhoneOnlyUserID="554">
		<cfset request.RowsPerPage="6">
		<cfset request.LinksPerPage="4">
		<cfset Request.DefensioApi = {Key = "09fd4c33ed0a988b0294be1dc201dbca", OwnerUrl = "modernsignal.net"}>
		<cfset Request.AddAlertPageID="55">
		<cfset Request.ManageAlertPageID="56">
		<cfset Request.CreateAccountPageID="58">
		<cfset Request.ImageViewerPageID="64">
		<cfset Request.ImageBasedELPPageID="65">
	</cfcase>
	<!--- Laptop Local Envi --->
	<cfcase value="localhost">
		<cfset Request.dsn="DAR">
		<cfset Request.dbusername="">
		<cfset Request.dbpassword="">
		<cfset Request.httpURL = "http://localhost">
		<cfset Request.httpsURL = "http://localhost">
		<cfset Request.environment="LT">
		<cfset Request.AppVirtualPath = "">
		<cfset request.MCFUploadsDir = "uploads">
		<cfset request.MCFTenderDocsDir = "TenderDocs">
		<!--- Set error handling for local environment -- show error but don't send email --->
		<cfset Request.lh_showErrorInfo = true>
		<cfset Request.lh_sendErrorEmail = false>
		<cfset Request.lh_useFriendlyUrls = true>
		<cfset Request.MailToFormsTo = "douglas@modernsignal.com">
		<cfset Request.AlertsFrom = "dar@modernsignal.com">
		<cfset Request.BCCEmail = "">
		<cfset Request.DevelCCEmail = "douglas@modernsignal.com">
		<cfset Request.ListingImagesDir = "c:/inetpub/wwwroot/ListingImages">
		<cfset Request.ListingUploadedDocsDir = "c:/inetpub/wwwroot/ListingUploadedDocs">
	</cfcase>
	<!--- Development server --->
	<cfcase value="zoomtanzania.dev2.modernsignal.net">
		<cfset Request.dsn="ZoomTanzania">
		<cfset Request.httpURL = "http://zoomtanzania.dev2.modernsignal.net">
		<cfset Request.httpsURL = "http://zoomtanzania.dev2.modernsignal.net">
		<cfset Request.environment="Devel">
		<!--- Password protect entire site --->
		<cfif CGI.SCRIPT_NAME does not contain "inttasks"><!--- exception for Synching calls --->
			<cfinclude template="Lighthouse/Admin/checkQaLogin.cfm">
		</cfif>
		<!--- Set error handling for local environment -- show error but don't send email --->
		<cfset Request.lh_showErrorInfo = true>
		<cfset Request.lh_sendErrorEmail = true>
		<cfset Request.MailToFormsTo = "eleanor@modernsignal.com">
		<cfset Request.MailToFormsFrom = "douglas@modernsignal.com">
		<cfset Request.AlertsFrom = "dar@modernsignal.com">
		<cfset Request.BCCEmail = "douglas@modernsignal.com">
		<cfset Request.DevelCCEmail = "douglas@modernsignal.com,eleanor@modernsignal.com">
		<cfset Request.AlertsBCCEmail = "douglas@modernsignal.com">
		<cfset Request.SectionOverviewPageID="30">
		<cfset Request.NonAcctRenewalPageID="31">
		<cfset Request.NationalParksPageID="51">
		<cfset Request.NationalParkFeePageID="52">
		<cfset Request.TenderPageID="54">
		<cfset Request.PhoneOnlyUserID="554">
		<cfset request.RowsPerPage="6">
		<cfset request.LinksPerPage="4">
		<cfset Request.DefensioApi = {Key = "09fd4c33ed0a988b0294be1dc201dbca", OwnerUrl = "modernsignal.net"}>
		<cfset Request.AddAlertPageID="55">
		<cfset Request.ManageAlertPageID="56">
		<cfset Request.CreateAccountPageID="58">
		<cfset Request.ImageViewerPageID="64">
		<cfset Request.ImageBasedELPPageID="65">
	</cfcase>
	<cfcase value="zoomtanzania.dave.modernsignal.net">
		<cfset Request.dsn="ZoomTanzania">
		<cfset Request.httpURL = "http://#cgi.SERVER_NAME#">
		<cfset Request.httpsURL = "http://#cgi.SERVER_NAME#">
		<cfset Request.environment="Devel">
		<cfset Request.lh_showErrorInfo = true>
		<cfset Request.lh_sendErrorEmail = false>
		<cfset Request.MailToFormsTo = "eleanor@modernsignal.com">
		<cfset Request.MailToFormsFrom = "dar@modernsignal.com">
		<cfset Request.AlertsFrom = "dar@modernsignal.com">
		<cfset Request.BCCEmail = "">
		<cfset Request.DevelCCEmail = "douglas@modernsignal.com,eleanor@modernsignal.com">
		<cfset Request.SectionOverviewPageID="30">
		<cfset Request.NonAcctRenewalPageID="31">
		<cfset Request.NationalParksPageID="51">
		<cfset Request.NationalParkFeePageID="52">
		<cfset Request.TenderPageID="54">
		<cfset Request.PhoneOnlyUserID="554">
		<cfset request.RowsPerPage="6">
		<cfset request.LinksPerPage="4">
		<cfset Request.ListingImagesDir = "e:/sites/ZoomTanzania/web/ListingImages">
		<cfset Request.ListingUploadedDocsDir = "e:/sites/ZoomTanzania/web/ListingUploadedDocs">
		<cfset Request.ListingEmailedDocsDir = "e:/sites/ZoomTanzania/web/ListingEmailedDocs">
		<cfset Request.TenderDocsDir = "e:/sites/ZoomTanzania/web/TenderDocs">
		<cfset Request.UploadedImages = "e:/sites/ZoomTanzania/web/Uploads">
		<cfset Request.DefensioApi = {Key = "09fd4c33ed0a988b0294be1dc201dbca", OwnerUrl = "modernsignal.net"}>
		<cfset Request.AddAlertPageID="55">
		<cfset Request.ManageAlertPageID="56">
		<cfset Request.CreateAccountPageID="58">
		<cfset Request.ImageViewerPageID="64">
		<cfset Request.ImageBasedELPPageID="65">
	</cfcase>
</cfswitch>

<!--- Initialize the application.  Add lh_Initialize=1 to url to re-initialize at any time. --->
<cfif Not ApplicationIsInitialized()>
<cfset Application.GoogleAnalyticsAcctNum = "">
	<cfset InitializeApplication()>
<!--- Override application defaults, if necessary. See Functions/Init.cfm for the default values. --->
	<!--- <cfsavecontent variable="Application.ErrorMessage"></cfsavecontent> ---> 
</cfif>

<!--- admin-specific variables and settings --->
<!--- Admin pages are assumed to be all admin pages within /admin directory. --->
<cfif FindNoCase("/admin/",cgi.script_name)>
	<!--- Check for secure connection --->
	<cfinclude template="Lighthouse/Admin/checkssl.cfm">
	<!--- Make sure user is logged in --->
	<cfinclude template="Lighthouse/Admin/checklogin.cfm">
</cfif>

<!------------------------------------------>
<!--- Set application-specific variables --->
<!------------------------------------------>

<cfif Request.lh_useFriendlyUrls>
	<cfset AmpOrQuestion="?">
<cfelse>
	<cfset AmpOrQuestion="&">
</cfif>



<!--- Force user to be on 'www' url --->
<cfif Request.environment is "live">
	<!--- set up the getRequest method for easy access --->
	<cfset PageRequestData = getPageContext().getRequest() />
 	<cfset ServerName=PageRequestData.getServerName()>
	<cfif not ServerName contains "www" and reFind("\d+.\d+.\d+.\d+",ServerName) is 0>
		<cfset ServerName="www." & ServerName>
		<cfif PageRequestData.getRequestURI() is "/Lighthouse/404.cfm">
			<cfset PageRequested=REReplace(PageRequestData.getQueryString(),"404;https?://[^/]+","")>
			<cfset PageRequestQueryString="">
		<cfelse>
			<cfset PageRequested=PageRequestData.getRequestURI()>
			<cfif Len(PageRequestData.getQueryString())>
				<cfset PageRequestQueryString="?" & PageRequestData.getQueryString()>
			<cfelse>
				<cfset PageRequestQueryString="">
			</cfif>
		</cfif>
		<cfif PageRequested is "/index.cfm">
			<cfset PageRequested="">
		</cfif>
		<cfif PageRequestData.isSecure()>
			<cflocation url="https://#ServerName##PageRequested##PageRequestQueryString#" addToken="false">
		<cfelse>
			<cflocation url="http://#ServerName##PageRequested##PageRequestQueryString#" addToken="false">
		</cfif>
	</cfif>

	<cfif cgi.Server_Name contains "everythingdar.com">
		<cfif PageRequestData.getRequestURI() is "/Lighthouse/404.cfm">
			<cfset PageRequested=REReplace(PageRequestData.getQueryString(),"404;https?://[^/]+","")>
			<cfset PageRequestQueryString="">
		<cfelse>
			<cfset PageRequested=PageRequestData.getRequestURI()>
			<cfif Len(PageRequestData.getQueryString())>
				<cfset PageRequestQueryString="?" & PageRequestData.getQueryString()>
			<cfelse>
				<cfset PageRequestQueryString="">
			</cfif>
		</cfif>
		<cfset ScriptName=ReplaceNoCase(cgi.script_name,"/Lighthouse/404.cfm","","ALL")>
		<cfif PageRequested is "/index.cfm">
			<cfset PageRequested="">
		</cfif>
		<cfheader statuscode="301" statustext="Moved Permanently">
		<cfheader name="Location" value="#Request.httpsURL##PageRequested##PageRequestQueryString#">
		<cfabort>
	</cfif>

</cfif>

<cfset application.CurrentDateInTZ = createODBCDate(dateAdd("h",7,Now()))>
<cfset application.JobClickPerDayLimit = "3">

