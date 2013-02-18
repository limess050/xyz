<!--- Get existing values for all fields
Compare to form fields values
If changed, add to Chenged string
if Len(ChangedString), insert update record --->
<cfset TrackedColumns="PaymentMethodID,CCTypeID,CCExpireMonth,CCExpireYear,CSV,PaymentStatusID,PaymentDate,PaymentAmount">

<cfset ChangedString="">

<cfquery name="getOrig" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select #Replace(TrackedColumns,"_","","ALL")#
	From Orders
	Where OrderID=<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">
</cfquery>
<cfquery name="PaymentMethods" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select PaymentMethodID as SelectValue, Title as SelectText
	From PaymentMethods
	Order By PaymentMethodID
</cfquery>
<cfquery name="CCTypes" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select CCTypeID as SelectValue, Title as SelectText
	From CCTYpes
	Order By CCTypeID
</cfquery>
<cfquery name="PaymentStatuses" datasource="#Request.dsn#" username="#Request.dbusername#" password="#request.dbpassword#">
	Select PaymentStatusID as SelectValue, Title as SelectText
	From PaymentStatuses
	Order By PaymentStatusID
</cfquery>
<cfloop list="#TrackedColumns#" index="i">
	<cfset LabelName=Replace(Replace(i,"ID",":"),"_"," ","ALL")>
	<cfset ColumnName=Replace(i,"_","","ALL")>
	<cfset OldValue=Evaluate('getOrig.' & ColumnName)>
	<cfset NewValue=Evaluate(ColumnName)>	
	<cfif ColumnName is "PaymentDate">
		<cfset OldValue=DateFormat(OldValue,"dd/mm/yyyy")>
	</cfif>
	
	<cfif OldValue neq NewValue>
		<cfif ListFind("PaymentMethodID,CCTypeID,PaymentStatusID",ColumnName)>
			<cfswitch expression="#ColumnName#">
				<cfcase value="PaymentMethodID">
					<cfloop query="PaymentMethods">
						<cfif Len(NewValue) and SelectValue is NewValue>
							<cfset NewValue=SelectText>
						</cfif>
						<cfif Len(OldValue) and SelectValue is OldValue>
							<cfset OldValue=SelectText>
						</cfif>
					</cfloop>
				</cfcase>
				<cfcase value="CCTypeID">
					<cfloop query="CCTypes">
						<cfif Len(NewValue) and SelectValue is NewValue>
							<cfset NewValue=SelectText>
						</cfif>
						<cfif Len(OldValue) and SelectValue is OldValue>
							<cfset OldValue=SelectText>
						</cfif>
					</cfloop>
				</cfcase>
				<cfcase value="PaymentStatusID">
					<cfloop query="PaymentStatuses">
						<cfif Len(NewValue) and SelectValue is NewValue>
							<cfset NewValue=SelectText>
						</cfif>
						<cfif Len(OldValue) and SelectValue is OldValue>
							<cfset OldValue=SelectText>
						</cfif>
					</cfloop>
				</cfcase>
			</cfswitch>
		</cfif>
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
		(OrderID, UpdateDate, UpdatedByID, Descr)
		VALUES
		(<cfqueryparam cfsqltype="cf_sql_integer" value="#pk#">,
		GetDate(),
		<cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">,
		<cfqueryparam value="#ChangedString#" cfsqltype="CF_SQL_VARCHAR" maxlength="2000">)
	</cfquery>
</cfif>

