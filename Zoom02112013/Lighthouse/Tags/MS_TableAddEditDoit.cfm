<!---
File Name: 	MS_TableAddEditDoit.cfm
Author: 	David Hammond
Description:

Inputs:
--->


<cfset allColumns = StructKeyList(Request.Table.Columns)>

<!--- If there is no form information, try to load saved form scope. 
	Form scope is saved on the login page if the form is submitted after a session has expired. --->
<cfif StructCount(form) is 0>
	<cfif StructKeyExists(session,"SavedFormScope")>
		<cfset StructAppend(form,session.SavedFormScope)>
	</cfif>
</cfif>

<!---
Validation
Perform server-side validation.
--->
<cfset errorMessage = "">
<cfset formValues = "">
<cfloop index="colNum" from="1" to="#ArrayLen(Request.Table.ColumnOrder)#">
	<cfset Column = Request.Table.Columns[Request.Table.ColumnOrder[colNum]]>

	<cfif IsDefined("#Column.Name#_isEditable")><cfset Column.Editable = form[Column.Name & "_isEditable"]></cfif>

	<cfif Column.Name is not Request.Table.PrimaryKey and Column.Editable>
		<cfif Column.Required>
			<cfswitch expression="#Column.Type#">
				<cfcase value="ChildTable">
					<cfif Not StructKeyExists(form,Column.Name & "_rowIds")>
						<cfset errorMessage = errorMessage & "<LI>You did not enter any values into the <b>#Column.DispName#</b> field. This is a required field.">
					</cfif>
				</cfcase>
				<cfcase value="File">
					<cfif Len(StripCR(Trim(form[Column.Name]))) is 0>
						<cfif IsDefined("form.#Column.Name#_OldFile")>
							<cfparam name= "form.#Column.Name#_Delete" default="">
							<cfif Len(StripCR(Trim(form[Column.Name & "_OldFile"]))) is 0 or StripCR(Trim(form[Column.Name & "_Delete"])) is "Y">
								<cfset errorMessage = errorMessage & "<LI>You did not select a file for the <b>#Column.DispName#</b> field. This is a required field.">
							</cfif>
						<cfelse>
							<cfset errorMessage = errorMessage & "<LI>You did not select a file for the <b>#Column.DispName#</b> field. This is a required field.">
						</cfif>
					</cfif>
				</cfcase>
				<cfdefaultcase>
					<cfif Len(StripCR(Trim(form[Column.Name]))) is 0>
						<cfset errorMessage = errorMessage & "<LI>You did not enter a value into the <b>#Column.DispName#</b> field. This is a required field.">
					</cfif>
				</cfdefaultcase>
			</cfswitch>
		</cfif>
		<cfif Column.Unique and Len(Trim(form[Column.Name])) gt 0>
			<cfset checkValue = Trim(form[Column.Name])>
			<cfquery name="checkUnique" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT #Request.Table.PrimaryKey# FROM #Request.Table.table#
				WHERE #Column.Name# = '#checkValue#'
					<cfif form.pk gt 0>and #Request.Table.PrimaryKey# <> <cfqueryparam cfsqltype="cf_sql_integer" value="#form.pk#"></cfif>
			</cfquery>
			<cfif checkUnique.recordcount gt 0>
				<cfset errorMessage = errorMessage & "<LI>The value in the <b>#Column.DispName#</b> field is already in use. It must be unique.">
			</cfif>
		</cfif>
		<cfswitch expression="#Column.Type#">
			<cfcase value="Integer">
				<cfif Len(Trim(form[Column.Name])) gt 0 and Not IsNumeric(form[Column.Name])>
					<cfset errorMessage = errorMessage & "<LI>The value in field <b>#Column.DispName#</b> must be a number.">
				</cfif>
			</cfcase>
			<cfcase value="Date">
				<cfif Column.ShowDate>
					<cfif Len(Trim(form[Column.Name])) gt 0 and Not IsDate(form[Column.Name])>
						<cfset errorMessage = errorMessage & "<LI>The value in field <b>#Column.DispName#</b> must be a valid date.">
					</cfif>
				</cfif>
				<cfif Column.ShowTime>
					<cfif Len(Trim(form[Column.Name & "_Hour"])) gt 0>
						<cfif Not IsNumeric(form[Column.Name & "_Hour"])>
							<cfset errorMessage = errorMessage & "<LI>The value in field <b>#Column.DispName# Hour</b> must be a number.">
						<cfelseif form[Column.Name & "_Hour"] gt 12>
							<cfset errorMessage = errorMessage & "<LI>The value in field <b>#Column.DispName# Hour</b> must be an hour from 1 to 12.">
						</cfif>
					</cfif>
					<cfif Len(Trim(form[Column.Name & "_Minute"])) gt 0>
						<cfif Not IsNumeric(form[Column.Name & "_Minute"])>
							<cfset errorMessage = errorMessage & "<LI>The value in field <b>#Column.DispName# Minute</b> must be a number.">
						<cfelseif form[Column.Name & "_Minute"] gt 59>
							<cfset errorMessage = errorMessage & "<LI>The value in field <b>#Column.DispName# Minute</b> must be an minute from 0 to 59.">
						</cfif>
					</cfif>
				</cfif>
			</cfcase>
			<cfcase value="Textarea">
				<cfif Len(Column.MaxLength)>
					<cfif Len(form[Column.Name]) gt Column.MaxLength>
						<cfset errorMessage = errorMessage & "<LI>The value in field <b>#Column.DispName#</b> is longer than the maximum of #Column.MaxLength# characters.">
					</cfif>
				</cfif>
			</cfcase>
		</cfswitch>
	</cfif>

	<!--- Set column type equivalencies for this page --->
	<cfif Column.Type is "select-popup"><cfset Column.Type = "select"></cfif>
