<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright : (C) 2002, 2003, 2004 AJLSM (ajlsm.com)
Licence   : http://www.fsf.org/copyleft/gpl.html


frederic.glorieux@ajlsm.com

This is a part of an AJLSM customization of docbook.

    This stylesheet import the docboo-xsl pack

    Order 
    - global variables
    - navigation templates
    - specific overrides
    - patches

-->
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:doc="http://nwalsh.com/xsl/documentation/1.0" xmlns:suwl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.UnwrapLinks" exclude-result-prefixes="doc suwl msxsl xi" version="1.1">
	<!--    imports and inclusions -->
	<xsl:import href="xml2html.xsl"/>
	<xsl:import href="../html/docbook.xsl"/>
	<xsl:import href="dbx2meta.xsl"/>
	<xsl:include href="xinclude.xsl"/>
	<xsl:output omit-xml-declaration="yes" method="xml" encoding="UTF-8" indent="no"/>
	<!--
     |    standard XSL DocBook parameters.
     |-->
	<!-- the language for generated content -->
	<xsl:param name="l10n.gentext.default.language" select="'fr'"/>
	<!-- numerated titles -->
	<xsl:param name="section.autolabel" select="1"/>
	<!--
     |    other includes and parameters.
     |-->
   <!-- TODO: should be a standard docbook-xsl param -->
	<xsl:param name="css"/>
	<xsl:param name="divs" select="' set book part chapter article section '"/>
	<!-- name of the default suffix target for generated links -->
	<xsl:param name="index" select="'index'"/>
	<xsl:param name="_html" select="'.html'"/>
	<xsl:param name="_xml" select="'.xml'"/>
	<!-- documents variables -->
	<!--
     |
     |    Some docbook templates
     |-->
	<xsl:template name="body.attributes">
		<!-- a focus onload
        <xsl:attribute name="onload">if (document.forms[0]) if (document.forms[0].elements[0]) document.forms[0].elements[0].focus()</xsl:attribute>
        -->
		<!--
  <xsl:attribute name="bgcolor">white</xsl:attribute>
  <xsl:attribute name="text">black</xsl:attribute>
  <xsl:attribute name="link">#0000FF</xsl:attribute>
  <xsl:attribute name="vlink">#840084</xsl:attribute>
  <xsl:attribute name="alink">#0000FF</xsl:attribute>
-->
	</xsl:template>
	<!-- docbook template to add hml/head declarations, like css, js
    TODO: link/@rel -->
	<!--
	<xsl:template name="user.head.content">
		<xsl:param name="node" select="."/>
		<xsl:variable name="prepath">
			<xsl:call-template name="toc.ancestors.path">
				<xsl:with-param name="toc.ancestors" select="$toc.ancestors"/>
			</xsl:call-template>
		</xsl:variable>
		<link rel="stylesheet" href="{$prepath}css/docbook-html.css"/>
		<script type="text/javascript" src="{$prepath}css/xml.js">
			<xsl:comment> no </xsl:comment>
		</script>
		<style type="text/css">
/* user styles */
        </style>
	</xsl:template>
