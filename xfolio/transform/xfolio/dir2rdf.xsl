<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:transform [
  <!-- identifier of a default file name identifier to open a directory -->
  <!ENTITY index "index">
]>
<!--
creation:
	2004-01-27
modified:
	2004-02-10
creator:
	frederic.glorieux@ajlsm.com
publisher:
	http://www.strabon.org

goal:
  crawl a list of i18n files and directories, to include dc:property from an RDF

logic:

-->
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dir="http://apache.org/cocoon/directory/2.0" xmlns="http://purl.org/rss/1.0/" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="dir xi xsi rdf dc xsl">
  <xsl:import href="naming.xsl"/>
  <xsl:import href="file2rdf.xsl"/>
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <!-- prefix of your persistant URIs -->
  <xsl:param name="domain"/>
  <!-- branch of the file -->
  <xsl:param name="branch"/>
  <xsl:param name="depth" select="1"/>
  <xsl:template match="/*" priority="1">
    <!--
		<xsl:processing-instruction name="xml-stylesheet">
			<xsl:text>type="text/xsl" href="/stylesheets/meta/dir2html.xsl"</xsl:text>
		</xsl:processing-instruction>

Should be verified on the DTD of RDF but the root attribute 
rdf:about is used to resolve absolute URIs
-->
    <rdf:RDF xsi:type="directory" rdf:about="{$domain}{$branch}">
      <xsl:choose>
        <xsl:when test="dir:file[starts-with(@name, 'index')]">
          <rdf:Description>
            <xsl:apply-templates select="dir:file[starts-with(@name, 'index')]" mode="one"/>
            <!-- add a default title with directory name -->
            <dc:title xsi:type="filename">
              <xsl:value-of select="concat(@name, '/')"/>
            </dc:title>
            <dc:identifier xsi:type="filename">
              <xsl:value-of select="concat(@name, '/')"/>
            </dc:identifier>
          </rdf:Description>
        </xsl:when>
      </xsl:choose>
      <!--
	count items, one for each document (in any formats and languages 
-->
      <!-- unplug, let if for full toc
					<dc:format xsi:type="count">
						<xsl:value-of select="count(
.//dir:file [../dir:file[starts-with(@name, '&index;')]]
[
	(contains(@name, '_') 
		and not(contains(preceding-sibling::dir:file/@name, substring-before(@name, '_')))  
	)
  or ( not(contains(@name, '_')) and contains(@name, '.') 
  		and not(contains(preceding-sibling::dir:file/@name, substring-before(@name, '.')))  
  	)
	or ( not(contains(@name, '_')) and not(contains(@name, '.')))
]
)"/>
					</dc:format>
-->
      <xsl:apply-templates>
        <xsl:with-param name="depth" select="$depth - 1"/>
      </xsl:apply-templates>
    </rdf:RDF>
  </xsl:template>
  <!--

	dir:directory

-->
  <!-- default, keep all directories (prune empties)  -->
  <xsl:template match="dir:directory"/>
  <!-- take all directories with files -->
  <xsl:template match="dir:directory[dir:file | dir:directory]">
    <xsl:param name="branch" select="$branch"/>
    <xsl:param name="depth"/>
    <rdf:Description>
      <!-- 
	count items, one for each document (in any formats and languages 
let it for full table of contents 
feature better optimized with a db:xml
-->
      <!--
				<dc:format xsi:type="count">

					<xsl:value-of select="count(
.//dir:file [../dir:file[starts-with(@name, '&index;')]]  
[
	(contains(@name, '_') and contains(@name, '.') 
		and not(contains(preceding-sibling::dir:file/@name, substring-before(@name, '_')))  
	)
  or ( not(contains(@name, '_')) and contains(@name, '.') 
  		and not(contains(preceding-sibling::dir:file/@name, substring-before(@name, '.')))  
  	)
	or ( not(contains(@name, '_')) and not(contains(@name, '.')))
]
)"/>
				</dc:format>
-->
      <!--
				<xsl:apply-templates select="dir:file[starts-with(@name, '&index;')]" mode="one">
					<xsl:with-param name="branch" select="concat($branch, @name, '/')"/>
				</xsl:apply-templates>
			<xi:include href="cocoon:/{$branch}{@name}/index.rdf#xpointer(/*/*/*)"/>
-->
      <xsl:if test="dir:file[starts-with(@name, 'index')]">
        <xsl:apply-templates select="dir:file[starts-with(@name, 'index')]" mode="one">
          <xsl:with-param name="branch" select="concat($branch, @name, '/')"/>
        </xsl:apply-templates>
      </xsl:if>
      <dc:identifier xsi:type="filename">
        <xsl:value-of select="concat($domain, $branch, @name, '/')"/>
      </dc:identifier>
      <dc:title xsi:type="filename">
        <xsl:attribute name="xml:lang">
          <xsl:call-template name="getLang">
            <xsl:with-param name="path" select="@name"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:value-of select="@name"/>
      </dc:title>
      <dc:identifier xsi:type="filename">
        <xsl:value-of select="concat(@name, '/')"/>
      </dc:identifier>
      <xsl:if test="not(dir:file[starts-with(@name, 'index')])">
        <xsl:apply-templates select="dir:file[1]" mode="one">
          <xsl:with-param name="branch" select="concat($branch, @name, '/')"/>
        </xsl:apply-templates>
      </xsl:if>
    </rdf:Description>
    <!--
	TODO : toc CAUTION will not work ! (repeated index or first file)
-->
    <xsl:if test="$depth &gt; 0">
      <xsl:apply-templates>
        <xsl:with-param name="branch" select="concat($branch, @name, '/')"/>
        <xsl:with-param name="depth" select="$depth - 1"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
  <!--

	dir:file
	index should be first handled by directory
-->
  <xsl:template match="dir:file"/>
  <!-- a file as an RSS item, include rdf meta -->
  <xsl:template match="dir:file[not(starts-with(@name, '&index;'))]">
    <xsl:param name="branch" select="$branch"/>
    <xsl:param name="radical">
      <xsl:call-template name="getRadical">
        <xsl:with-param name="path" select="@name"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="preceding-sibling::dir:file[contains(@name, $radical)]"/>
      <xsl:otherwise>
        <rdf:Description>
          <!-- perhaps better to include only the generated rdf ? -->
          <!--

this expression should be optimize from file 2rdf
<xi:include href="cocoon:/{$branch}{$radical}.rdf#xpointer(/*/*/*)"/>

						<xsl:apply-templates select="../dir:file[contains(@name, $radical)]" mode="one">
							<xsl:with-param name="branch" select="$branch"/>
						</xsl:apply-templates>
						-->
          <xsl:apply-templates select="../dir:file[contains(@name, $radical)]" mode="one">
            <xsl:with-param name="branch" select="$branch"/>
          </xsl:apply-templates>
        </rdf:Description>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:transform>
