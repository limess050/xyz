<!---
File Name: 	MS_TableView.cfm
Author: 	David Hammond
Description:

Inputs:
	table (required)
	startRow (opt)
	orderBy (opt)
--->
<cfsilent>
<cfset actionURL = cgi.script_name & "?action=View">
<cfif len(queryParams) gt 0>
	<cfset actionURL = actionURL & "&amp;" & queryParams>
</cfif>
<cfif len(Request.Table.persistentParams) gt 0>
	<cfset actionURL = actionURL & "&amp;" & Request.Table.persistentParams>
</cfif>
<cfif Not StructKeyExists(url,"reportType")>
	<cfset url.reportType="">
</cfif>

<!---Set the list of all possible columns. --->
<cfset allColumns = StructKeyList(Request.Table.Columns)>

<!---Initialize variables for table view --->
<cfset Request.Table.InitializeView()>

<!---Set columns in list to true ... --->
<cfif Len(Request.Table.ViewColumnsList) gt 0>
	<cfloop index="colName" list="#Request.Table.ViewColumnsList#">
		<cfif StructKeyExists(Request.Table.Columns,colName) and Request.Table.Columns[colName].AllowView>
			<cfset Request.Table.Columns[colName].View = true>
		</cfif>
	</cfloop>
<!---... or use default columns --->
<cfelse>
	<cfloop index="colName" list="#allColumns#">
		<cfif Request.Table.Columns[colName].DefaultView>
			<cfset Request.Table.Columns[colName].View = true>
			<cfset Request.Table.ViewColumnsList = ListAppend(Request.Table.ViewColumnsList,colName)>
		</cfif>
	</cfloop>
</cfif>

<!---Construct Query --->
<cfset MainQueryInfo = StructNew()>
<cfset MainQueryInfo.selectClause = "#Request.Table.table#.#Request.Table.PrimaryKey#">
<cfset MainQueryInfo.fromClause = Request.Table.table>
<cfset MainQueryInfo.whereClause = "">
<cfset MainQueryInfo.orderByClause = url.orderBy>

<cfset Request.ColumnEdit = false>
<cfset ViewColumns = ArrayNew(1)>

<!---Loop through columns to build query --->
<cfloop collection="#Request.Table.Columns#" item="colName">
	<cfset Request.Table.addQueryColumn(MainQueryInfo,Request.Table.Columns[colName],Request.Table.table)>
</cfloop>

<!---set view columns in proper order --->
<cfif Len(Request.Table.ColumnOrderList) gt 0>
	<cfset Request.Table.ColumnOrder = ListToArray(Request.Table.ColumnOrderList)>
</cfif>
<cfset totalRow = false>
<cfloop index="i" from="1" to="#ArrayLen(Request.Table.columnOrder)#">
	<cfif StructKeyExists(Request.Table.Columns,Request.Table.ColumnOrder[i])>
		<cfset Column = Request.Table.Columns[Request.Table.ColumnOrder[i]]>
		<cfif Column.View>
			<cfset ArrayAppend(ViewColumns,Column)>
			<cfif Column.ShowTotal>
				<cfset Column.TotalHolder = 0>
				<cfset totalRow = true>
			</cfif>
		</cfif>
	</cfif>
</cfloop>

