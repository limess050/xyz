<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Orders">

<cfif IsDefined('url.OrderBy')>
	<cfset url.OrderBy=ReplaceNoCase(url.OrderBy,'Orders.','OrdersSearchView.','ALL')>
</cfif>

<cfinclude template="../Lighthouse/Admin/Header.cfm">
<cfoutput><script language="JavaScript" src="#Request.HTTPSURL#/scripts/jquery-1.3.2.min.js" type="text/javascript"></script></cfoutput>

<cfparam name="Action" default="View">
<cfparam name="OrderTable" default="Orders">

<cfset AllowAcctAssignment="true">
<cfif Action is "Edit">
<!--- See if already has an account associated with the order --->	
	<cfquery name="CheckAccount"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select UserID
		From Orders
		Where OrderID= <cfqueryparam value="#PK#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif Len(CheckAccount.UserID)>
		<cfset AllowAcctAssignment="false">
	</cfif>
</cfif>

<cfif ListFind("Search,View",Action)>
	<cfset OrderTable="OrdersSearchView">
</cfif>

<cfif ListFind("Edit",Action) and IsDefined('pk')>
	<cfquery name="Listings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.ListingID, 
		CASE WHEN L.ListingTypeID in (10,12) THEN L.ShortDescr ELSE L.ListingTitle END as ListingTitle,
		L.ListingType, L.active, L.Reviewed, L.OrderID, L.ExpandedListingOrderID,
		L.ListingPackageID, L.ExpirationDate, L.ListingTypeID,
		CASE WHEN LR.ListingRenewalID is not null THEN LR.ListingFee ELSE L.ListingFee END as ListingFee,
		CASE WHEN LR.ListingRenewalID is not null THEN LR.ExpandedListingFee ELSE L.ExpandedListingFee END as ExpandedListingFee,
		LR.ListingRenewalID,  LR.ListingPackageID as RenewalListingPackageID,
		(Select Top 1 Title From Categories C2 Inner Join ListingCategories LC2 on C2.CategoryID=LC2.CategoryID Where LC2.ListingID=L.ListingID) as Category,
		LT.Title as ListingType, LT.TermExpiration,
		M.Title as MakeTitle
		From ListingsView L
		Left Outer Join ListingRenewals LR on L.ListingID=LR.ListingID and LR.OrderID=<cfqueryparam value="#PK#" cfsqltype="CF_SQL_INTEGER">
		Left Outer Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
		Left Outer Join Makes M on L.MakeID=M.MakeID
		Where L.OrderID = <cfqueryparam value="#PK#" cfsqltype="CF_SQL_INTEGER">
		or L.ExpandedListingOrderID = <cfqueryparam value="#PK#" cfsqltype="CF_SQL_INTEGER">
		or LR.OrderID = <cfqueryparam value="#PK#" cfsqltype="CF_SQL_INTEGER">
		Order By ListingID 
	</cfquery>
	<cfquery name="ListingPackages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select L.*, 
		CASE
		WHEN LP.FiveListing=1 THEN 5
		WHEN LP.TenListing=1 THEN 10
		WHEN LP.TwentyListing=1 THEN 20
		WHEN LP.UnlimitedListing=1 THEN 1000000<!--- Unlimited --->
		END as ListingsPaidFor,
		O.OrderID, PS.Title as PaymentStatus, O.PaymentDate,
		(Select Top 1 Title From Categories C inner join ListingCategories LC on C.CategoryID=LC.CategoryID Where LC.ListingID=L.ListingID) as Category,
		LT.Title as ListingType, LT.TermExpiration,
		M.Title as MakeTitle	
		From ListingPackages LP 
		Left Outer Join Listings L on LP.ListingPackageID=L.ListingPackageID
		Inner Join Orders O on LP.OrderID=O.OrderID
		Left Outer Join PaymentStatuses PS on O.PaymentStatusID=PS.PaymentStatusID
		Left Outer Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
		Left Outer Join Makes M on L.MakeID=M.MakeID
		Where O.OrderID = <cfqueryparam value="#PK#" cfsqltype="CF_SQL_INTEGER">
		Order By L.ListingPackageID, L.ListingID 
	</cfquery>
	<cfquery name="ListingServices" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select LS.ListingServiceID, LS.ServiceDescr, LS.ListingID,
		L.ListingTitle
		From ListingServices LS Inner Join ListingsView L on LS.ListingID=L.ListingID
		Where LS.OrderID = <cfqueryparam value="#PK#" cfsqltype="CF_SQL_INTEGER">
		Order By ListingServiceID 
	</cfquery>
	<cfquery name="BannerAds" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select BA.*,
		PS.Title as PaymentStatus, P.Placement
		From BannerAds BA left join orders o on BA.OrderID = O.OrderID
		Left Join PaymentStatuses PS on O.PaymentStatusID=PS.PaymentStatusID
		Left join BannerADPlacement P on BA.placementID = P.placementID
		Where BA.OrderID = <cfqueryparam value="#PK#" cfsqltype="CF_SQL_INTEGER">
		
	</cfquery>
