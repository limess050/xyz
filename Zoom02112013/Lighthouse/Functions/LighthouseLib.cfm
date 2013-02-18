<!---
This library contains functions specific to Lighthouse
--->

<cffunction name="GetProperty" description="Gets a property from a struct, and returns default if it doesn't exist." output="false" returntype="Any">
	<cfargument name="Properties" required="true" type="Struct">
	<cfargument name="Property" required="true" type="String">
	<cfargument name="DefaultValue" required="true" type="Any">
	<cfif StructKeyExists(Properties,Property)>
		<cfreturn Properties[Property]>
	<cfelse>
		<cfreturn DefaultValue>
	</cfif>
</cffunction>

<!---
 SQL String
 
 @param s (required) String to escape
 @return sqlString	The string with single quotes escaped.
 --->
<cffunction name="sqlStringFormat" output="false" returntype="string">
	<cfargument name="s" required="true" type="string">
	<cfreturn Replace(s,"'","''","ALL")>
</cffunction>

<cffunction name="sqlStringListFormat" output="false" returntype="string">
	<cfargument name="list" required="true" type="string">
	<cfset var newList = "">
	<cfloop list="#list#" index="item">
		<cfset newList = ListAppend(newList,"'" & sqlStringFormat(item) & "'")>
	</cfloop>
	<cfreturn newList>
</cffunction>

<!---
 Adds a parameter to a query string
 
 @param queryString	(required) current query string
 @param name			(required) parameter name
 @param value			(required) parameter value
 @return Returns a simple value
--->
<cffunction name="addQueryParam" output="false" returntype="string">
	<cfargument name="queryString" required="true" type="string">
	<cfargument name="name" required="true" type="string">
	<cfargument name="value" required="true" type="string">
	<cfif Len(queryString) is 0>
		<cfreturn name & "=" & UrlEncodedFormat(value)>
	<cfelse>
		<cfreturn queryString & "&" & name & "=" & UrlEncodedFormat(value)>
	</cfif>
</cffunction>

<!---
 Adds a query string parameter to a url
 
 @param url	(required) current url
 @param name (required) parameter name
 @param value (required) parameter value
 @return Returns a simple value
--->
<cffunction name="addQueryParamToUrl" output="false" returntype="string">
	<cfargument name="url" required="true" type="string">
	<cfargument name="name" required="true" type="string">
	<cfargument name="value" required="true" type="string">
	<cfif Find("?",url) gt 0>
		<cfreturn url & "&" & name & "=" & UrlEncodedFormat(value)>
	<cfelse>
		<cfreturn url & "?" & name & "=" & UrlEncodedFormat(value)>
	</cfif>
</cffunction>

<!---
 Removes a parameter from a query string
 
 @param queryString	(required) current query string
 @param name			(required) parameter name
 @return Returns a simple value
--->
<cffunction name="removeQueryParam" output="false" returntype="string">
	<cfargument name="queryString" required="true" type="string">
	<cfargument name="name" required="true" type="string">
	<cfreturn REReplaceNoCase(queryString,"(&amp;#name#=[^&]*|#name#=[^&]*&amp;|#name#=[^&]*)","")>
</cffunction>

<cfscript>
/**
 * Turns a list into a query.
 *
 * @param list				The list
 * @param columnList		List of column names
 * @param rowDelimiter		Delimiter character for rows. Default is ;
 * @param valueDelimiter	Delimiter character for values. Default is ,
 * @return Returns a query
 */
function listToQuery(list, columnList) {

	// Initialize arguements
	var rowDelimiter = GetProperty(Arguments,"3",";");
	var valueDelimiter = GetProperty(Arguments,"4",",");

	// Create query
	var q = QueryNew(columnList);
	var i = 1;
	var n = 1;
	var values = "";
	var value = "";

	// Loop through rows
	for (i = 1; i lte ListLen(list,rowDelimiter); i = i + 1) {
		QueryAddRow(q);
		values = ListGetAt(list,i,rowDelimiter);
		value = "";
		// Loop through columns
		for (n = 1; n lte ListLen(columnList); n = n + 1) {
			// If value not set for a column, the last value given in the row will be used.
			if (n lte ListLen(values,valueDelimiter)) {
				value = ListGetAt(values,n,valueDelimiter);
			}
			QuerySetCell(q,ListGetAt(columnList,n),value);
		}
	}

	return q;
}

