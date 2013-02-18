<!--- Make sure Section name is unique to its siblings. --->

<cfquery name="getDupe" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select CategoryID
	From Categories
	Where Title=<cfqueryparam value="#Title#" cfsqltype="CF_SQL_VARCHAR">
	and parentSectionID=<cfqueryparam cfsqltype="cf_sql_integer" value="#parentSectionID#">
	and SectionID<cfif Len(SectionID)>=<cfqueryparam cfsqltype="cf_sql_integer" value="#SectionID#"><cfelse> is null</cfif>
	and CategoryID<><cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>

<cfif getDupe.RecordCount>
	<P CLASS=PAGETITLE>Data Validation Error</P>
	<P><SPAN CLASS=STATUSMESSAGE>
	There were problems processing the form.  See details below and go back to correct the problems.
	<ul><LI>The value in the <b>Category Name</b> field is already in use in the selected <cfif not Len(SectionID)>parent </cfif>section. It must be unique within the <cfif not Len(SectionID)>parent </cfif>section.</ul>

	</SPAN></P>
	<FORM>
	<INPUT TYPE="BUTTON" VALUE="Go Back" ONCLICK="history.back()">
	</FORM>
	<cfabort>
</cfif>
