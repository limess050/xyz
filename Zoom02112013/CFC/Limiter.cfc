<cfcomponent>
	<cffunction name="limiter">
		<!---
		   Adapted from code by Charlie Arehart, charlie@carehart.org
		   http://www.carehart.org/blog/client/index.cfm/2010/5/21/throttling_by_ip_address
		   - Throttles requests made more than "count" times within "duration" seconds.
		   - sends 429 status code for bots to consider as well as text for humans to read
		   - also logs to a new "limiter.log" that is created automatically in cf logs directory, tracking
			 when limits are hit, to help fine tune
		--->
		<cfargument name="duration" type="numeric" default=3>
		<cfargument name="count" type="numeric" default=6>
		<cfset var cacheId = "rate_limiter_" & CGI.REMOTE_ADDR>
		<cfset var rate = cacheGet(cacheId)>
	
		<cfif isNull(rate)>
			<!--- Create cached object --->
			<cfset cachePut(cacheID, {attempts = 1, start = Now()}, createTimeSpan(0,0,1,0))>
		<cfelseif DateDiff("s", rate.start, Now()) LT arguments.duration>
			<cfif rate.attempts gte arguments.count>
				<cfoutput>
					<p>&nbsp;</p><p>&nbsp;</p>
					<p>You are making too many requests too fast, please slow down and wait #arguments.duration# seconds</p>
				</cfoutput>
				<cfheader statuscode="429" statustext="Too Many Requests">
				<cfheader name="Retry-After" value="#arguments.duration#">
				<cflog file="limiter" text="#cgi.remote_addr# #cgi.request_method# #cgi.SCRIPT_NAME# #cgi.QUERY_STRING# #cgi.http_user_agent#">
				<cfif rate.attempts is arguments.count>
					<!--- Lock out for duration --->
					<cfset cachePut(cacheID, {attempts = rate.attempts + 1, start = Now()}, createTimeSpan(0,0,1,0))>
				</cfif>
				<cfabort>
			<cfelse>
				<!--- Increment attempts --->
				<cfset cachePut(cacheID, {attempts = rate.attempts + 1, start = rate.start}, createTimeSpan(0,0,1,0))>
			</cfif>
		<cfelse>
			<!--- Reset attempts --->
			<cfset cachePut(cacheID, {attempts = 1, start = Now()}, createTimeSpan(0,0,1,0))>
		</cfif>
	</cffunction>
	
	<cffunction name="Stats" output="true" access="remote">
		<cfdump var="#cacheGetAllIds()#">
	</cffunction>

	<cffunction name="Test" output="true" access="remote">
		<cfset limiter()>
		<cfdump var="#cacheGet("rate_limiter_" & CGI.REMOTE_ADDR)#">
		<cfdump var="#cacheGetMetaData("rate_limiter_" & CGI.REMOTE_ADDR)#">
	</cffunction>
</cfcomponent>