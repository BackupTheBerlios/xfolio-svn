<?xml version="1.0" encoding="UTF-8"?>
<!--
(c) 2003 ajlsm.com, 2004 xfolio.org, ajlsm.com
http://www.fsf.org/copyleft/gpl.html

	2003-05-16
FG:frederic.glorieux@xfolio.org

Provide a view for rdf/Dublin Core records 
Should be efficient on lots of kind of rdf in different situations

	history
2004-04-06 
2004-05-16 Originally developped for a test of rdf under SDX


  TODO

Centralize relative URIs resolving for resourecs, and images
?? xmlns="http://www.w3.org/1999/xhtml"

-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rss="http://purl.org/rss/1.0/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns:dt="http://xsltsl.org/date-time" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="i18n xsl rss rdf dc dt xsi xlink">
  <xsl:import href="naming.xsl"/>
  <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
  <!-- give a language from somewhere to choose properties to display -->
  <xsl:param name="language"/>
  <xsl:param name="lang">
    <xsl:call-template name="getLang">
      <xsl:with-param name="path" select="$language"/>
    </xsl:call-template>
  </xsl:param>
  <!-- important ? perhaps in standalone -->
  <xsl:param name="css"/>
  <!-- could be used in different cases -->
  <xsl:param name="mode"/>
  <!-- name of the file requester -->
  <xsl:param name="this"/>
  <!-- encoding, default is the one specified in xsl:output -->
  <xsl:param name="encoding" select="document('')/*/xsl:output/@encoding"/>
  <!-- if server is able to resize images -->
  <xsl:param name="resize"/>
  <!-- identifier -->
  <xsl:param name="identifier"/>
  <!-- list of languages -->
  <xsl:variable name="langs" select="document('langs.xml')"/>
  <!--
	 handle the root  
-->
  <xsl:template match="rdf:RDF">
    <xsl:choose>
      <xsl:when test="$mode='menu'">
        <xsl:apply-templates select="." mode="menu"/>
      </xsl:when>
      <!-- title list -->
      <xsl:when test="$mode='title'">
        <xsl:apply-templates select="rdf:Description" mode="title">
          <xsl:sort select="dc:title"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$mode='creator'">
        <xsl:apply-templates select="rdf:Description" mode="creator">
          <xsl:sort select="dc:creator[1]"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <html>
          <head>
            <meta http-equiv="Content-type">
              <xsl:attribute name="content">
                <xsl:text>text/html; charset=</xsl:text>
                <xsl:value-of select="$encoding"/>
              </xsl:attribute>
            </meta>
          </head>
          <body>
            <!--
TODO			[contains(rdf:Description/dc:format, 'image')]
			-->
            <xsl:choose>
              <xsl:when test="$mode='image'">
                <xsl:apply-templates select="rdf:Description" mode="image"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="rdf:Description"/>
              </xsl:otherwise>
            </xsl:choose>
          </body>
        </html>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- template handle RDF root for a menu -->
  <xsl:template match="rdf:RDF" mode="menu">
    <table id="menu" cellpadding="3">
      <xsl:for-each select="rdf:Description">
        <tr>
          <!-- will bug in some case use  -->
          <xsl:if test="contains(dc:identifier, $this)">
            <xsl:attribute name="class">this</xsl:attribute>
            <xsl:attribute name="bgcolor">#FFFFCC</xsl:attribute>
          </xsl:if>
          <xsl:variable name="image" select="dc:relation[contains(@xsi:type, 'image/jpeg')][1]"/>
          <xsl:if test="$image and $resize">
            <td class="img" bgcolor="#CCCCCC" width="52px" height="52px" align="center" valign="middle">
              <!-- 
