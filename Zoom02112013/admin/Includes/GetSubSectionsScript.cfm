<cfparam name="IncludeCats" default="0">
<cfparam name="CatsMultiple" default="0">

<script language="javascript" type="text/javascript">
		var sectionIDList=0;
		var categoryIDList=0;
		$(document).ready(function()
		{		    
			$("#ParentSectionID_TR").hide();
			$("#SectionID_TR").hide();
			$("#CategoryID_TR").hide();
			var parentSectionIDList='';
			<cfif Action is "Search">
				//alert(document.f1.ParentSectionID.value);	
				for (var i = 0; i < document.f1.ParentSectionID.length; i++) {
					//alert(i);
					if (document.f1.ParentSectionID[i].selected==true) {
						//alert(i);
						if (parentSectionIDList.length!=0) {
							parentSectionIDList=parentSectionIDList + '|' + document.f1.ParentSectionID[i].value;
						}
						else {
							parentSectionIDList=document.f1.ParentSectionID[i].value;
						}
						
					}
				}			
				for (var i = 0; i < document.f1.SectionID.length; i++) {
					//alert(i);
					if (document.f1.SectionID[i].selected==true) {
						//alert(i);
						if (sectionIDList.length!=0) {
							sectionIDList=sectionIDList + '|' + document.f1.SectionID[i].value;
						}
						else {
							sectionIDList=document.f1.SectionID[i].value;
						}
						
					}
				}
			<cfelse>
				//alert(document.f1.ParentSectionID.value);	
				parentSectionIDList=document.f1.ParentSectionID.value
				sectionIDList=document.f1.SectionID.value
			</cfif>
				//alert ('p' + parentSectionIDList);
			getSectionSelectList(parentSectionIDList);		
			<cfif IncludeCats>getCategorySelectList(parentSectionIDList,sectionIDList);</cfif>		
		});
		$("#ParentSectionID").change(function(e)
	    {	
			parentSectionIDList='';
			sectionIDList='';
			<cfif Action is "Search">
				//alert(document.f1.ParentSectionID.value);	
				for (var i = 0; i < document.f1.ParentSectionID.length; i++) {
					//alert(i);
					if (document.f1.ParentSectionID[i].selected==true) {
						//alert(i);
						if (parentSectionIDList.length!=0) {
							parentSectionIDList=parentSectionIDList + '|' + document.f1.ParentSectionID[i].value;
						}
						else {
							parentSectionIDList=document.f1.ParentSectionID[i].value;
						}
						
					}
				}
			<cfelse>
				//alert(document.f1.ParentSectionID.value);	
				parentSectionIDList=document.f1.ParentSectionID.value
			</cfif>
				//alert ('p' + parentSectionIDList);
			getSectionSelectList(parentSectionIDList);		
			<cfif IncludeCats>getCategorySelectList(parentSectionIDList,sectionIDList);</cfif>							       
	    });
		<cfoutput>
		function getSectionSelectList(x) {
			if (sectionIDList=='') {
				sectionIDList=0;
			}
			if (x=='') {
				var datastring = "ParentSectionID=0&SectionID=" + sectionIDList + "&Action=#Action#";
			}
			else {
				var datastring = "ParentSectionID=" + x + "&SectionID=" + sectionIDList + "&Action=#Action#";
			}		 
            
			$.ajax(
            {
				type:"POST",
                url:"#Request.HTTPURL#/includes/GetSubSections.cfc?method=SelectList&returnformat=plain",
                data:datastring,
                success: function(response)
                {
					var resp = jQuery.trim(response);					
					$("##ParentSectionID_TR").show();
					if (resp=='') {
                    	$("##SectionID_TR").html('<td class="ADDFIELDCELL" colspan="2"><input name="SectionID_isEditable" value="true" type="hidden"><input name="SectionID" value="" type="hidden"></td>');						
						$("##SectionID_TR").hide();
						<cfif IncludeCats>getCategorySelectList(x,'0');</cfif>	
					}
					else {
                    	$("##SectionID_TR").html(resp);
						$("##SectionID_TR").show();
						$("##SectionID").change(function(e)
						    {	
								var sectionIDList='';
								<cfif Action is "Search">
									for (var i = 0; i < document.f1.SectionID.length; i++) {
										if (document.f1.SectionID[i].selected==true) {
											if (sectionIDList.length!=0) {
												sectionIDList=sectionIDList + '|' + document.f1.SectionID[i].value;
											}
											else {
												sectionIDList=document.f1.SectionID[i].value;
											}
											
										}
									}
								<cfelse>
									sectionIDList=document.f1.SectionID.value
								</cfif>
								<cfif IncludeCats>getCategorySelectList(x,sectionIDList);</cfif>							       
						    });
					}
					
                }
            });
		} 
		<cfif IncludeCats>
		function getCategorySelectList(p,s) {
			if (categoryIDList=='') {
				categoryIDList=0;
			}
			for (var i = 0; i < document.f1.CategoryID.length; i++) {
				if (document.f1.CategoryID[i].selected==true) {
					if (categoryIDList.length!=0) {
						categoryIDList=categoryIDList + '|' + document.f1.CategoryID[i].value;
					}
					else {
						categoryIDList=document.f1.CategoryID[i].value;
					}					
				}
			}
			if (p=='' && s=='') {
				var datastring = "ParentSectionID=0&SectionID=0&CategoryID=" + categoryIDList + "&Action=#Action#" + "&CatsMultiple=#CatsMultiple#";
			}
			else if (s=='') {
				var datastring = "ParentSectionID=" + p + "&SectionID=0&CategoryID=" + categoryIDList + "&Action=#Action#" + "&CatsMultiple=#CatsMultiple#";
			}
			else if (p=='') {
				var datastring = "ParentSectionID=0&SectionID=" + s + "&CategoryID=" + categoryIDList + "&Action=#Action#" + "&CatsMultiple=#CatsMultiple#";
			}
			else {
				var datastring = "ParentSectionID=" + p + "&SectionID=" + s + "&CategoryID=" + categoryIDList + "&Action=#Action#" + "&CatsMultiple=#CatsMultiple#";
			}		 
            
			$.ajax(
            {
				type:"POST",
                url:"#Request.HTTPURL#/includes/GetCategories.cfc?method=SelectList&returnformat=plain",
                data:datastring,
                success: function(response)
                {
					var resp = jQuery.trim(response);
                    $("##CategoryID_TR").html(resp);									
					$("##CategoryID_TR").show();
                }
            });
		} 
		</cfif>
		</cfoutput>
	</script>