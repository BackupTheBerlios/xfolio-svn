<?xml version="1.0" encoding="UTF-8"?>
<!--
 #         - GNU Lesser General Public License Version 2.1
 #         - Sun Industry Standards Source License Version 1.1
 #  Copyright: 2000 by Sun Microsystems, Inc.
 #  All Rights Reserved.
 #  The Initial Developer of the Original Code is: Sun Microsystems, Inc.

I'm not sure there's a lot of lines from the original code, but I start on it
2004-O1-27 
FG:frederic.glorieux@xfolio.org


goal:
  provide the best set of Dublin Core properties from an Openoffice
  writer document.

usage:
  The root template produce an RDF document with the DC properties
	Single DC properties may be accessed by global xsl:param
  A template "metas" give an HTML version of this properties.
  This template may be externalize in a specific rdf2meta ?

history:
  2004-06-28:FG better linking resolving
  The metas could be used separated for other usages.
  These transformation was extracted from a global oo2html

todo:
  
	may be used for other target namespace DC compatible
  what about a default properties document ?
	format in arabic

bugs:
  seems to bug with xalan under cocoon in creator template
  
documentation:
	http://www.w3.org/TR/xhtml2/abstraction.html#dt_MediaDesc

-->
<xsl:transform version="1.1" xmlns:style="http://openoffice.org/2000/style" xmlns:text="http://openoffice.org/2000/text" xmlns:office="http://openoffice.org/2000/office" xmlns:table="http://openoffice.org/2000/table" xmlns:draw="http://openoffice.org/2000/drawing" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="http://openoffice.org/2000/meta" xmlns:number="http://openoffice.org/2000/datastyle" xmlns:svg="http://www.w3.org/2000/svg" xmlns:chart="http://openoffice.org/2000/chart" xmlns:dr3d="http://openoffice.org/2000/dr3d" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="http://openoffice.org/2000/form" xmlns:script="http://openoffice.org/2000/script" xmlns:config="http://openoffice.org/2001/config" office:class="text" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dir="http://apache.org/cocoon/directory/2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" exclude-result-prefixes="office meta  table number fo xlink chart math script xsl draw svg dr3d form config text style dir">
  <xsl:import href="../xfolio/naming.xsl"/>
  <!-- used to resolve links for images (?) -->
  <!--
  <xsl:import href="oo2html.xsl"/>
-->
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <!-- identifier for doc in all formats -->
  <xsl:param name="identifier"/>
  <!-- extensions from which a transformation is expected -->
  <xsl:param name="extensions"/>
  <!-- 
FG:2004-06-10

  language logic.
  
  DC property may be precised by an @xml:lang attribute.
  Priority order of the information
   - filename
   - meta oo

	important, don't let an empty attribute

	-->
  <xsl:param name="language">
    <xsl:if test="$identifier">
      <xsl:call-template name="getLang">
        <xsl:with-param name="path" select="$identifier"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:param>
  <xsl:param name="lang">
    <xsl:choose>
      <xsl:when test="normalize-space($language) != ''">
        <xsl:value-of select="$language"/>
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
These variables are used to normalize stle names of styles
-->
  <xsl:variable name="majs" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöùúûüýÿþ .()/\?'"/>
  <xsl:variable name="mins" select="'abcdefghijklmnopqrstuvwxyzaaaaaaaeeeeiiiidnooooouuuuybbaaaaaaaceeeeiiiionooooouuuuyyb------'"/>
  <!--


-->
  <xsl:template match="/">
    <rdf:RDF>
      <rdf:Description>
        <xsl:call-template name="dc:properties"/>
      </rdf:Description>
    </rdf:RDF>
  </xsl:template>
  <!--
	all possible dc:properties to extract
