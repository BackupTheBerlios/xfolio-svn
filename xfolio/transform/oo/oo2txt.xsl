<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:transform [
  <!ENTITY majs "ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöùúûüýÿþ .()/\">
  <!ENTITY mins "abcdefghijklmnopqrstuvwxyzaaaaaaaeeeeiiiidnooooouuuuybbaaaaaaaceeeeiiiionooooouuuuyyb------">
]>
<!--
 - GNU Lesser General Public License Version 2.1
 - Sun Industry Standards Source License Version 1.1
The Initial Developer of the Original Code is: Sun Microsystems, Inc.
Copyright: 2000 by Sun Microsystems, Inc.
All Rights Reserved.
(c) 2003, ajlsm.com ; 2004, ajlsm.com, xfolio.org

2003-02-17
FG:frederic.glorieux@xfolio.org;

	goal
provide a  text version of an oo XML, 
displayable in a mail, and compatible with common wiki.

	usage
All style classes handle in this xsl are standard openOffice. To
define specific styles to handle, best is import this xsl. If possible, 
modify only for better rendering of standard oo.

	history

FG:2004-06-11 Start for text
FG:2003-11-12 This work is continued, in the xhtml 
FG:2003-02-12 The original xsl was designed for docbook.

	bugs
teletype style is not handled
what to do with placeholder and definition styles ?
the $props of inline template have strange behavior

	todo
tables, links
Automatic toc ?

  -->
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:style="http://openoffice.org/2000/style" xmlns:text="http://openoffice.org/2000/text" xmlns:office="http://openoffice.org/2000/office" xmlns:table="http://openoffice.org/2000/table" xmlns:draw="http://openoffice.org/2000/drawing" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="http://openoffice.org/2000/meta" xmlns:number="http://openoffice.org/2000/datastyle" xmlns:svg="http://www.w3.org/2000/svg" xmlns:chart="http://openoffice.org/2000/chart" xmlns:dr3d="http://openoffice.org/2000/dr3d" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="http://openoffice.org/2000/form" xmlns:script="http://openoffice.org/2000/script" xmlns:config="http://openoffice.org/2001/config" office:class="text" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="http://apache.org/cocoon/i18n/2.1" exclude-result-prefixes="office meta  table number dc fo xlink chart math script xsl draw svg dr3d form config text style i18n">
  <!-- text version -->
  <xsl:output method="text"/>
  <!-- encoding, default is the one specified in xsl:output -->
  <xsl:param name="encoding" select="document('')/*/xsl:output/@encoding"/>
  <!-- keep root node -->
  <xsl:variable name="root" select="/"/>
  <!--

  root template for an oo the document

-->
  <xsl:template match="/">
    <xsl:apply-templates select="// office:body"/>
    <xsl:if test=".//text:footnote">
      <xsl:text>

----

</xsl:text>
      <xsl:apply-templates select="//office:body" mode="foot"/>
    </xsl:if>
  </xsl:template>
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
    <xsl:text>

!</xsl:text>
    <!-- add some title level -->
    <xsl:value-of select="substring('!!!!', 1, 3-@text:level)"/>
    <xsl:text> </xsl:text>
    <!-- indent ? -->
    <!--
    <xsl:value-of select="substring('   ', 1, @text:level)"/>
    <xsl:value-of select="substring('                            ', 1, (@text:level - 1)*2)"/>
-->
    <!-- 
show numbering ? may be bad idea to get back text
add some indent ?
          <xsl:copy-of select="$number"/>
    -->
    <xsl:apply-templates/>
    <!-- just a space -->
    <xsl:text>
</xsl:text>
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
    <!-- store the block in a variable to wrap it after inline process -->
    <xsl:variable name="text">
      <xsl:choose>
        <!--  empty block -->
        <xsl:when test="normalize-space(.)='' and not(*[name()!='text:change'])"/>
        <xsl:when test="$style='standard' or $style='text-body'">
          <xsl:text>
</xsl:text>
          <xsl:apply-templates/>
          <xsl:text>
</xsl:text>
        </xsl:when>
        <xsl:when test="$style='first-line-indent'">
          <xsl:text>

    </xsl:text>
          <xsl:apply-templates/>
          <xsl:text>
</xsl:text>
        </xsl:when>
        <!-- handling of fields -->
        <xsl:when test="(text:title or $style='title') and normalize-space(.)!=''">
          <xsl:text>
!!! </xsl:text>
          <xsl:apply-templates/>
          <xsl:if test="$next != 'subtitle'">
----
          </xsl:if>
        </xsl:when>
        <xsl:when test="($style='subtitle' or text:subject) and normalize-space(.)!=''">
          <xsl:text>
!!!'' </xsl:text>
          <xsl:apply-templates/>
          <xsl:text> ''
----
</xsl:text>
        </xsl:when>
        <!-- Definition list -->
        <xsl:when test="$style='list-heading' or $style='dt'">
          <xsl:if test="$prev!='list-heading' and $prev!='dt'">
            <xsl:text>
