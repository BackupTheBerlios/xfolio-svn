<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:error="http://apache.org/cocoon/error/2.1">
  <xsl:param name="context"/>
  <xsl:template match="/*">
    <html>
      <head>
        <title>XFolio start admin</title>
      </head>
      <body>
      <p>&#160;</p>
      <center>
        <h1>Xfolio, parameters on start</h1>
      </center>
      <p>
The application is not yet informed of the parameters it needs. Because it is an 
electronic folder server, it needs essentially the path of the folder to serve.
Some other optional properties may be changed, discover them below. For exploitation,
it's also possible to set these upper, by Java System.properties or context parameters. 
See admin doc for more info.
      </p>
      <p>&#160;</p>
      
        <form name="params" action="{$context}" onsubmit="
if (this.efolderFile.value) this.efolder.value=this.efolderFile.value;
if (this.siteFile.value) this.site.value=this.siteFile.value;
">
          <table>
            <tr>
              <th width="5%">
                <big>efolder</big>
              </th>
              <td>
                <input name="efolder" type="hidden"/>
                <!--
A default value, a doc efolder in classical distrib
            -->
                <input name="efolderFile" size="50" type="file"/>
              </td>
            </tr>
            <tr>
              <td colspan="2">

	Provide here a path for your efolder of documents
	(absolute, or relative to the xfolio webapp folder).
	If you want to search something on your File System,
	click the "browse" button, and catch the welcome page
	of your folder
	(the application will serve the complete directory of this file).
	You can also write or copy/paste a path by hand.
              </td>
            </tr>
            <tr>
              <th>
                <big>domain</big>
              </th>
              <td>
                <input name="domain"/>
              </td>
            </tr>
            <tr>
              <td colspan="2">

	Provide the name of the domain for which you want to work for,
	like "http://xfolio.org", or "http://country.strabon.org/subproject". 
	There's no applicative issue, it's only to identify properly your
	documents by a persistent URI, on a server who will answer.
	It could be nicer than
	"http://localhost:8080" (if you are working standalone on your machine for
	a site to export). By the way, with nothing, it works also.

              </td>
            </tr>
            <tr>
              <th>
                <big>skin</big>
              </th>
              <td>
                <!-- TODO, generate from skin directory -->
                <select name="skin">
                  <option> </option>
                  <xsl:for-each select="//skins/*">
                     <option>
                       <xsl:value-of select="."/>
                     </option>
                  </xsl:for-each>
                </select>
              </td>
            </tr>
            <tr>
              <td colspan="2">

	Provide the name of a skin you want to use.
	It's the name of a folder under xfolio/skin
	directory. A select should provide the available skin of your
	xfolio installation.

              </td>
            </tr>
            <tr>
              <th>
            <big>go</big>
            </th>
              <td>
                <button type="submit">Submit</button>
              </td>
            </tr>
            <tr>
              <td colspan="2">
Send your parameters, or try the demo to test this app.

              </td>
            </tr>
          </table>
        </form>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
