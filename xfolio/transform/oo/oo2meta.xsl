<?xml version="1.0" encoding="UTF-8"?>
<!--
 #         - GNU Lesser General Public License Version 2.1
 #         - Sun Industry Standards Source License Version 1.1
 #  Copyright: 2000 by Sun Microsystems, Inc.
 #  All Rights Reserved.
 #  The Initial Developer of the Original Code is: Sun Microsystems, Inc.

I'm not sure there's a lot of lines from the original code, 
but I start on it, and learn with


creation   : 2004-01-27
modified   : 2004-01-27
author     : frederic.glorieux@ajlsm.com

goal:
  provide the best set of Dublin Core properties from an Openoffice
  writer document.

usage:
  The root template produce an RDF document with the DC properties
	Single DC properties may be accessed by global xsl:param
  A template "metas" give an HTML version of this properties.
  This template may be externalize in a specific rdf2meta ?

history:
  These transformation was extracted from a global oo2html
  The metas could be used separated for other usages.

todo:
  make it work
  what about a default properties document ?
	format in arabic

bugs:
  seems to bug with xalan under cocoon in creator template
  
documentation:
	http://www.w3.org/TR/xhtml2/abstraction.html#dt_MediaDesc

-->
<xsl:transform version="1.0" xmlns:style="http://openoffice.org/2000/style" xmlns:text="http://openoffice.org/2000/text" xmlns:office="http://openoffice.org/2000/office" xmlns:table="http://openoffice.org/2000/table" xmlns:draw="http://openoffice.org/2000/drawing" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="http://openoffice.org/2000/meta" xmlns:number="http://openoffice.org/2000/datastyle" xmlns:svg="http://www.w3.org/2000/svg" xmlns:chart="http://openoffice.org/2000/chart" xmlns:dr3d="http://openoffice.org/2000/dr3d" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="http://openoffice.org/2000/form" xmlns:script="http://openoffice.org/2000/script" xmlns:config="http://openoffice.org/2001/config" office:class="text" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dir="http://apache.org/cocoon/directory/2.0" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="office meta  table number fo xlink chart math script xsl draw svg dr3d form config text style dc dir">
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	<!-- identifier for doc in all formats -->
	<xsl:param name="identifier"/>
	<!-- target uri of generated doc -->
	<xsl:param name="uri"/>
	<!-- source uri proceed by this transformation -->
	<xsl:param name="source"/>
	<!-- language  provide externally in case of naming policy -->
	<xsl:param name="language"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="normalize-space(translate($language, '_', ''))!=''">
				<xsl:value-of select="normalize-space(translate($language, '_', ''))"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- unsure for authors writing different languages with same app -->
				<xsl:value-of select="//office:meta/dc:language"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="publisher"/>
	<xsl:param name="copyright"/>
	<!-- in case of more precise typing -->
	<xsl:param name="type" select="'text'"/>
	<!--