</cfif>

<script>
	function checkPaidDate(formObj) {
		if(formObj.PaymentStatusID[formObj.PaymentStatusID.selectedIndex].value==2 || formObj.PaymentStatusID[formObj.PaymentStatusID.selectedIndex].value==3) {
			if (!checkText(formObj.elements["PaymentDate"],"Payment Date")) return false;
		}
		return true;
	}	
</script>

<lh:MS_Table table="#OrderTable#" title="#pg_title#">
	<cfif ListFindNoCase("Add,Edit,AddEditDoIt",Action)>
		<lh:MS_TableColumn
			ColName="OrderID"
			DispName="ID"
			type="integer"
			PrimaryKey="true"
			Identity="true" />
			
		<lh:MS_TableColumn
			ColName="OrderDate"
			DispName="Date Purchased"
			ShowDate="Yes" 
			type="Date"
			Required="Yes"
			Editable="No"
			Format="DD/MM/YYYY" />
			
		<!--- <lh:MS_TableColumn
			ColName="UserID2"
			DispName="Business Account"
			type="pseudo"
			Expression="'<a href=""Accounts.cfm?Action=Edit&PK=' + Cast(UserID as varchar(1000)) +'"">' + Cast(UserID as varchar(1000)) + '</a>'"
			ShowOnEdit="true" /> --->
			
		<lh:MS_TableColumn
			ColName="UserID"
			DispName="Business Account"
			type="select"
			FKTable="LH_Users"
			FKDescr="IsNull(Company,UserID)"
			SelectQuery="Select UserID as SelectValue, IsNull(Company,UserID) as SelectText From LH_Users Where AdminUser=0 Order By Company"
			Editable="#AllowAcctAssignment#" />
			
		<lh:MS_TableColumn
			ColName="PreVATTotal"
			DispName="Subtotal"
			type="Integer"
			Format="_$_,___.__"
			Editable="No" />
			
		<lh:MS_TableColumn
			ColName="VAT"
			DispName="VAT (18%)"
			type="Integer"
			Format="_$_,___.__"
			Editable="No" />
			
		<lh:MS_TableColumn
			ColName="OrderTotal"
			DispName="Order Total"
			type="Integer"
			Format="_$_,___.__"
			Editable="No" />
			
		<lh:MS_TableColumn
			ColName="PaymentMethodID"
			DispName="Payment Method"
			type="select"
			FKTable="PaymentMethods"
			FKDescr="Title" />	
			
		<lh:MS_TableColumn
			ColName="CCTypeID"
			DispName="Credit Card Type"
			type="select"
			FKTable="CCTypes"
			FKDescr="Title" />	
			
		<lh:MS_TableColumn
			ColName="CCExpireMonth"
			DispName="Credit Card Expiration Date Month"
			type="select"
			FKTable="CCExpireMonths"
			FKDescr="Title" />	
			
		<lh:MS_TableColumn
			ColName="CCExpireYear"
			DispName="Credit Card Expiration Date Year"
			type="select"
			FKTable="CCExpireYears"
			FKDescr="CCExpireYear" />	
			
		<lh:MS_TableColumn
			ColName="CSV"
			type="text" 
			MaxLength="10" />
			
		<lh:MS_TableColumn
			ColName="PaymentStatusID"
			DispName="Payment Status"
			type="select"
			Required="Yes"
			FKTable="PaymentStatuses"
			FKDescr="Title"
			Validate="checkPaidDate(formObj)" />	
			
		<lh:MS_TableColumn
			ColName="PaymentDate"
			DispName="Date Payment Received"
			ShowDate="Yes" 
			type="Date"
			Format="DD/MM/YYYY" />
			
		<lh:MS_TableColumn
			ColName="PaymentAmount"
			DispName="Amount Received"
			type="Integer"
			Format="_$_,___.__" />
			
		<lh:MS_TableColumn
			ColName="HasListingPackages"
			DispName="Listing Package Purchase"
			type="pseudo"
			Expression="(Case WHEN (Select Count(ListingPackageID) From ListingPackages Where OrderID=Orders.OrderID) > 0 THEN 'Yes' ELSE 'No' END)"
			ShowOnEdit="true"  />	
	<cfelse>
		<lh:MS_TableColumn
			ColName="OrderID"
			DispName="ID"
			type="integer"
			PrimaryKey="true"
			Identity="true" />
			
		<lh:MS_TableColumn
			ColName="OrderDate"
			DispName="Date Purchased"
			ShowDate="Yes" 
			type="Date"
			Required="Yes"
			Editable="No"
			Format="DD/MM/YYYY" />
			
		<lh:MS_TableColumn
			ColName="PaymentStatusID"
			DispName="Payment Status"
			type="select"
			Required="Yes"
			FKTable="PaymentStatuses"
			FKDescr="Title" />	
			
		<lh:MS_TableColumn
			ColName="PaymentMethodID"
			DispName="Payment Method"
			type="select"
			Required="Yes"
			FKTable="PaymentMethods"
			FKDescr="Title" />	
			
		<lh:MS_TableColumn
			ColName="DueDate"
			DispName="Payment Due Date"
			ShowDate="Yes" 
			type="Date"
			Required="Yes"
			Format="DD/MM/YYYY" />
			
		<lh:MS_TableColumn
			ColName="OrderTotal"
			DispName="Order Total"
			type="Integer"
			Format="_$_,___.__" />
			
		<lh:MS_TableColumn
			ColName="UserID"
			DispName="Account Number"
			type="integer" 
			Required="Yes" />
			
		<lh:MS_TableColumn
			ColName="AccountName"
			DispName="Account Name"
			type="text" 
			Required="Yes" />
			
		<lh:MS_TableColumn
			ColName="ContactName"
			DispName="Contact Name"
			type="text" 
			Required="Yes" />
			
		<lh:MS_TableColumn
			ColName="ContactPhone"
			DispName="Contact Phone"
			type="text" 
			Required="Yes" />
			
		<lh:MS_TableColumn
			ColName="ContactEmail"
			DispName="Contact Email"
			type="text" 
			Required="Yes" />	
		
		<cfif Action is "Search">
		<lh:MS_TableColumn 
			colname="HasListingPackages" 
			DispName="Listing Package Purchase"
			type="checkbox" 
			OnValue="'Yes'" 
			Offvalue="'No'"
			DefaultValue="1" />
		<cfelse>
		<lh:MS_TableColumn
			ColName="HasListingPackages"
			DispName="Listing Package Purchase"
			type="pseudo"
			Expression="(Case WHEN (Select Count(ListingPackageID) From ListingPackages Where OrderID=OrdersSearchView.OrderID) > 0 THEN 'Yes' ELSE 'No' END)"
			ShowOnEdit="true"  />	
		</cfif>
			
	</cfif>	
	
	<cfif Request.environment is "Live" or Request.environment is "Devel" or Request.environment is "DB">
		<lh:MS_TableRowAction
			ActionName="Custom"
			Label="Send Payment Reminder Email"
			HREF="javascript:void(0);"
			onClick="sendReminderEmail(##PK##);"
			View="No"/>
			
		<lh:MS_TableRowAction
			ActionName="CustomTwo"
			Type="Custom"
			Label="Resend Order Confirmation Email"
			HREF="javascript:void(0);"
			onClick="sendConfirmationEmail(##PK##);"
			View="No"/>
	</cfif>
	
	<lh:MS_TableEvent
		EventName="OnAfterInsert"
		Include="../../admin/Orders_onAfterInsert.cfm" />
		
	<lh:MS_TableEvent
		EventName="OnAfterUpdate"
		Include="../../admin/Orders_onAfterUpdate.cfm" />

	<lh:MS_TableEvent
		EventName="OnBeforeUpdate"
		Include="../../admin/Orders_onBeforeUpdate.cfm" />
		