;</xsl:text>
          </xsl:if>
          <xsl:apply-templates/>
          <xsl:choose>
            <xsl:when test="$next ='list-heading' or $next='dt'"> \\ </xsl:when>
            <xsl:otherwise> : </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$style = 'list-contents' or $style = 'dd'">
          <xsl:apply-templates/>
          <xsl:choose>
            <xsl:when test="$next = 'list-contents' or $next = 'dd'"> \\ </xsl:when>
            <xsl:otherwise>
</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <!-- abstract -->
        <xsl:when test="text:description or $style='abstract'">
          <xsl:if test="not ($prev='abstract')">
            <xsl:text>
|</xsl:text>
          </xsl:if>
          <xsl:if test="$prev='abstract'">
            <xsl:text>\\ </xsl:text>
          </xsl:if>
          <xsl:apply-templates/>
          <xsl:if test="not ($next='abstract')">
            <xsl:text>
</xsl:text>
          </xsl:if>
        </xsl:when>
        <!-- indent ? -->
        <xsl:when test="$style='quotations'">
          <xsl:apply-templates/>
        </xsl:when>
        <xsl:when test="$style='preformatted-text'">
          <xsl:text>

{{{
</xsl:text>
          <xsl:apply-templates/>
          <xsl:text>
}}}

</xsl:text>
        </xsl:when>
        <xsl:when test="$style='horizontal-line'">
          <xsl:text>

----

</xsl:text>
        </xsl:when>
        <xsl:when test="$style='comment'">
          <xsl:text>

;:''</xsl:text>
          <xsl:apply-templates/>
          <xsl:text>''

</xsl:text>
        </xsl:when>
        <!-- ??? addressee, sender, salutation, signature -->
        <xsl:otherwise>
          <xsl:text>
</xsl:text>
          <xsl:apply-templates/>
          <xsl:text>
</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$text"/>
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
  <!--
 table 


-->
  <xsl:template match="table:table">
    <table class="table">
      <xsl:attribute name="id"><xsl:value-of select="@table:name"/></xsl:attribute>
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
        <xsl:attribute name="colnum"><xsl:value-of select="$left"/></xsl:attribute>
        <xsl:attribute name="colname">c
                    <xsl:value-of select="$left"/></xsl:attribute>
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
  <!-- 

lists 

-->
  <xsl:template match="text:ordered-list">
    <xsl:apply-templates/>
    <!-- workaround for bad oo XML output -->
    <xsl:if test="not(following-sibling::text:ordered-list)">
      <xsl:text>
</xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template match="text:unordered-list">
    <xsl:apply-templates/>
    <!-- workaround for bad oo XML output -->
    <xsl:if test="not(following-sibling::text:unordered-list)">
      <xsl:text>
</xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template match="text:list-item">
    <xsl:text>
</xsl:text>
    <xsl:for-each select="ancestor::text:ordered-list">
      <xsl:text>#</xsl:text>
    </xsl:for-each>
    <xsl:for-each select="ancestor::text:unordered-list">
      <xsl:text>*</xsl:text>
    </xsl:for-each>
    <xsl:text> </xsl:text>
    <!-- ?? is it the best for formatting ?? -->
    <xsl:variable name="text">
      <xsl:apply-templates select="*[not(contains(local-name(), 'list'))]"/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($text)"/>
    <!-- process nested list-item -->
    <xsl:apply-templates select="*[contains(local-name(), 'list')]"/>
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
  <!-- 

handle inline, and give an html form to each default style 

-->
  <xsl:template match="text:span">
    <xsl:variable name="style-att" select="@text:style-name"/>
    <xsl:variable name="style">
      <xsl:choose>
        <xsl:when test="starts-with($style-att, 'T')">
          <xsl:value-of select="/office:document/office:automatic-styles/style:style[@style:name=$style-att]/@style:parent-style-name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate($style-att, '&majs;', '&mins;')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- get bold and other CSS properties from automatic style -->
    <xsl:variable name="props" select="//style:style[@style:name=$style-att]"/>
    <xsl:choose>
      <!-- handle empty nodes to avoid strange behavior of browsers on xhtml -->
      <xsl:when test="normalize-space(.)='' and not(*)"/>
      <xsl:when test="$style='emphasis'">
        <xsl:text>''</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>''</xsl:text>
      </xsl:when>
      <!-- Change Made By Kevin Fowlks (fowlks@msu.edu) June 16th, 2003 -->
      <xsl:when test="$style='citation'">
        <xsl:text>''</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>''</xsl:text>
      </xsl:when>
      <!-- ??
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
-->
      <xsl:when test="$style='example'">
        <xsl:text>{{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}}</xsl:text>
      </xsl:when>
      <xsl:when test="$style='teletype'">
        <xsl:text>{{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}}</xsl:text>
      </xsl:when>
      <xsl:when test="$style='user-entry'">
        <xsl:text>{{''</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>''}}</xsl:text>
      </xsl:when>
      <xsl:when test="$style='source-text'">
        <xsl:text>{{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}}</xsl:text>
      </xsl:when>
      <xsl:when test="$style='definition'">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$style='placeholder'">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$style='emphasis-bold'">
        <xsl:text>__</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>__</xsl:text>
      </xsl:when>
      <xsl:when test="$props">
        <xsl:choose>
          <xsl:when test="$props/style:properties/@fo:font-weight = 'bold'