request a thumb by filename, to avoid loading of complete images
if the server is not able to resize.
  -->
              <xsl:call-template name="thumb">
                <xsl:with-param name="relation" select="$image"/>
                <xsl:with-param name="size" select="50"/>
              </xsl:call-template>
            </td>
          </xsl:if>
          <td>
            <xsl:if test="not($image)">
              <xsl:attribute name="colspan">2</xsl:attribute>
            </xsl:if>
            
            <xsl:apply-templates select="." mode="title"/>
          </td>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>
  <!-- template mode image -->
  <xsl:template match="rdf:Description" mode="image">
    <!-- take the most valuable lang to display in this record -->
    <xsl:param name="xml:lang">
      <xsl:call-template name="dc:lang"/>
    </xsl:param>
    <div class="record">
      <h1>
        <xsl:apply-templates select="." mode="title"/>
      </h1>
      <div>
        <xsl:comment> &#160; </xsl:comment>
        <xsl:apply-templates select="dc:format[not(@xsi:type)][not(@xml:lang) or contains (@xml:lang, $xml:lang)][1]"/>
        <xsl:apply-templates select="." mode="formats"/>
        <xsl:apply-templates select="." mode="langs"/>
      </div>
      <xsl:for-each select="dc:relation[contains(@xsi:type, 'image')]">
        <a class="img" href="{.}">
          <img class="nolayout" width="800px" src="{.}" border="0" alt="{../dc:tile}"/>
        </a>
      </xsl:for-each>
      <p class="description">
        <xsl:apply-templates select="." mode="description"/>
      </p>
      <div class="">
        <xsl:apply-templates select="dc:date[1]"/>
        <xsl:if test="dc:date and (dc:coverage or dc:creator)">, </xsl:if>
        <xsl:apply-templates select="dc:coverage[1]"/>
        <xsl:if test="(dc:coverage or dc:date) and dc:creator">, </xsl:if>
        <xsl:apply-templates select="dc:creator[not(@xml:lang) or contains (@xml:lang, $xml:lang)][1]"/>
        <xsl:if test="dc:creator or dc:date or dc:coverage">. </xsl:if>
      </div>
      <small class="rights">
        <xsl:comment> &#160; </xsl:comment>
        <xsl:apply-templates select="dc:rights[1]"/>
      </small>
    </div>
  </xsl:template>
  <!--
Default template of a record
-->
  <xsl:template match="rdf:Description">
    <!-- take the most valuable lang to display in this record -->
    <xsl:param name="xml:lang">
      <xsl:call-template name="dc:lang"/>
    </xsl:param>
    <div class="record">
      <h1>
        <xsl:apply-templates select="." mode="title"/>
      </h1>
      <table width="100%">
        <tr>
          <td colspan="2">
            <small>
              <xsl:comment> &#160; </xsl:comment>
              <xsl:apply-templates select="dc:format[not(@xsi:type)][not(@xml:lang) or contains (@xml:lang, $xml:lang)][1]"/>
              <xsl:apply-templates select="." mode="formats"/>
              <xsl:apply-templates select="." mode="langs"/>
            </small>
          </td>
        </tr>
        <tr>
          <!--
awful to browse under firefox
  <img src="{dc:relation[contains(@xsi:type, 'image')]}?size=200" width="200" border="0" alt="{dc:tile}"/>
-->
          <xsl:variable name="image" select="dc:relation[contains(@xsi:type, 'image')][1]"/>
          <xsl:if test="$image and $resize">
            <a class="img">
              <xsl:attribute name="href">
                <xsl:call-template name="getRelative">
                  <xsl:with-param name="from" select="$identifier"/>
                  <xsl:with-param name="to" select="$image"/>
                </xsl:call-template>
              </xsl:attribute>
              <td class="img" bgcolor="#CCCCCC" width="204" height="204" align="center" valign="middle">
                <xsl:call-template name="thumb">
                  <xsl:with-param name="relation" select="$image"/>
                  <xsl:with-param name="size" select="200"/>
                </xsl:call-template>
              </td>
            </a>
          </xsl:if>
          <!--
							<xsl:apply-templates select="dc:relation[contains(@xsi:type, 'image')][1]">
								<xsl:with-param name="size" select="200"/>
							</xsl:apply-templates>
-->
          <td align="left">
            <p class="description">
              <xsl:apply-templates select="." mode="description"/>
            </p>
            <div class="">
              <xsl:apply-templates select="dc:date[1]"/>
              <xsl:if test="dc:date and (dc:coverage or dc:creator)">, </xsl:if>
              <xsl:apply-templates select="dc:coverage[1]"/>
              <xsl:if test="dc:coverage and dc:creator">, </xsl:if>
              <xsl:apply-templates select="dc:creator[not(@xml:lang) or contains (@xml:lang, $xml:lang)][1]"/>
              <xsl:if test="dc:creator or dc:date or dc:coverage">. </xsl:if>
            </div>
          </td>
        </tr>
        <tr>
          <td colspan="2">
            <small class="rights">
              <xsl:comment> &#160; </xsl:comment>
              <xsl:apply-templates select="dc:rights[1]"/>
            </small>
          </td>
        </tr>
      </table>
    </div>
  </xsl:template>
  <!--
