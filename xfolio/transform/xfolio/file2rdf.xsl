<?xml version="1.0" encoding="UTF-8"?>
<!--
creation=2004-01-27
modified=2004-01-27
author=frederic.glorieux@ajlsm.com
publisher=http://www.strabon.org

goal=
  provide a single DC record from multiple versions of a same document
  with links by language and format

-->
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dir="http://apache.org/cocoon/directory/2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:cinclude="http://apache.org/cocoon/include/1.0" exclude-result-prefixes="dir xi cinclude">
  <xsl:import href="naming.xsl"/>
  <xsl:output method="xml" indent="yes"/>
  <!-- extensions on which a DC record is expected to be include -->
  <xsl:param name="includes" select="' dbx sxw '"/>
  <!-- URI from which a server may answer a DC record -->
  <xsl:param name="context"/>
  <!-- prefix of your persistant URIs -->
  <xsl:param name="domain"/>
  <!-- branch of the file -->
  <xsl:param name="branch"/>
  <!-- an xsl processing instruction ? -->
  <xsl:param name="xsl"/>
  <!-- root -->
  <xsl:template match="/*">
    <!--
<?xml-stylesheet type="text/xsl" href="**.xsl"?>
-->
    <xsl:text>
</xsl:text>
    <xsl:if test="$xsl">
      <xsl:processing-instruction name="xml-stylesheet">
        <xsl:text>type="text/xsl" href="</xsl:text>
        <xsl:value-of select="$xsl"/>
        <xsl:text>"</xsl:text>
      </xsl:processing-instruction>
    </xsl:if>
    <rdf:RDF>
      <rdf:Description>
        <!--
unplug for now
				<xsl:if test="$identifier">
					<dc:identifier xsi:type="http://www.ietf.org/rfc/rfc2396.txt">
						<xsl:value-of select="$identifier"/>
					</dc:identifier>
					<dc:relation xsi:type="text/rdf">
						<xsl:value-of select="concat($identifier, '.rdf')"/>
					</dc:relation>
				</xsl:if>
			-->
        <xsl:apply-templates select="dir:file" mode="one"/>
      </rdf:Description>
    </rdf:RDF>
  </xsl:template>
  <!-- 
for each file, pass a path in case of recursive crossing directory

-->
  <xsl:template match="dir:file" mode="one">
    <xsl:param name="branch" select="$branch"/>
    <xsl:param name="name" select="@name"/>
    <xsl:param name="radical">
      <xsl:call-template name="getRadical">
        <xsl:with-param name="path" select="@name"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:variable name="extension">
      <xsl:call-template name="getExtension">
        <xsl:with-param name="path" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="lang">
      <xsl:call-template name="getLang">
        <xsl:with-param name="path" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- essentially for mediadir -->
    <xsl:apply-templates select="@*"/>
    <!-- get meta from which we can expect an rdf version -->
    <xsl:choose>
      <!--
		TODO, may bug here
		-->
      <xsl:when test="contains($includes, concat(' ', $extension, ' '))">
        <!-- this xsl may provide an rdf result from more than one dc record -->
        <!--
this solution may be expensive, cross server

				<xsl:copy-of select="document(concat($server, $path, substring-before(@name, '.'), '.dc'))/*/*/*"/>

cocoon:/ protocol buggy under cocoon2.0

				<xsl:copy-of select="document(concat('cocoon:/', $path, substring-before(@name, '.'), '.dc'))/*/*/*"/>
				<xi:include href="cocoon:/{$path}{substring-before(@name, '.')}.dc#xpointer(/*/*/*)"/>


This have produce strange bugs
				<cinclude:include src="cocoon:/{$path}{substring-before(@name, '.')}.dc"/>


-->
        <xsl:comment>
          <xsl:value-of select="@name"/>
        </xsl:comment>
        <!-- caution, may for names with more than one point -->
        <xi:include href="{$context}{$branch}{substring-before(@name, '.')}.dc#xpointer(/*/*/*)"/>
      </xsl:when>
      <!--
case of jpg

This is a bad place to say it but let it for now ?
Should be in sitemap

