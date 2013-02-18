<cfcomponent name="Table" hint="Defines a data table." extends="Object">

	<cfinclude template="../Functions/LighthouseLib.cfm">

	<cffunction name="Init" description="Instantiate a table." output="false" returntype="Table">
		<cfargument name="Properties" required="true" type="struct">
		
		<cfset var allowedaction = "">
		<cfset This.CurrentColumnGroup = "">
		
		<!--- Allow Properties to overwrite db settings for request --->
		<cfif StructKeyExists(Properties,"dsn")>
			<cfset Request.dsn = Properties.dsn>
			<cfif StructKeyExists(Properties,"dbtype")><cfset Request.dbtype = Properties.dbtype></cfif>
			<cfif StructKeyExists(Properties,"username")><cfset Request.dbusername = Properties.username></cfif>
			<cfif StructKeyExists(Properties,"password")><cfset Request.dbpassword = Properties.password></cfif>
		</cfif>
		
		<cfset This.ID = Application.Lighthouse.GetProperty(Properties,"id",Properties.Table)>
		<cfset This.Name = This.ID>
		<cfset This.Title = Application.Lighthouse.GetProperty(Properties,"Title",Properties.Table)>
		<cfset This.WhereClause = Application.Lighthouse.GetProperty(Properties,"WhereClause","")>

		<cfset This.IDTable = Application.Lighthouse.GetProperty(Properties,"IDTable","MS_TableIDs")>
	
		<cfif Not StructKeyExists(url,"orderBy")>
			<cfif StructKeyExists(Properties,"orderBy")><cfset url.orderBy = Properties.orderBy></cfif>
		</cfif>
		
		<cfif StructKeyExists(Properties,"groupby")><cfset This.GroupBy = Properties.groupby></cfif>

		<cfscript>
		// Initialize variables
		This.Columns = StructNew();
		This.ColumnOrder = ArrayNew(1);
		This.ColumnGroups = StructNew();
		//Request.Table.CurrentColumnGroup = "";
		This.Actions = StructNew();
		This.ActionOrder = ArrayNew(1);
		This.RowActions = StructNew();
		This.RowActionOrder = ArrayNew(1);
	
		This.PrimaryKey = "";
		This.RelatedTables = "";
		This.table = Properties.table;
	
		SetProperty(Properties,"resourcesDir",Application.Lighthouse.getBaseRelativePath() & Request.AppVirtualPath & "Lighthouse/Resources");
		SetProperty(Properties,"editable",true);
		SetProperty(Properties,"AllowColumnEdit",false);
		SetProperty(Properties,"DefaultAction","View");
		SetProperty(Properties,"allowedactions","View,Search,Add,Edit,Delete,DisplayOptions,CreateExcel");
		SetProperty(Properties,"disallowedactions","");
		SetProperty(Properties,"layout","../Tags/MS_TableDefaultTemplate.cfm");
		SetProperty(Properties,"persistentParams","");
		
		//RSS-related parameters
		if (StructKeyExists(Properties,"rssTitle")) {
			This.rssTitle = Properties.rssTitle;
			if (StructKeyExists(Properties,"rssDescription")) This.rssDescription = Properties.rssDescription;
			if (StructKeyExists(Properties,"rssPubDate")) This.rssPubDate = Properties.rssPubDate;
		}
	
		This.SpecialColumns = ArrayNew(1);
		This.Events = StructNew();
	
		for (i = 1; i lte ListLen(This.allowedactions); i = i + 1) {
			allowedaction = ListGetAt(This.allowedactions,i);
			if (Not ListFind(This.disallowedactions,allowedaction)) {
				if (ListFind("Edit,Delete",allowedaction)) {
					This.RowActions[allowedaction] = StructNew();
					This.RowActions[allowedaction].Name = allowedaction;
					This.RowActions[allowedaction].Type = allowedaction;
					This.RowActions[allowedaction].Label = allowedaction;
					This.RowActions[allowedaction].ConditionalParam = "";
					This.RowActions[allowedaction].Layout = "";
					This.RowActions[allowedaction].Target = "";
					ArrayAppend(This.RowActionOrder,allowedaction);
				} else {
					This.Actions[allowedaction] = StructNew();
					This.Actions[allowedaction].Name = allowedaction;
					This.Actions[allowedaction].Type = allowedaction;
					This.Actions[allowedaction].Label = allowedaction;
					This.Actions[allowedaction].ConditionalParam = "";
					This.Actions[allowedaction].Layout = "";
					This.Actions[allowedaction].Target = "";
					ArrayAppend(This.ActionOrder,allowedaction);
				}
			}
		}
		</cfscript>
				
		<cfreturn This>
	</cffunction>

	<cffunction name="AddColumn" description="Adds a column to the table." output="false" returntype="Column">
		<cfreturn CreateObject("component","Column").Init(arguments,This)>
	</cffunction>

	<cffunction name="Render" description="Displays table." output="true" returntype="void">
		<cfargument name="PageVariables" type="struct" required="true">
		<cfset Request.Table = This>
		<cfif Not StructKeyExists(PageVariables,"statusMessage")>
			<cfif StructKeyExists(url,"statusMessage")>
				<cfset PageVariables.statusMessage = url.statusMessage>
			<cfelse>
				<cfset PageVariables.statusMessage = "">
			</cfif>
		</cfif>
		<cfif Not StructKeyExists(PageVariables,"queryParams")>
			<cfif StructKeyExists(url,"queryParams")>
				<cfset PageVariables.queryParams = url.queryParams>
			<cfelse>
				<cfset PageVariables.queryParams = "">
			</cfif>
		</cfif>
	
		<!--- Set the current action --->
		<cfif StructKeyExists(url,"action")>
			<cfset Request.Table.action = url.action>
		<cfelseif StructKeyExists(form,"action")>
			<cfset Request.Table.action = form.action>
		<cfelseif StructKeyExists(PageVariables,"action")>
			<cfset Request.Table.action = PageVariables.action>
		<cfelse>
			<cfset Request.Table.action = Request.Table.DefaultAction>
		</cfif>
	
		<!---Add persistent params dynamically --->
		<cfif StructKeyExists(url,"lh_persistentParams")>
			<cfset Request.Table.persistentParams = Application.Lighthouse.addQueryParam(Request.Table.persistentParams,"lh_persistentParams",url.lh_persistentParams)>
			<cfloop list="#url.lh_persistentParams#" index="param">
				<cfif StructKeyExists(url,param)>
					<cfset Request.Table.persistentParams = Application.Lighthouse.addQueryParam(Request.Table.persistentParams,param,url[param])>
				</cfif>
			</cfloop>
		</cfif>
	
		<!--- If not simply processing form, display information at top of page --->
		<cfswitch expression="#Request.Table.Action#">
			<cfcase value="AddEditDoit">
				<cfinclude template="../Tags/MS_TableAddEditDoit.cfm">
			</cfcase>
	
			<cfcase value="ViewDoit">
				<cfinclude template="../Tags/MS_TableViewDoit.cfm">
			</cfcase>
	
			<cfdefaultcase>
				<!--- Construct queryParams, if necessary --->
				<cfif Len(PageVariables.queryParams) is 0>
					<cfset queryParams = "">
					<cfif Not StructKeyExists(url,"startRow")>
						<cfset url.startRow = "1">
					</cfif>
					<cfif Not StructKeyExists(url,"orderBy")>
						<cfset url.orderBy = "#Request.Table.table#.#Request.Table.ColumnOrder[1]#">
					</cfif>
					<cfif Not StructKeyExists(url,"Searching")>
						<cfif StructKeyExists(form,"Searching")>
							<cfset url.Searching = form.Searching>
						<cfelse>
							<cfset url.Searching = "false">
						</cfif>
					</cfif>
	
					<!--- Put all search criteria in queryParams so that it can be passed around --->
					<cfif url.Searching is "1">
						<cfset queryParams = Application.Lighthouse.addQueryParam(queryParams,"Searching","1")>
					</cfif>
					<cfif url.startRow is not 1>
						<cfset queryParams = Application.Lighthouse.addQueryParam(queryParams,"startrow",url.startRow)>
					</cfif>
					<cfif url.orderBy is not Request.Table.ColumnOrder[1]>
						<cfset queryParams = Application.Lighthouse.addQueryParam(queryParams,"orderBy",url.orderBy)>
					</cfif>
	
					<cfloop index="i" from="1" to="#ArrayLen(Request.Table.ColumnOrder)#">
						<cfset Column = Request.Table.Columns[Request.Table.ColumnOrder[i]]>
						<cfif Column.Search>
							<cfset queryParams = Request.Table.initializeSearchParam(Column,"",queryParams)>
						</cfif>
						<cfif StructKeyExists(url,"#Column.Name#_editCol")>
							<cfset queryParams = Application.Lighthouse.addQueryParam(queryParams,"#Column.Name#_editCol","1")>
						</cfif>
					</cfloop>
					<cfset PageVariables.queryParams = queryParams>
				<cfelse>
					<cfset queryParams = PageVariables.queryParams>
				</cfif>
	
				<cfif FindNoCase("Searching=1",PageVariables.queryParams)>
					<cfset url.Searching = true>
				<cfelse>
					<cfset url.Searching = false>
				</cfif>
	
				<!--- Make it easy to access current action info --->
				<cfif StructKeyExists(Request.Table.Actions,Request.Table.action)>
					<cfset ActionStruct = Request.Table.Actions[Request.Table.action]>
				<cfelse>
					<cfset ActionStruct = Request.Table.RowActions[Request.Table.action]>
				</cfif>
				
				<cfswitch expression="#ActionStruct.Type#">
					<cfcase value="Add,Edit">
						<cfinclude template="../Tags/MS_TableAddEditInit.cfm">
					</cfcase>
					<cfcase value="DisplayOptions">
						<cfif ActionStruct.Label is "DisplayOptions">
							<cfset ActionStruct.Label = "Display Options">
						</cfif>
					</cfcase>
				</cfswitch>
	
				<cfinclude template="#Request.Table.layout#">
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

	<cffunction name="InitializeView" output="false" returntype="void">
		<!---If new list of columns passed in url, set user data 
		Get user data --->
		<cfif StructKeyExists(url,"lh_ViewColumns")>
			<cfif StructKeyExists(url,"lh_TempView")>
				<cfset Request.Table.ViewColumnsList = url.lh_ViewColumns>
			<cfelse>
				<cfset Request.Table.ViewColumnsList = Application.Lighthouse.lh_setClientInfo("dispColumns_#Request.Table.ID#",url.lh_ViewColumns)>
			</cfif>
		<cfelse>
			<cfset Request.Table.ViewColumnsList = Application.Lighthouse.lh_getClientInfo("dispColumns_#Request.Table.ID#")>
		</cfif>
		<cfif StructKeyExists(url,"lh_MaxRows")>
			<cfif StructKeyExists(url,"lh_TempView")>
				<cfset Request.Table.MaxRows = url.lh_maxRows>
			<cfelse>
				<cfset Request.Table.MaxRows = Application.Lighthouse.lh_setClientInfo("maxRows_#Request.Table.ID#",url.lh_MaxRows)>
			</cfif>
		<cfelse>
			<cfset Request.Table.MaxRows = Application.Lighthouse.lh_getClientInfo("maxRows_#Request.Table.ID#","15")>
		</cfif>
		<cfif StructKeyExists(url,"lh_ColumnOrder")>
			<cfif StructKeyExists(url,"lh_TempView")>
				<cfset Request.Table.ColumnOrderList = url.lh_ColumnOrder>
			<cfelse>
				<cfset Request.Table.ColumnOrderList = Application.Lighthouse.lh_setClientInfo("columnOrder_#Request.Table.ID#",url.lh_ColumnOrder)>
			</cfif>
		<cfelse>
			<cfset Request.Table.ColumnOrderList = Application.Lighthouse.lh_getClientInfo("columnOrder_#Request.Table.ID#")>
		</cfif>
		<cfset Request.Table.StyleIDColumns = "">
	</cffunction>

	<cffunction name="AddQueryColumn" output="false" returntype="void">
		
		<cfargument name="QueryInfo" required="true" type="struct">
		<cfargument name="Column" required="true" type="struct">
		<cfargument name="table" required="true" type="string">
		<cfargument name="prefix" type="string" default="">
	
		<cfif Arguments.Column.Hidden>
			<cfset Arguments.Column.View = false>
		</cfif>
	
		<!--- some column types are equivalent to others for the purposes of this page. --->
		<cfswitch expression="#Arguments.Column.Type#">
			<cfcase value="radio,select-popup">
				<cfset Arguments.Column.Type = "select">
			</cfcase>
			<cfcase value="checkboxgroup">
				<cfset Arguments.Column.Type = "select-multiple">
			</cfcase>
			<cfcase value="Timestamp">
				<cfset Arguments.Column.Type = "Date">
			</cfcase>
		</cfswitch>
	
		<cfif Arguments.Column.Type is "select" and Len(Arguments.Column.ValueList) gt 0>
			<cfset Arguments.Column.Type = "Text">
		</cfif>
	
		<cfif Arguments.Column.StyleID>
			<cfset This.StyleIDColumns = ListAppend(This.StyleIDColumns,Arguments.Column.Name)>
		</cfif>
	
		<!--- Is this column being edited? --->
		<cfif Arguments.Column.AllowColumnEdit and Arguments.Column.Editable
				and len(url.reportType) is 0 and IsDefined(Arguments.Column.Name & "_editCol")>
			<cfset Request.ColumnEdit = true>
			<cfset Arguments.Column.DoEdit = true>
		<cfelse>
			<cfset Arguments.Column.DoEdit = false>
		</cfif>
	
		<cfswitch expression="#Arguments.Column.Type#">
			<cfcase value="select">
				<cfif IsDefined(Arguments.Column.Name & "_editCol") or Arguments.Column.StyleID
						or Len(Arguments.Column.ChildColumn) gt 0>
					<cfset Arguments.QueryInfo.selectClause = ListAppend(Arguments.QueryInfo.selectClause,"#Arguments.Table#.#Arguments.Column.Name#")>
				</cfif>
				<cfset Arguments.Column.FKTableAlias = Arguments.Column.Name & "JoinTable">
				<cfif Arguments.Column.View or Find(Arguments.Column.FKTableAlias,url.orderBy) gt 0>
					<!--- affix table alias to column names in fkdescr when adding to select clause --->
					<cfset qualifiedDescr = "">
					<cfset qualify = true>
					<cfset previousChar = " ">
					<cfloop index="i" from="1" to="#Len(Arguments.Column.FKDescr)#">
						<cfset theChar = Mid(Arguments.Column.FKDescr,i,1)>
						<cfif theChar is "'">
							<cfset qualify = not qualify>
						</cfif>
						<cfif qualify and previousChar is " " and REFind("[[:alpha:]]",theChar) is 1>
							<cfset qualifiedDescr = qualifiedDescr & Arguments.Column.FKTableAlias & "." & theChar>
						<cfelse>
							<cfset qualifiedDescr = qualifiedDescr & theChar>
						</cfif>
						<cfset previousChar = theChar>
					</cfloop>
					<cfset Arguments.QueryInfo.selectClause = ListAppend(Arguments.QueryInfo.selectClause,"#qualifiedDescr# as #Arguments.Column.Name#_Descr")>
					<cfset Arguments.QueryInfo.fromClause = "(#Arguments.QueryInfo.fromClause# left join #Arguments.Column.FKTable# as #Arguments.Column.FKTableAlias# on #Arguments.Table#.#Arguments.Column.Name# = #Arguments.Column.FKTableAlias#.#Arguments.Column.FKColName#)">
					<cfset Arguments.Column.QualifiedDescr = QualifiedDescr>
				</cfif>
			</cfcase>
			<cfcase value="Pseudo">
				<cfif Len(Arguments.Column.Expression) gt 0>
					<!--- Note that pseudo column uses special columns to be added to select clause --->
					<cfset Arguments.QueryInfo.orderByClause = ReplaceNoCase(Arguments.QueryInfo.orderByClause,Arguments.Column.Name,Arguments.Column.expression)>
				</cfif>
			</cfcase>
			<cfcase value="ChildTable">
				<!--- Create structure to hold query info --->
				<cfif Not IsDefined("Request.ChildTableQueryInfo")>
					<cfset Request.ChildTableQueryInfo = StructNew()>
				</cfif>
				<cfset Request.ChildTableQueryInfo[Arguments.Column.Name] = StructNew()>
				<cfset Request.ChildTableQueryInfo[Arguments.Column.Name].selectClause = "">
				<!---<cfset Request.ChildTableQueryInfo[Arguments.Column.Name].selectClause = Arguments.Column.Name & "." & Arguments.Column.PrimaryKey> --->
				<cfset Request.ChildTableQueryInfo[Arguments.Column.Name].fromClause = Arguments.Column.Name>
				<cfset Request.ChildTableQueryInfo[Arguments.Column.Name].orderByClause = "">
				<cfset Request.ChildTableQueryInfo[Arguments.Column.Name].whereClause = "">
				<cfset Request.ChildTableQueryInfo[Arguments.Column.Name].tableHeader = "<tr>">
				<cfset Request.ChildTableQueryInfo[Arguments.Column.Name].viewColumns = ArrayNew(1)>
				<!--- build query info for child table --->
				<cfloop index="i" from="1" to="#ArrayLen(Arguments.Column.ColumnOrder)#">
					<cfset ChildColumn = Arguments.Column.Columns[Arguments.Column.ColumnOrder[i]]>
					<!--- There is currently no way for the user to change the columns that are viewed --->
					<cfif ChildColumn.DefaultView>
						<cfset ChildColumn.View = true>
					</cfif>
					<cfif ChildColumn.View>
						<cfset Request.ChildTableQueryInfo[Arguments.Column.Name].tableHeader = Request.ChildTableQueryInfo[Arguments.Column.Name].tableHeader & "<th>" & ChildColumn.DispName & "</th>">
						<cfset ArrayAppend(Request.ChildTableQueryInfo[Arguments.Column.Name].viewColumns,ChildColumn)>
					</cfif>
					<cfset This.addQueryColumn(Request.ChildTableQueryInfo[Arguments.Column.Name],ChildColumn,Arguments.Column.Name,Arguments.Column.Name & "_")>
				</cfloop>
				<cfset Request.ChildTableQueryInfo[Arguments.Column.Name].tableHeader = Request.ChildTableQueryInfo[Arguments.Column.Name].tableHeader & "</tr>">
			</cfcase>
			<cfdefaultcase>
				<cfif (Arguments.Column.View or Arguments.Column.StyleID or Len(Arguments.Column.ChildColumn) gt 0)
						and Arguments.Column.Name is not This.PrimaryKey
						and Arguments.Column.Type is not "select-multiple"
						and Arguments.column.Type is not "select-multiple-popup">
					<cfset Arguments.QueryInfo.selectClause = ListAppend(Arguments.QueryInfo.selectClause,"#Arguments.table#.#Arguments.Column.Name#")>
				</cfif>
			</cfdefaultcase>
		</cfswitch>
		
		<!--- Build where clause --->
		<cfif Arguments.Column.Search>
			<cfset parameterName = Arguments.Prefix & Arguments.Column.Name>
			<cfif Len(url[ParameterName & "_nullOnly"]) gt 0>
				<cfset url[ParameterName] = "null">
			</cfif>
	
			<cfif Len(url[ParameterName]) gt 0 or (Arguments.Column.Type is "Date" and Len(url["#ParameterName#_end"]) gt 0) or Arguments.Column.Type is "ChildTable">
				<cfset SearchedValue = url[ParameterName]>
				<cfswitch expression="#Arguments.Column.Type#">
					<cfcase value="Select">
						<cfif Arguments.Column.FKType is "text">
							<cfset SearchedValue = Application.Lighthouse.sqlStringListFormat(SearchedValue)>
						</cfif>
						<cfset Arguments.QueryInfo.whereClause = Arguments.QueryInfo.whereClause & " and (#Arguments.Table#.#Arguments.Column.Name# in (#SearchedValue#)">
						<!--- Handle null searches --->
						<cfif ListFind(SearchedValue,"null")>
							<cfset Arguments.QueryInfo.whereClause = Arguments.QueryInfo.whereClause & " or #Arguments.Table#.#Arguments.Column.Name# is null">
						</cfif>
						<cfset Arguments.QueryInfo.whereClause = Arguments.QueryInfo.whereClause & ") ">
					</cfcase>
					<cfcase value="Select-multiple,select-multiple-popup">
						<cfset Arguments.QueryInfo.whereClause = Arguments.QueryInfo.whereClause & " and (exists (select * from #Arguments.Column.FKJoinTable# where #Arguments.Column.PKColName# = #Arguments.Table#.#This.PrimaryKey# and #Arguments.Column.FKColName# in ">
						<cfif Arguments.Column.FKType is "text">
							<cfset Arguments.QueryInfo.whereClause = Arguments.QueryInfo.whereClause & "(" & ListQualify(SearchedValue,"'") & "))">
						<cfelse>
							<cfset Arguments.QueryInfo.whereClause = Arguments.QueryInfo.whereClause & "(" & SearchedValue & "))">
						</cfif>
						<!--- Handle null searches --->
						<cfif ListFind(SearchedValue,"null")>
							<cfset Arguments.QueryInfo.whereClause = Arguments.QueryInfo.whereClause & " or not exists (select * from #Arguments.Column.FKJoinTable# where #Arguments.Column.PKColName# = #Arguments.Table#.#This.PrimaryKey#)">
						</cfif>
						<cfset Arguments.QueryInfo.whereClause = Arguments.QueryInfo.whereClause & ") ">
					</cfcase>
					<cfcase value="Integer">
						<cfif Len(url["#ParameterName#_nullOnly"]) gt 0>
							<cfset Arguments.QueryInfo.whereClause = ListAppend(Arguments.QueryInfo.whereClause," and #Arguments.Table#." & Arguments.Column.Name & " is null "," ")>
						<cfelseif  Len(url["#ParameterName#_end"]) gt 0>
							<cfparam name="SearchedValue" type="numeric">
							<cfparam name="url.#ParameterName#_end" type="numeric">
							<cfset Arguments.QueryInfo.whereClause = ListAppend(Arguments.QueryInfo.whereClause," and #Arguments.Table#." & Arguments.Column.Name & " between #SearchedValue# and #url["#ParameterName#_end"]#"," ")>
						<cfelse>
							<cfparam name="SearchedValue" type="numeric">
							<cfset Arguments.QueryInfo.whereClause = ListAppend(Arguments.QueryInfo.whereClause," and #Arguments.Table#." & Arguments.Column.Name & " = #SearchedValue#"," ")>
						</cfif>
					</cfcase>
					<cfcase value="Pseudo">
						<cfif len(Arguments.Column.includeFile) is 0>
							<cfif Len(url["#ParameterName#_end"]) gt 0>
								<cfset Arguments.QueryInfo.whereClause = ListAppend(Arguments.QueryInfo.whereClause," and #Arguments.Column.expression# between #SearchedValue# and #url["#ParameterName#_end"]#"," ")>
							<cfelse>
								<cfset Arguments.QueryInfo.whereClause = ListAppend(Arguments.QueryInfo.whereClause," and #Arguments.Column.expression# = #SearchedValue#"," ")>
							</cfif>
						</cfif>
					</cfcase>
					<cfcase value="Date">
						<cfset SearchedValue_end=url["#ParameterName#_end"]>
						<cfif Column.Format is "DD/MM/YYYY">
							<cfset SV1=ListGetAt(SearchedValue,1,'/')>
							<cfset SV2=ListGetAt(SearchedValue,2,'/')>
							<cfset SV3=ListGetAt(SearchedValue,3,'/')>
							<cfset SearchedValue=SV2 & '/' & SV1 & '/' & SV3>								
							<cfif Len(SearchedValue_end)>
								<cfset SVe1=ListGetAt(SearchedValue_end,1,'/')>
								<cfset SVe2=ListGetAt(SearchedValue_end,2,'/')>
								<cfset SVe3=ListGetAt(SearchedValue_end,3,'/')>
								<cfset SearchedValue_end=SVe2 & '/' & SVe1 & '/' & SVe3>
							</cfif>
						</cfif>
						<cfif Len(url["#ParameterName#_nullOnly"]) gt 0>
							<cfset Arguments.QueryInfo.whereClause = ListAppend(Arguments.QueryInfo.whereClause," and #Arguments.Table#." & Arguments.Column.Name & " is null "," ")>
						<cfelseif  Len(SearchedValue) gt 0 and Len(SearchedValue_end) gt 0>
							<cfset Arguments.QueryInfo.whereClause = ListAppend(Arguments.QueryInfo.whereClause," and #Arguments.Table#." & Arguments.Column.Name & " between #CreateODBCDate(SearchedValue)# and #CreateODBCDateTime(DateAdd("n",1439,SearchedValue_end))#"," ")>
						<cfelseif  Len(SearchedValue_end) gt 0>
							<cfset Arguments.QueryInfo.whereClause = ListAppend(Arguments.QueryInfo.whereClause," and #Arguments.Table#." & Arguments.Column.Name & " <= #CreateODBCDateTime(DateAdd("n",1439,SearchedValue_end))#"," ")>
						<cfelse>
							<cfset Arguments.QueryInfo.whereClause = ListAppend(Arguments.QueryInfo.whereClause," and #Arguments.Table#." & Arguments.Column.Name & " >= #CreateODBCDate(SearchedValue)#"," ")>
						</cfif>
					</cfcase>
					<cfcase value="ChildTable">
						<!--- Add where clause info to main query --->
						<cfif Request.ChildTableQueryInfo[Arguments.Column.Name].whereClause is not "">
							<cfset Arguments.QueryInfo.whereClause = Arguments.QueryInfo.whereClause &
								" and #This.PrimaryKey# IN (SELECT #This.PrimaryKey# FROM #Arguments.Column.Name# WHERE 1=1 #Request.ChildTableQueryInfo[Arguments.Column.Name].whereClause#) ">
						</cfif>
					</cfcase>
					<cfdefaultcase>
						<cfif Len(url["#ParameterName#_nullOnly"]) gt 0>
							<cfset Arguments.QueryInfo.whereClause = ListAppend(Arguments.QueryInfo.whereClause," and #Arguments.Table#." & Arguments.Column.Name & " = '' "," ")>
						<cfelse>
							<cfswitch expression="#Arguments.Column.SearchType#">
								<cfcase value="StartsWith">
									<cfset Arguments.QueryInfo.whereClause = ListAppend(Arguments.QueryInfo.whereClause," and #Arguments.Table#." & Arguments.Column.Name & " like '#Application.Lighthouse.sqlStringFormat(SearchedValue)#%'"," ")>
								</cfcase>
								<cfcase value="Contains">
									<cfset Arguments.QueryInfo.whereClause = ListAppend(Arguments.QueryInfo.whereClause," and #Arguments.Table#." & Arguments.Column.Name & " like '%#Application.Lighthouse.sqlStringFormat(SearchedValue)#%'"," ")>
								</cfcase>
								<cfdefaultcase>
									<cfset Arguments.QueryInfo.whereClause = ListAppend(Arguments.QueryInfo.whereClause," and #Arguments.Table#." & Arguments.Column.Name & " = '#Application.Lighthouse.sqlStringFormat(SearchedValue)#'"," ")>
								</cfdefaultcase>
							</cfswitch>
						</cfif>
					</cfdefaultcase>
				</cfswitch>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="InitializeSearchParam" output="false" returntype="string">
		<cfargument name="Column" type="struct" required="true">
		<cfargument name="Prefix" type="string" required="true">
		<cfargument name="queryParams" type="string" required="true">
		<cfset var parameterName = Prefix & Arguments.Column.Name>
		<cfif Not StructKeyExists(url,ParameterName)>
			<cfif StructKeyExists(form,ParameterName)>
				<cfset url[ParameterName] = form[ParameterName]>
			<cfelse>
				<cfset url[ParameterName] = "">
			</cfif>
		</cfif>
		<cfif Not StructKeyExists(url,"#ParameterName#_nullOnly")>
			<cfif StructKeyExists(form,"#ParameterName#_nullOnly")>
				<cfset url[ParameterName & "_nullOnly"] = form[ParameterName & "_nullOnly"]>
			<cfelse>
				<cfset url[ParameterName & "_nullOnly"] = "">
			</cfif>
		</cfif>
		<cfif Len(url[ParameterName]) gt 0>
			<cfset queryParams = Application.Lighthouse.addQueryParam(queryParams,ParameterName,url[ParameterName])>
		</cfif>
		<cfif Len(url[ParameterName & "_nullOnly"]) gt 0>
			<cfset queryParams = Application.Lighthouse.addQueryParam(queryParams,"#ParameterName#_nullOnly",url[ParameterName & "_nullOnly"])>
		</cfif>
		<cfif ListFindNoCase("Date,Timestamp,Integer,Pseudo",Arguments.Column.Type)>
			<cfif Not StructKeyExists(url,"#ParameterName#_end")>
				<cfif StructKeyExists(form,"#ParameterName#_end")>
					<cfset url[ParameterName & "_end"] = form[ParameterName & "_end"]>
				<cfelse>
					<cfset url[ParameterName & "_end"] = "">
				</cfif>
			</cfif>
			<cfif Len(url["#ParameterName#_end"]) gt 0>
				<cfset queryParams = Application.Lighthouse.addQueryParam(queryParams,"#ParameterName#_end",url["#ParameterName#_end"])>
			</cfif>
		<cfelseif Arguments.Column.Type is "ChildTable">
			<cfloop collection="#Column.Columns#" item="ChildColName">
				<cfset ChildColumn = Column.Columns[childColName]>
				<cfif ChildColumn.Search>
					<cfset queryParams = initializeSearchParam(ChildColumn,Arguments.Column.Name & "_",queryParams)>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn queryParams>
	</cffunction>
	
	<cffunction name="getNextId" output="false" returntype="numeric">
		<cfargument name="tableName" required="true" type="string">
		<cfargument name="primaryKey" required="true" type="string">
		
		<cftry>
			<cfquery name="getLastID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT LastID FROM #Request.Table.IDTable# 
				WHERE TableName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tableName#">
			</cfquery>
			<cfcatch>
				<cftry>
					<cfquery name="createIDTable" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						CREATE TABLE #Request.Table.IDTable# (TableName varchar(32), LastID int)
					</cfquery>
					<cfcatch><cfthrow message="Unable to create ID table #Request.Table.IDTable#."></cfcatch>
				</cftry>
				<cfset getLastID.recordCount = 0>
			</cfcatch>
		</cftry>
		<cfif getLastID.recordCount gt 0>
			<cfset nextID = getLastID.LastID + 1>
			<cfquery name="updateLastID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				UPDATE #Request.Table.IDTable#
				SET LastID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nextID#">
				WHERE TableName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tableName#">
			</cfquery>
		<cfelse>
			<cfquery name="getMaxID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT max(#PrimaryKey#) as max FROM #tableName#
			</cfquery>
			<cfif IsNumeric(getMaxID.max)>
				<cfset nextID = getMaxID.max + 1>
			<cfelse>
				<cfset nextID = 1>
			</cfif>
			<cfquery name="updateLastID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				INSERT INTO #Request.Table.IDTable# (TableName,LastID)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#tableName#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#nextID#">
				)
			</cfquery>
		</cfif>
		<cfreturn nextID>
	</cffunction>
	
	<cffunction name="getSqlValue" output="false" returntype="struct">
		<cfargument name="Column" type="Column" required="true">
		<cfargument name="isUpdate" type="boolean" required="true">
		<cfargument name="fieldId" type="string" default="#Column.Name#">
		
		<cfif Not StructKeyExists(form,arguments.fieldId)>
			<cfset form[arguments.fieldId] = "">
		</cfif>
		
		<cfswitch expression="#Column.Type#">
			<cfcase value="File">
				<!--- File upload --->
				<cfparam name="form.#arguments.fieldId#_OldFile" default="">
				<cfparam name="form.#arguments.fieldId#_Delete" default="">
				<cfset oldFile = StripCR(Trim(form[arguments.fieldId & "_OldFile"]))>
				<cfset deleteFile = StripCR(Trim(form[arguments.fieldId & "_Delete"]))>
				<cfset value = oldFile>
			
				<!--- Get destination from path.  Path should be relative to server root. --->
				<cfset destination = ExpandPath(Application.Lighthouse.getBaseRelativePath() & Column.Directory & "/")>
			
				<!--- Delete old file --->
				<cfif Len(oldFile) gt 0 and deleteFile is "Y">
					<cfif FileExists("#destination##oldFile#")>
						<cffile action="Delete" file="#destination##oldFile#">
						<cfset value = "">
					</cfif>
				</cfif>
			
				<!--- Upload new file --->
				<cfif Len(form[arguments.fieldId]) gt 0>
					<cfset cffile = UploadFile(
						FileField = arguments.fieldId, 
						Destination = destination, 
						NameConflict = Column.NameConflict,
						TempDirectory = Application.TempDirectory
					)>
					<cfset value = cffile.ServerFile>
				</cfif>
			</cfcase>
			<cfcase value="date">
				<cfif Not Column.ShowDate>
					<cfset value="01/01/1900">
				<cfelse>
					<cfset value = Trim(form[arguments.fieldId])>
					<cfif FindNoCase("d",Column.Format) is 1 and Len(value)>
						<!--- Handle d/m/yyyy formats --->
						<cfset value = DateFormat(LSParseDateTime(form[arguments.fieldId],"en_GB"))>
					</cfif>
				</cfif>
				<cfif Column.ShowTime>
					<cfif Column.ShowDate and not Len(value)>
						<cfset value="">
					<cfelse>
						<cfset hour = NumberFormat(form[arguments.fieldId & "_Hour"],"00")>
						<cfset minute = NumberFormat(form[arguments.fieldId & "_Minute"],"00")>
						<cfif hour is "00"><cfset hour = "12"></cfif>
						<cfset value = value & " #hour#:#minute# #form[arguments.fieldId & "_AMPM"]#">
					</cfif>
				</cfif>
			</cfcase>
			<cfcase value="textarea">
				<cfset value = Trim(form[arguments.fieldId])>
			</cfcase>
			<cfdefaultcase>
				<!--- Strip carriage returns to avoid bugs with Mac browsers --->
				<cfset value = StripCR(Trim(form[arguments.fieldId]))>
			</cfdefaultcase>
		</cfswitch>
		<cfreturn Column.getQueryParam(isUpdate,value)>	
	</cffunction>
</cfcomponent>