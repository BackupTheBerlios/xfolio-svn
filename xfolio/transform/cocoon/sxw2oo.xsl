<?xml version="1.0" encoding="UTF-8"?>
<!-- 
From forrest project, probably of general cocoon interest


    OpenOffice Writer files are stored in .swx files which are 
    ZIP files. Content, style, meta, ... are stored
    n different files within these archives. In order to generate 
    *one* XML file containing all parts this aggregation using
    the CInclude-transformer is necessary.


-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ci="http://apache.org/cocoon/include/1.0" xmlns:xi="http://www.w3.org/2001/XInclude" exclude-result-prefixes="ci xi">
  <xsl:param name="src"/>
  <xsl:template match="/">
    <office:document xmlns:office="http://openoffice.org/2000/office" xmlns:style="http://openoffice.org/2000/style" xmlns:text="http://openoffice.org/2000/text" xmlns:table="http://openoffice.org/2000/table" xmlns:draw="http://openoffice.org/2000/drawing" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="http://openoffice.org/2000/meta" xmlns:number="http://openoffice.org/2000/datastyle" xmlns:svg="http://www.w3.org/2000/svg" xmlns:chart="http://openoffice.org/2000/chart" xmlns:dr3d="http://openoffice.org/2000/dr3d" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="http://openoffice.org/2000/form" xmlns:script="http://openoffice.org/2000/script" xmlns:config="http://openoffice.org/2001/config" office:class="text" office:version="1.0">
<!--
      <ci:include select="/*/*" src="zip://meta.xml@{$src}"/>
      <ci:include select="/*/*" src="zip://content.xml@{$src}"/>
-->
      <xi:include href="zip://meta.xml@{$src}#xpointer(/*/*)"/>
      <xi:include href="zip://content.xml@{$src}#xpointer(/*/*)"/>
    </office:document>
  </xsl:template>
</xsl:stylesheet>
