<cfquery name="UPDATEPages" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	UPDATE #Request.dbprefix#_Pages 
	SET statusID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Application.Lighthouse.WorkInProgressStatus#">
	WHERE pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageID#">
</cfquery>
<html>
<script>
<cfoutput>
//opener.changeProperties("#JsStringFormat(title)#","#JsStringFormat(navTitle)#");
opener.reloadToolbar("pageID=#pageID#&reloadPage=1");
</cfoutput>
window.close();
</script>
</html>
<cfabort>