<?xml version="1.0" encoding="UTF-8"?>
<!--
(c) 2003, 2004 [xfolio.org], [ajlsm.com], [strabon.org], [eumedis.net]
Licence :  [http://www.gnu.org/copyleft/gpl.html GPL]

= WHAT =

This transformation take a documented directory as input,
and give some HTML views on it.

= WHO =

 *[FG] FredericGlorieux frederic.glorieux@xfolio.org

= CHANGES =

 * 2004-07-14:FG  "write site" in real time

= WHY =

I had implemented the same functionalities in pure XSL, and I'm now glad
to forget all that stuff for an easier solution to maintain (cause now 
most of the logic is done by a JAVA generator).

= TODO =

Everything.

-->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dir="http://apache.org/cocoon/directory/2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="xsl rdf dc xsi dir">
  <xsl:output method="xml" encoding="UTF-8"/>
  <!-- encoding, default is the one specified in xsl:output -->
  <xsl:param name="encoding" select="document('')/*/xsl:output/@encoding"/>
  <!-- lang requested -->
  <xsl:param name="lang"/>
  <!-- default language -->
  <xsl:param name="langDefault"/>
  <!-- for "you are here highlight" -->
  <xsl:param name="radicalHere"/>
  <!-- mode -->
  <xsl:param name="mode"/>
  <!-- resize -->
  <xsl:param name="resize" select="'yes'"/>
  <!--

Root template
-->
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$mode='table'">
        <xsl:apply-templates mode="table"/>
      </xsl:when>
      <xsl:otherwise>
        <ul>
          <xsl:apply-templates mode="toc"/>
        </ul>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--

A simple toc

maybe problems with directories called index ?
-->
  <xsl:template match="dir:directory" mode="toc">
    <!-- only directories -->
    <xsl:variable name="welcome" select="'index'"/>
    <xsl:choose>
      <!-- empty directory -->
      <xsl:when test="not(dir:*)">
        <li>
          <xsl:call-template name="title"/>
        </li>
      </xsl:when>
      <!-- no welcome file -->
      <xsl:when test="not(dir:file[@radical = $welcome])">
        <li>
          <xsl:call-template name="title"/>
        </li>
        <ul>
          <xsl:apply-templates mode="toc"/>
        </ul>
      </xsl:when>
      <!-- only welcome files -->
      <xsl:when test="not(dir:*[@radical != $welcome])">
        <xsl:apply-templates mode="toc"/>
      </xsl:when>
      <!-- different things and a welcome file to get a title -->
      <xsl:otherwise>
        <xsl:apply-templates select="dir:*[@radical = $welcome]" mode="toc"/>
        <ul>
          <xsl:apply-templates select="dir:*[@radical != $welcome]" mode="toc"/>
        </ul>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- 
to display only one file by radical, proceed only the first (and catch others) 
Input should be no too badly ordered, especially for extensions
-->
  <xsl:template match="dir:*[@radical = preceding-sibling::dir:*[1]/@radical]" mode="toc"/>
  <xsl:template match="dir:file" mode="toc">
    <xsl:variable name="radical" select="@radical"/>
    <xsl:choose>
      <xsl:when test="../dir:file[@radical=$radical][@xml:lang=$lang]">
        <xsl:apply-templates select="../dir:file[@radical=$radical][@xml:lang=$lang][1]" mode="li"/>
      </xsl:when>
      <xsl:when test="../dir:file[@radical=$radical][@xml:lang=$langDefault]">
        <xsl:apply-templates select="../dir:file[@radical=$radical][@xml:lang=$langDefault][1]" mode="li"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="../dir:file[@radical=$radical][1]" mode="li"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- 
display a file in a li for a toc
-->
  <xsl:template match="dir:file" mode="li">
    <li>
      <xsl:call-template name="title" mode="toc"/>
    </li>
  </xsl:template>
  <!--

A table to navigate

  -->
  <xsl:template match="dir:directory[ dir:file | dir:directory]" mode="table">
    <table id="menu" border="1">
      <xsl:for-each select="dir:file | dir:directory">
        <xsl:apply-templates select="." mode="tr"/>
      </xsl:for-each>
    </table>
  </xsl:template>
  <xsl:template match="dir:file | dir:directory" mode="tr">
    <tr>
      <!-- the "You are here"  -->
      <xsl:if test="contains($radicalHere, @radical)">
        <xsl:attribute name="class">this</xsl:attribute>
        <xsl:attribute name="bgcolor">#FFFFCC</xsl:attribute>
      </xsl:if>
      <xsl:variable name="image" select=".//dc:relation[contains(@xsi:type, 'image/jpeg')][1]"/>
      <xsl:if test="$image and $resize">
        <td class="img" bgcolor="#CCCCCC" width="52px" height="52px" align="center" valign="middle">
          <!-- 
request a thumb by filename, to avoid loading of complete images
if the server is not able to resize.

          <xsl:call-template name="thumb">
            <xsl:with-param name="relation" select="$image"/>
            <xsl:with-param name="size" select="50"/>
          </xsl:call-template>

  -->
        </td>
      </xsl:if>
      <td>
        <xsl:if test="not($image)">
          <xsl:attribute name="colspan">2</xsl:attribute>
        </xsl:if>
        <xsl:call-template name="title"/>
        <!--
            <xsl:apply-templates select="." mode="langs"/>
              -->
      </td>
    </tr>
  </xsl:template>
  <!--
get title
-->
  <xsl:template name="title">
    <!-- if no link ? -->
    <a target="_top" class="title" href="{@href}">
      <xsl:choose>
        <xsl:when test="name() = 'dir:directory'">
          <xsl:value-of select="@radical"/>
        </xsl:when>
        <xsl:when test=".//dc:title">
          <xsl:apply-templates select=".//dc:title[1]"/>
        </xsl:when>
        <xsl:when test="@radical != 'index'">
          <xsl:value-of select="@radical"/>
        </xsl:when>
        <!-- get the name of directory ? -->
        <xsl:otherwise>
          <xsl:value-of select="ancestor::dir:directory[1]/@radical"/>
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>
</xsl:transform>
