<cfimport prefix="lh" taglib="../Lighthouse/Tags">


<cfparam name="PositionID" default="1">
<cfset allFields="BannerAdPlacement,PositionID,CategoryIDs,ParentSectionIDs,SectionIDs">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="BannerAdPlacement,PositionID">


<cfquery name="getBannerPricing" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	select * from BannerAdPricing
</cfquery>

<cfset impressions = "1000,2000,5000,10000,15000,20000,25000,30000,35000,40000,45000,50000,60000,70000,80000,90000,100000">

<cfquery name="getBannerAd" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	
	
	Select B.*,BPS.ParentSectionID,BS.SectionID,BC.CategoryID,BP.Placement
	From BannerAds B Left Join BannerAdParentSections BPS on B.BannerAdID=BPS.BannerAdID
	inner join BannerAdPlacement BP ON BP.PlacementID = B.PlacementID
	Left Join BannerAdCategories BC on B.BannerAdID=BC.BannerAdID
	Left Outer Join BannerAdSections BS on B.BannerAdID=BS.BannerAdID 
	Where B.BannerAdID=<cfqueryparam value="#BannerAdID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfquery dbType="query" name="getParentSectionIDs">
	select distinct(ParentSectionID)
	from getBannerAd
</cfquery>
<cfquery dbType="query" name="getSectionIDs">
	select distinct(SectionID)
	from getBannerAd
</cfquery>
<cfset ParentSectionIDs=ValueList(getParentSectionIDs.ParentSectionID)>
<cfset SectionIDs=ValueList(getSectionIDs.SectionID)>
<cfset CategoryIDs=ValueList(getBannerAd.CategoryID)>

<cfset BannerAdPlacement = getBannerAd.PlacementID>
<cfset PositionID = getBannerAd.PositionID>
<cfset BannerAdImpressions = getBannerAd.Impressions>
<cfset BannerAdStartDate = getBannerAd.StartDate>
<cfset BannerAdEndDate = getBannerAd.EndDate>
<cfif Len(BannerAdStartDate)>
	<cfset BannerAdStartDate = DateFormat(BannerAdStartDate,"dd/mm/yyyy")>
</cfif>
<cfif Len(BannerAdEndDate)>
	<cfset BannerAdEndDate = DateFormat(BannerAdEndDate,"dd/mm/yyyy")>
</cfif>
<cfset BannerAdFileName = getBannerAd.BannerAdImage>
<cfset BannerAdUrl = getBannerAd.BannerAdUrl>

