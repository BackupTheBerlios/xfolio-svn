<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
                xmlns:date="http://exslt.org/dates-and-times"
                exclude-result-prefixes="doc date"
                extension-element-prefixes="date"
                version='1.0'>

<!-- ********************************************************************
     $Id: pi.xsl,v 1.2 2004/06/18 23:57:35 frederic Exp $
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://nwalsh.com/docbook/xsl/ for copyright
     and other information.

     This file contains general templates for processing processing
     instructions common to both the HTML and FO versions of the
     DocBook stylesheets.
     ******************************************************************** -->

<!-- Process PIs also on title pages -->
<xsl:template match="processing-instruction()" mode="titlepage.mode">
  <xsl:apply-templates select="."/>
</xsl:template>

<xsl:template match="processing-instruction('dbtimestamp')">
  <xsl:variable name="format">
    <xsl:variable name="pi-format">
      <xsl:call-template name="pi-attribute">
        <xsl:with-param name="pis" select="."/>
        <xsl:with-param name="attribute">format</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$pi-format != ''">
        <xsl:value-of select="$pi-format"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="gentext.template">
          <xsl:with-param name="context" select="'datetime'"/>
          <xsl:with-param name="name" select="'format'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>  

  <xsl:variable name="padding">
    <xsl:variable name="pi-padding">
      <xsl:call-template name="pi-attribute">
        <xsl:with-param name="pis" select="."/>
        <xsl:with-param name="attribute">padding</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$pi-padding != ''">
        <xsl:value-of select="$pi-padding"/>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="date">
    <xsl:if test="function-available('date:date-time')">
      <xsl:value-of select="date:date-time()"/>
    </xsl:if>
  </xsl:variable>

  <xsl:choose>
<!--    
    <xsl:when test="function-available('date:date-time')">
      <xsl:call-template name="datetime.format">
        <xsl:with-param name="date" select="$date"/>
        <xsl:with-param name="format" select="$format"/>
        <xsl:with-param name="padding" select="$padding"/>
      </xsl:call-template>
    </xsl:when>
--> 
   <xsl:otherwise>
      <xsl:message>
        Timestamp processing requires XSLT processor with EXSLT date support.
      </xsl:message>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>


</xsl:stylesheet>
