<?xml version="1.0" encoding="UTF-8"?>
<!--
           - GNU Lesser General Public License Version 2.1
           - Sun Industry Standards Source License Version 1.1
    The Initial Developer of the Original Code is: Sun Microsystems, Inc.
    Copyright: 2000 by Sun Microsystems, Inc.
    All Rights Reserved.
    (c) 2003, ajlsm.com ; 2004, ajlsm.com, xfolio.org

		2003-02-17;
		frederic.glorieux@xfolio.org;

	goal:
		provide an easy and clean xhtml, handling most of the structuration that
		a word processor is able to provide.
	usage:
		All style classes handle in this xsl are standard openOffice. To
		define specific styles to handle, best is import this xsl. If possible, 
		modify only for better rendering of standard oo.
	history:
		The original xsl was designed for docbook.
		This work is continued, in the xhtml 
		syntax. Most of the comments are from the author
		to help xsl developpers to understand some tricks.
	todo:
      Mozilla compatible
      media links
      footnotes
      split on section ?
      index terms ?
  -->
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:style="http://openoffice.org/2000/style" xmlns:text="http://openoffice.org/2000/text" xmlns:office="http://openoffice.org/2000/office" xmlns:table="http://openoffice.org/2000/table" xmlns:draw="http://openoffice.org/2000/drawing" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="http://openoffice.org/2000/meta" xmlns:number="http://openoffice.org/2000/datastyle" xmlns:svg="http://www.w3.org/2000/svg" xmlns:chart="http://openoffice.org/2000/chart" xmlns:dr3d="http://openoffice.org/2000/dr3d" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="http://openoffice.org/2000/form" xmlns:script="http://openoffice.org/2000/script" xmlns:config="http://openoffice.org/2001/config" office:class="text" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="http://apache.org/cocoon/i18n/2.1" exclude-result-prefixes="office meta  table number dc fo xlink chart math script xsl draw svg dr3d form config text style i18n">
  <!-- no indent to preserve design -->
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes" encoding="UTF-8"/>
  <!-- encoding, default is the one specified in xsl:output -->
  <xsl:param name="encoding" select="document('')/*/xsl:output/@encoding"/>
  <!-- keep root node -->
  <xsl:variable name="root" select="/"/>
  <!-- ?? parameter provided by the xhtml xsl pack of sun -->
  <xsl:param name="dpi" select="120"/>
  <!-- parent URI -->
  <xsl:param name="context"/>
  <!-- css link -->
  <xsl:param name="css"/>
  <!-- validation -->
  <xsl:param name="validation"/>
  <!-- folder where to find pictures -->
  <xsl:param name="pictures" select="test"/>
  <!-- title numbering -->
  <xsl:param name="numbering" select="false()"/>
  <!-- language from outside -->
  <xsl:param name="lang"/>
  <!-- 
These variables are used to normalize names of styles
-->
  <xsl:variable name="majs" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöùúûüýÿþ .()/\?'"/>
  <xsl:variable name="mins" select="'abcdefghijklmnopqrstuvwxyzaaaaaaaeeeeiiiidnooooouuuuybbaaaaaaaceeeeiiiionooooouuuuyyb------'"/>
  <!--
  root template for an oo the document
-->
  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-type">
          <xsl:attribute name="content">
            <xsl:text>text/html; charset=</xsl:text>
            <xsl:value-of select="$encoding"/>
          </xsl:attribute>
        </meta>
        <xsl:if test="$css">
          <link rel="stylesheet" href="{$css}"/>
        </xsl:if>
        <style type="text/css">
	table.img { border:1px solid; }
				</style>
      </head>
      <!-- default js functions on body if available onload property -->
      <!-- all layout is provide on CSS to keep a completely clean HTML -->
      <body>
        <div>
        <xsl:if test="contains($lang, 'ar')">
          <xsl:attribute name="dir">rtl</xsl:attribute>
        </xsl:if>
        <a name="0">
          <xsl:comment> &#160; </xsl:comment>
        </a>
        <xsl:apply-templates select="// office:body"/>
        <xsl:if test=".//text:footnote">
          <div id="footnotes">
            <hr width="30%" align="left"/>
            <xsl:apply-templates select="//office:body" mode="foot"/>
          </div>
        </xsl:if>
        </div>
      </body>
    </html>
  </xsl:template>
  <!-- default css -->
  <xsl:template name="css"/>
  <!-- default script -->
  <xsl:template name="js"/>
  <!-- unplug handle sections, sections only on titles  -->
  <xsl:template match="text:section">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- 
