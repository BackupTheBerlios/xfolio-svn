<?xml version="1.0" encoding="UTF-8"?>
<!--
creation=2004-01-27
modified=2004-01-27
author=frederic.glorieux@ajlsm.com
publisher=http://www.strabon.org

goal=
  normalize dc fields order and strip repeated ones
  also useful to normalize namespace

TODO:
get a title, a description, a language

documentation:
	http://www.w3.org/TR/xhtml2/abstraction.html#dt_MediaDesc
	Alternate, xml:lang
	Stylesheet
	Start
	Next
	Prev, Previous
	Parent
	Contents, Toc
	Index
	Glossary
	Copyright
	Chapter
	Section
	Subsection
	Appendix
	Help
	Bookmark
	Meta
-->
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" version="1.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="branch"/>
  <xsl:param name="domain"/>
  <xsl:variable name="majs" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöùúûüýÿþ:()/\?'"/>
  <xsl:variable name="mins" select="'abcdefghijklmnopqrstuvwxyzaaaaaaaeeeeiiiidnooooouuuuybbaaaaaaaceeeeiiiionooooouuuuyyb.......'"/>
  <xsl:template match="/*">
    <xsl:text>
</xsl:text>
    <xsl:if test="$xsl">
      <xsl:processing-instruction name="xml-stylesheet">
        <xsl:text>type="text/xsl" href="</xsl:text>
        <xsl:value-of select="$xsl"/>
        <xsl:text>"</xsl:text>
      </xsl:processing-instruction>
    </xsl:if>
    <rdf:RDF xml:base="{$domain}{$branch}">
      <rdf:Description>
        <xsl:apply-templates select="head"/>
      </rdf:Description>
    </rdf:RDF>
  </xsl:template>
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  <!-- reorder a record -->
  <xsl:template match="*[*[local-name()='meta']">
    <xsl:copy>
      <xsl:apply-templates select="node()[
	local-name() != 'meta' 
	and local-name() != 'link' 
	and namespace-uri()!='http://purl.org/dc/elements/1.1/']
"/>
      <xsl:apply-templates select="dc:title 
	| meta[contains(translate(@name, $majs, $mins), 'title')]
"/>
      <xsl:apply-templates select="dc:creator 
	| meta[contains(translate(@name, $majs;, $mins), 'creator')]
"/>
      <xsl:apply-templates select="dc:subject 
	| meta[contains(translate(@name, $majs, $mins), 'subject')]
	| meta[contains(translate(@name, $majs, $mins), 'keywords')]
"/>
      <xsl:apply-templates select="dc:description | 
	meta[contains(translate(@name, $majs, $mins), 'description')]
	| link[contains(translate(@rel, $majs, $mins), 'contents')]
	| link[contains(translate(@rel, $majs, $mins), 'toc')]
"/>
      <xsl:apply-templates select="dc:publisher | meta[contains(translate(@name, $majs, $mins), 'publisher')]"/>
      <xsl:apply-templates select="dc:contributor | meta[contains(translate(@name, $majs, $mins), 'contributor')]"/>
      <xsl:apply-templates select="dc:date | meta[contains(translate(@name, $majs, $mins), 'date')]">
        <xsl:sort select="text() | @content"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="dc:type | meta[contains(translate(@name, $majs, $mins), 'type')]"/>
      <xsl:apply-templates select="dc:format | meta[contains(translate(@name, $majs, $mins), 'format')]"/>
      <xsl:apply-templates select="dc:identifier | meta[contains(translate(@name, $majs, $mins), 'identifier')] | link[contains(translate(@rel, $majs, $mins), 'identifier')]"/>
      <xsl:apply-templates select="dc:source | meta[contains(translate(@name, $majs, $mins), 'source')] | link[contains(translate(@rel, $majs, $mins), 'source')]"/>
      <xsl:apply-templates select="dc:relation | meta[contains(translate(@name, $majs, $mins), 'relation')] | link[contains(translate(@rel, $majs, $mins), 'alternate')]"/>
      <xsl:apply-templates select="dc:coverage 
	| meta[contains(translate(@name, $majs, $mins), 'coverage')] 
	| link[contains(translate(@rel, $majs, $mins), 'coverage')]