-->
      <xsl:when test="$extension = 'jpg'">
        <dc:relation>
          <xsl:attribute name="xsi:type">
            <xsl:call-template name="getMime">
              <xsl:with-param name="path" select="@name"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:value-of select="concat($domain, $branch, @name)"/>
        </dc:relation>
        <dc:relation xsi:type="text/html">
          <xsl:value-of select="concat($domain, $branch, $radical, '.html')"/>
        </dc:relation>
      </xsl:when>
      <!-- identifier without meta -->
      <xsl:otherwise>
        <!-- this was used one day but can't remember for what
				<xsl:if test="not(../dir:file[contains(@name, $radical) 
	and contains(@name, '.')
	and contains($includes, substring-after(@name, '.')
	)]) or $short">
				</xsl:if>
				-->
        <dc:relation>
          <xsl:attribute name="xsi:type">
            <xsl:call-template name="getMime">
              <xsl:with-param name="path" select="@name"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:if test="$lang != ''">
            <xsl:attribute namespace="http://www.w3.org/XML/1998/namespace" name="lang">
              <xsl:value-of select="$lang"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:value-of select="concat($domain, $branch, @name)"/>
        </dc:relation>
      </xsl:otherwise>
    </xsl:choose>
    <!--
provide filename as last title, in hope of wikiName 
-->
    <dc:relation xsi:type="text/rdf">
      <xsl:if test="$lang != ''">
        <xsl:attribute namespace="http://www.w3.org/XML/1998/namespace" name="lang">
          <xsl:value-of select="$lang"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="concat($domain, $branch, $radical, '.rdf')"/>
    </dc:relation>
    <dc:title xsi:type="filename">
      <xsl:if test="$lang != ''">
        <xsl:attribute namespace="http://www.w3.org/XML/1998/namespace" name="lang">
          <xsl:value-of select="$lang"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="$radical"/>
    </dc:title>
    <dc:identifier xsi:type="filename">
      <xsl:value-of select="@name"/>
    </dc:identifier>
  </xsl:template>
  <!-- default : handle all attributes -->
  <xsl:template match="@* | @*[normalize-space(.)='']">
    <!-- unplug for now
		<xsl:comment>
			<xsl:value-of select="name()"/>
		</xsl:comment>
	-->
  </xsl:template>
  <!-- unused -->
  <xsl:template match="
   @*[contains(name(), 'Unknown.tag')] | @*[contains(name(), 'Component')] | @*[contains(name(), 'Thumbnail')]
 | @Software | @YCbCr.Positioning | @Exposure.Time | @Exposure.Program | @ISO.Speed.Ratings | @Exif.Version
 | @F-Number | @Components.Configuration | @Compressed.Bits.Per.Pixel | @Exposure.Bias.Value
 | @Max.Aperture.Value | @Metering.Mode | @Light.Source | @Flash | @Focal.Length | @FlashPix.Version
 | @File.Source | @Shutter.Speed.Value | @Aperture.Value | @Focal.Plane.X.Resolution
 | @Focal.Plane.Resolution.Unit | @Sensing.Method | @Directory.Version | @Focal.Plane.Y.Resolution
 | @Compression | @Make | @Model
"/>
  <!-- title -->
  <xsl:template match="@Object.Name">
    <dc:title xsi:type="Iptc.{name()}">
      <xsl:value-of select="."/>
    </dc:title>
  </xsl:template>
  <xsl:template match="@Headline">
    <dc:title xsi:type="Iptc.{name()}">
      <xsl:value-of select="."/>
    </dc:title>
  </xsl:template>
  <!--
	<xsl:template match="@name">

		<xsl:if test="normalize-space(../@Object.Name)=''">
			<dc:title xsi:type="File.{name()}">
				<xsl:value-of select="."/>
			</dc:title>
		</xsl:if>
	</xsl:template>