</cfloop>

<cfif Len(errorMessage) gt 0>
	<P CLASS=PAGETITLE>Data Validation Error</P>
	<P><SPAN CLASS=STATUSMESSAGE>
	There were problems processing the form.  See details below and go back to correct the problems.
	<ul><cfoutput>#errorMessage#</cfoutput></ul>
	</SPAN></P>
	<FORM>
	<INPUT TYPE="BUTTON" VALUE="Go Back" ONCLICK="history.back()">
	</FORM>
	<cfabort>
</cfif>

<!--- remove select multiple (and similar) columns from column list and put in special list --->
<cfset SelectMultipleColumns = "">
<cfset ChildTableColumns = "">
<cfset allAddColumns = allColumns>
<cfset allUpdateColumns = allColumns>
<cfloop index="colName" list="#allColumns#">
	<cfset Column = Request.Table.Columns[colName]>
	<cfif Column.Editable>
		<cfif ListFindNoCase("select-multiple,select-multiple-popup,checkboxgroup,Pseudo,ChildTable",Column.Type) is not 0>
			<cfset allAddColumns = ListDeleteAt(allAddColumns,ListFindNoCase(allAddColumns,colname))>
			<cfset allUpdateColumns = ListDeleteAt(allUpdateColumns,ListFindNoCase(allUpdateColumns,colname))>
			<cfif Column.Type is "ChildTable">
				<cfset ChildTableColumns = ListAppend(ChildTableColumns,colname)>
			<cfelseif Column.Type is not "Pseudo">
				<cfset SelectMultipleColumns = ListAppend(SelectMultipleColumns,colname)>
			</cfif>
		</cfif>
	<cfelseif Column.Type neq "TimeStamp">
		<cfset allUpdateColumns = ListDeleteAt(allUpdateColumns,ListFindNoCase(allUpdateColumns,colname))>
		<cfif ListFindNoCase("select-multiple,select-multiple-popup,checkboxgroup",Column.Type) is not 0>
			<cfset allAddColumns = ListDeleteAt(allAddColumns,ListFindNoCase(allAddColumns,colname))>
			<cfset SelectMultipleColumns = ListAppend(SelectMultipleColumns,colname)>
		<cfelseif Column.Type is "ChildTable">
			<cfset allAddColumns = ListDeleteAt(allAddColumns,ListFindNoCase(allAddColumns,colname))>
			<cfset ChildTableColumns = ListAppend(ChildTableColumns,colname)>
		<cfelseif Column.Type is "Pseudo">
			<cfset allAddColumns = ListDeleteAt(allAddColumns,ListFindNoCase(allAddColumns,colname))>
		</cfif>
	</cfif>
</cfloop>
<!--- remove primary key from update columns --->
<cfif ListFindNoCase(allUpdateColumns,Request.Table.PrimaryKey) gt 0>
	<cfset allUpdateColumns = ListDeleteAt(allUpdateColumns,ListFindNoCase(allUpdateColumns,Request.Table.PrimaryKey))>