/**
 * Sets session variables for browser version
 *
 * @return Nothing
 */
function getBrowserVersion() {
	if (Not IsDefined("session.browserName")) {
		session.browserName = "Unknown";
		session.browserVersion = "0";
		session.browserPlatform = "Windows";
		session.browserGeckoVersion = "0";

		//WriteOutput(cgi.http_user_agent & "<br>");

		// Match user agent with regular expression
		match = REFind("^([^\/]+)/([^ ]+) \(([^\)]+(\([^\)]+\)[^\)]*)*[^\)]*)\)( Gecko/([0-9]+))?( (.+))?$",cgi.http_user_agent,1,true);

		if (match.pos[1] is 1) {
			session.browserName = Mid(cgi.http_user_agent,match.pos[2],match.len[2]);
			session.browserVersion = Mid(cgi.http_user_agent,match.pos[3],match.len[3]);
			productComment = Mid(cgi.http_user_agent,match.pos[4],match.len[4]);
			if (match.pos[6] gt 0) {
				session.browserGeckoVersion = Mid(cgi.http_user_agent,match.pos[7],match.len[7]);
			}
			if (match.pos[8] gt 0) {
				vendorToken = Mid(cgi.http_user_agent,match.pos[9],match.len[9]);
			} else {
				vendorToken = "";
			}

			// Opera
			if (Find("Opera",vendorToken) gt 0) {
				session.browserName = "Opera";
				session.browserVersion = Val(Replace(vendorToken,"Opera ",""));

			// Internet Explorer
			} else if (Find("MSIE",productComment)) {
				session.browserName = "MSIE";
				session.browserVersion = Val(RemoveChars(productComment,1,Find("MSIE",productComment)+4));

			// Safari
			} else if (Find("Safari",vendorToken) gt 0) {
				session.browserName = "Safari";
				session.browserVersion = Val(RemoveChars(vendorToken,1,Find("Safari",vendorToken)+6));

			// Firefox, Netscape, etc.
			} else {
				match = REFind("^([^\/]+)/([^ ]+).*$",vendorToken,1,true);
				if (match.pos[1] is 1) {
					session.browserName = Mid(vendorToken,match.pos[2],match.len[2]);
					session.browserVersion = Mid(vendorToken,match.pos[3],match.len[3]);
				}
			}

			if (FindNoCase("Mac",productComment)) {
				session.browserPlatform="Mac";
			}

			//WriteOutput("Name: " & session.browserName & "<br>");
			//WriteOutput("Version: " & session.browserVersion & "<br>");
			//WriteOutput("Platform: " & session.browserPlatform & "<br>");
			//WriteOutput("Gecko: " & session.browserGeckoVersion & "<br>");
		}
	}
}

/**
 * Determines if client browser is mshtml compatible (IE 5.5+ on Windows)
 *
 * @return boolean
 */
function browserSupportsMSHtml() {
	if (Not IsDefined("session.browserName")) {
		getBrowserVersion();
	}
	if (session.browserName is "MSIE" and session.browserVersion gte 5.5 and session.browserPlatform is "Windows") {
		return true;
	} else {
		return false;
	}

}

/**
 * Determines if client browser is midas compatible (Mozilla 5+, Firefox)
 *
 * @return boolean
 */
function browserSupportsMidas() {
	if (Not IsDefined("session.browserName")) {
		getBrowserVersion();
	}
	if (session.browserGeckoVersion gt 0) {
		return true;
	} else {
		return false;
	}

}

/**
 * Gets a relative path to the server root directory
 *
 * @return baseRelativePath	The relative path to the root directory
 */
function getBaseRelativePath() {
	return repeatstring("../", listlen(CGI.script_name, "/") - 1);
}

/**
 * CSV Value
 * If value contains a comma, wraps value in quotation marks, and escapes any quotation marks.
 *
 * @return csvValueFormat	The escaped string
 */
function csvValueFormat(s) {
	if (findOneOf(",""#Chr(13)##Chr(10)#",s) gt 0) {
		return """" & Replace(s,"""","""""","ALL") & """";
	} else {
		return s;
	}
}

/**
 * Get a date formated for use in RSS pubDate field
 *
 * @param date	(required)
 * @return string
 */
function rssDateFormat(d) {
	utcdate = DateAdd("h",GetTimeZoneInfo().utcHourOffset,d);
	return DateFormat(utcDate,"ddd, d mmm yyyy") & " " & TimeFormat(utcDate,"HH:mm:ss") & " UT";
}

