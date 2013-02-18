<!--- Make sure Section name is unique to its siblings. --->

<cfquery name="getDupe" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select SectionID
	From Sections
	Where Title=<cfqueryparam value="#Title#" cfsqltype="CF_SQL_VARCHAR">
	and parentSectionID<cfif Len(ParentSectionID)>=<cfqueryparam cfsqltype="cf_sql_integer" value="#parentSectionID#"><cfelse> is null</cfif>
	and SectionID<><cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>

<cfif getDupe.RecordCount>
	<P CLASS=PAGETITLE>Data Validation Error</P>
	<P><SPAN CLASS=STATUSMESSAGE>
	There were problems processing the form.  See details below and go back to correct the problems.
	<ul><LI>The value in the <b>Section Name</b> field is already in use <cfif Len(ParentSectionID)>in the selected parent section<cfelse>as a parent section</cfif>. It must be unique within the parent section<cfif not Len(ParentSectionID)>s</cfif>.</ul>

	</SPAN></P>
	<FORM>
	<INPUT TYPE="BUTTON" VALUE="Go Back" ONCLICK="history.back()">
	</FORM>
	<cfabort>
</cfif>
