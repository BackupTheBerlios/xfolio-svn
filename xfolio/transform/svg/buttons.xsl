<?xml version="1.0" encoding="UTF-8"?>
<!--

	creation:
		2002
	modified:
		2004-04-05
	creator:
		frederic.glorieux@ajlsm.com
	goal:
		Try to find a generic way to produce SVG buttons from a single SVG origin
	usage:
		May be be use as a splitter with saxon7 or as a pipe in cocoon
	history:
		The original xsl was a test never used
		Will be now part of XFolio
  rights :
    (c)ajlsm.com
    http://www.gnu.org/copyleft/gpl.html
  TODO:
    The splitter have not be tested for months.
	  Isolate a separate split xsl template tested with different processors.
-->
<xsl:stylesheet version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:svg="http://www.w3.org/2000/svg">
	<xsl:output indent="no" method="xml"/>
	<!-- -->
	<xsl:param name="mode" select="'split'"/>
	<!-- symbol@id of the button -->
	<xsl:param name="symbol"/>
	<!-- change class of the button (over, etc) -->
	<xsl:param name="class"/>
	<!-- folder where to find the CSS for all buttons (depends on URI policy upper) -->
	<xsl:param name="skin"/>
	<!--  -->
	<xsl:template match="/">
		<xsl:choose>
			<!-- use in split mode -->
			<xsl:when test="$mode='split'">
				<!--
				<xsl:document href="index.html">
					<html>
						<head/>
						<body>
							<h1>buttons</h1>
							<xsl:apply-templates select="//symbol"/>
						</body>
					</html>
				</xsl:document>
				-->
				<html>
					<head/>
					<body>Processus terminé
            </body>
				</html>
			</xsl:when>
			<!-- output a single SVG button -->
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--
	
	templates for split
	-->

		<!--
		<xsl:document href="{@id}.svg">
			<svg width="20" height="20" viewBox="0 0 120 120" xmlns:xlink="http://www.w3.org/1999/xlink">
				<defs>
					<xsl:copy-of select="."/>
					<xsl:copy-of select="/svg/defs/filter[@id='bump']"/>
					<xsl:copy-of select="/svg/defs/filter[@id='inset']"/>
					<xsl:copy-of select="/svg/defs/filter[@id='ridge']"/>
				</defs>
				<rect fill="Beige" x="10" y="10" width="100" height="100" rx="10" ry="20" stroke-linecap="round" stroke-linejoin="round" stroke="none" filter="url(#bump)"/>
				<rect filter="url(#ridge)" stroke="green" fill="none" stroke-width="4" x="10" y="10" width="100" height="100" rx="10" ry="20" stroke-linecap="round" stroke-linejoin="round"/>
				<use fill="black" xlink:href="#{@id}" x="25" y="25" width="70" height="70" filter="url(#inset)"/>
			</svg>
		</xsl:document>
		<xsl:document href="{@id}1.svg">
			<svg width="20" height="20" viewBox="0 0 120 120" xmlns:xlink="http://www.w3.org/1999/xlink">
				<defs>
					<xsl:copy-of select="."/>
					<xsl:copy-of select="/svg/defs/filter[@id='bump']"/>
					<xsl:copy-of select="/svg/defs/filter[@id='inset']"/>
					<xsl:copy-of select="/svg/defs/filter[@id='ridge']"/>
				</defs>
				<rect fill="beige" x="10" y="10" width="100" height="100" rx="10" ry="20" stroke-linecap="round" stroke-linejoin="round" stroke="none" filter="url(#bump)"/>
				<rect filter="url(#ridge)" stroke="red" fill="none" stroke-width="4" x="10" y="10" width="100" height="100" rx="10" ry="20" stroke-linecap="round" stroke-linejoin="round"/>
				<use fill="red" xlink:href="#{@id}" x="25" y="25" width="70" height="70" filter="url(#inset)"/>
			</svg>
		</xsl:document>
		<xsl:document href="{@id}2.svg">
			<svg width="20" height="20" viewBox="0 0 120 120" xmlns:xlink="http://www.w3.org/1999/xlink">
				<defs>
					<xsl:copy-of select="."/>
					<xsl:copy-of select="/svg/defs/filter[@id='bump']"/>
					<xsl:copy-of select="/svg/defs/filter[@id='inset']"/>
					<xsl:copy-of select="/svg/defs/filter[@id='ridge']"/>
				</defs>
				<rect fill="red" x="10" y="10" width="100" height="100" rx="10" ry="20" stroke-linecap="round" stroke-linejoin="round" stroke="none" filter="url(#bump)"/>
				<use fill="white" xlink:href="#{@id}" x="25" y="25" width="70" height="70" filter="url(#inset)"/>
				<rect filter="url(#ridge)" stroke="green" fill="none" stroke-width="4" x="10" y="10" width="100" height="100" rx="10" ry="20" stroke-linecap="round" stroke-linejoin="round"/>
			</svg>
		</xsl:document>
-->



<!--
   change the symbol to display in a style group
-->
<xsl:template match="svg:use/@xlink:href[.='#symbol']">
	<xsl:attribute name="xlink:href">
		<xsl:value-of select="concat('#', $symbol)"/>
	</xsl:attribute>
</xsl:template>
	<!--
change class of the button
-->

	<xsl:template match="svg:g/@class">
		<xsl:attribute name="class">
			<xsl:value-of select="$class"/>
		</xsl:attribute>
	</xsl:template>
	<!--
strip unuseful symbols
-->
	<xsl:template match="svg:defs//svg:symbol">
		<xsl:choose>
			<xsl:when test="$symbol != '' and @id !='' and $symbol != @id"/>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- was for tests
	<xsl:template match="svg:svg">
		<svg width="500" height="300">
			<text x="4" y="200">COUCOU</text>
		</svg>
	</xsl:template>
	-->
  <!--
  Correct CSS link
<?xml-stylesheet type="text/css" href="buttons.css" ?>
  -->
  <xsl:template match="processing-instruction('xml-stylesheet')">
		<xsl:processing-instruction name="xml-stylesheet">
			<xsl:text>type="text/css" href="</xsl:text>
				<xsl:value-of select="$skin"/>
				<xsl:value-of select="substring-before( substring-after(., 'href=&quot;'), '&quot;')"/>
			<xsl:text>"</xsl:text>
		</xsl:processing-instruction>
  </xsl:template>
  <!--
  strip comments ?
  -->
  <xsl:template match="comment()"/>
	<!--
Default, copy all from SVG source
-->
	<xsl:template match="@*|node()" priority="-1">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
