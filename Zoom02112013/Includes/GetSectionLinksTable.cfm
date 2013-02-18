<!--- ParentSectionID passed in and SubSectionID select list passed out.
If SectionID passed in and SectionID exists in resulting select list, marked it 'selected' --->

<cfparam name="ParentSectionID" default="0">
<cfparam name="SubSectionID" default="">
<cfparam name="PopoutFormat" default="0">
<cfparam name="ShowEmptyCategories" default="1">

<cfparam name="JETID" default="">

<cfquery name="SectionLinks" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select C.SectionID, S.Title as SubSection, S.OrderNum as SectionOrderNum,
	C.CategoryID, C.Title as Category, C.OrderNum as CategoryOrderNum, C.SectionID, C.ParentSectionID, 
	(Select Count(L.ListingID) 
	From ListingsView L Inner Join ListingCategories LC on L.ListingID=LC.ListingID
	Where LC.CategoryID=C.CategoryID
	<cfinclude template="../includes/LiveListingFilter.cfm"> )
	as ListingCount
	From Sections S
	Left Outer Join Categories C on S.SectionID=C.SectionID or (C.ParentSectionID=S.SectionID and C.SectionID is null) 
	Where S.Active=1
	and C.ParentSectionID=<cfqueryparam value="#ParentSectionID#" cfsqltype="CF_SQL_INTEGER">
	<cfif Len(SubSectionID)>
		and C.SectionID=<cfqueryparam value="#SubSectionID#" cfsqltype="CF_SQL_INTEGER">
	</cfif>
	and C.Active=1
	Order By SectionOrderNum, CategoryOrderNum
</cfquery>



<cfif ParentSectionID is "8">
	<p>
		<div class="hpitem-expand" ID="EmpOppsDiv">
			<span class="hpcategory-expand"><a onClick="showJAndEContent(1,1);">Employment Opportunities</a></span><br />
			<span id="EmpOppsSpan"></span>
		</div> 
		<div class="hpitem-expand" ID="SeekEmpDiv">
			<span class="hpcategory-expand"><a onClick="showJAndEContent(1,2);">Seeking Employment</a></span><br />
			<span id="SeekEmpSpan"></span>
		</div> 
		<!--- <div class="hpitem-expand" ID="TendOppsDiv">
			<span class="hpcategory-expand"><a onClick="showJAndEContent(1,3);">Tenders Opportunities</a></span><br />
			<span id="TendOppsSpan"></span>
		</div>  --->
	</p>
<cfelse>
	<p>
	<cfoutput query="SectionLinks" group="SectionOrderNum">		
			<div class="hpitem-expand">
				<span class="hpcategory-expand"><cfif Len(SectionID)>#SubSection#<cfelse>&nbsp;</cfif></span><br />
				<cfset ShowComma="0">
				<cfset LinkCount=1>
		  		<cfoutput group="CategoryOrderNum"><cfif Len(Category)><cfif ShowComma>, </cfif><a href="#lh_getPageLink(2,'category')##AmpOrQuestion#CategoryID=#CategoryID#" <cfif LinkCount MOD 2 is "0">class="alternatelink"</cfif>>#Category#<!--- <cfif request.environment neq "live"> --->&nbsp;(#ListingCount#)<!--- </cfif> ---></a></cfif><cfset ShowComma="1"><cfset LinkCount=LinkCount+1></cfoutput>
			</div> 			
	</cfoutput>
	</p>
</cfif>


<cfif ParentSectionID is "8">	
	<cfoutput>
		<script language="javascript" type="text/javascript">			
			function showJAndEContent(x,y) {
				$("##EmpOppsSpan").hide('slow');
				$("##SeekEmpSpan").hide('slow');
				$("##TendOppsSpan").hide('slow');
				$("##SeekTendSpan").hide('slow');
				var datastring = "TID=" + x + "&ID=" + y; <!--- 
				<cfif Len(JETID)>
					datastring=datastring + "&JETID=#JETID#";
				</cfif> --->
				$.ajax(
		           {
					type:"POST",
		               url:"#Request.HTTPSURL#/includes/GetJAndELinksTable.cfc?method=Get&returnformat=plain",
		               data:datastring,
		               success: function(response)
		               {		
						   	var resp = jQuery.trim(response);	
							if (y==1) {
								$("##EmpOppsSpan").html(resp);
								$("##EmpOppsSpan").show('slow');
							}
							if (y==2) {
								$("##SeekEmpSpan").html(resp);
								$("##SeekEmpSpan").show('slow');
							}
							if (y==3) {
								$("##TendOppsSpan").html(resp);
								$("##TendOppsSpan").show('slow');
							}
							if (y==4) {
								$("##SeekTendSpan").html(resp);
								$("##SeekTendSpan").show('slow');
							}
		               }
		           });
			}	
		 	<cfif Len(JETID)>
		 		showJAndEContent(2,#JETID#);
		 	</cfif>	
		</script>
	</cfoutput>
</cfif>
