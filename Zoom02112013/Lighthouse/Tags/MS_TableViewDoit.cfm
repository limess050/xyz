<!---
File Name: 	MS_TableView.cfm
Author: 	David Hammond
Description:

Inputs:
	table (required)
	startRow (opt)
	orderBy (opt)
--->

<cfset allColumns = StructKeyList(Request.Table.Columns)>
<cfset SelectMultipleColumns = "">
<cfset UpdateColumns = "">
<cfloop index="colName" list="#allColumns#">
	<cfset Column = Request.Table.Columns[colName]>
	<cfif Column.Editable and IsDefined(Column.Name & "_editCol")>
		<cfif Column.Type is "select-multiple"
			or Column.Type is "select-multiple-popup"
			or Column.Type is "checkboxgroup">
			<cfset SelectMultipleColumns = ListAppend(SelectMultipleColumns,colname)>
		<cfelse>
			<cfset UpdateColumns = ListAppend(UpdateColumns,colname)>
		</cfif>
	</cfif>
</cfloop>

<cfloop index="id" list="#editedIDs#">
	<cfif len(updateColumns) gt 0>
		<cfquery name="update" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			update #Request.Table.table#
			set
			<cfset firstColumn = true>
			<cfloop index="colName" list="#UpdateColumns#">
				<cfset fieldNameSuffix = "_" & id>
				<cfparam name="form.#colName##fieldNameSuffix#" default="">
				<cfset Column = Request.Table.Columns[colName]>

				<!--- File upload --->
				<cfif Column.Type is "File">
					<cfparam name="form.#colName#_OldFile#fieldNameSuffix#" default="">
					<cfparam name="form.#colName#_Delete#fieldNameSuffix#" default="">
					<cfset oldFile = StripCR(Trim(form["#colName#_OldFile#fieldNameSuffix#"]))>
					<cfset deleteFile = StripCR(Trim(form["#colName#_Delete#fieldNameSuffix#"]))>
					<cfset value = oldFile>

					<!--- Get destination from path.  Path should be relative to server root. --->
					<cfset destination = ExpandPath(getBaseRelativePath() & Column.Directory & "/")>

					<!--- Delete old file --->
					<cfif Len(oldFile) gt 0 and deleteFile is "Y">
						<cfif FileExists("#destination##oldFile#")>
							<cffile action="Delete" file="#destination##oldFile#">
							<cfset value = "">
						</cfif>
					</cfif>

					<!--- Upload new file --->
					<cfif Len(form[colName]) gt 0>
						<cfset cffile = UploadFile(
							FileField = "#colName##fieldNameSuffix#", 
							Destination = destination, 
							NameConflict = Column.NameConflict,
							TempDirectory = Application.TempDirectory
						)>
						<cfset value = cffile.ServerFile>
					</cfif>
				<cfelseif Column.Type is "textarea">
					<cfset value = Trim(form[colName & fieldNameSuffix])>
				<cfelse>
					<!--- Strip carriage returns to avoid bugs with Mac browsers --->
					<cfset value = StripCR(Trim(form[colName & fieldNameSuffix]))>
				</cfif>

				<cfif not firstColumn>
					,
				<cfelse>
					<cfset firstColumn = not firstColumn>
				</cfif>


				#colName# =

				<cfswitch expression="#Column.Type#">
					<cfcase value="integer">
						<cfif Len(value) gt 0>
							#value#
						<cfelse>
							null
						</cfif>
					</cfcase>
					<cfcase value="select">
						<cfif Len(value) gt 0>
							<cfif Column.FKType is "text">
								'#value#'
							<cfelse>
								#value#
							</cfif>
						<cfelse>
							null
						</cfif>
					</cfcase>
					<cfcase value="date">
						<cfif Len(value) gt 0>
							<cfif Column.ShowTime>
								<cfset hour = NumberFormat(form["#colName#_Hour#fieldNameSuffix#"],"00")>
								<cfset minute = NumberFormat(form["#colName#_Minute#fieldNameSuffix#"],"00")>
								<cfif hour is "00"><cfset hour = "12"></cfif>
								<cfset value = value & " #hour#:#minute# #form["#colName#_AMPM#fieldNameSuffix#"]#">
								<cfset value = StripCR(value)>
							</cfif>
							'#value#'
						<cfelse>
							null
						</cfif>
					</cfcase>
					<cfcase value="Timestamp">
						<cfif Column.StampOnEdit>
							#CreateODBCDateTime(Now())#
						<cfelse>
							#colName#
						</cfif>
					</cfcase>
					<cfcase value="checkbox">
						<cfif Len(value) gt 0>
							'#value#'
						<cfelse>
							'#Column.OffValue#'
						</cfif>
					</cfcase>
					<cfdefaultcase>
						'#value#'
					</cfdefaultcase>
				</cfswitch>

			</cfloop>
			where #Request.Table.PrimaryKey# = <cfif Request.Table.Columns[Request.Table.PrimaryKey].Type is "Text">'#id#'<cfelse>#id#</cfif>
		</cfquery>
	</cfif>

	<cfloop index="colName" list="#SelectMultipleColumns#">
		<cfset fieldNameSuffix = "_" & id>
		<cfset Column = Request.Table.Columns[colName]>
		<cfif IsDefined("form.#colName##fieldNameSuffix#")>
			<cfset values = StripCR(Trim(form["#colName##fieldNameSuffix#"]))>
		<cfelse>
			<cfset values = "">
		</cfif>

		<!--- Delete existing values --->
		<cfquery name="deleteValues" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			delete from #Column.FKJoinTable# where #Request.Table.PrimaryKey# = #id#
		</cfquery>
		<cfif Len(values) gt 0>
			<cfparam name="Column.OrderColumn" default="">
			<cfif Len(Column.OrderColumn) gt 0 and Column.Type is "select-multiple-popup">
				<!--- If tracking order, insert one at a time --->
				<cfset ob = 1>
				<cfloop index="value" list="#values#">
					<cfquery name="insertValue" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						insert into #Column.FKJoinTable# (#Column.PKColName#,#Column.FKColName#,#Column.OrderColumn#)
						values (#id#,<cfif Column.FKType is "text">'#value#'<cfelse>#value#</cfif>,#ob#)
					</cfquery>
					<cfset ob = ob + 1>
				</cfloop>
			<cfelse>
				<cfif Column.FKType is "text"><cfset values = ListQualify(values,"'")></cfif>
				<!--- Insert values --->
				<cfquery name="insertValues" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					insert into #Column.FKJoinTable# (#Column.PKColName#,#Column.FKColName#)
					select #id#,#Column.FKColName# from #Column.FKTable# where #Column.FKColName# in (#PreserveSingleQuotes(values)#)
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>

</cfloop>


<cfset statusMessage = "Changes Saved">
<cfset redirectURL = "#cgi.script_name#?#Replace(cgi.query_string,"action=ViewDoit","action=View")#&statusMessage=#URLEncodedFormat(statusMessage)#">
<cflocation url="#redirectURL#">

