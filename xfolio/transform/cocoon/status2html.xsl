<?xml version="1.0"?>
<!--+
    | Converts output of the StatusGenerator into HTML page
    | 
    | CVS $Id: status2html.xsl,v 1.1 2004/06/18 23:31:57 frederic Exp $
    +-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:status="http://apache.org/cocoon/status/2.0" xmlns:i18n="http://apache.org/cocoon/i18n/2.1">
	<xsl:param name="contextPath"/>
	<xsl:template match="status:statusinfo">
		<html>
			<head>
				<title>Xfolio, Status [<xsl:value-of select="@status:host"/>]</title>
			</head>
			<body>
				<h1>
					<xsl:value-of select="@status:host"/> - <xsl:value-of select="@status:date"/>
					<i18n:date-time />
				</h1>
				<i18n:text key="a_key">article_text1</i18n:text>
				<xsl:apply-templates/>
			</body>
		</html>
	</xsl:template>
	<!-- default, keep all -->
	<xsl:template match="status:group"/>
	<xsl:template match="status:group">
		<h2>
			<xsl:value-of select="@status:name"/>
		</h2>
		<ul>
			<xsl:apply-templates select="status:value"/>
		</ul>
		<xsl:apply-templates select="status:group"/>
	</xsl:template>
	<xsl:template match="status:value">
		<li>
			<span class="description">
				<xsl:value-of select="@status:name"/>
				<xsl:text>: </xsl:text>
			</span>
			<xsl:choose>
				<xsl:when test="contains(@status:name,'free') or contains(@status:name,'total')">
					<xsl:call-template name="suffix">
						<xsl:with-param name="bytes" select="number(.)"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="count(status:line) &lt;= 1">
					<xsl:value-of select="status:line"/>
				</xsl:when>
				<xsl:otherwise>
					<span class="switch" id="{generate-id(.)}-switch" onclick="toggle('{generate-id(.)}')">[show]</span>
					<ul id="{generate-id(.)}" style="display: none">
						<xsl:apply-templates/>
					</ul>
				</xsl:otherwise>
			</xsl:choose>
		</li>
	</xsl:template>
	<xsl:template match="status:line">
		<li>
			<xsl:value-of select="."/>
		</li>
	</xsl:template>
	<xsl:template name="suffix">
		<xsl:param name="bytes"/>
		<xsl:choose>
			<!-- More than 4 MB (=4194304) -->
			<xsl:when test="$bytes &gt;= 4194304">
				<xsl:value-of select="round($bytes div 10485.76) div 100"/> MB
      </xsl:when>
			<!-- More than 4 KB (=4096) -->
			<xsl:when test="$bytes &gt; 4096">
				<xsl:value-of select="round($bytes div 10.24) div 100"/> KB
      </xsl:when>
			<!-- Less -->
			<xsl:otherwise>
				<xsl:value-of select="$bytes"/> B
      </xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>