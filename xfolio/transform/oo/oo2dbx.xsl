<?xml version="1.0" encoding="UTF-8"?>
<!-- these entities are provide to normalize style names (commpatible CSS, not Java) -->
<!DOCTYPE xsl:transform [
	<!ENTITY majs "ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöùúûüýÿþ .()/\">
	<!ENTITY mins "abcdefghijklmnopqrstuvwxyzaaaaaaaeeeeiiiidnooooouuuuybbaaaaaaaceeeeiiiionooooouuuuyyb------">
]>
<!--


 #         - GNU Lesser General Public License Version 2.1
 #         - Sun Industry Standards Source License Version 1.1
 #  Copyright: 2000 by Sun Microsystems, Inc.
 #  All Rights Reserved.
 #  The Initial Developer of the Original Code is: Sun Microsystems, Inc.

I'm not sure there's a lot of lines from the original code, but I start on it
2004-03-31 frederic.glorieux@ajlsm.com



-->
<xsl:stylesheet version="1.0" xmlns:style="http://openoffice.org/2000/style" xmlns:text="http://openoffice.org/2000/text" xmlns:office="http://openoffice.org/2000/office" xmlns:table="http://openoffice.org/2000/table" xmlns:draw="http://openoffice.org/2000/drawing" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="http://openoffice.org/2000/meta" xmlns:number="http://openoffice.org/2000/datastyle" xmlns:svg="http://www.w3.org/2000/svg" xmlns:chart="http://openoffice.org/2000/chart" xmlns:dr3d="http://openoffice.org/2000/dr3d" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="http://openoffice.org/2000/form" xmlns:script="http://openoffice.org/2000/script" xmlns:config="http://openoffice.org/2001/config" office:class="text" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="office meta  table number dc fo xlink chart math script xsl draw svg dr3d form config text style">
	<!--
let work Eric Bellot if something missing
	-->
	<xsl:import href="ooo2sdbk.xsl"/>
	<xsl:output method="xml" indent="yes"/>
	<!--
<xsl:output method="xml" indent="no" omit-xml-declaration="no"
	doctype-public="-//OASIS//DTD DocBook XML V4.1.2//EN"
	doctype-system="http://www.oasis-open.org/docbook/xml/4.0/docbookx.dtd"/>
-->
	<xsl:param name="xsl"/>
	<!--
	2003-09-30 frederic.glorieux@ajlsm.com 
	TODO: replace all the @disable-output-escaping
	
	2004-03-09 frederic.glorieux@ajlsm.com
	key system to restore hierarchy on flat title is replaced by a "apply from to"
-->
	<!--

only because imports

-->
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	<!-- -->
	<xsl:template match="/office:document">
		<!-- 2003-09-30 frederic.glorieux@ajlsm.com 
unplug DOCTYPE, let a server or a xsl:output do it
-->
		<!-- 2003-09-30 frederic.glorieux@ajlsm.com
add xsl processing instruction 
<?xml-stylesheet type="text/xsl" href="file:///C:\projets\docbook-tools\xsl\html\docbook-ajlsm.xsl"?>
-->
		<xsl:if test="$xsl">
			<xsl:processing-instruction name="xml-stylesheet">
				<xsl:text>type="text/xsl" href="</xsl:text>
				<xsl:value-of select="$xsl"/>
				<xsl:text>"</xsl:text>
			</xsl:processing-instruction>
		</xsl:if>
		<article>
			<!--
  process all nodes before the first title level one
	process all level one title to open a section and so on 
	TOTHINK, what to do with the sections of native oo ?
-->
			<xsl:attribute name="lang">
				<xsl:value-of select="//office:meta/dc:language"/>
			</xsl:attribute>
			<xsl:apply-templates select=".//office:meta"/>
			<xsl:apply-templates select=".//office:body"/>
		</article>
	</xsl:template>
	<!--

	body

-->
	<xsl:template match="office:body">
		<xsl:comment> body </xsl:comment>
		<xsl:choose>
			<!-- simple, no title, no hierarchy to reproduce -->
			<xsl:when test="not(text:h)">
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:otherwise>
				<!-- process all nodes before the first title (= same id)  -->
				<xsl:apply-templates select="
*[generate-id(following-sibling::text:h[1]) = generate-id(current()/text:h[1])]
      "/>
				<!-- bad title formaters will be sad but they may lose sections if they