-->
	<!-- override -->
	<xsl:template name="head.content">
		<xsl:comment> head.content template </xsl:comment>
		<xsl:call-template name="metas"/>
		<xsl:if test="$css">
				<link rel="stylesheet" href="{$css}"/>
		</xsl:if>
	</xsl:template>
	<!--
     | NAVIGATION
     |-->
	<!--
     | resolving links 
     |-->
	<xsl:template match="@url">
		<xsl:value-of select="."/>
	</xsl:template>
	<xsl:template match="ulink/@url[not(contains(., '://')) and contains(., '.xml')]">
		<xsl:value-of select="concat(substring-before(., $_xml), $_html)"/>
	</xsl:template>
	<!-- override ulink, with just an <apply-templates select="@url"/> at the right place -->
	<xsl:template match="ulink" name="ulink">
		<xsl:variable name="link">
			<xsl:variable name="href">
				<xsl:apply-templates select="@url"/>
			</xsl:variable>
			<a href="{$href}">
				<xsl:if test="@id">
					<xsl:attribute name="name">
						<xsl:value-of select="@id"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="$ulink.target != ''">
					<xsl:attribute name="target">
						<xsl:value-of select="$ulink.target"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="count(child::node())=0">
						<xsl:value-of select="$href"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$href=''">
					<xsl:comment>
						<xsl:value-of select="name(.)"/>
					</xsl:comment>
				</xsl:if>
			</a>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="function-available('suwl:unwrapLinks')">
				<xsl:copy-of select="suwl:unwrapLinks($link)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$link"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--
     |    SECTIONNING - INFOS - TitlePage
     |
     |    override docbook-xsl/html/component.xsl
     |
     |-->
	<xsl:template match="set | book | part | chapter | article | section">
		<xsl:variable name="name" select="name()"/>
		<div class="{name(.)}">
			<xsl:call-template name="language.attribute"/>
			<xsl:if test="string($generate.id.attributes) != '0'">
				<xsl:attribute name="id">
					<xsl:call-template name="object.id"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="title"/>
			<div id="b{generate-id(title)}">
				<xsl:apply-templates select="*[contains(name(), 'info')] | title/preceding-sibling::node()"/>
				<xsl:variable name="toc.params">
					<xsl:call-template name="find.path.params">
						<xsl:with-param name="table" select="normalize-space($generate.toc)"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:call-template name="make.lots">
					<xsl:with-param name="toc.params" select="$toc.params"/>
					<xsl:with-param name="toc">
						<xsl:call-template name="component.toc">
							<xsl:with-param name="toc.title.p" select="contains($toc.params, 'title')"/>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:apply-templates select="* [name()!='abstract'] [not(contains(name(), 'info') or contains(name(), 'title'))] | title/following-sibling::processing-instruction()"/>
				<xsl:if test=".=/*">
					<xsl:call-template name="process.footnotes"/>
				</xsl:if>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="/set/title | /book/title | /part/title | /chapter/title | /article/title | /section/title" priority="1">
		<h1>
			<center>
				<xsl:apply-templates select="@*"/>
				<xsl:apply-templates/>
				<xsl:for-each select="./following-sibling::*[1][name()='subtitle']">
					<div class="subtitle">
						<i>
							<xsl:apply-templates/>
						</i>
					</div>
				</xsl:for-each>
				<xsl:comment>
					<xsl:value-of select="name(.)"/>
				</xsl:comment>
			</center>
		</h1>
	</xsl:template>
	<xsl:template match="set/title | book/title | part/title | chapter/title | article/title | section/title">
		<xsl:variable name="id">
			<xsl:choose>
				<xsl:when test="contains(local-name(..), 'info')">
					<xsl:call-template name="object.id">
						<xsl:with-param name="object" select="../.."/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="object.id">
						<xsl:with-param name="object" select=".."/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="level" select="count(ancestor::*[contains($divs, name())])-1"/>
		<xsl:variable name="n">
			<xsl:choose>
				<xsl:when test="$level &gt; 6">6</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$level"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="h{$n}">
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="id">
				<xsl:value-of select="$id"/>
			</xsl:attribute>
			<a name="{$id}">
				<xsl:comment>
					<xsl:value-of select="name(.)"/>
				</xsl:comment>
			</a>
			<xsl:if test="../ancestor::*[contains($divs, name())]">
				<span class="number">
					<xsl:attribute name="onclick">if (!document.getElementById) return false; 
    var o=document.getElementById('b<xsl:value-of select="generate-id()"/>'); if (!o.style) return false; 
    o.style.display=(o.style.display == 'none')?'':'none'; return false;
        </xsl:attribute>
					<xsl:number level="multiple" count="section[not(. = /section)]" format="1.1."/>
					<xsl:text>) </xsl:text>
				</span>
			</xsl:if>
			<xsl:apply-templates/>
			<xsl:for-each select="./following-sibling::*[1][name()='subtitle']">
				<div class="subtitle">
					<i>
						<xsl:apply-templates/>
					</i>
				</div>
			</xsl:for-each>
			<xsl:comment>
				<xsl:value-of select="name(.)"/>
			</xsl:comment>
		</xsl:element>
	</xsl:template>
	<!-- div header, as a line -->
	<xsl:template match="setinfo | bookinfo | partinfo | chapterinfo | articleinfo | sectioninfo">
		<fieldset class="{name(.)}">
			<xsl:for-each select="date | edition | pubdate | revhistory | subjectset | keywordset">
				<xsl:apply-templates select="."/>
				<xsl:if test="position() != last()"> - </xsl:if>
			</xsl:for-each>
			<xsl:apply-templates select="abstract | ../abstract"/>
			<xsl:for-each select="author | authorgroup | editor | publisher | publishername | personname">
				<xsl:apply-templates select="."/>
				<xsl:if test="position() != last()"> - </xsl:if>
			</xsl:for-each>
		</fieldset>
	</xsl:template>
	<xsl:template match="setinfo/title | bookinfo/title | partinfo/title | chapterinfo/title | articleinfo/title | sectioninfo/title"/>
	<xsl:template match="authorgroup">
		<xsl:for-each select="*">
			<xsl:apply-templates select="."/>
			<xsl:if test="position() != last()"> - </xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="author | publisher | editor">
		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test=".//email[1]">a</xsl:when>
				<xsl:otherwise>span</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:text>&#32;</xsl:text>
		<xsl:element name="{$name}">
			<xsl:if test=".//email">
				<xsl:attribute name="href">mailto:<xsl:value-of select=".//email"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="class">
				<xsl:value-of select="name(.)"/>
			</xsl:attribute>
			<xsl:variable name="title">
				<xsl:apply-templates select="node()"/>
			</xsl:variable>
			<xsl:attribute name="title">
				<xsl:value-of select="$title"/>
			</xsl:attribute>
			<xsl:comment>
				<xsl:value-of select="name()"/>
			</xsl:comment>
			<xsl:choose>
				<xsl:when test="personname | publishername">
					<xsl:apply-templates select="personname | publishername"/>
				</xsl:when>
				<xsl:when test="surname">
					<xsl:apply-templates select="firstname"/>
					<xsl:text>&#32;</xsl:text>
					<xsl:apply-templates select="surname"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
		<xsl:text>&#32;</xsl:text>
	</xsl:template>
	<xsl:template match="publishername">
		<span class="{name(.)}">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	<!--
	revhistory, give it as a simple line instead of the default full table
	-->
	<xsl:template match="revhistory" priority="2">
		<div class="{name(.)}">
			<xsl:apply-templates select="revision[1]"/>
			<xsl:if test="revision[position()=last() and position()!=1]">
				<xsl:text> - </xsl:text>
				<xsl:apply-templates select="revision[position()=last() and position()!=1]"/>
			</xsl:if>
		</div>
	</xsl:template>
	<xsl:template match="revision">
		<span class="{name(.)}">
			<xsl:variable name="title">
				<xsl:apply-templates select="revdescription | revremark"/>
			</xsl:variable>
			<xsl:attribute name="title">
				<xsl:value-of select="$title"/>
			</xsl:attribute>
			<xsl:apply-templates select="date"/>
		</span>
		<xsl:text>&#32;</xsl:text>
	</xsl:template>
	<!--
	address
	-->
	<xsl:template match="address">
		<address>
			<xsl:apply-templates/>
		</address>
	</xsl:template>
	<xsl:template match="address/affiliation | street | country | affiliation | jobtitle | orgname | orgdiv | phone" priority="-1">
		<div class="{name(.)}">
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	<!--  
	ISO 8601 Date and Time templates  
	-->
	<xsl:template match="date">
		<span class="date">
      <xsl:apply-templates/>
		<!-- where is the template ?
			<xsl:call-template name="datetime.format">
				<xsl:with-param name="date" select="string(.)"/>
				<xsl:with-param name="format" select="'d B Y'"/>
			</xsl:call-template>
    -->
		</span>
	</xsl:template>
	<!--
     |    Bibliography
     |-->
	<!-- specific bibliographic format -->
	<xsl:template match="biblioentry">
		<xsl:variable name="id">
			<xsl:call-template name="object.id"/>
		</xsl:variable>
		<!-- no more support of external $bibliography.collection, 
	use generic inclusion with id instead -->
		<div class="{name(.)}">
			<xsl:call-template name="anchor"/>
			<xsl:call-template name="biblioentry.label"/>
			<xsl:apply-templates mode="bibliography.mode"/>
		</div>
	</xsl:template>
	<!-- biblioid -->
	<xsl:template match="biblioid" mode="bibliomixed.mode">
		<span class="{name(.)}">
			<xsl:apply-templates mode="bibliomixed.mode"/>
		</span>
	</xsl:template>
	<xsl:template match="biblioid" mode="bibliography.mode">
		<span class="{name(.)}">
			<xsl:apply-templates mode="bibliography.mode"/>
			<xsl:value-of select="$biblioentry.item.separator"/>
		</span>
	</xsl:template>
	<xsl:template match="biblioid[@class='uri']" mode="bibliography.mode">
     &lt;<a href="{.}">
			<xsl:apply-templates mode="bibliography.mode"/>
		</a>&gt;
            <xsl:value-of select="$biblioentry.item.separator"/>
	</xsl:template>
	<xsl:template match="biblioid[@class='uri']" mode="bibliomixed.mode">
     &lt;<a href="{.}">
			<xsl:apply-templates mode="bibliomixed.mode"/>
		</a>&gt;
     </xsl:template>
	<xsl:template match="abstract" mode="bibliography.mode">
		<span class="abstract">
			<small>
				<xsl:value-of select="."/>
			</small>
		</span>
	</xsl:template>
	<!--
     |    BLOCKS
     |-->
	<!-- override docbook-xsl/html/formal.xsl -->
	<xsl:template name="formal.object.heading">
		<xsl:param name="object" select="."/>
		<h6>
			<xsl:comment>
				<xsl:value-of select="name()"/>
			</xsl:comment>
			<xsl:apply-templates select="$object" mode="object.title.markup">
				<xsl:with-param name="allow-anchors" select="1"/>
			</xsl:apply-templates>
		</h6>
	</xsl:template>
	<!-- override docbook-xsl/html/block.xsl -->
	<xsl:template match="abstract">
		<blockquote class="{name(.)}">
			<xsl:call-template name="anchor"/>
			<xsl:apply-templates/>
		</blockquote>
	</xsl:template>
	<!-- CDATA - reformat xml if @role="xml" -->
	<xsl:template match="programlisting[@role='xml']">
		<xsl:variable name="id">
			<xsl:call-template name="object.id"/>
		</xsl:variable>
		<div class="{name(.)}" id="{$id}">
			<xsl:apply-templates select="@*"/>
			<xsl:call-template name="anchor"/>
			<xsl:apply-templates select="comment() | processing-instruction() | node()" mode="xml:html"/>
		</div>
	</xsl:template>
	<!-- resolve inclusion as processing instructions -->
	<xsl:template match="processing-instruction('xi-include')" mode="xml:html">
		<xsl:param name="href" select="substring-before( substring-after(., 'href=&quot;'), '&quot;')"/>
		<xsl:param name="content">
			<xsl:call-template name="xi:include">
				<xsl:with-param name="href" select="$href"/>
			</xsl:call-template>
		</xsl:param>
		<xsl:call-template name="xml">
			<xsl:with-param name="content" select="$content"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="xml">
		<xsl:param name="content" select="."/>
		<xsl:choose>
			<xsl:when test="$content and normalize-space($content) != ''">
				<xsl:apply-templates select="$content" mode="xml:html"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$content"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- some specific toc tags -->
	<xsl:template match="toc[@role='index']/tocentry">
		<dt class="{name(.)}">
			<xsl:apply-templates select="node()[not(@role='abstract')][name() != 'abstract']"/>
		</dt>
		<dd class="{name(.)}">
			<xsl:apply-templates select="abstract | phrase[@role='abstract']"/>
		</dd>
	</xsl:template>
	<xsl:template match="tocentry/title | tocentry/phrase[@role='title']">
		<div>
			<b>
				<xsl:apply-templates/>
			</b>
		</div>
	</xsl:template>
	<xsl:template match="tocentry/subtitle | phrase[@role='subtitle']">
		<i>
			<div class="subtitle">
				<xsl:apply-templates/>
			</div>
		</i>
	</xsl:template>
	<xsl:template match="tocentry/abstract | tocentry/phrase[@role='abstract']">
		<div>
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	<!-- drastic simplification of litellayout
    linenumbering don't work on common xsl processor (saxon, IE)
    shade could be easily replaced by css class
    replacing &#13; by <br/> don't work in some xsl engine (IE)
    replacing &#32; by &#160; break correct copy/paste or searching
     -->
	<xsl:template match="literallayout">
		<pre class="{name(.)}">
			<xsl:value-of select="."/>
		</pre>
	</xsl:template>
	<!-- presentation commodity, an hide/show on figure and exemple -->
	<xsl:template match="figure[contains(@condition, 'hide')] | example[contains(@condition, 'hide')]">
		<xsl:param name="id">
			<xsl:apply-templates select="." mode="id"/>
		</xsl:param>
		<div>
			<xsl:apply-templates select="@*"/>
			<p>
				<a href="#{$id}">
					<xsl:attribute name="onclick">if (!document.getElementById) return false; 
    var o=document.getElementById('<xsl:value-of select="$id"/>'); if (!o.style) return false; 
    o.style.display=(o.style.display == 'none')?'':'none'; return false;
        </xsl:attribute>
					<xsl:apply-templates select="." mode="object.title.markup">
						<xsl:with-param name="allow-anchors" select="1"/>
					</xsl:apply-templates>
				</a>
			</p>
			<div>
				<xsl:apply-templates select="@*"/>
				<xsl:attribute name="id">
					<xsl:value-of select="$id"/>
				</xsl:attribute>
				<xsl:attribute name="style">display:none; {}</xsl:attribute>
				<xsl:apply-templates select="*[name()!='title']"/>
			</div>
		</div>
	</xsl:template>
	<!--
     |    Inlines
     |-->
	<xsl:template match="emphasis">
		<xsl:call-template name="simple.xlink">
			<xsl:with-param name="content">
				<xsl:variable name="name">
					<xsl:choose>
						<xsl:when test="contains(@role, 'bold')">b</xsl:when>
						<xsl:when test="@role='b'">b</xsl:when>
						<xsl:when test="contains(@role, 'strong')">strong</xsl:when>
						<xsl:when test="@role='i'">i</xsl:when>
						<xsl:when test="contains(@role, 'italic')">i</xsl:when>
						<xsl:when test="@role='em'">em</xsl:when>
						<xsl:when test="contains(@role, 'emphasis')">em</xsl:when>
						<xsl:when test="@role='s'">s</xsl:when>
						<xsl:when test="contains(@role, 'strike')">strike</xsl:when>
						<xsl:when test="@role='big'">big</xsl:when>
						<xsl:when test="contains(@role, 'small')">small</xsl:when>
						<xsl:when test="@role='tt'">tt</xsl:when>
						<xsl:when test="@role='br'">br</xsl:when>
						<xsl:otherwise>em</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:element name="{$name}">
					<xsl:call-template name="atts"/>
					<xsl:call-template name="anchor"/>
					<xsl:apply-templates/>
					<xsl:if test="normalize-space(.) = '' and @role !='br'">
						<xsl:comment>
							<xsl:value-of select="name(.)"/>
						</xsl:comment>
					</xsl:if>
				</xsl:element>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<!--
     |    some overriding templates,
     |    to allow xml output and keep compatibility with html brothers 
     |    (it's not xhtml, because there's no doctype declaration )
     |-->
	<xsl:template name="anchor">
		<xsl:param name="node" select="."/>
		<xsl:param name="conditional" select="1"/>
		<xsl:variable name="id">
			<xsl:call-template name="object.id">
				<xsl:with-param name="object" select="$node"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="$conditional = 0 or $node/@id">
			<a name="{$id}">
				<xsl:comment>
					<xsl:value-of select="name(.)"/>
				</xsl:comment>
			</a>
		</xsl:if>
	</xsl:template>
	<!--
     |    General templates
     |-->
	<!-- for a full CSS rendering of Docbook -->
	<!--
	<xsl:template name="el" match="*" priority="-3">
		<span>
			<xsl:call-template name="atts"/>
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	-->
	<xsl:template name="atts" match="*" mode="atts">
		<xsl:attribute name="class">
			<xsl:value-of select="name()"/>
		</xsl:attribute>
		<xsl:apply-templates select="@*"/>
	</xsl:template>
	<xsl:template name="object.id" match="node()" mode="id">
		<xsl:param name="object" select="."/>
		<xsl:choose>
			<xsl:when test="$object/@id">
				<xsl:value-of select="$object/@id"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="generate-id($object)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- default, why not copy ? not very dangerous -->
	<xsl:template match="@*">
		<xsl:copy/>
	</xsl:template>
	<xsl:template match="@role">
		<xsl:attribute name="class">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>
	<xsl:template match="@id">
		<xsl:attribute name="id">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>
	<xsl:template match="@lang">
		<xsl:attribute name="xml:lang">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>
	<xsl:template match="@xreflabel">
		<xsl:attribute name="title">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>
	<!-- xhtml2 common attribute -->
	<xsl:template match="@revisionflag">
		<xsl:attribute name="edit">
			<xsl:choose>
				<xsl:when test=". = 'added'">inserted</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>
	<xsl:template match="@revision">
		<xsl:attribute name="datetime">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>
	<!-- mode text, very bad for spaces -->
	<xsl:template match="node()" mode="text">
		<xsl:variable name="nodes">
			<xsl:apply-templates select="."/>
		</xsl:variable>
		<xsl:value-of select="$nodes"/>
	</xsl:template>
	<!-- debug -->
	<xsl:template name="debug" match="node()" mode="debug">
		<xsl:param name="node" select="."/>
		<textarea rows="5" cols="80" style="width:100%">
			<xsl:copy-of select="$node"/>
		</textarea>
	</xsl:template>
</xsl:stylesheet>