This template should display a thumbnail of a related image to
the resource, may be used in default mode to display a record

This will not work as a toc (need to pass a path ?)
-->
  <xsl:template name="thumb" match="dc:relation[contains(@xsi:type, 'image/jpg')]">
    <xsl:param name="relation" select="."/>
    <xsl:param name="size"/>
    <xsl:variable name="radical">
      <xsl:call-template name="getRadical">
        <xsl:with-param name="path" select="$relation"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="parent">
      <xsl:call-template name="getParent">
        <xsl:with-param name="path">
          <xsl:call-template name="getRelative">
            <xsl:with-param name="from" select="$relation/ancestor::rdf:RDF/@rdf:about"/>
            <xsl:with-param name="to" select="$relation"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <a class="img" href="{$parent}{$radical}.jpg">
      <img src="{$parent}{$radical}_{$size}.jpg" border="0" alt="{../dc:tile}"/>
    </a>
  </xsl:template>
  <!-- this template match a multilingual DC record, to display some html  
	1) find the best link on requested language 
	2) add alternate language versions
	3) if not short, add other formats
	4) 
	-->
  <xsl:template name="dc:lang">
    <xsl:choose>
      <xsl:when test="dc:title[contains(@xml:lang, $lang)]">
        <xsl:value-of select="substring (dc:title[contains(@xml:lang, $lang)]/@xml:lang , 1, 2)"/>
      </xsl:when>
      <xsl:when test="dc:title/@xml:lang">
        <xsl:value-of select="substring ( dc:title[1]/@xml:lang , 1, 2)"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- title -->
  <xsl:template match="rdf:Description" name="title" mode="title">
    <xsl:param name="xml:lang">
      <xsl:call-template name="dc:lang"/>
    </xsl:param>
    <xsl:variable name="uri">
                <xsl:call-template name="getRelative">
                  <xsl:with-param name="from" select="ancestor::rdf:RDF/@rdf:about"/>
                  <xsl:with-param name="to" select="dc:relation[contains (@xml:lang, $xml:lang) and @xsi:type='text/html'][1]"/>
                </xsl:call-template>
    </xsl:variable>
    <!--
Lucky effect, request title for text document, not for directory
		-->
    <xsl:variable name="title">
      <xsl:value-of select="dc:title[contains (@xml:lang, $xml:lang)][1]"/>
    </xsl:variable>
    <!--
    <xsl:value-of select="ancestor::rdf:RDF/@rdf:about"/><br/>
    <xsl:value-of select="dc:relation[contains (@xml:lang, $xml:lang) and @xsi:type='text/html'][1]"/><br/>
-->    
<!-- if no link ? -->
    <a target="_top" class="title" href="{$uri}">
      <xsl:choose>
        <xsl:when test="normalize-space($title)=''">
          <i18n:text key="noTitle">No title</i18n:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$title"/>
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>
  <!-- creator -->
  <xsl:template match="rdf:Description" name="creator" mode="creator">
    <xsl:param name="xml:lang">
      <xsl:call-template name="dc:lang"/>
    </xsl:param>
    <xsl:variable name="creator" select="dc:creator[contains (@xml:lang, $xml:lang)][1]"/>
    <xsl:variable name="uri" select="dc:creator[contains (@xml:lang, $xml:lang)][1]/@xlink:href"/>
    <xsl:choose>
      <xsl:when test="normalize-space($creator)=''">
        <!--
          validation mode ?
					<i18n:text key="noCreator">Unknown</i18n:text>
        -->
      </xsl:when>
      <!--
better resolution of links 
     <xsl:when test="normalize-space($uri) != ''">
        <a target="_top" class="creator" href="substring-after($uri, $domain)">
          <xsl:value-of select="$creator"/>
        </a>
      </xsl:when>
