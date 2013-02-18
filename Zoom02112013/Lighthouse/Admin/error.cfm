<cffunction name="displayStructure" output="false" returntype="string">
	<cfargument required="true" name="struct" type="struct">
	<cfset s = "<table border=1 cellspacing=0>">
	<cfloop collection="#struct#" item="var">
		<cfif IsSimpleValue(struct[var])>
			<cfif Len(struct[var]) gt 0>
				<cfset s = s & "<tr><td>#var#</td><td>#struct[var]#</td></tr>">
			</cfif>
		<cfelseif IsStruct(struct[var])>
			<cfset s = s & "<tr><td>#var#</td><td>#displayStructure(struct[var])#</td></tr>">
		<cfelse>
			<cfset s = s & "<tr><td>#var#</td><td>[Complex Value]</td></tr>">
		</cfif>
	</cfloop>
	<cfset s = s & "</table>">
	<cfreturn s>
</cffunction>

<!--- Set default for a production environment. Override for local or devel environments.  --->
<cfif Not StructKeyExists(Request,"lh_sendErrorEmail")>
	<cfset Request.lh_sendErrorEmail = true>
</cfif>
<cfif Not StructKeyExists(Request,"lh_showErrorInfo")>
	<cfset Request.lh_showErrorInfo = false>
</cfif>

<!--- Get logged-in user --->
<cfif StructKeyExists(session,"userID")>
	<cfif Len(session.userID) gt 0>
		<cfset userid = session.userid>
	<cfelse>
		<cfset userid = "">
	</cfif>
<cfelse>
	<cfset userid = "">
</cfif>

<cfset tagContext = "<table border=1 cellspacing=0><tr><th>Tag</th><th>Line</th><th>Template</th>">
<cfloop index="i" from="1" to="#ArrayLen(error.tagContext)#">
	<cfset tagContext = tagContext & "<tr>">
	<cfif StructKeyExists(error.tagContext[i],"ID")>
		<cfset tagContext = tagContext & "<td>" & error.tagContext[i].ID & "</td>">
	<cfelse>
		<cfset tagContext = tagContext & "<td></td>">
	</cfif>
	<cfset tagContext = tagContext & "<td>" & error.tagContext[i].Line & "</td>">
	<cfset tagContext = tagContext & "<td>" & error.tagContext[i].Template & "</td>">
	<cfset tagContext = tagContext & "</tr>">
</cfloop>
<cfset tagContext = tagContext & "</table>">

<cfset errorInfo = "<p><b>Error Info:</b></p>
<ul>
	<li><b>Requested Page:</b> #error.template#?#error.queryString#</li>
	<li><b>Referring Page:</b> #cgi.HTTP_REFERER#</li>
	<li><b>Logged in user:</b> #userid#</li>
	<li><b>Date and Time:</b> #DateFormat(error.dateTime)# #TimeFormat(error.dateTime)#</li>
	<li><b>Error Message</b>:<p>#error.diagnostics#</p></li>
</ul>
<p><b>Exception Info:</b></p>
<ul>
   <li><b>Type:</b> #error.Type#
   <li><b>Root Cause:</b> #error.rootCause#
   <li><b>Message:</b> #error.message#
</ul>
<p><b>Tag Context:</b></p>
#tagContext#
<p><b>Url:</b></p>#displayStructure(Url)#
<p><b>Form:</b></p>#displayStructure(form)#
<p><b>CGI:</b></p>#displayStructure(cgi)#
">

<cfif Request.lh_sendErrorEmail>
	<cfmail to="#error.mailto#" from="websiteerrors@modernsignal.com" subject="#Request.glb_title# Error (#cgi.http_host#)" type="html">#errorInfo#</cfmail>
</cfif>

<cfoutput>#Evaluate(DE(Application.ErrorMessage))#</cfoutput>