2003-09-30 FG : nested sections on matched level titles it works, I will understand one day
2003-11-18 FG : don't works, drastic simplification without keys, used also to build a toc
-->
  <xsl:template match="office:body">
    <xsl:apply-templates/>
    <!-- close div section -->
    <!-- unplug under cocoon, don't work
		<xsl:variable name="max" select="text:h[position()=last()]/@text:level"/>
		<xsl:for-each select="*[position() &lt;= $max]">
			<xsl:text disable-output-escaping="yes"><![CDATA[</div>]]></xsl:text>
		</xsl:for-each>
		-->
  </xsl:template>
  <!--
	TOCs

This good logic may be tested on section
-->
  <!-- process a table of contents only if requested in the source 

Should 

	-->
  <xsl:template match="text:table-of-content">
    <xsl:apply-templates select="// office:body" mode="toc"/>
  </xsl:template>
  <xsl:template match="node()" mode="toc"/>
  <xsl:template match="office:body" mode="toc">
    <xsl:if test=".//text:h[normalize-space(.)!='']">
      <dl class="toc" id="toc">
        <!-- sections may bug -->
        <xsl:apply-templates select=".//text:h[@text:level='1'][normalize-space(.)!='']" mode="toc"/>
      </dl>
    </xsl:if>
  </xsl:template>
  <xsl:template match="text:h[normalize-space(.)='']" mode="toc"/>
  <xsl:template match="text:h" mode="toc">
    <xsl:variable name="number">
      <xsl:apply-templates select="." mode="number"/>
    </xsl:variable>
    <dt>
      <!--  -->
      <xsl:if test="$numbering">
        <xsl:value-of select="$number"/>
        <xsl:text>) </xsl:text>
      </xsl:if>
      <a href="#{$number}">
        <xsl:apply-templates/>
      </a>
    </dt>
    <xsl:variable name="level" select="number(@text:level)"/>
    <xsl:variable name="next" select="following-sibling::text:h[normalize-space(.)!=''][number(@text:level)=$level][1]"/>
    <!--
Get all following level-1 before the next level
Thanks Jenny
http://www.biglist.com/lists/xsl-list/archives/200008/msg01102.html
-->
    <xsl:choose>
      <xsl:when test="
following-sibling::text:h[normalize-space(.)!=''][number(@text:level) = $level +1]
[generate-id(following-sibling::text:h[normalize-space(.)!=''][number(@text:level) = $level][1]) = generate-id($next)]
">
        <dd>
          <dl>
            <xsl:apply-templates select="
following-sibling::text:h[normalize-space(.)!=''][number(@text:level) = $level +1]
[generate-id(following-sibling::text:h[normalize-space(.)!=''][number(@text:level) = $level][1]) = generate-id($next)]
" mode="toc"/>
          </dl>
        </dd>
      </xsl:when>
      <xsl:when test="
following-sibling::text:h[normalize-space(.)!=''][number(@text:level) = $level +1]
and not(following-sibling::text:h[normalize-space(.)!=''][number(@text:level) = $level])
">
        <dd>
          <dl>
            <xsl:apply-templates select="
following-sibling::text:h[normalize-space(.)!=''][number(@text:level) = $level +1]
" mode="toc"/>
          </dl>
        </dd>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!--
	sectionning
	-->
  <!-- should not be useful but ... -->
  <xsl:template match="text:h[normalize-space(.)='']"/>
  <xsl:template name="section" match="text:h">
    <xsl:param name="level" select="@text:level"/>
    <xsl:variable name="prev" select="preceding-sibling::text:h[1][normalize-space(.)!='']"/>
    <xsl:variable name="next" select="following-sibling::text:h[1][normalize-space(.)!='']"/>
    <!-- close previous opened section, open one -->
    <xsl:variable name="dif" select="$prev/@text:level - ./@text:level + 1"/>
    <!-- unplug, not sax compliant
		<xsl:for-each select="../*[position() &lt;= $dif]">
			<xsl:text disable-output-escaping="yes">&lt;/div&gt;</xsl:text>
		</xsl:for-each>
		<xsl:text disable-output-escaping="yes">&lt;div class="section"&gt;</xsl:text>
