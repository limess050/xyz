
<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "House Banner Ads">
<cfinclude template="../Lighthouse/Admin/Header.cfm">

<cfoutput><script language="JavaScript" src="#Request.HTTPSURL#/scripts/jquery-1.3.2.min.js" type="text/javascript"></script></cfoutput>


<lh:MS_Table table="HouseBannerAds" title="#pg_title#" defaultAction="View">
	
	<lh:MS_TableColumn
		ColName="HouseBannerAdID"
		DispName="ID"
		type="integer"
		PrimaryKey="true"
		Search="no"	
		Identity="true" />	
	
		
		<lh:MS_TableColumn
		ColName="PositionID"
		DispName="Position"
		type="select"
		FKTable="BannerAdPosition"
		FKColName="PositionID"
		FKDescr="Position"
		View="no"	
		SelectQuery="Select PositionID as SelectValue, Position as SelectText From BannerAdPosition Order By PositionID"	
		Required="Yes" />
	
		
	<lh:MS_TableColumn
		ColName="BannerAdUrl"
		DispName="Banner Ad Url"	
		type="text" 
		MaxLength="200"
		Required="Yes" 			
		 />
		
		
	<lh:MS_TableColumn
			ColName="BannerAdImage"
			DispName="Image"
			type="File"
			Directory="#Request.MCFUploadsDir#/BannerAds"
			NameConflict="makeunique"
			DeleteWithRecord="Yes"
			Search="No"
		/>	
		
		<lh:MS_TableColumn 
		colname="BannerAdED" 
		dispname="Everything DAR Ad"	
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="0"
		View="No"
		Search="Yes"/>
		
	
		<lh:MS_TableColumn 
		colname="active" 
		dispname="Active?"	
		type="checkbox" 
		OnValue="1" 
		Offvalue="0"
		DefaultValue="1"
		View="No"
		Search="Yes"		 />
		
		
	
</lh:MS_Table>


<cfinclude template="../Lighthouse/Admin/Footer.cfm">