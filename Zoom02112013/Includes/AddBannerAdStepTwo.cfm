<cfimport prefix="lh" taglib="../Lighthouse/Tags">



<cfset allFields="LinkID,BannerAdID,PositionID,ParentSectionIDs,SectionIDs,CategoryIDs">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="BannerAdID">

<cfif Len(LinkID)>
	<cfquery name="getBannerAd" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select B.*
		From BannerAds B 
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
		
		
	<cfelse><!--- No record found so stop passing LinkID --->
		<cfset LinkID="">
		<div id="internalalert">Banner ad not found</div><br clear="all"></div>
		<cfinclude template="../templates/footer.cfm"></div></div></body></html>
		<cfabort>
	</cfif>
</cfif>

<cfif Len(BannerAdID)>
	<cfquery name="getBannerAd" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select B.*,BPS.ParentSectionID,BS.SectionID,BC.CategoryID
		From BannerAds B Left Join BannerAdParentSections BPS on B.BannerAdID=BPS.BannerAdID
		Left Join BannerAdCategories BC on B.BannerAdID=BC.BannerAdID
		Left Outer Join BannerAdSections BS on B.BannerAdID=BS.BannerAdID
		Where B.BannerAdID=<cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif getBannerAd.RecordCount>
		<cfquery dbType="query" name="getParentSectionIDs">
			select distinct(ParentSectionID)
			from getBannerAd
		</cfquery>
		<cfquery dbType="query" name="getSectionIDs">
			select distinct(SectionID)
			from getBannerAd
		</cfquery>

		<cfset PositionID = getBannerAd.PositionID>
		<cfset LinkID = getBannerAd.LinkID>
		<cfset ParentSectionIDs=ValueList(getParentSectionIDs.ParentSectionID)>
		<cfset SectionIDs=ValueList(getSectionIDs.SectionID)>
		<cfset CategoryIDs=ValueList(getBannerAd.CategoryID)>
		
	<cfelse>
		<div id="internalalert">Banner ad not found</div><br clear="all"></div>
		<cfinclude template="../templates/footer.cfm"></div></div></body></html>
		<cfabort>
	</cfif>
	
<cfelse>
	<cfset LinkID = createUUID()>
	<cfquery name="insBannerAd" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		insert into BannerAds(LinkID,InProgress)
		values
		(<cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR">, 1)
		select @@identity as newBannerID
	</cfquery>
	<cfset BannerAdID = insBannerAd.newBannerID>		
</cfif>




<script language="javascript">
	function validateForm(f){
	 if (!checkChecked(f.PositionID,"Banner Ad Position")) {
				return false;
	}
	if (!checkChecked(f.ParentSectionIDs,"Banner Ad Sections")) {
				return false;
	}
	return true;
	}
</script>


<cfquery name="getSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum
	FROM PageSectionsView PS
	Where ParentSectionID < 1000
	Order By PS.OrderNum
</cfquery>



<cfoutput>
<form name="f1" action="page.cfm?PageID=#Request.AddABannerAdPageID#" method="post" ONSUBMIT="return validateForm(this)">
	<input type="hidden" name="BannerAdID" value="#BannerAdID#">
	<table>
	<tr>
	<td colspan="2">First, what ad position are you interested in? Use the illustration below as reference:<br><br>
	<b>Select One:</b>
	</td>
	</tr>
	<tr>
	<td>
	<input type="radio" name="PositionID" value="1" <cfif PositionID EQ 1>checked</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;Position 1<br><br>
	<input type="radio" name="PositionID" value="2" <cfif PositionID EQ 2>checked<cfelse>disabled</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;Position 2<br><br>
	<input type="radio" name="PositionID" value="3" <cfif PositionID EQ 3>checked</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;Position 3<br><br>
	</td>
	<td><img src="images/inner/BannerAdPositionCat.jpg" width="200"></td>
	</tr>
	</table>
	<table border="0" cellspacing="0" cellpadding="0" name="bannerAdTable" id="bannerAdTable" class="datatable">
		
		<tr>
			<td>
				Now tell us what Sections you are interested in.
			</td>
		</tr>		
		<tr>
			<td>
				<cfloop query="getSections">
					<input type="checkbox" name="ParentSectionIDs" value="#ParentSectionID#" <cfif ListFind(ParentSectionIDs,ParentSectionID)>checked</cfif>> #PSTitle#<br>
				</cfloop>
			</td>
		</tr>		
		<tr>
			
			<td>
				<div id="NextButtonDiv">
					<input type="button" class="btn" onclick="location.href='/postaBannerAd?Step=1&LinkID=#LinkID#'" value="<< Previous" name="Previous"/>
					<input type="submit" name="Next" value="Next >>" class="btn"></div>
				
				<input type="hidden" name="Step" value="3">
			</td>
		</tr>
	</table>
	
	
</form>
</cfoutput>

