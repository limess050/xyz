
<cfset allFields="CategoryID,StatusMessage,CheckOut">
<cfinclude template="../includes/setVariables.cfm">

<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfset ContentStyle="innercontent-nolines">

<cfinclude template="header.cfm">


<cfif Len(CheckOut)>	
	<cftransaction>	
		<cfquery name="deleteExistingTenderNotificationCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Delete From UserCategories
			Where UserID=<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">	
		</cfquery>
		<cfloop list="#CategoryID#" index="i">		
			<cfquery name="insertTenderNotificationCateogry" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Insert into UserCategories
				(UserID, CategoryID)
				VALUES
				(<cfqueryparam value="#session.UserID#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#i#" cfsqltype="CF_SQL_INTEGER">)				
			</cfquery>		
		</cfloop>		
	</cftransaction>
	<cflocation URL="#lh_getPageLink(7,'myaccount')##AmpOrQuestion#StatusMessage=Tender Notification Categories updated." addToken="No">
	<cfabort>
</cfif>

<cfquery name="getCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select C.CategoryID as SelectValue, C.Title as SelectText
	From Sections S
	Left Outer Join Categories C on S.SectionID=C.SectionID or (C.ParentSectionID=S.SectionID and C.SectionID is null) 
	Where S.Active=1
	and C.Active=1
	and C.ParentSectionID=8
	and S.SectionID = 29
	Order By C.OrderNum
</cfquery>

<cfinclude template="../includes/MyTenderNotificationCategories.cfm">

<script>
	function validateForm(formObj) {	
		<cfif Edit>
			alert('You can not submit this form in the CMS.');
			return false;
		</cfif>		
		return true;
	}
</script>

<!--- <cfoutput>#Request.Page.GetCookieCrumb()#</cfoutput><br>
<cfoutput>#Request.Page.GetSectionName()#</cfoutput> --->

<!--- <lh:MS_SitePagePart id="title" class="title">
<lh:MS_SitePagePart id="body" class="body">

 --->

<cfoutput>
<!-- CENTER COL --><div id="innercontent-widecol">
<h1>My Tender Notifications</h1>
<cfif Len(StatusMessage)>
	<p><strong><em>#StatusMessage#</em></strong>
</cfif>		
<lh:MS_SitePagePart id="body" class="body">
<p>&nbsp;</p>
<form name="f1" action="page.cfm?PageID=#PageID#" method="post" ONSUBMIT="return validateForm(this)">
	<input type="hidden" name="Checkout" value="1">
	<table>
		<tr>
			<td colspan="2">
				<p class="instructions">Check the categories for which you wish to receive notices.</p>
			</td>
		</tr>
		<cfloop query="getCategories">
			<tr>
				<td>
					<input type="checkbox" name="CategoryID" value="#SelectValue#" <cfif ListFind(ValueList(getTenderNotificationCategories.CategoryID),SelectValue)>checked</cfif>>
				</td>
				<td>
					#SelectText#
				</td>
			</tr>
		</cfloop>
		<tr>
			<td colspan="2">
				<input type="submit" name="button" id="button" value="Save Tender Notification Categories" class="btn" />
			</td>
		</tr>
	</table>
 
  <!-- END CENTER COL -->

<!-- RIGHT COL -->
</form>
</cfoutput>
</div>

<!-- END CENTER COL -->

<cfset ShowRightColumn="0">
<cfinclude template="footer.cfm">