-->
	<xsl:template match="/">
		<html>
			<head>
				<xsl:call-template name="metas"/>
			</head>
			<body/>
		</html>
	</xsl:template>
	<xsl:template name="metas">
		<title>
			<xsl:call-template name="title"/>
		</title>
		<meta name="DC.title">
			<xsl:if test="$lang">
				<xsl:attribute name="xml:lang">
					<xsl:value-of select="$lang"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="content">
				<xsl:call-template name="title"/>
			</xsl:attribute>
		</meta>
		<meta name="DC.creator">
			<xsl:if test="$lang">
				<xsl:attribute name="xml:lang">
					<xsl:value-of select="$lang"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="content">
				<xsl:call-template name="creator"/>
			</xsl:attribute>
		</meta>
		<xsl:apply-templates select="//office:meta/dc:subject"/>
		<xsl:apply-templates select="//office:meta/meta:keywords"/>
		<meta name="DC.description">
			<xsl:if test="$lang">
				<xsl:attribute name="xml:lang">
					<xsl:value-of select="$lang"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="content">
				<xsl:call-template name="description"/>
			</xsl:attribute>
		</meta>
		<!-- publisher ?? -->
		<meta name="DC.date.created" scheme="http://www.w3.org/TR/NOTE-datetime">
			<xsl:if test="$lang">
				<xsl:attribute name="xml:lang">
					<xsl:value-of select="$lang"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="content">
				<xsl:apply-templates select="//office:meta/meta:creation-date"/>
			</xsl:attribute>
		</meta>
		<meta name="DC.date.modified" scheme="http://www.w3.org/TR/NOTE-datetime">
			<xsl:if test="$lang">
				<xsl:attribute name="xml:lang">
					<xsl:value-of select="$lang"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="content">
				<xsl:apply-templates select="//office:meta/dc:date"/>
			</xsl:attribute>
		</meta>
		<meta name="DC.type" content="{$type}"/>
		<meta name="DC.format">
			<xsl:if test="$lang">
				<xsl:attribute name="xml:lang">
					<xsl:value-of select="$lang"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="content">
				<xsl:call-template name="format"/>
			</xsl:attribute>
		</meta>
		<!-- server give an identifier for the doc, common to each lang and format -->
		<xsl:if test="$identifier">
			<link rel="DC.identifier" href="{$identifier}"/>
		</xsl:if>
		<!-- server give the target uri of this transformation -->
		<xsl:if test="$uri">
			<link rel="DC.relation" type="text/html" href="{$uri}">
				<xsl:if test="$lang">
					<xsl:attribute name="xml:lang">
						<xsl:value-of select="$lang"/>
					</xsl:attribute>
				</xsl:if>
			</link>
		</xsl:if>
		<!-- server give the source uri of this transformation -->
		<xsl:if test="$source">
			<link rel="DC.source" type="application/vnd.sun.xml.writer" href="{$source}">
				<xsl:if test="$lang">
					<xsl:attribute name="xml:lang">
						<xsl:value-of select="$lang"/>
					</xsl:attribute>
				</xsl:if>
			</link>
		</xsl:if>
		<xsl:if test="$copyright">
			<link rel="copyright" href="{$copyright}">
				<xsl:if test="$lang">
					<xsl:attribute name="xml:lang">
						<xsl:value-of select="$lang"/>
					</xsl:attribute>
				</xsl:if>
			</link>
		</xsl:if>
	</xsl:template>
	<!-- main subject to index -->
	<xsl:template match="dc:subject">
		<meta name="DC.subject" content="{.}">
			<xsl:attribute name="xml:lang">
				<xsl:value-of select="$lang"/>
			</xsl:attribute>
		</meta>
	</xsl:template>
	<!-- treat comma separated subjects as different topics -->
	<xsl:template match="meta:keywords">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="meta:keyword">
		<meta name="DC.subject" content="{.}" scheme="http://openoffice.org/2000/meta#keyword">
			<xsl:attribute name="xml:lang">
				<xsl:value-of select="$lang"/>
			</xsl:attribute>
		</meta>
	</xsl:template>
	<!-- first date creation, last date modification -->
	<xsl:template match="meta:creation-date | dc:date">
		<xsl:value-of select="substring-before(.,'T')"/>
	</xsl:template>
	<!-- meta user defined when not empty -->
	<xsl:template match="meta:user-defined">
		<xsl:if test="normalize-space(.)!=''">
			<meta name="{@meta:name}" content="{.}"/>
		</xsl:if>
	</xsl:template>
	<!-- do something with that ? -->
	<xsl:template match="meta:editing-cycles"/>
	<xsl:template match="meta:editing-duration"/>
	<!--<xsl:template match="meta:initial-creator">
    <author>
    <xsl:apply-templates />
        </author>
    </xsl:template>-->
	<!-- get the best description -->
	<xsl:template name="description">
		<xsl:variable name="style" select="'abstract'"/>
		<xsl:variable name="style-modified" select="
//office:automatic-styles/style:style[@style:parent-style-name=$style]/@style:name
          "/>
		<xsl:choose>
			<xsl:when test="normalize-space(//office:meta/dc:description)!=''">
				<xsl:value-of select="//office:meta/dc:description"/>
			</xsl:when>
			<xsl:when test="
