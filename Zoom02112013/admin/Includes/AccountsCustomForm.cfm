<cfparam name="StatusMessage" default="">
<cfparam name="QueryParams" default="">
<cfparam name="pk" Default="0">

<cfquery name="q" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select A.*, A.Blacklist_Fl,
	(Select Count(Al.AlertID) from Alerts Al inner join AlertSections ASe on Al.AlertID=ASe.AlertID Where Al.UserID=A.UserID) as NumAlerts,
	(Select Top 1 U.UpdateDate From Updates U Where U.UserID=A.UserID Order by UpdateDate Desc) as UpdateDate,
	(Select Top 1 IsNull(Us.FirstName,'') + ' ' + IsNull(Us.LastName,'') From Updates Up Left Outer Join LH_Users Us on Up.UpdatedByID=Us.UserID Where Us.UserID=A.UserID Order by UpdateDate Desc) as UpdatedBy
	From LH_Users A
	Where A.UserID=<cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfquery name="getUserTenderNotificationCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select C.CategoryID, C.Title as Category
	From UserCategories UC 
	Inner Join Categories C on UC.CategoryID=C.CategoryID
	Where C.Active=1
	and UC.UserID=<cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">	
	Order By C.OrderNum
</cfquery>

<cfquery name="getTenderNotificationCategories" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select C.CategoryID as SelectValue, C.Title as SelectText
	From Sections S
	Left Outer Join Categories C on S.SectionID=C.SectionID or (C.ParentSectionID=S.SectionID and C.SectionID is null) 
	Where S.Active=1
	and C.Active=1
	and C.ParentSectionID=8
	and S.SectionID = 29
	Order By C.OrderNum
</cfquery>


<cfquery name="Orders" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select O.*,
	PM.Title as PaymentMethod,
	PS.Title as PaymentStatus
	From Orders O
	Left Outer join PaymentMethods PM on O.PaymentMethodID=PM.PaymentMethodID
	Left Outer Join PaymentStatuses PS on O.PaymentStatusID=PS.PaymentStatusID
	Where O.UserID=<cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">
	Order By OrderID 
</cfquery>