and $props/style:properties/@fo:font-style='italic'">
            <xsl:text>__''</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>''__</xsl:text>
          </xsl:when>
          <xsl:when test="$props/style:properties/@fo:font-weight = 'bold'">
            <xsl:text>__</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>__</xsl:text>
          </xsl:when>
          <xsl:when test="$props/style:properties/@fo:font-style='italic'">
            <xsl:text>''</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>''</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
          <!--
          <xsl:when test="$props/style:properties/@style:text-underline">
              <xsl:apply-templates/>
          </xsl:when>
-->
        </xsl:choose>
      </xsl:when>
      <!-- FG:2004-06-10, never used, why ? -->
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- line break -->
  <xsl:template match="text:line-break">
    <xsl:text> \\ </xsl:text>
  </xsl:template>
  <xsl:template match="text:tab-stop">
    <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
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
    <xsl:text>

;:''</xsl:text>
    <xsl:apply-templates select="."/>
    <xsl:text>''

</xsl:text>
  </xsl:template>
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
				between automatic styles with footer, fast patch here -->
        <xsl:value-of select="
translate(//office:automatic-styles/style:style[@style:name = $current][@style:parent-style-name!='Footer']/@style:parent-style-name
, '&majs;', '&mins;')
"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="translate($current , '&majs;', '&mins;')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
	 links - may be to handle for redirections 
-->
  <xsl:template match="text:a | draw:a" name="a">
    <a>
      <xsl:attribute name="href"><xsl:apply-templates select="@xlink:href"/></xsl:attribute>
      <xsl:attribute name="class"><xsl:apply-templates select="@text:style-name | @draw:style-name | @draw:text-style-name"/></xsl:attribute>
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
    <xsl:text>[</xsl:text>
    <xsl:value-of select="text:footnote-citation"/>
    <xsl:text>]</xsl:text>
  </xsl:template>
  <!-- default, pass it -->
  <xsl:template match="*" mode="foot">
    <xsl:apply-templates mode="foot"/>
  </xsl:template>
  <!-- write nothing -->
  <xsl:template match="text()" mode="foot"/>
  <xsl:template match="text:footnote" mode="foot">
    <xsl:text>

[#</xsl:text>
    <xsl:value-of select="text:footnote-citation"/>
    <xsl:text>] </xsl:text>
    <xsl:apply-templates select="text:footnote-body"/>
  </xsl:template>
  <!-- first para of a footnote -->
  <xsl:template match="text:footnote-body/text:p[1]">
    <xsl:apply-templates/>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <!--
images
[alternate text|http://example.com/example.png]
image works only for absolute links
-->
  <xsl:template match="draw:image">
    <xsl:choose>
      <xsl:when test="starts-with(@xlink:href, 'http://')">
        <xsl:text>[</xsl:text>
        <!-- alternate text -->
        <xsl:choose>
          <xsl:when test="normalize-space(svg:desc) != ''">
            <xsl:value-of select="svg:desc"/>
            <xsl:text>|</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(@draw:name) != ''">
            <xsl:value-of select="@draw:name"/>
            <xsl:text>|</xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:value-of select="@xlink:href"/>
        <xsl:text>]</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- 
	template to resolve internal image links 

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
  <!--

a text word wrap

-->
  <xsl:template name="wrap">
    <xsl:param name="text" select="."/>
    <!-- factorize as sheet param ? -->
    <xsl:param name="width" select="72"/>
    <!-- index for breaking space -->
    <xsl:param name="i" select="$width"/>
    <xsl:choose>
      <!-- last line -->
      <xsl:when test="string-length($text) &lt;= $width">
        <xsl:value-of select="$text"/>
      </xsl:when>
      <!-- longer than one line, cut after -->
      <xsl:when test="not(contains(substring($text, 1, $i), ' '))">
        <xsl:call-template name="wrap">
          <xsl:with-param name="i" select="$i+1"/>
          <xsl:with-param name="text" select="$text"/>
        </xsl:call-template>
      </xsl:when>
      <!-- not on the break space, cut before -->
      <xsl:when test="substring($text, $i, 1) != ' '">
        <xsl:call-template name="wrap">
          <xsl:with-param name="i" select="$i - 1"/>
          <xsl:with-param name="text" select="$text"/>
        </xsl:call-template>
      </xsl:when>
      <!-- should be on a break space -->
      <xsl:when test="substring($text, $i, 1) = ' '">
        <xsl:value-of select="substring($text, 1, $i)"/>
        <xsl:text>
</xsl:text>
        <xsl:call-template name="wrap">
          <xsl:with-param name="text" select="substring($text, $i+1)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- should never arrive -->
      <xsl:otherwise>
        <xsl:text> ??? </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
