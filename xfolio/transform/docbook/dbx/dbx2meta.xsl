<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright : (C) 2002, 2003, 2004 AJLSM (ajlsm.com)
Licence   : http://www.fsf.org/copyleft/gpl.html


frederic.glorieux@ajlsm.com

This is a part of an AJLSM customization of docbook.


goal=
  provide the best set of Dublin Core properties from a docbook doc.

usage=
  The root template produce an RDF document with the DC properties
	Single DC properties may be accessed by global xsl:param
  A template "metas" give an HTML version of this properties.
  This template may be externalize in a specific rdf2meta ?

history=
  These transformation was extracted from a global oo2html
  The metas could be used separated for other usages.

todo=
  make it work
  what about a default properties document ?
	format in arabic

bugs=
  seems to bug with xalan under cocoon in creator template

-->
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1">
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	<!-- language may be more surely setted externaly -->
	<xsl:param name="identifier"/>
	<xsl:param name="source"/>
	<xsl:param name="target"/>
	<xsl:param name="publisher"/>
	<xsl:param name="copyright"/>
	<!-- provide externally -->
	<xsl:param name="language"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="normalize-space(translate($language, '_', ''))!=''">
				<xsl:value-of select="normalize-space(translate($language, '_', ''))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@lang | @xml:lang"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="type" select="'text'"/>
	<xsl:param name="root" select="/"/>
	<!--


