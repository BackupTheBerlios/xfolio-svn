<?xml version="1.0" encoding="UTF-8"?>
<!--
	creation:
2004-05-06

	modified:
2004-05-06

	author:
PT:terray@4dconcept.fr

	publisher:
http://strabon.org

	what:
This transformation filters the "STRABON" links, to change them into meaningful
links. 

	history:
From layout.xsl

	DONE:


-->
<xsl:stylesheet
	version="1.0"
	xmlns:dir="http://apache.org/cocoon/directory/2.0"
	xmlns:stb="http://strabon.org/ns/skin"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:htm="http://www.w3.org/1999/xhtml"
	xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	exclude-result-prefixes="xsl dir dc htm stb rdf i18n">

	<!-- no indent to preserve design -->
	<xsl:output method="xml" indent="no" encoding="UTF-8"/>
	<!-- encoding, default is the one specified in xsl:output -->
	<xsl:param name="encoding" select="document('')/*/xsl:output/@encoding"/>

	<!-- Template for chronological period, just an alert for now-->
	<xsl:template match="htm:a[starts-with(@href,'./chrono:')]">
		<xsl:variable name="period" select="substring-after(@href,'./chrono:')"/>
		<a>
			<xsl:attribute name="href">
				<xsl:text>javascript:alert("This is a chronological period");</xsl:text>
			</xsl:attribute>
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<!-- Template for strabon link, just an alert for now-->
	<xsl:template match="htm:a[starts-with(@href,'./strabon:')]">
		<xsl:variable name="id" select="substring-after(@href,'./strabon:')"/>
		<a>
			<xsl:attribute name="href">
				<xsl:text>javascript:alert("This is a link to another STRABON data");</xsl:text>
			</xsl:attribute>
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<!-- Template for dictionnary entry, open a new window on google -->
	<xsl:template match="htm:a[starts-with(@href,'./dict:')]">
		<xsl:variable name="entry" select="substring-after(@href,'./dict:')"/>
		<a target="_blank">
			<xsl:attribute name="href">
				<xsl:text>http://www.google.fr/search?q=</xsl:text>
				<xsl:choose>
					<xsl:when test="$entry!=''">
						<xsl:value-of select="translate($entry,' ','+')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="translate(.,' ','+')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<!-- Template for persons, open a new window on encyclopedia.com -->
	<xsl:template match="htm:a[starts-with(@href,'./person:')]">
		<xsl:variable name="name" select="substring-after(@href,'./person:')"/>
		<xsl:choose>
			<xsl:when test="$name!=''">
				<a target="_blank">
					<xsl:attribute name="href">
						<xsl:text>http://www.encyclopedia.com/searchpool.asp?target=</xsl:text>
						<xsl:value-of select="$name"/>
					</xsl:attribute>
					<xsl:apply-templates/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a>
					<xsl:attribute name="href">
						<xsl:text>javascript:alert("This is a person");</xsl:text>
					</xsl:attribute>
					<xsl:apply-templates/>
				</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Template for GNS location, open a new window on gns server -->
	<xsl:template match="htm:a[starts-with(@href,'./location:')]">
		<xsl:variable name="UFI" select="substring-after(@href,'./location:')"/>
		<xsl:choose>
			<xsl:when test="$UFI!=''">
				<a target="_blank">
					<xsl:attribute name="href">
						<xsl:text>http://gnswww.nima.mil/geonames/Gazetteer/Search/Results.jsp?Feature__Unique_Feature_ID=</xsl:text>
						<xsl:value-of select="$UFI"/>
					</xsl:attribute>
					<xsl:apply-templates/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a>
					<xsl:attribute name="href">
						<xsl:text>javascript:alert("This is a location");</xsl:text>
					</xsl:attribute>
					<xsl:apply-templates/>
				</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- default, copy all -->
	<!-- maybe useful in case of too much xmlns declarations, see the source -->
	<xsl:template match="node()|@*" priority="-1">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
