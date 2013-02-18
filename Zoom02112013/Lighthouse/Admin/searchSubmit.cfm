<cfinclude template="checkPermission.cfm">
<cfset pg_title = "Search Engine Awareness">
<cfinclude template="header.cfm">

<cfset sitemapUrl = Request.httpUrl & "/Lighthouse/rss.cfm">

<!--- Get current robots.txt file --->
<cffile action="read" file="#ExpandPath("#Request.AppVirtualPath#/robots.txt")#" variable="robotstxt">

<!--- resubmit sitemap to google --->
<cfif IsDefined("resubmitGoogle")>
	<cfhttp url="www.google.com/webmasters/sitemaps/ping?sitemap=#UrlEncodedFormat(sitemapUrl)#" throwOnError="Yes">
	<cfoutput><p class="STATUSMESSAGE">Resubmit to google status message: #cfhttp.statusCode#</p></cfoutput>
<!--- save changes to robots.txt --->
<cfelseif IsDefined("form.robotstxt")>
	<cfif variables.robotstxt is not form.robotstxt>
		<cftry>
			<cffile action="write" file="#ExpandPath("../robots.txt")#" output="#form.robotstxt#" charset="utf-8">
			<cfset variables.robotstxt = form.robotstxt>
			<p class="STATUSMESSAGE">robots.txt has been saved</p>
			<cfcatch>
				<p class="STATUSMESSAGE">Error saving robots.txt: <cfoutput>#cfcatch.message#</cfoutput></p>
			</cfcatch>
		</cftry>
	<cfelse>
		<p class="STATUSMESSAGE">robots.txt is unchanged</p>
	</cfif>
</cfif>

<h1>Submitting your site map to search engines</h1>
<p>
Submitting your site to search engines is a way of letting the search engines know about pages on your site, as well as when those pages have been updated.  It's important to realize that submitting your site to the search engines does not affect the ranking of your pages, but can help to ensure that the information available through the search engines about your site is as up-to-date as possible.
</p>
<p>The url for this site's sitemap is <b><cfoutput>#variables.sitemapUrl#</cfoutput></b>.  It is an RSS 2.0 compliant file, so it is also called a site feed.  Use this url to submit to any of the following search engines:</p>

<h2>Google</h2>
<p>You must create an account with Google to submit your sitemap for the first time.  Go here: <a href="http://www.google.com/webmasters/sitemaps/" target="_blank">http://www.google.com/webmasters/sitemaps/</a>.  Be sure to check out the sitemap FAQ's: <a href="http://www.google.com/webmasters/sitemaps/docs/en/faq.html" target="_blank">http://www.google.com/webmasters/sitemaps/docs/en/faq.html</a></p>
<p>After you have created an account and submitted your sitemap, you can click the following link to re-submit your sitemap:</p>
<p><a href="index.cfm?adminFunction=searchSubmit&resubmitGoogle=true">Re-submit your sitemap now</a>.
<p>It is recommended that you re-submit your sitemap whenever new content is published on the site, but not more than once an hour.</p>

<h2>Yahoo!</h2>
<p>Submit <cfoutput>#variables.sitemapUrl#</cfoutput> as a feed here: <a href="http://submit.search.yahoo.com/free/request" target="_blank">http://submit.search.yahoo.com/free/request</a>.</p>

<hr>
<h1>Search Engine Restrictions -- the robots.txt file</h1>
<p>In conjunction with a site map, every site should use a robots.txt file to tell search engines what pages <em>shouldn't</em> be indexed.  All responsible search bots should check for the existence of the robots.txt file before indexing your site.  For more information about the robots.txt file, see one of the following links:</p>

<p><a href="http://www.robotstxt.org/" target="_blank">http://www.robotstxt.org/</a><br>
<a href="http://www.google.com/webmasters/remove.html" target="_blank">http://www.google.com/webmasters/remove.html</a><br>
<a href="http://help.yahoo.com/help/us/ysearch/slurp/slurp-02.html" target="_blank">http://help.yahoo.com/help/us/ysearch/slurp/slurp-02.html</a></p>

<p>Advanced users can edit this site's robots.txt file here:</p>

<form action="index.cfm?adminFunction=searchSubmit" method="post">
<cfoutput><textarea cols="64" rows="#Min(25,Max(5,ListLen(variables.robotstxt,Chr(10))))#" name="robotstxt">#variables.robotstxt#</textarea></cfoutput><br>
<input type="submit" value="Save File">
</form>

<cfinclude template="footer.cfm">