normalize-space(
//text:*[@text:style-name=$style or @text:style-name = $style-modified]
) != ''
          ">
				<xsl:for-each select="
//text:*[@text:style-name=$style or @text:style-name = $style-modified]
            ">
					<xsl:if test="position()!=1">
						<xsl:value-of select="'
    '"/>
					</xsl:if>
					<xsl:value-of select="normalize-space(.)"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
					</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- get the best title -->
	<xsl:template name="title">
		<xsl:variable name="title">
			<xsl:call-template name="getElementByStyle">
				<xsl:with-param name="style" select="'Title'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="normalize-space(//office:meta/dc:title) != ''">
				<xsl:value-of select="//office:meta/dc:title"/>
			</xsl:when>
			<xsl:when test="normalize-space(//office:meta/dc:title) != ''">
				<xsl:value-of select="normalize-space(//text:title)"/>
			</xsl:when>
			<xsl:when test="normalize-space($title) != ''">
				<xsl:value-of select="normalize-space($title)"/>
			</xsl:when>
			<xsl:when test="//text:h">
				<xsl:value-of select="normalize-space(//text:h)"/>
			</xsl:when>
			<!--
			<xsl:otherwise>
				<xsl:value-of select="document($messfile, $encoding)//*[@id='notitle']/label"/>
			</xsl:otherwise>
			-->
		</xsl:choose>
	</xsl:template>
	<!-- get the best creator -->
	<xsl:template name="creator">
		<xsl:choose>
			<xsl:when test="//text:sender-lastname">
				<xsl:value-of select="//text:sender-lastname"/>
				<xsl:if test="//text:sender-firstname">
					<xsl:text>, </xsl:text>
					<xsl:value-of select="//text:sender-firstname"/>
				</xsl:if>
				<xsl:if test="//text:sender-company">
					<xsl:text> (</xsl:text>
					<xsl:value-of select="//text:sender-company"/>
					<xsl:if test="//text:sender-country">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="//text:sender-country"/>
					</xsl:if>
					<xsl:text>)</xsl:text>
				</xsl:if>
				<xsl:if test="//text:sender-email">
					<xsl:text> - </xsl:text>
					<xsl:apply-templates select="//text:sender-email"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="//office:meta/meta:initial-creator">
				<xsl:value-of select="//office:meta/meta:initial-creator"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="//office:meta/dc:creator"/>
			</xsl:otherwise>
		</xsl:choose>
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
	<xsl:template name="getElementByStyle">
		<xsl:param name="style"/>
		<xsl:variable name="style-auto" select="
//office:automatic-styles/style:style[@style:parent-style-name=$style]/@style:name
          "/>
		<xsl:copy-of select="//*[
   @text:style-name      = $style
or @text:style-name      = $style-auto
or @draw:style-name      = $style
or @draw:style-name      = $style-auto
or @draw:text-style-name = $style
or @draw:text-style-name = $style-auto
or @table:style-name     = $style
or @table:style-name     = $style-auto
]"/>
	</xsl:template>
	<!-- give size of a doc in different units, tooken from
		<meta:document-statistic meta:table-count="1" meta:image-count="0" meta:object-count="0" meta:page-count="11" meta:paragraph-count="326" meta:word-count="3405" meta:character-count="23617"/>
	-->
	<xsl:template name="format" match="meta:document-statistic">
		<xsl:for-each select="//meta:document-statistic">
			<xsl:value-of select="@meta:page-count"/>
			<xsl:text> p. : </xsl:text>
			<xsl:value-of select="@meta:word-count"/>
			<xsl:text> mots, </xsl:text>
			<xsl:value-of select="@meta:character-count"/>
			<xsl:text> signes, </xsl:text>
			<xsl:value-of select="@meta:image-count"/>
			<xsl:text> ill. </xsl:text>
		</xsl:for-each>
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
	<xsl:template match="text:sender-email">
		<xsl:choose>
			<xsl:when test="contains(., '@')">
				<xsl:value-of select="substring-before(., '@')"/>
				<xsl:text>(at)</xsl:text>
				<xsl:value-of select="substring-after(., '@')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:transform>