-->
    <xsl:variable name="number">
      <xsl:apply-templates select="." mode="number"/>
    </xsl:variable>
    <a name="{$number}" class="anchor">
      <xsl:comment>
        <xsl:value-of select="$number"/>
      </xsl:comment>
    </a>
    <xsl:element name="h{@text:level}">
      <xsl:attribute name="id">
        <xsl:value-of select="$number"/>
      </xsl:attribute>
      <xsl:if test="$numbering">
        <span class="no">
          <xsl:copy-of select="$number"/>
        </span>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
      <!-- just a space -->
      <xsl:text>&#32;</xsl:text>
      <small class="nav">
        <a title="{$prev}" class="button" rel="prev" tabindex="-1">
          <xsl:attribute name="href">
            <xsl:text>#</xsl:text>
            <xsl:variable name="prev-num">
              <xsl:apply-templates select="$prev" mode="number"/>
            </xsl:variable>
            <xsl:value-of select="$prev-num"/>
          </xsl:attribute>
          <xsl:text>&lt;</xsl:text>
        </a>
        <a class="button" rel="sup" tabindex="-2" href="#top">
          <xsl:text>^</xsl:text>
        </a>
        <a title="{$next}" class="button" rel="next" tabindex="1">
          <xsl:attribute name="href">
            <xsl:text>#</xsl:text>
            <xsl:variable name="next-num">
              <xsl:apply-templates select="$next" mode="number"/>
            </xsl:variable>
            <xsl:value-of select="$next-num"/>
          </xsl:attribute>
          <xsl:text>&gt;</xsl:text>
        </a>
      </small>
    </xsl:element>
  </xsl:template>
  <!-- entity declaration ?
  <xsl:template match="text:variable-set|text:variable-get">
    <xsl:choose>
      <xsl:when test="contains(@text:name,'entitydecl')">
        <xsl:text disable-output-escaping="yes">&amp;</xsl:text>
        <xsl:value-of select="substring-after(@text:name,'entitydecl_')"/>
        <xsl:text disable-output-escaping="yes">;</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
-->
  <!--


	 handle blocks, give them an HTML form on semantic styles 


-->
  <xsl:template match="text:p">
    <!-- get styles -->
    <xsl:variable name="prev">
      <xsl:apply-templates select="preceding-sibling::*[1]/@text:style-name"/>
    </xsl:variable>
    <xsl:variable name="style">
      <xsl:apply-templates select="@text:style-name"/>
    </xsl:variable>
    <xsl:variable name="next">
      <xsl:apply-templates select="following-sibling::*[1]/@text:style-name"/>
    </xsl:variable>
    <xsl:choose>
      <!--
FG:2004-06-17  careful when strip empty blocks, some can contain images
-->
      <!-- bad semantic practice but efficient spacer -->
      <xsl:when test="normalize-space(.)='' and not(*[name()!='text:change'])
">
        <p class="spacer"> &#160; </p>
      </xsl:when>
      <xsl:when test="$style='standard' or $style='first-line-indent' or $style='text-body' or $style='hanging-indent'">
        <p class="{$style}">
          <xsl:apply-templates/>
        </p>
      </xsl:when>
      <xsl:when test="text:title | text:subject">
        <center>
          <h1 class="{$style}">
            <xsl:apply-templates/>
          </h1>
        </center>
      </xsl:when>
      <xsl:when test="$style='title' and normalize-space(.)!=''">
        <center>
          <h1 class="{$style}">
            <xsl:apply-templates/>
          </h1>
        </center>
      </xsl:when>
      <xsl:when test="$style='subtitle'">
        <center>
          <em>
            <h1 class="subtitle">
              <xsl:apply-templates/>
            </h1>
          </em>
        </center>
      </xsl:when>
      <!-- Definition list -->
      <!-- match the first term to open the list, let level2 work on the logic -->
      <xsl:when test="
($style='list-heading' or $style='dt')
and ($prev != 'list-heading' and $prev != 'dt' and $prev != 'list-contents' and $prev != 'dd')">
        <dl>
          <xsl:apply-templates select="." mode="level2"/>
        </dl>
      </xsl:when>
      <!-- let all following definition list styles to level2 -->
      <xsl:when test="$style = 'list-heading' or $style = 'dt' or
			 $style = 'list-contents' or $style = 'dd'"/>
      <xsl:when test="$style='quotations'">
        <blockquote>
          <xsl:apply-templates/>
        </blockquote>
      </xsl:when>
      <xsl:when test="$style='preformatted-text'">
        <pre>
          <xsl:apply-templates/>
        </pre>
      </xsl:when>
      <xsl:when test="$style='person'">
        <p class="person">
          <xsl:apply-templates/>
        </p>
      </xsl:when>
      <xsl:when test="$style='horizontal-line'">
        <hr/>
      </xsl:when>
      <xsl:when test="$style='comment'">
        <xsl:comment>
          <xsl:value-of select="."/>
        </xsl:comment>
      </xsl:when>
      <xsl:otherwise>
        <div class="{$style}">
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- 

This level process nodes to be nested in the ones opened in the blocks upper,
 to restore some hierarchy. Essentially used for definition lists.

-->
  <xsl:template match="text:p" name="level2" mode="level2">
    <!-- get styles -->
    <xsl:variable name="prev">
      <xsl:apply-templates select="preceding-sibling::*[1]/@text:style-name"/>
    </xsl:variable>
    <xsl:variable name="style">
      <xsl:apply-templates select="@text:style-name"/>
    </xsl:variable>
    <xsl:variable name="next">
      <xsl:apply-templates select="following-sibling::*[1]/@text:style-name"/>
    </xsl:variable>
    <!-- choices -->
    <xsl:choose>
      <xsl:when test="
