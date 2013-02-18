
<cfsetting showdebugoutput="no">

<cffunction name="CreateCAPTCHA" access="remote" returntype="string" displayname="Creates an image and a hashed form field">	

	<cfset rString = "">       
	
	<cfset CAPchars = "23456789ABCDEFGHJKMNPQRS">
	<cfset CAPlength = 7>
	<cfset CAPresult = "">
	<cfset CAPi = "">
	<cfset CAPchar = "">
	
	<cfscript>
		for(CAPi=1; CAPi <= CAPlength; CAPi++) {
			CAPchar = mid(CAPchars, randRange(1, len(CAPchars)),1);
			CAPresult&=CAPchar;
		}
	</cfscript>	
	
	<cfsavecontent variable="newImage">
		<cfimage action="captcha" width="280" height="45" difficulty="medium" fonts="verdana,arial,times new roman,courier" fontsize="30" text="#CAPresult#">
	</cfsavecontent>
	
	<cfset newHash=Hash(CAPresult)>
	<cfset Session.CaptchaHash = hash(ucase(CAPresult))>
	
	<cfset ResponseVars["NewImage"]= newImage />
	<cfset ResponseVars["NewHash"]= newHash />
	
	<cfset rString=serializeJSON(ResponseVars)>
	
 	<cfreturn rString>
</cffunction>

<cffunction name="ValidateCAPTCHA" access="remote" returntype="string" displayname="Takes entered text and hashed value and comparess them">	
	<cfargument name="CaptchaEntry" required="yes">
	<cfargument name="CaptchaHash" required="yes">
	<cfset ResponseVars = "0">   
	<cfif hash(ucase(arguments.CaptchaEntry)) is arguments.CaptchaHash>
		<cfset ResponseVars="1">
	</cfif>    
	
	<cfset rString=serializeJSON(ResponseVars)>
	
 	<cfreturn rString>
</cffunction>

