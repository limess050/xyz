<cfimport prefix="lh" taglib="../Lighthouse/Tags">



<cfset allFields="BannerAdPlacement,BannerAdID,LinkID">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="BannerAdPlacement,BannerAdID">


<cfif Len(LinkID)>
	<cfquery name="getBannerAd" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select B.*,BPS.ParentSectionID,BS.SectionID,BC.CategoryID
		From BannerAds B Left Join BannerAdParentSections BPS on B.BannerAdID=BPS.BannerAdID
		Left Join BannerAdCategories BC on B.BannerAdID=BC.BannerAdID
		Left Outer Join BannerAdSections BS on B.BannerAdID=BS.BannerAdID
		Where B.LinkID=<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">;
	</cfquery>
	<cfif getBannerAd.RecordCount>
		<cfif not getBannerAd.InProgress>
			<div id="internalalert">Banner ad already processed.</div><br clear="all"></div>
			<cfinclude template="../templates/footer.cfm"></div></div></body></html>
			<cfabort>
			<cfabort>
		</cfif>
		<cfset BannerAdID = getBannerAd.BannerAdID>
		<cfset BannerAdPlacement = getBannerAd.PlacementID>
		
		
	<cfelse><!--- No record found so stop passing LinkID --->
		<cfset LinkID="">
		<div id="internalalert">Banner ad not found</div><br clear="all"></div>
		<cfinclude template="../templates/footer.cfm"></div></div></body></html>
		<cfabort>
	</cfif>
</cfif>

<script language="javascript">
	history.forward(1);
	function validateForm(f){
	 if (!checkChecked(f.BannerAdPlacement,"Banner Ad Placement")) {
				return false;
	}
	return true;
	}
</script>
<img src="images/inner/bannerAdPosition.jpg" width="700">

<cfquery name="getPlacements" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select * from BannerAdPlacement
	Where PlacementID Not IN (2,4,5)
	order by PlacementID
</cfquery>



<cfoutput>
<form name="f1" action="page.cfm?PageID=#Request.AddABannerAdPageID#" method="post" ONSUBMIT="return validateForm(this)">
	<table border="0" cellspacing="0" cellpadding="0" class="datatable">
		<tr>
			<td colspan="2">
				<strong>To help place your ad, please tell us where on the site you are interested in advertising. Please
				check only one, you can repeat the process if necessary.</strong>
			</td>
		</tr>
		<cfloop query ="getPlacements">
		<tr>
			<td>
				<input type="radio" name="BannerAdPlacement" value="#PlacementID#" <cfif PlacementID EQ BannerAdPlacement>checked</cfif>>
			</td>
			<td>
				<b>#Placement# Placement</b> - #descr#
			</td>
		</tr>
		</cfloop>
		
		<tr>
			<td>&nbsp;</td>
			<td>
				<div id="NextButtonDiv"><input type="submit" name="Next" value="Next >>" class="btn"></div>
				<input type="hidden" name="BannerAdID" value="#BannerAdID#">
				<input type="hidden" name="Step" value="2">
			</td>
		</tr>
	</table>
	
	
</form>
</cfoutput>

