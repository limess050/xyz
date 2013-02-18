<!--- This takes a date as an input and swaps the day and month values so that a date entered in dd/mm/yyy foramt is output in mm/dd/yyyy formt --->
<cfif not IsDefined('InDate')>
	No Date value passed.
	<cfabort>
</cfif>

<cfif Len(InDate)>
	<cfset OutDate1=ListGetAt(InDate,1,'/')>
	<cfset OutDate2=ListGetAt(InDate,2,'/')>
	<cfset OutDate3=ListGetAt(InDate,3,'/')>
	<cfset OutDate=OutDate2 & '/' & OutDate1 & '/' & OutDate3>								
	<cfif not IsValid("USDate",OutDate)>
		Invalid Date entered.
		<cfabort>
	</cfif>
<cfelse>
	<cfset OutDate="">				
</cfif>