/**
 * Get a date formated to compy with RFC 3339 (http://www.faqs.org/rfcs/rfc3339.html).
 * Suitable for use in Atom feeds
 *
 * @param date	(required)
 * @return string
 */
function internetDateFormat(d) {
	utcdate = DateAdd("h",GetTimeZoneInfo().utcHourOffset,d);
	return DateFormat(utcDate,"yyyy-mm-dd") & "T" & TimeFormat(utcDate,"HH:mm:ssZ");
}

/**
 * Converts form field parameters into query parameters for the current page
 *
 * @return Returns a simple value.
 */
function getParameterizedUrl() {
	ffparams = "";
	if (isdefined("fieldnames")) {
		for (i = 1; i lte ListLen(fieldnames); i = i + 1) {
			formField = ListGetAt(fieldnames,i);
			if (StructKeyExists(form,formfield)) {
				if (Len(form[formfield]) gt 0) {
					ffparams = ListAppend(ffparams, "#formfield#=#urlencodedformat(form[formfield])#", "&");
				}
			}
		}
	}
	thishref = "#cgi.script_name#?#cgi.query_string#";
	if (len(ffparams)) {
		thishref = "#thishref#&#ffparams#";
	}
	return thishref;
}

/**
 * Should be compatible with javascript decodeUri function (needs work)
 *
 * @param uri	(required)
 * @return Decoded uri
 */
function jsDecodeUri(uri) {
	return Replace(uri,"&amp;","&","ALL");
}


/**
 * Gets the actual db table name for a standard MCF table.
 * Standard table names can be overriden by setting a variable in the form "MCFDB[table]TableName"
 * e.g. Request.MCFDBUsersTableName = "Members"
 *
 * @param table		The table
 * @return Returns a simple value.
 */
function lighthouse_getTableName(table) {
	if (StructKeyExists(Request,"MCFDB" & table & "TableName")) {
		return Request["MCFDB" & table & "TableName"];
	} else {
		return Request.dbprefix & "_" & table;
	}
}

/**
 * Adds an error to the Lighthouse error array.  Used to hold syntax errors.
 *
 * @param errorMsg	A string containing the error
 * @return Nothing
 */
function lighthouse_addError(errorMsg) {
	if (Not StructKeyExists(Request,"Lighthouse_Errors")) {
		Request.Lighthouse_Errors = ArrayNew(1);
	}
	ArrayAppend(Request.Lighthouse_Errors,errorMsg);
}

/**
 * Get password for userID
 *
 * @userID string
 * @return string
 */
function lighthouse_getPasswordForUserID(userID) {
	q = lh_query("SELECT password FROM #Request.dbprefix#_Users WHERE userID = #userID#");
	if (q.recordcount gt 0) {
		return "";
	} else {
		return q.password;
	}
}

// highlightKeywords() 
// Description: Highlight search criteria keywords in a given html string
//
// html, the source string, string where to look and replace 
// keywords, keywords to search for and replace with
// returns: string
function HighlightKeywords(html, keywords){
	highlightStart = "<span class=""searchedkeyword"">";
	highlightEnd = "</span>";
	// for each keyword	
	for (i=1; i lte ListLen(keywords, " "); i=i+1){
		// get keyword
		k = ListGetAt(keywords, i, " "); 
		// locate each instance of keyword
		j = FindNoCase(k, html, 0); 
		while (j gt 0) {
			// found
			// split into characters on the left and right sides of the keyword
			if (j gt 1) {
				leftSide = Reverse(Mid(html, 1, (j-1)));
			} else {
				leftSide = "";
			}
			if ((j+(len(k)-1)) lt len(html)) {
				rightSide = Right(html, (Len(html) - (j+(Len(k)-1))));
			} else {
				rightSide = "";
			}
			// determine if the keyword is inside an html tag or a character entity
			if (REFind("^[^<>]*<",leftSide) is 1 and REFind("^[^<>]*>",rightSide) is 1) {
				// inside a tag, don't hightlight
				j = findNoCase(k, html, j + Len(k)); 
			} else if (REFind("^\w*&",leftSide) is 1 and REFind("^\w*;",rightSide) is 1) {
				// inside an html character entity, don't hightlight
				j = findNoCase(k, html, j + Len(k)); 
			} else {
				// insert highlight
				html = Insert(highlightEnd, html, j+Len(k)-1);
				html = Insert(highlightStart, html, j-1);
				j = findNoCase(k, html, j + Len(k) + Len(highlightStart) + Len(highlightEnd)); 
			}
		}
	}
	return html;	
}
</cfscript>

