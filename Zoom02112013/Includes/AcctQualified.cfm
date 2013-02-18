<cfset HR4Qualified=0>
<cfset FSBO4Qualified=0>
<cfif Len(AcctUserID)>
	<cfquery name="getAccountQuals" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
		Select AQ.HR4Qualified, AQ.FSBO4Qualified
		From AccountsQualified AQ
		Where AQ.UserID=<cfqueryparam value="#AcctUserID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif getAccountQuals.HR4Qualified>
		<cfset HR4Qualified=1>
	</cfif>
	<cfif getAccountQuals.FSBO4Qualified>
		<cfset FSBO4Qualified=1>
	</cfif>
</cfif>