($style = 'list-heading' or $style ='dt')">
        <dt>
          <xsl:apply-templates/>
        </dt>
        <xsl:if test="
$next = 'list-heading' or $next='dt' or $next='list-contents' or $next='dd'">
          <xsl:apply-templates select="following-sibling::*[1]" mode="level2"/>
        </xsl:if>
      </xsl:when>
      <!-- on all definition list styles, continue level2 -->
      <xsl:when test="
($style = 'list-contents' or $style ='dd') 
">
        <dd>
          <xsl:apply-templates/>
        </dd>
        <xsl:if test="
$next = 'list-heading' or $next='dt' or $next='list-contents' or $next='dd'">
          <xsl:apply-templates select="following-sibling::*[1]" mode="level2"/>
        </xsl:if>
      </xsl:when>
      <!-- not yet used -->
      <xsl:otherwise>
        <div class="{$style}">
          <xsl:apply-templates/>
        </div>
        <xsl:if test="$next = $style">
          <xsl:apply-templates select="following-sibling::*[1]" mode="level2"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--

	 abstract 

-->
  <xsl:template match="text:description">
    <blockquote class="abstract">
      <xsl:apply-templates/>
    </blockquote>
  </xsl:template>
  <xsl:template match="office:script"/>
  <xsl:template match="office:settings"/>
  <xsl:template match="office:font-decls"/>
  <!-- an anchor, what about renaming anchors ? -->
  <xsl:template match="text:bookmark-start | text:bookmark">
    <a name="{@text:name}">
      <xsl:comment> &#160; </xsl:comment>
    </a>
  </xsl:template>
  <!-- not handled (is it useful for HTML ?) -->
  <xsl:template match="text:bookmark-end"/>
  <!-- whats annotation ? -->
  <xsl:template match="office:annotation/text:p">
    <note>
      <remark>
        <xsl:apply-templates/>
      </remark>
    </note>
  </xsl:template>
  <!-- table -->
  <xsl:template match="table:table">
    <table class="table">
      <xsl:attribute name="id">
        <xsl:value-of select="@table:name"/>
      </xsl:attribute>
      <xsl:call-template name="generictable"/>
    </table>
  </xsl:template>
  <xsl:template name="generictable">
    <xsl:variable name="cells" select="count(descendant::table:table-cell)"/>
    <xsl:variable name="rows">
      <xsl:value-of select="count(descendant::table:table-row) "/>
    </xsl:variable>
    <xsl:variable name="cols">
      <xsl:value-of select="$cells div $rows"/>
    </xsl:variable>
    <xsl:variable name="numcols">
      <xsl:choose>
        <xsl:when test="child::table:table-column/@table:number-columns-repeated">
          <xsl:value-of select="number(table:table-column/@table:number-columns-repeated+1)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$cols"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--
Work with colspec ?
    <xsl:element name="tgroup">
      <xsl:attribute name="cols">
        <xsl:value-of select="$numcols"/>
      </xsl:attribute>
      <xsl:call-template name="colspec">
        <xsl:with-param name="left" select="1"/>
      </xsl:call-template>
    </xsl:element>
