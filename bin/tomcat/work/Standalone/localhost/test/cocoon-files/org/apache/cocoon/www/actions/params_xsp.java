
      
    package org.apache.cocoon.www.actions;

    import java.io.File;
    import java.io.IOException;
    import java.io.StringReader;
    //import java.net.*;
    import java.util.Date;
    import java.util.List;
    import java.util.Stack;

    //import org.w3c.dom.*;
    import org.xml.sax.InputSource;
    import org.xml.sax.SAXException;
    import org.xml.sax.helpers.AttributesImpl;

    //import org.apache.avalon.framework.*;
    import org.apache.avalon.framework.component.Component;
    import org.apache.avalon.framework.component.ComponentException;
    import org.apache.avalon.framework.component.ComponentManager;
    import org.apache.avalon.framework.component.ComponentSelector;
    import org.apache.avalon.framework.context.Context;
    //import org.apache.avalon.framework.util.*;

    import org.apache.cocoon.Constants;
    import org.apache.cocoon.ProcessingException;
    import org.apache.cocoon.generation.Generator;
    //import org.apache.cocoon.util.*;

    import org.apache.cocoon.components.language.markup.xsp.XSPGenerator;
    import org.apache.cocoon.components.language.markup.xsp.XSPObjectHelper;
    import org.apache.cocoon.components.language.markup.xsp.XSPRequestHelper;
    import org.apache.cocoon.components.language.markup.xsp.XSPResponseHelper;
    import org.apache.cocoon.components.language.markup.xsp.XSPSessionHelper;

    /* User Imports */
    
      import java.util.*;
    
      import java.net.*;
    
      import org.apache.avalon.framework.context.ContextException;
    
      import org.apache.cocoon.environment.Redirector;
    
      import org.apache.cocoon.acting.ServerPagesAction;
    
      import org.apache.cocoon.environment.Session;
    

    /**
     * Generated by XSP. Edit at your own risk, :-)
     */
    public class params_xsp extends XSPGenerator {

        // Files this XSP depends on
        private static File[] _dependentFiles = new File[] {
          
            };

        // Initialize attributes used by modifiedSince() (see AbstractServerPage)
        {
            this.dateCreated = 1089568844708L;
            this.dependencies = _dependentFiles;
        }

        /* Built-in parameters available for use */
        // context    - org.apache.cocoon.environment.Context
        // request    - org.apache.cocoon.environment.Request
        // response   - org.apache.cocoon.environment.Response
        // parameters - parameters defined in the sitemap
        // objectModel- java.util.Map
        // resolver   - org.apache.cocoon.environment.SourceResolver

        /* User Class Declarations */
        

      private Redirector actionRedirector;
      private Map actionResultMap;
      
	// get from cocoon2.0 sources, perhaps there's better somewhere

	/** Contextualize this class */
	File context_work_dir;
	public void contextualize(Context context) throws ContextException {
		context_work_dir = (File) context.get(Constants.CONTEXT_WORK_DIR);
	}

    public void delDir(File dir)
    {
        if (dir==null) return;
        if (dir.isFile()) dir.delete();
        if (dir.isDirectory())
        {
            File[] files=dir.listFiles();
            for (int i=0; i < files.length; i++) {delDir(files[i]);}
            dir.delete();
        }
    }
    
    public String path2dir(String path) {
      if (path==null || "null".equals(path) || "".equals(path)) return null;
      try {
        
        File dir=new File(path);
        if (!dir.isAbsolute()) dir=new File(context.getRealPath("/"), path);
        // maybe a file from a directory, take the parent
        if (!dir.isDirectory() && dir.isFile()) dir=dir.getParentFile();
        // not a dir, return nothing
        if (!dir.isDirectory()) return null;
        return dir.getCanonicalPath();
			}
			catch (Exception e) {return null;}
    }
    
    public boolean check (String s) {
       return !(s == null || "null".equals(s) || "".equals(s));
    }

/*
 Properties are used as context variable
 if not set, a value is search as
    a context initParameter
    a system property
    a request parameter (server on start)
*/

    public String searchValue(String name) {
      String value=(String)context.getAttribute("xfolio."+name);
      if (!check(value)) value=context.getInitParameter("xfolio."+name);
      if (!check(value)) value=System.getProperty("xfolio."+name);
      if (!check(value)) value=(String)request.getParameter(name);
      return value;
    }

	

        /**
         * Generate XML data.
         */
        public void generate() throws SAXException, IOException, ProcessingException {
            
            

            this.contentHandler.startDocument();
            AttributesImpl xspAttr = new AttributesImpl();

            
            
          this.contentHandler.startPrefixMapping(
            "xml",
            "http://www.w3.org/XML/1998/namespace"
          );
      
          this.contentHandler.startPrefixMapping(
            "xsp",
            "http://apache.org/xsp"
          );
      
          this.contentHandler.startPrefixMapping(
            "input",
            "http://apache.org/cocoon/xsp/input/1.0"
          );
      

    this.contentHandler.startElement(
      "",
      "admin",
      "admin",
      xspAttr
    );
    xspAttr.clear();

    
        this.characters("\n\t\t");
      
// strange logic but efficient in sitemap logic
// this action fails if everything is OK to continue sitemap process

  boolean stop=false;

/*
see
http://java.sun.com/j2se/1.4.2/docs/api/java/net/URLConnection.html#getFileNameMap()
*/
/*
      new URI(
        super.resolver.resolveURI("WEB-INF/classes/content-types.properties").getURI() 
      ).normalize().toURL().getFile()
*/


 
/*
  get Parameters to start the server
    xfolio.efolder = the documents folder to serve
    xfolio.skin = the default skin folder
    xfolio.lang = the default lang
    xfolio.domain = the internet domain for which this pages are generated
    xfolio.site = a directory where to write the generated files

*/


/* 
  to continue as fast as possible, 
  verify if efolder path is set on context
  if not, set it and take other params
*/

  String efolder=String.valueOf(context.getAttribute("xfolio.efolder"));
  if (!(efolder == null  || "null".equals(efolder) || "".equals(efolder)) ) {
  }
  else {
    efolder=context.getInitParameter("xfolio.efolder");
    if (path2dir(efolder)==null) efolder=System.getProperty("xfolio.efolder");
    if (path2dir(efolder)==null) efolder=String.valueOf(request.getParameter("efolder"));

    // impossible to get a value, set nothing, stop 
    if ( path2dir(efolder)==null ) stop=true;
    // a value is provide, test it
		else {
      String dir=path2dir(efolder);
      System.out.println("param requested : " + efolder);
      System.out.println("efolder served : " + dir);
      context.setAttribute("xfolio.efolder", dir + File.separator );
      // delete workdir here, if efolder changes, problems may happen
      System.out.println("Deleting Work dir : '" + context_work_dir +"'.");
      delDir(context_work_dir);


      // set skin for this context
      
      String skin=searchValue("skin");
      // no test of availability of skin for now. Who should test if it exists ?
      if (check(skin)) context.setAttribute("xfolio.skin", skin );

      // set domain (documentation variable)

      String domain=searchValue("skin");
      if (check(domain)) context.setAttribute("xfolio.domain", domain);

      // set site (a destination folder)

      String site=searchValue("site");
      site=path2dir(site);
      if (check(site)) context.setAttribute("xfolio.site", site);


    }
  }      


  
/*
  dynamic skin

  if a user ask for a skin by a param
  dynamic skin for each user oblige to have session
  the session value is setted on the request param skin
  skin is a folder name xfolio/skins/{skin}
*/

	// a skin param requested
	String skin=request.getParameter("skin");
  Session session=null;
	if (skin ==null) { } 
	else if ("".equals(skin)) {
		// delete session ?
	}
	else {
		session=request.getSession(true);
		session.setAttribute("skin", skin);
	}



this.actionRedirector = (Redirector)this.objectModel.get(ServerPagesAction.REDIRECTOR_OBJECT);
this.actionResultMap = (Map)this.objectModel.get(ServerPagesAction.ACTION_RESULT_OBJECT);
      if (this.actionRedirector == null) {

      System.out.println("params.xsp requested");

			
      

    this.contentHandler.startElement(
      "",
      "path",
      "path",
      xspAttr
    );
    xspAttr.clear();

    
        this.characters("\n\t\t\t\t");
      
        
        XSPObjectHelper.xspExpr(contentHandler, context.getRealPath("/"));
      
        this.characters("\n\t\t\t");
      

    this.contentHandler.endElement(
      "",
      "path",
      "path"
    );

    

      


      

    xspAttr.addAttribute(
      "",
      "context",
      "context",
      "CDATA",
      " " + String.valueOf(context.getAttribute("xfolio.skin")) + " "
    );
  

    this.contentHandler.startElement(
      "",
      "skins",
      "skins",
      xspAttr
    );
    xspAttr.clear();

    
        this.characters("\n        ");
      
        this.characters("\n        ");
      
          File[] skins=new File(context.getRealPath("/"), "skin").listFiles();
          for (int i=0 ; i < skins.length ; i++) {
            String name=skins[i].getName();
            if (
              skins[i].isDirectory()
              && !"CVS".equals(name) 
              && !"Thumbs.db".equals(name)
              && !name.startsWith(".")
              && !name.startsWith("_")
            ) {
                

    this.contentHandler.startElement(
      "",
      "skin",
      "skin",
      xspAttr
    );
    xspAttr.clear();

    
        
        XSPObjectHelper.xspExpr(contentHandler, name);
      

    this.contentHandler.endElement(
      "",
      "skin",
      "skin"
    );

    
            }
          }
          
        this.characters("\n\t\t\t");
      

    this.contentHandler.endElement(
      "",
      "skins",
      "skins"
    );

    


                    
    this.comment(" Sitemap properties ");
  
                    

    this.contentHandler.startElement(
      "",
      "sitemap",
      "sitemap",
      xspAttr
    );
    xspAttr.clear();

    
        this.characters("\n                        ");
      
		String[] names=parameters.getNames();
                    try {
                        for (int i=0; i < names.length; i++) {
                            
    xspAttr.addAttribute(
      "",
      "class",
      "class",
      "CDATA",
      "sitemap"
    );
    

    xspAttr.addAttribute(
      "",
      "name",
      "name",
      "CDATA",
      String.valueOf(names[i])
    );
  

    xspAttr.addAttribute(
      "",
      "value",
      "value",
      "CDATA",
      String.valueOf(parameters.getParameter(names[i]))
    );
  

    this.contentHandler.startElement(
      "",
      "key",
      "key",
      xspAttr
    );
    xspAttr.clear();

    
        this.characters("\n\t\t\t\t");
      
        this.characters("\n\t\t\t\t");
      
        this.characters("\n                            ");
      

    this.contentHandler.endElement(
      "",
      "key",
      "key"
    );

    
			}
                    } catch (Exception e) {}

                        
        this.characters("\n                    ");
      

    this.contentHandler.endElement(
      "",
      "sitemap",
      "sitemap"
    );

    

			
			
    this.comment(" Context properties ");
  
			

    this.contentHandler.startElement(
      "",
      "context",
      "context",
      xspAttr
    );
    xspAttr.clear();

    
        this.characters("\n\t\t\t");
      
        this.characters("\t");
      
					for (Enumeration e = context.getAttributeNames() ; e.hasMoreElements() ;) {
         		String key=e.nextElement().toString();

				
    xspAttr.addAttribute(
      "",
      "class",
      "class",
      "CDATA",
      "context"
    );
    

    xspAttr.addAttribute(
      "",
      "name",
      "name",
      "CDATA",
      String.valueOf(key)
    );
  

    this.contentHandler.startElement(
      "",
      "key",
      "key",
      xspAttr
    );
    xspAttr.clear();

    
        this.characters("\n\t\t\t\t\t\t");
      
        this.characters("\n\t\t\t\t\t\t");
      
        
        XSPObjectHelper.xspExpr(contentHandler, context.getAttribute(key));
      
        this.characters("\n\t\t\t\t\t");
      

    this.contentHandler.endElement(
      "",
      "key",
      "key"
    );

    
     			}
     			
        this.characters("\n\t\t\t");
      

    this.contentHandler.endElement(
      "",
      "context",
      "context"
    );

    
			
    this.comment(" System properties ");
  
			    Set allKeys = System.getProperties().keySet();     // turn keys into a set
			    // Turn the Set into an array of Strings
			    String[] keys = (String[])allKeys.toArray(new String[allKeys.size()]);
			    Arrays.sort(keys);  // sort the array
			

    this.contentHandler.startElement(
      "",
      "system",
      "system",
      xspAttr
    );
    xspAttr.clear();

    
        this.characters("\n\t\t\t\t");
      
			    for (int i=0; i < keys.length; i++) {
			      // print each key and its value
			      

    xspAttr.addAttribute(
      "",
      "number",
      "number",
      "CDATA",
      " " + String.valueOf(i) + " "
    );
  

    xspAttr.addAttribute(
      "",
      "name",
      "name",
      "CDATA",
      " " + String.valueOf(keys[i]) + " "
    );
  

    this.contentHandler.startElement(
      "",
      "key",
      "key",
      xspAttr
    );
    xspAttr.clear();

    
        this.characters("\n\t\t\t\t\t\t");
      
        this.characters("\n\t\t\t\t\t\t");
      
        this.characters("\n\t\t\t\t\t\t");
      
        this.characters("\n\t\t\t\t\t\t\t");
      
        
        XSPObjectHelper.xspExpr(contentHandler, System.getProperty(keys[i]));
      
        this.characters("\n\t\t\t\t\t\t");
      
        this.characters("\n\t\t\t\t\t");
      

    this.contentHandler.endElement(
      "",
      "key",
      "key"
    );

    
					}
				
        this.characters("\n\t\t\t");
      

    this.contentHandler.endElement(
      "",
      "system",
      "system"
    );

    			

      }





	// action always fail to give hand to sitemap
	try {	
		if (stop) this.objectModel.put(ServerPagesAction.ACTION_SUCCESS_OBJECT, Boolean.TRUE);
		else this.objectModel.put(ServerPagesAction.ACTION_SUCCESS_OBJECT, Boolean.FALSE);
	} 
	catch (Exception e) {this.objectModel.put(ServerPagesAction.ACTION_SUCCESS_OBJECT, Boolean.FALSE);}
	

        this.characters("\n\t");
      

    this.contentHandler.endElement(
      "",
      "admin",
      "admin"
    );

    
      this.contentHandler.endPrefixMapping(
        "xml"
      );
      
      this.contentHandler.endPrefixMapping(
        "xsp"
      );
      
      this.contentHandler.endPrefixMapping(
        "input"
      );
      

            this.contentHandler.endDocument();

            
            
        }
    }
  
    