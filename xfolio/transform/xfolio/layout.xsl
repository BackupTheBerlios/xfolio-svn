<?xml version="1.0" encoding="UTF-8"?>
<!--
2004-02-23
2004-06-08

FG:frederic.glorieux@ajlsm.com

(c) xfolio.org, ajlsm.com, strabon.org
Licence : GPL

This transformation take an xhtml template, an xhtml content, and an RDF menu as an input.
In the template, some tags in xmlns:foo="http://xfolio.org/ns/skin" namespace
are handle, replaced by 

	history
Change taglib namespace to reflect legal status.
In case of non respect of namespace, match html by local-name(), in hope of no conflicts
Come from an xsl becoming a bit too complex to be simple editable layout.



-->
<xsl:stylesheet version="1.0" xmlns:dir="http://apache.org/cocoon/directory/2.0" xmlns:foo="http://xfolio.org/ns/skin" xmlns:htm="http://www.w3.org/1999/xhtml" xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" exclude-result-prefixes="xsl dir dc htm foo rdf i18n">
  <!-- to provide info on the file -->
  <xsl:import href="rdf2html.xsl"/>
  <!-- to resolve some path -->
  <xsl:import href="naming.xsl"/>
  <!-- no indent to preserve design -->
  <xsl:output method="xml" indent="no" encoding="UTF-8"/>
  <!-- given by server -->
  <xsl:param name="skin" select="'/'"/>
  <!-- lists of available skins as a directory -->
  <xsl:param name="skins" select="/*/skins/*/dir:directory"/>
  <!-- uri of the page, provide by server -->
  <xsl:param name="uri"/>
  <!-- if the server resize, he needs to say it -->
  <xsl:param name="resize"/>
  <!-- cocoon context of the uri -->
  <xsl:param name="context"/>
  <!-- encoding, default is the one specified in xsl:output -->
  <xsl:param name="encoding" select="document('')/*/xsl:output/@encoding"/>
  <!-- identifier of the doc -->
  <xsl:param name="identifier"/>
  <!--

	 handle root node 

-->
  <xsl:template match="/aggregate">
    <!-- the input provide by the sitemap should be in the form
  <aggregate>
    <template>
      <html>
      ... an xhtml template to process ...
      </html>
    </template>
    <content>
    ... a full xhtml article ...
    </content>
    <menu>
			... an xhtml div to include as navigation menu ...
		</menu>
  </aggregate>
-->
    <xsl:apply-templates select="template"/>
  </xsl:template>
  <xsl:template match="template">
    <xsl:apply-templates select="*[1]"/>
  </xsl:template>
  <!-- rewrite links from template to be relative to a skin directory -->
  <xsl:template match="
	  template//*[local-name()='img']/@src[not(contains(., ':'))] 
	| template//*[local-name()='script']/@src[not(contains(., ':'))] 
	| template//*[local-name()='link'][@rel='stylesheet']/@href[not(contains(., ':'))]
	| template//*/@background[not(contains(., ':'))]
	
	">
    <xsl:attribute name="{name()}">
      <xsl:value-of select="$skin"/>
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  <!--
2004-05-08
Here is defined the template for images
Especially the way to display metadata around it
MAYDO:put in xhtml template layout of images (after tests here)

Problems waited because of relative links
-->
  <xsl:template match="/aggregate/content//*[local-name()='img']">
    <xsl:variable name="parent">
      <xsl:call-template name="getParent">
        <xsl:with-param name="path" select="@src"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="radical">
      <xsl:call-template name="getRadical">
        <xsl:with-param name="path" select="@src"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="extension">
      <xsl:call-template name="getExtension">
        <xsl:with-param name="path" select="@src"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="uri">
      <xsl:text>cocoon:/</xsl:text>
      <xsl:value-of select="$context"/>
      <xsl:value-of select="$parent"/>
      <xsl:value-of select="$radical"/>
      <xsl:text>.rdf</xsl:text>
    </xsl:variable>
<!--
javax.xml.transform.TransformerException: Impossible de charger le document demandé : unknown protocol: cocoon

-->
    <xsl:variable name="rdf" select="document($uri, .)"/>
    <xsl:choose>
      <xsl:when test="@class='nolayout'">
        <xsl:copy-of select="."/>
      </xsl:when>
      <!--
record available on this image
rewrite it
 -->
      <xsl:when test="$rdf">
        <div class="img">
          <xsl:attribute name="style">
            <xsl:value-of select="
concat( 'float: ',@align, ' ; width:', substring-after(@src, 'size=') ,'px ; margin:1ex;')"/>
          </xsl:attribute>
          <h6>
            <xsl:comment>  - </xsl:comment>
            <xsl:value-of select="$rdf/*/*/dc:title[1]"/>
          </h6>
          <a href="{$parent}{$radical}.html">
            <img>
              <xsl:copy-of select="@*"/>
              <!-- 
fast patch to show image without resizing 
(size defined by div) 

bug in IE
<xsl:attribute name="width">100%</xsl:attribute>