-->
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template name="colspec">
    <xsl:param name="left"/>
    <xsl:if test="number($left &lt; ( table:table-column/@table:number-columns-repeated +2)  )">
      <xsl:element name="colspec">
        <xsl:attribute name="colnum">
          <xsl:value-of select="$left"/>
        </xsl:attribute>
        <xsl:attribute name="colname">c
                    <xsl:value-of select="$left"/>
        </xsl:attribute>
      </xsl:element>
      <xsl:call-template name="colspec">
        <xsl:with-param name="left" select="$left+1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match="table:table-column">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="table:table-header-rows">
    <thead>
      <xsl:apply-templates/>
    </thead>
  </xsl:template>
  <xsl:template match="table:table-header-rows/table:table-row">
    <tr>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>
  <!-- bad xsl example but good XML practice,
  if thead, then put rows in tgroup
  -->
  <xsl:template match="table:table/table:table-row">
    <tr>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>
  <xsl:template match="table:table-cell">
    <xsl:variable name="element">
      <xsl:choose>
        <xsl:when test="text:p/@text:style-name='Table Heading'">th</xsl:when>
        <xsl:otherwise>td</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$element}">
      <!-- ???
      <xsl:if test="@table:number-columns-spanned &gt; 1">
        <xsl:attribute name="namest">
          <xsl:value-of select="concat('c',count(preceding-sibling::table:table-cell[not(@table:number-columns-spanned)]) +sum(preceding-sibling::table:table-cell/@table:number-columns-spanned)+1)"/>
        </xsl:attribute>
        <xsl:attribute name="nameend">
          <xsl:value-of select="concat('c',count(preceding-sibling::table:table-cell[not(@table:number-columns-spanned)]) +sum(preceding-sibling::table:table-cell/@table:number-columns-spanned)+ @table:number-columns-spanned)"/>
        </xsl:attribute>
      </xsl:if>
    -->
      <xsl:choose>
        <!-- if more than one block, process them -->
        <xsl:when test="*[2]">
          <xsl:apply-templates/>
        </xsl:when>
        <!-- if only one block, put value directly (without block declarations) -->
        <xsl:otherwise>
          <xsl:apply-templates select="*/node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  <!-- lists -->
  <xsl:template match="text:ordered-list">
    <ol>
      <xsl:apply-templates/>
    </ol>
  </xsl:template>
  <xsl:template match="text:unordered-list">
    <ul>
      <xsl:apply-templates/>
    </ul>
  </xsl:template>
  <xsl:template match="text:list-item">
    <li>
      <xsl:choose>
        <xsl:when test="count(*)=1">
          <xsl:apply-templates select="*/node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </li>
  </xsl:template>
  <!--
  
  TODO media links
  
  
  -->
  <!-- do something with those frames ? -->
  <xsl:template match="draw:*">
    <div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!-- handle inline, and give an html form to each default style -->
  <xsl:template match="text:span">
    <xsl:variable name="style-att" select="@text:style-name"/>
    <xsl:variable name="style">
      <xsl:choose>
        <xsl:when test="starts-with($style-att, 'T')">
          <xsl:value-of select="/office:document/office:automatic-styles/style:style[@style:name=$style-att]/@style:parent-style-name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate($style-att, $majs, $mins)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- get bold and other CSS properties from automatic style -->
    <xsl:variable name="props" select="//style:style[@style:name=$style-att]"/>
    <xsl:choose>
      <!-- handle empty nodes to avoid strange behavior of browsers on xhtml -->
      <xsl:when test="normalize-space(.)='' and not(*)"/>
      <xsl:when test="$style='emphasis'">
        <em>
          <xsl:apply-templates/>
        </em>
      </xsl:when>
      <!-- Change Made By Kevin Fowlks (fowlks@msu.edu) June 16th, 2003 -->
      <xsl:when test="$style='citation'">
        <cite>
          <xsl:apply-templates/>
        </cite>
      </xsl:when>
      <xsl:when test="$style='sub'">
        <sub>
          <xsl:apply-templates/>
        </sub>
      </xsl:when>
      <xsl:when test="$style='sup'">
        <sup>
          <xsl:apply-templates/>
        </sup>
      </xsl:when>
      <xsl:when test="$style='example'">
        <samp>
          <xsl:apply-templates/>
        </samp>
      </xsl:when>
      <xsl:when test="$style='teletype'">
        <tt>
          <xsl:apply-templates/>
        </tt>
      </xsl:when>
      <xsl:when test="$style='source-text'">
        <code>
          <xsl:apply-templates/>
        </code>
      </xsl:when>
      <xsl:when test="$style='definition'">
        <dfn>
          <xsl:apply-templates/>
        </dfn>
      </xsl:when>
      <xsl:when test="$style='emphasis-bold'">
        <strong>
          <xsl:apply-templates/>
        </strong>
      </xsl:when>
      <xsl:when test="$props">
        <xsl:choose>
          <xsl:when test="$props/style:properties/@fo:font-weight = 'bold'">
            <b>
              <xsl:apply-templates/>
            </b>
          </xsl:when>
          <xsl:when test="$props/style:properties/@fo:font-style='italic'">
            <i>
              <xsl:apply-templates/>
            </i>
          </xsl:when>
          <xsl:when test="$props/style:properties/@style:text-underline">
            <u>
              <xsl:apply-templates/>
            </u>
          </xsl:when>
          <xsl:when test="$style=''">
            <xsl:apply-templates/>
          </xsl:when>
          <xsl:otherwise>
            <span class="{$style}">
              <xsl:apply-templates/>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$style=''">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <span class="{$style}">
          <xsl:apply-templates/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="text:line-break">
    <br/>
  </xsl:template>
  <xsl:template match="text:tab-stop">
    <span class="tab">&#160;&#160;&#160;&#160;</span>
  </xsl:template>
  <xsl:template match="text:expression">
    <span class="expression" title="{@text:formula}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="text:drop-down">
    <span class="{@text:name}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="text:text-input">
    <span class="{@text:description}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <!--    
        <text:h text:level="1">Part One Title
            <text:reference-mark-start text:name="part"/>
            <text:p text:style-name="Text body">
                <text:span text:style-name="XrefLabel">xreflabel_part</text:span>
            </text:p>
            <text:reference-mark-end text:name="part"/>
        </text:h>
-->
  <!--<xsl:template match="text:p/text:span[@text:style-name = 'XrefLabel']"/>-->
  <xsl:template match="text:reference-mark-start"/>
  <xsl:template match="text:reference-mark-end"/>
  <xsl:template match="comment">
    <xsl:comment>
      <xsl:value-of select="."/>
    </xsl:comment>
  </xsl:template>
  <!--
