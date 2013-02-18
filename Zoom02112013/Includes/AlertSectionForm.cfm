
<cfset allFields="ConfirmationID,AlertSectionID,CategoryIDs,LocationIDs,PriceMinUS,PriceMaxUS,PriceMinTZS,PriceMaxTZS,NewAlertSectionID">
<cfinclude template="setVariables.cfm">
<cfmodule template="_checkNumbers.cfm" fields="AlertSectionID,NewAlertSectionID">

<cfimport prefix="lh" taglib="../Lighthouse/Tags">

<cfif ListFind("4,39,40,50,55",i)>
	<cfset ShowPriceRanges = "1">
</cfif>
<cfif i is "37">
	<cfset ShowLocations = "0">
</cfif>
<cfif i is "8">
	<cfset LimitSelectionCount = "1">
</cfif>

<cfif Len(ConfirmationID) and not Len(NewAlertSectionID)>
	<cfquery name="AlertSectionCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select CategoryID
		From AlertSectionCategories
		Where AlertSectionID = <cfqueryparam value="#AlertSectionID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfset CategoryIDs = ValueList(AlertSectionCategories.CategoryID)>
	
	<cfif ShowLocations>
		<cfquery name="AlertSectionLocations" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			Select LocationID
			From AlertSectionLocations
			Where AlertSectionID = <cfqueryparam value="#AlertSectionID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset LocationIDs = ValueList(AlertSectionLocations.LocationID)>
	</cfif>
	
	<cfset PriceMinUS = ConfirmAlertSection.PriceMinUS>
	<cfset PriceMaxUS = ConfirmAlertSection.PriceMaxUS>
	<cfset PriceMinTZS = ConfirmAlertSection.PriceMinTZS>
	<cfset PriceMaxTZS = ConfirmAlertSection.PriceMaxTZS>
	
</cfif>

<cfquery name="SectionCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select CategoryID as SelectValue, Title as SelectText
	From Categories
	Where  Active = 1
	and (ParentSectionID = <cfqueryparam value="#i#" cfsqltype="CF_SQL_INTEGER">
		or SectionID = <cfqueryparam value="#i#" cfsqltype="CF_SQL_INTEGER">)
		and (SectionID <> 29 or SectionID is null) <!--- Old J&E Tenders categories --->
	Order by OrderNum
</cfquery>
<script>
	function validateForm(formObj) {		
		if (!checkSelected(formObj.elements["CategoryIDs"],"Categories")) return false;	
		<cfif LimitSelectionCount>
			if ($("#CategoryIDs :selected").length > 6){
				alert('Please select no more than 6 Jobs and Employment categories.');
				$("#CategoryIDs").focus();
				return false; 			
			}
		</cfif>
		<cfif ShowLocations>
			if (!checkSelected(formObj.elements["LocationIDs"],"Areas")) return false;	
		</cfif>
		<cfif ShowPriceRanges>
			if (!checkNumber(formObj.elements["PriceMinUS"],"Min ($US)")) return false;	
			if (!checkNumber(formObj.elements["PriceMaxUS"],"Max ($US)")) return false;	
			if (!checkNumber(formObj.elements["PriceMinTZS"],"Min (TSH)")) return false;	
			if (!checkNumber(formObj.elements["PriceMaxTZS"],"Max (TSH)")) return false;	
			if (checkTextNoWarning(formObj.elements["PriceMinUS"],"Min (US$)") || checkTextNoWarning(formObj.elements["PriceMaxUS"],"Max (US$)") || checkTextNoWarning(formObj.elements["PriceMinTZS"],"Min (TSH)") || checkTextNoWarning(formObj.elements["PriceMaxTZS"],"Max (TSH)")) {
				if (!checkTextAllOrNothing(formObj.elements["PriceMinUS"],"Min ($US)")) return false;									
				if (!checkTextAllOrNothing(formObj.elements["PriceMaxUS"],"Max ($US)")) return false;									
				if (!checkTextAllOrNothing(formObj.elements["PriceMinTZS"],"Min (TSH)")) return false;									
				if (!checkTextAllOrNothing(formObj.elements["PriceMaxTZS"],"Max (TSH)")) return false;									
			}
		</cfif>
		return true;
	}
	
	function checkTextNoWarning (fieldObj, s) {
		if (isWhitespace(fieldObj.value)) return false;
		else return true;
	}
	
	function checkTextAllOrNothing (fieldObj, s) {
		if (isWhitespace(fieldObj.value)) {
			alert('If you enter a value in any of the 4 Price Range fields, you must enter values in all 4 fields.');
			fieldObj.focus();
			return false;			
		}
		else { 
			return true;
		}
	}
				
