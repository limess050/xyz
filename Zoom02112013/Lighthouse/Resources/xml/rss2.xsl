<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 	<xsl:output method="html"/>
	<xsl:template match="/rss/channel">
		<html>
		<head>
		<title><xsl:value-of select="title"/></title>
		<link rel="stylesheet" href="/Lighthouse/Resources/css/MSStandard.css" type="text/css" />
		</head>
		<body class="NORMALTEXT">
			<h1>
				<xsl:value-of select="title"/>
			</h1>
			<p>
				This is an RSS feed.  You can copy and paste this url to subscribe to this feed:<br/>
				<a href="{link}"><xsl:value-of select="link"/></a>
			</p>
			<p>
				For information about what an RSS feed is and how you can use it go here:<br/>
				<a href="http://www.feedburner.com/fb/a/aboutrss">http://www.feedburner.com/fb/a/aboutrss</a>
			</p>
			<h2>Current Feed Content:</h2>
			<p>
				<xsl:value-of select="description"/>
			</p>
			<ul>
				<xsl:apply-templates select="item"/>
			</ul>
		</body>
		</html>
	</xsl:template>
	<xsl:template match="/rss/channel/item">
		<li>
			<a href="{link}" title="{description}"><b>
				<xsl:value-of select="title"/>
			</b></a>
			<div>
				<xsl:value-of select="description" disable-output-escaping="yes"/>
				<br/><br/>
			</div>
		</li>
	</xsl:template>
</xsl:stylesheet>