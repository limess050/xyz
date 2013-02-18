
<cfparam name="Prelaunch" default="0">

<!--- Prior to launch date, calculate all expiration dates from April 1, 2010 and make all listing pacakges expire on April 1, 2010 --->
<cfif DateDiff("d","4/1/2010",Now()) lt "0">
	<cfset Prelaunch="1">
</cfif>