-->
  <!-- creator -->
  <xsl:template match="@Artist">
    <!-- if no IPTC creator, take Exif one -->
    <xsl:if test="normalize-space(../@By-line)=''">
      <dc:creator xsi:type="Exif.{name()}">
        <xsl:value-of select="."/>
      </dc:creator>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@By-line">
    <dc:creator xsi:type="Iptc.{name()}">
      <xsl:value-of select="."/>
      <xsl:if test="normalize-space(../@By-line.Title) != ''">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="../@By-line.Title"/>
        <xsl:text>)</xsl:text>
      </xsl:if>
    </dc:creator>
  </xsl:template>
  <xsl:template match="@By-line.Title"/>
  <!-- subject -->
  <xsl:template match="@Category">
    <dc:subject xsi:type="Iptc.{name()}">
      <xsl:value-of select="."/>
    </dc:subject>
  </xsl:template>
  <xsl:template match="@Keywords | @Supplemental.Category-s-">
    <xsl:call-template name="keywords"/>
  </xsl:template>
  <!-- one element by keyword -->
  <xsl:template name="keywords">
    <xsl:param name="max" select="20"/>
    <xsl:param name="string" select="."/>
    <xsl:param name="separator">
      <xsl:choose>
        <xsl:when test="contains($string, ',')">,</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="' '"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="contains($string, $separator) and $max &gt;= 0">
        <dc:subject xsi:type="Iptc.{name()}">
          <xsl:value-of select="substring-before($string, $separator)"/>
        </dc:subject>
        <xsl:call-template name="keywords">
          <xsl:with-param name="string" select="substring-after($string, $separator)"/>
          <xsl:with-param name="separator" select="$separator"/>
          <xsl:with-param name="max" select="$max - 1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <dc:subject xsi:type="Iptc.{name()}">
          <xsl:value-of select="$string"/>
        </dc:subject>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- description -->
  <xsl:template match="@Caption-Abstract">
    <dc:description xsi:type="Iptc.{name()}">
      <xsl:value-of select="."/>
    </dc:description>
  </xsl:template>
  <!-- title ?
	<xsl:template match="@Image.Description">
		<dc:description xsi:type="Exif.{name()}">
			<xsl:value-of select="."/>
		</dc:description>
	</xsl:template>
 -->
  <xsl:template match="@User.Comment">
    <dc:description xsi:type="Exif.{name()}">
      <xsl:value-of select="."/>
    </dc:description>
  </xsl:template>
  <!--
	seems to be filled by lots of applications
	<xsl:template match="@Jpeg.Comment">
		<dc:description xsi:type="{name()}">
			<xsl:value-of select="."/>
		</dc:description>
	</xsl:template>
	-->
  <!-- publisher -->
  <!-- contributor -->
  <xsl:template match="@Writer-Editor">
    <dc:contributor xsi:type="Iptc.{name()}">
      <xsl:value-of select="."/>
    </dc:contributor>
  </xsl:template>
  <!-- date -->
  <xsl:template match="@Date.Created | @Time.Created"/>
  <xsl:template match="@Date-Time.Original | @Date-Time | @Date-Time.Digitized">
    <dc:date xsi:type="Iptc.{name()}">
      <xsl:value-of select="."/>
    </dc:date>
  </xsl:template>
  <!-- type -->
  <xsl:template match="@Scene.Type">
    <!-- ? pertinent ?
		<dc:type xsi:type="Exif.{name()}">
			<xsl:value-of select="."/>
		</dc:type>
	-->
  </xsl:template>
  <!-- format -->
  <xsl:template match="@Image.Height | @Image.Width"/>
  <xsl:template match="@Exif.Image.Width">
    <dc:format>
      <xsl:value-of select="substring-before(., ' ')"/>
      <xsl:text>x</xsl:text>
      <xsl:value-of select="substring-before(../@Exif.Image.Height, ' ')"/>
      <xsl:text> pixels</xsl:text>
    </dc:format>
    <dc:format xsi:type="{name()}">
      <xsl:value-of select="."/>
    </dc:format>
  </xsl:template>
  <xsl:template match="@Exif.Image.Height | @Color.Space">
    <dc:format xsi:type="{name()}">
      <xsl:value-of select="."/>
    </dc:format>
  </xsl:template>
  <xsl:template match="@Data.Precision">
    <dc:format xsi:type="Exif.{name()}">
      <xsl:value-of select="."/>
    </dc:format>
  </xsl:template>
  <!-- identifier -->
  <!-- source -->
  <xsl:template match="@Source">
    <dc:source xsi:type="Iptc.{name()}">
      <xsl:value-of select="."/>
    </dc:source>
  </xsl:template>
  <!-- language -->
  <!-- relation -->
  <!-- coverage -->
  <xsl:template match="@Province-State"/>
  <xsl:template match="@Country-Primary.Location"/>
  <xsl:template match="@City">
    <dc:coverage xsi:type="Iptc">
      <xsl:value-of select="."/>
      <xsl:if test="
   normalize-space (../@Province-State) != ''
or normalize-space (../@Country-Primary.Location) != ''
			">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="../@Province-State"/>
        <xsl:if test="
    normalize-space (../@Province-State) != ''
and normalize-space (../@Country-Primary.Location) != ''
			">, </xsl:if>
        <xsl:value-of select="../@Country-Primary.Location"/>
        <xsl:text>)</xsl:text>
      </xsl:if>
    </dc:coverage>
  </xsl:template>
  <!-- rights -->
  <xsl:template match="@Copyright">
    <dc:rights xsi:type="Exif.{name()}">
      <xsl:value-of select="."/>
    </dc:rights>
  </xsl:template>
  <xsl:template match="@Copyright.Notice">
    <dc:rights xsi:type="Iptc.{name()}">
      <xsl:value-of select="."/>
    </dc:rights>
  </xsl:template>
</xsl:transform>