</script>



<cfoutput>
<form name="f1" action="page.cfm?PageID=<cfif Len(ConfirmationID)>#Request.ManageAlertPageID#<cfelse>#Request.AddAlertPageID#</cfif>" method="post" ONSUBMIT="return validateForm(this)">
	<input type="hidden" name="Step" value="<cfif Len(NewAlertSectionID)>6<cfelseif Len(ConfirmationID)>3<cfelse>2</cfif>">
	<cfif Len(NewAlertSectionID)>
		<input type="hidden" name="NewAlertSectionID" value="#NewAlertSectionID#">
	<cfelse>
		<input type="hidden" name="AlertSectionID" value="<cfif Len(ConfirmationID)>#AlertSectionID#<cfelse>#i#</cfif>">
	</cfif>
	
	<cfif Len(ConfirmationID)>
		<input type="hidden" name="ConfirmationID" value="#ConfirmationID#">
	</cfif>
	<table border="0" cellspacing="0" cellpadding="0" class="datatable">
		<tr>
			<td colspan=2>
				<lh:MS_SitePagePart id="bodySectionData#i#" class="body">
			</td>
		</tr>
		<tr>
			<td class="rightAtd">
				*&nbsp;What kind of <cfloop query="AlertSections"><cfif SelectValue is i>#SelectText#</cfif></cfloop>?<br /><strong>(Choose all that apply)</strong>
					<span class="instructions"><br>To multi-select,hold the "Ctrl" key and click each option desired</span>
			</td>
			<td>
				<select name="CategoryIDs" id="CategoryIDs" multiple size=4 style = "width: 250px">
					<option value = "">-- Select a Category --</option>
					<cfloop query="SectionCategories">
						<option value="#SelectValue#" <cfif Len(ConfirmationID) and ListFind(CategoryIDs,SelectValue)>selected</cfif>>#SelectText#</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<cfif ShowLocations>
			<tr>
				<td class="rightAtd">
					*&nbsp;In which areas?<br /><strong>(Choose all that apply)</strong>
						<span class="instructions"><br>To multi-select, hold the "Ctrl" key and click each option desired</span>
				</td>
				<td>
					<select name="LocationIDs" id="LocationIDs" multiple size=4 style = "width: 250px">
						<option value = "">-- Select an Area --</option>
						<cfloop query="Locations">
							<option value="#SelectValue#" <cfif Len(ConfirmationID) and ListFind(LocationIDs,SelectValue)>selected</cfif>>#SelectText#</option>
						</cfloop>
					</select>
				</td>
			</tr>
		</cfif>
		<cfif ShowPriceRanges>
			<tr>
				<td  colspan=2>
					Price Range <strong>(Optional)</strong>:<br><span class="instructions">Limit alert results by price. You must provide a "Min" & "Max" in <strong>BOTH</strong> $USD and TSH to use this feature.<br><br>
					If you do not provide a price range you will receive <cfloop query="AlertSections"><cfif SelectValue is i>#SelectText#</cfif></cfloop> alerts regardless of price.</span>
				 </td>
			</tr>			
			<tr>
				<td class="rightAtd">
					Min ($US): <input type = "text" name = "PriceMinUS" id = "PriceMinUS" value="<cfif Len(ConfirmationID) and Len(PriceMinUS)>#NumberFormat(PriceMinUS,0)#</cfif>" /> - 
				</td>
				<td>
					Max ($US): <input type = "text" name = "PriceMaxUS" id = "PriceMaxUS" value="<cfif Len(ConfirmationID) and Len(PriceMaxUS)>#NumberFormat(PriceMaxUS,0)#</cfif>"  />
				</td>
			</tr>					
			<tr>
				<td class="rightAtd">
					Min (TSH): <input type = "text" name = "PriceMinTZS" id = "PriceMinTZS" value="<cfif Len(ConfirmationID) and Len(PriceMinTZS)>#NumberFormat(PriceMinTZS,0)#</cfif>"  /> - 
				</td>
				<td>
					Max (TSH): <input type = "text" name = "PriceMaxTZS" id = "PriceMaxTZ" value="<cfif Len(ConfirmationID) and Len(PriceMaxTZS)>#NumberFormat(PriceMaxTZS,0)#</cfif>"  />
				</td>
			</tr>
		</cfif>
		<tr>
				<td>&nbsp;</td>
				<td>
					&nbsp;<br>
					<input type="submit" name="Next" value="Next >>" class="btn">
				</td>
		</tr>
	</table>		
</form>
</cfoutput>