<!---
Converts a structure into a javascript array

@struct structure
@jsVar string
--->
<cffunction name="StructToJsObject" output="false" returntype="string">
	<cfargument name="struct" required="true" type="struct">
	<cfargument name="includeEmptyValues" type="boolean" default="true">
	<cfset props = "">
	<cfloop collection="#struct#" item="key">
		<cfif IsSimpleValue(struct[key])>
			<cfif includeEmptyValues or Len(struct[key]) gt 0>
				<cfset props = ListAppend(props,"#key#:""#jsStringFormat(struct[key])#""")>
			</cfif>
		</cfif>
	</cfloop>
	<cfreturn "{" & props & "}">
</cffunction>

<!---
 Generate an auto-login code for current user

 @return code - string
--->
<cffunction name="lighthouse_getLoginCode" output="false" returntype="string">
	<cfif StructKeyExists(session,"loginCode")>
		<cfreturn session.loginCode>
	<cfelseif Not StructKeyExists(session,"userID")>
		<cfreturn "">
	<cfelseif Len(session.userID) is 0>
		<cfreturn "">
	<cfelse>
		<!---get password for user --->
		<cfset pwd = lighthouse_getPasswordForUserID(session.userID)>
		<!---construct code --->
		<cfset session.loginCode = UrlEncodedFormat(session.userID & "," & encrypt(cftoken,pwd))>
		<cfreturn session.loginCode>
	</cfif>
</cffunction>

<!---
 Check a login code generated by lighthouse_getLoginCode()

 @code string
 @return boolean
--->
<cffunction name="lighthouse_verifyLoginCode" output="false" returntype="boolean">
	<cfargument name="code" required="true" type="string">
	<cftry>
		<!---deconstruct code --->
		<cfset userID = ListFirst(code)>
		<cfset clientID = decrypt(ListDeleteAt(code,1),lighthouse_getPasswordForUserID(userID))>
		<cfquery name="q" datasource="#Request.dsn#" username="#Request.username#" password="#Request.password#">
			SELECT data FROM MS_CData 
			WHERE clientid = <cfqueryparam value="#clientID#" cfsqltype="cf_sql_integer"> 
				and setting = <cfqueryparam value="userID" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!---make sure userID mateches clientID --->
		<cfif userID is q.data>
			<!---make sure request is coming from the same ip address --->
			<cfquery name="q2" datasource="#Request.dsn#" username="#Request.username#" password="#Request.password#">
				SELECT data FROM MS_CData 
				WHERE clientid = <cfqueryparam value="#clientID#" cfsqltype="cf_sql_integer"> 
					and setting = <cfqueryparam value="remote_addr" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfif q2.data is cgi.remote_addr>
				<cfset session.userID = userID>
				<cfreturn true>
			<cfelse>
				<cfreturn false>
			</cfif>
		<cfelse>
			<cfreturn false>
		</cfif>
		<cfcatch type="any">
			<cfreturn false>
		</cfcatch>
	</cftry>
</cffunction>

<!---
 Strip and alphanumeric characters and make lower case, for use as page name in url

 @name string
 @return string
--->
<cffunction name="lh_getUrlPageName" output="false" returntype="string">
	<cfargument name="name" required="true" type="string">
	<cfreturn ReReplace(lcase(name),"[^a-z0-9\-]","","ALL")>
</cffunction>

<!---
 Take html and make it well-formed xml
 
 @param html The html
 @return text string
 --->
<cffunction name="StripHtml" output="false" returntype="string">
	<cfargument name="html" required="true" type="string">
	<!--- strip html tags --->
	<cfreturn REReplace(html,"<[^>]*>"," ","ALL")>
</cffunction>

<!---
 Remove all Line breaks from a string
 
 @param s The string
 @return text string
 --->
<cffunction name="StripLineBreaks" output="false" returntype="string">
	<cfargument name="s" required="true" type="string">
	<cfreturn REReplace(s,"[\r\n]+"," ","ALL")>
</cffunction>

<!---
 Get query string to add to url for links that require authentication
 
 @return string
