<!--- Get existing values for all fields
Compare to form fields values
If changed, add to Chenged string
if Len(ChangedString), insert update record --->
<cfset TrackedColumns="Company,Password,Contact_First_Name,Contact_Last_Name,Contact_Phone_Land,Contact_Phone_Mobile,Contact_Outside_Phone_Country_Code,Contact_Outside_Phone,Contact_Email,Alt_Contact_First_Name,Alt_Contact_Last_Name,Alt_Contact_Phone_Land,Alt_Contact_Phone_Mobile,Alt_Contact_Outside_Phone_Country_Code,Alt_Contact_Outside_Phone,Alt_Contact_Email">

<cfset ChangedString="">

<cfquery name="getOrig" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select #Replace(TrackedColumns,"_","","ALL")#
	From LH_Users
	Where UserID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>
<cfloop list="#TrackedColumns#" index="i">
	<cfset LabelName=Replace(Replace(Replace(i,"ID",":"),"Alt","Secondary","ALL"),"_"," ","ALL")>
	<cfset ColumnName=Replace(i,"_","","ALL")>
	<cfset OldValue=Evaluate('getOrig.' & ColumnName)>
	<cfset NewValue=Evaluate(ColumnName)>	
	<cfif OldValue neq NewValue>
		<cfif not Len(NewValue)>
			<cfset ChangedString=ListAppend(ChangedString,"#LabelName# '#OldValue#' deleted.","|")>
		<cfelseif Not Len(OldValue)>
			<cfset ChangedString=ListAppend(ChangedString,"#LabelName# '#NewValue#' entered.","|")>
		<cfelse>
			<cfset ChangedString=ListAppend(ChangedString,"#LabelName# '#OldValue#' changed to '#NewValue#'.","|")>
		</cfif>
	</cfif>
</cfloop>
<cfif Len(ChangedString)>
	<cfquery name="updatedBy" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Insert into Updates
		(UserID, UpdateDate, UpdatedByID, Descr)
		VALUES
		(<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">,
		GetDate(),
		<cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">,
		<cfqueryparam value="#ChangedString#" cfsqltype="CF_SQL_VARCHAR" maxlength="2000">)
	</cfquery>
</cfif>