have errors in their level title order (handle a 0 number ?) -->
				<xsl:apply-templates select="text:h[number(@text:level) = 1]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--

	process titles

-->
	<xsl:template match="text:h">
		<section>
			<title>
				<xsl:apply-templates/>
			</title>
			<xsl:call-template name="section"/>
		</section>
	</xsl:template>
	<!--
	generic logic to restore hierarchy from a title element
Thanks Jenny
http://www.biglist.com/lists/xsl-list/archives/200008/msg01102.html
-->
	<xsl:template name="section">
		<xsl:param name="level" select="@text:level"/>
		<!-- 1) process all nodes before the next title -->
		<xsl:variable name="next" select="following-sibling::text:h[1]"/>
		<xsl:choose>
			<xsl:when test="not($next)">
				<xsl:apply-templates select="
following-sibling::*
"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="
following-sibling::*
	[generate-id(following-sibling::text:h[1]) = generate-id($next)]
"/>
			</xsl:otherwise>
		</xsl:choose>
		<!--
	if next title is sub level, process subsections but not too far
-->
		<xsl:if test="number($next/@text:level) &gt; $level">
			<xsl:variable name="end" select="following-sibling::text:h[@text:level &lt;= $level][1]"/>
			<!-- bad hierarchy may be corrected -->
			<xsl:apply-templates select="
following-sibling::text:h[@text:level = number($next/@text:level)]
	[ generate-id(following-sibling::text:h[@text:level &lt;= $level][1]) = generate-id($end) ]
"/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="text:variable-set|text:variable-get">
		<xsl:choose>
			<xsl:when test="contains(@text:name,'entitydecl')">
				<xsl:text disable-output-escaping="yes">&amp;</xsl:text>
				<xsl:value-of select="substring-after(@text:name,'entitydecl_')"/>
				<xsl:text disable-output-escaping="yes">;</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="text:section[@text:name = 'ArticleInfo']/text:p[not(@text:style-name='XMLComment')]">
		<xsl:apply-templates/>
	</xsl:template>
	<!--
Better metas possible
	
	-->
	<xsl:template match="office:meta">
		<articleinfo>
			<xsl:apply-templates/>
		</articleinfo>
	</xsl:template>
	<xsl:template match="text:ordered-list">
		<orderedlist>
			<xsl:apply-templates/>
		</orderedlist>
	</xsl:template>
	<!--
    <xsl:template match="meta:editing-cycles"/>

    <xsl:template match="meta:user-defined"/>

    <xsl:template match="meta:editing-duration"/>

    <xsl:template match="dc:language"/>
-->
	<xsl:template match="dc:description">
		<abstract>
			<para>
				<xsl:apply-templates/>
			</para>
		</abstract>
	</xsl:template>
	<xsl:template match="dc:subject"/>
	<xsl:template match="dc:date | meta:creation-date">
		<date>
			<xsl:value-of select="substring-before(.,'T')"/>
		</date>
	</xsl:template>
	<xsl:template match="meta:initial-creator | dc:creator">
		<author>
			<xsl:apply-templates/>
		</author>
	</xsl:template>
	<xsl:template match="dc:title">
		<title>
			<xsl:apply-templates/>
		</title>
	</xsl:template>
	<xsl:template match="text:title">
		<xsl:apply-templates/>
	</xsl:template>
	<!-- notes in word processor are recorded as xml comment -->
	<xsl:template match="office:annotation">
		<xsl:comment>
			<xsl:value-of select="."/>
		</xsl:comment>
	</xsl:template>
	<!--
	2003-09-30 frederic.glorieux@ajlsm.com
	table support in a separate module
-->
	<!--

   block

To restore hierarchy among flat blocks, the idea implemented is to read a style propertie
 - process all blocks here at level1, but catch the blocks which should
   be inside another element (like a para in abstract, or a term in variablelist...)
 - the insiders elements are processed in the level2 mode, till their next
   brother should be inside something
 - more levels are needed with more hierarchy like variablelist/varlistentry/listitem/para