--->
<cffunction name="lh_getAuthToken" output="false" returntype="string">
	<cfif Not StructKeyExists(Request,"lh_authToken")>
		<cfif IsDefined("url.lh_authCode")>
			<cfset Request.lh_authToken = "lh_auth=1&amp;lh_authCode=#UrlEncodedFormat(url.lh_authCode)#">
		<cfelseif Request.lh_authType is "auto">
			<cfset Request.lh_authToken = "lh_auth=1&amp;lh_authCode=#lighthouse_getLoginCode()#">
		<cfelse>
			<cfset Request.lh_authToken = "lh_auth=1">
		</cfif>
	</cfif>
	<cfreturn Request.lh_authToken>
</cffunction>

<!---
 Adds authToken to the url
 
 @param url		(required) current query string
 @return 		Returns a simple value
--->
<cffunction name="lh_addAuthToken" output="false" returntype="string">
	<cfargument name="url" required="true" type="string">
	<cfif Find("?",url) gt 0>
		<cfreturn url & "&amp;" & Application.Lighthouse.lh_getAuthToken()>
	<cfelse>
		<cfreturn url & "?" & Application.Lighthouse.lh_getAuthToken()>
	</cfif>
</cffunction>


<!---
 Gets client data using custom storage engine.
 Sets session variable for setting if it is not already set.
 This is intended to work in a way that is equivalent to client variables stored in the database.
 It can be more secure that client variables in a shared server environment, however, because in order to
 use database client storage the database username and password must be stored in the CF administrator.

 @param setting		The setting to get.
 @param default		The value to return if no setting is found for the user. (Optional)
 @return string
--->
<cffunction name="lh_getClientInfo" output="false" returnType="string">
	<cfargument name="setting" type="string" required="Yes">
	<cfargument name="default" type="string" default="">

	<cftry>
		<!--- Get value from session.variable, if available --->
		<cfif StructKeyExists(session,setting)>

			<cfreturn session[setting]>

		<!--- Set or get value in database --->
		<cfelse>

			<cfquery name="getData" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				SELECT data FROM MS_CData 
				WHERE clientid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cftoken#"> 
					and setting = <cfqueryparam cfsqltype="cf_sql_varchar" value="#setting#">
			</cfquery>
			<cfif getData.recordcount gt 0>
				<cfset foo = SetVariable("session.#setting#",getData.data)>
				<cfreturn getData.data>
			<cfelse>
				<cfset foo = SetVariable("session.#setting#",default)>
				<cfreturn default>
			</cfif>
		</cfif>

		<cfcatch type="database">
			<!--- MS_CData table probably does not exist. --->
			<cfset foo = SetVariable("session.#setting#",default)>
			<cfreturn default>
		</cfcatch>
	</cftry>
</cffunction>

<!---
 Sets client data using custom storage engine.
 Sets session variable for setting too.
 This is intended to work in a way that is equivalent to client variables stored in the database.
 It can be more secure that client variables in a shared server environment, however, because in order to
 use database client storage the database username and password must be stored in the CF administrator.

 @param setting		The setting to set.
 @param data		The value to set.
 @param secondTry 	Used internally by the function if a database error occurs.
 @return String
