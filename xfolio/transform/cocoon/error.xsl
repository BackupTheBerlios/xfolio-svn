<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:error="http://apache.org/cocoon/error/2.1">
	<xsl:param name="css"/>
	<xsl:template match="error:notify">
		<html>
			<head>
				<title>
					<xsl:value-of select="@error:type"/>:<xsl:value-of select="error:title"/>
				</title>
				<link rel="stylesheet" type="text/css" href="{$css}"/>
				<style type="text/css">
 th {text-align:right}
 textarea {height:15em;}
 body {background:#F0F0F0; }
				</style>
			</head>
			<body>
				<table class="table" cellpadding="2" cellspacing="5" border="0" width="100%">
					<caption>
						<h1>
							<xsl:apply-templates select="error:title"/>
						</h1>
					</caption>
					<tr>
						<th>Message</th>
						<th>
								<big>
									<xsl:call-template name="returns2br">
										<xsl:with-param name="string" select="error:message"/>
									</xsl:call-template>
								</big>
						</th>
					</tr>
					<tr>
						<th>Source</th>
						<td>
							<xsl:value-of select="@error:sender"/>
						</td>
					</tr>
					<tr>
						<th>Exception</th>
						<td>
							<xsl:value-of select="error:source"/>
						</td>
					</tr>
					<tr>
						<th>Details</th>
						<td>
								<xsl:apply-templates select="error:description" mode="returns2br"/>
						</td>
					</tr>
					<xsl:apply-templates select="error:extra"/>
				</table>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="error:description">
		<tr>
			<td class="highlight" valign="top">
                description
            </td>
			<td bgcolor="#ffffff">
				<xsl:apply-templates mode="returns2br"/>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="error:message">
		<xsl:apply-templates mode="returns2br"/>
	</xsl:template>
	<xsl:template match="error:extra">
		<tr>
			<th>
				<xsl:value-of select="@error:description"/>
			</th>
			<td colspan="2">
				<xsl:choose>
					<xsl:when test="contains(@error:description,'stacktrace')">
						<!-- wrap="OFF" if you want simple lines -->
						<textarea rows="7" cols="80" wrap="OFF" style="width:100% ;font-size:8pt" readonly="readonly">
							<xsl:apply-templates/>
						</textarea>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates mode="returns2br"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="*|text()" name="text" mode="text">
		<xsl:param name="string" select="."/>
		<xsl:variable name="return" select="'&#xa;'"/>
		<xsl:choose>
			<xsl:when test="contains($string,$return)">
				<xsl:value-of select="substring-before($string,$return)"/>
				<xsl:call-template name="text">
					<xsl:with-param name="string" select="substring-after($string,$return)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="returns2br" match="*" mode="returns2br">
		<xsl:param name="string" select="."/>
		<xsl:variable name="return" select="'&#xa;'"/>
		<xsl:choose>
			<xsl:when test="contains($string,$return)">
				<xsl:value-of select="substring-before($string,$return)"/>
				<br/>
				<xsl:call-template name="returns2br">
					<xsl:with-param name="string" select="substring-after($string,$return)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