-->
	<xsl:template name="metas">
		<title>
			<xsl:call-template name="title"/>
		</title>
		<meta name="DC.title">
			<xsl:if test="$lang != ''">
				<xsl:attribute name="xml:lang">
					<xsl:value-of select="$lang"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="content">
				<xsl:call-template name="title"/>
			</xsl:attribute>
		</meta>
		<xsl:for-each select="/*/*[contains(name(), 'info')]/author | /*/*[contains(name(), 'info')]/authorgroup/author">
			<meta name="DC.creator">
				<xsl:variable name="content">
					<xsl:apply-templates select="." mode="text"/>
				</xsl:variable>
				<xsl:attribute name="content">
					<xsl:value-of select="normalize-space($content)"/>
				</xsl:attribute>
			</meta>
		</xsl:for-each>
		<xsl:apply-templates select="/*/*[contains(name(), 'info')]/subjectset"/>
		<xsl:apply-templates select="/*/*[contains(name(), 'info')]/keywordset"/>
		<meta name="DC.description">
			<xsl:if test="$lang != ''">
				<xsl:attribute name="xml:lang">
					<xsl:value-of select="$lang"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="content">
				<xsl:call-template name="description"/>
			</xsl:attribute>
		</meta>
		<xsl:for-each select="/*/*[contains(name(), 'info')]/publisher | /*/*[contains(name(), 'info')]/publishername">
			<meta name="DC.publisher">
				<xsl:variable name="content">
					<xsl:apply-templates/>
				</xsl:variable>
				<xsl:attribute name="content">
					<xsl:value-of select="normalize-space($content)"/>
				</xsl:attribute>
			</meta>
		</xsl:for-each>
		<xsl:for-each select="/*/*[contains(local-name(), 'info')][1]//date">
			<xsl:choose>
				<xsl:when test="position()=1">
					<meta name="DC.date.created" scheme="http://www.w3.org/TR/NOTE-datetime" content="{.}"/>
				</xsl:when>
				<xsl:when test="position()=last() and position() != 1">
					<meta name="DC.date.modified" scheme="http://www.w3.org/TR/NOTE-datetime" content="{.}"/>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
		<meta name="DC.type" content="{$type}"/>
		<meta name="DC.format">
			<xsl:if test="$lang != ''">
				<xsl:attribute name="xml:lang">
					<xsl:value-of select="$lang"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="content">
				<xsl:call-template name="format"/>
			</xsl:attribute>
		</meta>
		<!-- TODO:biblioid ?? -->
		<!-- server give an identifier for the doc, common to each lang and format -->
		<xsl:if test="$identifier">
			<link rel="DC.identifier" href="{$identifier}"/>
		</xsl:if>
		<!-- server give the target uri of this transformation -->
		<xsl:if test="$target">
			<link rel="DC.relation" type="text/html" href="{$target}">
				<xsl:if test="$lang != ''">
					<xsl:attribute name="xml:lang">
						<xsl:value-of select="$lang"/>
					</xsl:attribute>
				</xsl:if>
			</link>
		</xsl:if>
		<!-- TODO:bibliosource -->
		<!-- server give the source uri of this transformation -->
		<xsl:if test="$source">
			<link rel="DC.source" type="text/xml" href="{$source}">
				<xsl:if test="$lang != ''">
					<xsl:attribute name="xml:lang">
						<xsl:value-of select="$lang"/>
					</xsl:attribute>
				</xsl:if>
			</link>
		</xsl:if>
		<xsl:for-each select="/*/*[contains(name(), 'info')]/copyright">
			<meta name="DC.copyright">
				<xsl:variable name="content">
					<xsl:apply-templates select="."/>
				</xsl:variable>
				<xsl:attribute name="content">
					<xsl:value-of select="normalize-space($content)"/>
				</xsl:attribute>
			</meta>
		</xsl:for-each>
	</xsl:template>
	<!-- main subject to index -->
	<xsl:template match="subjectset | keywordset">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="subject | keyword">
		<meta name="DC.subject">
			<xsl:attribute name="scheme">
				<xsl:choose>
					<xsl:when test="../@scheme">
						<xsl:copy-of select="../@scheme"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>http://docbook.org#</xsl:text>
						<xsl:value-of select="local-name()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="$lang != ''">
				<xsl:attribute name="xml:lang">
					<xsl:value-of select="$lang"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="content">
				<xsl:apply-templates/>
			</xsl:attribute>
		</meta>
	</xsl:template>
	<xsl:template match="subjecterm">
		<xsl:value-of select="normalize-space(.)"/>
		<xsl:if test="following-sibling::*"> - </xsl:if>
	</xsl:template>
	<xsl:template name="description">
		<xsl:choose>
			<xsl:when test="/*/*[contains(local-name(), 'info')]/abstract">
				<xsl:value-of select="/*/*[contains(local-name(), 'info')]/abstract"/>
			</xsl:when>
			<xsl:when test="/*/abstract">
				<xsl:value-of select="/*/abstract"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- get the best title -->
	<xsl:template name="title">
		<xsl:choose>
			<xsl:when test="/*/*[contains(local-name(), 'info')]/title">
				<xsl:value-of select="/*/*[contains(local-name(), 'info')]/title"/>
			</xsl:when>
			<xsl:when test="/*/title">
				<xsl:value-of select="/*/title"/>
			</xsl:when>
			<!-- localize ? -->
			<xsl:otherwise>sans-titre</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- get the best creator -->
	<xsl:template name="creator">
		<!-- import ? -->
	</xsl:template>
	<!-- get a publisher -->
	<xsl:template name="publisher">
		<xsl:choose>
			<xsl:when test="$publisher">
				<meta name="DC.publisher" content="{$publisher}"/>
			</xsl:when>
			<!--
			<xsl:when test="$server">
				<link t
			</xsl:when>
			-->
		</xsl:choose>
	</xsl:template>
	<xsl:template name="format">
		<xsl:variable name="string" select="normalize-space(/)"/>
		<xsl:variable name="signs" select="string-length($string)"/>
		<xsl:variable name="pages" select="round($signs div 1500)"/>
		<!-- numer of word = number of spaces -->
		<xsl:variable name="words" select="$signs - string-length(translate($string, ' ', ''))"/>
		<xsl:variable name="images" select="count(imageobject)"/>
		<xsl:value-of select="$pages"/>
		<xsl:text> p. : </xsl:text>
		<xsl:value-of select="$words"/>
		<xsl:text> mots, </xsl:text>
		<xsl:value-of select="$signs"/>
		<xsl:text> signes, </xsl:text>
		<xsl:value-of select="$images"/>
		<xsl:text> ill. </xsl:text>
	</xsl:template>
	<!-- snippets to include
  <xsl:template match="tests" xmlns:date="xalan://java.util.Date" xmlns:encoder="xalan://java.net.URLEncoder"
     <xsl:value-of select="encoder:encode(string(test))"/>
     <xsl:value-of select="date:new()" />
  </xsl:template>
  -->
	<!-- default, keep meta section in normal processing -->
	<!-- try to catch paragraphs for meta, matching is complex
  because of lots of possible template implementation -->
	<!--
  <xsl:template match="text:section[@text:name='meta']"/>
  <xsl:template match="text:section[@text:name='meta']/*"/>

  <xsl:template match="text:p[@text:style-name='meta' 
  or .//*[@text:name='dc'] 
  or .//*[@text:name='dc'] 
  or .//*[@text:style-name='lang'] 
  or .//*[@text:name='lang']
  or .//*[@text:name='content' or @text:style-name='content' or @text:description='content']
  ]">
    <meta name="{normalize-space(.//*[@text:name='dc' or @text:style-name='dc'])}" lang="{normalize-space(.//*[@text:name='lang' or @text:style-name='lang'])}" scheme="{normalize-space(.//*[@text:name='scheme' or @text:style-name='scheme'])}">
      <xsl:attribute name="content">
        <xsl:variable name="content">
          <xsl:apply-templates select="
.//text:modification-date | .//text:creation-date | .//text:file-name
| 
.//*[@text:name='content' or @text:style-name='content' or @text:description='content']
          "/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($content)"/>
      </xsl:attribute>
    </meta>
  </xsl:template>
-->
</xsl:transform>
