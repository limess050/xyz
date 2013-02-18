<!---
Creator: Ed Tabara
Email: 1smartsolution@gmail.com
Date: 27 Nov 2008
Site: http://www.1smartsolution.com

2009/05/22 Modified by David Hammond.  Added ownerUrl to Init.

Description: Defensio is a web service designed to help manage spam on publicly-accessible social web applications such as blogs

NOTE: Before using this component you will have to get an API Key from http://defensio.com
--->
<cfcomponent>
	<cffunction name="init" output="No" returntype="any" hint="initialize the component">
		<cfargument name="key" required="Yes" type="any">
		<cfargument name="ownerURL" required="Yes" type="any"> <!--- the URL of the site owner using the service --->
		<cfset this.key = key>
		<cfset this.ownerUrl = ownerUrl>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="validateKey" output="No" returntype="any" hint="This action verifies that the key is valid for the owner calling the service. A user must have a valid API key in order to use the Defensio web service.">
		<cfset var cfhttp = "">
		<cfset var theXML = "">
		<cfset var rez = StructNew()>
		
		<cfhttp url="http://api.defensio.com/blog/1.2/validate-key/#this.key#.xml" method="POST" useragent="Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US; rv:1.8.1.14) Gecko/20080404 Firefox/2.0.0.14">
			<cfhttpparam name="owner-url" type="FORMFIELD" value="#This.ownerURL#">
		</cfhttp>
		
		<cfif IsXML(cfhttp.FileContent)>
			<cfset theXML = XMLParse(cfhttp.FileContent)>
			<cfset rez.isError = 0>
			<cfif StructKeyExists(theXML, "defensio-result")>
				<cfset rez.status = theXML["defensio-result"].status.XmlText> <!-- possible values: success, fail --->
				<cfset rez.message = theXML["defensio-result"].message.XmlText>
				<cfset rez.version = theXML["defensio-result"]["api-version"].XmlText>
				<cfif rez.status eq "fail">
					<cfset rez.isError = 1>
				</cfif>
			<cfelse>
				<cfset rez.isError = 1>
				<cfset rez.message = cfhttp.FileContent>
			</cfif>
		<cfelse>
			<cfset rez.isError = 1>
			<cfset rez.message = cfhttp.FileContent>
		</cfif>
		<cfreturn rez>
	</cffunction>

	<cffunction name="announceArticle" output="No" returntype="any" hint="This action should be invoked upon the publication of an article to announce its existence. The actual content of the article is sent to Defensio for analysis.">
		<cfargument name="articleAuthor" required="Yes" type="any"> <!--- the name of the author of the article --->
		<cfargument name="articleAuthorEmail" required="Yes" type="any"> <!--- the email address of the person posting the article --->
		<cfargument name="articleTitle" required="Yes" type="any"> <!--- the title of the article --->
		<cfargument name="articleContent" required="Yes" type="any"> <!--- the content of the blog posting itself --->
		<cfargument name="permalink" required="Yes" type="any"> <!--- the permalink of the article just posted --->
		
		<cfset var cfhttp = "">
		<cfset var theXML = "">
		<cfset var rez = StructNew()>
		
		<cfhttp url="http://api.defensio.com/blog/1.2/announce-article/#this.key#.xml" method="POST" useragent="Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US; rv:1.8.1.14) Gecko/20080404 Firefox/2.0.0.14">
			<cfhttpparam name="owner-url" type="FORMFIELD" value="#This.ownerURL#">
			<cfhttpparam name="article-author" type="FORMFIELD" value="#articleAuthor#">
			<cfhttpparam name="article-author-email" type="FORMFIELD" value="#articleAuthorEmail#">
			<cfhttpparam name="article-title" type="FORMFIELD" value="#articleTitle#">
			<cfhttpparam name="article-content" type="FORMFIELD" value="#articleContent#">
			<cfhttpparam name="permalink" type="FORMFIELD" value="#permalink#">
		</cfhttp>
		
		<cfif IsXML(cfhttp.FileContent)>
			<cfset theXML = XMLParse(cfhttp.FileContent)>
			<cfset rez.isError = 0>
			<cfif StructKeyExists(theXML, "defensio-result")>
				<cfset rez.status = theXML["defensio-result"].status.XmlText> <!-- possible values: success, fail --->
				<cfset rez.message = theXML["defensio-result"].message.XmlText>
				<cfset rez.version = theXML["defensio-result"]["api-version"].XmlText>
				<cfif rez.status eq "fail">
					<cfset rez.isError = 1>
				</cfif>
			<cfelse>
				<cfset rez.isError = 1>
				<cfset rez.message = cfhttp.FileContent>
			</cfif>
		<cfelse>
			<cfset rez.isError = 1>
			<cfset rez.message = cfhttp.FileContent>
		</cfif>
		<cfreturn rez>
	</cffunction>

	<cffunction name="auditComment" output="No" returntype="any" hint="This central action determines not only whether Defensio thinks a comment is spam or not, but also a measure of its 'spaminess', i.e. its relative likelihood of being spam.">
		<cfargument name="userIP" required="Yes" type="any"> <!--- the IP address of whomever is posting the comment --->
		<cfargument name="articleDate" required="Yes" type="any"> <!--- the date the original blog article was posted (yyyy/mm/dd) --->
		<cfargument name="commentAuthor" required="Yes" type="any"> <!--- the name of the author of the comment --->
		<cfargument name="commentType" required="Yes" type="any"> <!--- the type of the comment being posted to the blog. possible values: comment, trackback, pingback, other --->
		<cfargument name="commentContent" default="" type="any"> <!--- the actual content of the comment (strongly recommended to be included where ever possible) --->
		<cfargument name="commentAuthorEmail" default="" type="any"> <!--- the email address of the person posting the comment  --->
		<cfargument name="commentAuthorURL" default="" type="any"> <!--- the URL of the person posting the comment --->
		<cfargument name="permalink" default="" type="any"> <!--- the permalink of the blog post to which the comment is being posted  --->
		<cfargument name="referrer" default="" type="any"> <!--- the URL of the site that brought commenter to this page  --->
		<cfargument name="userLoggedIn" default="false" type="any"> <!--- whether or not the user posting the comment is logged-into the blogging platform.possible values: true, false  --->
		<cfargument name="trustedUser" default="false" type="any"> <!--- whether or not the user is an administrator, moderator or editor of this blog; the client should pass true only if blogging platform can guarantee that the user has been authenticated and has a role of responsibility on this blog. possible values: tru, false --->
		<cfargument name="openid" default="" type="any"> <!--- the OpenID URL of the currently logged in user. Must be used in conjunction with user-logged-in=true. OpenID authentication must be taken care of by your application.  --->
		<cfargument name="testForce" default="" type="any"> <!--- FOR TESTING PURPOSES ONLY: use this parameter to force the outcome of audit-comment . optionally affix (with a comma) a desired spaminess return value (in the range 0 to 1). possible values: "spam,x.xxxx", "ham,x.xxxx"  --->
		
		<cfset var cfhttp = "">
		<cfset var theXML = "">
		<cfset var rez = StructNew()>
		
		<cfhttp url="http://api.defensio.com/blog/1.2/audit-comment/#this.key#.xml" method="POST" useragent="Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US; rv:1.8.1.14) Gecko/20080404 Firefox/2.0.0.14">
			<cfhttpparam name="owner-url" type="FORMFIELD" value="#This.ownerURL#">
			<cfhttpparam name="user-ip" type="FORMFIELD" value="#userIP#">
			<cfhttpparam name="article-date" type="FORMFIELD" value="#articleDate#">
			<cfhttpparam name="comment-author" type="FORMFIELD" value="#commentAuthor#">
			<cfhttpparam name="comment-type" type="FORMFIELD" value="#commentType#">
			<cfif Len(commentContent)><cfhttpparam name="comment-content" type="FORMFIELD" value="#commentContent#"></cfif>
			<cfif Len(commentAuthorEmail)><cfhttpparam name="comment-author-email" type="FORMFIELD" value="#commentAuthorEmail#"></cfif>
			<cfif Len(commentAuthorURL)><cfhttpparam name="comment-author-url" type="FORMFIELD" value="#commentAuthorURL#"></cfif>
			<cfif Len(permalink)><cfhttpparam name="permalink" type="FORMFIELD" value="#permalink#"></cfif>
			<cfif Len(referrer)><cfhttpparam name="referrer" type="FORMFIELD" value="#referrer#"></cfif>
			<cfif Len(userLoggedIn)><cfhttpparam name="user-logged-in" type="FORMFIELD" value="#userLoggedIn#"></cfif>
			<cfif Len(trustedUser)><cfhttpparam name="trusted-user" type="FORMFIELD" value="#trustedUser#"></cfif>
			<cfif Len(openid)><cfhttpparam name="openid" type="FORMFIELD" value="#openid#"></cfif>
			<cfif Len(testForce)><cfhttpparam name="test-force" type="FORMFIELD" value="#testForce#"></cfif>
		</cfhttp>
		
		<cfif IsXML(cfhttp.FileContent)>
			<cfset theXML = XMLParse(cfhttp.FileContent)>
			<cfset rez.isError = 0>
			<cfif StructKeyExists(theXML, "defensio-result")>
				<cfset rez.status = theXML["defensio-result"].status.XmlText> <!-- possible values: success, fail --->
				<cfset rez.message = theXML["defensio-result"].message.XmlText>
				<cfset rez.version = theXML["defensio-result"]["api-version"].XmlText>
				<cfif rez.status eq "fail">
					<cfset rez.isError = 1>
				<cfelse>
					<cfset rez.signature = theXML["defensio-result"].signature.XmlText> <!--- a message signature that uniquely identifies the comment in the Defensio system. this signature should be stored by the client for retraining purposes --->
					<cfset rez.spam = theXML["defensio-result"].spam.XmlText> <!--- a boolean value indicating whether Defensio believe the comment to be spam --->
					<cfset rez.spaminess = theXML["defensio-result"].spaminess.XmlText> <!--- a value indicating the relative likelihood of the comment being spam. this value should be stored by the client for use in building convenient spam sorting user-interfaces --->
				</cfif>
			<cfelse>
				<cfset rez.isError = 1>
				<cfset rez.message = cfhttp.FileContent>
			</cfif>
		<cfelse>
			<cfset rez.isError = 1>
			<cfset rez.message = cfhttp.FileContent>
		</cfif>
		<cfreturn rez>
	</cffunction>

	<cffunction name="reportFalseNegatives" output="No" returntype="any" hint="This action is used to retrain false negatives. That is to say, to indicate to the filter that comments originally tagged as 'ham' (i.e. legitimate) were in fact spam.">
		<cfargument name="signatures" required="Yes" type="any"> <!--- list of signatures (may contain a single entry) of the comments to be submitted for retraining. note that a signature for each comment was originally provided by Defensio's audit-comment action. possible values: comma-separated list of alphanumeric strings --->
		
		<cfset var cfhttp = "">
		<cfset var theXML = "">
		<cfset var rez = StructNew()>
		
		<cfhttp url="http://api.defensio.com/blog/1.2/report-false-negatives/#this.key#.xml" method="POST" useragent="Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US; rv:1.8.1.14) Gecko/20080404 Firefox/2.0.0.14">
			<cfhttpparam name="owner-url" type="FORMFIELD" value="#This.ownerURL#">
			<cfhttpparam name="signatures" type="FORMFIELD" value="#signatures#">
		</cfhttp>
		
		<cfif IsXML(cfhttp.FileContent)>
			<cfset theXML = XMLParse(cfhttp.FileContent)>
			<cfset rez.isError = 0>
			<cfif StructKeyExists(theXML, "defensio-result")>
				<cfset rez.status = theXML["defensio-result"].status.XmlText> <!-- possible values: success, fail --->
				<cfset rez.message = theXML["defensio-result"].message.XmlText>
				<cfset rez.version = theXML["defensio-result"]["api-version"].XmlText>
				<cfif rez.status eq "fail">
					<cfset rez.isError = 1>
				</cfif>
			<cfelse>
				<cfset rez.isError = 1>
				<cfset rez.message = cfhttp.FileContent>
			</cfif>
		<cfelse>
			<cfset rez.isError = 1>
			<cfset rez.message = cfhttp.FileContent>
		</cfif>
		<cfreturn rez>
	</cffunction>

	<cffunction name="reportFalsePositives" output="No" returntype="any" hint="This action is used to retrain false positives. That is to say, to indicate to the filter that comments originally tagged as spam were in fact 'ham' (i.e. legitimate comments).">
		<cfargument name="signatures" required="Yes" type="any"> <!--- list of signatures (may contain a single entry) of the comments to be submitted for retraining. note that a signature for each comment was originally provided by Defensio's audit-comment action. possible values: comma-separated list of alphanumeric strings --->
		
		<cfset var cfhttp = "">
		<cfset var theXML = "">
		<cfset var rez = StructNew()>
		
		<cfhttp url="http://api.defensio.com/blog/1.2/report-false-positives/#this.key#.xml" method="POST" useragent="Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US; rv:1.8.1.14) Gecko/20080404 Firefox/2.0.0.14">
			<cfhttpparam name="owner-url" type="FORMFIELD" value="#This.ownerURL#">
			<cfhttpparam name="signatures" type="FORMFIELD" value="#signatures#">
		</cfhttp>
		
		<cfif IsXML(cfhttp.FileContent)>
			<cfset theXML = XMLParse(cfhttp.FileContent)>
			<cfset rez.isError = 0>
			<cfif StructKeyExists(theXML, "defensio-result")>
				<cfset rez.status = theXML["defensio-result"].status.XmlText> <!-- possible values: success, fail --->
				<cfset rez.message = theXML["defensio-result"].message.XmlText>
				<cfset rez.version = theXML["defensio-result"]["api-version"].XmlText>
				<cfif rez.status eq "fail">
					<cfset rez.isError = 1>
				</cfif>
			<cfelse>
				<cfset rez.isError = 1>
				<cfset rez.message = cfhttp.FileContent>
			</cfif>
		<cfelse>
			<cfset rez.isError = 1>
			<cfset rez.message = cfhttp.FileContent>
		</cfif>
		<cfreturn rez>
	</cffunction>
	
	<cffunction name="getStats" output="No" returntype="any" hint="This action returns basic statistics regarding the performance of Defensio since activation.">
		<cfset var cfhttp = "">
		<cfset var theXML = "">
		<cfset var rez = StructNew()>
		
		<cfhttp url="http://api.defensio.com/blog/1.2/get-stats/#this.key#.xml" method="POST" useragent="Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US; rv:1.8.1.14) Gecko/20080404 Firefox/2.0.0.14">
			<cfhttpparam name="owner-url" type="FORMFIELD" value="#This.ownerURL#">
		</cfhttp>
		
		<cfif IsXML(cfhttp.FileContent)>
			<cfset theXML = XMLParse(cfhttp.FileContent)>
			<cfset rez.isError = 0>
			<cfif StructKeyExists(theXML, "defensio-result")>
				<cfset rez.status = theXML["defensio-result"].status.XmlText> <!-- possible values: success, fail --->
				<cfset rez.message = theXML["defensio-result"].message.XmlText>
				<cfset rez.version = theXML["defensio-result"]["api-version"].XmlText>
				<cfset rez.accuracy = theXML["defensio-result"].accuracy.XmlText> <!--- describes the percentage of comments correctly identified as spam/ham by Defensio on this blog. possible values: a float between 0 and 1, e.g. 0.9983 --->
				<cfset rez.spam = theXML["defensio-result"].spam.XmlText> <!--- the number of spam comments caught by the filter --->
				<cfset rez.ham = theXML["defensio-result"].ham.XmlText> <!--- the number of ham (legitimate) comments accepted by the filter --->
				<cfset rez.falsePositives = theXML["defensio-result"]["false-positives"].XmlText> <!--- the number of times a legitimate message was retrained from the spambox (i.e. "de-spammed" by the user) --->
				<cfset rez.falseNegatives = theXML["defensio-result"]["false-negatives"].XmlText> <!--- the number of times a spam message was retrained from comments box (i.e. "de-legitimized" by the user)  --->
				<cfset rez.learning = theXML["defensio-result"].learning.XmlText> <!--- a boolean value indicating whether Defensio is still in its initial learning phase . possible values: true, false --->
				<cfset rez.learningStatus = theXML["defensio-result"]["learning-status"].XmlText> <!--- more details on the reason(s) why Defensio is still in its initial learning phase --->
				<cfif rez.status eq "fail">
					<cfset rez.isError = 1>
				</cfif>
			<cfelse>
				<cfset rez.isError = 1>
				<cfset rez.message = cfhttp.FileContent>
			</cfif>
		<cfelse>
			<cfset rez.isError = 1>
			<cfset rez.message = cfhttp.FileContent>
		</cfif>
		<cfreturn rez>
	</cffunction>
</cfcomponent>