-->
      <xsl:otherwise>
        <xsl:value-of select="$creator"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- langs available -->
  <xsl:template match="rdf:Description" name="langs" mode="langs">
    <xsl:param name="xml:lang">
      <xsl:call-template name="dc:lang"/>
    </xsl:param>
    <xsl:if test="dc:*[local-name()='relation' or local-name()='source'][@xml:lang][@xsi:type = 'text/html']">
      <select class="langs" onchange="uri=this.options[this.selectedIndex].value; window.location=uri;">
        <option> </option>
        <xsl:for-each select="dc:*[local-name()='relation' or local-name()='source'][@xml:lang][@xsi:type = 'text/html']">
          <xsl:variable name="code" select="substring (@xml:lang, 1, 2)"/>
          <option value="{@rdf:resource}">
            <xsl:if test="contains(@xml:lang, $lang)">
              <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            <!-- problems to solve links !! -->
            <xsl:text>[</xsl:text>
            <xsl:value-of select="@xml:lang"/>
            <xsl:text>] </xsl:text>
            <xsl:value-of select="$langs/*/*[@code=$code]/*[contains(@xml:lang, $lang)]"/>
          </option>
        </xsl:for-each>
      </select>
    </xsl:if>
  </xsl:template>
  <!-- formats available -->
  <xsl:template match="rdf:Description" name="formats" mode="formats">
    <xsl:param name="xml:lang">
      <xsl:call-template name="dc:lang"/>
    </xsl:param>
    <xsl:if test="dc:*[local-name()='relation' or local-name()='source'][not(@xml:lang) or contains(@xml:lang, $xml:lang)][@xsi:type != 'text/html']">
      <span class="formats">
        <!-- "(" may be undesire ? -->
        <xsl:text> (</xsl:text>
        <!-- 
for each different formats of a desired lang 
FG:2004-06-17 Kairouan
tricky XPath, but buggy when there is an html file of same name
-->
        <xsl:for-each select="dc:*[local-name()='relation' or local-name()='source']
[not(@xml:lang) or contains(@xml:lang, $xml:lang)]
[@xsi:type != 'text/html']
[not(preceding-sibling::dc:*[not(@xml:lang) or contains(@xml:lang, $xml:lang)][local-name()='relation' or local-name()='source']/@xsi:type = @xsi:type)]
				">
          <a target="_top" tabindex="2" title="{@xsi:type}">
            <xsl:attribute name="href">
              <xsl:call-template name="getRelative">
                <xsl:with-param name="from" select="$identifier"/>
                <xsl:with-param name="to" select="."/>
              </xsl:call-template>
            </xsl:attribute>
            <!-- icon ? -->
            <xsl:variable name="extension">
              <xsl:call-template name="getExtension">
                <xsl:with-param name="path" select="."/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$extension=''">txt</xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$extension"/>
              </xsl:otherwise>
            </xsl:choose>
          </a>
          <xsl:if test="position()!=last()">, </xsl:if>
        </xsl:for-each>
        <xsl:text>) </xsl:text>
      </span>
    </xsl:if>
    <!--
		<xsl:for-each select="dc:date[not(@xml:lang) or contains(@xml:lang , $xml:lang)]">
			<xsl:choose>
				<xsl:when test="position()=last()">
					<xsl:text> &#160; </xsl:text>
					<xsl:apply-templates select="."/>
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</xsl:for-each>
		-->
  </xsl:template>
  <!-- get description 
	
	-->
  <xsl:template match="rdf:Description" name="description" mode="description">
    <xsl:param name="length" select="10000"/>
    <xsl:param name="xml:lang">
      <xsl:call-template name="dc:lang"/>
    </xsl:param>
    <xsl:if test="normalize-space(rss:description)!='' or normalize-space(dc:description)!=''">
      <!--
			<xsl:apply-templates select="dc:subject[not(@xml:lang) or contains(@xml:lang , $xml:lang)][1]"/>
