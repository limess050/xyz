
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Banner Ad Pricing">
<cfinclude template="../Lighthouse/Admin/Header.cfm">





<lh:MS_Table table="BannerAdPricing" title="#pg_title#"  allowedActions="Edit,View" >
	
	<lh:MS_TableColumn
		ColName="BannerAdPricingID"
		DispName="ID"
		type="integer"
		Format="_$_,___.__" 
		PrimaryKey="true"
		Identity="true" />
	
	<lh:MS_TableColumn
		ColName="HomePageAdFeeMonthly"
		DispName="Homepage Ad Fee Monthly"
		type="integer"
		Format="_$_,___.__" 	
		 />	
		 
	<lh:MS_TableColumn
		ColName="SitewidePosition1FeeMonthly"
		DispName="Site-Wide Position 1 Fee Monthly"
		type="integer"
		Format="_$_,___.__" 	
		 />	
		 
	<lh:MS_TableColumn
		ColName="SectionPosition1FeeMonthly"
		DispName="Section Position 1 Fee Monthly"
		type="integer"
		Format="_$_,___.__" 	
		 />		
		 
	<lh:MS_TableColumn
		ColName="SubsectionPosition1FeeMonthly"
		DispName="Sub-Section Position 1 Fee Monthly"
		type="integer"
		Format="_$_,___.__" 	
		 />	
		 
	<lh:MS_TableColumn
		ColName="CategoryPosition1FeeMonthly"
		DispName="Category Position 1 Fee Monthly"
		type="integer"
		Format="_$_,___.__" 	
		 />	
		 
		 
	
	<lh:MS_TableColumn
		ColName="SitewidePosition2FeeLT10K"
		DispName="Site-Wide Position 2 Fee < 10K"
		type="integer"
		Format="_$_,___.__" 	
		 />	
		 
	<lh:MS_TableColumn
		ColName="SectionPosition2FeeLT10K"
		DispName="Section Position 2 Fee < 10K"
		type="integer"
		Format="_$_,___.__" 	
		 />		
		 
	<lh:MS_TableColumn
		ColName="SubsectionPosition2FeeLT10K"
		DispName="Sub-Section Position 2 Fee < 10K"
		type="integer"
		Format="_$_,___.__" 	
		 />	
		 
	<lh:MS_TableColumn
		ColName="CategoryPosition2FeeLT10K"
		DispName="Category Position 2 Fee < 10K"
		type="integer"
		Format="_$_,___.__" 	
		 />
	
		 
	<lh:MS_TableColumn
		ColName="SitewidePosition3FeeLT10K"
		DispName="Site-Wide Position 3 Fee < 10K"
		type="integer"
		Format="_$_,___.__" 	
		 />	
		 
	<lh:MS_TableColumn
		ColName="SectionPosition3FeeLT10K"
		DispName="Section Position 3 Fee < 10K"
		type="integer"
		Format="_$_,___.__" 	
		 />		
		 
	<lh:MS_TableColumn
		ColName="SubsectionPosition3FeeLT10K"
		DispName="Sub-Section Position 3 Fee < 10K"
		type="integer"
		Format="_$_,___.__" 	
		 />	
		 
	<lh:MS_TableColumn
		ColName="CategoryPosition3FeeLT10K"
		DispName="Category Position 3 Fee < 10K"
		type="integer"
		Format="_$_,___.__" 	
		 />	 
		 
		 
	<lh:MS_TableColumn
		ColName="SitewidePosition2Fee1150K"
		DispName="Site-Wide Position 2 Fee 11K - 50K"
		type="integer"
		Format="_$_,___.__" 	
		 />	
		 
	<lh:MS_TableColumn
		ColName="SectionPosition2Fee1150K"
		DispName="Section Position 2 Fee 11K - 50K"
		type="integer"
		Format="_$_,___.__" 	
		 />		
		 
	<lh:MS_TableColumn
		ColName="SubsectionPosition2Fee1150K"
		DispName="Sub-Section Position 2 Fee 11K - 50K"
		type="integer"
		Format="_$_,___.__" 	
		 />	
		 
	<lh:MS_TableColumn
		ColName="CategoryPosition2Fee1150K"
		DispName="Category Position 2 Fee 11K - 50K"
		type="integer"
		Format="_$_,___.__" 	
		 />	
		 
	<lh:MS_TableColumn
		ColName="SitewidePosition3Fee1150K"
		DispName="Site-Wide Position 3 Fee 11K - 50K"
		type="integer"
		Format="_$_,___.__" 	
		 />	
		 
	<lh:MS_TableColumn
		ColName="SectionPosition3Fee1150K"
		DispName="Section Position 3 Fee 11K - 50K"
		type="integer"
		Format="_$_,___.__" 	
		 />		
		 
	<lh:MS_TableColumn
		ColName="SubsectionPosition3Fee1150K"
		DispName="Sub-Section Position 3 Fee 11K - 50K"
		type="integer"
		Format="_$_,___.__" 	
		 />	
		 
	<lh:MS_TableColumn
		ColName="CategoryPosition3Fee1150K"
		DispName="Category Position 3 Fee 11K - 50K"
		type="integer"
		Format="_$_,___.__" 	
		 />		 	 	 	   	 
		 
		<lh:MS_TableColumn
		ColName="SitewidePosition2FeeGT50K"
		DispName="Site-Wide Position 2 Fee > 50K"
		type="integer"
		Format="_$_,___.__" 
		 />	
		 
	<lh:MS_TableColumn
		ColName="SectionPosition2FeeGT50K"
		DispName="Section Position 2 Fee > 50K"
		type="integer"
		Format="_$_,___.__" 
		 />		
		 
	<lh:MS_TableColumn
		ColName="SubsectionPosition2FeeGT50K"
		DispName="Sub-Section Position 2 Fee > 50K"
		type="integer"
		Format="_$_,___.__" 
		 />	
		 
	<lh:MS_TableColumn
		ColName="CategoryPosition2FeeGT50K"
		DispName="Category Position 2 Fee > 50K"
		type="integer"
		Format="_$_,___.__" 
		 />	 	
		 
	<lh:MS_TableColumn
		ColName="SitewidePosition3FeeGT50K"
		DispName="Site-Wide Position 3 Fee > 50K"
		type="integer"
		Format="_$_,___.__" 
		 />	
		 
	<lh:MS_TableColumn
		ColName="SectionPosition3FeeGT50K"
		DispName="Section Position 3 Fee > 50K"
		type="integer"
		Format="_$_,___.__" 
		 />		
		 
	<lh:MS_TableColumn
		ColName="SubsectionPosition3FeeGT50K"
		DispName="Sub-Section Position 3 Fee > 50K"
		type="integer"
		Format="_$_,___.__" 
		 />	
		 
	<lh:MS_TableColumn
		ColName="CategoryPosition3FeeGT50K"
		DispName="Category Position 3 Fee > 50K"
		type="integer"
		Format="_$_,___.__" 
		 />		 
	
</lh:MS_Table>


<cfinclude template="../Lighthouse/Admin/Footer.cfm">