--->
<cffunction name="lh_setClientInfo" output="false" returnType="string">

	<cfargument name="setting" type="string" required="Yes">
	<cfargument name="data" type="string" required="Yes">
	<cfargument name="secondtry" type="boolean" default="false">
	<cfargument name="errorMsg" type="string" default="">

	<cftry>

		<cfset clientid = cftoken>

		<cfquery name="checkData" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
			SELECT data FROM MS_CData 
			WHERE clientid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cftoken#"> 
				and setting = <cfqueryparam cfsqltype="cf_sql_varchar" value="#setting#">
		</cfquery>
		<cfif checkData.recordcount is 0>
			<cfquery name="setData" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				INSERT INTO MS_CData (clientid,setting,data)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#clientid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#setting#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#data#">
				)
			</cfquery>
		<cfelse>
			<cfquery name="setData" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				UPDATE MS_CData
				SET data = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data#">
				WHERE clientid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#clientid#">
					and setting = <cfqueryparam cfsqltype="cf_sql_varchar" value="#setting#">
			</cfquery>
		</cfif>
		<cfset foo = SetVariable("session.#setting#",data)>
		<cfreturn data>

		<cfcatch type="database">
			<!--- If a database error is thrown, try to create data table before throwing error. --->
			<cfif not secondtry>
				<cftry>
					<cfquery name="createTable" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						CREATE TABLE dbo.MS_CData (ClientID int NOT NULL, Setting varchar(50), Data varchar(8000), DateSet smalldatetime NULL )
					</cfquery>
					<cfcatch>
						<!--- varchar(1000) will fail in Access, so try using a memo field --->
						<cftry>
							<cfquery name="createTable" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
								CREATE TABLE dbo.MS_CData (Clientid int NOT NULL, Setting varchar(50) NOT NULL, Data memo NULL)
							</cfquery>
							<cfcatch></cfcatch>
						</cftry>
					</cfcatch>
				</cftry>
				<cftry>
					<!--- try to create primary key constraint/index --->
					<cfquery name="setpk" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						ALTER TABLE dbo.MS_CData ADD CONSTRAINT DF_MS_CData_DateSet DEFAULT getDate() FOR DateSet
					</cfquery>
					<cfquery name="setpk" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						ALTER TABLE dbo.MS_CData ADD CONSTRAINT PK_MS_CData PRIMARY KEY CLUSTERED (Clientid,Setting)
					</cfquery>
					<cfcatch>
						<cftry>
							<!--- try it without the clustered key word --->
							<cfquery name="setpk" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
								ALTER TABLE MS_CData ADD CONSTRAINT PK_MS_CData PRIMARY KEY (Clientid,Setting)
							</cfquery>
							<cfcatch></cfcatch>
						</cftry>
					</cfcatch>
				</cftry>
				<cfreturn lh_setClientInfo(setting=setting, data=data, secondtry=true, errorMsg=cfcatch.detail)>
			<cfelse>
				<cfthrow type="clientInfo"
					message="Error trying to save client information."
					detail="A database error occurred.  An attempt was made to create the MS_CData table was made, but was not successful.<p><b>Error 1:</b><br>#errorMsg#</p><p><b>Error 2:</b><br>#cfcatch.detail#</p>">
			</cfif>
		</cfcatch>
	</cftry>
</cffunction>

<!---
 Mimics the cfquery tag.

 @sql string - sql statement
 @param datasource
 @param username
 @param password
 @return Query
--->
<cffunction name="lh_query" output="false" returnType="query">
	<cfargument name="sql" type="string" required="true">
	<cfargument name="datasource" type="string" required="true" default="#Request.dsn#">
	<cfargument name="username" type="string" required="true" default="#Request.dbusername#">
	<cfargument name="password" type="string" required="true" default="#Request.dbpassword#">
	<cfquery name="lighthouseQuery" datasource="#datasource#" username="#username#" password="#password#">
		#PreserveSingleQuotes(sql)#
	</cfquery>
	<cfreturn lighthouseQuery>
</cffunction>

<!---
 Determines if a particular Lighthouse module or feature is available

 @param moduleName
 @return Boolean
--->
<cffunction name="lh_isModuleInstalled" output="false" returnType="boolean">
	<cfargument name="moduleName" type="string" required="true">
	<cfswitch expression="#moduleName#">
		<cfcase value="clientUsers">
			<!--- Make sure that clients are installed --->
			<cfif Not StructKeyExists(Application,"module_installed_clientUsers")>
				<cflock scope="application" type="exclusive" timeout="20">
				<cftry>
					<cfquery name="checkClientUsers" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						SELECT top 1 userID FROM #lighthouse_getTableName("ClientUsers")#
					</cfquery>
					<cfset application.module_installed_clientUsers = true>
					<cfcatch type = "Database">
						<cfset application.module_installed_clientUsers = false>
					</cfcatch>
				</cftry>
				</cflock>
			</cfif>
			<cflock scope="application" type="readOnly" timeout="20">
				<cfreturn Application.module_installed_clientUsers>
			</cflock>
		</cfcase>
		<cfcase value="spellcheck">
			<!--- Make sure that spellcheck engine is installed --->
			<cfif Not StructKeyExists(Application,"module_installed_spellcheck")>
				<cflock scope="application" type="exclusive" timeout="20">
				<cftry>
					<CFX_JSpellCheck
						searchdepth="1"
						lexdir="#GetDirectoryFromPath(GetCurrentTemplatePath())#..\Resources\spellchecker\lex"
						action="check"
						words="">
					<cfset Application.module_installed_spellcheck = true>
					<cfcatch>
						<cfset Application.module_installed_spellcheck = false>
					</cfcatch>
				</cftry>
				</cflock>
			</cfif>
			<cflock scope="application" type="readOnly" timeout="20">
				<cfreturn Application.module_installed_spellcheck>
			</cflock>
		</cfcase>
		<cfcase value="siteEditor">
			<!--- Make sure that site editor is installed by checking for existence of the pages table. --->
			<cfif Not StructKeyExists(Application,"module_installed_siteEditor")>
				<cflock scope="application" type="exclusive" timeout="20">
				<cftry>
					<cfquery name="checksiteEditor" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
						SELECT top 1 pageID FROM #Request.dbprefix#_Pages
					</cfquery>
					<cfset application.module_installed_siteEditor = true>
					<cfcatch type = "Database">
						<cfset application.module_installed_siteEditor = false>
					</cfcatch>
				</cftry>
				</cflock>
			</cfif>
			<cflock scope="application" type="readOnly" timeout="20">
				<cfreturn Application.module_installed_siteEditor>
			</cflock>
		</cfcase>
	</cfswitch>
