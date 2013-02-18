<!---
File Name: 	MS_TableListOrder.cfm
Author: 	Adam Polon
Description:

Inputs:

--->

<cfset DescriptionColumn = Request.Table.Actions[action].DescriptionColumn>
<cfset OrderColumn = Request.Table.Actions[action].OrderColumn>
<cfset SelectQuery = Request.Table.Actions[action].SelectQuery>
<cfparam name="UpdateListOrder" default="No">

<!--- Make sure we have the required information to order --->
<cfif Len(DescriptionColumn) is 0 or Len(OrderColumn) is 0>
	Error: You must specify one column as a DescriptionColumn and one column as a OrderColumn
	<cfabort>
</cfif>

<!--- If form was submitted, update OrderColumn --->
<cfif UpdateListOrder>
	<cfparam name="updownlist" default="">
	<cfset i = 1>
	<cfloop list="#updownlist#" index="pkid">
		<cfquery name="getRecords" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		UPDATE #Request.Table.table#
		SET #OrderColumn# = <cfqueryparam cfsqltype="cf_sql_integer" value="#i#">
		WHERE #Request.Table.PrimaryKey# = <cfqueryparam cfsqltype="#Request.Table.Columns[Request.Table.PrimaryKey].CfSqlType#" value="#pkid#">
		</cfquery>
		<cfset i = i + 1>
	</cfloop>

	<!---
	<cfset statusMessage = "Changes saved.">
	<cfset redirectURL = "#cgi.script_name#?action=#Request.Table.action#&#Request.Table.persistentParams#&statusMessage=#URLEncodedFormat(statusMessage)#">
	<cfif IsDefined("queryParams")><cfset redirectURL = redirectURL & "&queryParams=#URLEncodedFormat(queryParams)#"></cfif>

	<cflocation url="#redirectURL#">
	<script type="text/javascript">
	window.location.href = "<cfoutput>#redirectURL#</cfoutput>";
	</script>
	<cfabort>
	--->
</cfif>

<cfif Len(selectQuery)>
	<cfquery name="getRecords" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	#preserveSingleQuotes(selectQuery)#
	</cfquery>
<cfelse>
	<cfquery name="getRecords" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT #Request.Table.PrimaryKey# as selectValue, #preserveSingleQuotes(DescriptionColumn)# as selectText
	FROM #Request.Table.table#
	<cfif Request.Table.whereClause is not "">
		WHERE (#PreserveSingleQuotes(Request.Table.whereClause)#)
	</cfif>
	ORDER BY #OrderColumn#
	</cfquery>
</cfif>

<cfif getRecords.recordCount lt 20>
	<cfset selectSize = getRecords.recordCount>
<cfelse>
	<cfset selectSize = 20>
</cfif>

<cfoutput>
<span class=normaltext>Use the up and down arrows to arrange items in the list in the correct order.  Press submit when you are finished.</span>

<form name="f1" action="#cgi.script_name#?action=#Request.Table.action#&#Request.Table.persistentParams#" method="post" onSubmit="selectAll(this.updownlist)">
<input type="hidden" name="UpdateListOrder" value="Yes">
<input type="hidden" name="statusMessage" value="Changes saved.">
<cfif IsDefined("queryParams")><INPUT TYPE="HIDDEN" NAME="queryParams" VALUE="#queryParams#"></cfif>
</cfoutput>

<TABLE BORDER="0">
<TR>
	<TD>
	<cfoutput>
	<SELECT NAME="updownlist" size="#selectSize#" MULTIPLE>
	</cfoutput>
		<cfoutput query="getRecords">
			<OPTION VALUE="#selectValue#"> #selectText#
		</cfoutput>
	</SELECT>
	</TD>
	<TD ALIGN="CENTER" VALIGN="MIDDLE">
	<cfoutput>
	<IMG SRC="#Request.Table.resourcesDir#/images/moveup.gif" ALT="Move Up" onClick="moveUp(document.f1.updownlist)" STYLE="cursor:hand;">
	<BR>
	<IMG SRC="#Request.Table.resourcesDir#/images/movedown.gif" ALT="Move Down" onClick="moveDown(document.f1.updownlist)" STYLE="cursor:hand;">
	</cfoutput>
	</TD>
</TR>
<TR>
	<TD align="center"><BR><INPUT TYPE="submit" VALUE="Submit"></TD>
</TR>
</TABLE>
</form>