<?xml version="1.0" encoding="ISO-8859-1" ?> 
<!--
#===================================================
# OOo2sDBK : OpenOffice-Writer to simplified Docbook
#===================================================
#
# :author: Eric Bellot
# :email: ebellot@netcourrier.com
# :date: 2002-12-03 02:09:09
# :version: 0.4
# :Copyright: (C) 2002 Eric Bellot
#
# This script is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# See ``COPYING`` for more information.
-->
<xsl:stylesheet version="1.1" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:office="http://openoffice.org/2000/office" 
    xmlns:style="http://openoffice.org/2000/style" 
    xmlns:text="http://openoffice.org/2000/text" 
    xmlns:table="http://openoffice.org/2000/table" 
    xmlns:draw="http://openoffice.org/2000/drawing" 
    xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:number="http://openoffice.org/2000/datastyle" 
    xmlns:svg="http://www.w3.org/2000/svg" 
    xmlns:chart="http://openoffice.org/2000/chart" 
    xmlns:dr3d="http://openoffice.org/2000/dr3d" 
    xmlns:math="http://www.w3.org/1998/Math/MathML" 
    xmlns:form="http://openoffice.org/2000/form" 
    xmlns:script="http://openoffice.org/2000/script" 
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:meta="http://openoffice.org/2000/meta" 
    exclude-result-prefixes="office style text table draw 
    fo xlink number svg chart dr3d math form script dc meta">

<xsl:output method="xml" indent="no" omit-xml-declaration="no"
	doctype-public="-//OASIS//DTD DocBook XML V4.1.2//EN"
	doctype-system="http://www.oasis-open.org/docbook/xml/4.0/docbookx.dtd"/>

<!-- OpenOffice's version. Values : 1.0|1.0.1 -->
<xsl:param name="generator" 
    select="/office:document/office:meta/meta:generator"/>
<xsl:param name="oooVersionNumber">
    <xsl:value-of select="substring-before(substring-after($generator,' '),' ')"/>
</xsl:param>
<xsl:param name="measureUnit">
	<xsl:choose>
	<xsl:when test="//table:table">
		<xsl:call-template name="measureUnit"/>
	</xsl:when>
	<xsl:otherwise>
	 	<xsl:value-of select="'unknow'"/>
	</xsl:otherwise>
	</xsl:choose>
</xsl:param>

<xsl:output method="xml" indent="yes" omit-xml-declaration="no"/>

<xsl:template name="measureUnit">
	<xsl:param name="firstValue" select="//style:properties[1]/@style:width"/>
	<xsl:if test="contains(string($firstValue),'mm')">
		<xsl:value-of select="'mm'"/>
	</xsl:if>
	<xsl:if test="contains(string($firstValue),'cm')">
		<xsl:value-of select="'cm'"/>
	</xsl:if>
	<xsl:if test="contains(string($firstValue),'inch')">
		<xsl:value-of select="'inch'"/>
	</xsl:if>
	<xsl:if test="contains(string($firstValue),'pi')">
		<xsl:value-of select="'pi'"/>
	</xsl:if>
	<xsl:if test="contains(string($firstValue),'pt')">
		<xsl:value-of select="'pt'"/>
	</xsl:if>
	<xsl:if test="contains(string($firstValue),'%')">
		<xsl:value-of select="'%'"/>
	</xsl:if>
</xsl:template>

<!-- 
=============
DOCUMENT ROOT
=============
-->

<xsl:template match="/">
	 <article>
	 	<xsl:attribute name="lang">
            <xsl:value-of 
			    select="/office:document/office:meta/dc:language"/>
        </xsl:attribute>

		<!--<xsl:apply-templates select="/office:document/office:meta" mode="top"/>-->
        <xsl:call-template name="articleInfo"/>
	    <!--On commence par le 1er titre de niveau 1-->
	 	<xsl:choose>
				<xsl:when test="/office:document/office:body/text:h[@text:level='1']">
					<xsl:apply-templates
						select="/office:document/office:body/text:h[@text:level='1'][1]"
				mode="hierarchy"/>
	  		</xsl:when>
	  		<xsl:otherwise>
				<xsl:apply-templates 
					select="/office:document/office:body" 
					mode="noHierarchy"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates 
                    select="/office:document/office:body/text:bibliography"
		    mode="bottom"/>
	</article> 
</xsl:template>

<!-- 
====================
SECTION'S  HIERARCHY
====================
-->

<xsl:template match="*|@*" name="hierarchy" mode="hierarchy">
	<!-- Le paramètre "level" permet de mémoriser la profondeur du niveau
	en cours (1, 2, etc.) -->
    <xsl:param name="source"/>
	<xsl:param name="level" select="'0'"/>
	<xsl:choose>
		<xsl:when test="name(.)!='text:h'">
		    <xsl:call-template name="allTags">
                <xsl:with-param name="source" select="'hierarchy'"/>
            </xsl:call-template>
            <xsl:apply-templates select="following-sibling::*[1]" 
                mode="hierarchy"> 
				<xsl:with-param name="level" select="$level"/> 
			</xsl:apply-templates>
		</xsl:when>
	
		<!-- Si le titre "h" est cours est d'une profondeur plus
			élevée que le précédent... -->
		<xsl:when test="@text:level > $level">
			<!-- Execute les modèles qui précèdent le 1er titre de
				niveau 1-->
			<xsl:if test="count(preceding-sibling::text:h[@text:level='1'])=0">
				<xsl:apply-templates select="preceding-sibling::*"/>
			</xsl:if>
					
			<!-- ...On construit une nouvelle section (sectn)
					et le contenu du tag "h" source est placé dans le
						tag "title" de sortie  -->
			<xsl:element name="section">
				<title><xsl:apply-templates/></title>
				<xsl:apply-templates select="following-sibling::*[1]" 
                    mode="hierarchy"> 
					<xsl:with-param name="level" select="@text:level"/> 
				</xsl:apply-templates>
			</xsl:element> 
			<xsl:apply-templates select="following-sibling::*[1]"
                mode="scanLevel">
				<xsl:with-param name="level" select="@text:level"/> 
			</xsl:apply-templates>
		</xsl:when> 
	</xsl:choose> 
</xsl:template> 

<xsl:template match="*" mode="scanLevel"> 
  <xsl:param name="level" select="'0'"/> 
	<xsl:choose> 
		<xsl:when test="@text:level &lt; $level"/> 
		<xsl:when test="@text:level = $level"> 
			<xsl:call-template name="hierarchy"> 
				<xsl:with-param name="level" select="$level - 1"/> 
			</xsl:call-template>
		</xsl:when> 
		<xsl:otherwise> 
		    <xsl:apply-templates select="following-sibling::*[1]"
                mode="scanLevel"> 
				<xsl:with-param name="level" select="$level"/> 
			</xsl:apply-templates>
		</xsl:otherwise> 
	</xsl:choose> 
</xsl:template>

<xsl:template match="/office:document/office:body" mode="noHierarchy">
    <xsl:apply-templates mode="noHierarchy"/>
</xsl:template>

<xsl:template match="*|@*" mode="noHierarchy">
    <xsl:call-template name="allTags"/>
</xsl:template>

<xsl:template name="allTags">
<xsl:param name="source"/>
    <xsl:choose>
        <xsl:when test="name(current())='text:p'">
             <xsl:call-template name="para">
                <xsl:with-param name="source" select="$source"/>
             </xsl:call-template>
        </xsl:when>
        <xsl:when test="name(current())='text:ordered-list'">
             <xsl:call-template name="ordList"/>
        </xsl:when>
        <xsl:when test="name(current())='text:unordered-list'">
             <xsl:call-template name="unordList"/>
        </xsl:when>
        <xsl:when test="name(current())='table:table'">
            <xsl:choose>
                <xsl:when test="$source='cellTable'">
                    <para>ERROR : Section's title in a cell !!!</para>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="table"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="name(current())='text:h'">
            <xsl:choose>
                <xsl:when test="$source='hierarchy'"/>
                <xsl:otherwise>
                    <para>ERROR : Section's title in bad position !!!</para>
                </xsl:otherwise>
             </xsl:choose>
        </xsl:when>
    </xsl:choose>
</xsl:template>
<!-- 
===========
ARTICLEINFO
===========
-->

<xsl:template match="/office:document/office:meta"/>
<xsl:template match="text:p"/>

<xsl:template name="articleInfo">
<xsl:param name="bodyRootPara" select="/office:document/office:body/text:p"/>
    <articleinfo>
        <xsl:apply-templates select="$bodyRootPara" mode="articleInfo"/>
        <xsl:apply-templates select="/office:document/office:meta/meta:keywords"/>
        <xsl:apply-templates select="/office:document/office:meta/dc:subject"/>
    </articleinfo>
</xsl:template>

<xsl:template match="text:p" mode="articleInfo">
    <xsl:param name="parentStyleName"
        select="/office:document/office:automatic-styles/
        style:style[@style:name=(current()/@text:style-name)]/
        @style:parent-style-name"/> 
    <xsl:param name="inAuthor" select="'false'"/>
    <xsl:call-template name="multimedia.top"/>
    <xsl:if test="@text:style-name='Title' or
            $parentStyleName='Title'">
        <title><xsl:apply-templates/></title>
    </xsl:if>
    <xsl:if test="@text:style-name='Subtitle' or
            $parentStyleName='Subtitle'">
        <subtitle><xsl:apply-templates/></subtitle>
    </xsl:if>
    <xsl:if test="@text:style-name='Pubdate' or
            $parentStyleName='Pubdate'">
        <pubdate><xsl:apply-templates/></pubdate>
    </xsl:if>
     <xsl:if test="@text:style-name='Releaseinfo' or
            $parentStyleName='Releaseinfo'">
        <releaseinfo><xsl:apply-templates/></releaseinfo>
    </xsl:if>
    <xsl:if test="@text:style-name='Author' or
            $parentStyleName='Author'">
        <author><xsl:call-template name="authorContent"/></author>
    </xsl:if>
    <xsl:if test="@text:style-name='Editor' or
            $parentStyleName='Editor'">
        <editor><xsl:call-template name="authorContent"/></editor>
    </xsl:if>
    <xsl:if test="@text:style-name='Authorblurb' or $parentStyleName='Authorblurb'">
        <xsl:if test="$inAuthor='true'">
            <authorblurb>
                <xsl:call-template name="paraWithTitle"/>
            </authorblurb>
        </xsl:if>
    </xsl:if>
    <xsl:if test="@text:style-name='Othercredit' or
            $parentStyleName='Othercredit'">
        <othercredit><xsl:call-template name="authorContent"/></othercredit>
    </xsl:if>
    <xsl:if test="@text:style-name='Corpauthor' or
            $parentStyleName='Corpauthor'">
        <corpauthor><xsl:apply-templates/></corpauthor>
    </xsl:if>
    <xsl:if test="@text:style-name='Copyright' or
            $parentStyleName='Copyright'">
        <copyright><xsl:apply-templates 
            select="text:span"/></copyright>
    </xsl:if>
    <xsl:if test="@text:style-name='Bibliomisc' or
            $parentStyleName='Bibliomisc'">
        <bibliomisc><xsl:apply-templates/></bibliomisc>
    </xsl:if>
    <xsl:if test="@text:style-name='Abstract' or
            $parentStyleName='Abstract'">
        <abstract><xsl:call-template name="paraWithTitle"/></abstract>
    </xsl:if>
           <xsl:if test="@text:style-name='Legalnotice' or
            $parentStyleName='Legalnotice'">
        <legalnotice><xsl:call-template name="paraWithTitle"/></legalnotice>
    </xsl:if> 
    <xsl:call-template name="multimedia.bottom"/>