</cffunction>

<!---
 Get the page link, depending on whether in edit mode or using friendly urls

 @pageID string
 @name string
 @return string
--->
<cffunction name="lh_getPageLink" output="false" returnType="string">
	<cfargument name="pageID" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	<cfif edit>
		<cfreturn "javascript:top.editPage(#arguments.pageID#)">
	<cfelse>
		<cfif Request.lh_useFriendlyUrls>
			<cfreturn Request.AppVirtualPath & "/" & arguments.name>
		<cfelse>
			<cfreturn Request.AppVirtualPath & "/page.cfm?pageID=" & arguments.pageID>
		</cfif>
	</cfif>
</cffunction>

<!---
 Converts any CF boolean value to "true" or "false" string for use in javascript

 @boolValue boolean
--->
<cffunction name="jsBoolean" output="false" returnType="string">
	<cfargument name="boolValue" type="boolean" required="true">
	<cfif boolValue>
		<cfreturn "true">
	<cfelse>
		<cfreturn "false">
	</cfif>
</cffunction>

<!---
Used to convert munged email addresses (automatically munged by MS_HTMLEdit) back to standard email addresses.  The munged addresses do not function correctly in newsletters or other emailed fasion.

@input string
--->
<cffunction name="unmungeEmails" output="false" returntype="string">
	<cfargument name="input" type="string" required="true">
	
	<cfset re = "<script [^>]+>document.write\(String.fromCharCode\(([^\)]+)\)\)</script>">
	<cfloop condition="REFind(re,input) gt 0">
	    <cfset r = REFind(re,input,1,true)>
	    <cfset script = Mid(input,r.pos[1],r.len[1])>
	    <cfset chars = Mid(input,r.pos[2],r.len[2])>
	    <cfset s = "">
	    <cfloop index="char" list="#chars#">
	        <cfset s = s & Chr(char)>
	    </cfloop>
	    <cfset input = Replace(input,script,s)>
	</cfloop>
	<cfreturn input>
</cffunction>

