/*
 * Created on 10 juil. 2004
 *
 */
package org.apache.cocoon.components.pipeline.impl;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;

import org.apache.cocoon.caching.CachedResponse;
import org.apache.cocoon.caching.CachingOutputStream;
import org.apache.cocoon.environment.Context;
import org.apache.cocoon.environment.Environment;
import org.apache.cocoon.environment.ObjectModelHelper;

/**
 * <h4>A light try to implement a filewriter on caching events</h4>
 * 
 * <p>
 * Every cacheable response should update a filesystem copy of a browsable site.
 * Do the less as possible here, cocoon API is not yet stable on this topic. 
 * </p>
 * 
 * <p> <b>issues</b> -
 * Old files are not deleted, but should be out of navigation.
 * How cache can know that a key is deleted ?
 * Careful, a user may insert XFolio files among other things.
 * Better for now is to let user to manage his files, 
 * and delete what he doen't like. 
 * </p>
 * 
 * TODO: the same for reader
 *
 * @author <a href="mailto:frederic.glorieux@xfolio.org">Frédéric Glorieux</a>
 */
public class XfolioCachingProcessingPipeline extends CachingProcessingPipeline {

    
    /**
     * <dt>Cache longest cacheable key</dt>
     * copy from 
     * <code>org.apache.cocoon.components.pipeline.impl.CachingProcessingPipeline</code>
     * 
     */

    protected void cacheResults(Environment environment, OutputStream os)  throws Exception {
        if (this.toCacheKey != null) {
            // See if there is an expires object for this resource.                
            Long expiresObj = (Long) environment.getObjectModel().get(ObjectModelHelper.EXPIRES_OBJECT);
            if ( this.cacheCompleteResponse ) {
                CachedResponse response = new CachedResponse(this.toCacheSourceValidities,
                                          ((CachingOutputStream)os).getContent(),
                                          expiresObj);
                this.cache.store(this.toCacheKey,
                                 response);
                // here is the moment where a file is written
                writeToFile(environment, os);

            
            } else {
                CachedResponse response = new CachedResponse(this.toCacheSourceValidities,
                                          (byte[])this.xmlSerializer.getSAXFragment(),
                                          expiresObj);
                this.cache.store(this.toCacheKey,
                                 response);
                // here could be a moment but Cocoon don't give the complete response
                // Perhaps it's a good practice to not write 

            }
        }
    }
    
    /**
     * Here is the method to write something somewhere.
     * The root folder is provide like other xfolio parameters
     * as a context parameter.
     * 
     * It's not provide when the component is parametrize, 
     * because it allows dynamic modification, and 
     * same sitemap could be executed by different servlet context.
     *
     */

    protected void writeToFile(Environment environment, OutputStream os)  throws Exception {
		Context ctx = ObjectModelHelper.getContext(environment.getObjectModel());
		// get the root path of where to generate site
		String site=null;
		if (ctx != null) site=(String)ctx.getAttribute("xfolio.site");
		if (site != null && !"".equals(site)) {
		    // FIXME path may be unwaited in case of context call
		    String uri=environment.getURI();
		    // MAYDO better could be done on localisation ?
 		    if (uri==null || "".equals(uri) || uri.lastIndexOf('/')==uri.length()-1) uri += "index.html";
	        File file=new File(new File(site), uri);
	        if (!file.exists()) {
	            file.getParentFile().mkdirs();
	            file.createNewFile();
	        }
	        FileOutputStream fileOS = new FileOutputStream(file);
	        fileOS.write(((CachingOutputStream)os).getContent());
	        fileOS.close();
		}
        
    }
    

}
