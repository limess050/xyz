<cfimport prefix="lh" taglib="../Lighthouse/Tags">


<cfparam name="PositionID" default="1">
<cfset allFields="PositionID,CategoryIDs,ParentSectionIDs,SectionIDs">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="PositionID">


<cfquery name="getBannerPricing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	select * from BannerAdPricing
</cfquery>

<cfset impressions = "1000,2000,5000,10000,15000,20000,25000,30000,35000,40000,45000,50000,60000,70000,80000,90000,100000">

<cfquery name="getBannerAd" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	update BannerAds set PositionID = <cfqueryparam value="#PositionID#" cfsqltype="CF_SQL_INTEGER">
	where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
		
	Select B.*,BPS.ParentSectionID,IsNull(o.PaymentAmount,B.Price) as PaymentAmount
	From BannerAds B Left Join BannerAdParentSections BPS on B.BannerAdID=BPS.BannerAdID
	Left join orders o on o.orderID = b.orderID
	Where B.BannerAdID=<cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>


<cfset PositionID = getBannerAd.PositionID>
<cfset paymentAmount = getBannerAd.paymentamount>
<cfset BannerAdImpressions = getBannerAd.Impressions>
<cfset BannerAdStartDate = getBannerAd.StartDate>
<cfset BannerAdEndDate = getBannerAd.EndDate>
<cfset LinkID = getBannerAd.LinkID>
<cfif Len(BannerAdStartDate)>
	<cfset BannerAdStartDate = DateFormat(BannerAdStartDate,"dd/mm/yyyy")>
</cfif>
<cfif Len(BannerAdEndDate)>
	<cfset BannerAdEndDate = DateFormat(BannerAdEndDate,"dd/mm/yyyy")>
</cfif>
<cfset BannerAdFileName = getBannerAd.BannerAdImage>
<cfset BannerAdLinkFile = getBannerAd.BannerAdLinkFile>
<cfset BannerAdUrl = getBannerAd.BannerAdUrl>

<script language="javascript">
		
	function validateForm(f){
			
	if (!checkText(f.StartDisplayingOn,"Start Displaying On")) {
				return false;
	}
	if (!checkDate(f.StartDisplayingOn,"Start Displaying On")) {
				return false;
	}
	
	if (!checkText(f.Price,"Price")) {
				return false;
	}
	
	if (!checkNumber(f.Price,"Price")) {
				return false;
	}
	
	if (!checkText(f.StopDisplayingOn,"Stop Displaying On")) {
				return false;
	}
	
	if (!checkDate(f.StopDisplayingOn,"Stop Displaying On")) {
				return false;
	}
	<cfif not Len(BannerAdFileName)>
	if (!checkText(f.BannerAdFile,"Banner Ad File")) {
				return false;
	}
	
	
	</cfif>
	<cfif not Len(BannerAdLinkFile)>
	if(f.BannerAdUrl.value == ''){
	if (!checkText(f.BannerAdLinkFile,"Banner Ad File")) {
				return false;
	}
	}
	
	</cfif>
	
	if(f.BannerAdUrl.value != ''){
	var v = new RegExp();
    v.compile("^[A-Za-z]+://[A-Za-z0-9-_]+\\.[A-Za-z0-9-_%&\?\/.=]+$");
    if (!v.test(f["BannerAdUrl"].value)) {
        alert("You must supply a valid URL.");
        return false;
    } 
	}
	
	if(f.BannerAdUrl.value != '' && f.BannerAdLinkFile.value != ''){
		alert('Please select either a banner ad url or a file but not both.')
		return false;
	}	
	
	
	
	return true;
	}
</script>

<cfquery name="deletePlacements" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	delete from BannerAdParentSections where BannerAdID = <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfquery name="addSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	insert into BannerAdParentSections(BannerAdID,ParentSectionID)
	select <cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">, ParentSectionID from PageSectionsView where ParentSectionID IN (<cfqueryparam value="#ParentSectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)
