<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:saxon="http://icl.com/saxon" exclude-result-prefixes="saxon xi xsi">
	<!--
     |    This trashfast implementation could not replace a full xinclude
     |    engine.
     |
     |    It's working quite correctly alone, as a first pipe
     |    full xpointer support is not implemented
     |
     |    You can also use as an include (need some priority), but remember
     |
     |    1) a nodeset is not a document
     |            if you want an <xsl:number/> for included things,
     |            it will be relatively to his owner document, not the nodeset
     |    2) the result document is not processed as a nodeset (one pass)
     |            effect, don't try to match someting behind your include
     |
     |    in this case, use it only for indepedant blocks
     |-->
	<!--
indentity transformation should be somewhere else
    <xsl:template match="/*">
        <xsl:apply-templates />
    </xsl:template>
    <xsl:template match="@xsi:*" mode="xi"/>
-->
	<!-- default, copy all, in xi mode -->
	<!--
     |    Different matching
     |-->
	<!-- handle as processing-instruction -->
	<xsl:template match="processing-instruction('xi-include')">
		<xsl:variable name="href" select="substring-before( substring-after(., 'href=&quot;'), '&quot;')"/>
		<xsl:variable name="content">
			<xsl:call-template name="xi:include">
				<xsl:with-param name="href" select="$href"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="xi:continue">
			<xsl:with-param name="content" select="$content"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="xi:include">
		<xsl:call-template name="xi:include">
			<xsl:with-param name="href" select="@href"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="xi:continue">
		<xsl:param name="content" select="no-node"/>
		<xsl:choose>
			<!-- if root, continue process on children nodes -->
			<xsl:when test="not($content)">
				<!-- stop, failed -->
			</xsl:when>
			<xsl:when test="not(name($content))">
				<xsl:apply-templates select="$content/node()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$content"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--
     |    The engine
     |-->
	<xsl:template name="xi:include">
		<xsl:param name="href" select="@href"/>
		<xsl:param name="depth" select="@depth"/>
		<xsl:comment> include <xsl:value-of select="$href"/>
		</xsl:comment>
		<xsl:variable name="file">
			<xsl:choose>
				<xsl:when test="contains($href, '#')">
					<xsl:value-of select="substring-before($href, '#')"/>
				</xsl:when>
				<xsl:when test="contains($href, '?')">
					<xsl:value-of select="substring-before($href, '?')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$href"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="id">
			<xsl:value-of select="normalize-space(substring-after($href, '#'))"/>
		</xsl:variable>
		<xsl:variable name="content">
			<xsl:choose>
				<xsl:when test="$file != ''">
					<xsl:choose>
						<xsl:when test="$depth &lt; 2">
							<xsl:copy-of select="document($file, .)/*"/>
						</xsl:when>
						<xsl:when test="$id != ''">
							<xsl:copy-of select="document($file, .)//*[@id=$id]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="document($file, .)" mode="xi"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message>Xinclude: Failed to get a value for the @href
attribute of xi:include element.</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$content">
				<xsl:copy-of select="$content"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>xi:include failed : <xsl:value-of select="$file"/>
					<xsl:if test="$id != ''">#</xsl:if>
					<xsl:value-of select="$id"/>
					<xsl:text>
</xsl:text>
						<xsl:copy-of select="$content"/>
					</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- handle xi:include in xi mode -->
	<xsl:template match="processing-instruction('xi-include')" mode="xi">
		<xsl:variable name="href" select="substring-before( substring-after(., 'href=&quot;'), '&quot;')"/>
		<xsl:variable name="content">
			<xsl:call-template name="xi:include">
				<xsl:with-param name="href" select="$href"/>
			</xsl:call-template>
		</xsl:variable>
	</xsl:template>
	<!-- default copy all -->
	<xsl:template match="@*|*|text()|processing-instruction()|comment()" priority="-3" mode="xi">
		<xsl:copy>
			<xsl:apply-templates select="@*|*|text() |processing-instruction()|comment()" mode="xi"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
<!-- End of XInclude support -->
