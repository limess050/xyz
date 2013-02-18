<cfcomponent name="Column" hint="Defines a column in a data table." extends="Object">

	<cffunction name="Init" description="Instantiate a column." output="false" returntype="Column">
		<cfargument name="Properties" required="true" type="struct">
		<cfargument name="Table" required="true" type="struct">
		<cfscript>
		This.Name = Properties.ColName;
		This.Order = StructCount(Table.Columns);
		This.View = false;
		This.ColumnGroup = Table.CurrentColumnGroup;
		Table.Columns[This.Name] = This;
		ArrayAppend(Table.ColumnOrder,This.Name);
		
		SetProperty(Properties,"DispName",Properties.ColName);
		SetProperty(Properties,"Type","text");
		SetProperty(Properties,"PrimaryKey",false);
		SetProperty(Properties,"Identity",false);
		SetProperty(Properties,"RelatedTables","");
		SetProperty(Properties,"OrderBy","");
		SetProperty(Properties,"FormFieldParameters","");
		SetProperty(Properties,"MaxLength","");
		SetProperty(Properties,"Required",false);
		SetProperty(Properties,"DefaultValue","");
		SetProperty(Properties,"Format","");
		SetProperty(Properties,"Validate","");
		SetProperty(Properties,"SpellCheck",false);
		SetProperty(Properties,"Unique",false);
		SetProperty(Properties,"Editable",Table.editable);
		SetProperty(Properties,"AllowView",true);
		
		if (StructKeyExists(Properties,"View")) This.DefaultView = Properties.View;
		else This.DefaultView = true;
		
		if (StructKeyExists(Properties,"Search")) This.Search = Properties.Search;
		else if (StructKeyExists(Table,"Search")) This.Search = Table.Search;
		else This.Search = true;
		
		SetProperty(Properties,"SearchType","Contains");
		SetProperty(Properties,"StyleID",false);
		SetProperty(Properties,"HelpText","");
		SetProperty(Properties,"ShowTotal",false);
		SetProperty(Properties,"Hidden",false);
		SetProperty(Properties,"AllowColumnEdit",Table.AllowColumnEdit);
		SetProperty(Properties,"ParentColumn","");
		SetProperty(Properties,"ChildColumn","");
		SetProperty(Properties,"AllowHTML",false);
		SetProperty(Properties,"ClassName","");
		
		// There is currently no difference between the way Floats and integers are handled:
		if (This.Type is "Float") This.Type = "integer";
		
		//  set default formfieldparameters for text fields
		if (This.Type is "text" and Len(This.FormFieldParameters) is 0 and Len(This.MaxLength) gt 0) {
			This.FormFieldParameters = "size=#Min(40,This.MaxLength)#";
		}
		
		// Set values in MS_Table
		if (This.PrimaryKey) {
			Table.PrimaryKey = This.Name;
			This.Required = true;
			if (Len(This.RelatedTables) gt 0) {
				Table.RelatedTables = This.RelatedTables;
			}
		}
		
		// Set order by
		if (Len(This.OrderBy) and Not IsDefined("url.orderBy")) {
			url.orderBy = Table.table & "." & This.Name;
			if (This.OrderBy is "desc") {
				url.orderBy = url.orderBy & " desc";
			}
		}
		
		// Type specific attributes
		switch (This.Type) {
			case "Integer": {
				This.CfSqlType = "CF_SQL_FLOAT";
				break;
			}
			case "Text": {
				SetProperty(Properties,"Unicode",false);
				This.CfSqlType = "CF_SQL_VARCHAR";
				break;
			}
			case "Textarea": {
				SetProperty(Properties,"Toolbars","Main,Tables");
				SetProperty(Properties,"ImageDir","");
				SetProperty(Properties,"SiteEditor","No");
				SetProperty(Properties,"HtmlEditor","");
				SetProperty(Properties,"HtmlEditorParameters","");
				SetProperty(Properties,"Unicode",false);
				if (This.SearchType is "Equals") This.SearchType = "Contains";
				This.CfSqlType = "CF_SQL_LONGVARCHAR";
				break;
			}
			case "Date": {
				SetProperty(Properties,"ShowDate",true);
				SetProperty(Properties,"ShowTime",false);
				if (Len(This.Format) is 0) This.Format = "m/d/yyyy";
				SetProperty(Properties,"TimeFormat","h:mm tt");
				This.CfSqlType = "CF_SQL_TIMESTAMP";
				break;
			}
			case "TimeStamp": {
				SetProperty(Properties,"ShowDate",true);
				SetProperty(Properties,"ShowTime",true);
				if (Len(This.Format) is 0) This.Format = "m/d/yyyy";
				SetProperty(Properties,"TimeFormat","h:mm tt");
				SetProperty(Properties,"StampOnEdit",false);
				This.CfSqlType = "CF_SQL_TIMESTAMP";
				break;
			}
			case "Pseudo": {
				SetProperty(Properties,"Expression","");
				SetProperty(Properties,"includeFile","");
				SetProperty(Properties,"showOnEdit",false);
				This.Editable = false;
				if (Len(This.Expression) gt 0) {
					// record special column that must be returned
					SpecialColumn = StructNew();
					SpecialColumn.Name = This.Name;
					SpecialColumn.Expression = This.expression;
					ArrayAppend(Table.SpecialColumns,SpecialColumn);
				}
				break;
			}
			case "File": {
				SetProperty(Properties,"Directory","");
				SetProperty(Properties,"NameConflict","MakeUnique");
				SetProperty(Properties,"DeleteWithRecord",false);
				SetProperty(Properties,"ShowFileBrowser",false);
				This.CfSqlType = "CF_SQL_VARCHAR";
				break;
			}
			case "Checkbox": {
				SetProperty(Properties,"OnValue","Y");
				SetProperty(Properties,"OffValue","N");
				SetProperty(Properties,"OnDisplayValue","Yes");
				SetProperty(Properties,"OffDisplayValue","No");
				if (IsNumeric(This.OnValue)) {
					This.CfSqlType = "CF_SQL_BIT";
				} else {
					This.CfSqlType = "CF_SQL_CHAR";
				}
				break;
			}
			case "Radio": {
				SetProperty(Properties,"ValueList","");
				SetProperty(Properties,"FKTable","");
				SetProperty(Properties,"FKColName",This.Name);
				SetProperty(Properties,"FKType","integer");
				SetProperty(Properties,"FKDescr","");
				SetProperty(Properties,"FKWhere","");
				SetProperty(Properties,"FKOrderBy",This.FKDescr);
				SetProperty(Properties,"SelectQuery","");
				SetProperty(Properties,"Group","");
				SetProperty(Properties,"RadioCols",3);
				if (This.FKType is "integer") {
					This.CfSqlType = "CF_SQL_INTEGER";
				} else {
					This.CfSqlType = "CF_SQL_VARCHAR";
				}
				break;
			}
			case "select": {
				SetProperty(Properties,"ValueList","");
				SetProperty(Properties,"FKTable","");
				SetProperty(Properties,"FKColName",This.Name);
				SetProperty(Properties,"FKType","integer");
				SetProperty(Properties,"FKDescr","");
				SetProperty(Properties,"FKWhere","");
				SetProperty(Properties,"FKOrderBy",This.FKDescr);
				SetProperty(Properties,"SelectQuery","");
				SetProperty(Properties,"Group","");
				This.SetProperty(Properties,"AutoComplete",false);
				This.SetProperty(Properties,"ComboBox",false);
				if (This.FKType is "integer") {
					This.CfSqlType = "CF_SQL_INTEGER";
				} else {
					This.CfSqlType = "CF_SQL_VARCHAR";
				}
				break;
			}
			case "select-popup": {
				SetProperty(Properties,"ValueList","");
				SetProperty(Properties,"FKTable","");
				SetProperty(Properties,"FKColName",This.Name);
				SetProperty(Properties,"FKType","integer");
				SetProperty(Properties,"FKDescr","");
				SetProperty(Properties,"FKWhere","");
				SetProperty(Properties,"FKOrderBy",This.FKDescr);
				SetProperty(Properties,"SelectQuery","");
				SetProperty(Properties,"PopupURL","");
				SetProperty(Properties,"ViewURL","");
				SetProperty(Properties,"AutoSelect",false);
				This.Group = "";
				This.AutoComplete = false;
				This.ComboBox = false;
				if (This.FKType is "integer") {
					This.CfSqlType = "CF_SQL_INTEGER";
				} else {
					This.CfSqlType = "CF_SQL_VARCHAR";
				}
				break;
			}
			case "Checkboxgroup": {
				SetProperty(Properties,"ValueList","");
				SetProperty(Properties,"FKTable","");
				SetProperty(Properties,"PKColName",Table.PrimaryKey);
				SetProperty(Properties,"FKColName",This.Name);
				SetProperty(Properties,"FKType","integer");
				SetProperty(Properties,"FKDescr","");
				SetProperty(Properties,"FKWhere","");
				SetProperty(Properties,"FKOrderBy",This.FKDescr);
				SetProperty(Properties,"FKJoinTable","");
				SetProperty(Properties,"SelectQuery","");
				SetProperty(Properties,"Group","");
				SetProperty(Properties,"ShowCheckAll",true);
				SetProperty(Properties,"CheckboxCols",3);
				SetProperty(Properties,"SubqueryMethod","structure");
				if (This.FKType is "integer") {
					This.CfSqlType = "CF_SQL_INTEGER";
				} else {
					This.CfSqlType = "CF_SQL_VARCHAR";
				}
				break;
			}
			case "select-multiple": {
				SetProperty(Properties,"ValueList","");
				SetProperty(Properties,"FKTable","");
				SetProperty(Properties,"PKColName",Table.PrimaryKey);
				SetProperty(Properties,"FKColName",This.Name);
				SetProperty(Properties,"FKType","integer");
				SetProperty(Properties,"FKDescr","");
				SetProperty(Properties,"FKWhere","");
				SetProperty(Properties,"FKOrderBy",This.FKDescr);
				SetProperty(Properties,"FKJoinTable","");
				SetProperty(Properties,"SelectQuery","");
				SetProperty(Properties,"Group","");
				SetProperty(Properties,"SubqueryMethod","structure");
				if (This.FKType is "integer") {
					This.CfSqlType = "CF_SQL_INTEGER";
				} else {
					This.CfSqlType = "CF_SQL_VARCHAR";
				}
				break;
			}
			case "select-multiple-popup": {
				SetProperty(Properties,"ValueList","");
				SetProperty(Properties,"FKTable","");
				SetProperty(Properties,"PKColName",Table.PrimaryKey);
				SetProperty(Properties,"FKColName",This.Name);
				SetProperty(Properties,"FKType","integer");
				SetProperty(Properties,"FKDescr","");
				SetProperty(Properties,"FKWhere","");
				SetProperty(Properties,"FKOrderBy",This.FKDescr);
				SetProperty(Properties,"FKJoinTable","");
				SetProperty(Properties,"OrderColumn","");
				SetProperty(Properties,"PopupURL","");
				SetProperty(Properties,"ViewURL","");
				SetProperty(Properties,"SubqueryMethod","structure");
				This.SelectQuery = "";
				This.group = "";
				if (This.FKType is "integer") {
					This.CfSqlType = "CF_SQL_INTEGER";
				} else {
					This.CfSqlType = "CF_SQL_VARCHAR";
				}
				break;
			}
		}
		</cfscript>
		<cfreturn This>
	</cffunction>

	<cffunction name="getValueFromQuery" output="false" returntype="string">
		<cfargument name="valueQuery" type="Query" default="#getRecords#">
		<cfargument name="MainQueryInfo" type="Struct">
	
		<cfswitch expression="#This.Type#">
			<cfcase value="Select">
				<cfset value = valueQuery[This.Name & "_Descr"][valueQuery.CurrentRow]>
			</cfcase>
			<cfcase value="Select-multiple,select-multiple-popup">
				<cfif This.SubqueryMethod is "structure"
						or This.SubqueryMethod is "queryOfQuery">
					<cfif Not StructKeyExists(variables,This.Name & "_MasterQuery")>
						<!--- If paging through results, get list of ids for the rows that will be displayed --->
						<cfif Len(url.reportType) is 0 and Request.Table.MaxRows gt 0 and Request.Table.MaxRows lte 100>
							<cfset MasterQueryIDs = valueQuery[Request.Table.PrimaryKey][url.startRow]>
							<cfloop index="i" from="#IncrementValue(url.startRow)#" to="#Min(url.startRow + Request.Table.MaxRows,valueQuery.recordCount)#">
								<cfset MasterQueryIDs = MasterQueryIDs & "," & valueQuery[Request.Table.PrimaryKey][i]>
							</cfloop>
							<cfset useIDList = true>
						<cfelse>
							<cfset useIDList = false>
						</cfif>
						<cfquery name="#This.Name#_MasterQuery" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							SELECT #This.FKJoinTable#.#This.PKColName# as ID,#PreserveSingleQuotes(This.FKDescr)# as SelectDescr
							FROM #This.FKTable# INNER JOIN #This.FKJoinTable# on #This.FKTable#.#This.FKColName# = #This.FKJoinTable#.#This.FKColName#
							WHERE #This.FKJoinTable#.#This.PKColName# IN (
								<cfif useIDList>
									<cfqueryparam cfsqltype="cf_sql_integer" value="#MasterQueryIds#" list="true">
								<cfelse>
									SELECT #Request.Table.PrimaryKey#
									FROM #Arguments.MainQueryInfo.fromClause#
									WHERE (<cfif Request.Table.whereClause is not "">#PreserveSingleQuotes(Request.Table.whereClause)#<cfelse>1=1</cfif>)	#PreserveSingleQuotes(Arguments.MainQueryInfo.whereClause)#
								</cfif>
							)
						</cfquery>
						<cfif This.SubqueryMethod is "structure">
							<cfset This.ValueStruct = StructNew()>
							<cfloop query="#This.Name#_MasterQuery">
								<cfset structKey = variables[This.Name & "_MasterQuery"]["ID"][CurrentRow]>
								<cfif StructKeyExists(This.ValueStruct,structKey)>
									<cfset This.ValueStruct[structKey] = This.ValueStruct[structKey] & ", " & SelectDescr>
								<cfelse>
									<cfset This.ValueStruct[structKey] = SelectDescr>
								</cfif>
							</cfloop>
						</cfif>
					</cfif>
					<cfif This.SubqueryMethod is "queryOfQuery">
						<cfquery name="qrySelectedValues" dbtype="query">
							SELECT SelectDescr
							FROM #This.Name#_MasterQuery
							WHERE #This.PKColName# =
								<cfqueryparam cfsqltype="cf_sql_integer" value="#valueQuery[Request.Table.PrimaryKey][valueQuery.CurrentRow]#">
						</cfquery>
						<cfset value = ValueList(qrySelectedValues.selectDescr,", ")>
					<cfelse>
						<cfif StructKeyExists(This.ValueStruct,valueQuery[Request.Table.PrimaryKey][valueQuery.CurrentRow])>
							<cfset value = This.ValueStruct[valueQuery[Request.Table.PrimaryKey][valueQuery.CurrentRow]]>
						<cfelse>
							<cfset value = "">
						</cfif>
					</cfif>
				<cfelse>
					<cfquery name="qrySelectedValues" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						SELECT #PreserveSingleQuotes(This.FKDescr)# as SelectDescr
						FROM #This.FKTable# INNER JOIN #This.FKJoinTable# on #This.FKTable#.#This.FKColName# = #This.FKJoinTable#.#This.FKColName#
						WHERE #This.FKJoinTable#.#This.PKColName# =
							<cfqueryparam cfsqltype="cf_sql_integer" value="#valueQuery[Request.Table.PrimaryKey][valueQuery.CurrentRow]#">
					</cfquery>
					<cfset value = ValueList(qrySelectedValues.selectDescr,", ")>
				</cfif>
			</cfcase>
			<cfcase value="Date">
				<cfif This.ShowDate and This.ShowTime>
					<cfset value = DateFormat(valueQuery[This.Name][valueQuery.CurrentRow],This.Format) & " " & TimeFormat(valueQuery[This.Name][valueQuery.CurrentRow],This.TimeFormat)>
				<cfelseif This.ShowDate>
					<cfset value = DateFormat(valueQuery[This.Name][valueQuery.CurrentRow],This.Format)>
				<cfelseif This.ShowTime>
					<cfset value = TimeFormat(valueQuery[This.Name][valueQuery.CurrentRow],This.TimeFormat)>
				</cfif>
			</cfcase>
			<cfcase value="Integer">
				<cfif Len(This.Format) gt 0 and Len(valueQuery[This.Name][valueQuery.CurrentRow]) gt 0>
					<cfset value = NumberFormat(valueQuery[This.Name][valueQuery.CurrentRow],This.Format)>
				<cfelse>
					<cfset value = valueQuery[This.Name][valueQuery.CurrentRow]>
				</cfif>
			</cfcase>
			<cfcase value="Pseudo">
				<cfif Len(This.includeFile) gt 0>
					<cfif Len(This.Expression) gt 0>
						<cfset value = valueQuery[This.Name][valueQuery.CurrentRow]>
					<cfelse>
						<cfset value = "">
					</cfif>
					<cfsavecontent variable="value">
					<cfinclude template="#This.includeFile#">
					</cfsavecontent>
				<cfelseif Len(This.Format) gt 0 and Len(valueQuery[This.Name][valueQuery.CurrentRow]) gt 0>
					<cfset value = NumberFormat(valueQuery[This.Name][valueQuery.CurrentRow],This.Format)>
				<cfelse>
					<cfset value = valueQuery[This.Name][valueQuery.CurrentRow]>
				</cfif>
			</cfcase>
			<cfcase value="Checkbox">
				<cfif valueQuery[This.Name][valueQuery.CurrentRow] is This.OnValue>
					<cfset value = This.OnDisplayValue>
				<cfelse>
					<cfset value = This.OffDisplayValue>
				</cfif>
			</cfcase>
			<cfcase value="File">
				<cfset value = "<a href=""#Request.HttpsUrl#/#This.Directory#/#valueQuery[This.Name][valueQuery.CurrentRow]#"" target=""_blank"">#valueQuery[This.Name][valueQuery.CurrentRow]#</a>">
			</cfcase>
			<cfdefaultcase>
				<cfif This.AllowHTML>
					<cfset value = valueQuery[This.Name][valueQuery.CurrentRow]>
				<cfelse>
					<cfset value = Replace(HTMLEditFormat(valueQuery[This.Name][valueQuery.CurrentRow]),Chr(10),"<br>","ALL")>
				</cfif>
			</cfdefaultcase>
		</cfswitch>
	
		<!--- Add to total --->
		<cfif This.ShowTotal and IsNumeric(valueQuery[This.Name][valueQuery.CurrentRow])>
			<cfset This.TotalHolder = This.TotalHolder + valueQuery[This.Name][valueQuery.CurrentRow]>
		</cfif>
	
		<cfreturn value>
	</cffunction>

	<cffunction name="getTotal" output="false" returntype="string">
		<cfif This.ShowTotal>
			<cfif Len(This.Format) gt 0>
				<cfreturn NumberFormat(This.TotalHolder,This.Format)>
			<cfelse>
				<cfreturn This.TotalHolder>
			</cfif>
		<cfelse>
			<cfreturn "">
		</cfif>
	</cffunction>

	<cffunction name="formatValue" description="Formats value for read-only display." output="false" returntype="string">
		<cfargument name="value" required="true" type="string">
		<cfargument name="doLookups" type="boolean" default="true">
		<cfargument name="forJavascript" type="boolean" default="false">
		<cfargument name="displayValue" type="string" default="">
		
		<cfswitch expression="#This.Type#">
			<cfcase value="Select">
				<cfif Len(value) gt 0>
					<cfset This.SelectedList = value>
					<cfif doLookups and Len(This.ValueList) is 0>
						<cfquery name="getValue" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							SELECT #PreserveSingleQuotes(This.FKDescr)# as SelectDescr
							FROM #This.FKTable#
							WHERE #This.FKColName# = <cfqueryparam cfsqltype="#This.CfSqlType#" value="#value#">
						</cfquery>
						<cfreturn getValue.selectDescr>
					<cfelse>
						<cfreturn value>
					</cfif>
				</cfif>
			</cfcase>
			<cfcase value="Select-Popup">
				<cfif Len(value) gt 0>
					<cfset This.SelectedList = value>
					<cfif doLookups and Len(This.ValueList) is 0>
						<cfquery name="getValue" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							SELECT #PreserveSingleQuotes(This.FKDescr)# as SelectDescr
							FROM #This.FKTable#
							WHERE #This.FKColName# = <cfqueryparam cfsqltype="#This.CfSqlType#" value="#value#">
						</cfquery>
						<cfreturn getValue.selectDescr>
					<cfelse>
						<cfif forJavascript>
							<cfreturn "[""#value#"",""#JSStringFormat(displayValue)#""]">
						<cfelse>
							<cfreturn value>
						</cfif>
					</cfif>
				</cfif>
			</cfcase>
			<cfcase value="Select-multiple,Checkboxgroup">
				<cfset This.SelectedList = value>
				<cfif Request.Table.action is "Add">
					<cfquery name="getValue" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						SELECT #PreserveSingleQuotes(This.FKDescr)# as SelectDescr
						FROM #This.FKTable#
						WHERE #This.FKColName# IN (<cfqueryparam cfsqltype="#This.CfSqlType#" list="true" value="#value#">)
					</cfquery>
				<cfelse>
					<cfquery name="getValue" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						SELECT #PreserveSingleQuotes(This.FKDescr)# as SelectDescr
						FROM #This.FKTable# inner join #This.FKJoinTable# on #This.FKTable#.#This.Name# = #This.FKJoinTable#.#This.Name#
						WHERE #This.FKJoinTable#.#This.PKColName# = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
					</cfquery>
				</cfif>
				<cfreturn ListChangeDelims(ValueList(getValue.selectDescr),", ")>
			</cfcase>
			<cfcase value="Date,Timestamp">
				<cfif This.ShowDate and This.ShowTime>
					<cfreturn DateFormat(value,This.Format) & " " & TimeFormat(value,This.TimeFormat)>
				<cfelseif This.ShowDate>
					<cfreturn DateFormat(value,This.Format)>
				<cfelseif This.ShowTime>
					<cfreturn TimeFormat(value,This.TimeFormat)>
				</cfif>
			</cfcase>
			<cfcase value="Integer">
				<cfif Len(This.Format) gt 0 and Len(value) gt 0>
					<cfreturn NumberFormat(value,This.Format)>
				<cfelse>
					<cfreturn value>
				</cfif>
			</cfcase>
			<cfcase value="Checkbox">
				<cfif value is This.OnValue>
					<cfreturn This.OnDisplayValue>
				<cfelse>
					<cfreturn This.OffDisplayValue>
				</cfif>
			</cfcase>
			<cfcase value="File">
				<cfif forJavascript>
					<cfreturn JSStringFormat(value)>
				<cfelse>
					<cfreturn "<a href=""/#This.Directory#/#value#"">#value#</a>">
				</cfif>
			</cfcase>
			<cfcase value="Pseudo">
				<cfif Len(This.includeFile) gt 0>
					<cfsavecontent variable="IncludeContent">
					<cfinclude template="#This.IncludeFile#">
					</cfsavecontent>
					<cfreturn IncludeContent>
				<cfelseif Len(This.Format) gt 0 and Len(valueQuery[This.Name][valueQuery.CurrentRow]) gt 0>
					<cfreturn NumberFormat(value,This.Format)>
				<cfelse>
					<cfreturn value>
				</cfif>
			</cfcase>
			<cfdefaultcase>
				<cfif forJavascript>
					<cfreturn JSStringFormat(value)>
				<cfelse>
					<cfif This.AllowHTML>
						<cfreturn value>
					<cfelse>
						<cfreturn Replace(HTMLEditFormat(value),Chr(10),"<br>","ALL")>
					</cfif>
				</cfif>
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

	<cffunction name="getQueryParam" output="false" returntype="struct">
		<cfargument name="isUpdate" type="boolean" required="true">
		<cfargument name="value" type="string" required="true">
		
		<cfset var QueryParam = StructNew()>
		<cfset QueryParam.Value = "">
		<cfset QueryParam.IsNull = false>
		<cfset QueryParam.DoUpdate = true>
	
		<cfswitch expression="#This.Type#">
			<cfcase value="integer">
				<!--- Strip legitimate characters that will cause SQL problems --->
				<cfset value = REReplace(value,"[$,]","","all")>
				<cfif Len(value) gt 0>
					<cfset QueryParam.value = value>
				<cfelse>
					<cfset QueryParam.IsNull = true>
				</cfif>
			</cfcase>
			<cfcase value="select">
				<cfif This.ComboBox>
					<!--- Get the id for the selected value. --->
					<cfif Len(value) gt 0>
						<cfquery name="getSelectID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							SELECT #This.FKColName# as selectValue FROM #This.FKTable# 
							WHERE #This.FKDescr# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#value#">
						</cfquery>
						<cfif getSelectID.recordcount is 0>
							<cfquery name="getSelectID" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
								INSERT INTO #This.FKTable# (#This.FKDescr#)
								VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#value#">)
							</cfquery>
							<cfset value = Application.Lighthouse.getInsertedId()>
						<cfelse>
							<cfset value = getSelectID.selectValue>
						</cfif>
					</cfif>
				</cfif>
				<cfif Len(value) gt 0>
					<cfset QueryParam.value = value>
				<cfelse>
					<cfset QueryParam.IsNull = true>
				</cfif>
			</cfcase>
			<cfcase value="date,radio">
				<cfif Len(value) gt 0>
					<cfset QueryParam.value = value>
				<cfelse>
					<cfset QueryParam.IsNull = true>
				</cfif>
			</cfcase>
			<cfcase value="Timestamp">
				<cfif isUpdate>
					<cfif This.StampOnEdit>
						<cfset QueryParam.value = Now()>
					<cfelse>
						<cfset QueryParam.DoUpdate = false>
					</cfif>
				<cfelse>
					<cfset QueryParam.value = Now()>
				</cfif>
			</cfcase>
			<cfcase value="checkbox">
				<cfif Len(value) gt 0>
					<cfset QueryParam.value = value>
				<cfelse>
					<cfset QueryParam.value = This.OffValue>
				</cfif>
			</cfcase>
			<cfdefaultcase>
				<cfset QueryParam.value = value>
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn QueryParam>
	</cffunction>

	<cffunction name="GetChildColumnValuesAuthToken" output="false" returntype="string">
		<cfset var key = This.FKColName & This.FKDescr & This.FKTable & This.FKWhere & This.ParentColumn & This.FKOrderBy>
		<cfobject component="#Application.ComponentPath#.Security" name="Security">
		<cfreturn Security.GetAuthToken(key)>
	</cffunction>

	<cffunction name="GetChildColumnValuesJson" output="true" access="remote">
		<cfargument name="Auth" required="true" type="string">
		<cfargument name="Value" required="true" type="string">
		<cfargument name="Text" required="true" type="string">
		<cfargument name="Table" required="true" type="string">
		<cfargument name="Where" required="true" type="string">
		<cfargument name="ParentColumn" required="true" type="string">
		<cfargument name="ParentColumnCfSqlType" required="true" type="string">
		<cfargument name="ParentColumnID" required="true" type="string">
		<cfargument name="OrderBy" required="true" type="string">
		{DATA: [
		<cfset var key = Arguments.Value & Arguments.Text & Arguments.Table & Arguments.Where & Arguments.ParentColumn & Arguments.OrderBy>
		<cfobject component="#Application.ComponentPath#.Security" name="Security">
		<cfif Arguments.Auth is Security.GetAuthToken(key)>
			<cfquery name="getValues" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT 
					#Arguments.Value# as SelectValue,
					#PreserveSingleQuotes(Arguments.Text)# as SelectText
				FROM #Arguments.Table#
				WHERE #Arguments.ParentColumn# in (<cfqueryparam cfsqltype="#Arguments.ParentColumnCfSqlType#" value="#Arguments.ParentColumnID#" list="true">)
				<cfif Len(Arguments.Where) gt 0>
					AND #PreserveSingleQuotes(Arguments.Where)#
				</cfif>
				<cfif Len(Arguments.OrderBy) gt 0>
					ORDER BY #PreserveSingleQuotes(Arguments.OrderBy)#
				</cfif>
			</cfquery>
			<cfloop query="getValues"><cfif currentRow gt 1>,</cfif>[#SelectValue#,"#SelectText#"]</cfloop>
		</cfif>
		]}
	</cffunction>
</cfcomponent>