<script language="javascript">
	$(document).ready(function()
	{	
		//$("#impressions").change(checkImpressions);
		//$("#StartDisplayingOn").blur(checkImpressions);
		//$("#StopDisplayingOn").blur(checkImpressions);
		$("#btn").click(checkImpressions);			
	});
	
	
	function checkImpressions(){
	if (validateForm(document.f1)){
	<cfif PositionID NEQ 1>
	<cfoutput>
		<cfif BannerAdPlacement EQ 4>	
		var imp = eval(parseInt($('##impressions').val())+#getBannerAd.impressions#); 		
		var datastring = "impressions="+imp+"&sectionIDs=#sectionIDs#&startDate=#DateFormat(getBannerAd.startDate,'dd/mm/yyyy')#&endDate=#DateFormat(getBannerAd.endDate,'dd/mm/yyyy')#";		
		
		$.ajax(
		           {
					type:"POST",
		               url:"#Request.HTTPURL#/includes/BannerAdImpressions.cfc?method=CheckImpressionsSection&returnformat=plain",
		               data:datastring,
		               success: function(response)
		               {
					   		validImp = parseInt(jQuery.trim(response));
							if(validImp != 0){
							alert('You have selected too many impressions for this sub section. Please either choose fewer impressions, lengthen the display period, or go back and select more sub sections. The daily impression average for the date range you selected is '+validImp+' impressions per day.');
							document.getElementById('impressions').selectedIndex = 0;
							$('##impressions').focus();
							}
							else{
							$('##f1').submit();
							}
	
		               }
		           });
		           
		<cfelseif BannerAdPlacement EQ 3>
		var imp = eval(parseInt($('##impressions').val())+#getBannerAd.impressions#); 		
		var datastring = "impressions="+imp+"&parentsectionIDs=#parentsectionIDs#&startDate=#DateFormat(getBannerAd.startDate,'dd/mm/yyyy')#&endDate=#DateFormat(getBannerAd.endDate,'dd/mm/yyyy')#";		
		
		$.ajax(
		           {
					type:"POST",
		               url:"#Request.HTTPURL#/includes/BannerAdImpressions.cfc?method=CheckImpressionsParentSection&returnformat=plain",
		               data:datastring,
		               success: function(response)
		               {
					   		validImp = parseInt(jQuery.trim(response));
							if(validImp != 0){
							alert('You have selected too many impressions for this section. Please either choose fewer impressions, lengthen the display period, or go back and select more sections. The daily impression average for the date range you selected is '+validImp+' impressions per day.');
							document.getElementById('impressions').selectedIndex = 0;
							$('##impressions').focus();
							}
							else{
							$('##f1').submit();
							}
	
		               }
		           });
		
		<cfelseif BannerAdPlacement EQ 5>
		var imp = eval(parseInt($('##impressions').val())+#getBannerAd.impressions#); 		
		var datastring = "impressions="+imp+"&categoryIDs=#categoryIDs#&startDate=#DateFormat(getBannerAd.startDate,'dd/mm/yyyy')#&endDate=#DateFormat(getBannerAd.endDate,'dd/mm/yyyy')#";		
		
		$.ajax(
		           {
					type:"POST",
		               url:"#Request.HTTPURL#/includes/BannerAdImpressions.cfc?method=CheckImpressionsCategory&returnformat=plain",
		               data:datastring,
		               success: function(response)
		               {
					   		validImp = parseInt(jQuery.trim(response));
							if(validImp != 0){
							alert('You have selected too many impressions for this category. Please either choose fewer impressions, lengthen the display period, or go back and select more categories. The daily impression average for the date range you selected is '+validImp+' impressions per day.');
							document.getElementById('impressions').selectedIndex = 0;
							$('##impressions').focus();
							}
							else{
							$('##f1').submit();
							}
	
		               }
		           });
		           
		<cfelse>           
		  $('##f1').submit();     
		</cfif>           
	</cfoutput>
	<cfelse>
		$('#f1').submit(); 	           	
	</cfif>	
	}
	}
	function validateForm(f){
	 if (!checkSelected(f.impressions,"Impressions")) {
				return false;
	}
	
	if (!checkText(f.Price,"Price")) {
				return false;
	}
	
	if (!checkNumber(f.Price,"Price")) {
				return false;
	}
	
	
	return true;
	}
</script>



<cfinclude template="../includes/BannerAdPricing.cfm">

<cfif BannerAdPlacement EQ 5>	
	
	<cfquery name="getCategoryTree" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum,
		S.SectionID, S.Title as STitle, S.OrderNum as SOrderNum,
		C.CategoryID, C.Title as CTitle, C.OrderNum as COrderNum
		FROM Categories C
		Inner Join Sections S on C.SectionID=S.SectionID
		Inner Join ParentSectionsView PS on S.ParentSectionID=PS.ParentSectionID
		WHERE C.CategoryID IN (<cfqueryparam value="#CategoryIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)
	</cfquery>
	
<cfelseif BannerAdPlacement EQ 3>
	<cfquery name="getSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum
		FROM  ParentSectionsView PS 
		WHERE PS.ParentSectionID IN (<cfqueryparam value="#ParentSectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)
	</cfquery>
	
<cfelseif BannerAdPlacement EQ 4>
	<cfquery name="getSections" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		SELECT PS.ParentSectionID, PS.Title as PSTitle, PS.OrderNum as PSOrderNum,
		S.SectionID, S.Title as STitle, S.OrderNum as SOrderNum
		FROM  Sections S
		Inner Join ParentSectionsView PS on S.ParentSectionID=PS.ParentSectionID
		WHERE S.SectionID IN (<cfqueryparam value="#SectionIDs#" cfsqltype="CF_SQL_INTEGER" list="true">)
	</cfquery>		

</cfif>


<cfoutput>
<form name="f1" id="f1" action="page.cfm?PageID=#Request.AddABannerAdPageID#" method="post" ENCTYPE="multipart/form-data" >
	<input type="hidden" name="BannerAdID" value="#BannerAdID#">
	
	<table  border="1" cellspacing="0" style="width:100%;">
		<tr style="background: ##96AFCF;">
			<td style="padding:3px;text-align:center">Location</td>
			<td style="padding:3px;text-align:center">## of Impressions</td>
			
		</tr>
		<cfif BannerAdPlacement EQ 5>
			<input type="hidden" name="CategoryIDs" value="#CategoryIDs#">
			<cfloop query="getCategoryTree">
				<tr>
				 	<td style="text-align:center;padding:5px;">#PSTitle# ><br> #Stitle# ><br> <b>#Ctitle#</b></td>
				 	<cfif currentRow EQ 1>
					 	<td rowSpan="#getCategoryTree.recordcount#" style="text-align:center;padding:5px;">
						 	<select name="impressions" id="impressions">
							<option value=""></option>
							<cfloop list="#impressions#" index="i">
								<cfif i LT 11000>
									<cfset price = PriceLT10K*(i/1000)>
								<cfelseif i GTE 11000 AND i LT 50000>
									<cfset price = Price1150K*(i/1000)>
								<cfelse>
									<cfset price = PriceGT50K*(i/1000)>		
								</cfif>
								<option value="#i#">#i#</option>	
							</cfloop>	
							</select>
							
						</td>
					</cfif>
				</tr>
			</cfloop>
		<cfelseif BannerAdPlacement EQ 3>
			<input type="hidden" name="ParentSectionIDs" value="#ParentSectionIDs#">
			<cfloop query="getSections">
				<tr>
				 	<td style="text-align:center;padding:5px;">#PSTitle#</td>
				 	<cfif currentRow EQ 1>
					 	<td rowSpan="#getSections.recordcount#" style="text-align:center;padding:5px;">
						 	<select name="impressions" id="impressions">
							<option value=""></option>
							<cfloop list="#impressions#" index="i">
								<cfif i LT 11000>
									<cfset price = PriceLT10K*(i/1000)>
								<cfelseif i GTE 11000 AND i LT 50000>
									<cfset price = Price1150K*(i/1000)>
								<cfelse>
									<cfset price = PriceGT50K*(i/1000)>		
								</cfif>
								<option value="#i#">#i#</option>	
							</cfloop>	
							</select>
							
						</td>
					</cfif>
				</tr>
			</cfloop>
		<cfelseif BannerAdPlacement EQ 4>
			<input type="hidden" name="SectionIDs" value="#SectionIDs#">
			<cfloop query="getSections">
				<tr>
				 	<td style="text-align:center;padding:5px;">#PSTitle#><br>#STitle#</td>
				 	<cfif currentRow EQ 1>
					 	<td rowSpan="#getSections.recordcount#" style="text-align:center;padding:5px;">
						 	<select name="impressions" id="impressions">
							<option value=""></option>
							<cfloop list="#impressions#" index="i">
								<cfif i LT 11000>
									<cfset price = PriceLT10K*(i/1000)>
								<cfelseif i GTE 11000 AND i LT 50000>
									<cfset price = Price1150K*(i/1000)>
								<cfelse>
									<cfset price = PriceGT50K*(i/1000)>		
								</cfif>
								<option value="#i#">#i#</option>	
							</cfloop>	
							</select>
							
						</td>
					</cfif>
				</tr>
			</cfloop>		
		<cfelseif BannerAdPlacement EQ 1>	
			<tr>
				<td style="text-align:center;padding:5px;">Home Page</td>
				 
				<td style="text-align:center;padding:5px;">
					<select name="impressions" id="impressions">
							<option value=""></option>
							<cfloop list="#impressions#" index="i">
								<cfif i LT 11000>
									<cfset price = PriceLT10K*(i/1000)>
								<cfelseif i GTE 11000 AND i LT 50000>
									<cfset price = Price1150K*(i/1000)>
								<cfelse>
									<cfset price = PriceGT50K*(i/1000)>		
								</cfif>
								<option value="#i#">#i#</option>	
							</cfloop>	
						</select>
						
				</td>
				<td style="text-align:center;padding:5px;"><input name="StartDisplayingOn" id="StartDisplayingOn" value="#BannerAdStartDate#" maxLength="20"></td>
				<td style="text-align:center;padding:5px;"><input name="StopDisplayingOn" id="StopDisplayingOn" value="#BannerAdEndDate#" maxLength="20"></td>
					
					
				</tr>
		<cfelseif BannerAdPlacement EQ 2>	
			<tr>
				<td style="text-align:center;padding:5px;">Site Wide</td>
				 
				<td style="text-align:center;padding:5px;">
					<select name="impressions" id="impressions">
							<option value=""></option>
							<cfloop list="#impressions#" index="i">
								<cfif i LT 11000>
									<cfset price = PriceLT10K*(i/1000)>
								<cfelseif i GTE 11000 AND i LT 50000>
									<cfset price = Price1150K*(i/1000)>
								<cfelse>
									<cfset price = PriceGT50K*(i/1000)>		
								</cfif>
								<option value="#i#">#i#</option>	
							</cfloop>	
						</select>
						
				</td>	
					
				</tr>		
		<cfelseif BannerAdPlacement EQ 6>	
			<tr>
				<td style="text-align:center;padding:5px;">Admin Pages</td>
				 
				<td style="text-align:center;padding:5px;">
					<select name="impressions">
							<option value=""></option>
							<cfloop list="#impressions#" index="i">
								<cfif i LT 11000>
									<cfset price = PriceLT10K*(i/1000)>
								<cfelseif i GTE 11000 AND i LT 50000>
									<cfset price = Price1150K*(i/1000)>
								<cfelse>
									<cfset price = PriceGT50K*(i/1000)>		
								</cfif>
								<option value="#i#">#i#</option>	
							</cfloop>	
						</select>
							
				</td>
					
				</tr>		
		</cfif>
	
	</table>	
		
	
	<br><br>
	
	
		
		<tr>
			<td valign="top">
				Price:
			</td>
			<td>
				<input type="text" name="Price" value="" ID="Price" size="42" maxlength="200" value=""><br>
				
			</td>
		</tr>
		<tr>
			
			<td><br>
				<div id="NextButtonDiv">
	
					<input type="button" name="Next" value="Next >>" id="btn"></div>
				
				<input type="hidden" name="Step" value="7">
			</td>
		</tr>
	</table>
	
	
</form>
</cfoutput>