-->
  <xsl:template name="dc:properties">
    <!-- better should be done on title -->
    <xsl:variable name="title">
      <xsl:call-template name="title"/>
    </xsl:variable>
    <xsl:if test="normalize-space($title) != ''">
      <dc:title>
        <xsl:call-template name="lang"/>
        <xsl:value-of select="normalize-space($title)"/>
      </dc:title>
    </xsl:if>
    <!-- dc:creator -->
    <xsl:call-template name="creators"/>
    <!-- dc:subject -->
    <xsl:apply-templates select="//office:meta/dc:subject"/>
    <xsl:apply-templates select="//office:meta/meta:keywords"/>
    <!-- dc:description -->
    <xsl:call-template name="description"/>
    <!-- publisher ?? -->
    <!-- dates -->
    <dc:date xsi:type="created">
      <!-- lang useful to precise to which version this date is applied -->
      <xsl:call-template name="lang"/>
      <xsl:apply-templates select="//office:meta/meta:creation-date"/>
    </dc:date>
    <dc:date xsi:type="modified">
      <xsl:call-template name="lang"/>
      <xsl:apply-templates select="//office:meta/dc:date"/>
    </dc:date>
    <!-- format -->
    <dc:format>
      <xsl:call-template name="lang"/>
      <xsl:call-template name="format"/>
    </dc:format>
    <!-- server give an identifier for the doc, common to each lang and format -->
    <xsl:if test="$identifier">
      <dc:identifier>
        <xsl:call-template name="lang"/>
        <xsl:value-of select="$identifier"/>
      </dc:identifier>
    </xsl:if>
    <!-- server give the source uri of this transformation -->
    <xsl:if test="$identifier">
      <dc:source xsi:type="application/vnd.sun.xml.writer">
        <xsl:call-template name="lang"/>
        <xsl:value-of select="$identifier"/>
        <xsl:text>.sxw</xsl:text>
      </dc:source>
    </xsl:if>
    <!-- relations, server give other possible transformations for this source -->
    <xsl:call-template name="formats"/>
    <!-- links for images -->
    <xsl:for-each select="//draw:image">
      <xsl:variable name="path" select="@xlink:href"/>
      <xsl:variable name="link">
        <xsl:choose>
          <!-- rewrite internal image links -->
          <xsl:when test="contains($path, '#Pictures/')">
            <xsl:value-of select="$identifier"/>
            <xsl:text>.sxw!/</xsl:text>
            <xsl:value-of select="substring-after($path, '#')"/>
          </xsl:when>
          <xsl:when test="not(contains($path, 'http://'))">
            <xsl:call-template name="getParent">
              <xsl:with-param name="path" select="$identifier"/>
            </xsl:call-template>
            <xsl:value-of select="$path"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$path"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <dc:relation>
        <xsl:attribute name="xsi:type">
          <xsl:call-template name="getMime">
            <xsl:with-param name="path" select="$link"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:call-template name="lang"/>
        
        <xsl:value-of select="$link"/>
      </dc:relation>
    </xsl:for-each>
    <!-- copyright -->
    <xsl:if test="$copyright">
      <dc:rights>
        <xsl:call-template name="lang"/>
        <xsl:value-of select="$copyright"/>
      </dc:rights>
    </xsl:if>
  </xsl:template>
  <!--
normalize creator

This template normalize a creator string (strip mail or position)
-->
  <xsl:template name="normalizeCreators">
    <xsl:param name="string"/>
  </xsl:template>
  <!-- main subject to index -->
  <xsl:template match="dc:subject">
    <dc:subject>
      <xsl:call-template name="lang"/>
      <xsl:apply-templates/>
    </dc:subject>
  </xsl:template>
  <!-- treat comma separated subjects as different topics -->
  <xsl:template match="meta:keywords">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="meta:keyword">
    <dc:subject xsi:type="http://openoffice.org/2000/meta#keyword">
      <xsl:call-template name="lang"/>
      <xsl:apply-templates/>
    </dc:subject>
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
  <!--
	 get the best description 

FG:2004-16-18 BUG, when more than one abstract in a doc


    <xsl:variable name="description">
      <xsl:call-template name="description"/>
    </xsl:variable>
    <xsl:if test="normalize-space($description) != ''">
      <dc:description>
        <xsl:call-template name="lang"/>
        <xsl:value-of select="$description"/>
      </dc:description>
    </xsl:if>

-->
  <xsl:template name="description">
    <xsl:variable name="style" select="'abstract'"/>
    <xsl:variable name="style-modified" select="
//office:automatic-styles/style:style[@style:parent-style-name=$style]/@style:name
          "/>
    <xsl:choose>
      <xsl:when test="normalize-space(//office:meta/dc:description)!=''">
        <dc:description>
          <xsl:call-template name="lang"/>
          <xsl:value-of select="//office:meta/dc:description"/>
        </dc:description>
      </xsl:when>
      <xsl:when test="
normalize-space(
//office:document//text:*[@text:style-name=$style or @text:style-name = $style-modified]
) != ''
          ">
        <dc:description>
          <xsl:call-template name="lang"/>
          <xsl:for-each select="
//office:document//text:*
[@text:style-name=$style or @text:style-name = $style-modified]
[normalize-space(.)!='']
">
            <xsl:choose>
              <!-- toujours prendre le premier paragraphe de description -->
              <xsl:when test="position()=1">
                <xsl:value-of select="normalize-space(.)"/>
              </xsl:when>
              <!-- un autre paragraphe de description, s'il suit le premier, le mettre -->
              <xsl:when test="
position()!=1 and preceding-sibling::*[1]
[@text:style-name = $style or 
@text:style-name = $style-modified]">
                <xsl:value-of select="'
    '"/>
                <xsl:value-of select="normalize-space(.)"/>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </dc:description>
      </xsl:when>
      <xsl:otherwise>
        <!-- no description known -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--

	 get the best title 