MAYDO : a process one by one merge with levels ? 
No, bad for performances and break the apply-templates from hierarchies upper
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
		<!-- choices -->
		<xsl:choose>
			<!-- standard -->
			<xsl:when test="$style='standard' or $style='first-line-indent'">
				<para>
					<xsl:apply-templates/>
				</para>
			</xsl:when>
			<!-- blockquote -->
			<xsl:when test="
	($style ='quotations' or $style ='blockquote')
and ($prev != 'quotations' and $prev!='blockquote')">
				<blockquote>
					<para>
						<xsl:apply-templates/>
						<xsl:if test="$next = 'quotations' or $next = 'blockquote'">
							<xsl:apply-templates select="following-sibling::*[1]" mode="level2"/>
						</xsl:if>
					</para>
				</blockquote>
			</xsl:when>
			<xsl:when test="$style ='quotations'"/>
			<!-- pre -->
			<xsl:when test="
($style='preformatted-text' or $style='literallayout')
and (true())
">
				<literallayout>
					<xsl:apply-templates/>
					<xsl:if test="$next = 'preformatted-text' or $next='literallayout'">
						<xsl:apply-templates select="following-sibling::*[1]" mode="level2"/>
					</xsl:if>
				</literallayout>
			</xsl:when>
			<!-- abstract -->
			<xsl:when test="$style='abstract' and $prev != $style">
				<abstract>
					<para>
						<xsl:apply-templates/>
					</para>
					<xsl:if test="$next = $style">
						<xsl:apply-templates select="following-sibling::*[1]" mode="level2"/>
					</xsl:if>
				</abstract>
			</xsl:when>
			<xsl:when test="$style='abstract'"/>
			<!-- marginalia -->
			<xsl:when test="$style='marginalia' and $prev != $style">
				<note>
					<para>
						<xsl:apply-templates/>
					</para>
					<xsl:if test="$next = $style">
						<xsl:apply-templates select="following-sibling::*[1]" mode="level2"/>
					</xsl:if>
				</note>
			</xsl:when>
			<xsl:when test="$style='marginalia'"/>
			<!-- abstract field -->
			<xsl:when test="text:description">
				<abstract>
					<para>
						<xsl:apply-templates/>
					</para>
				</abstract>
			</xsl:when>
			<!-- Definition list -->
			<!-- match the first term to open the list, let level2 work on the logic -->
			<xsl:when test="
($style='list-heading' or $style='dt')
and ($prev != 'list-heading' and $prev != 'dt' and $prev != 'list-contents' and $prev != 'dd')">
				<variablelist>
					<xsl:apply-templates select="." mode="level2"/>
				</variablelist>
			</xsl:when>
			<!-- let all following definition list styles to level2 -->
			<xsl:when test="$style = 'list-heading' or $style = 'dt' or $style = 'list-contents' or $style = 'dd'"/>
			<!-- titles -->
			<xsl:when test="$style='title' or $style='document-title'">
				<title>
					<xsl:apply-templates/>
				</title>
			</xsl:when>
			<xsl:when test="$style='document-subtitle' or $style='subtitle'">
				<subtitle>
					<xsl:apply-templates/>
				</subtitle>
			</xsl:when>
			<xsl:otherwise>
				<para>
					<xsl:apply-templates/>
				</para>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--
	mode="level2"
	this mode restore hierarchy for second level nodes, like paras in semantic blocks

	Careful, this is not a common xsl logic. Idea is to call that on the first element
	of a semantic sequence, and the template know when to stop or continue on the next
	element. On some specifics, a deeper level is requested.
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
			<!-- definition list 

This level should open varlistentry at the right place, 
and start to process its content with level3 template
logic to stop is in level3

-->
			<xsl:when test="
($style = 'list-heading' or $style ='dt') 
and  ($prev != 'list-heading' and $prev !='dt')">
				<varlistentry>
					<xsl:apply-templates select="." mode="level3"/>
				</varlistentry>
				<xsl:if test="
$next = 'list-heading' or $next='dt' or $next='list-contents' or $next='dd'">
					<xsl:apply-templates select="following-sibling::*[1]" mode="level2"/>
				</xsl:if>
			</xsl:when>
			<!-- on all definition list styles, continue level2 -->
			<xsl:when test="
($style = 'list-heading' or $style ='dt') 
or ($style = 'list-contents' or $style ='dd') 
">
				<xsl:if test="