-->
            </img>
          </a>
          <div>
            <small>
              <xsl:comment>  - </xsl:comment>
              <xsl:value-of select="$rdf/*/*/dc:creator"/>
            </small>
          </div>
        </div>
      </xsl:when>
      <!-- strip width % in case of image resized -->
      <xsl:when test="not($resize)">
        <a href="{$parent}{$radical}.html">
          <img>
            <xsl:copy-of select="@*"/>
            <!-- ?
            <xsl:attribute name="width">
              <xsl:value-of select="substring-after(@src, 'size=')"/>
              <xsl:text>px</xsl:text>
            </xsl:attribute>
            -->
          </img>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- should be head of the template, from which copy head of xhtml -->
  <xsl:template match="*[local-name()='head']">
    <head>
      <xsl:apply-templates/>
      <!-- get metas and some required styles -->
      <xsl:apply-templates select="/aggregate/content/*/*[local-name()='head']/node()"/>
    </head>
  </xsl:template>
  <!--
2004-05-08 FG
catch css links from content may break layout 
Maybe beet
	-->
  <xsl:template match="/aggregate/content/*/*[local-name()='head']/*[local-name()='link'][@rel='stylesheet']"/>
  <!-- match the article substitute -->
  <xsl:template match="foo:article">
    <xsl:apply-templates select="/aggregate/content/*/*[local-name()='body']/node()"/>
  </xsl:template>
  <!-- match the menu substitute -->
  <xsl:template match="foo:menu">
    <a href="../">^^^^</a>
    <!-- should be handled by rdf2html.xsl -->
    <xsl:apply-templates select="/aggregate/menu/node()" mode="menu"/>
  </xsl:template>
  <!-- handle possible tocs -->
  <!-- let tocs where authors decide to have
	<xsl:template match="foo:toc">
		<xsl:copy-of select="/*/content//*[@class='toc']"/>
	</xsl:template>
	<xsl:template match="content//*[@class='toc']"/>
	-->
  <!-- languages available for this doc -->
  <xsl:template match="foo:langs">
    <xsl:apply-templates select="/aggregate/rdf:RDF/rdf:Description[1]" mode="langs"/>
  </xsl:template>
  <!-- formats of this doc in same language -->
  <xsl:template match="foo:formats">
    <xsl:apply-templates select="/aggregate/rdf:RDF/rdf:Description[1]" mode="formats"/>
  </xsl:template>
  <!-- match the clickable uri substitute -->
  <xsl:template match="foo:identifier">
    <xsl:call-template name="path-links">
      <xsl:with-param name="uri" select="$identifier"/>
    </xsl:call-template>
  </xsl:template>
  <!-- match a skin selector -->
  <xsl:template match="foo:skin">
    <form name="skin" action="" method="post" style="display:inline">
      <select onchange="this.form.submit()" name="skin">
        <option/>
        <xsl:for-each select="$skins">
          <option>
            <xsl:value-of select="@name"/>
          </option>
        </xsl:for-each>
      </select>
    </form>
  </xsl:template>
  <!-- write a clickable uri 
2004-04-02 frederic.glorieux@ajlsm.com

This template seems to work with different kind of paths,
may be interesting to test more.
	-->
  <xsl:template name="path-links">
    <xsl:param name="uri" select="$uri"/>
    <xsl:choose>
      <!-- the root -->
      <xsl:when test="starts-with($uri, 'http://')">
        <xsl:variable name="server">
          <xsl:choose>
            <xsl:when test="contains(substring-after($uri, 'http://'), '/')">
              <xsl:value-of select="substring-before(substring-after($uri, 'http://'), '/')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="substring-after($uri, 'http://')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <a>
          <xsl:attribute name="href">
            <xsl:text>http://</xsl:text>
            <xsl:value-of select="$server"/>
          </xsl:attribute>
          <xsl:value-of select="$server"/>
        </a>
        <xsl:call-template name="path-links">
          <xsl:with-param name="uri" select="substring-after($uri, concat('http://', $server ))"/>
        </xsl:call-template>
      </xsl:when>
      <!-- not nice, but in case of path begining by a slash -->
      <xsl:when test="starts-with($uri, '/')">
        <a href="/" style="padding-left:1ex; padding-right:1ex">/</a>
        <xsl:call-template name="path-links">
          <xsl:with-param name="uri" select="substring-after($uri, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- a branch -->
      <xsl:when test="substring-after($uri, '/')!=''">
        <a>
          <xsl:attribute name="href">
            <xsl:text>./</xsl:text>
            <xsl:call-template name="path-upper">
              <xsl:with-param name="path" select="$uri"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:value-of select="substring-before($uri, '/')"/>
        </a>
        <span style="padding-left:1ex; padding-right:1ex;">/</span>
        <xsl:call-template name="path-links">
          <xsl:with-param name="uri" select="substring-after($uri, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- the leave -->
      <xsl:otherwise>
        <a href="{$uri}">
          <xsl:value-of select="$uri"/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- relative upper path -->
  <xsl:template name="path-upper">
    <xsl:param name="path"/>
    <xsl:param name="count" select="string-length($path) - string-length(translate($path, '/\', ''))"/>
    <xsl:choose>
      <xsl:when test="$count &lt; 2"/>
      <xsl:otherwise>
        <xsl:text>../</xsl:text>
        <xsl:call-template name="path-upper">
          <xsl:with-param name="count" select="$count - 1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- default, copy all -->
  <!-- maybe useful in case of too much xmlns declarations, see the source -->
  <xsl:template match="*">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="node()|@*" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