-->
  <xsl:template name="title">
    <xsl:variable name="title">
      <xsl:call-template name="getElementsByStyle">
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
  <xsl:template name="creators">
    <!-- creators

creators handled are from style sender and sisgnature

-->
    <xsl:variable name="style" select="signature"/>
    <xsl:variable name="style-auto" select="
//office:automatic-styles/style:style[translate(@style:parent-style-name, $majs, $mins)=$style]/@style:name
          "/>
    <xsl:for-each select="//*[normalize-space(.)!=''][
   translate(@text:style-name, $majs, $mins)      = $style
or @text:style-name      = $style-auto
]">
      <dc:creator xsi:type="signature">
        <xsl:call-template name="lang"/>
        <!-- copy the first link in creator, what about link type ? -->
        <xsl:copy-of select=".//@xlink:href[1]"/>
        <!-- if complex creator key, perhaps simplify here, or elsewhere ? -->
        <xsl:variable name="creator">
          <xsl:choose>
            <xsl:when test="contains(., '&lt;')">
              <xsl:value-of select="substring-before(., '&lt;')"/>
            </xsl:when>
            <xsl:when test="contains(., '(')">
              <xsl:value-of select="substring-before(., '(')"/>
            </xsl:when>
            <xsl:when test="contains(., ';')">
              <xsl:value-of select="substring-before(., ';')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="normalize-space($creator)"/>
      </dc:creator>
    </xsl:for-each>
    <xsl:variable name="creator">
      <xsl:call-template name="creator"/>
    </xsl:variable>
    <xsl:if test="normalize-space($creator)!=''">
      <dc:creator>
        <xsl:call-template name="lang"/>
        <xsl:value-of select="$creator"/>
      </dc:creator>
    </xsl:if>
    <!--
		<xsl:variable name="contributors">
			<xsl:call-template name="getElementsByStyle">
				<xsl:with-param name="style" select="'sender'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:for-each select="$contributors/*">
			<dc:contributor xsi:type="sender">
				<xsl:call-template name="lang"/>
				<xsl:value-of select="."/>
			</dc:contributor>
		</xsl:for-each>
-->
  </xsl:template>
  <!--
TODO:2004-05-11 better integration ?
	this template get a creator from user information
-->
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
          <xsl:value-of select="//text:sender-email"/>
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
  <!--

	from a style name, normalize the name and get elements of this style

-->
  <xsl:template name="getElementsByStyle">
    <xsl:param name="style"/>
    <xsl:variable name="style-auto" select="
//office:automatic-styles/style:style[translate(@style:parent-style-name, $majs, $mins)=$style]/@style:name
          "/>
    <xsl:copy-of select="//*[normalize-space(.)!=''][
   translate(@text:style-name, $majs, $mins)      = $style
or @text:style-name      = $style-auto
or translate(@draw:style-name, $majs, $mins)      = $style
or @draw:style-name      = $style-auto
or translate(@draw:text-style-name, $majs, $mins) = $style
or @draw:text-style-name = $style-auto
or translate(@table:style-name, $majs, $mins)     = $style
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
  <!--
FG:2004-06-08
add relations to other formats

From a param provide by server of other supported export formats,
<dc:relation/> elements are generated
-->
  <xsl:template name="formats">
    <!-- normalize extensions to have always a substring-before ' ' -->
    <xsl:param name="extensions" select="concat(normalize-space($extensions), ' ')"/>
    <xsl:choose>
      <!-- no path, break here -->
      <xsl:when test="normalize-space($identifier) =''"/>
      <!-- no extensions, break here -->
      <xsl:when test="normalize-space($extensions) =''"/>
      <!-- more than one extension -->
      <xsl:otherwise>
        <xsl:variable name="extension" select="substring-before($extensions, ' ')"/>
        <xsl:variable name="mime">
          <xsl:call-template name="getMime">
            <xsl:with-param name="path" select="$extension"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="name">
          <xsl:call-template name="getName">
            <xsl:with-param name="path" select="$identifier"/>
          </xsl:call-template>
        </xsl:variable>
        <dc:relation xsi:type="{$mime}" rdf:resource="{$name}.{$extension}">
          <xsl:call-template name="lang"/>
          <!-- relation maybe relative to identifier ? -->
          <xsl:value-of select="$identifier"/>
          <xsl:text>.</xsl:text>
          <xsl:value-of select="$extension"/>
        </dc:relation>
        <xsl:call-template name="formats">
          <xsl:with-param name="extensions" select="substring-after($extensions, ' ')"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
FG: 2004-06-10

A centralized template to add @xml:lang attribute
-->
  <xsl:template name="lang">
    <xsl:if test="normalize-space($lang) != ''">
      <xsl:attribute namespace="http://www.w3.org/XML/1998/namespace" name="lang">
        <xsl:value-of select="$lang"/>
      </xsl:attribute>
    </xsl:if>
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