$next = 'list-heading' or $next='dt' or $next='list-contents' or $next='dd'">
					<xsl:apply-templates select="following-sibling::*[1]" mode="level2"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$style='preformatted-text' or $style='literallayout'">
				<xsl:apply-templates/>
				<xsl:if test="$next = $style">
					<xsl:apply-templates select="following-sibling::*[1]" mode="level2"/>
				</xsl:if>
			</xsl:when>
			<!-- default case -->
			<xsl:otherwise>
				<para>
					<xsl:apply-templates/>
				</para>
				<xsl:if test="$next = $style">
					<xsl:apply-templates select="following-sibling::*[1]" mode="level2"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--
	mode="level3"
	this mode restore hierarchy for third level nodes, like paras in semantic blocks
-->
	<xsl:template match="text:p" name="level3" mode="level3">
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
	definition list.
	Here we should be in a <varlistentry/> from level2.
-->
			<!-- open a term, continue on other definition list styles -->
			<xsl:when test="($style = 'list-heading' or $style ='dt')">
				<term>
					<xsl:apply-templates/>
				</term>
				<xsl:if test="
$next = 'list-heading' or $next='dt' or $next='list-contents' or $next='dd'">
					<xsl:apply-templates select="following-sibling::*[1]" mode="level3"/>
				</xsl:if>
			</xsl:when>
			<!-- definition which is not the first, only a para, continue if next is a definition -->
			<xsl:when test="($style = 'list-contents' or $style ='dd')
and ($prev = 'list-contents' or $prev ='dd')
">
				<para>
					<xsl:apply-templates/>
				</para>
				<xsl:if test="$next='list-contents' or $next='dd'">
					<xsl:apply-templates select="following-sibling::*[1]" mode="level3"/>
				</xsl:if>
			</xsl:when>
			<!-- first definition, continue if next is a definition -->
			<xsl:when test="($style = 'list-contents' or $style ='dd')">
				<listitem>
					<para>
						<xsl:apply-templates/>
					</para>
					<xsl:if test="$next='list-contents' or $next='dd'">
						<xsl:apply-templates select="following-sibling::*[1]" mode="level3"/>
					</xsl:if>
				</listitem>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- 
LISTS
=====
Thanks Eric Bellot
<http://www.chez.com/ebellot/ooo2sdbk/>

-->
	<!-- Lists - UnorderedList -->
	<xsl:template match="text:unordered-list">
		<itemizedlist>
			<xsl:apply-templates/>
		</itemizedlist>
	</xsl:template>
	<!-- Lists - OrderedList -->
	<xsl:template match="text:ordered-list">
		<xsl:param name="styleName">
			<xsl:if test="ancestor-or-self::text:ordered-list[last()]/
              @text:style-name">
				<xsl:value-of select="ancestor-or-self::text:ordered-list
                    [last()]/@text:style-name"/>
			</xsl:if>
			<xsl:if test="ancestor-or-self::text:unordered-list
                  [last()]/@text:style-name">
				<xsl:value-of select="ancestor-or-self::text:unordered-list
                              [last()]/@text:style-name"/>
			</xsl:if>
		</xsl:param>
		<xsl:param name="level" select="count(ancestor-or-self::text:ordered-list) + 
                   count(ancestor-or-self::text:unordered-list)"/>
		<xsl:param name="numStyle" select="/office:document/office:automatic-styles/ 
                   text:list-style[@style:name=$styleName]/
                   text:list-level-style-number[@text:level=$level]/
                   @style:num-format"/>
		<orderedlist>
			<xsl:attribute name="continuation">
				<xsl:choose>
					<xsl:when test="@text:continue-numbering='true'">
						<xsl:text>continues</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>restarts</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="numeration">
				<xsl:choose>
					<xsl:when test="$numStyle='a'">
						<xsl:text>loweralpha</xsl:text>
					</xsl:when>
					<xsl:when test="$numStyle='A'">
						<xsl:text>upperalpha</xsl:text>
					</xsl:when>
					<xsl:when test="$numStyle='1'">
						<xsl:text>arabic</xsl:text>
					</xsl:when>
					<xsl:when test="$numStyle='i'">
						<xsl:text>lowerroman</xsl:text>
					</xsl:when>
					<xsl:when test="$numStyle='I'">
						<xsl:text>upperroman</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>arabic</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates/>
		</orderedlist>
	</xsl:template>
	<!-- Lists - Common tags -->
	<xsl:template match="text:list-item">
		<listitem>
			<xsl:apply-templates/>
		</listitem>
	</xsl:template>
	<!-- 