</cfquery>
<cfquery name="getSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum
	FROM  PageSectionsView PS 
	WHERE PS.ParentSectionID IN (<cfqueryparam value="#ParentSectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)
</cfquery>
	
<cfoutput>
	
<form name="f1" id="f1" action="page.cfm?PageID=#Request.AddABannerAdPageID#" method="post" onsubmit="return validateForm(this)" ENCTYPE="multipart/form-data" >
	<input type="hidden" name="BannerAdID" value="#BannerAdID#">
	<input type="hidden" name="validImpField" value="" id="validImpField">
	<table  border="1" cellspacing="0" style="width:100%;">
		<tr style="background: ##96AFCF;">
			<td style="padding:3px;text-align:center">Location</td>
			<td style="padding:3px;text-align:center">Start Displaying On</td>
			<td style="padding:3px;text-align:center">Stop Displaying On</td>
			
		</tr>
		<input type="hidden" name="ParentSectionIDs" value="#ParentSectionIDs#">
		<cfloop query="getSections">
			<tr>
			 	<td style="text-align:center;padding:5px;">#PSTitle#</td>
			 	<cfif currentRow EQ 1>				
				 	<td rowSpan="#getSections.recordcount#" style="text-align:center;padding:5px;"><input name="StartDisplayingOn" id="StartDisplayingOn" value="#BannerAdStartDate#" maxLength="20"></td>
					<td rowSpan="#getSections.recordcount#" style="text-align:center;padding:5px;"><input name="StopDisplayingOn" id="StopDisplayingOn" value="#BannerAdEndDate#" maxLength="20"></td>
				</cfif>	
				
			</tr>
		</cfloop>
		<script type="text/javascript">
				$(function() {
					$("##StartDisplayingOn").datepicker({showOn: 'button', buttonImage: 'images/calendar.gif', buttonImageOnly: true, dateFormat: 'dd/mm/yy', changeMonth: true, changeYear: true
					});
					$("##StopDisplayingOn").datepicker({showOn: 'button', buttonImage: 'images/calendar.gif', buttonImageOnly: true, dateFormat: 'dd/mm/yy', changeMonth: true, changeYear: true
					});
					});
		</script>
	</table>	
		
	
	<br><br>
	
	<table border="0" cellspacing="0" cellpadding="0" >
		<tr>
			<td>&nbsp;</td>
			<td><cfif PositionID EQ 1>
					Position #PositionID# Ad 675 X 90:
				<cfelseif PositionID EQ 2>	
					Position #PositionID# Ad 200 X 200:
				<cfelse>
					Position #PositionID# Ad 200 X 750:
				</cfif>	
			</td>
		</tr>
		<tr>
			<td valign="top">
				Upload Ad File:
			</td>
			<td>
				<input type="file" name="BannerAdFile" ID="BannerAdFile" size="42" maxlength="200" value=""> <cfif Len(BannerAdFileName)>Current Image: <a href="#request.httpUrl#/uploads/bannerAds/#BannerAdFileName#" target="_blank">#BannerAdFileName#</a></cfif><br>
				Ad files must meet specific dimensions and file size requirements.<br>
				Please click here for banner ad specifications before uploading.
			</td>
		</tr>
		<tr>
			<td valign="top">
				Banner Ad Url:
			</td>
			<td>
				<input type="text" name="BannerAdUrl" value="#BannerAdUrl#" ID="BannerAdUrl" size="42" maxlength="200"><br>
				This is the URL that you would like users to be redirected to when they click your
				ad.
			</td>
		</tr>
		<tr>
			<td valign="top">
				Banner Ad File:
			</td>
			<td>
				<input type="file" name="BannerAdLinkFile" ID="BannerAdLinkFile" size="42" maxlength="200" value=""> <cfif Len(BannerAdLinkFile)>Current File: <a href="#request.httpUrl#/uploads/bannerAds/#BannerAdLinkFile#" target="_blank">#BannerAdLinkFile#</a></cfif><br>
				
			</td>
		</tr>
		<tr>
			<td valign="top">
				Price:
			</td>
			<td>
				<input type="text" name="Price" value="#NumberFormat(PaymentAmount,'_.__')#" ID="Price" size="42" maxlength="200" value=""><br>
				
			</td>
		</tr>
		
		
		<tr>
			
			<td><br>
				<div id="NextButtonDiv">
					<input type="button" onclick="history.go(-1)" value="<< Previous" name="Previous" class="btn"/>
					<input type="submit" name="Next" value="Next >>" class="btn" id="btn"></div>
				
				<input type="hidden" name="Step" value="4">
			</td>
		</tr>
	</table>
	
	
</form>
</cfoutput>
