<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="xml2html.xsl"?>
<!--
SDX: Documentary System in XML.
Copyright : (C) 2000, 2001, 2002, 2003, 2004 Ministere de la culture et de la communication (France), AJLSM
Licence   : http://www.fsf.org/copyleft/gpl.html

 history
	Have been part of SDX distrib

 goal
	 displaying xml source in various format (html, text)

 author
	 frederic.glorieux@ajlsm.com


 usage :
	 fast test, apply this to itself, look at that in a xsl browse compliant
   as a root xsl matching all elements
   as an import xsl to format some xml
     with <xsl:apply-templates select="node()" mode="xml:html"/>
     in this case you need to copy css and js somewhere to link with

 features :
   DOM compatible hide/show
   double click to expand all
   old browser compatible
   no extra characters to easy copy/paste code
   html formatting oriented for logical css
   commented to easier adaptation
   all xmlns:*="uri" attributes in root node
   text reformating ( xml entities )

 problems :
   <![CDATA[ node ]]> can't be shown (processed by xml parser before xsl transformation)

 TODOs

 - FIX edit mode

 +-->
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xsl">
	<xsl:output indent="no" method="xml" cdata-section-elements="cdata"/>
	<xsl:param name="pre" select="false()"/>
	<xsl:param name="text-replace" select="true()"/>
	<xsl:param name="val-replace" select="true()"/>
	<xsl:param name="search-text" select="document('')/*/xsl:template[@name='xml:ampgtlt']/search"/>
	<xsl:param name="search-val" select="
