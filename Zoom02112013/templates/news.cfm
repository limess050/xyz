
<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<script type="text/javascript" src="Lighthouse/Resources/js/lighthouse_all.js"></script>

<cfset ContentStyle="innercontent-nolines">

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

<cfparam name="SearchKeyword" default="">
<cfparam name="SearchStartDate" default="">
<cfparam name="SearchEndDate" default="">
<cfparam name="SearchNewsCategoryID" default="">
<cfparam name="NCID" default="">
<cfparam name="Searching" default="0">

<cfif SearchKeyword is "Find News by Keyword">
	<cfset SearchKeyword="">
</cfif>

<cfsavecontent variable="NewsHeaderAdditions">
	<cfoutput>
		<script type="text/javascript" src="#Request.HTTPURL#/scripts/bookMark.js"></script>
	</cfoutput>
	<style>			
		#innercontent-midcol {float: left; margin-left: 20px; width: 529px; padding-bottom: 20px; font-size: 13px; }
		#innercontent-rightcol {float: left; margin-left: 10px; width: 180px; padding-bottom: 20px;}
	</style>
</cfsavecontent>
<cfhtmlhead text="#NewsHeaderAdditions#">


<script>
	$(function() {
		$("#SearchStartDate").datepicker({showOn: 'button', buttonImage: 'images/sitewide/date_16.png', buttonImageOnly: true, dateFormat: 'dd/mm/yy', changeMonth: true, changeYear: true
});
		$("#SearchEndDate").datepicker({showOn: 'button', buttonImage: 'images/sitewide/date_16.png', buttonImageOnly: true, dateFormat: 'dd/mm/yy', changeMonth: true, changeYear: true
});
	});
	
	function validateForm(formObj) {		
		if (!checkDateDDMMYYYY(formObj.elements["SearchStartDate"],"Search Start Date")) return false;		
		if (!checkDateDDMMYYYY(formObj.elements["SearchEndDate"],"Search End Date")) return false;	
		return true;
	}
</script>



<cfset InDate=SearchStartDate>
<cfinclude template="../includes/DateFormatter.cfm">
<cfset LocalSearchStartDate=OutDate>

<cfset InDate=SearchEndDate>
<cfinclude template="../includes/DateFormatter.cfm">
<cfset LocalSearchEndDate=OutDate>

<!--- <cfoutput>#Request.Page.GetCookieCrumb()#</cfoutput><br>
<cfoutput>#Request.Page.GetSectionName()#</cfoutput> --->

<!--- <lh:MS_SitePagePart id="title" class="title">
<lh:MS_SitePagePart id="body" class="body">
 ---> 

<!--- <style>
	#content {border-top: solid 2px #c0c0c0; clear: both; background: url(images/inner/bg.content.gif) repeat-y left #FFFFFF; padding-top: 5px;}
</style> --->

<cfquery name="getSearchNewsCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select NewsCategoryID, Title
	From NewsCategories 
	Where Active=1
	Order By OrderNum
</cfquery>