FOOTNOTES
=========
Thanks Eric Bellot
<http://www.chez.com/ebellot/ooo2sdbk/>

-->
	<xsl:template match="text:footnote|text:endnote">
		<footnote>
			<xsl:if test="text:footnote-citation[@text:label]">
				<xsl:attribute name="label">
					<xsl:value-of select="text:footnote-citation/@text:label"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="text:endonote-citation[@text:label]">
				<xsl:attribute name="label">
					<xsl:value-of select="text:endnote-citation/@text:label"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="id">
				<xsl:value-of select="@text:id"/>
			</xsl:attribute>
			<xsl:apply-templates select="text:footnote-body/*" mode="footnote"/>
		</footnote>
	</xsl:template>
	<xsl:template match="text:footnote-citation|text:endnote-citation"/>
	<xsl:template match="*" mode="footnote">
		<xsl:call-template name="allTags">
			<xsl:with-param name="source" select="'footnote'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="text:footnote-ref|text:endnote-ref">
		<footnoteref>
			<xsl:attribute name="linkend">
				<xsl:value-of select="@text:ref-name"/>
			</xsl:attribute>
		</footnoteref>
	</xsl:template>
	<xsl:template match="draw:text-box"/>
	<xsl:template match="draw:image">
		<xsl:choose>
			<xsl:when test="parent::text:p[@text:style-name='Mediaobject']">
				<xsl:element name="imageobject">
					<xsl:element name="imagedata">
						<xsl:attribute name="fileref">
							<xsl:value-of select="@xlink:href"/>
						</xsl:attribute>
					</xsl:element>
					<xsl:element name="caption">
						<xsl:value-of select="."/>
					</xsl:element>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="inlinegraphic">
					<xsl:attribute name="fileref">
						<xsl:value-of select="@xlink:href"/>
					</xsl:attribute>
					<xsl:attribute name="width"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--

	 handle inline, and give a form to each default style 


-->
	<xsl:template match="text:span">
		<xsl:variable name="style-att" select="@text:style-name"/>
		<xsl:variable name="style">
			<xsl:apply-templates select="@text:style-name"/>
		</xsl:variable>
		<!-- get bold and other CSS properties from automatic style -->
		<xsl:variable name="props" select="//style:style[@style:name=$style-att]"/>
		<xsl:choose>
			<!-- handle empty nodes to avoid strange behavior of browsers on xhtml -->
			<xsl:when test="normalize-space(.)='' and not(*)"/>
			<!-- default OpenOffice styles -->
			<xsl:when test="$style='emphasis'">
				<emphasis>
					<xsl:apply-templates/>
				</emphasis>
			</xsl:when>
			<xsl:when test="$style='citation'">
				<citation>
					<xsl:apply-templates/>
				</citation>
			</xsl:when>
			<xsl:when test="$style='subscript'">
				<subscript>
					<xsl:apply-templates/>
				</subscript>
			</xsl:when>
			<xsl:when test="$style='superscript'">
				<superscript>
					<xsl:apply-templates/>
				</superscript>
			</xsl:when>
			<xsl:when test="$style='example'">
				<computeroutput>
					<xsl:apply-templates/>
				</computeroutput>
			</xsl:when>
			<xsl:when test="$style='teletype'">
				<prompt>
					<xsl:apply-templates/>
				</prompt>
			</xsl:when>
			<xsl:when test="$style='source-text'">
				<literal>
					<xsl:apply-templates/>
				</literal>
			</xsl:when>
			<xsl:when test="$style='definition'">
				<varname>
					<xsl:apply-templates/>
				</varname>
			</xsl:when>
			<!--
	Which other styles to support ? Take all inline docbook element names ?