</xsl:template>


<xsl:template name="authorContent">
    <xsl:param name="parentStyleName"
        select="/office:document/office:automatic-styles/ 
        style:style[@style:name=(current()/@text:style-name)]/ 
        @style:parent-style-name"/>
    <xsl:param name="parentStyleNameOfFollowing" select="/office:document/office:automatic-styles/
                style:style[@style:name=current()/following-sibling::*[1]/@text:style-name]/
                @style:parent-style-name"/>
    <xsl:param name="parentStyleNameOfChild" select="/office:document/office:automatic-styles/
                style:style[@style:name=current()/*/@text:style-name]/
                @style:parent-style-name"/>
 
    <xsl:param name="inAuthor"/>
    <xsl:apply-templates
        select="text:span[@text:style-name='Honorific' or 
                $parentStyleNameOfChild='Honorific']|
                text:span[@text:style-name='Firstname' or 
                $parentStyleNameOfChild='Firstname']|
                text:span[@text:style-name='Othername' or 
                $parentStyleNameOfChild='Othername']|
                text:span[@text:style-name='Surname' or 
                $parentStyleNameOfChild='Surname']|
                text:span[@text:style-name='Lineage' or 
                $parentStyleNameOfChild='Lineage']"/>
    <xsl:if test="text:span[@text:style-name='Jobtitle' or 
                $parentStyleNameOfChild='Jobtitle']|
        text:span[@text:style-name='Orgname' or 
                $parentStyleNameOfChild='Orgname']">
        <affiliation>
            <xsl:apply-templates 
                select="text:span[@text:style-name='Jobtitle' or 
                $parentStyleNameOfChild='Jobtitle']|
                text:span[@text:style-name='Orgname' or 
                $parentStyleNameOfChild='Orgname']"/>
        </affiliation>
    </xsl:if>
    <xsl:if test="following-sibling::*[1] 
            [@text:style-name='Authorblurb' or 
            $parentStyleNameOfFollowing='Authorblurb']">
            <xsl:apply-templates select="following-sibling::*[1]" mode="articleInfo">
                <xsl:with-param name="inAuthor" select="'true'"/>
            </xsl:apply-templates>
    </xsl:if>
</xsl:template>

<xsl:template match="meta:keywords">
	<keywordset><xsl:apply-templates/></keywordset>
</xsl:template>

<xsl:template match="meta:keyword">
	<keyword><xsl:apply-templates/></keyword>
</xsl:template>

<xsl:template match="dc:subject">
    <xsl:param name="content" select="text()"/>
    <subjectset>
        <xsl:if test="normalize-space(substring-before($content,':'))">
            <xsl:attribute name="scheme">
                <xsl:value-of 
                    select="normalize-space(substring-before($content,':'))"/>
            </xsl:attribute>
        </xsl:if>
       <subject>
        <xsl:call-template name="subjectElements">
            <xsl:with-param name="content" select="substring-after($content,':')"/>
        </xsl:call-template>
        </subject>
    </subjectset>
</xsl:template>

<xsl:template name="subjectElements">
    <xsl:param name="content"/>
	<xsl:choose>
        <xsl:when test="contains($content,',')">
            <subjectterm>
                <xsl:value-of 
                    select="normalize-space(substring-before($content,','))"/>
             </subjectterm>
            <xsl:call-template name="subjectElements">
                <xsl:with-param name="content" select="substring-after($content,',')"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <subjectterm><xsl:value-of select="normalize-space($content)"/></subjectterm>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
		
<!-- 
=============
DOCUMENT BODY 
=============
-->

<!-- 
BLOCKS TAGS
===========
-->

<!-- Blocks - Standards blocks -->

<xsl:template name="para">
    <xsl:param name="source"/>
    <xsl:param name="pos"/>
    <xsl:param name="parentStyleName" 
               select="/office:document/office:automatic-styles/
                        style:style[@style:name=(current()/@text:style-name)]/
                        @style:parent-style-name"/>
    <xsl:param name="parentStyleNameOfPreceding" 
               select="/office:document/office:automatic-styles/
                       style:style[@style:name=current()/
                       preceding-sibling::*[1]/@text:style-name]/
                       @style:parent-style-name"/>
    <xsl:param name="parentStyleNameOfFollowing" 
               select="/office:document/office:automatic-styles/
                       style:style[@style:name=current()/
                       following-sibling::*[1]/@text:style-name]/
                       @style:parent-style-name"/>
    <xsl:param name="parent"/>
	<xsl:call-template name="multimedia.top"/>
        <xsl:choose>
			<xsl:when test="@text:style-name='Epigraph' or
                $parentStyleName='Epigraph'">
				<epigraph>
                    <xsl:if test="following-sibling::*[1][name()='text:p' and
                        @text:style-name='Attribution' or 
                        $parentStyleNameOfFollowing='Attribution']">
                        <xsl:apply-templates select="following-sibling::*[1]"
                            mode="attribution"/>
                    </xsl:if>
                    <xsl:call-template name="paraWithBreakLine"/>
                </epigraph>
			</xsl:when>
			<xsl:when test="@text:style-name='Quotations' or
                $parentStyleName='Quotations' or
                @text:style-name='Blockquote' or
                $parentStyleName='Blockquote'">
				<blockquote>
                    <xsl:if test="following-sibling::*[1][name()='text:p' and
                        @text:style-name='Attribution' or 
                        $parentStyleNameOfFollowing='Attribution']">
                        <xsl:apply-templates select="following-sibling::*[1]"
                            mode="attribution"/>
                    </xsl:if>
                    <xsl:call-template name="paraWithBreakLine"/>
                </blockquote>
			</xsl:when>
			<xsl:when test="@text:style-name='Preformatted Text' or
                $parentStyleName='Preformatted Text' or
                @text:style-name='ProgramListing' or
                $parentStyleName='ProgramListing'">
				<programlisting><xsl:apply-templates>
                <xsl:with-param name="parent" select="'programListing'"/>
                </xsl:apply-templates></programlisting></xsl:when>
                
			<xsl:when test="@text:style-name='Literallayout' or
                $parentStyleName='Literallayout'">
				<literallayout><xsl:apply-templates>
                <xsl:with-param name="parent" select="'programListing'"/>
                </xsl:apply-templates></literallayout></xsl:when>

            <xsl:when test="@text:style-name='Term' or
                $parentStyleName='Term'">
                <xsl:if
                    test="(preceding-sibling::*[1]/
                    @text:style-name != 'Definition' or
                    $parentStyleNameOfPreceding != 'Definition') and
                    (preceding-sibling::*[1]/@text:style-name != 'Term'
                    or $parentStyleNameOfPreceding != 'Term')"> 
                    <xsl:call-template name="varlistterm"/>
                </xsl:if>
                <xsl:if test="$source='varlist' and 
                              (preceding-sibling::*[1]/
                              @text:style-name='Definition' or 
                              $parentStyleNameOfPreceding='Definition')">
                    <xsl:call-template name="varlist"/>
                </xsl:if>
		    </xsl:when>
            <xsl:when test="@text:style-name='Definition' or
                $parentStyleName='Definition'">
                <xsl:if test="$source='varlist'">
                    <xsl:call-template name="paraWithBreakLine"/>
                </xsl:if>
                    <!--<xsl:if test="following-sibling::*[1][name()='text:p' 
                        and (@text:style-name='Definition' or 
                        $parentStyleNameOfFollowing='Definition')]">
                        <xsl:apply-templates select="following-sibling::*[1]"
                        mode="varlist"/>
                    </xsl:if>-->
            </xsl:when>
            <xsl:when test="@text:style-name='Note' or
                $parentStyleName='Note'">
				<note>
                    <xsl:call-template name="paraWithBreakLine"/>
				</note>
			</xsl:when>           
            <xsl:when test="@text:style-name='Heading' or
                $parentStyleName='Heading'"/>
            <xsl:when test="@text:style-name='Attribution' or
                $parentStyleName='Attribution'"/>
            <xsl:when test="text:sequence"/>
            <!-- suppress articleInfo's styles -->
             <xsl:when test="@text:style-name='Title' or
                $parentStyleName='Title'"/>
            <xsl:when test="@text:style-name='Subtitle' or
                    $parentStyleName='Subtitle'"/>
             <xsl:when test="@text:style-name='Releaseinfo' or
                    $parentStyleName='Releaseinfo'"/>
            <xsl:when test="@text:style-name='Pubdate' or
                    $parentStyleName='Pubdate'"/>
            <xsl:when test="@text:style-name='Author' or
                    $parentStyleName='Author'"/>
            <xsl:when test="@text:style-name='Editor' or
                    $parentStyleName='Editor'"/>
            <xsl:when test="@text:style-name='Authorblurb' 
                    or $parentStyleName='Authorblurb'"/>
            <xsl:when test="@text:style-name='Othercredit' or
                    $parentStyleName='Othercredit'"/>
            <xsl:when test="@text:style-name='Corpauthor' or
                    $parentStyleName='Corpauthor'"/>
            <xsl:when test="@text:style-name='Copyright' or
                    $parentStyleName='Copyright'"/>
            <xsl:when test="@text:style-name='Bibliomisc' or
                    $parentStyleName='Bibliomisc'"/>
            <xsl:when test="@text:style-name='Abstract' or
                    $parentStyleName='Abstract'"/>
            <xsl:when test="@text:style-name='Legalnotice' or
                    $parentStyleName='Legalnotice'"/>
                <!-- +++++ -->
			<xsl:otherwise>
				<xsl:call-template name="paraWithBreakLine"/>
			</xsl:otherwise>
		</xsl:choose>
	<xsl:call-template name="multimedia.bottom"/>
</xsl:template>

<xsl:template name="paraWithBreakLine">
    <xsl:if test="text:line-break">
        <xsl:apply-templates 
            select="text:line-break" mode="break2para"/>
    </xsl:if>
    <xsl:if test="not(text:line-break)">
        <para><xsl:apply-templates/></para>
    </xsl:if>
</xsl:template>

<xsl:template match="text:line-break" mode="break2para">
    <xsl:variable name="br-before" 
        select="preceding-sibling::text:line-break[1]"/>
    <xsl:variable name="content"  
        select="preceding-sibling::node()[not($br-before) or
                generate-id(preceding-sibling::text:line-break[1])
                =generate-id($br-before)]"/>
    <xsl:if test="$content">
      <para>
         <xsl:apply-templates select="$content" />
      </para>
    </xsl:if>
    <xsl:if test="position()=last()">
	    <para>
            <xsl:apply-templates select="following-sibling::node()"/>
	    </para>
    </xsl:if>
</xsl:template>

<xsl:template match="text:line-break">
    <xsl:param name="parent"/>
    <xsl:if test="$parent='programListing'">
	    <xsl:text disable-output-escaping="yes">&#013;</xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="text:tab-stop">
    <xsl:param name="parent"/>
    <xsl:if test="$parent='programListing'">
	    <xsl:text 
        disable-output-escaping="yes">&#032;&#032;&#032;&#032;</xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="text:s">
    <xsl:param name="parent"/>
    <xsl:param name="spaceOccurence" select="@text:c + 1"/>
    <xsl:if test="$parent='programListing'">
	    <xsl:call-template name="spaceRecursif">
		    <xsl:with-param name="spaceOccurence" 
                            select="$spaceOccurence"/>
	    </xsl:call-template>
    </xsl:if>
</xsl:template>

<xsl:template name="spaceRecursif">
	<xsl:param name="spaceOccurence"/>
	<xsl:if test="$spaceOccurence > 0">
		<xsl:text disable-output-escaping="yes">&#032;</xsl:text>
		<xsl:call-template name="spaceRecursif">
			<xsl:with-param name="spaceOccurence" 
				select="$spaceOccurence - 1"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- Blocks - Attribution -->

<xsl:template match="text:p" mode="attribution">
    <attribution><xsl:apply-templates/></attribution>
</xsl:template>

<!-- Block - Heading (local title) -->

<xsl:template name="paraWithTitle">
    <xsl:call-template name="precedingTitle"/>
    <xsl:call-template name="paraWithBreakLine"/>
</xsl:template>

<xsl:template name="precedingTitle">
    <xsl:param name="parentStyleNameOfPreceding" 
        select="/office:document/office:automatic-styles/
        style:style[@style:name=current()/preceding-sibling::*[1]/
        @text:style-name]/@style:parent-style-name"/>
	<xsl:if test="preceding-sibling::*[1][name()='text:p' 
        and (@text:style-name='Heading' or
        $parentStyleNameOfPreceding ='Heading')]">
        <xsl:apply-templates select="current()/preceding-sibling::*[1]"
        mode="includeTitle"/>
    </xsl:if>
</xsl:template>

<xsl:template match="text:p" mode="includeTitle">
    <title><xsl:apply-templates/></title>
</xsl:template>

<!-- 
LISTS
=====
-->

<!-- Lists - VariableList 
     'Term' and 'Definition' : not defaults styles of OpenOffice -->

<xsl:template name="varlistterm">
        <variablelist>
            <xsl:call-template name="varlist"/>
        </variablelist>
</xsl:template>

<xsl:template name="varlist">
    <xsl:param name="parentStyleNameOfFollowing" 
        select="/office:document/office:automatic-styles/
        style:style[@style:name=current()/
        following-sibling::*[1]/@text:style-name]/
        @style:parent-style-name"/>
    <xsl:param name="parentStyleNameOfFollowing2" 
        select="/office:document/office:automatic-styles/
        style:style[@style:name=current()/
        following-sibling::*[2]/@text:style-name]/
        @style:parent-style-name"/>
    <varlistentry>
        <term><xsl:apply-templates/></term>
        <listitem>
            <xsl:if test="following-sibling::*[1][name()='text:p'
                    and (@text:style-name='Definition' 
                    or $parentStyleNameOfFollowing='Definition')]">
                <xsl:apply-templates select="following-sibling::*[1]" 
                    mode="varlist"/>
            </xsl:if>
        </listitem>
    </varlistentry>
    <!--<xsl:choose>
        <xsl:when test="following-sibling::*[1][name()='text:p' and 
                  (@text:style-name='Term' or 
                  $parentStyleNameOfFollowing='Term')]">
        <xsl:apply-templates select="following-sibling::*[1]"
                             mode="varlist"/>
    </xsl:when>
    <xsl:when test="following-sibling::*[2][name()='text:p' and 
                  (@text:style-name='Term' or 
                  $parentStyleNameOfFollowing2='Term')]">
        <xsl:apply-templates select="following-sibling::*[2]"
                             mode="varlist"/>
    </xsl:when>
    <xsl:otherwise/>
    </xsl:choose>
   <xsl:if test="following-sibling::*[1][name()='text:p' and 
                  (@text:style-name='Term' or 
                  $parentStyleNameOfFollowing='Term')]">
        <xsl:apply-templates select="following-sibling::*[1]"
                             mode="varlist"/>
    </xsl:if>-->
    <xsl:if test="following-sibling::*[2][name()='text:p' and 
                  (@text:style-name='Term' or 
                  $parentStyleNameOfFollowing2='Term')]">
        <xsl:apply-templates select="following-sibling::*[2]"
                             mode="varlist"/>
    </xsl:if>
</xsl:template>

<!--
<xsl:template name="varlist">
    <xsl:param name="parentStyleName" select="/
    office:document/office:automatic-styles/
            style:style[@style:name=./@text:style-name]/
            @style:parent-style-name"/>
    <xsl:param name="parentStyleNameOfPreceding" select="/
    office:document/office:automatic-styles/
                    style:style[@style:name=current()/
                    preceding-sibling::*[1]/@text:style-name]/
                    @style:parent-style-name"/>
    <xsl:param name="parentStyleNameOfFollowing" select="/
                    office:document/office:automatic-styles/
                    style:style[@style:name=current()/
                    following-sibling::*[1]/@text:style-name]/
                    @style:parent-style-name"/>
    <varlistentry>
        <term><xsl:apply-templates/></term>
        <listitem>
            <xsl:if test="following-sibling::*[1][name()='text:p'
                    and (@text:style-name='Definition' 
                    or $parentStyleNameOfFollowing='Definition')]">
                <xsl:apply-templates select="following-sibling::*[1]" 
                    mode="varlist"/>
            </xsl:if>
        </listitem>
    </varlistentry>
        <xsl:apply-templates 
            select="following-sibling::text:p[(@text:style-name='Term'
            or $parentStyleName='Term') and 
            preceding-sibling::*[1][@text:style-name='Definition' and
            preceding-sibling::text:p[@text:style-name='Term']
            [1]=current()]][1]" 
            mode="varlist"/>
</xsl:template>
-->
<xsl:template match="*" mode="varlist">
    <xsl:call-template name="allTags">
        <xsl:with-param name="source" select="'varlist'"/>
    </xsl:call-template>
</xsl:template>

<!-- Lists - UnorderedList -->

<xsl:template match="text:unordered-list" name="unordList">
	<itemizedlist><xsl:apply-templates/></itemizedlist>
</xsl:template>

<!-- Lists - OrderedList -->

<xsl:template match="text:ordered-list" name="ordList">
<xsl:param name="styleName">
    <xsl:if 
        test="ancestor-or-self::text:ordered-list[last()]/
              @text:style-name">
        <xsl:value-of 
            select="ancestor-or-self::text:ordered-list
                    [last()]/@text:style-name"/>
    </xsl:if>
    <xsl:if test="ancestor-or-self::text:unordered-list
                  [last()]/@text:style-name">
        <xsl:value-of select="ancestor-or-self::text:unordered-list
                              [last()]/@text:style-name"/>
    </xsl:if>
</xsl:param>
<xsl:param name="level"
           select="count(ancestor-or-self::text:ordered-list) + 
                   count(ancestor-or-self::text:unordered-list)"/>
<xsl:param name="numStyle" 
           select="/office:document/office:automatic-styles/ 
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
	<listitem><xsl:apply-templates/></listitem>
</xsl:template>

<xsl:template match="text:list-item/text:p">
    <xsl:call-template name="multimedia.top"/>
    <xsl:call-template name="paraWithBreakLine"/>
    <xsl:call-template name="multimedia.bottom"/>
</xsl:template>

   
<!-- 
INLINES TAGS
============
-->

<xsl:template match="text:span">
    <xsl:param name="fontStyle" 
               select="/office:document/office:automatic-styles/
               style:style[@style:name=(current()/@text:style-name)]
               /style:properties/@fo:font-style"/>
    <xsl:param name="fontWeight" 
               select="/office:document/office:automatic-styles/
                       style:style[@style:name=(current()/
                       @text:style-name)]/style:properties/
                       @fo:font-weight"/>
    <xsl:param name="parentStyleName"
               select="/office:document/office:automatic-styles/
                       style:style[@style:name=(current()/
                       @text:style-name)]/@style:parent-style-name"/>

    <xsl:choose>
        <xsl:when test="$fontStyle='italic'">
            <emphasis><xsl:apply-templates/></emphasis>
        </xsl:when>
        <xsl:when test="$fontWeight='bold'">
            <emphasis role="strong"><xsl:apply-templates/></emphasis>
        </xsl:when>
        <xsl:when test="@text:style-name='Emphasis' 
                        or $parentStyleName='Emphasis'">
            <emphasis><xsl:apply-templates/></emphasis>
        </xsl:when>

        <xsl:when test="@text:style-name='Strong Emphasis' 
                        or $parentStyleName='Strong Emphasis'">
            <emphasis><xsl:attribute name="role">strong</xsl:attribute>
            <xsl:apply-templates/></emphasis>
        </xsl:when>

        <xsl:when test="@text:style-name='Citation' 
                        or $parentStyleName='Citation'">
            <quote><xsl:apply-templates/></quote>
        </xsl:when>

        <xsl:when test="@text:style-name='Source Text'
                        or @text:style-name='Example'
                        or @text:style-name='Teletype'
                        or @text:style-name='Literal'
                        or $parentStyleName='Source Text' 
                        or $parentStyleName='Example'
                        or $parentStyleName='Teletype'
                        or $parentStyleName='Literal'">
            <literal><xsl:apply-templates/></literal>
        </xsl:when>

        <xsl:when test="@text:style-name='User Entry' 
                        or $parentStyleName='User Entry'
                        or @text:style-name='Userentry' 
                        or $parentStyleName='Userentry'">
            <userinput><xsl:apply-templates/></userinput>
        </xsl:when>

        <xsl:when test="@text:style-name='Filename' 
                        or $parentStyleName='Filename'">
            <filename><xsl:apply-templates/></filename>	
        </xsl:when>

        <xsl:when test="@text:style-name='Computeroutput'
                        or $parentStyleName='Computeroutput'">
            <computeroutput><xsl:apply-templates/></computeroutput>	
        </xsl:when>

        <xsl:when test="@text:style-name='Command' 
                        or $parentStyleName='Command'">
        <command><xsl:apply-templates/></command>
        </xsl:when>

        <xsl:when test="@text:style-name='Option' 
                        or $parentStyleName='Option'">
            <option><xsl:apply-templates/></option>
        </xsl:when>

        <xsl:when test="@text:style-name='Acronym' 
                        or $parentStyleName='Acronym'">
            <acronym><xsl:apply-templates/></acronym>	
        </xsl:when>
        
        <xsl:when test="@text:style-name='Lineannotation' 
                        or $parentStyleName='Lineannotation'">
            <lineannotation><xsl:apply-templates/></lineannotation>	
        </xsl:when>

        <xsl:when test="@text:style-name='Replaceable' 
                        or $parentStyleName='Replaceable'">
            <replaceable><xsl:apply-templates/></replaceable>
        </xsl:when>

        <xsl:when test="@text:style-name='Attribution' 
                        or $parentStyleName='Attribution'">
            <attribution><xsl:apply-templates/></attribution>	
        </xsl:when>

        <xsl:when test="@text:style-name='Honorific' 
                        or $parentStyleName='Honorific'">
            <honorific><xsl:apply-templates/></honorific>	
        </xsl:when>

        <xsl:when test="@text:style-name='Firstname' 
                        or $parentStyleName='Firstname'">
            <firstname><xsl:apply-templates/></firstname>	
        </xsl:when>

        <xsl:when test="@text:style-name='Othername' 
                        or $parentStyleName='Othername'">
            <othername><xsl:apply-templates/></othername>	
        </xsl:when>

        <xsl:when test="@text:style-name='Surname' 
                        or $parentStyleName='Surname'">
            <surname><xsl:apply-templates/></surname>	
        </xsl:when>

        <xsl:when test="@text:style-name='Lineage'
                        or $parentStyleName='Lineage'">
            <lineage><xsl:apply-templates/></lineage>	
        </xsl:when>
        
        <xsl:when test="@text:style-name='Year' 
                        or $parentStyleName='Year'">
            <year><xsl:apply-templates/></year>	
        </xsl:when>

        <xsl:when test="@text:style-name='Holder' 
                        or $parentStyleName='Holder'">
            <holder><xsl:apply-templates/></holder>	
        </xsl:when>

        <xsl:when test="(@text:style-name='Email' 
                        or $parentStyleName='Email')">
            <email><xsl:apply-templates/></email>	
        </xsl:when>

        <xsl:when test="@text:style-name='Jobtitle' 
                        or $parentStyleName='Jobtitle'">
            <jobtitle><xsl:apply-templates/></jobtitle>	
        </xsl:when>

        <xsl:when test="@text:style-name='Orgname'
                        or $parentStyleName='Orgname'">
            <orgname><xsl:apply-templates/></orgname>	
        </xsl:when>

        <xsl:when test="@text:style-name='Citetitle' 
                        or $parentStyleName='Citetitle'">
            <citetitle><xsl:apply-templates/></citetitle>	
        </xsl:when>
        <xsl:otherwise>
	        <xsl:apply-templates/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- 
FOOTNOTES
=========
-->

<xsl:template match="text:footnote|text:endnote">
    <footnote>
        <xsl:if test="text:footnote-citation[@text:label]">
            <xsl:attribute name="label"><xsl:value-of
            select="text:footnote-citation/@text:label"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="text:endonote-citation[@text:label]">
            <xsl:attribute name="label"><xsl:value-of
                select="text:endnote-citation/@text:label"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="id"><xsl:value-of
            select="@text:id"/></xsl:attribute>
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

<!-- 
HYPERLINKS AND CROSS REFERENCES 
===============================
-->

<!-- L'attribut ID passe au parent des tags -->
<xsl:template match="text:reference-mark|text:bookmark|
                     text:reference-mark-start|text:bookmark-start">
	<phrase>
        <xsl:attribute name="id">
            <xsl:value-of select="@text:name"/>
        </xsl:attribute>
	</phrase>
</xsl:template>

<xsl:template match="text:reference-mark-end|text:bookmark-end"/>

<xsl:template match="text:reference-ref|text:bookmark-ref|
                     text:sequence-ref">
	<link>
		<xsl:attribute name="linkend">
            <xsl:value-of select="@text:ref-name"/>
        </xsl:attribute>
		<xsl:apply-templates/>
	</link>
</xsl:template>

<xsl:template match="text:a">
    <xsl:choose>
        <xsl:when test="text:span/@text:style-name='Email'">
            <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>
            <ulink>
                <xsl:attribute name="url">
                    <xsl:value-of select="@xlink:href"/>
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:value-of select="@office:target-frame-name"/>
                </xsl:attribute>
                <xsl:apply-templates/>
            </ulink>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- 
======
FRAMES
======
-->

<!-- Frame's position traetment -->

<xsl:template match="draw:text-box"/>
<xsl:template match="draw:a[draw:text-box]"/>

<xsl:template match="draw:image[@text:anchor-type='page']"/>
<xsl:template match="draw:image[(@text:anchor-type='paragraph') 
                     or (@text:anchor-type='char')]"/>
    
<xsl:template match="draw:a[draw:image[@text:anchor-type='page']]"/>
<xsl:template match="draw:a[draw:image[(@text:anchor-type='paragraph') 
                     or (@text:anchor-type='char')]]"/>

<xsl:template name="multimedia.top">
    <xsl:param name="calledPos" select="'top'"/>
        <xsl:apply-templates
            select=".//draw:image[(@text:anchor-type='paragraph' or
                    text:anchor-type='char') and
                    not(ancestor::draw:text-box)]|.//draw:text-box" 
            mode="extract">
                <xsl:with-param name="calledPos" select="$calledPos"/>
        </xsl:apply-templates>
</xsl:template>

<xsl:template name="multimedia.bottom">
    <xsl:param name="calledPos" select="'bottom'"/>
    <xsl:apply-templates
        select=".//draw:image[(@text:anchor-type='paragraph' 
                or text:anchor-type='char') 
                and not(ancestor::draw:text-box)]|
                .//draw:text-box" mode="extract">
        <xsl:with-param name="calledPos" select="$calledPos"/>
    </xsl:apply-templates>
</xsl:template>

<!-- Frames - Dispatch -->

<xsl:template match="draw:text-box" mode="extract">
    <xsl:param name="parentStyleName" 
               select="/office:document/office:automatic-styles/
                       style:style[@style:name=current()/
                       @draw:style-name]/@style:parent-style-name"/>
    <xsl:param name="calledPos"/>
    <xsl:param name="currentPos">
        <xsl:choose>
            <xsl:when test="/office:document/office:automatic-styles/
                            style:style[@style:name=current()
                            /@draw:style-name]/style:properties/
                            @style:vertical-pos!=''">
                <xsl:value-of 
                    select="/office:document/
                            office:automatic-styles/style:style
                            [@style:name=current()/@draw:style-name]
                            /style:properties/@style:vertical-pos"/>
            </xsl:when>
            <xsl:otherwise>top</xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <xsl:param name="inbox" select="1"/>
    <xsl:if test="$calledPos=$currentPos or 
        ($calledPos='top' and $currentPos!='bottom')">
        <xsl:if test="$parentStyleName='Note'">
            <xsl:call-template name="note"/>
        </xsl:if>
        <xsl:if test="$parentStyleName='Frame' 
                      or $parentStyleName='Graphics' ">
            <xsl:call-template name="figure"/>
        </xsl:if>
    </xsl:if>
</xsl:template>

<!-- Frames - Figure -->

<xsl:template name="figure">
    <figure>
        <xsl:attribute name="id">
            <xsl:value-of 
                select="text:p/text:sequence/@text:ref-name"/>
        </xsl:attribute>
        <title>
            <xsl:apply-templates select="text:p"/>
        </title>
        <mediaobject>
            <xsl:apply-templates 
                select=".//draw:image[(@text:anchor-type='paragraph') 
                        or (@text:anchor-type='char')]" 
                mode="extract"> 
                <xsl:with-param name="inbox" select="1"/>
            </xsl:apply-templates>
        </mediaobject>
    </figure>
</xsl:template>

<!-- Frames - Note -->

<xsl:template name="note">
    <xsl:param name="parentStyleName"
        select="/office:document/office:automatic-styles/
                style:style[@style:name=(current()/@text:style-name)]/
                @style:parent-style-name"/>
    <note>
        <xsl:apply-templates select="text:p[@text:style-name='Heading' 
                                     or $parentStyleName='Heading']" 
                             mode="includeTitle"/>
        <xsl:apply-templates mode="frame"/>
    </note>
</xsl:template>

<xsl:template match="*" mode="frame">
    <xsl:call-template name="allTags">
        <xsl:with-param name="source" select="'frame'"/>
    </xsl:call-template>
</xsl:template>
<!--
======
IMAGES
======
-->

<xsl:template match="draw:image" mode="extract">
	<xsl:param name="calledPos"/>
	<xsl:param name="currentPos">
		<xsl:choose>
			<xsl:when test="/office:document/office:automatic-styles/
                            style:style[@style:name=current()/
                            @draw:style-name]/style:properties/
                            @style:vertical-pos!=''">
				<xsl:value-of 
                    select="/office:document/office:automatic-styles/
                    style:style[@style:name=current()/
                    @draw:style-name]/style:properties/
                    @style:vertical-pos"/>
			</xsl:when>
			<xsl:otherwise>top</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="inbox"/>
    <xsl:choose>
     		<xsl:when test="substring-before(@xlink:href,'/')='#Pictures' 
                            or office:binary-data">
			<xsl:if test="$calledPos=$currentPos or 
                ($calledPos='top' and $currentPos!='bottom')">
                <para>WARNING ! Incorporated graphics are not supported.</para>
			</xsl:if>
			
		</xsl:when>
        <xsl:otherwise>
     	<xsl:choose>
		<xsl:when test="$inbox=1">
			<xsl:call-template name="image"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="$calledPos=$currentPos or 
                ($calledPos='top' and $currentPos!='bottom')">
				    <mediaobject>
				    	<xsl:call-template name="image"/>
				    </mediaobject>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="image">
    <imageobject> 
        <imagedata>
            <xsl:attribute name="fileref">
                <xsl:value-of select="@xlink:href"/>
            </xsl:attribute>
            <xsl:attribute name="width">
                <xsl:value-of select="@svg:width"/>
            </xsl:attribute>
            <xsl:attribute name="depth">
                <xsl:value-of select="@svg:height"/>
            </xsl:attribute>
        </imagedata>
    </imageobject>
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="text:p[@text:style-name='Illustration']|
                     text:p[@text:style-name='Figure']">
    <xsl:choose>
        <xsl:when test="text:sequence">
	            <xsl:apply-templates
                select="text:sequence/following-sibling::node()"/>
        </xsl:when>
        <xsl:otherwise>
	            <xsl:apply-templates/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Inlines images -->

<xsl:template match="draw:image[@text:anchor-type='as-char']">
<!--<node><xsl:value-of select="count(../node()) - c
ount(../text:line-break) 
- count(../text:s) - count(../text:tab-stop)"/></node>
<xsl:if test="count(../node())=1">
</xsl:if>-->
    <inlinemediaobject>
        <xsl:call-template name="image"/>
    </inlinemediaobject>
</xsl:template>

<xsl:template match="draw:a[draw:image[@text:anchor-type='as-char']]">
    <ulink>
		<xsl:attribute name="url">
            <xsl:value-of select="@xlink:href"/>
        </xsl:attribute>
        <xsl:if test="@office:target-frame-name!=''">
            <xsl:attribute name="type">
                <xsl:value-of select="@office:target-frame-name"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates/>
    </ulink>
</xsl:template>

<xsl:template match="svg:desc">
	<textobject><phrase><xsl:apply-templates/></phrase></textobject>
</xsl:template>

<!-- 
======
TABLES
======
-->
<xsl:template match="table:table" name="table">
    <xsl:param name="titlePosition" select="''"/>
   	<xsl:param name="colsListBrut">
        <xsl:call-template name="colsList"/>
   	</xsl:param>

  	<!-- Retrait des doublons et ordonnancement de la liste -->
  	<xsl:param name="fineColsList">
		<xsl:call-template name="fineColsList">
			<xsl:with-param name="colsListBrut" select="$colsListBrut"/>
		</xsl:call-template>
  	</xsl:param>
  	<xsl:param name="colsList">
		<xsl:call-template name="ascendantcolsList">
			<xsl:with-param name="colsList" select="$fineColsList"/>
		</xsl:call-template>
  	</xsl:param>
  	<xsl:param name="colsNumber2">
		<xsl:call-template name="colsNumber2">
			<xsl:with-param name="colsList" select="$colsList"/>
		</xsl:call-template>
  	</xsl:param>
    <xsl:choose>
        <xsl:when test="following-sibling::*[1]/text:sequence/@text:name='Table'">
            <xsl:call-template name="formalTable">
                <xsl:with-param name="titlePosition" select="'after'"/>
				<xsl:with-param name="colsList" select="$colsList"/>
				<xsl:with-param name="colsNumber" select="$colsNumber2"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
                <xsl:when test="preceding-sibling::*[1]/text:sequence/@text:name='Table'">
                    <xsl:call-template name="formalTable">
                        <xsl:with-param name="titlePosition" select="'before'"/>
                        <xsl:with-param name="colsList" select="$colsList"/>
                        <xsl:with-param name="colsNumber" select="$colsNumber2"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="informalTable">
                        <xsl:with-param name="colsList" select="$colsList"/>
                        <xsl:with-param name="colsNumber" select="$colsNumber2"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>



<!-- Tables - "Formal" Table -->
<xsl:template name="formalTable">
    <xsl:param name="titlePosition"/>
	<xsl:param name="colsList"/>
	<xsl:param name="colsNumber"/>
    <table>
    <!-- Title and 'id' attribute -->
            <xsl:if test="$titlePosition='before'">
                <xsl:attribute name="id">
                    <xsl:value-of 
                        select="preceding-sibling::*[1]/text:sequence/@text:ref-name"/>
                </xsl:attribute>
                <xsl:apply-templates select="preceding-sibling::*[1]" mode="tableTitle"/>
            </xsl:if>
            <xsl:if test="$titlePosition='after'">
                <xsl:attribute name="id">
                    <xsl:value-of 
                        select="following-sibling::*[1]/text:sequence/@text:ref-name"/>
                </xsl:attribute>
                <xsl:apply-templates select="following-sibling::*[1]" mode="tableTitle"/>
            </xsl:if>
        <tgroup>
        	<xsl:attribute name="cols">
                <xsl:value-of select="$colsNumber"/>
            </xsl:attribute>
	        <xsl:call-template name="colspecAttrib">
				<xsl:with-param name="colsList" select="$colsList"/>
				<xsl:with-param name="colsNumber" select="$colsNumber"/>
			</xsl:call-template>
	        <xsl:apply-templates select="table:table-row|table:table-header-rows/table:table-row">
				<xsl:with-param name="colsList" select="$colsList"/>
			</xsl:apply-templates>
        </tgroup>
    </table>
</xsl:template>


<!-- Table - Formaltable title -->

<xsl:template match="*[text:sequence]" mode="tableTitle">
    <title>
        <xsl:apply-templates
            select="text:sequence/following-sibling::node()"/>
    </title>    
</xsl:template>


<!-- Tables - InformalTables -->
<xsl:template name="informalTable">
	<xsl:param name="colsList"/>
	<xsl:param name="colsNumber"/>
	<informaltable>
        <tgroup>
        	<xsl:attribute name="cols">
                <xsl:value-of select="$colsNumber"/>
            </xsl:attribute>
	        <xsl:call-template name="colspecAttrib">
				<xsl:with-param name="colsList" select="$colsList"/>
				<xsl:with-param name="colsNumber" select="$colsNumber"/>
			</xsl:call-template>
	        <xsl:apply-templates select="table:table-row|table:table-header-rows/table:table-row">
				<xsl:with-param name="colsList" select="$colsList"/>
			</xsl:apply-templates>
        </tgroup>
    </informaltable>
</xsl:template>

<!-- 
=================
COLUMNS & COLSPEC
=================
-->

<!-- Tables - Colspec attribute -->
<xsl:template name="colspecAttrib">
	<xsl:param name="colsList"/>
	<xsl:param name="colsNumber"/>
	<xsl:param name="val1" select="0"/>
	<xsl:param name="val2" select="substring-before($colsList,';')"/>
	<xsl:param name="width">
		<xsl:call-template name="roundValue">
			<xsl:with-param name="inputValue" select="$val2 - $val1"/>
		</xsl:call-template>
	</xsl:param>
	<xsl:param name="cycle" select="1"/>
	 	<xsl:if test="$colsNumber >= $cycle">
			<colspec>
				<xsl:attribute name="colname">
						<xsl:value-of select="concat('c',$cycle)"/>
				</xsl:attribute>
				<xsl:attribute name="colwidth">
						<xsl:value-of select="concat($width,$measureUnit)"/>
				</xsl:attribute>
			</colspec>
			<xsl:call-template name="colspecAttrib">
				<xsl:with-param name="colsList" select="substring-after($colsList,';')"/>
				<xsl:with-param name="cycle" select="$cycle + 1"/>
				<xsl:with-param name="val1" select="$val2"/>
				<xsl:with-param name="colsNumber" select="$colsNumber"/>
			</xsl:call-template>
		</xsl:if>
</xsl:template>

<!-- 
Tables - ascendantcolsList, colsListtrunc, littleElt
		 Ordonnent de facon ascendante les elements de 'colsList"
-->
<xsl:template name="ascendantcolsList">
	<xsl:param name="colsList"/>
	<xsl:param name="eltNumber">
		<xsl:call-template name="colsNumber2">
			<xsl:with-param name="colsList" select="$colsList"/>
		</xsl:call-template>
	</xsl:param>
	<xsl:param name="littleElt">
		<xsl:call-template name="littleElt">
			<xsl:with-param name="colsListTest" select="$colsList"/>
		</xsl:call-template>
	</xsl:param>
	<xsl:param name="colsListtrunc">
	<xsl:call-template name="colsListtrunc">
		<xsl:with-param name="colsListTest" select="$colsList"/>
		<xsl:with-param name="littleElt" select="$littleElt"/>
	</xsl:call-template>
	</xsl:param>
	<xsl:param name="newList" select="''"/>
	<xsl:choose>
	<xsl:when test="not(contains($colsListtrunc,';'))">
		<xsl:value-of select="concat($newList, $littleElt,';')"/>
	 </xsl:when>
	 <xsl:otherwise>
	 	<xsl:call-template name="ascendantcolsList">
			<xsl:with-param name="newList" select="concat($newList, $littleElt,';')"/>
			<xsl:with-param name="colsList" select="$colsListtrunc"/>
		</xsl:call-template>
	 </xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="colsListtrunc">
	<xsl:param name="colsListTest"/>
	<xsl:param name="littleElt"/>
	<xsl:param name="eltCompare" select="substring-before($colsListTest,';')"/>
	<xsl:param name="fragmentBefore" select="''"/>
	<xsl:param name="fragmentAfter" select="substring-after($colsListTest,';')"/>
	<xsl:choose>
	 	<xsl:when test="($littleElt != $eltCompare) and ($fragmentAfter != '')">
			<xsl:call-template name="colsListtrunc">
			<xsl:with-param name="fragmentBefore">
	 			<xsl:value-of select="concat($fragmentBefore,';',$eltCompare)"/>
			</xsl:with-param>
			<xsl:with-param name="littleElt" select="$littleElt"/>
			<xsl:with-param name="colsListTest" select="$fragmentAfter"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
	 			<xsl:when test="starts-with(concat($fragmentBefore,';',$fragmentAfter),';')">
					<xsl:value-of select="substring-after(concat($fragmentBefore,';',$fragmentAfter),';')"/>	
				</xsl:when>
				<xsl:otherwise>
	 				<xsl:value-of select="concat($fragmentBefore,';',$fragmentAfter)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="littleElt">
	<xsl:param name="colsListTest"/>
	<xsl:param name="eltBaseTest" select="substring-before($colsListTest,';')"/>
	<xsl:param name="eltNumber">
		<xsl:call-template name="colsNumber2">
			<xsl:with-param name="colsList" select="$colsListTest"/>
		</xsl:call-template>
	</xsl:param>
	<xsl:param name="actualMinDiff" select="$eltBaseTest"/>
	<xsl:choose>
	 <xsl:when test="$eltNumber > 0">
		<xsl:call-template name="littleElt">
			<xsl:with-param name="actualMinDiff">
				<xsl:choose>
	 				<xsl:when test="$actualMinDiff > $eltBaseTest">
						<xsl:value-of select="$eltBaseTest"/>
					</xsl:when>
					<xsl:otherwise>
	 					<xsl:value-of select="$actualMinDiff"/>	
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="colsListTest" select="substring-after($colsListTest,';')"/>
		</xsl:call-template>
	 </xsl:when>
	 <xsl:otherwise>
	 	<xsl:value-of select="$actualMinDiff"/>
	 </xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- 
Tables - fineColsList et testDoublon
		 Elimine les blancs et les doublon de "colsList"
-->
<xsl:template name="fineColsList">
	<xsl:param name="colsListBrut"/>
	<xsl:param name="eltNumber">
		<xsl:call-template name="colsNumber2">
			<xsl:with-param name="colsList" select="$colsListBrut"/>
		</xsl:call-template>
	</xsl:param>
	<xsl:param name="colsListTest" select="substring-after($colsListBrut,';')"/>
	<xsl:param name="eltBaseTest" select="normalize-space(substring-before($colsListBrut,';'))"/>
	<xsl:param name="eltTestresult"><!-- 'True' si doublon -->
		<xsl:call-template name="testDoublon">
			<xsl:with-param name="colsListTest" select="$colsListTest"/>
			<xsl:with-param name="eltBaseTest" select="$eltBaseTest"/>
		</xsl:call-template>
	</xsl:param>
	<xsl:param name="newList" select="''"/>
	<xsl:choose>
	 <xsl:when test="$eltNumber = 1">
		<xsl:value-of select="concat(normalize-space($eltBaseTest),';',$newList)"/>
	 </xsl:when>
	 <xsl:otherwise>
	 	<xsl:call-template name="fineColsList">
			<xsl:with-param name="newList">
				<xsl:choose>
	 				<xsl:when test="$eltTestresult = 'false'">
						<xsl:value-of select="concat($eltBaseTest,';', $newList)"/>
					</xsl:when>
					<xsl:otherwise>
	 					<xsl:value-of select="$newList"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="colsListBrut" select="$colsListTest"/>
		</xsl:call-template>
	 </xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="testDoublon">
	<xsl:param name="colsListTest"/>
	<xsl:param name="eltNumber">
		<xsl:call-template name="colsNumber2">
			<xsl:with-param name="colsList" select="$colsListTest"/>
		</xsl:call-template>
	</xsl:param>
	<xsl:param name="eltBaseTest"/>
	<xsl:param name="eltListTest" select="normalize-space(substring-before($colsListTest,';'))"/>
	
	<xsl:choose>
	 	<xsl:when test="$eltBaseTest = $eltListTest">
			<xsl:value-of select="'true'"/>
		</xsl:when>
		<xsl:when test="$eltListTest =''">
			<xsl:value-of select="'false'"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="$eltNumber >= 1">
				<xsl:call-template name="testDoublon">
					<xsl:with-param name="colsListTest" select="substring-after($colsListTest,';')"/>
					<xsl:with-param name="eltBaseTest" select="$eltBaseTest"/>
				</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'false'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--
Tables - colsNumber2 
Cree les numeros (1, 2, etc.) qui formeront les element de colspec (c1,c2, etc)
-->
<xsl:template name="colsNumber2">
	<xsl:param name="colsList"/>
	<xsl:param name="cycle" select="0"/>
	<xsl:choose>
	 <xsl:when test="contains($colsList,';')">
		<xsl:call-template name="colsNumber2">
			<xsl:with-param name="colsList" select="substring-after($colsList,';')"/>
			<xsl:with-param name="cycle" select="$cycle + 1"/>
		</xsl:call-template>
	 </xsl:when>
	 <xsl:otherwise>
	 	<xsl:value-of select="$cycle"/>
	 </xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Tables - colsList -->

<xsl:template name="colsList">
    <xsl:param name="stylesURI" select="/office:document/office:automatic-styles/style:style"/>
	<xsl:param name="repeatCol"/>
	<xsl:param name="cellAncestorNbr"/>
	<xsl:for-each select="descendant::table:table-column">
		<xsl:call-template name="colPosition">
			<xsl:with-param name="origineValue">				
				<!-- retourne la distance d'origine de la sous-table 
				depuis la cellule-ancetre la plus elevee -->
				<xsl:choose>
					<xsl:when test="parent::table:sub-table">
						<xsl:call-template name="subtableOrigine">
							<xsl:with-param name="cellAncestorNbr" 
								select="count(ancestor::table:table-cell)"/>
							<xsl:with-param name="stylesURI" select="$stylesURI"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="stylesURI" select="$stylesURI"/>
			<xsl:with-param name="repeatCol">
				<xsl:choose>
					<xsl:when test="@table:number-columns-repeated">
						<xsl:value-of select="@table:number-columns-repeated"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="1"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
    </xsl:for-each>
</xsl:template>

<!-- 
Determine le distance a laquelle debute la sous-table / a la table
pour la colonne en cours
-->
<xsl:template name="subtableOrigine">
<xsl:param name="cumulOrigineValue" select="0"/>
<xsl:param name="cellAncestorNbr"/>
<xsl:param name="stylesURI"/>
<xsl:param name="precedingCellNumber" 
	select="count(ancestor::table:table-cell[$cellAncestorNbr]
		/preceding-sibling::table:table-cell) - 
		count(ancestor::table:table-cell[$cellAncestorNbr]
		/preceding-sibling::table:table-cell[@table:number-columns-spanned]) + 
		sum(ancestor::table:table-cell[$cellAncestorNbr]/
		preceding-sibling::table:table-cell/@table:number-columns-spanned)"
		/>
<xsl:param name="columnValue">
<xsl:choose>
	 <xsl:when test="$precedingCellNumber > 0">
		<xsl:apply-templates 
			select="ancestor::table:table-cell[$cellAncestorNbr]/parent::table:table-row/ 
					parent::table:table/child::table:table-column[1]|
					ancestor::table:table-cell[$cellAncestorNbr]/parent::table:table-row/
					parent::table:sub-table/child::table:table-column[1]|
					ancestor::table:table-cell[$cellAncestorNbr]/parent::table:table-row/ 
					parent::table:table-header-rows/parent::table:table/child::table:table-column[1]"
			mode="cellOrigine">
		<xsl:with-param name="precedingCellNumber" select="$precedingCellNumber"/>
		<xsl:with-param name="stylesURI" select="$stylesURI"/>
	</xsl:apply-templates>
	 </xsl:when>
	 <xsl:otherwise>0</xsl:otherwise>
</xsl:choose>
</xsl:param>
	<!-- Appel de l'ancetre no X -->
	<xsl:choose>
		<xsl:when test="$cellAncestorNbr > 1">
			<xsl:call-template name="subtableOrigine">
				<xsl:with-param name="cellAncestorNbr" select="$cellAncestorNbr - 1"/>
				<xsl:with-param name="cumulOrigineValue" select="$cumulOrigineValue + $columnValue"/>
				<xsl:with-param name="stylesURI" select="$stylesURI"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
	 		<xsl:value-of select="$cumulOrigineValue + $columnValue"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="table:table-column" mode="cellOrigine" name="cellOrigine">
	<xsl:param name="stylesURI"/>
	<xsl:param name="precedingCellNumber"/>
	<xsl:param name="colName" select="string(@table:style-name)"/>
	<xsl:param name="repetingCol">
		<xsl:choose>
	 		<xsl:when test="@table:number-columns-repeated">
				<xsl:value-of select="@table:number-columns-repeated"/>
			</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="colsNamesList" select="''"/>
	<xsl:param name="origineValue" select="0"/>
	<xsl:param name="actualWidth">
		<xsl:value-of select="substring-before($stylesURI[@style:name=$colName]
							 /style:properties/@style:column-width,$measureUnit)"/>
	</xsl:param>
	<xsl:choose>
		<xsl:when test="$repetingCol >= $precedingCellNumber">
			<xsl:value-of select="$origineValue + ($actualWidth * $precedingCellNumber)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="following-sibling::table:table-column[1]" 
				mode="cellOrigine">
				<xsl:with-param name="precedingCellNumber" 
					select="$precedingCellNumber -  $repetingCol"/>
				<xsl:with-param name="colsNamesList" 
					select="concat($colsNamesList,';',$colName)"/>
				<xsl:with-param name="origineValue"
					select="$origineValue + ($actualWidth * $repetingCol)"/>
				<xsl:with-param name="stylesURI" select="$stylesURI"/>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="colPosition">
	<!-- externes -->
    <xsl:param name="stylesURI"/>
	<xsl:param name="origineValue"/>
	<xsl:param name="concat"/>
	<xsl:param name="repeatCol"/>
	<xsl:param name="content"/>
	<xsl:param name="precedingColsSum">
		<xsl:choose>
	 		<xsl:when test="preceding-sibling::table:table-column">
				<xsl:call-template name="precedingColsSum">
					<xsl:with-param name="stylesURI" select="$stylesURI"/>
				</xsl:call-template>	
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="actualColWidth">
		<xsl:value-of select="
			$stylesURI[@style:name=current()/@table:style-name]/ 
			style:properties/@style:column-width
			"/>
	</xsl:param>
 	<xsl:param name="colWidthValue">
		<xsl:value-of select="substring-before($actualColWidth,$measureUnit)"/>
	</xsl:param>
	<xsl:param name="colWidthRounded">
		<xsl:call-template name="roundValue">
			<xsl:with-param name="inputValue" 
				select="$origineValue + $precedingColsSum +  
						($colWidthValue * $repeatCol)"/>
		</xsl:call-template>	
	</xsl:param>
	<xsl:value-of 
		select="$colWidthRounded"/>;
	<xsl:if test="$repeatCol > 1">
		<xsl:call-template name="colPosition">
			<xsl:with-param name="repeatCol" select="$repeatCol - 1"/>
			<xsl:with-param name="stylesURI" select="$stylesURI"/>
			<xsl:with-param name="origineValue" select="$origineValue"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<xsl:template name="precedingColsSum">
	<!-- externe -->
    <xsl:param name="stylesURI"/>
	<!--interne -->
	<xsl:param name="cpt" select="'1'"/>
    <xsl:param name="cumul" select="'0'"/>
    <xsl:param name="precNodeNumber" select="count(preceding-sibling::table:table-column)"/>
	<xsl:param name="content">
	<xsl:choose>
		 <xsl:when test="
		 	$stylesURI[@style:name=current()/
			preceding-sibling::table:table-column[$precNodeNumber]/
			@table:style-name]/
			style:properties/@style:column-width">
			<xsl:value-of select="
				$stylesURI[@style:name=current()/
				preceding-sibling::table:table-column[$precNodeNumber]/
				@table:style-name]/
				style:properties/@style:column-width"/>
		 </xsl:when>
		 <xsl:otherwise>0pt</xsl:otherwise>
	</xsl:choose>
	</xsl:param>
	<xsl:param name="repetCols">
		<xsl:choose>
	 		<xsl:when test="preceding-sibling::table:table-column[$precNodeNumber]/
			@table:number-columns-repeated">
	 			<xsl:value-of select="number(preceding-sibling::table:table-column
				[$precNodeNumber]/@table:number-columns-repeated)"/>
	 		</xsl:when>
	 		<xsl:otherwise>1</xsl:otherwise>
	</xsl:choose>
	</xsl:param>
    <xsl:param name="brutValue">
		<xsl:value-of select="substring-before(string($content),$measureUnit)"/>
	</xsl:param>
	<xsl:param name="actualValue" select="$brutValue * $repetCols"/>
	<xsl:if test="$precNodeNumber > 0">
		<xsl:call-template name="precedingColsSum">
			<xsl:with-param name="precNodeNumber" select="$precNodeNumber - 1"/>
			<xsl:with-param name="cumul" select="$cumul + $actualValue"/>
			<xsl:with-param name="stylesURI" select="$stylesURI"/>
		</xsl:call-template>
	</xsl:if>
	<xsl:if test="$precNodeNumber = 1">
		<xsl:value-of select="$actualValue + $cumul"/>
	</xsl:if>
</xsl:template>

<!-- 
====
ROWS
====
-->

<!-- Tables - Rows in table-header -->

<xsl:template match="table:table-header-rows/table:table-row">
	<xsl:param name="colsList"/>
	 <xsl:choose>
		<xsl:when test="count(preceding-sibling::table:table-row) != 0"/>
		<xsl:otherwise>
    <thead>
		 <xsl:apply-templates select="current()" mode="pas">
			<xsl:with-param name="colsList" select="$colsList"/>
		 </xsl:apply-templates>
	</thead>
	 </xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Tables - Rows directly in table or sub-table (body) -->

<xsl:template match="table:table/table:table-row|table:sub-table/table:table-row">
     <xsl:param name="colsList"/>

	 <xsl:choose>
		<xsl:when test="count(preceding-sibling::table:table-row) != 0"/>
		<xsl:otherwise>
		 <tbody>
			<xsl:apply-templates select="current()" mode="pas">
				<xsl:with-param name="colsList" select="$colsList"/>
			</xsl:apply-templates>
		 </tbody>		
	 </xsl:otherwise>
	</xsl:choose>
</xsl:template>	

<!-- Tables - process rows -->

<xsl:template match="table:table-row" mode="pas">
	<xsl:param name="colsList"/>
	<xsl:param name="rowID" select="generate-id(current())"/>
	<xsl:call-template name="rowsProcess">
		<xsl:with-param name="colsList" select="$colsList"/>
		<xsl:with-param name="rowID" select="$rowID"/>
	</xsl:call-template>
  	<xsl:apply-templates 
		select="following-sibling::table:table-row[1]"
	    mode="pas">
		<xsl:with-param name="colsList" select="$colsList"/>
	</xsl:apply-templates>
</xsl:template>
 
<xsl:template name="rowsProcess">
	<xsl:param name="colsList"/>
	<xsl:param name="rowID"/>
	<xsl:param name="maxRowsInSubtablesList">
        <xsl:choose>
            <xsl:when test="table:table-cell/table:sub-table">
				<xsl:apply-templates 
					select="table:table-cell[table:sub-table][1]" 
					mode="pas"/>
            </xsl:when>
            <xsl:otherwise>1;</xsl:otherwise>
        </xsl:choose>
	</xsl:param>
	<xsl:param name="maxRowsInSubtables">
		<xsl:value-of select="substring-before($maxRowsInSubtablesList,';')"/>
	</xsl:param>
	<xsl:param name="cycle" select="0"/>
	<xsl:param name="lastRow">
		<xsl:choose>
	 		<xsl:when test="$maxRowsInSubtables = $cycle">yes</xsl:when>
			<xsl:otherwise>no</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:if test="$maxRowsInSubtables > $cycle">
		<row>
			<xsl:apply-templates 
				select="descendant::table:table-cell[not(table:sub-table)]" 
				mode="rowProcess">
				<xsl:with-param name="cycle" select="$cycle"/>
				<xsl:with-param name="rowID" select="$rowID"/>
				<xsl:with-param name="colsList" select="$colsList"/>
				<xsl:with-param name="lastRow" select="$lastRow"/>
				<xsl:with-param name="maxRowsInSubtables" 
								select="$maxRowsInSubtables"/>
			</xsl:apply-templates>
		</row>
		<xsl:call-template name="rowsProcess">
			<xsl:with-param name="cycle" select="$cycle + 1"/>
			<xsl:with-param name="colsList" select="$colsList"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- Table - Rows tools -->

<!-- Ce modele retourne le nombre de lignes (au sens de la Docbook) 
qui precedent la ligne courante -->

<xsl:template match="table:table-row" mode="precedingDepth">
	<xsl:param name="rowID"/>
	<xsl:param name="depthCumul"  select="0"/>
	<xsl:param name="precedingSiblingDepth">
		<xsl:for-each select="preceding-sibling::table:table-row">
			<xsl:apply-templates select="table:table-cell[1]" mode="pas"/>
		</xsl:for-each>
	</xsl:param>
	<xsl:param name="precedingSiblingDepthValue">
	<xsl:choose>
		 <xsl:when test="$precedingSiblingDepth != ''">
				<xsl:call-template name="sumOfList">
					<xsl:with-param name="list" select="$precedingSiblingDepth"/>
				</xsl:call-template>
		 </xsl:when>
		 <xsl:otherwise>0</xsl:otherwise>
	</xsl:choose>
	</xsl:param>
	<xsl:choose>
		 <xsl:when 
		 	test="generate-id(ancestor::table:table-cell[1]/
				  parent::table:table-row) != $rowID">
			<xsl:apply-templates 
				select="ancestor::table:table-cell[1]/parent::table:table-row" 
				mode="precedingDepth">
				<xsl:with-param 
					name="depthCumul" 
					select="$depthCumul + $precedingSiblingDepthValue"/>
				<xsl:with-param name="rowID" select="$rowID"/>
			</xsl:apply-templates>
		 </xsl:when>
		 <xsl:otherwise>
			<xsl:value-of select="$depthCumul"/>
		 </xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Ce modele retourne le nombre de lignes (au sens de la Docbook) 
qui suivent la ligne courante -->

<xsl:template match="table:table-row" mode="followingDepth">
	<xsl:param name="rowID"/>
	<xsl:param name="depthCumul"  select="0"/>
	<xsl:param name="followingSiblingDepth">
		<xsl:for-each select="following-sibling::table:table-row">
			<xsl:apply-templates select="table:table-cell[1]" mode="pas"/>
		</xsl:for-each>
	</xsl:param>
	<xsl:param name="followingSiblingDepthValue">
	<xsl:choose>
		 <xsl:when test="$followingSiblingDepth != ''">
				<xsl:call-template name="sumOfList">
					<xsl:with-param name="list" select="$followingSiblingDepth"/>
				</xsl:call-template>
		 </xsl:when>
		 <xsl:otherwise>0</xsl:otherwise>
	</xsl:choose>
	</xsl:param>
	<xsl:choose>
		 <xsl:when 
		 	test="generate-id(ancestor::table:table-cell[1]/
				  parent::table:table-row) != $rowID">
			<xsl:apply-templates 
				select="ancestor::table:table-cell[1]/parent::table:table-row" 
				mode="followingDepth">
				<xsl:with-param 
					name="depthCumul" 
					select="$depthCumul + $followingSiblingDepthValue"/>
				<xsl:with-param name="rowID" select="$rowID"/>
			</xsl:apply-templates>
		 </xsl:when>
		 <xsl:otherwise>
			<xsl:value-of select="$depthCumul"/>
		 </xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- 
Ce modele retourne la profondeur de lignes de la ligne courante si 
elle contient des cellules avec une sous-table)
Il retourne une valeur de type x; (afin d'en faire une liste si besoin)
Ne retourne rien si pas de sous-table.
-->

<xsl:template match="table:table-cell" mode="pas">
	<xsl:param name="depth" select="'table'"/>
	<xsl:param name="nucleon" select="'sub'"/>
	<xsl:param name="maxDepthRows" select="1"/>
	<xsl:param name="subtablesDepthRows">
		<xsl:choose>
			<xsl:when 
				test="table:sub-table/table:table-row/ 
					  table:table-cell/table:sub-table">
				<xsl:apply-templates 
					select="table:sub-table/table:table-row/
						    table:table-cell[table:sub-table][1]" 
					mode="pas">
					<xsl:with-param name="depth" select="concat($nucleon, '-', $depth)"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="stDepthRowsSum">
		<xsl:call-template name="sumOfList">
			<xsl:with-param name="list" select="$subtablesDepthRows"/>
		</xsl:call-template>
	</xsl:param>
	<xsl:param 	name="depthRows" 
				select="count(table:sub-table/table:table-row
						[not(descendant::table:sub-table)])"/>
	<xsl:param name="totalDepthRows" select="$depthRows + $stDepthRowsSum"/>
	<xsl:choose>
	 	<xsl:when test="following-sibling::table:table-cell[table:sub-table]">
			<xsl:apply-templates 
				select="following-sibling::table:table-cell[table:sub-table][1]"
				mode="pas">
				<xsl:with-param name="maxDepthRows">
					<xsl:choose>
	 					<xsl:when test="$totalDepthRows > $maxDepthRows">
							<xsl:value-of select="$totalDepthRows"/>
						</xsl:when>
						<xsl:otherwise>
	 						<xsl:value-of select="$maxDepthRows"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="depth" select="$depth"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="$totalDepthRows > $maxDepthRows">
					<xsl:value-of select="concat($totalDepthRows,';')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($maxDepthRows,';')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--
==========
TABLE:CELL
==========
-->

<!-- Ce modele est la racine du traitement des cellules -->

<xsl:template match="table:table-cell" mode="rowProcess">
	<xsl:param name="colsList"/>
	<xsl:param name="cycle"/>
	<xsl:param name="maxRowsInSubtables"/>
	<xsl:param name="rowID"/>
	<xsl:param name="lastRow"/>
	<xsl:param name="namest">
		<xsl:call-template name="cellStart">
			<xsl:with-param name="colsList" select="$colsList"/>
		</xsl:call-template>
	</xsl:param>
	<xsl:param name="nameend">
		<xsl:call-template name="cellEnd">
			<xsl:with-param name="colsList" select="$colsList"/>
		</xsl:call-template>
	</xsl:param>
	<xsl:param name="precedingDepth">
		<xsl:choose>
	 		<xsl:when test="generate-id(parent::table:table-row) != $rowID">
				<xsl:apply-templates 
					select="parent::table:table-row" 
					mode="precedingDepth"/>
			</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="precedingDepthValue">
		<xsl:choose>
	 		<xsl:when test="$precedingDepth != 'false'">
				<xsl:value-of select="$precedingDepth"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="followingDepth">
		<xsl:choose>
	 		<xsl:when test="generate-id(parent::table:table-row) != $rowID">
				<xsl:apply-templates 
					select="parent::table:table-row" 
					mode="followingDepth"/>
			</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="followingDepthValue">
		<xsl:choose>
	 		<xsl:when test="$followingDepth != 'false'">
				<xsl:value-of select="$followingDepth"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="moreRowsBrut">
		<xsl:choose>
	 		<xsl:when test="parent::table:table-row/
							child::table:table-cell[table:sub-table]
							and not(table:sub-table)">
				<xsl:apply-templates 
					select="parent::table:table-row/child::table:table-cell
							[table:sub-table][1]" 
					mode="pas"/>
			</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="moreRowsValue">
		<xsl:choose>
			 <xsl:when test="$moreRowsBrut != ''">
				<xsl:call-template name="sumOfList">
					<xsl:with-param name="list" select="$moreRowsBrut"/>
				</xsl:call-template>
			 </xsl:when>
			 <xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="moreRows">
		<xsl:choose>
	 		<xsl:when test="($followingDepthValue = 0) and 
							 $maxRowsInSubtables > ($precedingDepthValue + $moreRowsValue)">
				<xsl:value-of select="$maxRowsInSubtables - $precedingDepthValue "/>
			</xsl:when>
			<xsl:otherwise>
	 			<xsl:value-of select="$moreRowsValue"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:param name="contenu" select="text:p/text()"/>
	<xsl:if test="$cycle = $precedingDepthValue">
		<xsl:call-template name="entryNormal">
			<xsl:with-param name="moreRowsValue" select="$moreRows - 1"/>
			<xsl:with-param name="namestValue" select="$namest"/>
			<xsl:with-param name="nameendValue" select="$nameend"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- Retourne le debut  de la cellule appelante au sens Docbook (namest)-->
<xsl:template name="cellStart">
	<xsl:param name="colsList"/>
	<xsl:param name="extremite" select="'start'"/>
	<xsl:param name="cellPosition">
		<xsl:choose>
	 		<xsl:when test="preceding-sibling::table:table-cell">
				<xsl:apply-templates 
					select="preceding-sibling::table:table-cell[1]" 
					mode="cellPosition">
					<xsl:with-param name="extremite" select="$extremite"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					 <xsl:when test="../parent::table:sub-table">
					 	<xsl:apply-templates 
							select="../../table:table-column[1]"
							mode="subtablePosition"/>
					 </xsl:when>
					 <xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="order">
		<xsl:choose>
			<xsl:when test="$cellPosition != 0">
				<xsl:call-template name="position2order">
					<xsl:with-param name="colsList" select="$colsList"/>
					<xsl:with-param name="cellPosition" select="$cellPosition"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:value-of select="$order"/>
</xsl:template>

<!-- Retourne la fin de la cellule appelante au sens Docbook (nameend) -->
<xsl:template name="cellEnd">
<xsl:param name="colsList"/>
<xsl:param name="extremite" select="'end'"/>
	<xsl:param name="cellPosition">
		<xsl:apply-templates select="current()" 
			mode="cellPosition">
			<xsl:with-param name="extremite" select="$extremite"/>
			<xsl:with-param name="colsList" select="$colsList"/>
		</xsl:apply-templates>
	</xsl:param>
	<xsl:param name="order">
		<xsl:call-template name="position2order">
			<xsl:with-param name="colsList" select="$colsList"/>
			<xsl:with-param name="cellPosition" select="$cellPosition"/>
		</xsl:call-template>
	</xsl:param>
	<xsl:value-of select="$order"/>
</xsl:template>

<!-- 
Retourne le numero de colonne de la cellule en fonction de sa 
position absolue dans le tableau.
Requiert : 
- "colsList" = liste des position absolues de colonnes
- "cellPosition" = position absolue de la cellule
-->
<xsl:template name="position2order">
<xsl:param name="colsList"/>
<xsl:param name="cellPosition"/>
<xsl:param name="cycle" select="1"/>
<xsl:param name="colsListElt" select="substring-before($colsList,';')"/>
<xsl:choose>
	 <xsl:when test="$cellPosition != $colsListElt">
		<xsl:call-template name="position2order">
			<xsl:with-param name="cycle" select="$cycle + 1"/>
			<xsl:with-param name="colsList" select="substring-after($colsList,';')"/>
			<xsl:with-param name="cellPosition" select="$cellPosition"/>
		</xsl:call-template>
	 </xsl:when>
	 <xsl:otherwise>
	 	<xsl:value-of select="$cycle"/>
	 </xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- 
Retourne la position de la cellule numero "placeOfCell" dont l'etendue OOo 
"repeatCol" est donnee
-->
<xsl:template match="table:table-cell" mode="cellPosition">
	<xsl:param name="extremite"/>
	<xsl:param name="currentCellSpan">
		<xsl:choose>
			<xsl:when test="@table:number-columns-spanned">
				<xsl:value-of select="@table:number-columns-spanned"/>
			</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="precedingCellsNbr" 
		select="count(preceding-sibling::table:table-cell 
				[not(@table:number-columns-spanned)]) +
				sum(preceding-sibling::table:table-cell/ 
				@table:number-columns-spanned)"/>
	<xsl:param name="placeOfCol">
		<xsl:choose>
	 		<xsl:when test="parent::table:table-row/parent::table:table|
							parent::table:table-row/parent::table:sub-table">
				<xsl:apply-templates select="../../table:table-column[1]" 
					mode="placeOfColl">
					<xsl:with-param name="placeOfCell" select="$precedingCellsNbr + $currentCellSpan"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise><!-- table:table-header-rows -->
				<xsl:apply-templates select="../../../table:table-column[1]" 
					mode="placeOfColl">
					<xsl:with-param name="placeOfCell" select="$precedingCellsNbr + $currentCellSpan"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="content"  select="text:p/text()"/>
	<xsl:param name="numCol" select="substring-before($placeOfCol,';')"/>
	<xsl:param name="repeatCol" select="substring-after($placeOfCol,';')"/>

	<xsl:param name="colposition">
			<xsl:choose>
	 	<xsl:when test="parent::table:table-row/parent::table:table|
						parent::table:table-row/parent::table:sub-table">
			<xsl:apply-templates select="../../table:table-column[position()=$numCol]" mode="colposition">
				<xsl:with-param name="repeatCol" select="$repeatCol"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
	 		<xsl:apply-templates 
				select="../../../table:table-column[position()=$numCol]" 
				mode="colposition">
				<xsl:with-param name="repeatCol" select="$repeatCol"/>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
	</xsl:param>
	<xsl:value-of select="$colposition"/>
</xsl:template>

<!-- 
Retourne le numero de la colonne 
correspondant a une position de cellule donnee (placeofCell)
pour le conteneur table ou sub-table courant
-->
<xsl:template match="table:table-column" mode="placeOfColl">
	<xsl:param name="placeOfCell"/>
	<xsl:param name="placeOfColl" select="1"/>
	<xsl:param name="repeatOfCol">
		<xsl:choose>
	 		<xsl:when test="@table:number-columns-repeated">
				<xsl:value-of select="@table:number-columns-repeated"/>
			</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:choose>
	 	<xsl:when test="$placeOfCell > 0">
			<xsl:choose>
	 			<xsl:when test="$placeOfCell > $repeatOfCol">
					<xsl:apply-templates 
						select="following-sibling::table:table-column[1]" 
						mode="placeOfColl">
						<xsl:with-param name="placeOfCell" select="$placeOfCell - $repeatOfCol"/>
						<xsl:with-param name="placeOfColl" select="$placeOfColl + 1"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
	 				<xsl:value-of select="concat($placeOfColl,';',$placeOfCell)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="concat($placeOfColl,';',1)"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- 
Retourne la position absolue de la colonne (distance entre la fin
de la colonne et le bord gauche du tableau)dans l'unite de mesure courante du document
-->

<xsl:template match="table:table-column" mode="colposition">
	<xsl:param name="stylesURI" select="/office:document/office:automatic-styles/style:style"/>
	<xsl:param name="repeatCol"/>
	<xsl:param name="cellAncestorNbr"/>
	<xsl:param name="precedingCellsNbr" select="count(preceding-sibling::table:table-cell)"/>
	<xsl:param name="colPosition">
	<xsl:call-template name="colPosition">
		<xsl:with-param name="origineValue">				
			<xsl:choose>
				<xsl:when test="parent::table:sub-table">
					<xsl:call-template name="subtableOrigine">
						<xsl:with-param name="cellAncestorNbr" 
							select="count(ancestor::table:table-cell)"/>
						<xsl:with-param name="stylesURI" select="$stylesURI"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
		<xsl:with-param name="stylesURI" select="$stylesURI"/>
		<xsl:with-param name="repeatCol" select="$repeatCol"/>
	</xsl:call-template>
	</xsl:param>
	<xsl:param name="colposfine" select="substring-before($colPosition,';')"/>
	<xsl:value-of select="$colposfine"/>
</xsl:template>

<!-- Retourne la position absolue de la sous-table qui incorpore la colonne courante
(postion absolue = distance entre bord gauche de la sous-table 
et bord gauche du tableau) -->
<xsl:template match="table:table-column" mode="subtablePosition">
	<xsl:param name="stylesURI" select="/office:document/office:automatic-styles/style:style"/>
	<xsl:param name="repeatCol"/>
	<xsl:param name="cellAncestorNbr"/>
	<xsl:param name="precedingCellsNbr" select="count(preceding-sibling::table:table-cell)"/>
	<xsl:param name="subtablePosition">
		<xsl:call-template name="subtableOrigine">
			<xsl:with-param name="cellAncestorNbr" 
				select="count(ancestor::table:table-cell)"/>
			<xsl:with-param name="stylesURI" select="$stylesURI"/>
		</xsl:call-template>
	</xsl:param>
	<xsl:param name="colposfine">
		<xsl:call-template name="roundValue">
			<xsl:with-param name="inputValue" select="$subtablePosition"/>
		</xsl:call-template>
	</xsl:param>
	<xsl:value-of select="$colposfine"/>
</xsl:template>

<!-- 
Retourne la somme des elements de la liste passee en paramètre
La liste doit être du type a;b;c; (le ';' final est requit)
-->
<xsl:template name="sumOfList">
	<xsl:param name="list"/>
	<xsl:param name="sum" select="0"/>
	<xsl:choose>
	 	<xsl:when test="substring-before($list,';') != ''">
			<xsl:call-template name="sumOfList">
				<xsl:with-param name="sum" select="$sum + substring-before($list,';')"/>
				<xsl:with-param name="list" select="substring-after($list,';')"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
	 		<xsl:value-of select="$sum"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Retourne la valeur arrondie adaptee a l'unite de messure en cour du document-->
<xsl:template name="roundValue">
<xsl:param name="inputValue"/>
<xsl:choose>
	 <xsl:when test="$measureUnit = 'pt' or $measureUnit = 'pi' or $measureUnit = '%'">
			<xsl:value-of select="round($inputValue)"/>
	 </xsl:when>
	 <xsl:when test="$measureUnit = 'cm' or $measureUnit = 'inch'">
			<xsl:value-of select="round($inputValue * 10) div 10"/>
	 </xsl:when>
	 <xsl:otherwise><!-- mm -->
	 	<xsl:value-of select="round($inputValue)"/>
	 </xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- Table - Table-cell -->
<!-- traitement final des cellules du tableau -->
<xsl:template name="entryNormal">
    <xsl:param name="namestValue"/>
    <xsl:param name="nameendValue"/>
    <xsl:param name="moreRowsValue" select="'0'"/>
        <xsl:param name="valign" 
            select="/office:document/office:automatic-styles/ 
                        style:style[@style:name=current()/@table:style-name]/
                        style:properties/@fo:vertical-align"/>
                <entry>
		<xsl:if test="($nameendValue - $namestValue) > 1">
                        <xsl:attribute name="namest">
                            <xsl:value-of select="concat('c',($namestValue + 1))"/>
                        </xsl:attribute>
                        <xsl:attribute name="nameend">
                            <xsl:value-of select="concat('c',$nameendValue)"/>
                        </xsl:attribute>
		</xsl:if>
                    <xsl:if test="$moreRowsValue >= 1">
                        <xsl:attribute name="morerows">
                            <xsl:value-of select="$moreRowsValue"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="valign">
                        <xsl:choose>
                            <xsl:when test="$valign!=''">
                               <xsl:value-of select="$valign"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'top'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:apply-templates mode="inCellTable"/>
                </entry>
</xsl:template>

<!-- Tables - Cell content -->

<xsl:template match="*" mode="inCellTable">
    <xsl:call-template name="allTags">
        <xsl:with-param name="source" select="'cellTable'"/>
    </xsl:call-template>
</xsl:template>

<!-- DELETED STYLES -->
<xsl:template match="text:sequence-decls"/>
<xsl:template match="text:table-of-content"/>

</xsl:stylesheet>