</cfif>
<!--- remove primary key from add columns if it is an identity column --->
<cfif ListFindNoCase(allAddColumns,Request.Table.PrimaryKey) gt 0 and Request.Table.Columns[Request.Table.PrimaryKey].Identity>
	<cfset allAddColumns = ListDeleteAt(allAddColumns,ListFindNoCase(allAddColumns,Request.Table.PrimaryKey))>
</cfif>

<!--- Add New Record --->
<cfif form.pk is "0">
	<cfif StructKeyExists(Request.Table.Events,"onBeforeInsert")>
		<cfinclude template = "#Request.Table.Events.onBeforeInsert.Include#">
	</cfif>

	<cftransaction>
		<!--- If primary key is not an identity column, get next id --->
		<cfif Not Request.Table.Columns[Request.Table.PrimaryKey].Identity>
			<cfset pk = Request.Table.getNextId(Request.Table.table,Request.Table.PrimaryKey)>
			<cfset form[Request.Table.PrimaryKey] = pk>
		</cfif>
	
		<!--- Insert record --->
		<cfquery name="insert" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			INSERT INTO #Request.Table.table# (
				<cfloop index="colName" list="#allAddColumns#">
					<cfif colName is not ListFirst(allAddColumns)>,</cfif>#colName#
				</cfloop>
			)
			VALUES (
			<cfloop index="colName" list="#allAddColumns#">
				<cfif colName is not ListFirst(allAddColumns)>,</cfif>
				<cfset QueryParam = Request.Table.getSqlValue(Request.Table.Columns[colName],false)>
				<cftrace text=":#Request.Table.Columns[colName].Name#:#Request.Table.Columns[colName].CfSqlType#:#QueryParam.Value#">
				<cfqueryparam cfsqltype="#Request.Table.Columns[colName].CfSqlType#" null="#QueryParam.IsNull#" value="#QueryParam.Value#">
			</cfloop>
			)
		</cfquery>
	
		<!--- get pk for identity column --->
		<cfif Request.Table.Columns[Request.Table.PrimaryKey].Identity>
			<cfset pk = Application.Lighthouse.getInsertedId()>
		</cfif>
	</cftransaction>

	<cfset statusMessage = "Record added to the #Request.Table.Title# table.">

<!--- Update Record --->
<cfelse>

	<cfif StructKeyExists(Request.Table.Events,"onBeforeUpdate")>
		<cfinclude template = "#Request.Table.Events.onBeforeUpdate.Include#">
	</cfif>

	<cfparam name="form.#Request.Table.PrimaryKey#" default="#pk#">
	<cfquery name="update" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		UPDATE #Request.Table.table#
		SET
		<cfset started=false>
		<cfloop index="colName" list="#allUpdateColumns#">
			<cfset QueryParam = Request.Table.getSqlValue(Request.Table.Columns[colName],true)>
			<cfif QueryParam.DoUpdate>
				<cfif started>,</cfif>
				#colName# = <cfqueryparam cfsqltype="#Request.Table.Columns[colName].CfSqlType#" null="#QueryParam.IsNull#" value="#QueryParam.Value#">
				<cfset started = true>
			</cfif>
		</cfloop>
		WHERE #Request.Table.PrimaryKey# = <cfqueryparam cfsqltype="#Request.Table.Columns[Request.Table.PrimaryKey].CfSqlType#" value="#pk#">
	</cfquery>
	<cfset statusMessage = "Changes saved.">
</cfif>

<cfloop index="colName" list="#SelectMultipleColumns#">
	<cfset Column = Request.Table.Columns[colName]>
	<cfif Not Column.Hidden>
		<cfparam name="form.#colName#" default="">
		<cfset values = StripCR(Trim(form[Column.Name]))>
		<!--- Delete existing values --->
		<cfif form.pk gt 0>
			<cfquery name="deleteValues" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				DELETE FROM #Column.FKJoinTable# 
				WHERE #Request.Table.PrimaryKey# = <cfqueryparam cfsqltype="#Request.Table.Columns[Request.Table.PrimaryKey].CfSqlType#" value="#pk#">
			</cfquery>
		</cfif>
		<cfif Len(values) gt 0>
			<cfparam name="Column.OrderColumn" default="">
			<cfif Len(Column.OrderColumn) gt 0 and Column.Type is "select-multiple-popup">
				<!--- If tracking order, insert one at a time --->
				<cfset ob = 1>
				<cfloop index="value" list="#values#">
					<cfquery name="insertValue" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						INSERT INTO #Column.FKJoinTable# (
							#Column.PKColName#,
							#Column.FKColName#,
							#Column.OrderColumn#
						)
						VALUES (
							<cfqueryparam cfsqltype="#Request.Table.Columns[Request.Table.PrimaryKey].CfSqlType#" value="#pk#">,
							<cfqueryparam cfsqltype="#Column.CfSqlType#" value="#value#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#ob#">
						)
					</cfquery>
					<cfset ob = ob + 1>
				</cfloop>
			<cfelse>
				<!--- Insert values --->
				<cfquery name="insertValues" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					INSERT INTO #Column.FKJoinTable# (#Column.PKColName#,#Column.FKColName#)
					SELECT <cfqueryparam cfsqltype="#Request.Table.Columns[Request.Table.PrimaryKey].CfSqlType#" value="#pk#">,#Column.FKColName#
					FROM #Column.FKTable# 
					WHERE #Column.FKColName# IN (
						<cfqueryparam cfsqltype="#Column.CfSqlType#" list="true" value="#values#">
					)
				</cfquery>
			</cfif>
		</cfif>
	</cfif>
