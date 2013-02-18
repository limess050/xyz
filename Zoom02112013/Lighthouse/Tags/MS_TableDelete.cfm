<!---
File Name: 	MS_TableDelete.cfm
Author: 	David Hammond
Description:

Inputs:
--->

<cfif Not IsDefined("DeleteConfirmed")>
	<cfparam name="redirectURL" default="#cgi.http_referer#">
	<cfif Not Find("?",redirectURL)><cfset redirectURL = redirectURL & "?"></cfif>

	<!--- Check for any related records --->
	<cfparam name="ErrorMessage" default="">
	<cfif Len(Request.Table.RelatedTables) gt 0>
		<cfloop index="tc" list="#Request.Table.RelatedTables#">
			<cfquery name="checkRelatedTable" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT count(*) as c FROM #ListFirst(tc,".")# 
				WHERE #ListLast(tc,".")# = <cfqueryparam cfsqltype="#Request.Table.Columns[Request.Table.PrimaryKey].CfSqlType#" value="#pk#">
			</cfquery>
			<cfif checkRelatedTable.c gt 0>
				<cfset ErrorMessage = ErrorMessage & "<li>Related records exists in the table ""#ListFirst(tc,".")#""">
			</cfif>
		</cfloop>
		<cfif Len(ErrorMessage) gt 0>
			<cfoutput>
			<div class="STATUSMESSAGE">
				<p>This record cannot be deleted for the following reasons:</p>
				<ul>#ErrorMessage#</ul>
			</div>
			<form>
				<INPUT TYPE="BUTTON" VALUE="Go Back" ONCLICK="window.location='#redirectURL#&StatusMessage=#URLEncodedFormat("Delete operation cancelled.")#'" class=button>
			</form>
			</cfoutput>
			<cfabort>
		</cfif>
	</cfif>

	<!--- Find files associated to record --->
	<cfset fileColumns = ArrayNew(1)>
	<cfloop index="colNum" from="1" to="#ArrayLen(Request.Table.ColumnOrder)#">
		<cfset Column = Request.Table.Columns[Request.Table.ColumnOrder[colNum]]>
		<cfif Column.Type is "file">
			<cfquery name="checkFile" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT #Column.Name# as filefield
				FROM #Request.Table.table#
				WHERE #Request.Table.PrimaryKey# = <cfqueryparam cfsqltype="#Request.Table.Columns[Request.Table.PrimaryKey].CfSqlType#" value="#pk#">
			</cfquery>
			<cfif checkFile.filefield is not "">
				<cfset Column.fileName = checkFile.filefield>
				<cfset Column.filePath = Application.Lighthouse.getBaseRelativePath() & Column.Directory & "/" & checkFile.filefield>
				<cfset foo = ArrayAppend(fileColumns, Column)>
			</cfif>
		</cfif>
	</cfloop>

	<cfoutput>
	<form action="#cgi.script_name#?action=Delete&#Request.Table.persistentParams#&pk=#pk#" method="post">
		<p class="STATUSMESSAGE">Click "OK" to delete this record</p>
		<cfif ArrayLen(fileColumns) gt 0>
			<p>The following file(s) are associated to this record. Select the files that should be deleted along with the record.</p>
			<p>
			<cfloop index="i" from="1" to="#ArrayLen(fileColumns)#">
				<cfif FileExists(ExpandPath(fileColumns[i].filePath))>
					<input type="checkbox" id="#fileColumns[i].Name#" name="filesToDelete" value="#fileColumns[i].filePath#"
					<cfif fileColumns[i].deleteWithRecord>checked="true"</cfif>><label for="#fileColumns[i].Name#">#fileColumns[i].fileName# - <a href="#fileColumns[i].filePath#" target="_blank">View file</a></label><br>
				<cfelse>
					#fileColumns[i].fileName# (This file does not exist)<br>
				</cfif>
			</cfloop>
			</p>
		</cfif>
		<INPUT TYPE="HIDDEN" NAME="queryParams" VALUE="#queryParams#">
		<INPUT TYPE="HIDDEN" NAME="deleteConfirmed" VALUE="Yes">
		<INPUT TYPE="SUBMIT" VALUE="OK" class=button>
		<INPUT TYPE="BUTTON" VALUE="Cancel" ONCLICK="window.location='#redirectURL#&StatusMessage=#URLEncodedFormat("Delete operation cancelled.")#'" class=button>
	</form>
	</cfoutput>
	<cfabort>
</cfif>


<cftransaction>
	<cfif StructKeyExists(Request.Table.Events,"onBeforeDelete")>
		<cfinclude template = "#Request.Table.Events.onBeforeDelete.Include#">
	</cfif>
	<!--- Delete from join tables and child table --->
	<cfloop index="colNum" from="1" to="#ArrayLen(Request.Table.ColumnOrder)#">
		<cfset Column = Request.Table.Columns[Request.Table.ColumnOrder[colNum]]>
		<cfswitch expression="#Column.Type#">
			<cfcase value="select-multiple,checkboxgroup,select-multiple-popup">
				<cftry>
				<cfquery name="delete" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					DELETE FROM #Column.FKJoinTable# 
					WHERE #Column.PKColName# = <cfqueryparam cfsqltype="#Request.Table.Columns[Request.Table.PrimaryKey].CfSqlType#" value="#pk#">
				</cfquery>
				<cfcatch></cfcatch>
				</cftry>
			</cfcase>
			<cfcase value="ChildTable">
				<cftry>
				<cfquery name="deleteChildTable" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
					DELETE FROM #Column.Name# 
					WHERE #Request.Table.PrimaryKey# = <cfqueryparam cfsqltype="#Request.Table.Columns[Request.Table.PrimaryKey].CfSqlType#" value="#pk#">
				</cfquery>
				<cfcatch></cfcatch>
				</cftry>
			</cfcase>
		</cfswitch>
	</cfloop>
	<!--- Delete record --->
	<cfquery name="delete" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		DELETE FROM #Request.Table.table# 
		WHERE #Request.Table.PrimaryKey# = <cfqueryparam cfsqltype="#Request.Table.Columns[Request.Table.PrimaryKey].CfSqlType#" value="#pk#">
	</cfquery>
	<!--- Delete associated files --->
	<cfif StructKeyExists(form,"filesToDelete")>
		<cfloop index="fileToDelete" list="#filesToDelete#">
			<cfif FileExists(ExpandPath(fileToDelete))>
				<cffile action="Delete" file="#ExpandPath(fileToDelete)#">
			</cfif>
		</cfloop>
	</cfif>
	<cfif StructKeyExists(Request.Table.Events,"onAfterDelete")>
		<cfinclude template = "#Request.Table.Events.onAfterDelete.Include#">
	</cfif>
</cftransaction>

<cfset redirectURL = "#cgi.script_name#?action=View&#Request.Table.persistentParams#&StatusMessage=#URLEncodedFormat("Record Deleted.")#">
<cfif Len(queryParams) gt 0><cfset redirectURL = redirectURL & "&#queryParams#"></cfif>

<script type="text/javascript">
window.location.href = "<cfoutput>#redirectURL#</cfoutput>";
</script>