<cfquery name="Listings" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select L.*,
	PS.Title as PaymentStatus, O.PaymentDate,
	LP.OrderID as ListingPackageOrderID,
	PS2.Title as ListingPackagePaymentStatus, O2.PaymentDate as ListingPackagePaymentDate,
	(Select Top 1 Title From Categories C2 Inner Join ListingCategories LC2 on C2.CategoryID=LC2.CategoryID Where LC2.ListingID=L.ListingID) as Category,		
	LT.Title as ListingType, LT.TermExpiration,
	M.Title as MakeTitle
	From ListingsView L
	Left Outer Join Orders O on L.OrderID=O.OrderID
	Left Outer Join PaymentStatuses PS on O.PaymentStatusID=PS.PaymentStatusID
	Left Outer Join ListingPackages LP on L.ListingPackageID=LP.ListingPackageID
	Left Outer Join Orders O2 on LP.OrderID=O2.OrderID
	Left Outer Join PaymentStatuses PS2 on O2.PaymentStatusID=PS2.PaymentStatusID
	Left Outer Join ListingTypes LT on L.ListingTypeID=LT.ListingTypeID
	Left Outer Join Makes M on L.MakeID=M.MakeID
	Where L.OrderID in (<cfif Orders.RecordCount><cfqueryparam value="#ValueList(Orders.OrderID)#" cfsqltype="CF_SQL_INTEGER" list="Yes"><cfelse>0</cfif>)
	or L.ExpandedListingOrderID in (<cfif Orders.RecordCount><cfqueryparam value="#ValueList(Orders.OrderID)#" cfsqltype="CF_SQL_INTEGER" list="Yes"><cfelse>0</cfif>)
	or LP.OrderID in (<cfif Orders.RecordCount><cfqueryparam value="#ValueList(Orders.OrderID)#" cfsqltype="CF_SQL_INTEGER" list="Yes"><cfelse>0</cfif>)
	or (L.OrderID IS NULL AND L.InProgress = 0 and L.InProgressUserID=<cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">)
	Order By L.ListingID 
</cfquery>

<cfquery name="BannerAds" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select BA.*,
	PS.Title as PaymentStatus, P.Placement
	From BannerAds BA left join orders o on BA.OrderID = O.OrderID
	Left Join PaymentStatuses PS on O.PaymentStatusID=PS.PaymentStatusID
	Left join BannerADPlacement P on BA.placementID = P.placementID
	Where BA.OrderID in (<cfif Orders.RecordCount><cfqueryparam value="#ValueList(Orders.OrderID)#" cfsqltype="CF_SQL_INTEGER" list="Yes"><cfelse>0</cfif>)
	
</cfquery>

<cfquery name="ListingPackages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select LP.ListingPackageID, LP.OrderID,
	O.PaymentDate, O.PaymentStatusID,
	CASE
	WHEN LP.FiveListing=1 THEN 5
	WHEN LP.TenListing=1 THEN 10
	WHEN LP.TwentyListing=1 THEN 20
	WHEN LP.UnlimitedListing=1 THEN 1000000<!--- Unlimited --->
	END as ListingsPaidFor,
	LP.FiveListing, LP.TenListing, LP.TwentyListing,
	(Select Count(ListingID) From Listings Where ListingPackageID=LP.ListingPackageID) + (Select Count(ListingRenewalID) From ListingRenewals Where ListingPackageID=LP.ListingPackageID) as ListingsInPackage,
	LPT.Title as ListingPackageType, PS.Title as PaymentStatus
	From ListingPackages LP
	Inner Join Orders O on LP.OrderID=O.OrderID
	Inner Join ListingPackageTypes LPT on LP.ListingPackageTypeID=LPT.ListingPackageTypeID
	Inner Join PaymentStatuses PS on O.PaymentStatusID=PS.PaymentStatusID
	and O.UserID=<cfqueryparam value="#PK#" cfsqltype="CF_SQL_INTEGER">
	Order By O.OrderDate desc
</cfquery>	

<cfoutput>
<div id=bodyOfPageDiv>
<h1 style="margin:0px"> Accounts:
	#Action# </h1>

<cfif Len(statusMessage)><p class="STATUSMESSAGE">#StatusMessage#</p></cfif>

<P>

	<TABLE CELLPADDING=1 CELLSPACING=1 BORDER=0 CLASS=ACTIONBUTTONTABLE>
	<TR> <TD CLASS=ACTIONCELL><a href="Accounts.cfm?action=View<cfif Len(QueryParams)>&#QueryParams#</cfif>">View Search Results</a></TD> <TD CLASS=ACTIONCELL><a href="Accounts.cfm?action=View&">View All</a></TD> <TD CLASS=ACTIONCELL><a href="Accounts.cfm?action=Search<cfif Len(QueryParams)>&#QueryParams#</cfif>">Refine Search</a></TD> <TD CLASS=ACTIONCELL><a href="Accounts.cfm?action=Search&">New Search</a></TD> <TD CLASS=ACTIONCELL><a href="Accounts.cfm?action=Add<cfif Len(QueryParams)>&queryParams=#QueryParams#</cfif>">Add</a></TD> </TR>

	</TABLE>

	<TABLE CELLPADDING=1 CELLSPACING=1 BORDER=0 CLASS=ACTIONBUTTONTABLE>
	<TR>
		<TD CLASS=ACTIONCELL><a href="javascript:void(0);" onClick="sendAccountEmail(#pk#);" >Resend Welcome Email</a></TD> 
		<cfif not Len(q.ConfirmedDate)><TD CLASS=ACTIONCELL><a href="AccountMarkConfirmed.cfm?PK=#PK#<cfif IsDefined('QueryParams')>&QueryParams=#URLEncodedFormat(queryParams)#</cfif>">Mark Account Confirmed</a></TD></cfif>
		<TD CLASS=ACTIONCELL><a href="Accounts.cfm?action=Delete&&pk=#pk#<cfif Len(QueryParams)>&queryParams=#QueryParams#</cfif>" >Delete</a></TD> 
		<td class="ACTIONCELL BLBut" <cfif q.Blacklist_fl>style="display:none;"</cfif>><a href="javascript:void(0);" onclick="blacklistAccount(this,#pk#);">Blacklist Account</a></td> 
		<td class="ACTIONCELL UBLBut" <cfif not q.Blacklist_fl>style="display:none;"</cfif>><a href="javascript:void(0);" onclick="unblacklistAccount(this,#pk#);">Un-Blacklist Account</a></td>
	</TR>
	</TABLE>

</P>

<script type="text/javascript">
var monitor;
dojo.require("dojo.json");
function onBeforeUnload(){
	if (monitor.isChanged()) {
		var msg = "Your unsaved changes may be lost.\n\nThe following fields have changed:"
		for (var i=0;i<monitor.ChangedFields.length;i++){
			var f =  monitor.ChangedFields[i];
			msg += "\n - " + f.name;
			
		}
		return msg;
	}
}
dojo.addOnLoad(function(){
	dojo.require("dojo.widget.*");
	dojo.require("dojo.widget.DatePicker");
	dojo.require("dojo.widget.PopupContainer");
	
	//Set up monitor
	monitor = new lh.ChangeMonitor(function(){
		if (monitor.isChanged()){
			if (getEl("SubmitButton1").value != "Save Changes"){
				getEl("SubmitButton1").value = "Save Changes";
				getEl("SubmitButton2").value = "Save Changes";
			}
		} else {
			if (getEl("SubmitButton1").value != "Submit"){
				getEl("SubmitButton1").value = "Submit";
				getEl("SubmitButton2").value = "Submit";
			}
		}
	});
	mainTable.monitorColumns(monitor);
	//Pause to give wysiwyg a chance to load
	window.setTimeout("monitor.start()",2000);
	window.onbeforeunload = onBeforeUnload;

	//Cancel onbeforeunload when mousing over javascript links.  Otherwise IE shows warning.
	var links = document.getElementsByTagName("A");
	for (var i = 0; i < links.length; i++) {
		if (links[i].href.indexOf("javascript:") == 0) {
			xAddEvent(links[i], "mouseover", cancelOnBeforeUnload);
			xAddEvent(links[i], "mouseout", setOnBeforeUnload);
		}
	}
});


var mainTable = lh.addTable({"ACTIONS":{"CreateExcel":{"TARGET":"","LABEL":"CreateExcel","LAYOUT":"","TYPE":"CreateExcel","NAME":"CreateExcel","CONDITIONALPARAM":""},"Add":{"TARGET":"","LABEL":"Add","LAYOUT":"","TYPE":"Add","NAME":"Add","CONDITIONALPARAM":""},"Search":{"TARGET":"","LABEL":"Search","LAYOUT":"","TYPE":"Search","NAME":"Search","CONDITIONALPARAM":""},"View":{"TARGET":"","LABEL":"View","LAYOUT":"","TYPE":"View","NAME":"View","CONDITIONALPARAM":""},"DisplayOptions":{"TARGET":"","LABEL":"DisplayOptions","LAYOUT":"","TYPE":"DisplayOptions","NAME":"DisplayOptions","CONDITIONALPARAM":""}},"ID":"Accounts","EVENTS":{"OnBeforeUpdate":{"INCLUDE":"../../admin/Accounts_onBeforeUpdate.cfm","NAME":"OnBeforeUpdate"},"OnAfterInsert":{"INCLUDE":"../../admin/Accounts_onAfterInsert.cfm","NAME":"OnAfterInsert"}},"CURRENTCOLUMNGROUP":"","RESOURCESDIR":"../../..//DAR/web/Lighthouse/Resources","ROWACTIONS":{"Delete":{"TARGET":"","LABEL":"Delete","LAYOUT":"","TYPE":"Delete","NAME":"Delete","CONDITIONALPARAM":""},"Edit":{"TARGET":"","LABEL":"Edit","LAYOUT":"","TYPE":"Edit","NAME":"Edit","CONDITIONALPARAM":""}},"ALLOWCOLUMNEDIT":false,"DISALLOWEDACTIONS":"","PERSISTENTPARAMS":"","TITLE":"Accounts","ACTION":"Edit","PRIMARYKEY":"UserID","ROWACTIONORDER":["Edit","Delete"],"TABLE":"Accounts","RELATEDTABLES":"","SPECIALCOLUMNS":[],"COLUMNS":{"ContactPhoneLand":{"SEARCHTYPE":"Contains","ALLOWVIEW":true,"PARENTCOLUMN":"","DEFAULTVALUE":"","CLASSNAME":"","ALLOWCOLUMNEDIT":false,"RELATEDTABLES":"","VIEW":false,"VALIDATE":"","MAXLENGTH":"20","UNICODE":false,"ORDER":"4","UNIQUE":false,"CHILDCOLUMN":"","PRIMARYKEY":false,"DEFAULTVIEW":true,"HELPTEXT":"","SHOWTOTAL":false,"ORDERBY":"","FORMFIELDPARAMETERS":"size=20","IDENTITY":false,"STYLEID":false,"EDITABLE":true,"CFSQLTYPE":"CF_SQL_VARCHAR","TYPE":"text","SEARCH":true,"HIDDEN":false,"FORMAT":"","DISPNAME":"Phone (landline)","NAME":"ContactPhoneLand","SPELLCHECK":false,"COLUMNGROUP":"Contact","ALLOWHTML":false,"REQUIRED":false},"AltContactFirstName":{"ALLOWVIEW":true,"ALLOWCOLUMNEDIT":false,"TYPE":"text","NAME":"AltContactFirstName","DEFAULTVALUE":"","PRIMARYKEY":false,"SEARCH":true,"HIDDEN":false,"DEFAULTVIEW":true,"STYLEID":false,"ALLOWHTML":false,"FORMAT":"","CLASSNAME":"","SEARCHTYPE":"Contains","REQUIRED":false,"COLUMNGROUP":"AltContact","VALIDATE":"","UNIQUE":false,"CFSQLTYPE":"CF_SQL_VARCHAR","MAXLENGTH":"200","IDENTITY":false,"SPELLCHECK":false,"EDITABLE":true,"DISPNAME":"First Name","FORMFIELDPARAMETERS":"size=40","HELPTEXT":"","CHILDCOLUMN":"","ORDERBY":"","VIEW":false,"ORDER":"9","UNICODE":false,"RELATEDTABLES":"","SHOWTOTAL":false,"PARENTCOLUMN":""},"ContactOutsidePhone":{"VALIDATE":"","ORDERBY":"","DEFAULTVIEW":true,"NAME":"ContactOutsidePhone","DEFAULTVALUE":"","ALLOWHTML":false,"ORDER":"7","CHILDCOLUMN":"","SEARCH":true,"SEARCHTYPE":"Contains","VIEW":false,"SHOWTOTAL":false,"ALLOWCOLUMNEDIT":false,"CFSQLTYPE":"CF_SQL_VARCHAR","RELATEDTABLES":"","PRIMARYKEY":false,"DISPNAME":"Phone (outside TZ)","REQUIRED":false,"TYPE":"text","SPELLCHECK":false,"MAXLENGTH":"20","FORMAT":"","COLUMNGROUP":"Contact","STYLEID":false,"IDENTITY":false,"FORMFIELDPARAMETERS":"size=20","UNICODE":false,"EDITABLE":true,"HELPTEXT":"","PARENTCOLUMN":"","HIDDEN":false,"ALLOWVIEW":true,"UNIQUE":false,"CLASSNAME":""},"Title":{"REQUIRED":"Yes","CLASSNAME":"","EDITABLE":true,"STYLEID":false,"COLUMNGROUP":"","NAME":"Title","ORDER":"1","UNIQUE":"Yes","SEARCHTYPE":"Contains","TYPE":"text","FORMAT":"","HELPTEXT":"","UNICODE":false,"DEFAULTVALUE":"","VALIDATE":"","VIEW":false,"PRIMARYKEY":false,"ALLOWVIEW":true,"MAXLENGTH":"200","ALLOWHTML":false,"DISPNAME":"Account Name","DEFAULTVIEW":true,"CFSQLTYPE":"CF_SQL_VARCHAR","SHOWTOTAL":false,"SPELLCHECK":false,"SEARCH":true,"ALLOWCOLUMNEDIT":false,"PARENTCOLUMN":"","FORMFIELDPARAMETERS":"size=40","IDENTITY":false,"ORDERBY":"","RELATEDTABLES":"","HIDDEN":false,"CHILDCOLUMN":""},"ContactLastName":{"HELPTEXT":"","ORDERBY":"","PARENTCOLUMN":"","SEARCH":true,"MAXLENGTH":"200","DISPNAME":"Last Name","REQUIRED":"Yes","STYLEID":false,"CLASSNAME":"","COLUMNGROUP":"Contact","VIEW":false,"ALLOWCOLUMNEDIT":false,"NAME":"ContactLastName","ALLOWHTML":false,"SHOWTOTAL":false,"PRIMARYKEY":false,"FORMAT":"","DEFAULTVIEW":true,"UNIQUE":false,"ORDER":"3","ALLOWVIEW":true,"SPELLCHECK":false,"CFSQLTYPE":"CF_SQL_VARCHAR","FORMFIELDPARAMETERS":"size=40","RELATEDTABLES":"","VALIDATE":"","UNICODE":false,"DEFAULTVALUE":"","EDITABLE":true,"TYPE":"text","IDENTITY":false,"HIDDEN":false,"CHILDCOLUMN":"","SEARCHTYPE":"Contains"},"AltContactEmail":{"DEFAULTVIEW":true,"PARENTCOLUMN":"","TYPE":"text","SEARCHTYPE":"Contains","PRIMARYKEY":false,"ORDER":"15","DEFAULTVALUE":"","SEARCH":true,"ALLOWHTML":false,"COLUMNGROUP":"AltContact","CLASSNAME":"","IDENTITY":false,"HELPTEXT":"","CHILDCOLUMN":"","VALIDATE":"checkAltEmail()","SPELLCHECK":false,"FORMFIELDPARAMETERS":"size=40","STYLEID":false,"DISPNAME":"Email","ALLOWCOLUMNEDIT":false,"EDITABLE":true,"HIDDEN":false,"SHOWTOTAL":false,"MAXLENGTH":"200","NAME":"AltContactEmail","UNIQUE":false,"FORMAT":"","UNICODE":false,"CFSQLTYPE":"CF_SQL_VARCHAR","ORDERBY":"","RELATEDTABLES":"","ALLOWVIEW":true,"REQUIRED":false,"VIEW":false},"UserID":{"PARENTCOLUMN":"","TYPE":"integer","CFSQLTYPE":"CF_SQL_FLOAT","DISPNAME":"ID","HELPTEXT":"","VALIDATE":"","MAXLENGTH":"","SPELLCHECK":false,"ALLOWVIEW":true,"RELATEDTABLES":"","FORMFIELDPARAMETERS":"","HIDDEN":false,"SHOWTOTAL":false,"DEFAULTVIEW":true,"UNIQUE":false,"ALLOWHTML":false,"DEFAULTVALUE":"","REQUIRED":true,"SEARCHTYPE":"Contains","SEARCH":true,"IDENTITY":true,"EDITABLE":true,"FORMAT":"","VIEW":false,"NAME":"UserID","COLUMNGROUP":"","PRIMARYKEY":true,"ALLOWCOLUMNEDIT":false,"CLASSNAME":"","ORDERBY":"","ORDER":"0","STYLEID":false,"CHILDCOLUMN":""},"ContactEmail":{"FORMFIELDPARAMETERS":"size=40","REQUIRED":"Yes","SHOWTOTAL":false,"UNIQUE":false,"CLASSNAME":"","NAME":"ContactEmail","RELATEDTABLES":"","CHILDCOLUMN":"","CFSQLTYPE":"CF_SQL_VARCHAR","EDITABLE":true,"PARENTCOLUMN":"","ALLOWHTML":false,"FORMAT":"","ORDERBY":"","TYPE":"text","ORDER":"8","SEARCHTYPE":"Contains","HELPTEXT":"","DEFAULTVIEW":true,"ALLOWCOLUMNEDIT":false,"MAXLENGTH":"200","DISPNAME":"Email","VALIDATE":"checkPrimaryEmail()","SPELLCHECK":false,"UNICODE":false,"STYLEID":false,"PRIMARYKEY":false,"ALLOWVIEW":true,"IDENTITY":false,"SEARCH":true,"COLUMNGROUP":"Contact","DEFAULTVALUE":"","HIDDEN":false,"VIEW":false},"ContactPhoneMobile":{"RELATEDTABLES":"","FORMAT":"","ALLOWVIEW":true,"REQUIRED":false,"ALLOWCOLUMNEDIT":false,"HELPTEXT":"","ALLOWHTML":false,"MAXLENGTH":"20","FORMFIELDPARAMETERS":"size=20","TYPE":"text","COLUMNGROUP":"Contact","PARENTCOLUMN":"","DEFAULTVIEW":true,"PRIMARYKEY":false,"IDENTITY":false,"NAME":"ContactPhoneMobile","SEARCHTYPE":"Contains","CLASSNAME":"","UNIQUE":false,"ORDERBY":"","ORDER":"5","DEFAULTVALUE":"","HIDDEN":false,"CHILDCOLUMN":"","VIEW":false,"CFSQLTYPE":"CF_SQL_VARCHAR","VALIDATE":"","STYLEID":false,"DISPNAME":"Phone (mobile)","EDITABLE":true,"SPELLCHECK":false,"SHOWTOTAL":false,"UNICODE":false,"SEARCH":true},"AltContactPhoneLand":{"MAXLENGTH":"20","SEARCHTYPE":"Contains","PRIMARYKEY":false,"DISPNAME":"Phone (landline)","HIDDEN":false,"FORMFIELDPARAMETERS":"size=20","IDENTITY":false,"STYLEID":false,"CLASSNAME":"","ORDER":"11","NAME":"AltContactPhoneLand","PARENTCOLUMN":"","UNIQUE":false,"ALLOWCOLUMNEDIT":false,"FORMAT":"","DEFAULTVIEW":true,"VIEW":false,"ALLOWVIEW":true,"VALIDATE":"","ALLOWHTML":false,"EDITABLE":true,"COLUMNGROUP":"AltContact","REQUIRED":false,"TYPE":"text","SEARCH":true,"HELPTEXT":"","CHILDCOLUMN":"","ORDERBY":"","SPELLCHECK":false,"CFSQLTYPE":"CF_SQL_VARCHAR","DEFAULTVALUE":"","SHOWTOTAL":false,"UNICODE":false,"RELATEDTABLES":""},"AltContactLastName":{"TYPE":"text","ALLOWCOLUMNEDIT":false,"ORDER":"10","RELATEDTABLES":"","FORMFIELDPARAMETERS":"size=40","ORDERBY":"","COLUMNGROUP":"AltContact","UNICODE":false,"NAME":"AltContactLastName","SEARCH":true,"MAXLENGTH":"200","UNIQUE":false,"DISPNAME":"Last Name","CFSQLTYPE":"CF_SQL_VARCHAR","CHILDCOLUMN":"","PRIMARYKEY":false,"FORMAT":"","EDITABLE":true,"SEARCHTYPE":"Contains","DEFAULTVIEW":true,"STYLEID":false,"REQUIRED":false,"VIEW":false,"CLASSNAME":"","ALLOWVIEW":true,"ALLOWHTML":false,"IDENTITY":false,"PARENTCOLUMN":"","HIDDEN":false,"HELPTEXT":"","DEFAULTVALUE":"","SHOWTOTAL":false,"VALIDATE":"","SPELLCHECK":false},"Password":{"DEFAULTVIEW":true,"ALLOWHTML":false,"REQUIRED":"Yes","VALIDATE":"","SEARCH":true,"DISPNAME":"Password","CHILDCOLUMN":"","HELPTEXT":"","MAXLENGTH":"20","STYLEID":false,"ALLOWVIEW":true,"COLUMNGROUP":"","ORDER":"16","EDITABLE":true,"CFSQLTYPE":"CF_SQL_VARCHAR","ALLOWCOLUMNEDIT":false,"ORDERBY":"","SHOWTOTAL":false,"RELATEDTABLES":"","IDENTITY":false,"DEFAULTVALUE":"","SEARCHTYPE":"Contains","TYPE":"text","VIEW":false,"PRIMARYKEY":false,"NAME":"Password","UNIQUE":"Yes","PARENTCOLUMN":"","HIDDEN":false,"CLASSNAME":"","UNICODE":false,"SPELLCHECK":false,"FORMFIELDPARAMETERS":"size=20","FORMAT":""},"ContactOutsidePhoneCountryCode":{"EDITABLE":true,"REQUIRED":false,"SEARCHTYPE":"Contains","UNIQUE":false,"HIDDEN":false,"ALLOWVIEW":true,"STYLEID":false,"SHOWTOTAL":false,"MAXLENGTH":"20","ORDERBY":"","VALIDATE":"","PARENTCOLUMN":"","SEARCH":true,"RELATEDTABLES":"","COLUMNGROUP":"Contact","PRIMARYKEY":false,"HELPTEXT":"","FORMFIELDPARAMETERS":"Size=\'4\'","CFSQLTYPE":"CF_SQL_VARCHAR","NAME":"ContactOutsidePhoneCountryCode","IDENTITY":false,"ALLOWCOLUMNEDIT":false,"VIEW":false,"CHILDCOLUMN":"","FORMAT":"","SPELLCHECK":false,"ORDER":"6","UNICODE":false,"TYPE":"text","DEFAULTVIEW":true,"DISPNAME":"Phone (outside TZ) Country Code","CLASSNAME":"","ALLOWHTML":false,"DEFAULTVALUE":""},"ContactFirstName":{"CHILDCOLUMN":"","ORDERBY":"","HIDDEN":false,"SEARCHTYPE":"Contains","CFSQLTYPE":"CF_SQL_VARCHAR","FORMAT":"","HELPTEXT":"","SEARCH":true,"RELATEDTABLES":"","IDENTITY":false,"DEFAULTVIEW":true,"SHOWTOTAL":false,"MAXLENGTH":"200","UNIQUE":false,"UNICODE":false,"ORDER":"2","REQUIRED":"Yes","VALIDATE":"","PARENTCOLUMN":"","COLUMNGROUP":"Contact","DISPNAME":"First Name","PRIMARYKEY":false,"FORMFIELDPARAMETERS":"size=40","ALLOWCOLUMNEDIT":false,"ALLOWVIEW":true,"TYPE":"text","EDITABLE":true,"DEFAULTVALUE":"","VIEW":false,"ALLOWHTML":false,"NAME":"ContactFirstName","CLASSNAME":"","SPELLCHECK":false,"STYLEID":false},"AltContactPhoneMobile":{"HIDDEN":false,"PARENTCOLUMN":"","DEFAULTVALUE":"","DISPNAME":"Phone (mobile)","ORDER":"12","ALLOWHTML":false,"STYLEID":false,"HELPTEXT":"","VALIDATE":"","RELATEDTABLES":"","ORDERBY":"","COLUMNGROUP":"AltContact","SHOWTOTAL":false,"MAXLENGTH":"20","EDITABLE":true,"FORMAT":"","UNIQUE":false,"IDENTITY":false,"CFSQLTYPE":"CF_SQL_VARCHAR","SEARCHTYPE":"Contains","DEFAULTVIEW":true,"PRIMARYKEY":false,"UNICODE":false,"NAME":"AltContactPhoneMobile","TYPE":"text","SPELLCHECK":false,"SEARCH":true,"VIEW":false,"CHILDCOLUMN":"","FORMFIELDPARAMETERS":"size=20","CLASSNAME":"","ALLOWVIEW":true,"REQUIRED":false,"ALLOWCOLUMNEDIT":false},"AltContactOutsidePhoneCountryCode":{"MAXLENGTH":"20","VALIDATE":"","ORDERBY":"","FORMFIELDPARAMETERS":"Size=\'4\'","IDENTITY":false,"DEFAULTVALUE":"","PARENTCOLUMN":"","FORMAT":"","NAME":"AltContactOutsidePhoneCountryCode","CFSQLTYPE":"CF_SQL_VARCHAR","UNIQUE":false,"SPELLCHECK":false,"VIEW":false,"EDITABLE":true,"SEARCHTYPE":"Contains","SHOWTOTAL":false,"REQUIRED":false,"STYLEID":false,"ALLOWVIEW":true,"ALLOWCOLUMNEDIT":false,"HIDDEN":false,"ORDER":"13","HELPTEXT":"","RELATEDTABLES":"","ALLOWHTML":false,"DEFAULTVIEW":true,"COLUMNGROUP":"AltContact","UNICODE":false,"TYPE":"text","CLASSNAME":"","SEARCH":true,"CHILDCOLUMN":"","PRIMARYKEY":false,"DISPNAME":"Phone (outside TZ) Country Code"},"AltContactOutsidePhone":{"DISPNAME":"Phone (outside TZ)","CFSQLTYPE":"CF_SQL_VARCHAR","ORDER":"14","IDENTITY":false,"UNIQUE":false,"PRIMARYKEY":false,"ALLOWCOLUMNEDIT":false,"HIDDEN":false,"FORMFIELDPARAMETERS":"size=20","SPELLCHECK":false,"SEARCHTYPE":"Contains","SHOWTOTAL":false,"FORMAT":"","CLASSNAME":"","STYLEID":false,"RELATEDTABLES":"","ORDERBY":"","ALLOWHTML":false,"HELPTEXT":"","PARENTCOLUMN":"","DEFAULTVIEW":true,"ALLOWVIEW":true,"VIEW":false,"CHILDCOLUMN":"","MAXLENGTH":"20","NAME":"AltContactOutsidePhone","DEFAULTVALUE":"","TYPE":"text","REQUIRED":false,"SEARCH":true,"VALIDATE":"","EDITABLE":true,"UNICODE":false,"COLUMNGROUP":"AltContact"}},"ALLOWEDACTIONS":"View,Search,Add,Edit,Delete,DisplayOptions,CreateExcel","NAME":"Accounts","EDITABLE":true,"COLUMNGROUPS":{"AltContact":{"LABEL":"Secondary Contact","NAME":"AltContact"},"Contact":{"NAME":"Contact","LABEL":"Primary Contact"}},"DEFAULTACTION":"View","IDTABLE":"MS_TableIDs","WHERECLAUSE":"","LAYOUT":"../Tags/MS_TableDefaultTemplate.cfm","COLUMNORDER":["UserID","Title","ContactFirstName","ContactLastName","ContactPhoneLand","ContactPhoneMobile","ContactOutsidePhoneCountryCode","ContactOutsidePhone","ContactEmail","AltContactFirstName","AltContactLastName","AltContactPhoneLand","AltContactPhoneMobile","AltContactOutsidePhoneCountryCode","AltContactOutsidePhone","AltContactEmail","Password"],"ACTIONORDER":["View","Search","Add","DisplayOptions","CreateExcel"]});
mainTable.addRow();

function validateForm(formObj) {
	window.onbeforeunload = null;
	
						if (!checkText(formObj.elements["Title"],"Account Name")) return false;
					
						if (!checkText(formObj.elements["ContactFirstName"],"First Name")) return false;
					
						if (!checkText(formObj.elements["ContactLastName"],"Last Name")) return false;
					
						if (!checkText(formObj.elements["ContactEmail"],"Email")) return false;
					
				if (!checkPrimaryEmail()) return false;
			
				if (!checkAltEmail()) return false;
			
						if (!checkText(formObj.elements["Password"],"Password")) return false;
					
	return true;
}
function checkFile (formObj,colName,s) {
	var uploadFieldObj = formObj.elements[colName];
	if (isWhitespace(uploadFieldObj.value)) {
		if (formObj.elements[colName + "_OldFile"]) {
			var oldfileFieldObj = formObj.elements[colName + "_OldFile"];
			var deleteCheckbox = formObj.elements[colName + "_Delete"];
			if (isWhitespace(oldfileFieldObj.value) || deleteCheckbox.checked) {
				return warnEmpty (uploadFieldObj, s);
			} else {
				return true;
			}
		}
		return warnEmpty (uploadFieldObj, s);
	}
	return true;
}



var spellCheckFieldsArray = new Array();

</script>
<FORM ACTION="Accounts.cfm?action=SpellCheck" METHOD="POST" NAME="SpellCheckForm" TARGET="SpellCheck">
<INPUT TYPE="HIDDEN" NAME="string">
<INPUT TYPE="HIDDEN" NAME="fieldObj">
</FORM>

<FORM ACTION="Accounts.cfm?action=AddEditDoit&" METHOD="POST" NAME="f1" ONSUBMIT="return validateForm(this)" ENCTYPE="multipart/form-data">
<INPUT TYPE="HIDDEN" NAME="pk" ID="pk" VALUE="#pk#">
<INPUT TYPE="HIDDEN" NAME="queryParams" VALUE="#QueryParams#"> 

	<TABLE CLASS=ADDTABLE CELLPADDING=5 CELLSPACING=0>
	
		<TR ID="AddEditFormTopButtons">
			<TD CLASS=SMALLTEXT>* Required Field</TD>
			<TD CLASS=SMALLTEXT ALIGN=RIGHT>

				
				<INPUT TYPE="SUBMIT" id="SubmitButton1" VALUE="Submit" class=button>
				
				<INPUT TYPE="RESET" VALUE="Reset Form" class=button>
			</TD>
		</TR>	

		<cfif Pk neq "0">
			<TR CLASS=ADDROW ID="UserID_TR">
				<TD CLASS=ADDLABELCELL>
					*&nbsp;<label for="UserID">ID:</label>
				</TD>
				<TD CLASS=ADDFIELDCELL>
					#pk#
				</TD>
			</TR>
		</cfif>
			
			<TR CLASS=ADDROW ID="Title_TR">
				<TD CLASS=ADDLABELCELL>
					*&nbsp;<label for="Title">Account Name:</label>

				</TD>
				<TD CLASS=ADDFIELDCELL>
					<input type="hidden" name="Title_isEditable" value="true"> 
			<INPUT TYPE="TEXT" NAME="Company" ID="Company" MAXLENGTH="200" VALUE="#q.Company#" size=40>
			
				</TD>
			</TR>
		
					<tbody class="columngroup" id="Contact_Group">
					<tr class="columngroup"><td colspan=2><h2>Primary Contact</h2></td></tr>

					

			
			<TR CLASS=ADDROW ID="ContactFirstName_TR">
				<TD CLASS=ADDLABELCELL>
					*&nbsp;<label for="ContactFirstName">First Name:</label>

				</TD>
				<TD CLASS=ADDFIELDCELL>
					<input type="hidden" name="ContactFirstName_isEditable" value="true"> 
			<INPUT TYPE="TEXT" NAME="ContactFirstName" ID="ContactFirstName" MAXLENGTH="200" VALUE="#q.ContactFirstName#" size=40>
			
				</TD>

			</TR>
		

			
			<TR CLASS=ADDROW ID="ContactLastName_TR">
				<TD CLASS=ADDLABELCELL>
					*&nbsp;<label for="ContactLastName">Last Name:</label>

				</TD>
				<TD CLASS=ADDFIELDCELL>
					<input type="hidden" name="ContactLastName_isEditable" value="true"> 
			<INPUT TYPE="TEXT" NAME="ContactLastName" ID="ContactLastName" MAXLENGTH="200" VALUE="#q.ContactLastName#" size=40>

			
				</TD>
			</TR>
		

			
			<TR CLASS=ADDROW ID="ContactPhoneLand_TR">
				<TD CLASS=ADDLABELCELL>
					<label for="ContactPhoneLand">Phone (landline):</label>

				</TD>
				<TD CLASS=ADDFIELDCELL>
					<input type="hidden" name="ContactPhoneLand_isEditable" value="true"> 
			<INPUT TYPE="TEXT" NAME="ContactPhoneLand" ID="ContactPhoneLand" MAXLENGTH="20" VALUE="#q.ContactPhoneLand#" size=20>

			
				</TD>
			</TR>
		

			
			<TR CLASS=ADDROW ID="ContactPhoneMobile_TR">
				<TD CLASS=ADDLABELCELL>
					<label for="ContactPhoneMobile">Phone (mobile):</label>

				</TD>
				<TD CLASS=ADDFIELDCELL>
					<input type="hidden" name="ContactPhoneMobile_isEditable" value="true"> 
			<INPUT TYPE="TEXT" NAME="ContactPhoneMobile" ID="ContactPhoneMobile" MAXLENGTH="20" VALUE="#q.ContactPhoneMobile#" size=20>

			
				</TD>
			</TR>
					
			<TR CLASS=ADDROW ID="ContactOutsidePhone_TR">
				<TD CLASS=ADDLABELCELL>
					<label for="ContactOutsidePhone">Phone (outside TZ):</label>

				</TD>
				<TD CLASS=ADDFIELDCELL>
				<input type="hidden" name="ContactOutsidePhoneCountryCode_isEditable" value="true"> 
			<INPUT TYPE="TEXT" NAME="ContactOutsidePhoneCountryCode" ID="ContactOutsidePhoneCountryCode" MAXLENGTH="20" VALUE="#q.ContactOutsidePhoneCountryCode#" Size='4'>
					<input type="hidden" name="ContactOutsidePhone_isEditable" value="true"> 
			<INPUT TYPE="TEXT" NAME="ContactOutsidePhone" ID="ContactOutsidePhone" MAXLENGTH="20" VALUE="#q.ContactOutsidePhone#" size=20>

			
				</TD>
			</TR>
		

			
			<TR CLASS=ADDROW ID="ContactEmail_TR">
				<TD CLASS=ADDLABELCELL>
					*&nbsp;<label for="ContactEmail">Email:</label>

				</TD>
				<TD CLASS=ADDFIELDCELL>

					<input type="hidden" name="ContactEmail_isEditable" value="true"> 
			<INPUT TYPE="TEXT" NAME="ContactEmail" ID="ContactEmail" MAXLENGTH="200" VALUE="#q.ContactEmail#" size=40>
			
				</TD>
			</TR>
		
					</tbody>
					
					<tbody class="columngroup" id="AltContact_Group">
					<tr class="columngroup"><td colspan=2><h2>Secondary Contact</h2></td></tr>
					

			
			<TR CLASS=ADDROW ID="AltContactFirstName_TR">
				<TD CLASS=ADDLABELCELL>

					<label for="AltContactFirstName">First Name:</label>

				</TD>
				<TD CLASS=ADDFIELDCELL>
					<input type="hidden" name="AltContactFirstName_isEditable" value="true"> 
			<INPUT TYPE="TEXT" NAME="AltContactFirstName" ID="AltContactFirstName" MAXLENGTH="200" VALUE="#q.AltContactFirstName#" size=40>
			
				</TD>
			</TR>
		

			
			<TR CLASS=ADDROW ID="AltContactLastName_TR">

				<TD CLASS=ADDLABELCELL>
					<label for="AltContactLastName">Last Name:</label>

				</TD>
				<TD CLASS=ADDFIELDCELL>
					<input type="hidden" name="AltContactLastName_isEditable" value="true"> 
			<INPUT TYPE="TEXT" NAME="AltContactLastName" ID="AltContactLastName" MAXLENGTH="200" VALUE="#q.AltContactLastName#" size=40>
			
				</TD>
			</TR>

		

			
			<TR CLASS=ADDROW ID="AltContactPhoneLand_TR">
				<TD CLASS=ADDLABELCELL>
					<label for="AltContactPhoneLand">Phone (landline):</label>

				</TD>
				<TD CLASS=ADDFIELDCELL>
					<input type="hidden" name="AltContactPhoneLand_isEditable" value="true"> 
			<INPUT TYPE="TEXT" NAME="AltContactPhoneLand" ID="AltContactPhoneLand" MAXLENGTH="20" VALUE="#q.AltContactPhoneLand#" size=20>
			
				</TD>

			</TR>
		

			
			<TR CLASS=ADDROW ID="AltContactPhoneMobile_TR">
				<TD CLASS=ADDLABELCELL>
					<label for="AltContactPhoneMobile">Phone (mobile):</label>

				</TD>
				<TD CLASS=ADDFIELDCELL>
					<input type="hidden" name="AltContactPhoneMobile_isEditable" value="true"> 
			<INPUT TYPE="TEXT" NAME="AltContactPhoneMobile" ID="AltContactPhoneMobile" MAXLENGTH="20" VALUE="#q.AltContactPhoneMobile#" size=20>

			
				</TD>
			</TR>
		
			
			<TR CLASS=ADDROW ID="AltContactOutsidePhone_TR">
				<TD CLASS=ADDLABELCELL>
					<label for="AltContactOutsidePhone">Phone (outside TZ):</label>

				</TD>
				<TD CLASS=ADDFIELDCELL>
					<input type="hidden" name="AltContactOutsidePhoneCountryCode_isEditable" value="true"> 
			<INPUT TYPE="TEXT" NAME="AltContactOutsidePhoneCountryCode" ID="AltContactOutsidePhoneCountryCode" MAXLENGTH="20" VALUE="#q.AltContactOutsidePhoneCountryCode#" Size='4'>
					<input type="hidden" name="AltContactOutsidePhone_isEditable" value="true"> 
			<INPUT TYPE="TEXT" NAME="AltContactOutsidePhone" ID="AltContactOutsidePhone" MAXLENGTH="20" VALUE="#q.AltContactOutsidePhone#" size=20>

			
				</TD>
			</TR>
		

			
			<TR CLASS=ADDROW ID="AltContactEmail_TR">
				<TD CLASS=ADDLABELCELL>
					<label for="AltContactEmail">Email:</label>

				</TD>
				<TD CLASS=ADDFIELDCELL>
					<input type="hidden" name="AltContactEmail_isEditable" value="true"> 
			<INPUT TYPE="TEXT" NAME="AltContactEmail" ID="AltContactEmail" MAXLENGTH="200" VALUE="#q.AltContactEmail#" size=40>

			
				</TD>
			</TR>
		
					</tbody>
					

			
			<TR CLASS=ADDROW ID="Password_TR">
				<TD CLASS=ADDLABELCELL>
					*&nbsp;<label for="Password">Password:</label>

				</TD>

				<TD CLASS=ADDFIELDCELL>
					<input type="hidden" name="Password_isEditable" value="true"> 
			<INPUT TYPE="TEXT" NAME="Password" ID="Password" MAXLENGTH="20" VALUE="#q.Password#" size=20>
			
				</TD>
			</TR>
			
			<TR CLASS=ADDROW ID="Active_TR">
				<TD CLASS=ADDLABELCELL>
					<label for="Active">Active:</label>
 
				</TD>
				<TD CLASS=ADDFIELDCELL>
					<input type="hidden" name="Active_isEditable" value="true"> 

			<INPUT TYPE="Checkbox" NAME="Active" ID="Active" VALUE="1" <cfif q.Active is "1">checked</cfif>>
			
				</TD>
			</TR>
			
			<!--- <tr class="ADDROW" id="Blacklist_Fl_TR">
				<td class="ADDLABELCELL">
					<label for="Blacklist_Fl">Blacklist_Fl:</label>

				</td>
				<td class="ADDFIELDCELL">
					<input name="Blacklist_Fl_isEditable" value="true" type="hidden"> 
			<input name="Blacklist_Fl" id="Blacklist_Fl" value="1" type="Checkbox">			
				</td>
			</tr> --->
			
			<TR CLASS=ADDROW ID="ConfirmedDate_TR">
				<TD CLASS=ADDLABELCELL>
					<label for="ConfirmedDate">Date Confirmed:</label>
 
				</TD>
				<TD CLASS=ADDFIELDCELL>
					<input type="hidden" name="ConfirmedDate_isEditable" value="false"> 

					<INPUT TYPE="hidden" NAME="ConfirmedDate" ID="ConfirmedDate" VALUE="#q.ConfirmedDate#" >
					#q.ConfirmedDate#
				</TD>
			</TR>
			<TR CLASS=ADDROW ID="NumAlerts_TR">
				<TD CLASS=ADDLABELCELL>
					<label for="NumAlerts">Number of Alerts:</label>

				</TD>
				<TD CLASS=ADDFIELDCELL>
					
					<input type="hidden" name="NumAlerts_isEditable" value="false">
					
					<input type="hidden" name="NumAlerts" value="#q.NumAlerts#">
					#q.NumAlerts#
				</TD>
			</TR>
			
		<TR CLASS=ADDROW ID="CategoryID_TR">
				<TD CLASS=ADDLABELCELL>
					*&nbsp;<label for="CategoryID">Tender Notification Categories:</label>
				</TD>

				<TD CLASS=ADDFIELDCELL>
					<input type="hidden" name="CategoryID_isEditable" value="true"> 
			<TABLE CLASS=ADDTABLE>
			
					<TR><TD CLASS=NORMALTEXT>
						<a href="javascript:setChecked(document.f1,true,'CategoryID_[0-9]+')">Check All</a> | <a href="javascript:setChecked(document.f1,false,'CategoryID_[0-9]+')">Check None</a>
					</TD></TR>
					<cfloop query="getTenderNotificationCategories">
						<tr>
							<td>
								<INPUT TYPE="CHECKBOX" ID="CategoryID_#CurrentRow#" NAME="CategoryID" VALUE="#SelectValue#" <cfif ListFind(ValueList(getUserTenderNotificationCategories.CategoryID),SelectValue)>checked</cfif>><label for="CategoryID_#CurrentRow#">#SelectText#</label>
							</td>
						</tr>
					</cfloop>
					<!--- <TR>

					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_1" NAME="CategoryID" VALUE="374" ><label for="CategoryID_1">Corporate Event Management</label></TD>
					
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_2" NAME="CategoryID" VALUE="375" CHECKED ><label for="CategoryID_2">Shipping, Transportation & Logistics</label></TD>
					</TR> <TR>
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_3" NAME="CategoryID" VALUE="376" ><label for="CategoryID_3">Printing</label></TD>
					
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_4" NAME="CategoryID" VALUE="377" ><label for="CategoryID_4">Electrical & Mechanical Engineering</label></TD>

					</TR> <TR>
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_5" NAME="CategoryID" VALUE="378" CHECKED ><label for="CategoryID_5">Solar Energy</label></TD>
					
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_6" NAME="CategoryID" VALUE="289" ><label for="CategoryID_6">Accounting & Bookkeeping</label></TD>
					</TR> <TR>
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_7" NAME="CategoryID" VALUE="291" ><label for="CategoryID_7">Agriculture</label></TD>
					
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_8" NAME="CategoryID" VALUE="292" ><label for="CategoryID_8">Construction & Architecture</label></TD>

					</TR> <TR>
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_9" NAME="CategoryID" VALUE="293" ><label for="CategoryID_9">Customer Service / Relations</label></TD>
					
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_10" NAME="CategoryID" VALUE="295" ><label for="CategoryID_10">Education</label></TD>
					</TR> <TR>
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_11" NAME="CategoryID" VALUE="296" ><label for="CategoryID_11">Civil Engineering</label></TD>
					
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_12" NAME="CategoryID" VALUE="297" ><label for="CategoryID_12">Food Service & Hospitality</label></TD>

					</TR> <TR>
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_13" NAME="CategoryID" VALUE="299" ><label for="CategoryID_13">Graphic Arts & Video</label></TD>
					
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_14" NAME="CategoryID" VALUE="300" ><label for="CategoryID_14">Human Resources</label></TD>
					</TR> <TR>
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_15" NAME="CategoryID" VALUE="301" ><label for="CategoryID_15">IT Systems & Network Administration</label></TD>

					
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_16" NAME="CategoryID" VALUE="302" ><label for="CategoryID_16">Legal</label></TD>
					</TR> <TR>
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_17" NAME="CategoryID" VALUE="303" ><label for="CategoryID_17">Management</label></TD>
					
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_18" NAME="CategoryID" VALUE="304" ><label for="CategoryID_18">Manufacturing</label></TD>
					</TR> <TR>
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_19" NAME="CategoryID" VALUE="305" ><label for="CategoryID_19">Marketing, PR & Advertising</label></TD>

					
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_20" NAME="CategoryID" VALUE="306" ><label for="CategoryID_20">Health</label></TD>
					</TR> <TR>
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_21" NAME="CategoryID" VALUE="307" ><label for="CategoryID_21">Mining</label></TD>
					
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_22" NAME="CategoryID" VALUE="309" ><label for="CategoryID_22">Project/Program Management</label></TD>
					</TR> <TR>
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_23" NAME="CategoryID" VALUE="311" ><label for="CategoryID_23">Research, Monitoring & Evaluation</label></TD>

					
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_24" NAME="CategoryID" VALUE="314" ><label for="CategoryID_24">Security</label></TD>
					</TR> <TR>
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_25" NAME="CategoryID" VALUE="315" ><label for="CategoryID_25">Software & Database</label></TD>
					
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_26" NAME="CategoryID" VALUE="316" ><label for="CategoryID_26">Telecom & Internet</label></TD>
					</TR> <TR>

					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_27" NAME="CategoryID" VALUE="319" ><label for="CategoryID_27">Web Design & Administration</label></TD>
					
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_28" NAME="CategoryID" VALUE="320" ><label for="CategoryID_28">Writing, Editing & Journalism</label></TD>
					</TR> <TR>
					<TD CLASS=NORMALTEXT><INPUT TYPE="CHECKBOX" ID="CategoryID_29" NAME="CategoryID" VALUE="308" ><label for="CategoryID_29">Other</label></TD>
					</TR>  --->
			</TABLE>

		
				</TD>
			</TR>

		
		<TR ID="AddEditFormBottomButtons">
			<TD CLASS=SMALLTEXT>* Required Field</TD>
			<TD CLASS=SMALLTEXT ALIGN=RIGHT>
				
				<INPUT TYPE="SUBMIT" id="SubmitButton2" VALUE="Submit" class=button>

				
				<INPUT TYPE="RESET" VALUE="Reset Form" class=button>
			</TD>
		</TR>
	
	</TABLE>

	<script type="text/javascript">
	//Mark last rows in groups.

	var groups = document.getElementsByTagName("TBODY");
	var children;
	for (var i = 0; i < groups.length; i ++) {
		if (groups[i].className == "columngroup") {
			children = groups[i].childNodes;
			for (var j = children.length-1; j > -1; j--) {
				if (children[j].tagName == "TR") {
					children[j].className = "ADDROW lastrowingroup";
					break;
				}
			}
		}
	}
	</script>



</FORM>


</cfoutput>
<cfif Action is "Edit">
	<p><em><strong>History for this Account</strong></em></p>
	<p><strong>Orders</strong>
	<cfif Orders.RecordCount>
		<table border="1" cellspacing="0" cellpadding="3" class="info">
			<tr>
				<th>
					Order ID
				</th>
				<th>
					Date of Purchase
				</th>
				<th>
					Payment Method
				</th>
				<th>
					Payment Status
				</th>
				<th>
					Payment Due
				</th>
				<th>
					Order Total
				</th>
			</tr>
			<cfoutput query="Orders">
				<tr>
					<td>
						<a href="Orders.cfm?Action=Edit&PK=#OrderID#">#OrderID#</a>
					</td>
					<td>
						#DateFormat(OrderDate,'dd/mm/yyyy')#
					</td>
					<td>
						#PaymentMethod#
					</td>
					<td>
						#PaymentStatus#
					</td>
					<td>
						#DateFormat(DueDate,'dd/mm/yyyy')#
					</td>
					<td>
						#DollarFormat(OrderTotal)#
					</td>
				</tr>
			</cfoutput>
		</table>
	<cfelse>
		<p>No Orders found.
	</cfif>
	
	<p><strong>Listings</strong>
	<cfif Listings.RecordCount>
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
						<a href="Listings.cfm?Action=Edit&PK=#ListingID#">#ListingTitle#<!--- <cfif Len(Title)>#Title#<cfelse>#VehicleYear# #Make# #MakeTitle# #Model#</cfif> --->&nbsp;</a>
					</td>
					<td>
						<cfif Active is "1">Active<cfelse>Inactive</cfif>
					</td>
					<td>
						<cfif Reviewed is "1">Reviewed<cfelse>Pending</cfif>
					</td>
					<td>
						<cfif Len(OrderID)>
							<a href="Orders.cfm?Action=Edit&PK=#OrderID#">#OrderID#</a>
						<cfelseif Len(ListingPackageID)>
							<a href="Orders.cfm?Action=Edit&PK=#ListingPackageOrderID#">#ListingPackageOrderID#</a><br />
							(Listing Package #ListingPackageID#)
						</cfif>
					</td>
					<td>
						#PaymentStatus#
					</td>
					<td>
						#DateFormat(ExpirationDate,'dd/mm/yyyy')#
					</td>
				</tr>
			</cfoutput>
		</table>
	<cfelse>
		<p>No Listings found.
	</cfif>
	
	<cfif ListingPackages.RecordCount>
		<p><strong>Listing Packages</strong>
		<table border="1" cellspacing="0" cellpadding="3" class="info">
			<tr>
				<th>
					Listing Package ID
				</th>
				<th>
					Package Description
				</th>
				<th>
					# of Listings Purchased
				</th>
				<th>
					# of Listings Used
				</th>
				<th>
					Order ID
				</th>
				<th>
					Date of Purchase
				</th>
				<th>
					Expires On
				</th>
			</tr>
			<cfoutput query="ListingPackages">
				<tr>
					<td>
						#ListingPackageID#
					</td>
					<td>
						#ListingPackageType#
					</td>
					<td>
						<cfif ListingsPaidFor is "1000000">Unlimited<cfelse>#ListingsPaidFor#</cfif>
					</td>
					<td>
						<a href="Listings.cfm?Action=View&Searching=1&ListingPackageID=#ListingPackageID#">#ListingsInPackage#</a>
					</td>
					<td>
						<a href="Orders.cfm?Action=Edit&PK=#OrderID#">#OrderID#</a>
					</td>
					<td>
						#PaymentStatus#
					</td>
					<td>
						<cfif Len(PaymentDate)>
							#DateFormat(DateAdd('yyyy',1,PaymentDate),'dd/mm/yyyy')#
						<cfelse>
							1 year from date payment received
						</cfif>						
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
	<cfquery name="q2" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select A.DateCreated,
		(Select Top 1 UpdateDate From Updates Where UserID=A.UserID Order by UpdateDate Desc) as UpdateDate,
		(Select Top 1 IsNull(Us.FirstName,'') + ' ' + IsNull(Us.LastName,'') From Updates Up Left Outer Join LH_Users Us on Up.UpdatedByID=Us.UserID Where Us.UserID=A.UserID Order by UpdateDate Desc) as UpdatedBy
		From LH_Users A
		Where A.UserID=<cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfquery name="UpdateHistory" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select U.UpdateDate, U.Descr,
		IsNull(Us.FirstName,'') + ' ' + IsNull(Us.LastName,'') as UpdatedBy
		From Updates U 
		Left Outer Join LH_Users Us on U.UpdatedByID=Us.UserID
		Where U.UserID=<cfqueryparam value="#pk#" cfsqltype="CF_SQL_INTEGER">
		Order By U.UpdateDate Desc
	</cfquery>
	<p>
	<cfoutput>Date Added: #DateFormat(q2.DateCreated,'dd/mm/yyyy')# | Last Updated: #DateFormat(q2.UpdateDate,'dd/mm/yyyy')# | Updated By: #q2.UpdatedBy#</cfoutput>
	<cfif UpdateHistory.RecordCount>
		<p><strong>Payment Update History</strong><br>
		<cfoutput query="UpdateHistory">
			#DateFormat(UpdateDate,'dd/mm/yyyy')#: by #UpdatedBy#:<br /> 				
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#Replace(Descr,"|","<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;","ALL")#<br>
		</cfoutput>
	</cfif>
</cfif>

</div>