<!--- Build query based on search criteria and the columns that must be returned --->
<cfquery name="getRecords" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT
		<cfif url.reportType is "rss" or  url.reportType is "atom">
			#Request.Table.PrimaryKey#
			<cfif IsDefined("Request.Table.rssTitle")>,#PreserveSingleQuotes(Request.Table.rssTitle)# as rssTitle</cfif>
			<cfif IsDefined("Request.Table.rssDescription")>,#PreserveSingleQuotes(Request.Table.rssDescription)# as rssDescription</cfif>
			<cfif IsDefined("Request.Table.rssPubDate")>,#PreserveSingleQuotes(Request.Table.rssPubDate)# as rssPubDate</cfif>
		<cfelse>
			#PreserveSingleQuotes(MainQueryInfo.selectClause)#
			<cfloop index="i" from="1" to="#ArrayLen(Request.Table.SpecialColumns)#"><cfset specColExpr = Request.Table.SpecialColumns[i].Expression>
				,#PreserveSingleQuotes(specColExpr)# as #Request.Table.SpecialColumns[i].Name#
			</cfloop>
		</cfif>
	FROM #MainQueryInfo.fromClause#
	WHERE (<cfif Request.Table.whereClause is not "">#PreserveSingleQuotes(Request.Table.whereClause)#<cfelse>1=1</cfif>)	
		#PreserveSingleQuotes(MainQueryInfo.whereClause)#
	<cfif StructKeyExists(Request.Table,"GroupBy")>
		GROUP BY #Request.Table.GroupBy#
	</cfif>
	ORDER BY #PreserveSingleQuotes(MainQueryInfo.orderByClause)#
</cfquery>
</cfsilent>

<cfif getRecords.recordCount is 0>
	<p>No records found.</p>
	<cfexit>
</cfif>

<!--- Display records depending on report type --->
<cfswitch expression = "#url.reportType#">
	<!--- Standard display --->
	<cfcase value="">
		<!---Initialize variables --->
		<cfset numRecords = getRecords.recordCount>
		<cfif Request.Table.MaxRows is 0>
			<cfset Request.Table.MaxRows = Max(numRecords,2)>
		</cfif>

		<!---Fix start row --->
		<cfif url.startRow gt numRecords>
			<cfset url.startRow = numRecords>
		</cfif>
		<cfif (url.startRow - 1) mod Request.Table.MaxRows neq 0>
			<cfset url.startRow = url.startRow - (url.startRow - 1) mod Request.Table.MaxRows>
		</cfif>
		<cfset alternate = false>

		<!---Strip orderby params for column header links --->
		<cfset orderByURL = REReplaceNoCase(actionURL,"orderBy=[^&$]+|desc=[^&$]+","","ALL")>
		<cfset orderByURL = Replace(orderByURL,"&amp;&amp;","&amp;","ALL")>

		<cfset jsColList = "">
		<cfloop index="i" from="1" to="#ArrayLen(Request.Table.ColumnOrder)#">
			<cfif StructKeyExists(Request.Table.Columns,Request.Table.ColumnOrder[i])>
				<cfif Request.Table.Columns[Request.Table.ColumnOrder[i]].AllowView>
					<cfset jsColList = ListAppend(jsColList,"[""#Request.Table.ColumnOrder[i]#"",""#JSStringFormat(Request.Table.Columns[Request.Table.ColumnOrder[i]].DispName)#"",#Request.Table.Columns[Request.Table.ColumnOrder[i]].View#]")>
				</cfif>
			</cfif>
		</cfloop>

		<cfoutput>
		<script type="text/javascript">
		//functions to show menu for columnHeader
		var actionURL = "#Application.Lighthouse.jsDecodeUri(actionURL)#";
		var orderByUrl = "#Application.Lighthouse.jsDecodeUri(orderByUrl)#";
		var orderBy = "#url.orderBy#";
		var columnList = "#Request.Table.ViewColumnsList#";
		var columns = [#jsColList#];
		</script>
		<script type="text/javascript" src="#Request.Table.resourcesDir#/js/msTableView.js"></script>

		<cfif Request.ColumnEdit>
			<cfset multipart = false>
			<script type="text/javascript">
			var mainTable = lh.addTable(#Application.Json.encode(Request.Table)#);
				
			// client-side validation for column edit
			function validateForm(formObj) {
				valid = true;
				<cfloop index="colNum" from="1" to="#ArrayLen(ViewColumns)#">
					<cfset Column = ViewColumns[colNum]>
					<cfif Column.DoEdit>
						for (var i = 0; i < formObj.elements.length; i ++) {
							e = formObj.elements[i];
							if (e.name.search('^#Column.Name#_[0-9]+$') == 0) {
								<cfif Column.Required>
									<cfswitch expression="#Column.Type#">
										<cfcase value="Select">
											valid = checkSelected(e,"#Column.DispName#");
										</cfcase>
										<cfcase value="Radio,checkboxgroup">
											valid = checkChecked(e,"#Column.DispName#");
										</cfcase>
										<cfcase value="File">
											valid = checkFile(formObj,e.name,"#Column.DispName#");
										</cfcase>
										<cfdefaultcase>
											valid = checkText(e,"#Column.DispName#");
										</cfdefaultcase>
									</cfswitch>
								</cfif>
								if (!valid) { return false; }
								<cfif Len(Column.Validate) gt 0>
									valid = #Column.Validate#;
								</cfif>
								if (!valid) { return false; }
								<cfswitch expression="#Column.Type#">
									<cfcase value="Textarea">
										<cfif Len(Column.MaxLength)>
											valid = checkLength(e,#Column.MaxLength#,"#Column.DispName#");
										</cfif>
									</cfcase>
									<cfcase value="Integer">
										valid = checkNumber(e,"#Column.DispName#");
									</cfcase>
									<cfcase value="Date">
										<cfif Column.ShowDate>
											valid = checkDate(e,"#Column.DispName#");
										</cfif>
										<cfif Column.ShowTime>
											valid = checkNumber(document.getElementById(e.name + "_Hour"),"#Column.DispName# Hour");
											valid = checkNumber(document.getElementById(e.name + "_Minute"),"#Column.DispName# Minute");
										</cfif>
									</cfcase>
									<cfcase value="File">
										<cfset multipart = true>
									</cfcase>
								</cfswitch>
								if (!valid) { return false; }
							}
						}
					</cfif>
				</cfloop>
				return valid;
			}
			</script>
			<FORM NAME="f1" ACTION="#cgi.script_name#?action=ViewDoit&#Request.Table.persistentParams#&#queryParams#" METHOD="POST" ONSUBMIT="return validateForm(this)" <cfif multipart>ENCTYPE="multipart/form-data"</cfif>>
			<p align=right><INPUT TYPE="SUBMIT" VALUE="Save Changes" class=button></p>
			<cfset editedIds = "">
		</cfif>

		<cfif StructKeyExists(Request.Table.RowActions,"Select")>
			<cfset selectAction = Request.Table.RowActions["Select"]>
			<cfif IIf(Len(selectAction.ConditionalParam),"IsDefined(""url.#selectAction.ConditionalParam#"")","true")>
				<script type="text/javascript">
				function markSelectedItems() {
					var selButtons = document.getElementsByName("selButton");
					for (var i = 0; i < selButtons.length; i ++) {
						selBut = selButtons[i];
						if (opener.#selectAction.FieldID#_isSelected(selBut.getAttribute("ROWID"))) {
							markSelectedItem(selBut);
						} else {
							markUnselectedItem(selBut);
						}
					}
				}
				function markSelectedItem(selBut) {
					selBut.onclick = deselectItem;
					selBut.innerHTML = "Deselect";
					selBut.parentNode.className = selBut.parentNode.className + " selected";
				}
				function markUnselectedItem(selBut) {
					selBut.onclick = selectItem;
					selBut.innerHTML = "#selectAction.Label#";
					selBut.parentNode.className = replace(selBut.parentNode.className,"selected","");
				}
				function selectItem(e) {
					var selBut = xGetEventSrcElement(e)
					#selectAction.jsfunction#(selBut.getAttribute("ROWID"),selBut.getAttribute("ROWDESCR"));
					markSelectedItems();
				}
				function deselectItem(e) {
					var selBut = xGetEventSrcElement(e)
					opener.#selectAction.FieldID#_delete(selBut.getAttribute("ROWID"));
					markSelectedItems();
				}
				xAddEvent(window,"load",markSelectedItems);
				</script>
			</cfif>
		</cfif>

		<!--- PAGE NAVIGATION TOP --->
		<p><cf_MS_PageNav
			totalItems="#numRecords#"
			numPerPage="#Request.Table.MaxRows#"
			startRow="#url.startRow#"
			showInfo="true"
			url="#actionURL#"></p>

		<TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0 CLASS=VIEWTABLE>
		<!--- Column Group header --->
		<tr id="viewgroupheaderrow">
			<td></td>
			<cfset colspan = 0>
			<cfloop index="colNum" from="1" to="#ArrayLen(ViewColumns)#">
				<cfset Column = ViewColumns[colNum]>
				<cfif Len(Column.ColumnGroup) is 0 and Len(Request.Table.CurrentColumnGroup) is 0>
					<td></td>
				<cfelse>
					<cfif Len(Request.Table.CurrentColumnGroup) gt 0 and Column.ColumnGroup is not Request.Table.CurrentColumnGroup>
						<td class=viewgroupheadercell colspan="#colspan#">#Request.Table.ColumnGroups[Request.Table.CurrentColumnGroup].Label#</td>
						<cfset Request.Table.CurrentColumnGroup = "">
						<cfset colspan = 0>
					</cfif>
					<cfif Len(Column.ColumnGroup) gt 0>
						<cfset Request.Table.CurrentColumnGroup = Column.ColumnGroup>
						<cfset colspan = colspan + 1>
					<cfelse>
						<td></td>
					</cfif>
				</cfif>
			</cfloop>
			<cfif Len(Request.Table.CurrentColumnGroup) gt 0>
				<td class=viewgroupheadercell colspan="#colspan#">#Request.Table.ColumnGroups[Request.Table.CurrentColumnGroup].Label#</td>
				<cfset Request.Table.CurrentColumnGroup = "">
				<cfset colspan = 0>
			</cfif>
		</tr>
		<!--- Column Headers --->
		<tr>
			<TD CLASS=VIEWHEADERCELL SCOPE="col" onclick="showAddColumnMenu(this)" onmouseout="hideAddColumnMenu(this)">+</TD>
			<cfloop index="colNum" from="1" to="#ArrayLen(ViewColumns)#">
				<cfset Column = ViewColumns[colNum]>
				<!--- Set the orderBy for this column. --->
				<cfswitch expression="#Column.Type#">
					<cfcase value="select">
						<cfset thisOrderBy = Column.QualifiedDescr>
					</cfcase>
					<cfcase value="pseudo">
						<cfset thisOrderBy = Column.Name>
					</cfcase>
					<cfcase value="textarea">
						<cfif Request.dbtype is "mssql">
							<cfset thisOrderBy = "convert(varchar,#Request.Table.table#.#Column.Name#)">
						<cfelse>
							<cfset thisOrderBy = Request.Table.table & "." & Column.Name>
						</cfif>
					</cfcase>
					<cfcase value="select-multiple,select-multiple-popup,childtable">
						<cfset thisOrderBy = "">
					</cfcase>
					<cfdefaultcase>
						<cfset thisOrderBy = Request.Table.table & "." & Column.Name>
					</cfdefaultcase>
				</cfswitch>
				<TD NOWRAP CLASS=VIEWHEADERCELL SCOPE="col" colName="#Column.Name#"
					<cfif Column.AllowColumnEdit and Column.Editable>editable="1"</cfif>
					orderBy="#thisOrderBy#"
					onclick="showColumnMenu(this)"
					onmouseout="hideColumnMenu(this)"
					>#Column.DispName#
					<cfif FindNoCase(thisOrderBy & " desc",url.orderBy) is 1>
						<img src="#Request.Table.resourcesDir#/images/arrowup.gif" width=11 height=12 alt="Sort Descending">
					<cfelseif ListFindNoCase(url.orderBy,thisOrderBy) is 1>
						<img src="#Request.Table.resourcesDir#/images/arrowdn.gif" width=11 height=12 alt="Sort Ascending">
					</cfif>
				</TD>
			</cfloop>
		</tr>
		</cfoutput>

		<!--- Rows --->
		<cfoutput query="getRecords" startrow="#url.startRow#" MaxRows="#Request.Table.MaxRows#">
			<tr class="VIEWROW<cfloop list="#Request.Table.StyleIDColumns#" index="styleColName"> #styleColName##getRecords[styleColName][CurrentRow]#</cfloop><cfif alternate> alternate</cfif>"><td>&nbsp;</td>

				<!--- Values --->
				<cfset pk = getRecords[Request.Table.PrimaryKey][CurrentRow]>
				<cfloop index="colNum" from="1" to="#ArrayLen(ViewColumns)#">
					<cfset Column = ViewColumns[colNum]>
					<td>
						<cfif Column.DoEdit>
							<cfif StructKeyExists(getRecords,Column.Name)>
								<cf_MS_TableDisplay_Field column="#Column#" value="#getRecords[Column.Name][CurrentRow]#" pk="#pk#">
							<cfelse>
								<cf_MS_TableDisplay_Field column="#Column#" pk="#pk#">
							</cfif>
							<cfif ListFind(editedIDs,pk) is 0>
								<cfset editedIDs = ListAppend(editedIDs,pk)>
							</cfif>
						<cfelse>
							#Column.getValueFromQuery(getRecords,MainQueryInfo)#
						</cfif>
					</td>
				</cfloop>
	
				<!--- Action buttons --->
				<cfloop index="i" from="1" to="#ArrayLen(Request.Table.RowActionOrder)#">
					<cfset CurrAction = Request.Table.RowActions[Request.Table.RowActionOrder[i]]>
					<cfif IIf(Len(CurrAction.ConditionalParam),"IsDefined(""url.#CurrAction.ConditionalParam#"")","true")>
						<cfswitch expression="#CurrAction.Type#">
							<cfcase value="Select">
								<TD CLASS=VIEWACTIONCELL NAME="selButton" ID="selButton" ROWID="#pk#" ROWDESCR="#JSStringFormat(getRecords[CurrAction.DescrColName][CurrentRow])#"></TD>
							</cfcase>
							<cfcase value="Custom">
								<cfset showButton = true>
								<cfif Len(CurrAction.Condition)><cfif Not Evaluate(CurrAction.Condition)><cfset showButton = false></cfif></cfif>
								<cfif showButton>
									<cfif Find("javascript:",CurrAction.href)>
										<cfset theCurrActionHref = REReplace(CurrAction.Href,"##([^##]+)##","##JSStringFormat(HTMLEditFormat(\1))##","ALL")>
									<cfelse>
										<cfset theCurrActionHref = REReplace(CurrAction.Href,"##([^##]+)##","##URLEncodedFormat(\1)##","ALL")>
									</cfif>
									<cfset theCurrActionOnClick = REReplace(CurrAction.OnClick,"##([^##]+)##","##JSStringFormat(HTMLEditFormat(\1))##","ALL")>
									<TD CLASS=VIEWACTIONCELL><a href="#Evaluate("""" & theCurrActionHref & """")#" onclick="#Evaluate("""" & theCurrActionOnClick & """")#" <cfif Len(CurrAction.Target) gt 0>TARGET="#CurrAction.Target#"</cfif>>#CurrAction.Label#</a></TD>
								</cfif>
							</cfcase>
							<cfdefaultcase>
								<TD CLASS=VIEWACTIONCELL><a href="#cgi.script_name#?action=#Request.Table.RowActionOrder[i]#&#Request.Table.persistentParams#&pk=#pk#<cfif Len(queryParams) gt 0>&queryParams=#URLEncodedFormat(queryParams)#</cfif>" <cfif Len(CurrAction.Target) gt 0>TARGET="#CurrAction.Target#"</cfif>>#CurrAction.Label#</a></TD>
							</cfdefaultcase>
						</cfswitch>
					</cfif>
				</cfloop>
			</tr>
			<cfset alternate = not alternate>
		</cfoutput>

		<!--- Total row --->
		<cfif totalRow>
			<tr class=VIEWTOTALROW><td>&nbsp;</td>
				<cfloop index="colNum" from="1" to="#ArrayLen(ViewColumns)#">
					<td><cfoutput>#ViewColumns[colNum].getTotal()#</cfoutput></td>
				</cfloop>
			</tr>
		</cfif>
		</table>

		<!--- PAGE NAVIGATION BOTTOM --->
		<p><cf_MS_PageNav
			totalItems="#numRecords#"
			numPerPage="#Request.Table.MaxRows#"
			startRow="#url.startRow#"
			url="#actionURL#"></p>

		<!--- Close column edit form --->
		<cfif Request.ColumnEdit>
			<p align=right>
			<INPUT TYPE="HIDDEN" NAME="editedIDs" VALUE="<cfoutput>#editedIDs#</cfoutput>">
			<INPUT TYPE="SUBMIT" VALUE="Save Changes" class=button>
			</p>
			</FORM>
		</cfif>

		<!--- Report links --->
		<p>
		<cfoutput>
		<cfif StructKeyExists(Request.Table.Actions,"CreateExcel")>
			Export as
			<A HREF="#actionUrl#&amp;reportType=excel" class=normaltext>Excel</A>,
			<A HREF="#actionUrl#&amp;reportType=table" target="_blank" class=normaltext>HTML Table</A>,
			<A HREF="#actionUrl#&amp;reportType=csv" class=normaltext>CSV</A><cfif IsDefined("Request.Table.rssTitle")>,
				<A HREF="#actionUrl#&amp;reportType=rss&amp;#Application.Lighthouse.lh_getAuthToken()#" class=normaltext><img src="#Request.AppVirtualPath#/Lighthouse/Resources/images/rss.gif" alt="RSS Feed" border=0 align="top"></A>
				<cfhtmlhead text="<link rel=""alternate"" type=""application/rss+xml"" title=""#Request.Table.Title# Search Results RSS"" href=""#actionUrl#&amp;reportType=rss&amp;#Application.Lighthouse.lh_getAuthToken()#"">">
			</cfif>
		</cfif>
		<cfif StructKeyExists(Request.Table.Actions,"DisplayOptions")>
			| <A HREF="#cgi.script_name#?action=DisplayOptions&#Request.Table.persistentParams#<cfif Len(queryParams) gt 0>&queryParams=#URLEncodedFormat(queryParams)#</cfif>" class=normaltext>Display Options</A>
		</cfif>
		</cfoutput>
		</p>

		<!--- Include event code --->
		<cfif StructKeyExists(Request.Table.Events,"onAfterSearch")>
			<cfinclude template = "#Request.Table.Events.onAfterSearch.Include#">
		</cfif>
	</cfcase>

	<!--- HTML-formatted reports --->
	<cfcase value = "excel,table">
		<cftry>
			<cfif url.reportType is "excel">
				<cfcontent type="application/x-msexcel" reset="Yes">
				<cfheader name="Content-Disposition" value="filename=#Request.Table.Name#.xls">
			<cfelse>
				<cfcontent type="text/html" reset="Yes">
			</cfif>
			<html>
			<head>
			<cfoutput><link rel=stylesheet href="#Request.httpUrl##Request.AppVirtualPath#/Lighthouse/Resources/css/#Request.MCFStyle#.css" type="text/css"></cfoutput>
			<style>
			/* Prevent line breaks from creating new cells. Note that other tags can still cause problems (p,li,etc) */
			br {mso-data-placement:same-cell;}
			tr {vertical-align:top;}
			</style>
			</head>
			<body>
			<table>
				<!--- Column Headers --->
				<tr>
					<cfloop index="colNum" from="1" to="#ArrayLen(ViewColumns)#">
						<th nowrap><cfoutput>#ViewColumns[colNum].DispName#</cfoutput></th>
					</cfloop>
				</tr>
				<!--- Rows --->
				<cfoutput query="getRecords">
					<tr><cfloop index="colNum" from="1" to="#ArrayLen(ViewColumns)#"><td>#ViewColumns[colNum].getValueFromQuery(getRecords,MainQueryInfo)#</td></cfloop></tr>
				</cfoutput>
				<!--- Total row --->
				<cfif totalRow>
					<tr>
						<cfloop index="colNum" from="1" to="#ArrayLen(ViewColumns)#">
							<td><cfoutput>#ViewColumns[colNum].getTotal()#</cfoutput></td>
						</cfloop>
					</tr>
				</cfif>
			</table>
			</body>
			</html>
			<!--- There is a bug with cfabort.  Use cfexit and set variable so that all content can be suppressed --->
			<cfset Request.EndResponse = true>
			<cfexit>
			<cfcatch>
				<cfcontent type="text/html" reset="No">
				<cfrethrow>
			</cfcatch>
		</cftry>
	</cfcase>

	<!--- CSV report --->
	<cfcase value = "csv">
		<cfset dir = ExpandPath("temp")>
		<cfset fileName = Request.Table.table & "_" & DateFormat(Now(),"yyyymmdd") & TimeFormat(Now(),"HHmmss") & ".csv">
		<cfset filePath = dir & "\" & fileName>
		<cfif Not DirectoryExists(dir)>
			<cfdirectory action="create" directory="#dir#">
		<cfelse>
			<!--- Delete reports older than 1 hour --->
			<cfdirectory action="list" directory="#dir#" name="reports">
			<cfloop query="reports">
				<cfif dateLastModified lt DateAdd("h",-1,Now())>
					<cffile action="delete" file="#dir#\#name#">
				<cfelse>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>
		<cfset numCols = ArrayLen(ViewColumns)>
		<cfset minusOne = numCols-1>
		<cfset startTime = GetTickCount()>
		<!--- Column Headers --->
		<!--- If first column starts with "ID", force quotation marks around it to
			avoid problem with Excel trying to interpret it as an SYLK file
			http://support.microsoft.com/?kbid=323626 --->
		<cfif Find("ID",ViewColumns[1].DispName) is 1>
			<cfset line = """" & Replace(ViewColumns[1].DispName,"""","""""","ALL") & """">
		<cfelse>
			<cfset line = Application.Lighthouse.csvValueFormat(ViewColumns[1].DispName)>
		</cfif>
		<cfloop index="i" from="2" to="#numCols#">
			<cfset line = line & "," & Application.Lighthouse.csvValueFormat(ViewColumns[i].DispName)>
		</cfloop>
		<cffile action="append" file="#filePath#" output="#line#">
		<!--- Rows --->
		<cfoutput query="getRecords">
			<cfset Variables.line = Application.Lighthouse.csvValueFormat(ViewColumns[1].getValueFromQuery(getRecords,MainQueryInfo))>
			<cfloop index="i" from="2" to="#numCols#">
				<cfset Variables.line = Variables.line & "," & Application.Lighthouse.csvValueFormat(ViewColumns[i].getValueFromQuery(getRecords,MainQueryInfo))>
			</cfloop>
			<cffile action="append" file="#Variables.filePath#" output="#Variables.line#">
		</cfoutput>
		<!--- Total row --->
		<cfif totalRow>
			<cfset line = Application.Lighthouse.csvValueFormat(ViewColumns[1].getTotal())>
			<cfloop index="i" from="2" to="#minusOne#">
				<cfset line = line & "," & Application.Lighthouse.csvValueFormat(ViewColumns[i].getTotal())>
			</cfloop>
			<cffile action="append" file="#Variables.filePath#" output="#line#">
		</cfif>
		<cfset numSeconds = (GetTickCount() - startTime) / 1000>
		<cfoutput>
		<p>Report generated in #numSeconds# seconds.</p>
		<p><a href="temp/#fileName#" target="_blank">Download CSV file</a></p>
		</cfoutput>
	</cfcase>

	<!--- RSS 2.0 report --->
	<cfcase value = "rss">
		<cftry>
			<cfcontent type="text/xml" reset="Yes"><?xml version="1.0" encoding="UTF-8"?>
			<?xml-stylesheet href="<cfoutput>#Request.httpsUrl#</cfoutput>/Lighthouse/Resources/xml/rss2.xsl" type="text/xsl" media="screen"?>
			<!---
			<?xml-stylesheet href="http://feeds.feedburner.com/~d/styles/rss2full.xsl" type="text/xsl" media="screen"?>
			<?xml-stylesheet href="http://feeds.feedburner.com/~d/styles/itemcontent.css" type="text/css" media="screen"?>
			--->
			<rss version="2.0">
			<channel>
				<cfoutput>
					<title>#XmlFormat("#Request.glb_title#: #Request.Table.Title#")#</title>
					<link>#XmlFormat("#Request.httpsUrl##actionUrl#&amp;reportType=rss&amp;#Application.Lighthouse.lh_getAuthToken()#")#</link>
					<description>Search results</description>
					<language>en-us</language>
					<generator>Modern Signal Lighthouse</generator>
					<!--- <pubDate>#Application.Lighthouse.rssDateFormat(Now())#</pubDate>
					<lastBuildDate>#Application.Lighthouse.rssDateFormat(Now())#</lastBuildDate> --->
				</cfoutput>
				<cfoutput query="getRecords">
					<cfset link = XmlFormat("#Request.httpsUrl##cgi.script_name#?action=Edit&pk=#getRecords[Request.Table.PrimaryKey][CurrentRow]#&#Application.Lighthouse.lh_getAuthToken()#")>
					<cfset title = XmlFormat(Application.Lighthouse.StripHtml(rssTitle))>
					<cfif Len(title) is 0>
						<cfset title = XmlFormat(Left(Application.Lighthouse.StripHtml(rssDescription),100))>
					</cfif>
					<item>
						<link>#link#</link>
						<guid>#link#<cfif Len(rssPubDate) gt 0>#UrlEncodedFormat(Application.Lighthouse.rssDateFormat(rssPubDate))#</cfif></guid>
						<cfif IsDefined("rssTitle")><title>#XmlFormat(title)#</title></cfif>
						<cfif IsDefined("rssDescription")><description>#XmlFormat(rssDescription)#</description></cfif>
						<cfif IsDefined("rssPubDate")><cfif Len(rssPubDate) gt 0><pubDate>#Application.Lighthouse.rssDateFormat(rssPubDate)#</pubDate></cfif></cfif>
					</item>
				</cfoutput>
			</channel>
			</rss>
			<cfset Request.EndResponse = true>
			<cfexit>
			<cfcatch>
				<cfcontent type="text/html" reset="No">
				<cfrethrow>
			</cfcatch>
		</cftry>
	</cfcase>

	<!--- Atom 1.0 report --->
	<cfcase value = "atom">
		<cftry>
			<cfcontent type="text/xml" reset="Yes"><?xml version="1.0" encoding="UTF-8"?>
			<feed xmlns="http://www.w3.org/2005/Atom">
				<cfoutput>
					<id>#XmlFormat("#Request.httpsUrl##actionUrl#&amp;reportType=atom&amp;#Application.Lighthouse.lh_getAuthToken()#")#</id>
					<title>#XmlFormat("#Request.glb_title#: #Request.Table.Title#")#</title>
					<updated>#internetDateFormat(Now())#</updated>
					<link rel="self" href="#XmlFormat("#Request.httpsUrl##actionUrl#&amp;reportType=atom&amp;#Application.Lighthouse.lh_getAuthToken()#")#"/>
					<author><name>#XmlFormat("#Request.glb_title#")#</name></author>
					<subtitle>Search results</subtitle>
					<generator>Modern Signal Lighthouse</generator>
				</cfoutput>
				<cfoutput query="getRecords">
					<cfset link = XmlFormat("#Request.httpsUrl##cgi.script_name#?action=Edit&pk=#getRecords[PrimaryKey][CurrentRow]#&#Application.Lighthouse.lh_getAuthToken()#")>
					<entry>
						<id>#link#</id>
						<cfif IsDefined("rssTitle")><title>#XmlFormat(Application.Lighthouse.StripHtml(rssTitle))#</title></cfif>
						<cfif IsDefined("rssPubDate")><cfif Len(rssPubDate) gt 0><updated>#internetDateFormat(rssPubDate)#</updated></cfif></cfif>
						<link rel="alternate" href="#link#"/>
						<cfif IsDefined("rssDescription")><content type="html">#XmlFormat(rssDescription)#</content></cfif>
					</entry>
				</cfoutput>
			</feed>
			<cfset Request.EndResponse = true>
			<cfexit>
			<cfcatch>
				<cfcontent type="text/html" reset="No">
				<cfrethrow>
			</cfcatch>
		</cftry>
	</cfcase>
</cfswitch>

