<!---
	CONFIGURATION PARAMS FOR CFX_JSpellCheck
	Company: CFDEV.COM
	Author: Pete Freitag
	Date: 01/01
 --->

<!--- SEE THE DOCS FOR DETAILS ABOUT THESE ATTRIBUTES --->

<!---
	Alternatly you can use the lexdir attribute, and it will append
	/american.clx, /american.tlx, and /userdic.tlx by default to the dir
<cfset Request.tlx = "#Request.lexdir#american.tlx">
<cfset Request.clx = "#Request.lexdir#american.clx">
<cfset Request.userdict = "#Request.lexdir#userdic.tlx">
 --->
<cfset Request.lexdir = GetDirectoryFromPath(GetCurrentTemplatePath()) & "lex">
<cfset Request.tlx = "#Request.lexdir#/american.tlx">
<cfset Request.clx = "#Request.lexdir#/american.clx">
<cfset Request.userdict = "#Request.lexdir#/userdic.tlx">


<cfset Request.searchdepth = 50>
<!---
	The English phonetic comparator uses english language rules to form
	suggestions, it is faster than the typographical comparator, but can
	only be used on English Dictionaries.
 --->
<cfset Request.englishphonetic = 1>
<cfset Request.striphtml = 1>
<!--- other option is wddx, only change this in your own apps --->
<cfset Request.format = "javascript">
<!---
	If the CF Server is only using one set of dictionary files, then it
	can cache the spell checking object in memory, this provides significant
	performance increases (upwards of 30%).  So if possible keep this
	attribute set to false
 --->
<cfset Request.multilingual = 0>
<cfset Request.Suggestions = 14>