TODO : find good HTML form for indexation terms
	<xsl:template match="text:alphabetical-index-mark-start">
		<xsl:element name="indexterm">
			<xsl:attribute name="class">
				<xsl:text disable-output-escaping="yes">startofrange</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="id">
				<xsl:value-of select="@text:id"/>
			</xsl:attribute>

			<xsl:element name="primary">
				<xsl:value-of select="@text:key1"/>
			</xsl:element>

			<xsl:if test="@text:key2">
				<xsl:element name="secondary">
					<xsl:value-of select="@text:key2"/>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	<xsl:template match="text:alphabetical-index-mark-end">
		<xsl:element name="indexterm">
			<xsl:attribute name="startref">
				<xsl:value-of select="@text:id"/>
			</xsl:attribute>
			<xsl:attribute name="class">
				<xsl:text disable-output-escaping="yes">endofrange</xsl:text>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>
	<xsl:template match="text:alphabetical-index">
		<xsl:element name="index">
			<xsl:element name="title">
				<xsl:value-of select="text:index-body/text:index-title/text:p"/>
			</xsl:element>
			<xsl:apply-templates select="text:index-body"/>
		</xsl:element>

	</xsl:template>
	<xsl:template match="text:index-body">

		<xsl:for-each select="text:p[@text:style-name = 'Index 1']">
			<xsl:element name="indexentry">
				<xsl:element name="primaryie">
					<xsl:value-of select="."/>
				</xsl:element>
				<xsl:if test="key('secondary_children', generate-id())">
					<xsl:element name="secondaryie">
						<xsl:value-of select="key('secondary_children', generate-id())"/>
					</xsl:element>
				</xsl:if>
			</xsl:element>
		</xsl:for-each>

	</xsl:template>
-->
  <!--
    default matching
     -->
  <xsl:template match="office:styles | office:master-styles | office:automatic-styles"/>
  <!-- ??
  <xsl:template match="office:styles">
    <xsl:apply-templates/>
  </xsl:template>
-->
  <!-- default handling of unknown tags for debug
  <xsl:template match="*">
    <xsl:comment>
      <xsl:apply-templates select="." mode="path"/>
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:comment>
  </xsl:template>
  -->
  <xsl:template match="*" mode="path">
    <xsl:param name="current" select="."/>
    <xsl:for-each select="$current/ancestor-or-self::*">
      <xsl:text>/</xsl:text>
      <xsl:variable name="name" select="name()"/>
      <xsl:value-of select="$name"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="count(preceding-sibling::*[name()=$name])+1"/>
      <xsl:text>]</xsl:text>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="debug">
    <xsl:param name="current" select="/"/>
    <xsl:text disable-output-escaping="yes">&lt;!-- </xsl:text>
    <xsl:apply-templates select="$current" mode="debug"/>
    <xsl:text disable-output-escaping="yes"> --&gt;</xsl:text>
  </xsl:template>
  <xsl:template match="node() | @*" mode="debug">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="debug"/>
    </xsl:copy>
  </xsl:template>
  <!--

	get a semantic style name 
	 - CSS compatible (no space, all min) 
	 - from automatic styles 

-->
  <xsl:template match="@text:style-name | @draw:style-name | @draw:text-style-name | @table:style-name">
    <xsl:variable name="current" select="."/>
    <xsl:choose>
      <xsl:when test="
//office:automatic-styles/style:style[@style:name = $current]
">
        <!-- can't understand why but sometimes there's a confusion 
				between automatic styles with footer, same for header, fast patch here -->
        <xsl:value-of select="
translate(//office:automatic-styles/style:style[@style:name = $current][@style:parent-style-name!='Header'][@style:parent-style-name!='Footer']/@style:parent-style-name
, $majs, $mins)
"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="translate($current , $majs, $mins)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
	 links - may be to handle for redirections 
-->
  <xsl:template match="text:a | draw:a" name="a">
    <a>
      <xsl:attribute name="href">
        <xsl:apply-templates select="@xlink:href"/>
      </xsl:attribute>
      <xsl:attribute name="class">
        <xsl:apply-templates select="@text:style-name | @draw:style-name | @draw:text-style-name"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  <!-- image links could be in the draw:a -->
  <!-- global redirection of links -->
  <xsl:template match="@xlink:href | @href">
    <xsl:choose>
      <xsl:when test="false()"/>
      <xsl:when test="not(contains(.,'//')) and contains(., '.sxw')">
        <xsl:value-of select="concat(substring-before(., '.sxw'), '.html')"/>
        <xsl:value-of select="substring-after(., '.sxw')"/>
      </xsl:when>
      <xsl:when test="not(contains(.,'//')) and contains(., '.doc')">
        <xsl:value-of select="concat(substring-before(., '.doc'), '.html')"/>
        <xsl:value-of select="substring-after(., '.sxw')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- get title number for anchor and links 
