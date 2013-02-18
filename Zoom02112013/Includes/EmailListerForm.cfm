<!--- This template expects a ListingID. --->
<cfparam name="UserEmail" default="">
<cfif IsDefined('session.UserID' ) and Len(session.UserID)>
	<cfquery name="getUser" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select ContactEmail
		From LH_Users
		Where UserID = <cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfset UserEmail=getUser.ContactEmail>
</cfif>
<script type="text/javascript" src="js/jquery-1.3.min.js"></script>
<script type="text/javascript" src="http://jquery-multifile-plugin.googlecode.com/svn/trunk/jquery.MultiFile.js"></script>
<script type="text/javascript" src="Lighthouse/Resources/js/lighthouse_all.js"></script>
<script type="text/javascript">
    $(document).ready(function(){
        $('#ELForm').submit(function(){
            var files = $('#ELForm input:file');
            var count=1;
            files.attr('name',function(){return this.name+''+(count++);});
            $('#fileCount').val(count-2);
        });
    });

	function checkForm(f) {
		if (!checkText(f.Email,"Email")) return false;
		if (!checkText(f.ConfirmEmail,"Email Confirm")) return false;
		if (!checkText(f.CaptchaEntry,"Match Text")) return false;
		if (!captchaValidate()) return false;
		if (!checkText(f.SubjectLine,"Subject Line")) return false;
		if (!checkText(f.EmailBody,"Message Body")) return false;
				
		return true;
	}	
</script>

<cfoutput>
	<cfif not IsDefined('ListingID') or not IsNumeric(ListingID) or not Len(ListingID)>
		No Listing found.
	<cfelse>
		<form name="ELForm" id="ELForm" action="EmailLister.cfm" method="post" enctype="multipart/form-data" onsubmit="return checkForm(this)">
			<cfset captcha = CreateObject("component","cfc.Captcha").init(autoload=false)>
			<cfset cffp = CreateObject("component","cfformprotect.cffpVerify").init()>
			#captcha.renderScripts()#
			<cfinclude template="../cfformprotect/cffp.cfm" />
			<input type="hidden" name="ListingID" ID="ListingID" value="#ListingID#">
			<input type="hidden" name="FileCount" id="fileCount" value="0">
			<table cellpadding="5" cellspacing="0">
				<tr>
					<td style="font:12px Arial,Helvetica,sans-serif;">
						*&nbsp;Your&nbsp;Email&nbsp;Address
					</td>
					<td>
						<input type="text" name="Email" ID="Email" size="42" maxlength="200" value="#UserEmail#" style="border:2px solid ##000">
					</td>
				</tr>
				<tr>
					<td style="font:12px Arial,Helvetica,sans-serif;">
						*&nbsp;Confirm&nbsp;Email&nbsp;Address
					</td>
					<td>
						<input type="text" name="ConfirmEmail" ID="ConfirmEmail" size="42" maxlength="200" value="#UserEmail#" style="border:2px solid ##000">
					</td>
				</tr>
				<tr>
					<td style="font:12px Arial,Helvetica,sans-serif;" valign="top">
						File
					</td>
					<td style="font:12px Arial,Helvetica,sans-serif;">
						<input type="file" name="EmailFile" ID="EmailFile" maxlength="5" value="" class="multi" accept="txt|pdf|doc|docx|rtf|xls|xlsx|ppt|pptx|gif|jpg|jpeg|tiff" style="border:2px solid ##000">
						
						To attach more than 1 file, click the "Browse" button again. 2MB maximum file size.
					</td>
					
				</tr>
				<tr class="captcha-wrapper">
					<td valign="top" style="font:12px Arial,Helvetica,sans-serif;">
						*&nbsp;Match Text<br>
						To protect against spam, please prove you are a real person by 
						typing what you see to the right.  If you can't read it clearly, 
						please click #captcha.renderRefreshButton("refresh")#.
					</td>
					<td>
						#captcha.renderImage()#
						<p>#captcha.renderEntry()#</p>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<br><strong>Do not use ALL CAPS in the subject line or in your message.  Spam filters consider ALL CAPS to be "shouting", and using all caps can result in your message going into the recipients Spam Folder.</strong>
						<br><br>
					</td>
				</tr>
				<tr>
					<td valign="top" style="font:12px Arial,Helvetica,sans-serif;">
						*&nbsp;Subject&nbsp;Line
					</td>
					<td>
						<input type="text" name="SubjectLine" size="42" maxlength="150" style="border:2px solid ##000">
					</td>
				</tr>
				<tr>
					<td valign="top" style="font:12px Arial,Helvetica,sans-serif;">
						*&nbsp;Your&nbsp;Message
					</td>
					<td>
						<textarea cols="30" rows="5" name="EmailBody" id="EmailBody" style="border:2px solid ##000"></textarea>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<input type="submit" name="submit" id="submit" value="Send Email">
					</td>
				</tr>
			</table>
		</form>
	</cfif>
</cfoutput>
