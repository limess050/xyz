<!---
File Name: 	MS_TableDisplay_*.cfm
Author: 	David Hammond
Description:
	Display tag
Inputs:
--->

<cfif Len(PageVariables.statusMessage) gt 0>
	<P CLASS=STATUSMESSAGE><cfoutput>#PageVariables.statusMessage#</cfoutput></P>
</cfif>