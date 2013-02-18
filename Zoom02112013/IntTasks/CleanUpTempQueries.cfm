

<!--- This is a scheduled template that runs every 10 minutes. It removes CategoryQuery and ParentSectionQuery records that are over three hours old. --->

<cfquery name="deletePSQLines"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Delete From ParentSectionQueryLines
	Where DateCreated <  DATEADD(hh,-3,GetDate())
</cfquery>

<cfquery name="delPSQs"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Delete From ParentSectionQueries
	Where DateCreated <  DATEADD(hh,-3,GetDate())
</cfquery>

<cfquery name="deleteCQLines"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Delete From CategoryQueryLines
	Where DateCreated <  DATEADD(hh,-3,GetDate())
</cfquery>

<cfquery name="DeleteCQs"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Delete From CategoryQueries
	Where DateCreated <  DATEADD(hh,-3,GetDate())
</cfquery>


