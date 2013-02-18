<cffunction name="textMessage" access="public" returntype="string" hint="Converts an html email message into a nicely formatted with line breaks plain text message">
    <cfargument name="string" required="true" type="string">
    <cfscript>
        var pattern = "<br>";
        var CRLF = chr(13) & chr(10);
        var message = ReplaceNoCase(arguments.string, pattern, CRLF , "ALL");
        pattern = "<[^>]*>";
    </cfscript>
    <cfreturn REReplaceNoCase(message, pattern, "" , "ALL")>
</cffunction>