</cfloop>

<cfloop index="colName" list="#ChildTableColumns#">
	<cfset Column = Request.Table.Columns[colName]>
	<cfif Not Column.Hidden>
		<cfset childTableAddColumns = StructKeyList(Column.Columns)>
		<cfif StructKeyExists(form,Column.Name & "_rowIds")>
			<cfset rowIds = form[Column.Name & "_rowIds"]>
		<cfelse>
			<cfset rowIds = "">
		</cfif>
		<cfset recordIds = "">
		<!--- Handle insert and update actions for child table with a primary key --->
		<cfif Len(Column.PrimaryKey) gt 0>
			<cfset childTableUpdateColumns = ListDeleteAt(childTableAddColumns,ListFindNoCase(childTableAddColumns,Column.PrimaryKey))>
			<cfif Column.Columns[Column.PrimaryKey].Identity>
				<cfset childTableAddColumns = childTableUpdateColumns>
			</cfif>
			<cfloop list="#rowIds#" index="recordNum" >
				<cfif StructKeyExists(form,"#Column.Name#_#Column.PrimaryKey#_#recordNum#")>
					<!--- Add New Record --->
					<cfif form["#Column.Name#_#Column.PrimaryKey#_#recordNum#"] is "">
						<cftransaction>
							<!--- If primary key is not an identity column, get next id --->
							<cfif Not Column.Columns[Column.PrimaryKey].Identity>
								<cfset childTablePk = Request.Table.getNextId(Column.Name,Column.PrimaryKey)>
								<cfset form["#Column.Name#_#Column.PrimaryKey#_#recordNum#"] = childTablePk>
							</cfif>
							<!--- Insert record --->
							<cfquery name="insert" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
								INSERT INTO #Column.Name# (
									#Request.Table.PrimaryKey#
									<cfloop index="colName" list="#childTableAddColumns#">
										,#colName#
									</cfloop>
									<cfif Len(Column.OrderColumn) gt 0>
										,#Column.OrderColumn#
									</cfif>
								)
								VALUES (
									<cfqueryparam cfsqltype="#Request.Table.Columns[Request.Table.PrimaryKey].CfSqlType#" value="#pk#">
									<cfloop index="colName" list="#childTableAddColumns#">
										<cfset QueryParam = Request.Table.getSqlValue(Column.Columns[colName],false,"#Column.Name#_#colName#_#recordNum#")>
										,<cfqueryparam cfsqltype="#Column.Columns[colName].CfSqlType#" null="#QueryParam.IsNull#" value="#QueryParam.Value#">
									</cfloop>
									<cfif Len(Column.OrderColumn) gt 0>
										,<cfqueryparam cfsqltype="cf_sql_integer" value="#form["#Column.Name#_#Column.OrderColumn#_#recordNum#"]#">
									</cfif>
								)
							</cfquery>
							<!--- get pk for identity column --->
							<cfif Column.Columns[Column.PrimaryKey].Identity>
								<cfset childTablePk = Application.Lighthouse.getInsertedId()>
							</cfif>
							<cfset recordIDs = ListAppend(recordIds,childTablePk)>
						</cftransaction>
					<!--- Update Record --->
					<cfelse>
						<cfset childTablePk = form["#Column.Name#_#Column.PrimaryKey#_#recordNum#"]>
						<cfquery name="update" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							UPDATE #Column.Name#
							SET
							#Request.Table.PrimaryKey# = <cfqueryparam cfsqltype="#Request.Table.Columns[Request.Table.PrimaryKey].CfSqlType#" value="#pk#">
							<cfloop index="colName" list="#childTableUpdateColumns#">
								<cfset QueryParam = Request.Table.getSqlValue(Column.Columns[colName],true,"#Column.Name#_#colName#_#recordNum#")>
								<cfif QueryParam.DoUpdate>
									,#colName# = <cfqueryparam cfsqltype="#Column.Columns[colName].CfSqlType#" null="#QueryParam.IsNull#" value="#QueryParam.Value#">
								</cfif>
							</cfloop>
							<cfif Len(Column.OrderColumn) gt 0>
								,#Column.OrderColumn# = <cfqueryparam cfsqltype="cf_sql_integer" value="#form["#Column.Name#_#Column.OrderColumn#_#recordNum#"]#">
							</cfif>
							WHERE #Column.PrimaryKey# = <cfqueryparam cfsqltype="cf_sql_integer" value="#childTablePk#">
						</cfquery>
						<cfset recordIDs = ListAppend(recordIds,childTablePk)>
					</cfif>
				</cfif>
			</cfloop>
			<!--- Delete Old Records --->
			<cfquery name="update" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				DELETE FROM #Column.Name#
				WHERE #Request.Table.PrimaryKey# = <cfqueryparam cfsqltype="#Request.Table.Columns[Request.Table.PrimaryKey].CfSqlType#" value="#pk#">
					<cfif Len(recordIds) gt 0>
						and #Column.PrimaryKey# NOT IN (
							<cfqueryparam cfsqltype="cf_sql_integer" list="true" value="#recordIds#">
						)
					</cfif>
			</cfquery>
		<!--- Handle insert and update actions for child table without a primary key --->
		<cfelse>
			<!--- Delete Old Records --->
			<cfquery name="update" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				DELETE FROM #Column.Name# 
				WHERE #Request.Table.PrimaryKey# = <cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
			</cfquery>
			<cfloop list="#rowIds#" index="recordNum">
				<!--- Look for any value specified for the recordNum --->
				<cfloop index="colName" list="#childTableAddColumns#">
					<cfif StructKeyExists(form,"#Column.Name#_#colName#_#recordNum#")>
						<!--- Insert record --->
						<cfquery name="insert" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
							INSERT INTO #Column.Name# (
								#Request.Table.PrimaryKey#
								<cfloop index="colName" list="#childTableAddColumns#">
									,#colName#
								</cfloop>
								<cfif Len(Column.OrderColumn) gt 0>
									,#Column.OrderColumn#
								</cfif>
							)
							VALUES (
								<cfqueryparam cfsqltype="#Request.Table.Columns[Request.Table.PrimaryKey].CfSqlType#" value="#pk#">
								<cfloop index="colName" list="#childTableAddColumns#">
									<cfset QueryParam = Request.Table.getSqlValue(Column.Columns[colName],false,"#Column.Name#_#colName#_#recordNum#")>
									,<cfqueryparam cfsqltype="#Column.Columns[colName].CfSqlType#" null="#QueryParam.IsNull#" value="#QueryParam.Value#">
								</cfloop>
								<cfif Len(Column.OrderColumn) gt 0>
									,<cfqueryparam cfsqltype="cf_sql_integer" value="#form["#Column.Name#_#Column.OrderColumn#_#recordNum#"]#">
								</cfif>
							)
						</cfquery>
						<cfbreak>
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>
	</cfif>
</cfloop>

<cfif form.pk is "0">
	<cfif StructKeyExists(Request.Table.Events,"onAfterInsert")>
		<cfinclude template = "#Request.Table.Events.onAfterInsert.Include#">
	</cfif>
<cfelse>
	<cfif StructKeyExists(Request.Table.Events,"onAfterUpdate")>
		<cfinclude template = "#Request.Table.Events.onAfterUpdate.Include#">
	</cfif>
</cfif>

<cfset redirectURL = "#cgi.script_name#?action=Edit&#Request.Table.persistentParams#&pk=#pk#&statusMessage=#URLEncodedFormat(statusMessage)#">
<cfif IsDefined("queryParams")><cfset redirectURL = redirectURL & "&queryParams=#URLEncodedFormat(queryParams)#"></cfif>
<cfif IsDefined("form.SubmitAndSelectButton")><cfset redirectURL = redirectURL & "&SubmitAndSelectButton=1"></cfif>
<cflocation url="#redirectURL#">