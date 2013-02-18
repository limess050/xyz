<cfsilent>
<cfsetting showDebugOutput = "no">
<cfinclude template="checkLogin.cfm">
<cfset checkPermissionFunction = "editPage">
<cfinclude template="checkPermission.cfm">
<cfobject component="#Application.ComponentPath#.#url.object#" name="obj">
<cfheader name="Expires" value="#Now()#">

<cfswitch expression="#url.object#">
	<cfcase value="Page">
		<cfswitch expression="#url.method#">
			<cfcase value="GetWorkingPage">
				<cfset output = "/*" & Application.Json.encode(obj.GetWorkingPage(url.pageID),"array","lower",false) & "*/">
			</cfcase>
			<cfcase value="GetTreeNodes">
				<cfset widgetId = Application.Json.decode(url.data).node.widgetId>
				<cfset output = Application.Json.encode(obj.GetTreeNodes(widgetId),"array","lower",false,"title,widgetId,isFolder")> 
			</cfcase>
			<cfcase value="Update">
				<cfset obj.Init(form)>
				<cfset output = "/*" & obj.update() & "*/">
			</cfcase>
		</cfswitch>
	</cfcase>
	<cfcase value="Topic">
		<cfswitch expression="#url.method#">
			<cfcase value="GetAll">
				<cfset topics = obj.GetAll()>
				<cfsavecontent variable="output">
					/*[<cfoutput query="topics"><cfif currentRow gt 1>,</cfif>["#JSStringFormat(topicid)#","#JSStringFormat(topic)#"]</cfoutput>]*/
				</cfsavecontent>
			</cfcase>
		</cfswitch>
	</cfcase>
</cfswitch>

</cfsilent><cfoutput>#output#</cfoutput>