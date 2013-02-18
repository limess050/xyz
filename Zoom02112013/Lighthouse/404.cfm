<!--- Handle 404 errors.  Set this script to handle 404 errors in the web server --->
<cfif Len(cgi.query_string) gt 0>
	<!--- Get name in IIS --->
	<cfset name = REReplace(cgi.query_string,"404;https?://[^/]+","")>
	<!--- Get query string --->
	<cfset queryStart = Find("?",name)>
	<cfif queryStart gt 0>
		<cfif queryStart lt Len(name)>
			<cfset queryString = Mid(name,queryStart+1,Len(name)-queryStart)>
		</cfif>
		<cfset name = Left(name,queryStart-1)>
	</cfif>
<cfelseif Len(cgi.redirect_url) gt 0>
	<!--- Get name and query string in Apache --->
	<cfset name = cgi.redirect_url>
	<cfset queryString = cgi.redirect_query_string>
</cfif>
<cfif StructKeyExists(variables,"name")>
	
	<!--- Extract page name --->
	<cfif len(Request.AppVirtualPath) gt 0>
		<!---Remove name to the app root --->
		<cfset name = ReplaceNoCase(name,Request.AppVirtualPath,"")>
	</cfif>
	<!---Remove leading slash --->
	<cfset name = REReplace(name,"^/","")>
	<!---Remove Trailing slash --->
	<cfset name = REReplace(name,"/$","")>
	
	<!--- If there is a query string, parse parameters into url scope --->
	<cfif StructKeyExists(variables,"queryString")>
		<cfloop list="#queryString#" delimiters="&" index="nameValue">
			<cfif ListLen(nameValue,"=") gt 1>
				<cfset url[ListFirst(nameValue,"=")] = UrlDecode(ListLast(nameValue,"="))>
			</cfif>
		</cfloop>
	</cfif>
	
	<cfif ListFindNoCase("gif,jpg,jpeg,png,js,ico,css,php",ListLast(name,"."))>
		<!--- Files with extensions that shouldn't result in a db lookup --->
		<cfheader statuscode="404">
		<h1>Not Found</h1>
		<p>The requested url was not found on this server.</p>
		<cfabort>
	<cfelse>
		<!--- serve page --->
		<cfinclude template="../page.cfm">
		<cfabort>
	</cfif>
	
</cfif>

<cfheader statuscode="404">

<!--- The page name wasn't found.  Display generic 404 error. --->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<link rel=stylesheet href="style.css" type="text/css">
	<title>File Not Found</title>
</head>
<body>
<h1>File Not Found</h1>
</body>
</html>
