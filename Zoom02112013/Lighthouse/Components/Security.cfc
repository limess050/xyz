<cfcomponent hint="Handles security functions for the application" output="false">
	
	<cfset This.LockoutThreshold = 3>
	<cfset This.LockoutDuration = 30>
	
	<cffunction name="GetLoginSecurity" output="false" access="private" returntype="struct">
		<cfargument name="username" required="true" type="string">
		<cfset var s = StructNew()>
		<cfif Not StructKeyExists(Application.SecurityInfo,username)>
			<cfset Application.SecurityInfo[username] = s>
		<cfelse>
			<cfset s = Application.SecurityInfo[username]>
		</cfif>
		<cfreturn s>
	</cffunction>
	
	<cffunction name="HandleInvalidLogin" returntype="struct">
		<cfargument name="username" required="true" type="string">
		<cfset var s = GetLoginSecurity(username)>
		
		<cfif StructKeyExists(s,"NumberInvalidLogins")>
			<cfset s.NumberInvalidLogins = s.NumberInvalidLogins + 1>
		<cfelse>
			<cfset s.NumberInvalidLogins = 1>
		</cfif>
		<cfset s.LastInvalidLogin = Now()>
		
		<cfreturn s>
	</cffunction>

	<cffunction name="HandleSuccessfulLogin" returntype="struct">
		<cfargument name="username" required="true" type="string">
		<cfset var s = GetLoginSecurity(username)>
		
		<cfset s.NumberInvalidLogins = 0>
		<cfset s.LastSuccessfulLogin = Now()>
		
		<cfreturn s>
	</cffunction>

	<cffunction name="CheckLoginStatus" returntype="struct" output="true">
		<cfargument name="username" required="true" type="string">
		<cfset var s = GetLoginSecurity(username)>

		<cfset s.AllowLogin = true>

		<cfif StructKeyExists(s,"LastInvalidLogin")>
			<cfif DateDiff("n",s.LastInvalidLogin,Now()) gt This.LockoutDuration>
				<cfset s.NumberInvalidLogins = 0>
			</cfif>
		<cfelse>
			<cfset s.NumberInvalidLogins = 0>
		</cfif>
		
		<cfif StructKeyExists(s,"NumberInvalidLogins")>
			<cfif s.NumberInvalidLogins gte This.LockoutThreshold>
				<cfset s.AllowLogin = false>
			</cfif>
		</cfif>
		
		<cfreturn s>
	</cffunction>

	<cffunction name="UnlockAccount" returntype="struct" output="true">
		<cfargument name="username" required="true" type="string">
		<cfset var s = GetLoginSecurity(username)>
		<cfset s.NumberInvalidLogins = 0>
		<cfreturn s>
	</cffunction>
	
	<cffunction name="GetEncryptionKey" hint="Get the secret key to use in encrypt and decrypt" returntype="string">
		<cfargument name="algorithm" type="string" default="AES">
		<cfset var key = "">
		<cfset var keyName = "EncryptionKey_" & arguments.algorithm>
		<cfset var keyDirectory = "">
		<cfset var keyFile = "">
		
		<!--- Get key --->
		<cfif StructKeyExists(This,keyName)>
			<cfset key = This[keyName]>
		<cfelse>
			<cfset keyDirectory = "#Application.SecureDirectory#keys">
			<cfset keyFile = "#keyDirectory#\#cgi.SERVER_NAME#_#Arguments.algorithm#.key">
			<!--- look for key file --->
			<cfif FileExists(keyFile)>
				<cffile action="read" file="#keyFile#" variable="key">
			<cfelse>
				<cfif Not DirectoryExists(keyDirectory)>
					<cfdirectory action="create" directory="#keyDirectory#">
				</cfif>
				<cfset key = GenerateSecretKey(Arguments.algorithm)>
				<cffile action="write" file="#keyFile#" output="#key#">
			</cfif>
			<cfset this[keyName] = key>
		</cfif>
		<cfreturn key>	
	</cffunction>
	
	<cffunction name="EncryptString" hint="Encrypts the string using the given algorithm." returntype="string">
		<cfargument name="string" type="string" required="true">
		<cfargument name="algorithm" type="string" default="AES">
		<cfreturn Encrypt(string,This.GetEncryptionKey(Arguments.algorithm),Arguments.algorithm)>
	</cffunction>
	
	<cffunction name="DecryptString" hint="Decrypts the string using the given algorithm." returntype="string">
		<cfargument name="string" type="string" required="true">
		<cfargument name="algorithm" type="string" default="AES">
		<cftry>
			<cfreturn Decrypt(string,This.GetEncryptionKey(Arguments.algorithm),Arguments.algorithm)>
			<cfcatch>
				<!--- If there is an error decrypting, we'll assume the value has not been encrypted yet. --->
				<cfreturn string>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="HashString" hint="Hashes a string." returntype="string">
		<cfargument name="string" type="string" required="true">
		<cfargument name="algorithm" type="string" default="SHA-256">
		<cfreturn Hash(string,Arguments.algorithm)>
	</cffunction>

	<cffunction name="HashAllPasswords" hint="Hashes passwords in the users table." returntype="void">
		<cfif Application.HashUserPasswords>
			<cfquery name="getUsers" datasource="#Application.dsn#" username="#Application.dbusername#" password="#Application.dbpassword#">
				SELECT userID,password 
				FROM #Application.Lighthouse.lighthouse_getTableName("Users")#
				WHERE Len(password) <= 20
			</cfquery>
			<cfloop query="getUsers">
				<cfquery name="updateUser" datasource="#Application.dsn#" username="#Application.dbusername#" password="#Application.dbpassword#">
					UPDATE #Application.Lighthouse.lighthouse_getTableName("Users")#
					SET password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Application.Security.HashString(password)#">
					WHERE userID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userID#">
				</cfquery>
			</cfloop>
		</cfif>
	</cffunction>
	
	<cffunction name="GetAuthToken" hint="Get a unique token to validate an action." output="false">
		<cfargument name="key" default="#cgi.SCRIPT_NAME#" type="string">
		<cfreturn This.HashString("#cftoken##Session.UserID##key#")>
	</cffunction>

</cfcomponent>