document('')/*/xsl:template[@name='xml:ampgtlt']/search
| document('')/*/xsl:template[@name='xml:quot']/search
"/>
	<xsl:param name="cdatas" select="concat(' cdata ', normalize-space(/*/*/@cdata-section-elements), ' ')"/>
	<xsl:param name="action"/>
	<xsl:param name="back"/>
	<xsl:param name="pres" select="' style script litterallayout pre '"/>
	<xsl:variable name="xml:search-atts" select="document('')/*/xsl:template[@name='search-atts']/search"/>
	<!-- style -->
	<xsl:template name="xml:css">
		<style type="text/css"><![CDATA[
	
	         /*
            body css properties are applied to operators

            nodes have a class :
                processing-instruction, comment,
                text, attribute value
                tag name, attribute name
            tag+atts are included in el class
             */

						body {font-size:12pt;}

            .xml_pi
                {color:#000080; font-weight: bold;}
            pre.xml_rem
                {  margin:0; padding:0; white-space:pre;
                 font-size:90%;
                font-family: monospace, sans-serif;
                color:#666666; background:#FFFFF0; font-weight: 100; }
            pre.xml_pre
                {  margin:0; padding:0; white-space:pre;
                font-family: monospace, sans-serif; }
            .x /* text */, .v /* value attribute */, .xml_cdata
                { font-weight:bold; color:#555555; 
                margin:0; padding:0;
                font-family:monospace, sans-serif; 
                background:#FFFFFF;
                }
            .xml_cdata {color:red}
            .el
                {color:#CC3333; font-weight:900; font-family: Verdana, sans-serif; }
            .a  /* attname */
                {color:#008000;font-weight:100; font-family: Verdana, sans-serif; }
            a:link.v, a:link.a, a:link.el, a:link.xml_swap,
            a:visited.v, a:visited.a, a:visited.el, a:visited.xml_swap
                { text-decoration:underline; }
            a:hover.v, a:hover.a, a:hover.el, a:hover.xml_swap
                { text-decoration:none; color:#FFFFFF; background:blue; }
            a:active.v, a:active.a, a:active.el, a:active.xml_swap
                {background:#CC3333;color:#FFFFFF;}
            .t /* tag */
                { font-size:80%; white-space:nowrap;}
            .ns
                { color:#000080; font-weight:100;}
            
            dd.xml_margin, .xml_mix
                { display:block; margin-left:5px; padding-left:20px; border-left: 1px dotted;
                margin-top:0px; margin-bottom:0px; margin-right:0px; }
            dl.xml_block
                { margin:0; padding:0;}
            
            .swap_hide { color:blue; text-decoration:underline; }

            .xml
                { display:block; 
                font-family: "Lucida Console", monospace, sans-serif; font-size:80%;
                color:Navy; margin-left:2em; }

]]></style>
	</xsl:template>
	<!--
     |    ROOT
     |-->
	<xsl:template match="/">
		<xsl:call-template name="xml:html"/>
	</xsl:template>
	<!-- template to call from everywhere -->
	<xsl:template name="xml:content">
		<xsl:param name="content" select="."/>
		<xsl:apply-templates select="$content" mode="xml:html"/>
	</xsl:template>
	<xsl:template name="xml:click">
		<script type="text/javascript"><![CDATA[

function click(event) {

    var mark = event.target;

    while ((mark.className != "b") && (mark.nodeName != "BODY")) {
        mark = mark.parentNode
    }
    
    var e = mark;
    
    while ((e.className != "e") && (e.nodeName != "BODY")) {
        e = e.parentNode
    }
    
    if (mark.childNodes[0].nodeValue == "+") {
        mark.childNodes[0].nodeValue = "-";
        for (var i = 2; i < e.childNodes.length; i++) {
            var name = e.childNodes[i].nodeName;
            if (name != "#text") {
                if (name == "PRE" || name == "SPAN") {
                   window.status = "inline";
                   e.childNodes[i].style.display = "inline";
                } else {
                   e.childNodes[i].style.display = "block";
                }
            }
        }
    } else if (mark.childNodes[0].nodeValue == "-") {
        mark.childNodes[0].nodeValue = "+";
        for (var i = 2; i < e.childNodes.length; i++) {
            if (e.childNodes[i].nodeName != "#text") {
                e.childNodes[i].style.display = "none";
            }
        }
    }
}  
  
]]></script>
	</xsl:template>
	<xsl:template name="xml:edit">
		<script type="text/javascript"><![CDATA[

            var SWAP_CLASS='xml_margin';


    function save(text, fileName)
    {
        log="";
        if (document.execCommand)
        {
            if (!document.frames[0]) return log + "no frame to write in";
            win=document.frames[0];
            win.document.open("text/html", "replace");
            win.document.write(text);
            win.document.close();
            win.focus();
            win.document.execCommand('SaveAs', fileName);
        }
     /*
     
     function writeToFile(fileName,text) {
 
netscape.security.PrivilegeManager.enablePrivilege('UniversalFileAccess');
    var fileWriter = new java.io.FileWriter(fileName);
    fileWriter.write (text, 0, text.length);
    fileWriter.close();
}

if (document.layers) {
    writeToFile('file.txt','Hello World');
}
		*/
    }

    function dom(xml)
    {
        if (window.DOMParser) return (new DOMParser()).parseFromString(xml, "text/xml");
        else if (window.ActiveXObject)
        {
            var doc = new ActiveXObject("Microsoft.XMLDOM");
            doc.async = false;
            doc.loadXML(xml);
            return doc;
        }
        else
        {
            alert(NOXML);
            return null;
        }
    }
    
    function xml_save()
    {
        if (!document.getElementById) return false;
        o=document.getElementById('edit');
        if (!o.innerText) return false; 
        var edit=o.contentEditable; 
        o.contentEditable=false; 
        var xml=o.innerText; 
        o.contentEditable=edit; 
        var doc=dom(xml); 
        if (!doc || !doc.documentElement) if (!confirm('The document you want to save is not well-formed. Continue ?')) return false;  
        save(xml)
    }
    
    function xml_edit(button, edit)
    {
        if (!document.getElementById) return false;
        if (document.body.isContentEditable==null) return false;
        var o=document.getElementById('edit'); 
        if(!o) return false; 
        if (edit == null) edit=!o.isContentEditable; 
        if (edit) { 
            if (button) button.className='but_in'; 
            o.contentEditable=true;
            document.cookie="edit=true";
        } 
        else { 
            if (button) button.className=''; 
            o.contentEditable=false; 
            document.cookie="edit=false";
        }
    }

    function xml_submit(form)
    {
        if (!form) form=document.forms[0];
        if (!document.getElementById) return false;
        o=document.getElementById('edit'); 
        if (!o.innerText) return false; 
        var edit=o.contentEditable; 
        o.contentEditable=false; 
        var xml=o.innerText; 
        o.contentEditable=edit; 
        var doc=dom(xml); 
        if (!doc || !doc.documentElement) if (!confirm('The document you want to upload is not well-formed. Continue ?')) return false;  
        if (!form || !form.xml) return false;
        form.xml.value=xml;
        if(form.url) form.url.value=window.location.href;
        return true;
    }
    
    function edit_key(o)
    {
        if (!event) return;
        var key=event.keyCode;
        if (!o) o=document.getElementById('edit');
        if (!o.isContentEditable) return true;
        if (key==9) {
            if (event.shiftKey) document.execCommand("Outdent"); 
            else document.execCommand("Indent"); 
            window.event.cancelBubble = true;
            window.event.returnValue = false;
            return false;
        }
        if (key==83) {
            if (!event.ctrlKey) return;
            xml_save();
            window.event.cancelBubble = true;
            window.event.returnValue = false;
            return false;
        }
        if (key==85) {
            if (!event.ctrlKey) return;
            form=document.forms[0];
            if (!form) return;
            if (xml_submit(form)) form.submit();
            window.event.cancelBubble = true;
            window.event.returnValue = false;
            return false;
        }
    }
    
    function xml_load()
    {
        if (!document.getElementById || !document.execCommand || document.body.isContentEditable==null) return false; 
        var o=document.getElementById('bar'); 
        if (!o || !o.style) return; 
        o.style.display='';
        xml_edit(document.forms[0].butEdit, (document.cookie.search("edit=true") != -1));
    }

]]></script>
	</xsl:template>
	<xsl:template name="xml:bar">
		<form id="bar" style="margin:0; display:none;" onsubmit="return xml_submit(this); ">
			<xsl:if test="$action">
				<xsl:attribute name="action">
					<xsl:value-of select="$action"/>
				</xsl:attribute>
				<xsl:attribute name="method">post</xsl:attribute>
			</xsl:if>
			<iframe id="save" style="display:none">nothing</iframe>
			<xsl:if test="$back">
				<input type="hidden" name="back" value="{$back}"/>
				<button accesskey="b" type="button" onclick="window.location.href=this.form.back.value">
					<u>B</u>ack
                    </button>
			</xsl:if>
			<button name="butEdit" type="button" accesskey="e" onclick="xml_edit(this)">
				<u>E</u>dit</button>
			<button type="button" accesskey="s" onclick="xml_save()">
				<u>S</u>ave</button>
			<xsl:if test="$action">
				<button type="submit" accesskey="u">
					<u>U</u>pload</button>
			</xsl:if>
			<input type="hidden" name="url"/>
			<textarea name="xml" cols="1" rows="1" style="width:1px; height:1px">nothing</textarea>
		</form>
	</xsl:template>
	<!-- no match here for import -->
	<xsl:template name="xml:html">
		<xsl:param name="content" select="/node()"/>
		<xsl:param name="title" select="'XML - source'"/>
		<html>
			<head>
				<title>
					<xsl:value-of select="$title"/>
				</title>
				<xsl:call-template name="xml:css"/>
				<xsl:call-template name="xml:swap"/>
			</head>
			<body onload="if(window.xml_load)xml_load()" ondblclick="if(window.swap_all)swap_all(this)">
				<div class="xml" id="edit">
					<div class="xml_pi">&lt;?xml version="1.0"?&gt;</div>
					<!--
					<xsl:apply-templates select="$content" mode="xml:html"/>
<h1>??</h1>
-->
					<xsl:apply-templates select="$content" mode="xml:html"/>
				</div>
			</body>
		</html>
	</xsl:template>
	<!-- script -->
	<xsl:template name="xml:swap">
		<script type="text/javascript"><![CDATA[
    function swap(id) {
      if (!document.getElementById) return true; 
      if (!id) return true;
      var o=document.getElementById(id); 
      if (!o || !o.style) return true; 
      o.style.display=(o.style.display == 'none')?'':'none'; 
      return false;
    }
]]></script>
	</xsl:template>
	<!-- PI -->
	<xsl:template match="processing-instruction()" mode="xml:html">
		<span class="xml_pi">
			<xsl:apply-templates select="." mode="xml:text"/>
		</span>
	</xsl:template>
	<!-- add xmlns declarations -->
	<xsl:template name="xml:ns">
		<xsl:variable name="ns" select="../namespace::*"/>
		<xsl:for-each select="namespace::*">
			<xsl:if test="
            name() != 'xml' 
            and (
                not(. = $ns) 
                or not($ns[name()=name(current())])
            )">
				<xsl:value-of select="' '"/>
				<span class="a">
					<xsl:text>xmlns</xsl:text>
					<xsl:if test="normalize-space(name())!=''">
						<xsl:text>:</xsl:text>
						<span class="ns">
							<xsl:value-of select="name()"/>
						</span>
					</xsl:if>
				</span>
				<xsl:text>="</xsl:text>
				<span class="ns">
					<xsl:value-of select="."/>
				</span>
				<xsl:text>"</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<!-- attribute -->
	<xsl:template match="@*" mode="xml:html">
		<xsl:call-template name="xml:html-att">
			<xsl:with-param name="attvalue-href"/>
			<xsl:with-param name="attvalue-title"/>
			<xsl:with-param name="attname-href"/>
			<xsl:with-param name="attname-title"/>
		</xsl:call-template>
	</xsl:template>
	<!-- template to call for attname and and attvalue -->
	<xsl:template name="xml:html-att">
		<xsl:param name="attvalue-href"/>
		<xsl:param name="attvalue-title"/>
		<xsl:param name="attname-href"/>
		<xsl:param name="attname-title"/>
		<xsl:value-of select="' '"/>
		<code class="a">
			<xsl:if test="$attname-title">
				<xsl:attribute name="title">
					<xsl:value-of select="$attname-title"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$attname-href">
					<a href="{$attname-href}">
						<xsl:call-template name="xml:name"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="xml:name"/>
				</xsl:otherwise>
			</xsl:choose>
		</code>
		<xsl:text>=&quot;</xsl:text>
		<a class="v">
			<xsl:if test="$attvalue-href">
				<xsl:attribute name="href">
					<xsl:value-of select="$attvalue-href"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="$attvalue-title">
				<xsl:attribute name="title">
					<xsl:value-of select="$attvalue-title"/>
				</xsl:attribute>
			</xsl:if>
			<!-- escaping &amp; to show entities -->
			<xsl:choose>
				<xsl:when test="
                    (contains(., '&amp;') 
                    or contains(., '&lt;')
                    or contains(., '&gt;')
                    or contains(., '&quot;'))
                    and $val-replace
                    ">
					<xsl:call-template name="replaces">
						<xsl:with-param name="string" select="."/>
						<xsl:with-param name="searches" select="$search-val"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</a>
		<xsl:text>"</xsl:text>
	</xsl:template>
	<!--  text -->
	<!--
    <xsl:template match="text()[normalize-space(.)='']" mode="xml:html">
    </xsl:template>
    ? -->
	<!--
    <xsl:template match="text()[normalize-space(.)='']" mode="xml:html"/>
-->
	<xsl:template match="text()" mode="xml:html">
		<xsl:param name="text" select="."/>
		<span class="x">
			<xsl:choose>
				<xsl:when test="
                    (contains(., '&amp;') 
                    or contains(., '&lt;')
                    or contains(., '&gt;'))
                    and $text-replace
                    ">
					<xsl:call-template name="replaces">
						<xsl:with-param name="string" select="$text"/>
						<xsl:with-param name="searches" select="$search-text"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</span>
	</xsl:template>
	<!-- comment -->
	<xsl:template match="comment()" mode="xml:html">
		<pre class="xml_rem">
			<a href="#i" class="pointer" id="src{generate-id()}" onclick="if (window.swap) return swap('{generate-id()}'); ">&lt;!--</a>
			<i id="{generate-id()}">
				<xsl:value-of select="."/>
			</i>
			<xsl:text>--&gt;</xsl:text>
		</pre>
	</xsl:template>
	<!-- name -->
	<xsl:template match="node()" name="xml:name" mode="xml:name">
		<xsl:param name="node" select="."/>
		<xsl:if test="contains(name($node), ':')">
			<a href="{namespace-uri()}" class="ns">
				<xsl:value-of select="normalize-space(substring-before(name($node), ':'))"/>
			</a>
			<xsl:text>:</xsl:text>
		</xsl:if>
		<xsl:value-of select="local-name($node)"/>
	</xsl:template>
	<!--
     |    ELEMENT
     | TODO:optimize repeted templates
     |-->
	<!-- element matching template - maybe override to provide links -->
	<xsl:template match="*" mode="xml:html">
		<xsl:call-template name="xml:html-el">
			<xsl:with-param name="elname-href"/>
			<xsl:with-param name="elname-title"/>
		</xsl:call-template>
	</xsl:template>
	<!-- element template to call -->
	<xsl:template name="xml:html-el">
		<!-- parameters for a link on element name -->
		<xsl:param name="elname-href"/>
		<xsl:param name="elname-title"/>
		<xsl:param name="current" select="."/>
		<xsl:param name="id" select="generate-id($current)"/>
		<xsl:param name="inline" select="normalize-space(../text())!=''"/>
		<xsl:param name="content" select="$current/text()[normalize-space(.)!=''] | $current/comment() | $current/processing-instruction() | $current/*"/>
		<xsl:choose>
			<!-- empty inline -->
			<xsl:when test="$inline and not($content)">
				<span class="t">
					<xsl:text>&lt;</xsl:text>
					<xsl:call-template name="xml:tag-open">
						<xsl:with-param name="elname-href" select="$elname-href"/>
						<xsl:with-param name="elname-title" select="$elname-title"/>
						<xsl:with-param name="empty" select="true()"/>
					</xsl:call-template>
				</span>
			</xsl:when>
			<!-- empty struct -->
			<xsl:when test="not($content)">
				<div class="t">
					<xsl:text>&lt;</xsl:text>
					<xsl:call-template name="xml:tag-open">
						<xsl:with-param name="elname-href" select="$elname-href"/>
						<xsl:with-param name="elname-title" select="$elname-title"/>
						<xsl:with-param name="empty" select="true()"/>
					</xsl:call-template>
				</div>
			</xsl:when>
			<!-- inline -->
			<xsl:when test="$inline">
				<span class="t">
					<xsl:text>&lt;</xsl:text>
					<xsl:call-template name="xml:tag-open">
						<xsl:with-param name="elname-href" select="$elname-href"/>
						<xsl:with-param name="elname-title" select="$elname-title"/>
					</xsl:call-template>
				</span>
				<xsl:apply-templates select="$current/node()" mode="xml:html">
					<xsl:with-param name="inline" select="true()"/>
				</xsl:apply-templates>
				<span class="t">
					<xsl:call-template name="xml:tag-close"/>
					<xsl:text>&gt;</xsl:text>
				</span>
			</xsl:when>
			<!-- pre -->
			<xsl:when test="@xml:space='preserve' or contains($pres, concat(' ', local-name(), ' '))">
				<pre class="xml_pre">
					<span class="t">
						<a class="xml_swap" href="#close{$id}" name="open{$id}" onclick="if (window.swap) return swap('{$id}');">
							<xsl:text>&lt;</xsl:text>
						</a>
						<xsl:call-template name="xml:tag-open">
							<xsl:with-param name="elname-href" select="$elname-href"/>
							<xsl:with-param name="elname-title" select="$elname-title"/>
						</xsl:call-template>
					</span>
					<div id="{$id}">
						<xsl:apply-templates select="$current/node()" mode="xml:html"/>
					</div>
					<span class="t">
						<xsl:call-template name="xml:tag-close"/>
						<xsl:text>&gt;</xsl:text>
					</span>
				</pre>
			</xsl:when>
			<!-- block mixed -->
			<xsl:when test="normalize-space($current/text())!='' and *">
				<div class="xml_block">
					<span class="t">
						<a class="xml_swap" href="#close{$id}" name="open{$id}" onclick="if (window.swap) return swap('{$id}');">
							<xsl:text>&lt;</xsl:text>
						</a>
						<xsl:call-template name="xml:tag-open">
							<xsl:with-param name="elname-href" select="$elname-href"/>
							<xsl:with-param name="elname-title" select="$elname-title"/>
						</xsl:call-template>
					</span>
					<span class="xml_mix" id="{$id}">
						<xsl:apply-templates select="$current/node()" mode="xml:html">
							<xsl:with-param name="inline" select="true()"/>
						</xsl:apply-templates>
					</span>
					<span class="t">
						<xsl:call-template name="xml:tag-close"/>
						<xsl:text>&gt;</xsl:text>
					</span>
				</div>
			</xsl:when>
			<!-- struct -->
			<xsl:when test="normalize-space($current/text()) = '' and *">
				<dl class="xml_block">
					<dt class="t">
						<a class="xml_swap" href="#close{$id}" name="open{$id}" onclick="if (window.swap) return swap('{$id}');">
							<xsl:text>&lt;</xsl:text>
						</a>
						<xsl:call-template name="xml:tag-open">
							<xsl:with-param name="elname-href" select="$elname-href"/>
							<xsl:with-param name="elname-title" select="$elname-title"/>
						</xsl:call-template>
					</dt>
					<dd class="xml_margin" id="{$id}">
						<xsl:apply-templates select="$current/node()" mode="xml:html"/>
					</dd>
					<dt class="t">
						<xsl:call-template name="xml:tag-close"/>
						<a class="xml_swap" href="#open{$id}" name="close{$id}">
							<xsl:text>&gt;</xsl:text>
						</a>
					</dt>
				</dl>
			</xsl:when>
			<!-- block or with no children -->
			<xsl:otherwise>
				<div>
					<span class="t">
						<xsl:text>&lt;</xsl:text>
						<xsl:call-template name="xml:tag-open">
							<xsl:with-param name="elname-href" select="$elname-href"/>
							<xsl:with-param name="elname-title" select="$elname-title"/>
						</xsl:call-template>
					</span>
					<xsl:apply-templates select="$current/node()" mode="xml:html"/>
					<span class="t">
						<xsl:call-template name="xml:tag-close"/>
						<xsl:text>&gt;</xsl:text>
					</span>
				</div>
			</xsl:otherwise>
		</xsl:choose>
		<!-- MAYDO
    <xsl:if test="$hide">
        <xsl:attribute name="style">display:none; {};</xsl:attribute>
    </xsl:if>
    <xsl:if test="$cdata and $content">
        <xsl:text>&lt;![CDATA[</xsl:text>
    </xsl:if>
-->
		<!--
        <xsl:param name="content" select="$element/node()"/>
        <xsl:param name="local-name" select="concat(' ', local-name($element), ' ')"/>
        <xsl:param name="hide" select="contains($hides, $local-name) or $element/@xml:swap[contains(., 'hide')]"/>
        <xsl:param name="inline" select="contains($inlines, $local-name)"/>
        <xsl:variable name="block" select="contains($blocks, $local-name)"/>
        <xsl:variable name="cdata" select="contains($cdatas, $local-name)"/>
        <xsl:variable name="pre" select="contains($pres, $local-name) or @xml:space='preserve'"/>
            -->
		<!--

<xsl:choose>
  <xsl:when test="not($content)"/>
  <xsl:when test="$content/descendant-or-self::*[1]">
    <dl>
    
    </dl>
  
  </xsl:when>

</xsl:choose>

    <xsl:if test="$cdata">
        <xsl:text>]]&gt;</xsl:text>
    </xsl:if>

-->
	</xsl:template>
	<!-- open an xml tag -->
	<xsl:template name="xml:tag-open">
		<xsl:param name="current" select="."/>
		<xsl:param name="empty"/>
		<xsl:param name="id" select="generate-id($current)"/>
		<xsl:param name="elname-href"/>
		<xsl:param name="elname-title"/>
		<code class="el">
			<b>
				<xsl:if test="$elname-title">
					<xsl:attribute name="title">
						<xsl:value-of select="$elname-title"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$elname-href">
						<a href="{$elname-href}">
							<xsl:apply-templates select="$current" mode="xml:name"/>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$current" mode="xml:name"/>
					</xsl:otherwise>
				</xsl:choose>
			</b>
		</code>
		<xsl:apply-templates select="$current/@*[name()!='xml:swap']" mode="xml:html"/>
		<!-- ns declarations after attribute values -->
		<xsl:call-template name="xml:ns"/>
		<xsl:if test="$empty">/</xsl:if>
		<xsl:text>&gt;</xsl:text>
	</xsl:template>
	<!-- close an xml tag -->
	<xsl:template name="xml:tag-close">
		<xsl:param name="current" select="."/>
		<xsl:param name="id" select="generate-id($current)"/>
		<xsl:text>&lt;/</xsl:text>
		<code class="el">
			<b>
				<xsl:apply-templates select="$current" mode="xml:name"/>
			</b>
		</code>
	</xsl:template>
	<!-- unplugged -->
	<!--
    <xsl:template match="*[local-name()='include' or local-name()='import']" mode="xml:html">
        <xsl:call-template name="xml:element">
            <xsl:with-param name="element" select="."/>
            <xsl:with-param name="content" select="document(@href, .)"/>
            <xsl:with-param name="hide" select="true()"/>
        </xsl:call-template>
    </xsl:template>
    -->
	<!--
     find/replace on a set of nodes
     thanks to jeni@jenitennison.com
     http://www.biglist.com/lists/xsl-list/archives/200110/msg01229.html
     fixed and adapted by frederic.glorieux@ajlsm.com -->
	<xsl:template name="replaces">
		<xsl:param name="string"/>
		<xsl:param name="searches" select="no-node"/>
		<xsl:choose>
			<!--
            <xsl:when xmlns:java="java" xmlns:xalan="http://xml.apache.org/xalan" test="function-available('xalan:distinct')">
                <xsl:value-of select="java:org.apache.xalan.xsltc.compiler.util.Util.replace($string, 'a', '__')"/>
            </xsl:when>
        -->
			<xsl:when test="false()">
				<!-- -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="first" select="$searches[1]"/>
				<xsl:variable name="rest" select="$searches[position() > 1]"/>
				<xsl:choose>
					<xsl:when test="$first and contains($string, $first/find)">
						<!-- replace with rest in before -->
						<xsl:call-template name="replaces">
							<xsl:with-param name="string" select="substring-before($string, $first/find)"/>
							<xsl:with-param name="searches" select="$rest"/>
						</xsl:call-template>
						<!-- copy-of current replace -->
						<xsl:copy-of select="$first/replace/node()"/>
						<!-- replace with all in after -->
						<xsl:call-template name="replaces">
							<xsl:with-param name="string" select="substring-after($string, $first/find)"/>
							<xsl:with-param name="searches" select="$searches"/>
						</xsl:call-template>
					</xsl:when>
					<!-- empty the searches -->
					<xsl:when test="$rest">
						<xsl:call-template name="replaces">
							<xsl:with-param name="string" select="$string"/>
							<xsl:with-param name="searches" select="$rest"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$string"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- find/replace to search in attributes value -->
	<xsl:template name="xml:quot">
		<search>
			<find>&quot;</find>
			<replace>&amp;quot;</replace>
		</search>
		<!--
        <search>
            <find>&apos;</find>
            <replace>&amp;apos;</replace>
        </search>
        <search>
            <find>&#xA;</find>
            <replace>
                <br/>
            </replace>
        </search>
        -->
	</xsl:template>
	<xsl:template name="xml:br">
		<search>
			<find>&#xA;</find>
			<replace>
				<br/>
			</replace>
		</search>
	</xsl:template>
	<!--
        <search>
            <find>&#xA;</find>
            <replace>
                <br/>
            </replace>
        </search>
-->
	<!-- find/replace to search -->
	<xsl:template name="xml:ampgtlt">
		<!-- entities -->
		<search>
			<find>&amp;</find>
			<replace>&amp;amp;</replace>
		</search>
		<search>
			<find>&gt;</find>
			<replace>&amp;gt;</replace>
		</search>
		<search>
			<find>&lt;</find>
			<replace>&amp;lt;</replace>
		</search>
	</xsl:template>
	<!--
     |    text mode
     |-->
	<!-- PI -->
	<xsl:template match="processing-instruction()" mode="xml:text">
		<xsl:text>&lt;?</xsl:text>
		<xsl:value-of select="concat(name(.), ' ', .)"/>
		<xsl:text>?&gt;</xsl:text>
	</xsl:template>
	<!-- @* -->
	<xsl:template match="@*" mode="xml:text">
		<xsl:value-of select="concat(' ', name(), '=&quot;', ., '&quot;')"/>
	</xsl:template>
	<!-- comment -->
	<xsl:template match="comment()" mode="xml:text">
		<xsl:call-template name="xml:margin"/>
		<xsl:text>&lt;!--</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>--&gt;</xsl:text>
	</xsl:template>
	<!-- * -->
	<xsl:template match="*" mode="xml:text">
		<xsl:call-template name="xml:margin"/>
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:apply-templates select="@*" mode="xml:text"/>
		<xsl:call-template name="xml:ns-text"/>
		<xsl:if test="not(node() | comment())">
			<xsl:text>/</xsl:text>
		</xsl:if>
		<xsl:text>&gt;</xsl:text>
		<xsl:if test="comment() | node ()">
			<xsl:apply-templates select="comment() | node () | processing-instruction()" mode="xml:text"/>
			<xsl:if test="* | comment()">
				<xsl:call-template name="xml:margin"/>
			</xsl:if>
			<xsl:text>&lt;/</xsl:text>
			<xsl:value-of select="name()"/>
			<xsl:text>&gt;</xsl:text>
		</xsl:if>
	</xsl:template>
	<!-- xmlns -->
	<xsl:template name="xml:ns-text">
		<xsl:variable name="ns" select="../namespace::*"/>
		<xsl:for-each select="namespace::*">
			<xsl:if test="
            name() != 'xml' 
            and (
                not(. = $ns) 
                or not($ns[name()=name(current())])
            )">
				<xsl:text> xmlns</xsl:text>
				<xsl:if test="normalize-space(name())!=''">
					<xsl:text>:</xsl:text>
					<xsl:value-of select="name()"/>
				</xsl:if>
				<xsl:text>="</xsl:text>
				<xsl:value-of select="."/>
				<xsl:text>"</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<!-- "breakable" space margin -->
	<xsl:template name="xml:margin">
		<xsl:text>&#32;
</xsl:text>
		<xsl:for-each select="ancestor::*">
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
