<cfparam name="fieldName" default="">
<title>Spell Checker</title>
<!-- frames -->
<frameset  rows="212,*" frameborder="0">
    <frame name="topframe" src="top.cfm" marginwidth="5" marginheight="5" scrolling="no" frameborder="0">
    <cfoutput><frame name="bottom" src="bottom.cfm?jsvar=#jsvar#&fieldName=#fieldName#" marginwidth="2" marginheight="2" scrolling="no" frameborder="0"></cfoutput>
</frameset>