<!---
Used to get a relative path back to directory of the calling template.
--->
<cffunction name="GetReversePath" output="false" returntype="string">
	<cfscript>
	basepath = Replace(GetBaseTemplatePath(),"\","/","ALL");
	currentpath = Replace(GetCurrentTemplatePath(),"\","/","ALL");
	sharedpath = "";
	for (i = 1; i lt ListLen(basepath,"/"); i = i + 1) {
		if (ListGetAt(currentpath,i,"/") is ListGetAt(basepath,i,"/")) {
			sharedpath = ListAppend(sharedPath,ListGetAt(currentpath,i,"/"),"/");
		} else {
			break;
		}
	}
	basevirtual = ReplaceNoCase(basepath,sharedpath & "/","");
	currentvirtual = ReplaceNoCase(currentpath,sharedpath,"");
	relativestart = repeatstring("../", listlen(currentvirtual, "/") - 1);
	relativepath = "#relativestart##REReplace(basevirtual,"[^/]+$","")#";
	</cfscript>
	<cfreturn relativePath>
</cffunction>

<!---
Takes comma separated list and removes all duplicates.
Note that the list is returned sorted.

There are other tags on the Allaire site which do the same thing and
are more flexible (which I noticed after I created this tag).
This one has its place, though, because the regular expression potentially takes
the place of a LOT of cold fusion looping and will therefore be much
more efficient processing very long lists.

@list (required) starting list
--->
<cffunction name="ListRemoveDuplicates" output="false" returntype="string">
	<cfargument name="list" required="true" type="string">
	<!---
	This RE eliminates duplicates, but only if they are next to each other, so sort first.
	Add commas to beginning and end of list to make RE simpler, then remove them.
	--->
	<cfset list = ListSort(list,"Textnocase")>
	<cfset list = "," & list & ",">
	<!--- <cfoutput>#list#</cfoutput><BR> --->
	<cfloop condition='list is not REReplaceNoCase(list,",([^,]+,)\1+",",\1")'>
		<cfset list = REReplaceNoCase(list,",([^,]+,)\1+",",\1","ALL")>
	</cfloop>
	<cfset list = Mid(list,2,Len(list)-2)>
	
	<cfreturn list>
</cffunction>

<!---
 Returns true if the string has zero length or is all white space
 
 @param s (required) String to check
 @return boolean
 --->
<cffunction name="IsEmpty" output="false" returntype="boolean">
	<cfargument name="s" required="true" type="string">
	<cfreturn Len(Trim(s)) is 0>
</cffunction>

<cffunction name="GetAllowedExtensions" returntype="string">
	<cfreturn "ai,asx,avi,bmp,csv,dat,doc,docx,fla,flv,gif,html,ico,jpeg,jpg,m4a,mov,mp3,mp4,mpa,mpg,mpp,pdf,png,pps,ppsx,ppt,pptx,ps,psd,qt,ra,ram,rar,rm,rtf,svg,swf,tif,txt,vcf,vsd,wav,wks,wma,wps,xls,xlsx,xml,zip">
</cffunction>

<cffunction name="UploadFile" hint="Replaces cffile upload, handling file extension checking and providing better error handling." output="false" returntype="struct">
	<cfargument name="FileField" required="true" type="string">
	<cfargument name="Destination" required="true" type="string">
	<cfargument name="AllowedExtensions" default="#GetAllowedExtensions()#" type="string">
	<cfargument name="NameConflict" default="MakeUnique" type="string">
	<cfargument name="InvalidExtensionMessage" default="The uploaded file has an invalid extension." type="string">
	<cfargument name="TempDirectory" default="#getTempDirectory()#">
	<cfset var tempPath = "">
	<cfset var serverPath = "">
	<cfset var file = "">
	<cfset var fileName = "">
	
	<!--- Make sure the destination directory exists. --->
	<cfif Not DirectoryExists(destination)>
		<cfthrow type="InvalidDestination" message="Destination directory ""#HtmlEditFormat(destination)#"" does not exist.">
	</cfif>

	<!--- Upload to temp directory. --->
	<cffile action="upload" filefield="#Arguments.FileField#" destination="#Arguments.TempDirectory#" nameconflict="#Arguments.NameConflict#">
	<cfset tempPath = ListAppend(cffile.ServerDirectory, cffile.ServerFile, "\/")>

	<!--- Check file extension --->
	<cfif Not ListFindNoCase(Arguments.AllowedExtensions,cffile.clientFileExt)>
		<!--- Bad file extension.  Delete file. --->
		<cfif FileExists(tempPath)>
			<cffile action="Delete" file="#tempPath#">
		</cfif>
		<!--- Throw error --->
		<cfthrow type="InvalidExtension" message="#Arguments.InvalidExtensionMessage#">
	</cfif>
	
	<!--- Replace bad characters in file name --->
	<cfset fileName = REReplaceNoCase(cffile.clientFileName,"[^\w_-]","","ALL")>
	<cfset file = fileName & "." & cffile.ClientFileExt>
	<cfset serverPath = ListAppend(destination, file, "\/")>
	
	<!--- Make the file name unique --->
	<cfif Arguments.NameConflict is "MakeUnique" and FileExists(serverPath)>
		<cfset fileName = fileName & getTickCount()>
		<cfset file = fileName & "." & cffile.ClientFileExt>
		<cfset serverPath = ListAppend(destination, file, "\/")>
	</cfif>
	
	<!--- Rename and move file to destination directory --->
	<cffile action="rename" source="#tempPath#" destination="#serverPath#">
	<cfset cffile.ServerDirectory = destination>
	<cfset cffile.serverFile = file>

	<cfreturn cffile>
</cffunction>