"/>
      <xsl:apply-templates select="dc:rights 
	| meta[contains(translate(@name, $majs, $mins), 'rights')] 
	| link[contains(translate(@rel, $majs, $mins), 'rights') 
					or contains(translate(@rel, $majs, $mins), 'copyright')]
"/>
    </xsl:copy>
  </xsl:template>
  <!-- avoid repeated properties -->
  <xsl:template match="dc:*"/>
  <xsl:template match="dc:*[not(.=preceding-sibling::dc:*)]">
    <xsl:copy-of select="."/>
  </xsl:template>
  <!-- catch all, to take only differents -->
  <xsl:template match="meta | link"/>
  <!-- htm:link to dc:* -->
  <xsl:template match="link[not(@href=preceding-sibling::link/@href)]">
    <xsl:variable name="name" select="translate(@rel, $majs, $mins)"/>
    <xsl:variable name="element">
      <!-- may be factorized -->
      <xsl:choose>
        <xsl:when test="starts-with($name, 'dc.') and contains(substring-after($name, 'dc.') , '.')">
          <xsl:text>dc:</xsl:text>
          <xsl:value-of select="substring-before(substring-after($name, 'dc.') , '.')"/>
        </xsl:when>
        <xsl:when test="starts-with($name, 'dc.')">
          <xsl:text>dc:</xsl:text>
          <xsl:value-of select="substring-after($name, 'dc.')"/>
        </xsl:when>
        <xsl:when test="$name='contents'">
          <xsl:value-of select="dc:relation"/>
        </xsl:when>
        <xsl:when test="$name='copyright'">
          <xsl:value-of select="dc:rights"/>
        </xsl:when>
        <xsl:otherwise>dc:relation</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$element}">
      <xsl:choose>
        <xsl:when test="@lang">
          <xsl:attribute name="xml:lang">
            <xsl:value-of select="@lang"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="@xml:lang"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="@type">
        <xsl:attribute name="xsi:type">
          <xsl:value-of select="@type"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@title != ''">
          <xsl:attribute name="rdf:resource">
            <xsl:value-of select="@href"/>
          </xsl:attribute>
          <xsl:value-of select="@title"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@href"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  <!-- handling meta with a new content -->
  <xsl:template match="meta[
	(@content != '' and not(@content=preceding-sibling::meta/@content))
	or 	(. != '' and not(.=preceding-sibling::meta))
	]">
    <xsl:variable name="name" select="translate(@name, '&caps;', '&ascii;')"/>
    <xsl:variable name="element">
      <xsl:choose>
        <xsl:when test="starts-with($name, 'dc.') and contains(substring-after($name, 'dc.') , '.')">
          <xsl:text>dc:</xsl:text>
          <xsl:value-of select="substring-before(substring-after($name, 'dc.') , '.')"/>
        </xsl:when>
        <xsl:when test="starts-with($name, 'dc.')">
          <xsl:text>dc:</xsl:text>
          <xsl:value-of select="substring-after($name, 'dc.')"/>
        </xsl:when>
        <xsl:when test="copyright">
          <xsl:value-of select="dc:rights"/>
        </xsl:when>
        <xsl:when test="keywords">
          <xsl:value-of select="dc:subject"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$name"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$element}">
      <xsl:choose>
        <xsl:when test="@lang">
          <xsl:attribute name="xml:lang">
            <xsl:value-of select="@lang"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="@xml:lang"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="@scheme">
        <xsl:attribute name="xsi:type">
          <xsl:value-of select="@scheme"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="normalize-space(.) != ''">
          <xsl:value-of select="."/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@content"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
</xsl:transform>