recursive numbering
-->
  <xsl:template match="text:h" name="count-h" mode="number">
    <xsl:param name="level" select="1"/>
    <xsl:param name="number"/>
    <!--
Really tricky to find the good counter with no hierarchy.
count all brothers 

  $start    ) try to get the parent title (if not you are at level 1)
  $position ) find a property easy to compare from outside, count of brothers before (position)
  $count    ) count brother title before to same level, but after start
-->
    <xsl:variable name="start" select="
    
preceding-sibling::text:h[@text:level=($level - 1)][normalize-space(.)!=''][1]
"/>
    <xsl:variable name="position" select="count($start/preceding-sibling::*)+1"/>
    <xsl:variable name="count">
      <xsl:choose>
        <xsl:when test="$start">
          <xsl:value-of select="count(preceding-sibling::text:h[normalize-space(.)!=''][@text:level=$level and count(preceding-sibling::*) +1 &gt;$position])
    "/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="count(preceding-sibling::text:h[@text:level=$level][normalize-space(.)!=''])
    "/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="@text:level = $level">
        <xsl:value-of select="$count + 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="parent" select="preceding-sibling::text:h[@text:level = $level][normalize-space(.)!=''][1]"/>
        <a tabindex="-1" href="#{$number}{$count}" title="{$parent}">
          <xsl:value-of select="$count"/>
        </a>
        <xsl:text>.</xsl:text>
        <xsl:call-template name="count-h">
          <xsl:with-param name="level" select="$level+1"/>
          <xsl:with-param name="number" select="concat($number, $count, '.')"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--

 Notes


-->
  <!-- footnotes -->
  <xsl:template match="text:footnote">
    <sup>
      <a href="#{@text:id}" name="_{@text:id}" class="noteref">
        <xsl:apply-templates select="text:footnote-citation"/>
      </a>
    </sup>
  </xsl:template>
  <!-- default, pass it -->
  <xsl:template match="*" mode="foot">
    <xsl:apply-templates mode="foot"/>
  </xsl:template>
  <!-- write nothing -->
  <xsl:template match="text()" mode="foot"/>
  <xsl:template match="text:footnote" mode="foot">
    <p id="{@text:id}" class="footnote">
      <xsl:apply-templates select="text:footnote-body"/>
    </p>
  </xsl:template>
  <!-- put note ref in first paragraph -->
  <xsl:template match="text:footnote-body/text:p[1]">
    <div class="Footnote">
      <a name="{../../@text:id}" href="#_{../../@text:id}">
        <xsl:apply-templates select="../../text:footnote-citation"/>
      </a>
      <xsl:text>&#160;&#160;</xsl:text>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!--


images

-->
  <xsl:template match="draw:image">
    <xsl:variable name="page-properties" select="//style:page-master/style:properties"/>
    <xsl:variable name="image-width">
      <xsl:call-template name="convert2mm">
        <xsl:with-param name="value" select="@svg:width"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="page-width">
      <xsl:call-template name="convert2mm">
        <xsl:with-param name="value" select="$page-properties/@fo:page-width"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="margin-left">
      <xsl:call-template name="convert2mm">
        <xsl:with-param name="value" select="$page-properties/@fo:margin-left"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="margin-right">
      <xsl:call-template name="convert2mm">
        <xsl:with-param name="value" select="$page-properties/@fo:margin-right"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="left">
      <xsl:call-template name="convert2mm">
        <xsl:with-param name="value" select="$page-properties/@fo:margin-left"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="right">
      <xsl:call-template name="convert2mm">
        <xsl:with-param name="value" select="$page-properties/@fo:margin-left"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="width-tmp" select="round( ( $image-width div ($page-width - $left - $right))*100)"/>
    <xsl:variable name="width">
      <xsl:choose>
        <xsl:when test="$width-tmp &gt; 100">100</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$width-tmp"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--
		<xsl:comment>
			<xsl:value-of select="$width-tmp"/>
		</xsl:comment>
-->
    <!-- 
		
	align support: left, center, right
	rule :
	if x < width/2 =>left
-->
    <xsl:variable name="x">
      <xsl:call-template name="convert2mm">
        <xsl:with-param name="value" select="@svg:x"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="x-middle" select="