<cfquery name="getNewsCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select NewsCategoryID, Title
	From NewsCategories 
	Where Active=1
	<cfif Len(NCID)>
		and NewsCategoryID = <cfqueryparam value="#NCID#" cfsqltype="CF_SQL_INTEGER">
	<cfelseif Len(SearchNewsCategoryID)>
		and NewsCategoryID in (<cfqueryparam value="#SearchNewsCategoryID#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
	</cfif>
	Order By OrderNum
</cfquery>

<cfset TotalNewsItems="0">
<cfset NewsCategoriesWithItems="">

<cfloop query="getNewsCategories">
	<cfquery name="getCategory#NewsCategoryID#News" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select 
		<cfif not Searching>
			<cfif Len(NCID)>
				Top 12
			<cfelse>
				Top 5
			</cfif>
		</cfif>		
		N.NewsID, N.Headline, N.WebsiteURL, N.Source, N.DatePosted,
		<cfif Len(SearchKeyword)>
			KEY_TBL.RANK as Rank
		<cfelse>
			0 as Rank
		</cfif>		
		From News N Inner Join NewsNewsCategories NNC on N.NewsID=NNC.NewsID
		<cfif Len(SearchKeyword)>INNER JOIN FREETEXTTABLE(News, *, <cfqueryparam value="#SearchKeyword#" cfsqltype="CF_SQL_VARCHAR">) AS KEY_TBL ON KEY_TBL.[KEY] = N.NewsID</cfif>
		Where N.Active=1
		<cfif not Searching>
			<cfif Len(NCID)>
				and N.DatePosted >= <cfqueryparam value="#DateAdd('d',-12,Now())#" cfsqltype="CF_SQL_DATE">	
			<cfelse>
				and N.DatePosted >= <cfqueryparam value="#DateAdd('d',-6,Now())#" cfsqltype="CF_SQL_DATE">	
			</cfif>
		</cfif>
		and NNC.NewsCategoryID=<cfqueryparam value="#NewsCategoryID#" cfsqltype="CF_SQL_INTEGER">			
		<cfif Len(SearchStartDate) and not Len(SearchEndDate)>
			and N.DatePosted >= <cfqueryparam value="#LocalSearchStartDate#" cfsqltype="CF_SQL_DATE">
		<cfelseif Len(SearchEndDate) and not Len(SearchStartDate)>
			and N.DatePosted <= <cfqueryparam value="#LocalSearchEndDate#" cfsqltype="CF_SQL_DATE">
		<cfelseif Len(SearchStartDate) and Len(SearchEndDate)>
			<cfif SearchStartDate is SearchEndDate>
				and N.DatePosted = <cfqueryparam value="#LocalSearchStartDate#" cfsqltype="CF_SQL_DATE">
			<cfelse>
				and N.DatePosted >= <cfqueryparam value="#LocalSearchStartDate#" cfsqltype="CF_SQL_DATE"> and N.DatePosted <= <cfqueryparam value="#LocalSearchEndDate#" cfsqltype="CF_SQL_DATE">				
			</cfif>
		</cfif>		
		<cfif Len(SearchKeyword)>
			ORDER BY RANK DESC
		<cfelse>
			Order By DatePosted desc
		</cfif>		
	</cfquery>
	<cfset CategoryNewsItems=Evaluate("getCategory" & NewsCategoryID & "News.RecordCount")>
	<cfset TotalNewsItems=TotalNewsItems + CategoryNewsItems>
	<cfif CategoryNewsItems>
		<cfset NewsCategoriesWithItems=ListAppend(NewsCategoriesWithItems,NewsCategoryID)>
	</cfif>
</cfloop>

<cfset HalfTotalNewsItems=TotalNewsItems/2>

		
		
<cfoutput>
<div class="centercol-inner legacy">
<div class="landingpageheader"><a href="News"><img src="images/inner/header.tanzanianewstoday.gif" width="305" height="47" alt="Tanzania News Today" border="0" /></a><img src="images/inner/header.stayinformed.gif" onclick="bookmark('#Request.HTTPURL#/News','ZoomTanzania.com News')" class="bookmarkLink"></div>

<!-- TOOLS/SEARCH ROW -->
<div class="newssearchtools"><form action="#lh_getPageLink(34,'news')#" method="<cfif Request.lh_useFriendlyUrls>get<cfelse>post</cfif>" ONSUBMIT="return validateForm(this)"><input name="SearchStartDate" type="text" id="SearchStartDate" size="10" maxlength="50" value="#SearchStartDate#" />&nbsp;-&nbsp;<input name="SearchEndDate" type="text" id="SearchEndDate" size="10" maxlength="50" value="#SearchEndDate#" />&nbsp;&nbsp;<input name="SearchKeyword" type="text" id="SearchKeyword" value="<cfif Len(SearchKeyword)>#SearchKeyword#<cfelse>Find News by Keyword</cfif>" size="28" maxlength="50" onFocus="value=''" />&nbsp;&nbsp;<select name="SearchNewsCategoryID">
  <option value="">-- Select a Type of News --</option>
  	<cfloop query="getSearchNewsCategories">
	  	<option value="#NewsCategoryID#" <cfif NewsCategoryID is SearchNewsCategoryID>selected</cfif>> #Title#
	</cfloop>
</select>
	<input type="hidden" name="Searching" value="1">
    <label>
      <input type="submit" name="button" id="button" value="Search" />
    </label>
</form></div>
</cfoutput>

<cfif Searching and TotalNewsItems is "0">
	No News found for your search criteria.
<cfelse>
	<cfif Len(NCID) or Len(SearchNewsCategoryID) or ListLen(NewsCategoriesWithItems) is "1">
		<cfif Len(NCID)>
			<cfset NCQueryID=NCID>
		<cfelseif Len(SearchNewsCategoryID)>
			<cfset NCQueryID=SearchNewsCategoryID>
		<cfelse>
			<cfset NCQueryID=NewsCategoriesWithItems>
		</cfif>
		<h1 class="news">
			<cfoutput query="getNewsCategories">
				<cfif NewsCategoryID is NCQueryID>
					#Title#
				</cfif>
			</cfoutput>
		</h1>
		<cfoutput query="getCategory#NCQueryID#News">
			<div class="topMargin"><strong>#DateFormat(DatePosted,"dd.mm.yyyy")#</strong> &ndash; <a href="#WebsiteURL#" target="_blank" class="largerLink">#Headline#</a><br />
			<em>Source: #Source#</em></div>
		</cfoutput>
	<cfelse>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		  	<tr>
		    	<td width="50%" >
					<cfset NewsItemsOutput=0>
					<cfset RightColumnStarted = "0">
					<cfset BreakBeforeCategory = "0">
					<cfset BreakAfterCategory = "0">
					<cfoutput query="getNewsCategories">
						<cfset CategoryNewsItems=Evaluate("getCategory" & NewsCategoryID & "News.RecordCount")>
						<cfset PreloadNewsItemsOutput=NewsItemsOutput + CategoryNewsItems>
						<!--- In order to approxiamtely balance the columns, break the column so that the category with the halfway count of total news items is placed in the left column if the halfway count is closer to the bottom of the category. If it is closer to the top of the category, put the Category in the right column.  --->
						<cfif RecordCount is "2" and CurrentRow is RecordCount><!--- If only two categories, one per column. --->
							<cfset BreakBeforeCategory=1>
						<cfelseif PreloadNewsItemsOutput gte HalfTotalNewsItems>
							<cfset HalfCategoryNewsItems=CategoryNewsItems/2>
							<cfset CategoryItemsToHalf=HalfTotalNewsItems-NewsItemsOutput>
							<cfif CategoryItemsToHalf lt HalfCategoryNewsItems>
								<cfset BreakBeforeCategory=1>
							<cfelse>
								<cfset BreakAfterCategory=1>
							</cfif>
						</cfif>
						<cfif not Searching or Evaluate("getCategory" & NewsCategoryID & "News.RecordCount") neq "0">							
							<cfif not RightColumnStarted and BreakBeforeCategory>
								</td>
								<td style="margin-right: 2em">&nbsp;</td>
								<td width="50%">
								<cfset RightColumnStarted = "1">
							</cfif>
							<table width="100%" border="0" cellspacing="0" cellpadding="0" class="landingpagetable">
				        		<tr>
				          			<td class="headercell">#Title#</td>
				        		</tr>
				        		<tr>
				          			<td class="landingpageleft">
										<div class="landingpagetablecontent">
											<cfif Evaluate("getCategory" & NewsCategoryID & "News.RecordCount")>
												<cfloop query="getCategory#NewsCategoryID#News">
													<p>#DateFormat(DatePosted,"dd.mm.yyyy")# &ndash; <a href="#WebsiteURL#" target="_blank" class="largerLink">#Headline#</a><br />
				            						<em>Source: #Source#</em></p>
													<cfset NewsItemsOutput=NewsItemsOutput+1>
												</cfloop>
				           						<div class="greencaps"><a href="#lh_getPageLink(34,'news')##AmpOrQuestion#NCID=#NewsCategoryID#">View all #Title# News</a></div>
											<cfelse>
												No #Title# News available.
											</cfif>
				          				</div>
									</td>
				        		</tr>
				      		</table>					
							<cfif not RightColumnStarted and BreakAfterCategory>
								</td>
								<td style="margin-right: 2em">&nbsp;</td>
								<td width="50%">
								<cfset RightColumnStarted = "1">
							</cfif>
						</cfif>
					</cfoutput>
		      	</td>
		  	</tr>
		</table>
	</cfif>
</cfif>
</div>

<!-- END CENTER COL -->

<cfinclude template="footer.cfm">
