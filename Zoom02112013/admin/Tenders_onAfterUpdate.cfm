<cfif Reviewed is "1"><!--- If record was just marked "Reviewed" it will be sent when the default View page is loaded, so redirect to there. --->
	<cflocation url="Tenders.cfm" addToken="No">
</cfif>