(($page-width - $margin-left - $margin-right) div 2) - 
($image-width div 2)"/>
    <xsl:variable name="align">
      <xsl:choose>
        <xsl:when test="($x + $x div 2) &lt; ($x-middle)">left</xsl:when>
        <xsl:when test="($x) &gt; ($x-middle + $x-middle div 2)">right</xsl:when>
        <xsl:otherwise>center</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="size">
      <xsl:call-template name="convert2pixel">
        <xsl:with-param name="value" select="@svg:width"/>
      </xsl:call-template>
    </xsl:variable>
    <!--
		<img alt="{svg:desc}" align="{$align}">
			<xsl:attribute name="src">
				<xsl:apply-templates select="@xlink:href">
					<xsl:with-param name="size" select="$size"/>
				</xsl:apply-templates>
			</xsl:attribute>
		</img>
-->
    <!--
FG:2004-05-08
		navigation around image is now provide from layout, 
		who knows more from where to take links and rdf
		also it's common to other formats (ex:XML)

		desired size is calculate proportionnaly to the page
-->
    <img alt="{svg:desc}" align="{$align}" border="0">
      <!--
	If image is not in frame or table, a width attribute could be add
		width="{$width}%"

to be sure to have enough pixels, a width is set by pixel
-->
      <xsl:attribute name="width">
        <xsl:value-of select="$size"/>
      </xsl:attribute>
      <xsl:attribute name="src">
        <xsl:apply-templates select="@xlink:href"/>
        <xsl:text>?size=</xsl:text>
        <xsl:value-of select="$size"/>
      </xsl:attribute>
    </img>
  </xsl:template>
  <!-- 
	template to resolve internal image links 

shared with meta rdf
-->
  <xsl:template match="draw:image/@xlink:href">
    <xsl:variable name="path" select="."/>
    <xsl:choose>
      <xsl:when test="contains($path, '#Pictures/')">
        <xsl:value-of select="concat($pictures, substring-after($path, '#'))"/>
      </xsl:when>
      <xsl:when test="not(contains($path, 'http://'))">
        <xsl:value-of select="$path"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- changing measure to pixel by via parameter provided dpi (dots per inch) standard factor (cp. section comment) -->
  <xsl:template name="convert2pixel">
    <xsl:param name="value"/>
    <xsl:param name="centimeter-in-mm" select="10"/>
    <xsl:param name="inch-in-mm" select="25.4"/>
    <xsl:param name="didot-point-in-mm" select="0.376065"/>
    <xsl:param name="pica-point-in-mm" select="0.35146"/>
    <xsl:param name="pixel-in-mm" select="$inch-in-mm div $dpi"/>
    <xsl:choose>
      <xsl:when test="contains($value, 'mm')">
        <xsl:value-of select="round(number(substring-before($value, 'mm')) div $pixel-in-mm)"/>
      </xsl:when>
      <xsl:when test="contains($value, 'cm')">
        <xsl:value-of select="round(number(substring-before($value, 'cm')) div $pixel-in-mm * $centimeter-in-mm)"/>
      </xsl:when>
      <xsl:when test="contains($value, 'in')">
        <xsl:value-of select="round(number(substring-before($value, 'in')) div $pixel-in-mm * $inch-in-mm)"/>
      </xsl:when>
      <xsl:when test="contains($value, 'dpt')">
        <xsl:value-of select="round(number(substring-before($value,'dpt')) div $pixel-in-mm * $didot-point-in-mm)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- convert2mm -->
  <xsl:template name="convert2mm">
    <xsl:param name="value"/>
    <xsl:param name="centimeter-in-mm" select="10"/>
    <xsl:param name="inch-in-mm" select="25.4"/>
    <xsl:param name="didot-point-in-mm" select="0.376065"/>
    <xsl:param name="pica-point-in-mm" select="0.35146"/>
    <xsl:param name="pixel-in-mm" select="$inch-in-mm div $dpi"/>
    <xsl:choose>
      <xsl:when test="contains($value, 'mm')">
        <xsl:value-of select="substring-before($value, 'mm')"/>
      </xsl:when>
      <xsl:when test="contains($value, 'cm')">
        <xsl:value-of select="substring-before($value, 'cm') * 10"/>
      </xsl:when>
      <xsl:when test="contains($value, 'in')">
        <xsl:value-of select="round(number(substring-before($value, 'in')) div $pixel-in-mm * $inch-in-mm)"/>
      </xsl:when>
      <xsl:when test="contains($value, 'dpt')">
        <xsl:value-of select="round(number(substring-before($value,'dpt')) div $pixel-in-mm * $didot-point-in-mm)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- modifications and changes, do something ? -->
  <xsl:template match="text:tracked-changes"/>
  <xsl:template match="text:tracked-changes//*" mode="toc"/>
  <!-- forms ??? -->
  <xsl:template match="office:forms | text:sequence-decls"/>
  <!-- snippets to include
  <xsl:template match="tests" xmlns:date="xalan://java.util.Date" xmlns:encoder="xalan://java.net.URLEncoder"
     <xsl:value-of select="encoder:encode(string(test))"/>
     <xsl:value-of select="date:new()" />
  </xsl:template>
  -->
</xsl:stylesheet>