</lh:MS_Table>

<!--- <cfif ListFind("Search",Action)>	
	<cfset IncludeCats="1">
	<cfinclude template="includes/GetSubSectionsScript.cfm">	
</cfif> --->

<cfif ListFind("Edit",Action) and IsDefined('pk')>
	<cfif Listings.RecordCount>
		<p><strong>Listings</strong>
		<table border="1" cellspacing="0" cellpadding="3" class="info">
			<tr>
				<th>
					Category
				</th>
				<th>
					Category Listing Type
				</th>
				<th>
					Listing Title
				</th>
				<th>
					Listing Status
				</th>
				<th>
					Review Status
				</th>
				<th>
					Order Details
				</th>
				<th>
					Expires On
				</th>
				<th>
					Fee
				</th>
			</tr>
			<cfoutput query="Listings">
				<tr>
					<cfif ListFind("10,12",ListingTypeID)>
						<cfquery name="getListingCats" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							Select C.Title as Category
							From Categories C inner join ListingCategories LC on C.CategoryID=LC.CategoryID
							Where LC.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
							Order By C.OrderNum
						</cfquery>
						<td>
							#Replace(ValueList(getListingCats.Category),",",", ","All") #				
						</td>
					<cfelse>
						<td>
							#Category#
						</td>
					</cfif>
					<td>
						#ListingType#
					</td>
					<td>
						<a href="Listings.cfm?Action=Edit&PK=#ListingID#">#ListingTitle#&nbsp;</a>
					</td>
					<td>
						<cfif Active is "1">Active<cfelse>Inactive</cfif>
					</td>
					<td>
						<cfif Reviewed is "1">Reviewed<cfelse>Pending</cfif>
					</td>
					<td>
						<cfif Len(ListingRenewalID)>
							This order included the renewal of this listing.<br />
							<cfif Len(RenewalListingPackageID)>
								(Listing Package #RenewalListingPackageID# credit applied.)
							</cfif>
						<cfelseif OrderID is ExpandedListingOrderID and OrderID is PK>
							This order included the listing and its expanded listing.<br />
						<cfelseif OrderID is PK and ExpandedListingOrderID is not PK and Len(ExpandedListingOrderID)>
							This order included only the listing and not this listing's expanded listing.<br />
						<cfelseif OrderID is PK and ExpandedListingOrderID is not PK>
							This order included only the listing. (There is no expanded listing.)<br />
						<cfelseif ExpandedListingOrderID is pK and OrderID is not PK>
							This order included only the expanded listing for this listing.<br />
						</cfif>
						<cfif Len(ListingPackageID) and not Len(ListingRenewalID)>
							(Listing Package #ListingPackageID# credit applied.)
						</cfif>
					</td>
					<td>
						<cfif Len(ExpirationDate)>
							#DateFormat(ExpirationDate,'dd/mm/yyyy')#
						<cfelse>
							#termExpiration# days from date payment received
						</cfif>						
					</td>
					<td>
						#DollarFormat(ListingFee)# <cfif Len(ExpandedListingFee) and ExpandedListingFee>(ELP Fee: #DollarFormat(ExpandedListingFee)#)</cfif>
					</td>
				</tr>
			</cfoutput>
		</table>
	</cfif>
	<cfif ListingPackages.RecordCount>
		<cfoutput>
		<p><strong>This order was for a Listing Package of <cfif ListingPackages.ListingsPaidFor is "1000000">unlimited<cfelse>#ListingPackages.ListingsPaidFor#</cfif> listings that now contains <cfif ListingPackages.RecordCount is "1" and not Len(ListingPackages.ListingID)>no<cfelse>these #ListingPackages.RecordCount#</cfif> listings.</strong>
		</cfoutput>
		<cfif ListingPackages.RecordCount gt "1" or Len(ListingPackages.ListingID)>
			<table border="1" cellspacing="0" cellpadding="3" class="info">
				<tr>
					<th>
						Category
					</th>
					<th>
						Category Listing Type
					</th>
					<th>
						Listing Title
					</th>
					<th>
						Listing Status
					</th>
					<th>
						Review Status
					</th>
					<th>
						Order ID
					</th>
					<th>
						Order Status
					</th>
					<th>
						Expires On
					</th>
				</tr>
				<cfoutput query="ListingPackages">
					<tr>
						<cfif ListFind("10,12",ListingTypeID)>
							<cfquery name="getListingCats" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
								Select C.Title as Category
								From Categories C inner join ListingCategories LC on C.CategoryID=LC.CategoryID
								Where LC.ListingID=<cfqueryparam value="#ListingID#" cfsqltype="CF_SQL_INTEGER">
								Order By C.OrderNum
							</cfquery>
							<td>
								#Replace(ValueList(getListingCats.Category),",",", ","All") #				
							</td>
						<cfelse>
							<td>
								#Category#
							</td>
						</cfif>
						<td>
							#ListingType#
						</td>
						<td>
							<a href="Listings.cfm?Action=Edit&PK=#ListingID#"><cfif Len(Title)>#Title#<cfelse>#VehicleYear# #Make# #MakeTitle# #Model# <cfif Len(ModelTitle)>#ucase(left(ModelTitle, 1))##lcase(right(ModelTitle, Len(ModelTitle) - 1))#</cfif></cfif>&nbsp;</a>
						</td>
						<td>
							<cfif Active is "1">Active<cfelse>Inactive</cfif>
						</td>
						<td>
							<cfif Reviewed is "1">Reviewed<cfelse>Pending</cfif>
						</td>
						<td>
							<a href="Orders.cfm?Action=Edit&PK=#OrderID#">#OrderID#</a>
						</td>
						<td>
							#PaymentStatus#
						</td>
						<td>
							<cfif Len(PaymentDate)>
								<cfif Renewed>#DateFormat(DateAdd('d',TermExpiration*2,PaymentDate),'dd/mm/yyyy')#<cfelse>#DateFormat(DateAdd('d',TermExpiration,PaymentDate),'dd/mm/yyyy')#</cfif>
							<cfelse>
								#termExpiration# days from date payment received
							</cfif>
							
						</td>
					</tr>
				</cfoutput>
			</table>
		</cfif>
	</cfif>
	
	<cfif ListingServices.RecordCount>
		<p><strong>Listing Services</strong>
		<table border="1" cellspacing="0" cellpadding="3" class="info">
			<tr>
				<th>
					Listing Title
				</th>
				<th>
					Service Descr
				</th>
			</tr>
			<cfoutput query="ListingServices">
				<tr>
					<td>
						<a href="Listings.cfm?Action=Edit&PK=#ListingID#">#ListingTitle#&nbsp;</a>
					</td>
					<td>
						<a href="ServiceOrder.cfm?Action=Edit&PK=#ListingServiceID#">#ServiceDescr#</a>
					</td>
				</tr>
			</cfoutput>
		</table>
	</cfif>
	
	<cfif BannerAds.RecordCount>
		<p><strong>Banner Ads</strong>
		<table border="1" cellspacing="0" cellpadding="3" class="info">
			<tr>
				<th>
					Placement
				</th>
				<th>
					Image Name
				</th>
				<th>
					# of Impressions
				</th>
				<th>
					Start
				</th>
				<th>
					End
				</th>
				<th>
					Review Status
				</th>
				<th>
					Order ID
				</th>
				<th>
					Order Status
				</th>
			</tr>
			<cfoutput query="BannerAds">
				<tr>
					<td>
						#Placement#
					</td>
					<td>
						<a href="BannerAds.cfm?action=Edit&pk=#BannerAdID#">#BannerAdImage#</a>
					</td>
					<td>#impressions#</td>
					<td>
						#DateFormat(startDate,'dd/mm/yyyy')#
					</td>
					<td>
						#DateFormat(endDate,'dd/mm/yyyy')#
					</td>
					<td>
						<cfif Reviewed is "1">Reviewed<cfelse>Pending</cfif>
					</td>
					<td>
						<cfif Len(OrderID)>
							<a href="Orders.cfm?Action=Edit&PK=#OrderID#">#OrderID#</a>
						</cfif>
					</td>
					<td>
						#PaymentStatus#
					</td>
					
				</tr>
			</cfoutput>
		</table>
	
	</cfif>
</cfif>


<cfif Action is "Edit">
	<cfquery name="q2" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select O.OrderDate,
		(Select Top 1 UpdateDate From Updates Where OrderID=O.OrderID Order by UpdateDate Desc) as UpdateDate,
		(Select Top 1 IsNull(Us.FirstName,'') + ' ' + IsNull(Us.LastName,'') From Updates Up Left Outer Join LH_Users Us on Up.UpdatedByID=Us.UserID Where OrderID=O.OrderID Order by UpdateDate Desc) as UpdatedBy
		From Orders O
		Where O.OrderID=<cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfquery name="UpdateHistory" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select U.UpdateDate, U.Descr,
		IsNull(Us.FirstName,'') + ' ' + IsNull(Us.LastName,'') as UpdatedBy
		From Updates U 
		Left Outer Join LH_Users Us on U.UpdatedByID=Us.UserID
		Where U.OrderID=<cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">
		Order By U.UpdateDate Desc
	</cfquery>
	<p>
	<cfoutput>Date Added: #DateFormat(q2.OrderDate,'dd/mm/yyyy')# | Last Updated: #DateFormat(q2.UpdateDate,'dd/mm/yyyy')# | Updated By: #q2.UpdatedBy#</cfoutput>
	<cfif UpdateHistory.RecordCount>
		<p><strong>Payment Update History</strong><br>
		<cfoutput query="UpdateHistory">
			#DateFormat(UpdateDate,'dd/mm/yyyy')#: by #UpdatedBy#:<br /> 				
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#Replace(Descr,"|","<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;","ALL")#<br>
		</cfoutput>
		
		
	</cfif>
</cfif>

<cfoutput>
<script language="javascript" type="text/javascript">
	
	function sendReminderEmail(x){
		var datastring = "PK=" + x;
		$.ajax(
           {
			type:"POST",
               url:"#Request.HTTPSURL#/Admin/PaymentReminderEmail.cfc?method=SendEmail&returnformat=plain",
               data:datastring,
               success: function(response)
               {
				alert(response);
               }
           });
	}
	
	function sendConfirmationEmail(x){
		var datastring = "PK=" + x;
		$.ajax(
           {
			type:"POST",
               url:"#Request.HTTPSURL#/Admin/OrderConfirmationEmail.cfc?method=SendEmail&returnformat=plain",
               data:datastring,
               success: function(response)
               {
				alert(response);
               }
           });
	}
	
</script>
</cfoutput>
<cfinclude template="../Lighthouse/Admin/Footer.cfm">