-->
      <xsl:variable name="text">
        <xsl:choose>
          <xsl:when test="dc:description[contains(@xml:lang , $xml:lang)]">
            <xsl:apply-templates select="dc:description[contains(@xml:lang , $xml:lang)]"/>
          </xsl:when>
          <xsl:when test="dc:description[not(@xml:lang)]">
            <xsl:apply-templates select="dc:description[not(@xml:lang)]"/>
          </xsl:when>
          <xsl:when test="dc:description">
            <xsl:apply-templates select="dc:description"/>
          </xsl:when>
          <xsl:when test="rss:description">
            <xsl:apply-templates select="rss:description"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="substring($text, 1, $length)"/>
      <xsl:value-of select="substring-before(substring($text, $length), ' ' )"/>
      <!-- link see more -->
      <xsl:if test="$length &lt;= string-length($text)">
        <xsl:text> [</xsl:text>
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="rdf:about"/>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="dc:format[@xml:lang and contains(@xml:lang, $xml:lang)][contains(., 'p.')]">
              <xsl:apply-templates select="dc:format[@xml:lang and contains(@xml:lang, $xml:lang)][contains(., 'p.')]" mode="pages"/>
              <xsl:text>&#160;p.</xsl:text>
            </xsl:when>
            <xsl:when test="dc:format[not(@xml:lang)][contains(., 'p.')]">
              <xsl:apply-templates select="dc:format[not(@xml:lang)][contains(., 'p.')]" mode="pages"/>
              <xsl:text>&#160;p.</xsl:text>
            </xsl:when>
            <xsl:otherwise>...</xsl:otherwise>
          </xsl:choose>
        </a>
        <xsl:text>] </xsl:text>
      </xsl:if>
      <!-- if other not included metas ? used for directories -->
    </xsl:if>
  </xsl:template>
  <!-- dates supposed to be ISO formatted -->
  <xsl:template match="dc:date">
    <span class="date">
      <xsl:value-of select="substring(., 1, 4)"/>
    </span>
    <!--
		<xsl:call-template name="dt:format-date-time">
			<xsl:with-param name="date" select="."/>
		</xsl:call-template>
		<xsl:text>. </xsl:text>
-->
  </xsl:template>
  <xsl:template match="dc:format">
    <span class="format">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="dc:subject">
    <span>
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="contains(@xsi:type, 'keyword')">keyword</xsl:when>
          <xsl:otherwise>subject</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="dc:*">
    <span class="{local-name()}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <!-- a description with a link see more -->
  <xsl:template match="dc:description">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- find number of pages from a dc:format element -->
  <xsl:template match="dc:format" mode="pages">
    <xsl:choose>
      <xsl:when test="contains(., 'p.')">
        <!-- last token may be the number of pages -->
        <xsl:call-template name="getLastToken">
          <xsl:with-param name="string" select="substring-before(., 'p.')"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- centralise ? -->
  <xsl:template name="getLastToken">
    <xsl:param name="string"/>
    <xsl:choose>
      <xsl:when test="substring-after(normalize-space($string), ' ') != ''">
        <xsl:call-template name="getLastToken">
          <xsl:with-param name="string" select="substring-after(normalize-space($string), ' ')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($string)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- 	get the best url for the resource in this rdf:Description record -->
  <xsl:template name="rdf:about">
    <xsl:variable name="uri">
      <xsl:choose>
        <xsl:when test="dc:*[local-name()= 'source' or local-name()= 'relation'][contains(@xml:lang, substring($lang, 1, 2)) and @xsi:type='text/html']">
          <xsl:value-of select="dc:*[local-name()= 'source' or local-name()= 'relation'][contains(@xml:lang, substring($lang, 1, 2)) and @xsi:type='text/html']"/>
        </xsl:when>
        <xsl:when test="dc:*[local-name()= 'source' or local-name()= 'relation'][@xsi:type='text/html']">
          <xsl:value-of select="dc:*[local-name()= 'source' or local-name()= 'relation'][@xsi:type='text/html']"/>
        </xsl:when>
        <xsl:when test="dc:*[local-name()= 'source' or local-name()= 'relation'][contains(@xsi:type, 'image')]">
          <xsl:value-of select="dc:*[local-name()= 'source' or local-name()= 'relation'][contains(@xsi:type, 'image')]"/>
        </xsl:when>
        <xsl:when test="dc:identifier">
          <xsl:value-of select="dc:identifier"/>
        </xsl:when>
        <xsl:when test="dc:relation">
          <xsl:value-of select="dc:relation"/>
        </xsl:when>
        <xsl:otherwise> Bug </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="getRelative">
      <xsl:with-param name="from" select="./ancestor::rdf:RDF/@rdf:about"/>
      <xsl:with-param name="to" select="$uri"/>
    </xsl:call-template>
  </xsl:template>
  <!--
	this template work on links in dc:relation and dc:source
	in case of absolute links to write relative
	-->
  <!--
  <xsl:template match="dc:relation | dc:source" name="link" mode="link">
    <xsl:param name="path" select="."/>
    <xsl:choose>
      <xsl:when test="starts-with($path, $domain)">
        <xsl:value-of select="substring-after($path, $domain)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
-->
  <!-- a specific template to have filename or directory if filename is index
	used to have relative link for menu navigation
	context is an rdf:Description with multiple absolute links on formats or langs
	 -->
</xsl:stylesheet>