-->
			<!-- if no semantic, somme typo -->
			<xsl:when test="$props">
				<xsl:choose>
					<xsl:when test="$props/style:properties/@fo:font-weight = 'bold'">
						<emphasis role="bold">
							<xsl:apply-templates/>
						</emphasis>
					</xsl:when>
					<xsl:when test="$props/style:properties/@fo:font-style='italic'">
						<emphasis role="italic">
							<xsl:apply-templates/>
						</emphasis>
					</xsl:when>
					<xsl:when test="$props/style:properties/@style:text-underline">
						<emphasis role="u">
							<xsl:apply-templates/>
						</emphasis>
					</xsl:when>
					<xsl:otherwise>
						<emphasis role="{$style}">
							<xsl:apply-templates/>
						</emphasis>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<phrase role="{$style}">
					<xsl:apply-templates/>
				</phrase>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="text:tab-stop">
		<phrase role="tab">&#160;&#160;&#160;&#160;</phrase>
	</xsl:template>
	<xsl:template match="text:line-break">
		<emphasis role="br"/>
	</xsl:template>
	<!-- link -->
	<xsl:template match="text:a">
		<xsl:element name="ulink">
			<xsl:attribute name="url">
				<xsl:value-of select="@xlink:href"/>
			</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
		<!--
    <xsl:choose>
      <xsl:when test="contains(@xlink:href,'://')">
        <xsl:element name="ulink">
          <xsl:attribute name="url">
            <xsl:value-of select="@xlink:href"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="not(contains(@xlink:href,'#'))">
        <xsl:element name="olink">
          <xsl:attribute name="targetdocent">
            <xsl:value-of select="@xlink:href"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="linkvar" select="substring-after(@xlink:href,'#')"/>
        <xsl:element name="link">
          <xsl:attribute name="linkend">
            <xsl:value-of select="substring-before($linkvar,'%')"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
-->
	</xsl:template>
	<xsl:template match="text:*">
		<xsl:apply-templates/>
	</xsl:template>
	<!-- @endterm not retained due to problems with OOo method of displaying text in the reference-ref -->
	<xsl:template match="text:reference-ref">
		<xsl:element name="xref">
			<xsl:attribute name="linkend">
				<xsl:value-of select="@text:ref-name"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>
	<xsl:template name="id.attribute">
		<xsl:if test="child::text:reference-mark-start">
			<xsl:attribute name="id">
				<xsl:value-of select="child::text:reference-mark-start/@text:name"/>
			</xsl:attribute>
		</xsl:if>
		<!-- Constraints imposed by OOo method of displaying reference-ref text means that xreflabel and endterm are lost -->
		<!--<xsl:if test="child::text:p/text:span[@text:style-name = 'XrefLabel']">
        <xsl:attribute name="xreflabel">
            <xsl:value-of select="text:p/text:span"/>
        </xsl:attribute>
    </xsl:if> -->
	</xsl:template>
	<xsl:template match="text:reference-mark-start"/>
	<xsl:template match="text:reference-mark-end"/>
	<xsl:template match="comment">
		<xsl:comment>
			<xsl:value-of select="."/>
		</xsl:comment>
	</xsl:template>
	<xsl:template match="text:alphabetical-index-mark-start">
		<xsl:element name="indexterm">
			<xsl:attribute name="class">
				<xsl:text disable-output-escaping="yes">startofrange</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="id">
				<xsl:value-of select="@text:id"/>
			</xsl:attribute>
			<!--<xsl:if test="@text:key1">-->
			<xsl:element name="primary">
				<xsl:value-of select="@text:key1"/>
			</xsl:element>
			<!--</xsl:if>-->
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
	<!--

	get a semantic style name 
	 - CSS compatible (no space, all min) 
	 - from automatic styles 

-->
	<xsl:template match="@text:style-name | @draw:style-name | @draw:text-style-name | @table:style-name">
		<xsl:variable name="current" select="."/>
		<xsl:choose>
			<xsl:when test="
translate( //office:automatic-styles/style:style[@style:name = $current]
, '&majs;', '&mins;')
">
				<xsl:value-of select="
translate(//office:automatic-styles/style:style[@style:name = $current]/@style:parent-style-name
, '&majs;', '&mins;')
"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="translate($current , '&majs;', '&mins;')"/>
			</xsl:otherwise>
		</xsl:choose>
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
	<xsl:template match="*">
		<!--
		<xsl:comment>
			<xsl:apply-templates select="." mode="path"/>
			<xsl:value-of select="normalize-space(.)"/>
		</xsl:comment>
-->
	</xsl:template>
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
</xsl:stylesheet>
